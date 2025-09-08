import SwiftUI

struct ProgressDetailView: View {
    @ObservedObject private var viewModel: ComplaintDetailViewModel
    let complaintId: String
    var previewData: [ProgressLog]? = nil // Optional injected data

    init(
        complaintId: String,
        complaintListViewModel: ComplaintListViewModel? = nil,
        previewData: [ProgressLog]? = nil
    ) {
        self.complaintId = complaintId
        self.previewData = previewData
        
        self.viewModel = ComplaintDetailViewModel(
            complaintListViewModel: complaintListViewModel
        )
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading progress logs...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                            let logs = Array(viewModel.progressLogs.reversed())
                            ForEach(Array(logs.enumerated()), id: \.element.id) { index, progressLog in
                                ProgressLogRow(
                                    progressLog: progressLog,
                                    isLast: index == logs.count - 1,
                                    isCurrent: index == logs.count - 1  // mark last (bottom) item as current
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
                   
                    await viewModel.fetchProgressLogs(complaintId: complaintId)
                }
            }
        }
    }
}

#Preview {
    ProgressDetailView(
        complaintId: "1",
        complaintListViewModel: nil,
        previewData: [
            ProgressLog(
                id: "101",
                userId: "1",
                attachmentId: nil,
                title: "Laporan Diterima",
                description: "Pengaduan berhasil dikirim dan diterima oleh sistem.",
                timestamp: ISO8601DateFormatter().date(from: "2025-08-20T10:05:00Z")!,
                files: [
                    File(
                        id: "201",
                        name: "lampiran_foto.jpg",
                        path: "https://via.placeholder.com/300", // Replace with your mock or real URL
                        mimeType: "image/jpeg",
                        otherAttributes: nil,
                        progressFiles: nil
                    )
                ],
                progressFiles: [
                    ProgressFile(
                        id: "301",
                        progressId: "101",
                        fileId: "202",
                        progress: nil,
                        file: File(
                            id: "202",
                            name: "form_pengaduan.pdf",
                            path: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
                            mimeType: "application/pdf",
                            otherAttributes: nil,
                            progressFiles: nil
                        )
                    )
                ]
            ),
            ProgressLog(
                id: "102",
                userId: "2",
                attachmentId: nil,
                title: "Teknisi Dijadwalkan",
                description: "Teknisi akan datang pada 22 Agustus.",
                timestamp: ISO8601DateFormatter().date(from: "2025-08-21T08:00:00Z")!,
                files: nil,
                progressFiles: nil
            )
        ]
    )
}
