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
            
            if let keyDate = selectedUnit.keyHandoverDate {
                await unitListViewModel.loadUnits()
                let note = selectedUnit.keyHandoverNote ?? ""
                
                try await unitListViewModel.updateKeyHandoverDate(
                    unitId: selectedUnit.id,
                    keyDate: keyDate,
                    note: note
                )
            }
            
            let submittedComplaint = try await complaintService.submitComplaint(request: initialRequest)
            print("✅ Complaint created immediately with ID: \(submittedComplaint.id)")
            complaintCreated = true
            do {
                let _ = try await createInitialProgressLog(
                    complaintId: submittedComplaint.id,
                    userId: request.userId,
                    title: request.title
                )
                print("✅ Progress log created successfully")
            } catch {
                print("⚠️ Progress log creation failed: \(error.localizedDescription)")
                let _ = try await progressLogService.createProgress(
                    complaintId: submittedComplaint.id,
                    userId: request.userId,
                    title: request.title,
                    description: "Complaint Submitted and is Under Review by BSC (Images failed to upload)",
                    files: nil
                )
                print("✅ Fallback progress log created without images")
            }
            
            do {
                await loadComplaints(byUserId: request.userId)
                print("✅ Complaint list refreshed successfully")
            } catch {
                print("⚠️ Failed to refresh complaint list, but submission was successful: \(error.localizedDescription)")
            }
            
            // Clean up UI state
            closeUpImage = nil
            overallImage = nil
            closeUpPhotoItem = nil
            overallPhotoItem = nil
            
            // 4️⃣ Fire off AI classification in background - MOVED TO END
            // Don't let this affect the main complaint creation success
            Task.detached { [weak self] in
                do {
                    let classificationRequest = ClassificationRequest(complaintDetail: request.description)
                    let classificationResult = try await ClassificationAIService().getClassification(request: classificationRequest)
                    let classificationId = classificationResult.classificationId
                    print("🤖 AI classified complaint as \(classificationId)")
                    
                    // Update the complaint with classification
                    try await ComplaintService2().updateComplaintClassification(
                        complaintId: submittedComplaint.id,
                        classificationId: classificationId
                    )
                    print("✅ Complaint updated with classification")
                } catch {
                    print("⚠️ Classification failed for complaint \(submittedComplaint.id): \(error.localizedDescription)")
                    // Don't propagate this error to the UI since complaint creation succeeded
                }
            }
            
        } catch {
            print("❌ Error submitting complaint: \(error.localizedDescription)")
            
            // Only show error if complaint creation actually failed
            if !complaintCreated {
                errorMessage = "Failed to submit complaint. Please try again later."
            } else {
                // Complaint was created but something else failed
                print("⚠️ Complaint created successfully but post-processing failed: \(error.localizedDescription)")
                // Don't show error to user since their complaint was successfully submitted
            }
        }
        
        isLoading = false
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
        classificationId: String,
        latitude: Double,
        longitude: Double,
        handoverMethod: HandoverMethod,
        selectedUnit: Unit2
    ) async {
        let fixedStatusId = "661a5a05-730b-4dc3-a924-251a1db7a2d7"
        // Create request without key handover date and note
        let request = CreateComplaintRequest2(
            unitId: unitId,
            userId: userId,
            statusId: fixedStatusId,
            classificationId: classificationId,
            title: title,
            description: description,
            latitude: latitude,
            longitude: longitude,
            handoverMethod: handoverMethod,
            keyHandoverDate: nil,
            keyHandoverNote: nil
        )
        
        await submitComplaint(request: request, selectedUnit: selectedUnit)
    }
    
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
