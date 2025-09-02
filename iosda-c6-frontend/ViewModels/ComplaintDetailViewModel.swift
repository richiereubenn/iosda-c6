import SwiftUI
import Foundation

@MainActor
class ComplaintDetailViewModel: ObservableObject {
    @Published var progressLogs: [ProgressLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let complaintService: ComplaintServiceProtocol
    private let useMockData = true 
    
   
    private let complaintListViewModel: ComplaintListViewModel?

    init(
        complaintService: ComplaintServiceProtocol = ComplaintService(),
        complaintListViewModel: ComplaintListViewModel? = nil
    ) {
        self.complaintService = complaintService
        self.complaintListViewModel = complaintListViewModel
    }

    func fetchProgressLogs(complaintId: Int) async {
        isLoading = true
        errorMessage = nil

        if useMockData {
        
            if let sharedViewModel = complaintListViewModel {
                progressLogs = sharedViewModel.logs(for: complaintId)
            } else {
  
                progressLogs = getMockProgressLogs(for: complaintId)
            }
            isLoading = false
            return
        }

        // Real backend fetch
        do {
            progressLogs = try await complaintService.fetchProgressLogs(complaintId: complaintId)
        } catch {
            errorMessage = "Failed to load progress logs: \(error.localizedDescription)"
        }

        isLoading = false
    }

    
    private func getMockProgressLogs(for complaintId: Int) -> [ProgressLog] {
        let formatter = ISO8601DateFormatter()
        
        switch complaintId {
        case 1:
            return [
                ProgressLog(
                    id: 101,
                    userId: nil,
                    attachmentId: nil,
                    title: "Complaint Submitted",
                    description: "Complaint submitted, waiting for review.",
                    timestamp: formatter.date(from: "2025-08-20T10:05:00Z"),
                    files: nil,
                    progressFiles: nil
                ),
                ProgressLog(
                    id: 102,
                    userId: nil,
                    attachmentId: nil,
                    title: "Teknisi Dijadwalkan",
                    description: "Teknisi akan datang pada 22 Agustus.",
                    timestamp: formatter.date(from: "2025-08-21T08:00:00Z"),
                    files: nil,
                    progressFiles: nil
                )
            ]
        case 2:
            return [
                ProgressLog(
                    id: 401,
                    userId: nil,
                    attachmentId: nil,
                    title: "Complaint Submitted",
                    description: "Complaint submitted, waiting for review.",
                    timestamp: formatter.date(from: "2025-08-15T09:05:00Z"),
                    files: nil,
                    progressFiles: nil
                ),
                ProgressLog(
                    id: 402,
                    userId: nil,
                    attachmentId: nil,
                    title: "Material Dipesan",
                    description: "Bahan pengganti jendela sudah dipesan.",
                    timestamp: formatter.date(from: "2025-08-16T10:00:00Z"),
                    files: nil,
                    progressFiles: nil
                )
            ]
        case 3:
            return [
                ProgressLog(
                    id: 501,
                    userId: nil,
                    attachmentId: nil,
                    title: "Complaint Submitted",
                    description: "Complaint submitted, waiting for review.",
                    timestamp: formatter.date(from: "2025-07-30T08:10:00Z"),
                    files: nil,
                    progressFiles: nil
                ),
                ProgressLog(
                    id: 502,
                    userId: nil,
                    attachmentId: nil,
                    title: "Masalah Terselesaikan",
                    description: "Listrik sudah kembali normal.",
                    timestamp: formatter.date(from: "2025-08-01T18:00:00Z"),
                    files: nil,
                    progressFiles: nil
                )
            ]
        case 4:
            return [
                ProgressLog(
                    id: 201,
                    userId: nil,
                    attachmentId: nil,
                    title: "Complaint Submitted",
                    description: "Complaint submitted, waiting for review.",
                    timestamp: formatter.date(from: "2025-08-20T11:00:00Z"),
                    files: nil,
                    progressFiles: nil
                )
            ]
        case 5:
            return [
                ProgressLog(
                    id: 301,
                    userId: nil,
                    attachmentId: nil,
                    title: "Complaint Submitted",
                    description: "Complaint submitted, waiting for review.",
                    timestamp: formatter.date(from: "2025-08-20T12:00:00Z"),
                    files: nil,
                    progressFiles: nil
                ),
                ProgressLog(
                    id: 302,
                    userId: nil,
                    attachmentId: nil,
                    title: "Pekerjaan Dimulai",
                    description: "Teknisi sedang memperbaiki keran bocor.",
                    timestamp: formatter.date(from: "2025-08-22T09:00:00Z"),
                    files: nil,
                    progressFiles: nil
                )
            ]
        default:
            return []
        }
    }
}
