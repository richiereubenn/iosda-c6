import SwiftUI

struct ResidentPhotoUploadCard: View {
    let title: String
    let image: UIImage?
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 250)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                if let image = image {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(8)
                        
                        Button(action: onRemove) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .padding(6)
                    }
                } else {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.primaryBlue.opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.primaryBlue)
                        }
                        
                        Text(title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 4)
                    }
                }
            }
            // Remove onTapGesture since PhotosPicker handles the tap
            
            if image != nil {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                    
                    Text("Uploaded")
                        .font(.system(size: 10))
                        .foregroundColor(.green)
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                    
                    Text("Tap to select")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
