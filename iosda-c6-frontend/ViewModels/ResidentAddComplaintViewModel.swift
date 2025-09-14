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
    private var unitListViewModel: ResidentUnitListViewModel

    init(
           complaintService: ComplaintServiceProtocol2 = ComplaintService2(),
           unitService: UnitServiceProtocol2 = UnitService2(),
           progressLogService: ProgressLogServiceProtocol = ProgressLogService()  // Add this
       ) {
           self.complaintService = complaintService
           self.unitService = unitService
           self.progressLogService = progressLogService  // Add this
           self.unitListViewModel = ResidentUnitListViewModel()

           Task { @MainActor in
               self.unitListViewModel = ResidentUnitListViewModel()
           }
       }

    func submitComplaint(request: CreateComplaintRequest2, selectedUnit: Unit2) async {
          isLoading = true
          errorMessage = nil
        
        print("🏠 === VIEWMODEL DEBUG ===")
            print("🏠 Received selectedUnit.id: \(selectedUnit.id)")
            print("🗓️ Received selectedUnit.keyHandoverDate: \(selectedUnit.keyHandoverDate?.ISO8601Format() ?? "nil")")
            print("📝 Received selectedUnit.keyHandoverNote: \(selectedUnit.keyHandoverNote ?? "nil")")
            print("🗓️ Current Date() in ViewModel: \(Date().ISO8601Format())")
            print("🏠 === END VIEWMODEL DEBUG ===")

          let fixedStatusId = "661a5a05-730b-4dc3-a924-251a1db7a2d7"  // Example status ID

          // Compose the full complaint request without key handover info (handled separately)
          let fullRequest = CreateComplaintRequest2(
              unitId: request.unitId,
              userId: request.userId,
              statusId: fixedStatusId,
              classificationId: request.classificationId,
              title: request.title,
              description: request.description,
              latitude: request.latitude,
              longitude: request.longitude,
              handoverMethod: request.handoverMethod,
              keyHandoverDate: nil,  // handled separately
              keyHandoverNote: nil   // handled separately
          )

        do {
                // Step 1: Update unit's key handover date & note (if available)
                if let keyDate = selectedUnit.keyHandoverDate {
                    print("📦 Updating key handover date: \(keyDate)")
                    print("📦 Key date ISO8601: \(keyDate.ISO8601Format())")
                    
                    await unitListViewModel.loadUnits()
                    // If there is a key handover note, include it
                    let note = selectedUnit.keyHandoverNote ?? ""  // Use empty string if note is nil
                    
                    print("🔄 About to call updateKeyHandoverDate with:")
                               print("🔄 unitId: \(selectedUnit.id)")
                               print("🔄 keyDate: \(keyDate.ISO8601Format())")
                               print("🔄 note: '\(note)'")

                    // Update the unit with the key handover details
                    try await unitListViewModel.updateKeyHandoverDate(
                        unitId: selectedUnit.id,
                        keyDate: keyDate,
                        note: note
                    )
                    print("✅ Successfully updated key handover date")
                } else {
                    print("⚠️ selectedUnit.keyHandoverDate is nil - no update will be performed")
                }

            let submittedComplaint = try await complaintService.submitComplaint(request: fullRequest)
                        print("✅ Successfully submitted complaint with ID: \(submittedComplaint.id)")

                        // Step 3: Create initial progress log
//            do {
//                           let progressLog = try await progressLogService.createProgress(
//                               complaintId: submittedComplaint.id,  // Direct access since it's not optional
//                               userId: request.userId,
//                               title: request.title,
//                               description: "Complaint Submitted and is Under Review by BSC",
//                               files: nil
//                           )
//                           print("✅ Successfully created progress log: \(progressLog.id ?? "unknown")")
//                       } catch {
//                           print("⚠️ Failed to create progress log: \(error.localizedDescription)")
//                           // Don't fail the entire process if progress log creation fails
//                       }
            let progressLog = try await createInitialProgressLog(
                complaintId: submittedComplaint.id,
                userId: request.userId,
                title: request.title
            )



                // Step 3: Refresh the complaints list to show updated complaints
                await loadComplaints()
            // Clear photo state after successful submission
            closeUpImage = nil
            overallImage = nil
            closeUpPhotoItem = nil
            overallPhotoItem = nil


            } catch {
                print("❌ Error submitting complaint or updating unit: \(error.localizedDescription)")
                errorMessage = "Failed to submit complaint. Please try again later."
            }

            isLoading = false
        }

    func loadComplaints() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            complaints = try await complaintService.getAllComplaints()
        } catch {
            print("❌ Failed to load complaints: \(error.localizedDescription)")
            errorMessage = "Failed to load complaints."
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
