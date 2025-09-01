import SwiftUI

struct ProgressLogRow: View {
    let progressLog: ProgressLog
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline circle and line
            VStack(spacing: 0) {
                Circle()
                    .fill(progressLog.isCompleted ? Color.blue : Color.gray)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: progressLog.isCompleted ? "checkmark" : "circle")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Date and Time
                HStack {
                    Text(formatDate(progressLog.timestamp))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(formatTime(progressLog.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Title and Description
                if let title = progressLog.title {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                if let description = progressLog.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Attached Images
                if let files = progressLog.files, !files.isEmpty {
                    AttachedImagesView(files: files)
                }
                
                // Progress Files (if any)
                if let progressFiles = progressLog.progressFiles, !progressFiles.isEmpty {
                    ProgressFilesView(progressFiles: progressFiles)
                }
            }
            .padding(.bottom, 16)
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        
        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "id_ID") // Indonesian locale
        formatter.dateFormat = "EEEE, dd MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "" }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ProgressLogRow(progressLog: mockProgressLog, isLast: false)
        .padding()
}
private let mockProgressLog = ProgressLog(
    id: 1,
    userId: nil,
    attachmentId: nil,
    title: "Laporan Diterima",
    description: "Laporan telah diterima oleh pihak pengelola dan sedang dalam peninjauan.",
    timestamp: Date(),
    files: [
        File(
            id: 1,
            name: "foto_lampiran.jpg",
            path: "https://www.example.com/foto_lampiran.jpg",
            mimeType: "image/jpeg",
            otherAttributes: nil,
            progressFiles: nil
        )
    ],
    progressFiles: [
        ProgressFile(
            id: 1,
            progressId: 1,
            fileId: 2,
            progress: nil,
            file: File(
                id: 2,
                name: "form_pengaduan.pdf",
                path: "https://www.example.com/form_pengaduan.pdf",
                mimeType: "application/pdf",
                otherAttributes: nil,
                progressFiles: nil
            )
        )
    ]
)
