import Foundation
import SwiftUI

@MainActor
class ResidentComplaintDetailViewModel: ObservableObject {
    @Published var selectedComplaint: Complaint2? = nil
    @Published var selectedStatus: ComplaintStatus? = nil
    @Published var isLoading: Bool = false
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String? = nil
    @Published var firstProgress: ProgressLog2? = nil
    @Published var progressLogs: [ProgressLog2] = []
    @Published var isSubmitting: Bool = false
    
    private let service: ComplaintServiceProtocol2
    private let progressService: ProgressLogServiceProtocol
    
    static let baseURL = "https://api.kevinchr.com/complaint"
    
    init(
        service: ComplaintServiceProtocol2 = ComplaintService2(),
        progressService: ProgressLogServiceProtocol = ProgressLogService()
    ) {
        self.service = service
        self.progressService = progressService
    }
    
    func loadComplaint(byId id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let complaint = try await service.getComplaintById(id)
            selectedComplaint = complaint
            selectedStatus = ComplaintStatus(raw: complaint.statusName)
            
            await loadFirstProgress(for: id)
        } catch {
            errorMessage = "Failed to load complaint \(id): \(error.localizedDescription)"
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

}
