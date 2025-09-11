//
//  ProgressAttachmentsView.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 02/09/25.
//


import SwiftUI

struct ProgressAttachmentsView: View {
    let progressFiles: [ProgressFile]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Images Section
            let imageFiles = progressFiles.compactMap { $0.file }.filter { $0.isImage }
            if !imageFiles.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(imageFiles, id: \.id) { file in
                            AsyncImage(url: URL(string: file.path ?? "")) { image in
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
            let nonImageFiles = progressFiles.filter { !($0.file?.isImage ?? false) }
            if !nonImageFiles.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(nonImageFiles, id: \.id) { progressFile in
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
    }
}


#Preview {
    ProgressAttachmentsView(progressFiles: [
        ProgressFile(
            id: "1",
            progressId: "101",
            fileId: "201",
            progress: nil,
            file: File(
                id: "201",
                name: "photo1.jpg",
                path: "https://via.placeholder.com/150",
                mimeType: "image/jpeg",
                otherAttributes: nil,
                progressFiles: nil
            )
        ),
        ProgressFile(
            id: "2",
            progressId: "101",
            fileId: "202",
            progress: nil,
            file: File(
                id: "202",
                name: "document.pdf",
                path: "https://www.example.com/document.pdf",
                mimeType: "application/pdf",
                otherAttributes: nil,
                progressFiles: nil
            )
        )
    ])
}
