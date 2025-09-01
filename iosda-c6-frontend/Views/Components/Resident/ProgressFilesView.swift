import SwiftUI

struct ProgressFilesView: View {
    let progressFiles: [ProgressFile]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(progressFiles, id: \.id) { progressFile in
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text(progressFile.file?.name ?? "Document")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .onTapGesture {
                    if let urlString = progressFile.file?.path,
                       let url = URL(string: urlString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
}

#Preview {
    ProgressFilesView(progressFiles: mockProgressFiles)
}

// MARK: - Mock Data for Preview

private let mockProgressFiles: [ProgressFile] = [
    ProgressFile(
        id: 1,
        progressId: nil,
        fileId: nil,
        progress: nil,
        file: File(
            id: 101,
            name: "bukti_laporan.pdf",
            path: "https://www.example.com/bukti_laporan.pdf",
            mimeType: "application/pdf",
            otherAttributes: nil,
            progressFiles: nil
        )
    ),
    ProgressFile(
        id: 2,
        progressId: nil,
        fileId: nil,
        progress: nil,
        file: File(
            id: 102,
            name: "laporan_foto.jpg",
            path: "https://www.example.com/laporan_foto.jpg",
            mimeType: "image/jpeg",
            otherAttributes: nil,
            progressFiles: nil
        )
    ),
    ProgressFile(
        id: 3,
        progressId: nil,
        fileId: nil,
        progress: nil,
        file: File(
            id: 103,
            name: nil, // Test with nil name
            path: nil, // Test with nil path
            mimeType: nil,
            otherAttributes: nil,
            progressFiles: nil
        )
    )
]
