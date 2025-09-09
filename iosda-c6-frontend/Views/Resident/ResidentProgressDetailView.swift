import SwiftUI

struct ResidentProgressDetailView: View {

    @StateObject private var viewModel: ResidentComplaintDetailViewModel
    
    let complaintId: String
    var previewData: [ProgressLog]?
    
    init(complaintId: String, complaintListViewModel: ComplaintListViewModel2, previewData: [ProgressLog]? = nil) {
        self.complaintId = complaintId
        self.previewData = previewData
        _viewModel = StateObject(wrappedValue: ResidentComplaintDetailViewModel())
    }

    var body: some View {
        // 3. The unnecessary NavigationView has been removed.
        // The view should rely on the parent NavigationStack for its title and toolbar.
        Group {
            if viewModel.isLoading {
                ProgressView("Loading progress logs...")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.progressLogs.isEmpty {
                Text("No progress logs available.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        // Reverse the logs so the newest is at the top
                        let logs = Array(viewModel.progressLogs.reversed())
                        
                        ForEach(Array(logs.enumerated()), id: \.element.id) { index, progressLog in
                            ProgressLogRow(
                                progressLog: progressLog,
                                isLast: index == logs.count - 1,
                                // 4. The current log is now the FIRST item after reversing
                                isCurrent: index == 0
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
        }
        .navigationTitle("Progress Detail")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let previewData = previewData {
                viewModel.progressLogs = previewData
                viewModel.isLoading = false
            } else {
                await viewModel.getProgressLogs(complaintId: complaintId)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ResidentProgressDetailView(
            complaintId: "1", complaintListViewModel: ComplaintListViewModel2(),
            previewData: [
                ProgressLog(
                    id: "101", userId: "1", attachmentId: nil,
                    title: "Laporan Diterima",
                    description: "Pengaduan berhasil dikirim dan diterima oleh sistem.",
                    timestamp: ISO8601DateFormatter().date(from: "2025-08-20T10:05:00Z")!,
                    files: [], progressFiles: []
                ),
                ProgressLog(
                    id: "102", userId: "2", attachmentId: nil,
                    title: "Teknisi Dijadwalkan",
                    description: "Teknisi akan datang pada 22 Agustus.",
                    timestamp: ISO8601DateFormatter().date(from: "2025-08-21T08:00:00Z")!,
                    files: nil, progressFiles: nil
                )
            ]
        )
    }
}
