import SwiftUI

struct UploadImageCard: View {
    enum ImageType {
        case closeUp
        case overall
    }
    
    var imageType: ImageType = .closeUp
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
                .frame(height: 40)
            
            Image(systemName: "camera.on.rectangle")
                .resizable()
                .scaledToFit()
                .frame(height: 50)  // Bigger image height
            
            Text(imageType == .closeUp ? "Close-up of the Defect" : "Overall View of the Area")
                .font(.subheadline)
            
            Spacer()
                .frame(height: 40)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
        .padding(.horizontal)
    }
}

#Preview {
    VStack {
        UploadImageCard(imageType: .closeUp)
        UploadImageCard(imageType: .overall)
    }
}
