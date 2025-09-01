import SwiftUI

struct ProgressDetailView: View {
    let progressLogs: [ProgressLog]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(progressLogs.enumerated()), id: \.element.id) { index, progressLog in
                        ProgressLogRow(
                            progressLog: progressLog,
                            isLast: index == progressLogs.count - 1
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Progress Detail")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
struct ProgressDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressDetailView(progressLogs: sampleProgressLogs)
    }
    
    static let sampleProgressLogs: [ProgressLog] = [
        ProgressLog(
            id: 1,
            userId: 1,
            attachmentId: nil,
            title: "Sedang di tangani oleh satpam",
            description: "Paket sedang dalam proses verifikasi",
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            files: nil,
            progressFiles: nil
        ),
        ProgressLog(
            id: 2,
            userId: 1,
            attachmentId: 1,
            title: "Laporan diserahkan ke satpam",
            description: "Dokumentasi lengkap telah diserahkan",
            timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
            files: [
                File(id: 1, name: "photo1.jpg", path: "https://example.com/image1.jpg", mimeType: "image/jpeg", otherAttributes: nil, progressFiles: nil),
                File(id: 2, name: "photo2.jpg", path: "https://example.com/image2.jpg", mimeType: "image/jpeg", otherAttributes: nil, progressFiles: nil)
            ],
            progressFiles: nil
        ),
        ProgressLog(
            id: 3,
            userId: 1,
            attachmentId: 2,
            title: "Laporan diterima CRO",
            description: "Customer Relations Officer telah menerima laporan",
            timestamp: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
            files: nil,
            progressFiles: [
                ProgressFile(id: 1, progressId: 3, fileId: 3, progress: nil,
                           file: File(id: 3, name: "report.pdf", path: "/documents/report.pdf",
                                    mimeType: "application/pdf", otherAttributes: nil, progressFiles: nil))
            ]
        ),
        ProgressLog(
            id: 4,
            userId: 1,
            attachmentId: nil,
            title: "Laporan masuk",
            description: "Laporan berhasil diterima sistem",
            timestamp: Calendar.current.date(byAdding: .day, value: -4, to: Date()),
            files: nil,
            progressFiles: nil
        )
    ]
}
