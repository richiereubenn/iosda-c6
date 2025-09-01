import SwiftUI

struct AttachedImagesView: View {
    let files: [File]
    
    var body: some View {
        let imageFiles = files.filter { $0.isImage }
        
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
                            // Handle image tap - open full screen view
                        }
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
}

