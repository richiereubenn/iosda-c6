//
//  ResidentAddComplaintViewModel.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 13/09/25.
//


import Foundation
import SwiftUI
import PhotosUI

@MainActor
class ResidentAddComplaintViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var complaints: [Complaint2] = []
    @Published var userId: String? = nil
    
    @Published var closeUpImage: UIImage? = nil
    @Published var overallImage: UIImage? = nil
    
    @Published var currentImageType: ImageType = .closeUp
    @Published private var closeUpPhotoItem: PhotosPickerItem? = nil
    @Published private var overallPhotoItem: PhotosPickerItem? = nil
    
    enum ImageType {
        case closeUp
        case overall
        
        var title: String {
            switch self {
            case .closeUp:
                return "Close-up Photo"
            case .overall:
                return "Overall Photo"
            }
        }
    }
    
    private let unitService: UnitServiceProtocol2
    private let complaintService: ComplaintServiceProtocol2
    private let progressLogService: ProgressLogServiceProtocol
    private let classificationService: ClassificationServiceProtocol
    private let classificationAI: ClassificationAIServiceProtocol
    private var unitListViewModel: ResidentUnitListViewModel
    
    init(
        complaintService: ComplaintServiceProtocol2 = ComplaintService2(),
        unitService: UnitServiceProtocol2 = UnitService2(),
        progressLogService: ProgressLogServiceProtocol = ProgressLogService(), // Add this
        classificationService: ClassificationServiceProtocol = ClassificationService(),
        classificationAI: ClassificationAIServiceProtocol = ClassificationAIService()
        
    ) {
        self.complaintService = complaintService
        self.unitService = unitService
        self.progressLogService = progressLogService  // Add this
        self.classificationService = classificationService
        self.classificationAI = classificationAI
        self.unitListViewModel = ResidentUnitListViewModel()
        
        Task { @MainActor in
            self.unitListViewModel = ResidentUnitListViewModel()
        }
    }
    
    func submitComplaint(request: CreateComplaintRequest2, selectedUnit: Unit2) async {
        isLoading = true
        errorMessage = nil
        
        var complaintCreated = false
        
        do {
            let fixedStatusId = "661a5a05-730b-4dc3-a924-251a1db7a2d7"
            
            // 1️⃣ Initial request (classificationId nil at creation time)
            let initialRequest = CreateComplaintRequest2(
                unitId: request.unitId,
                userId: request.userId,
                statusId: fixedStatusId,
                classificationId: nil, // defer classification
                title: request.title,
                description: request.description,
                latitude: request.latitude,
                longitude: request.longitude,
                handoverMethod: request.handoverMethod,
                keyHandoverDate: nil,
                keyHandoverNote: nil
            )
            
            // 2️⃣ Update unit key handover if available
            if let keyDate = selectedUnit.keyHandoverDate {
                await unitListViewModel.loadUnits()
                let note = selectedUnit.keyHandoverNote ?? ""
                
                try await unitListViewModel.updateKeyHandoverDate(
                    unitId: selectedUnit.id,
                    keyDate: keyDate,
                    note: note
                )
            }
            
            // 3️⃣ Submit complaint immediately - THIS IS THE CRITICAL STEP
            let submittedComplaint = try await complaintService.submitComplaint(request: initialRequest)
            print("Complaint created immediately with ID: \(submittedComplaint.id)")
            complaintCreated = true // Mark as successful
            
            // 5️⃣ Create initial progress log - Handle image upload failures gracefully
            do {
                let _ = try await createInitialProgressLog(
                    complaintId: submittedComplaint.id,
                    userId: request.userId,
                    title: request.title
                )
                print("Progress log created successfully")
            } catch {
                print("Progress log creation failed: \(error.localizedDescription)")
                // Create a basic progress log without images as fallback
                let _ = try await progressLogService.createProgress(
                    complaintId: submittedComplaint.id,
                    userId: request.userId,
                    title: request.title,
                    description: "Complaint Submitted and is Under Review by BSC (Images failed to upload)",
                    files: nil
                )
                print("Fallback progress log created without images")
            }
            
            // 6️⃣ Refresh local list (don't let this fail the whole submission)
            do {
                await loadComplaints(byUserId: request.userId)
                print("Complaint list refreshed successfully")
            } catch {
                print("Failed to refresh complaint list, but submission was successful: \(error.localizedDescription)")
                // Don't propagate this error - the complaint was created successfully
            }
            
            // Clean up UI state
            closeUpImage = nil
            overallImage = nil
            closeUpPhotoItem = nil
            overallPhotoItem = nil
            
   
            // 7️⃣ Fire off AI classification in background
            Task { @MainActor in
                await self.classifyComplaint(
                    complaintId: submittedComplaint.id,
                    description: request.description
                )
            }


            
        } catch {
            print("Error submitting complaint: \(error.localizedDescription)")
            
            // Only show error if complaint creation actually failed
            if !complaintCreated {
                errorMessage = "Failed to submit complaint. Please try again later."
            } else {
                // Complaint was created but something else failed
                print("Complaint created successfully but post-processing failed: \(error.localizedDescription)")
                // Don't show error to user since their complaint was successfully submitted
            }
        }
        
        isLoading = false
    }
    
    private func classifyComplaint(complaintId: String, description: String) {
        print("Starting classification for complaint: \(complaintId)")
        
        Task.detached { [weak self] in
            guard let self else { return }
            
            do {
                // First attempt with raw description
                let classificationRequest = ClassificationRequest(complaintDetail: description)
                print("Sending classification request for: \(complaintId)")
                
                let classificationResult = try await self.classificationAI.getClassification(request: classificationRequest)
                let classificationId = classificationResult.classificationId
                print("AI classified complaint \(complaintId) as: \(classificationId)")
                
                try await self.complaintService.updateComplaintClassification(
                    complaintId: complaintId,
                    classificationId: classificationId
                )
                print("Successfully updated complaint \(complaintId) with classification \(classificationId)")
                
            } catch {
                print("Classification failed for complaint \(complaintId): \(error)")
                
                // Retry with enhanced context
                print("Retrying classification with more context...")
                do {
                    let retryDescription = """
                    Complaint details: \(description)

                    Context: This is a resident-submitted complaint related to property maintenance.
                    Priority: Standard review by BSC.
                    """
                    let retryRequest = ClassificationRequest(complaintDetail: retryDescription)
                    
                    let retryResult = try await self.classificationAI.getClassification(request: retryRequest)
                    let retryId = retryResult.classificationId
                    
                    try await self.complaintService.updateComplaintClassification(
                        complaintId: complaintId,
                        classificationId: retryId
                    )
                    print("Successfully updated complaint \(complaintId) on retry: \(retryId)")
                    
                } catch {
                    print("Retry classification also failed for complaint \(complaintId): \(error)")
                }
            }
        }
    }

    

    
    func loadComplaints(byUserId userId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            complaints = try await complaintService.getComplaintsByUserId(userId)
        } catch {
            errorMessage = "Failed to load your complaints: \(error.localizedDescription)"
        }
    }
    
    func submitInHouseComplaint(
        title: String,
        description: String,
        unitId: String,
        userId: String,
        statusId: String,
        latitude: Double,
        longitude: Double,
        handoverMethod: HandoverMethod,
        selectedUnit: Unit2
    ) async {
        isLoading = true
        errorMessage = nil
        
        var complaintCreated = false
        
        do {
            let fixedStatusId = "661a5a05-730b-4dc3-a924-251a1db7a2d7"
            
            // 1️⃣ Create in-house complaint request with nil keyHandoverDate and keyHandoverNote
            let inhouseRequest = CreateComplaintRequest2(
                unitId: unitId,
                userId: userId,
                statusId: fixedStatusId,
                classificationId: nil, // Will be set by AI
                title: title,
                description: description,
                latitude: latitude,
                longitude: longitude,
                handoverMethod: handoverMethod,
                keyHandoverDate: nil,    // ← Always nil for in-house
                keyHandoverNote: nil     // ← Always nil for in-house
            )
            
            // 2️⃣ Submit in-house complaint
            let submittedComplaint = try await complaintService.submitComplaint(request: inhouseRequest)
            print("In-house complaint created with ID: \(submittedComplaint.id)")
            complaintCreated = true
            
            // 3️⃣ Create initial progress log
            do {
                let _ = try await createInitialProgressLog(
                    complaintId: submittedComplaint.id,
                    userId: userId,
                    title: title
                )
                print("In-house progress log created successfully")
            } catch {
                print("In-house progress log creation failed: \(error.localizedDescription)")
                // Create fallback progress log without images
                let _ = try await progressLogService.createProgress(
                    complaintId: submittedComplaint.id,
                    userId: userId,
                    title: title,
                    description: "In-house Complaint Submitted and is Under Review by BSC (Images failed to upload)",
                    files: nil
                )
                print("Fallback in-house progress log created without images")
            }
            
            // 4️⃣ Refresh complaints list
            do {
                await loadComplaints(byUserId: userId)
                print("In-house complaint list refreshed successfully")
            } catch {
                print("Failed to refresh in-house complaint list, but submission was successful: \(error.localizedDescription)")
            }
            
            // 5️⃣ Clean up UI state
            closeUpImage = nil
            overallImage = nil
            closeUpPhotoItem = nil
            overallPhotoItem = nil
            
            // 6️⃣ Fire off AI classification for in-house complaint with enhanced description
            // 6️⃣ Fire off AI classification for in-house complaint
            Task.detached { [weak self] in
                guard let self else { return }
                
                do {
                    // First try with the raw description (same as submitComplaint)
                    let classificationRequest = ClassificationRequest(complaintDetail: description)
                    print("Sending in-house classification request for: \(submittedComplaint.id)")
                    
                    let classificationResult = try await self.classificationAI.getClassification(request: classificationRequest)
                    let classificationId = classificationResult.classificationId
                    print("AI classified in-house complaint \(submittedComplaint.id) as: \(classificationId)")
                    
                    try await self.complaintService.updateComplaintClassification(
                        complaintId: submittedComplaint.id,
                        classificationId: classificationId
                    )
                    print("Successfully updated in-house complaint \(submittedComplaint.id) with classification \(classificationId)")
                    
                } catch {
                    print("In-house classification failed for complaint \(submittedComplaint.id): \(error)")
                    
                    // Retry with enhanced description for more context
                    print("Retrying in-house classification with more context...")
                    do {
                        let retryDescription = """
                        Property maintenance issue: \(description)

                        Type: In-house complaint
                        Priority: Standard maintenance
                        Location: Residential unit
                        """
                        let retryRequest = ClassificationRequest(complaintDetail: retryDescription)
                        
                        let retryResult = try await self.classificationAI.getClassification(request: retryRequest)
                        let retryId = retryResult.classificationId
                        
                        try await self.complaintService.updateComplaintClassification(
                            complaintId: submittedComplaint.id,
                            classificationId: retryId
                        )
                        print("Successfully updated in-house complaint on retry: \(retryId)")
                        
                    } catch {
                        print("In-house classification retry also failed: \(error)")
                    }
                }
            }

            
        } catch {
            print("Error submitting in-house complaint: \(error.localizedDescription)")
            
            if !complaintCreated {
                errorMessage = "Failed to submit in-house complaint. Please try again later."
            } else {
                print("In-house complaint created successfully but post-processing failed: \(error.localizedDescription)")
            }
        }
        
        isLoading = false
    }
    
//    func submitInHouseComplaint(
//        title: String,
//        description: String,
//        unitId: String,
//        userId: String,
//        statusId: String,
//        //classificationId: String,
//        latitude: Double,
//        longitude: Double,
//        handoverMethod: HandoverMethod,
//        selectedUnit: Unit2
//    ) async {
//        let fixedStatusId = "661a5a05-730b-4dc3-a924-251a1db7a2d7"
//        // Create request without key handover date and note
//        let request = CreateComplaintRequest2(
//            unitId: unitId,
//            userId: userId,
//            statusId: fixedStatusId,
//            classificationId: nil,
//            title: title,
//            description: description,
//            latitude: latitude,
//            longitude: longitude,
//            handoverMethod: handoverMethod,
//            keyHandoverDate: nil,
//            keyHandoverNote: nil
//        )
//
//        await submitComplaint(request: request, selectedUnit: selectedUnit)
//    }
    
    private func createInitialProgressLog(
        complaintId: String,
        userId: String,
        title: String
    ) async throws -> ProgressLog2 {
        let images = allImages
        
        if images.isEmpty {
            return try await progressLogService.createProgress(
                complaintId: complaintId,
                userId: userId,
                title: title,
                description: "Complaint Submitted and is Under Review by BSC",
                files: nil
            )
        } else {
            return try await progressLogService.uploadProgressWithFiles(
                complaintId: complaintId,
                userId: userId,
                title: title,
                description: "Complaint Submitted and is Under Review by BSC",
                images: images
            )
        }
    }
    
    
    
    func getPhotoItem(for type: ImageType) -> PhotosPickerItem? {
        switch type {
        case .closeUp: return closeUpPhotoItem
        case .overall: return overallPhotoItem
        }
    }
    
    // Add setter
    func setPhotoItem(_ item: PhotosPickerItem?, for type: ImageType) {
        switch type {
        case .closeUp:
            closeUpPhotoItem = item
        case .overall:
            overallPhotoItem = item
        }
        
        guard let item = item else { return }
        
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    switch type {
                    case .closeUp:
                        closeUpImage = image
                    case .overall:
                        overallImage = image
                    }
                } else {
                    errorMessage = "Failed to load image"
                }
            } catch {
                errorMessage = "Image loading error: \(error.localizedDescription)"
            }
        }
    }
    
    func getImage(for type: ImageType) -> UIImage? {
        switch type {
        case .closeUp: return closeUpImage
        case .overall: return overallImage
        }
    }
    
    func removeImage(for type: ImageType) {
        switch type {
        case .closeUp:
            closeUpImage = nil
            closeUpPhotoItem = nil
        case .overall:
            overallImage = nil
            overallPhotoItem = nil
        }
    }
    
    var hasImages: Bool {
        return closeUpImage != nil || overallImage != nil
    }
    
    var allImages: [UIImage] {
        var ordered: [UIImage] = []
        if let closeUp = closeUpImage {
            ordered.append(closeUp)
        }
        if let overall = overallImage {
            ordered.append(overall)
        }
        return ordered
    }
}
