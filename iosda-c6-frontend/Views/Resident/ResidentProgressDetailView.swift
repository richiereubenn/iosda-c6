import SwiftUI

struct ResidentProgressDetailView: View {

    @StateObject private var viewModel = ResidentComplaintDetailViewModel()
    
    let complaintId: String
    var previewData: [ProgressLog2]?
    
    var sortedLogs: [ProgressLog2] {
        viewModel.progressLogs.sorted { ($0.timestamp ?? Date.distantPast) > ($1.timestamp ?? Date.distantPast) }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading progress logs...")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if sortedLogs.isEmpty {
                Text("No progress logs available.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(sortedLogs.enumerated()), id: \.element.id) { index, progressLog in
                            ProgressLogRow(
                                progressLog: progressLog,
                                isLast: index == sortedLogs.count - 1,
                                isFirst: index == 0
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
            complaintId: "1",
            previewData: [
                ProgressLog2(
                    id: "101",
                    complaintId: nil,
                    userId: "1",
                    title: "Laporan Diterima",
                    description: "Pengaduan berhasil dikirim dan diterima oleh sistem.",
                    timestamp: ISO8601DateFormatter().date(from: "2025-08-20T10:05:00Z")!,
                    createdAt: nil,
                    updatedAt: nil,
                    files: []
                ),
                ProgressLog2(
                    id: "102",
                    complaintId: nil,
                    userId: "2",
                    title: "Teknisi Dijadwalkan",
                    description: "Teknisi akan datang pada 22 Agustus.",
                    timestamp: ISO8601DateFormatter().date(from: "2025-08-21T08:00:00Z")!,
                    createdAt: nil,
                    updatedAt: nil,
                    files: nil
                )
            ]
        )
    }
}


#Preview {
    NavigationStack {
        ResidentProgressDetailView(
            complaintId: "1",
            previewData: [
                ProgressLog2(
                    id: "101",
                    complaintId: nil,
                    userId: "1",
                    title: "Laporan Diterima",
                    description: "Pengaduan berhasil dikirim dan diterima oleh sistem.",
                    timestamp: ISO8601DateFormatter().date(from: "2025-08-20T10:05:00Z"),
                    createdAt: nil,
                    updatedAt: nil,
                    files: []  // empty array for files
                ),
                ProgressLog2(
                    id: "102",
                    complaintId: nil,
                    userId: "2",
                    title: "Teknisi Dijadwalkan",
                    description: "Teknisi akan datang pada 22 Agustus.",
                    timestamp: ISO8601DateFormatter().date(from: "2025-08-21T08:00:00Z"),
                    createdAt: nil,
                    updatedAt: nil,
                    files: nil  // no files
                )
            ]
        )
    }
}

