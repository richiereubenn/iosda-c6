import SwiftUI

struct ProgressLogRow: View {
    let progressLog: ProgressLog2
    let isLast: Bool
    let isFirst: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline circle and line
            VStack(spacing: 0) {
                Circle()
                    .fill(isFirst ? Color.gray : Color.primaryBlue)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: isFirst ? "circle" : "checkmark")
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
                    Text(formatDateRow(progressLog.timestamp))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(formatDate(progressLog.timestamp ?? Date(), format: "HH:mm"))
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
                
                // Attached Files (images or PDFs)
                if let files = progressLog.files, !files.isEmpty {
                    ProgressAttachmentsView(progressFiles: files)
                        .padding(.top, 8)
                }
            }
            .padding(.bottom, 16)
        }
    }
    
    private func formatDateRow(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    ProgressLogRow(progressLog: mockProgressLog, isLast: false, isFirst: true)
        .padding()
}

private let mockProgressLog = ProgressLog2(
    id: "1",
    complaintId: "123",
    userId: "user1",
    title: "Laporan Diterima",
    description: "Laporan telah diterima oleh pihak pengelola dan sedang dalam peninjauan.",
    timestamp: Date(),
    createdAt: Date(),
    updatedAt: Date(),
    files: [
        ProgressFile2(
            id: "1",
            name: "foto_lampiran.jpg",
            path: "https://www.example.com/foto_lampiran.jpg",
            url: "https://www.example.com/foto_lampiran.jpg",
            mimeType: "image/jpeg"
        ),
        ProgressFile2(
            id: "2",
            name: "form_pengaduan.pdf",
            path: "https://www.example.com/form_pengaduan.pdf",
            url: "https://www.example.com/form_pengaduan.pdf",
            mimeType: "application/pdf"
        )
    ]
)
