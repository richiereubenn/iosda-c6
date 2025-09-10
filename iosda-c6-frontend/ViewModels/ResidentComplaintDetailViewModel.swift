import Foundation
import SwiftUI
import UIKit
@MainActor
class ResidentComplaintDetailViewModel: ObservableObject {
    @Published var selectedComplaint: Complaint2? = nil
    @Published var selectedStatus: ComplaintStatus? = nil
    @Published var firstProgress: ProgressLog2? = nil
    @Published var progressLogs: [ProgressLog2] = []
    @Published var firstProgressFiles: [ProgressFile2] = []

    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var isUpdating = false
    @Published var errorMessage: String?

    private let complaintService: ComplaintServiceProtocol2
    private let progressService: ProgressLogServiceProtocol

    private let baseURL = "https://api.kevinchr.com/complaint"
    
    init(
        complaintService: ComplaintServiceProtocol2 = ComplaintService2(),
        progressService: ProgressLogServiceProtocol = ProgressLogService()
    ) {
        self.complaintService = complaintService
        self.progressService = progressService
    }

    
    // MARK: - Load Complaint

    func loadComplaint(byId id: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let complaint = try await complaintService.getComplaintById(id)
            selectedComplaint = complaint
            selectedStatus = ComplaintStatus(raw: complaint.statusName)
            await loadFirstProgressFiles(for: id)  // Use this method instead
        } catch {
            errorMessage = "Failed to load complaint \(id): \(error.localizedDescription)"
        }
    }

    @MainActor
    func loadFirstProgressFiles(for complaintId: String) async {
        do {
            if let firstProgress = try await progressService.getFirstProgress(complaintId: complaintId) {
                self.firstProgress = firstProgress
                self.firstProgressFiles = firstProgress.files ?? []
            }
        } catch {
            print("Failed to load first progress files:", error)
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

    // MARK: - Update Complaint Status

    func updateStatus(to statusId: String) async {
        guard let complaint = selectedComplaint else {
            errorMessage = "No complaint selected"
            return
        }

        isUpdating = true
        defer { isUpdating = false }

        do {
            let updatedComplaint = try await complaintService.updateComplaintStatus(
                complaintId: complaint.id,
                statusId: statusId
            )

            let complainDetail = try await complaintService.getComplaintById(updatedComplaint.id)

            selectedComplaint = complainDetail
            selectedStatus = ComplaintStatus(raw: complainDetail.statusName)
        } catch {
            errorMessage = "Failed to update status: \(error.localizedDescription)"
        }
    }

    // MARK: - UI Utilities

    func shouldShowActions(for status: ComplaintStatus?) -> Bool {
        guard let status else { return false }
        switch status {
        case .underReview:
            return true
        default:
            return false
        }
    }

    func fullURL(for path: String?) -> String {
        guard let path else { return "" }
        if path.hasPrefix("http") {
            return path
        } else {
            return baseURL + path
        }
    }
}
