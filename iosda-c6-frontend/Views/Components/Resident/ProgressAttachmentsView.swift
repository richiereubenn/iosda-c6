import SwiftUI

struct ProgressAttachmentsView: View {
    let progressFiles: [ProgressFile2]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Images Section
            let imageFiles = progressFiles.filter { $0.mimeType?.starts(with: "image") == true }
            if !imageFiles.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(imageFiles, id: \.id) { file in
                            AsyncImage(url: URL(string: ResidentComplaintDetailViewModel.fullURL(for: file.url ?? file.path))) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                // Optional: Add full screen preview later
                            }
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }

            // Non-Image Files Section
            let nonImageFiles = progressFiles.filter { !($0.mimeType?.starts(with: "image") ?? false) }
            if !nonImageFiles.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(nonImageFiles, id: \.id) { file in
                        HStack {
                            Image(systemName: "doc.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text(file.name ?? "Document")
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
                            let full = ResidentComplaintDetailViewModel.fullURL(for: file.url ?? file.path)
                            if let url = URL(string: full) {
                                UIApplication.shared.open(url)
                            }

                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProgressAttachmentsView(progressFiles: [
        ProgressFile2(
            id: "1",
            name: "photo1.jpg",
            path: "https://via.placeholder.com/150",
            url: "https://via.placeholder.com/150",
            mimeType: "image/jpeg"
        ),
        ProgressFile2(
            id: "2",
            name: "document.pdf",
            path: "https://www.example.com/document.pdf",
            url: "https://www.example.com/document.pdf",
            mimeType: "application/pdf"
        )
    ])
}
