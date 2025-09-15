import Foundation
import SwiftUI

@MainActor
class ResidentComplaintDetailViewModel: ObservableObject {
    @Published var selectedComplaint: Complaint2? = nil
    @Published var selectedUnit: Unit2? = nil
    @Published var selectedStatus: ComplaintStatus? = nil
    @Published var isLoading: Bool = false
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String? = nil
    @Published var firstProgress: ProgressLog2? = nil
    @Published var progressLogs: [ProgressLog2] = []
    @Published var isSubmitting: Bool = false
    
    private let service: ComplaintServiceProtocol2
    private let unitService: UnitServiceProtocol2
    private let progressService: ProgressLogServiceProtocol
    private let keyLogService: KeyLogServiceProtocol
    
    static let baseURL = "https://api.kevinchr.com/complaint"
    
    init(
           service: ComplaintServiceProtocol2 = ComplaintService2(),
           progressService: ProgressLogServiceProtocol = ProgressLogService(),
           unitService: UnitServiceProtocol2 = UnitService2(),
           keyLogService: KeyLogServiceProtocol = KeyLogService()
       ) {
           self.service = service
           self.progressService = progressService
           self.unitService = unitService
           self.keyLogService = keyLogService
       }
    
    func loadComplaint(byId id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let complaint = try await service.getComplaintById(id)
            selectedComplaint = complaint
            selectedStatus = ComplaintStatus(raw: complaint.statusName)
            
            if let unitId = complaint.unitId {
                await loadUnit(byId: unitId)
            }
            
            await loadFirstProgress(for: id)
        } catch {
            errorMessage = "Failed to load complaint \(id): \(error.localizedDescription)"
        }
    }


    
    func loadUnit(byId id: String) async {
        do {
            let unit = try await unitService.getUnitById(id)
            selectedUnit = unit
        } catch {
            errorMessage = "Failed to load unit: \(error.localizedDescription)"
            selectedUnit = nil
        }
    }


    
    private func loadFirstProgress(for complaintId: String) async {
        do {
            firstProgress = try await progressService.getFirstProgress(complaintId: complaintId)
        } catch {
            print("Failed to load first progress: \(error.localizedDescription)")
        }
    }
    
    func updateStatus(to statusId: String) async {
        guard let complaint = selectedComplaint else {
            errorMessage = "No complaint selected"
            return
        }
        
        isUpdating = true
        defer { isUpdating = false }
        
        do {
            let updatedComplaint = try await service.updateComplaintStatus(
                complaintId: complaint.id,
                statusId: statusId
            )
            
            let complainDetail = try await service.getComplaintById(updatedComplaint.id)
            
            selectedComplaint = complainDetail
            selectedStatus = ComplaintStatus(raw: complainDetail.statusName)
        } catch {
            errorMessage = "Failed to update status: \(error.localizedDescription)"
        }
    }
    
    func shouldShowActions(for status: ComplaintStatus?) -> Bool {
        guard let status else { return false }
        switch status {
        case .underReviewbByBSC:
            return true
        default:
            return false
        }
    }
    
    var firstProgressImageURLs: [String] {
        guard let oldestLog = progressLogs.sorted(by: {
            ($0.timestamp ?? .distantFuture) < ($1.timestamp ?? .distantFuture)
        }).first else {
            return []
        }
        
        return oldestLog.files?.compactMap {
            ResidentComplaintDetailViewModel.fullURL(for: $0.url)
        } ?? []
    }

    
    var allProgressImageURLs: [String] {
        progressLogs.flatMap { log in
            log.files?.compactMap { file in
                ResidentComplaintDetailViewModel.fullURL(for: file.url)
            } ?? []
        }
    }

    
    static func fullURL(for path: String?) -> String {
        guard let path else { return "" }
        if path.hasPrefix("http") {
            return path
        } else {
            return baseURL + path
        }
    }
    
    func submitRejectionProgress(complaintId: String,
                                 userId: String,
                                 reason: String) async {
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            _ = try await progressService.createProgress(
                complaintId: complaintId,
                userId: userId,
                title: "reject info",
                description: reason,
                files: nil
            )
        } catch {
            errorMessage = "Failed to create rejection progress: \(error.localizedDescription)"
        }
    }
    
    func submitStartWorkProgress(
            complaintId: String,
            userId: String,
            images: [UIImage],
            title: String,
            description: String
        ) async {
            isSubmitting = true
            defer { isSubmitting = false }
            
            do {
                _ = try await progressService.uploadProgressWithFiles(
                    complaintId: complaintId,
                    userId: userId,
                    title: title,
                    description: description,
                    images: images
                )
            } catch {
                errorMessage = "Failed to create start work progress: \(error.localizedDescription)"
            }
        }
    
    func getProgressLogs(complaintId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let logs = try await progressService.getAllProgress(complaintId: complaintId)
            progressLogs = logs
        } catch {
            errorMessage = "Failed to load progress logs: \(error.localizedDescription)"
        }

        isLoading = false
    }
    
    // Replace your submitKeyHandoverEvidence function with this debug version:

    // Replace your submitKeyHandoverEvidence function with this fixed version:

    func submitKeyHandoverEvidence(
        complaintId: String,
        unitId: String?,
        userId: String,
        description: String = "Key handover submitted"
    ) async -> KeyLog? {
        do {
            print("📤 Submitting key handover evidence with description: '\(description)'")

            // 1️⃣ Progress log
            print("📝 Creating progress log...")
            _ = try await progressService.createProgress(
                complaintId: complaintId,
                userId: userId,
                title: "Submitted Key",
                description: description,
                files: nil
            )
            print("✅ Progress log created successfully")

            // 2️⃣ Key log (use unitId passed in)
            var createdKeyLog: KeyLog? = nil
            if let unitId = unitId {
                print("🗝️ Creating key log...")
                createdKeyLog = try await keyLogService.createKeyLog(
                    unitId: unitId,
                    userId: userId,
                    detail: "bsc"
                )
                print("✅ Key log created with detail 'bsc': \(createdKeyLog!)")
            } else {
                print("⚠️ No unitId found, cannot create key log")
            }

            // 3️⃣ Update complaint status - FIX: Use complaintId directly
            print("🔄 Updating complaint status...")
            print("🔍 selectedComplaint before status update: \(selectedComplaint?.id ?? "nil")")
            
            // Use the service directly instead of the updateStatus function
            do {
                let updatedComplaint = try await service.updateComplaintStatus(
                    complaintId: complaintId,  // Use the passed complaintId directly
                    statusId: "06d2b0a3-afc8-400c-b4b4-bdcee995f35f"
                )
                print("✅ Status update API call successful")
                
                // Update the selectedComplaint
                let complainDetail = try await service.getComplaintById(updatedComplaint.id)
                selectedComplaint = complainDetail
                selectedStatus = ComplaintStatus(raw: complainDetail.statusName)
                
            } catch {
                print("❌ Status update failed: \(error)")
                errorMessage = "Failed to update status: \(error.localizedDescription)"
            }

            // 4️⃣ Refresh complaint data
            print("🔄 Refreshing progress logs...")
            await getProgressLogs(complaintId: complaintId)
            print("✅ Data refresh completed")

            return createdKeyLog

        } catch {
            print("❌ Error in submitKeyHandoverEvidence: \(error)")
            errorMessage = "❌ Failed to submit key handover: \(error.localizedDescription)"
            return nil
        }
    }
}

