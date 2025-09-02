//
//  PhotoUploadSheet.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

struct PhotoUploadSheet: View {
    let title: String
    let description: String
    let photoLabel1: String
    let photoLabel2: String?
    let uploadAmount: Int // 1 or 2
    let onStartWork: () -> Void
    let onCancel: () -> Void
    
    @StateObject private var viewModel = PhotoUploadAlertViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Before starting, you are required to upload the following \(uploadAmount == 1 ? "photo" : "two photos"):")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• \(photoLabel1)")
                    if uploadAmount == 2, let label2 = photoLabel2 {
                        Text("• \(label2)")
                    }
                }
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Photo upload cards
            if uploadAmount == 1 {
                PhotoUploadCard(
                    title: "Photo",
                    image: viewModel.photo1,
                    onTap: {
                        viewModel.selectPhoto(type: .photo1)
                    },
                    onRemove: {
                        viewModel.removePhoto(type: .photo1)
                    }
                )
                .frame(maxWidth: .infinity)
            } else {
                HStack(spacing: 16) {
                    PhotoUploadCard(
                        title: "Photo 1",
                        image: viewModel.photo1,
                        onTap: {
                            viewModel.selectPhoto(type: .photo1)
                        },
                        onRemove: {
                            viewModel.removePhoto(type: .photo1)
                        }
                    )
                    
                    PhotoUploadCard(
                        title: "Photo 2",
                        image: viewModel.photo2,
                        onTap: {
                            viewModel.selectPhoto(type: .photo2)
                        },
                        onRemove: {
                            viewModel.removePhoto(type: .photo2)
                        }
                    )
                }
            }
            
            HStack(spacing: 16) {
                CustomButtonComponent(
                    text: "Cancel",
                    backgroundColor: Color.red,
                    textColor: .white
                ) {
                    viewModel.reset()
                    onCancel()
                }

                CustomButtonComponent(
                    text: "Start Work",
                    backgroundColor: viewModel.canStartWork(uploadAmount: uploadAmount) ? .primaryBlue : .gray,
                    textColor: .white
                ) {
                    onStartWork()
                }
                .disabled(!viewModel.canStartWork(uploadAmount: uploadAmount))
            }

        }
        .padding(20)
        .onAppear {
            viewModel.setUploadAmount(uploadAmount)
        }
        
        .confirmationDialog("Select Photo Source", isPresented: $viewModel.showActionSheet) {
            Button("Camera") {
                viewModel.selectPhotoSource(sourceType: .camera)
            }
            
            Button("Photo Library") {
                viewModel.selectPhotoSource(sourceType: .photoLibrary)
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose where to get the photo from")
        }
        
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(
                sourceType: viewModel.imageSourceType,
                onImageSelected: { image in
                    viewModel.setPhoto(image)
                }
            )
        }
    }
}

#Preview {
    Group {
        PhotoUploadSheet(
            title: "Start this Work?",
            description: "This will set the work status to 'In Progress'.",
            photoLabel1: "A close-up photo of the specific defect.",
            photoLabel2: nil,
            uploadAmount: 1,
            onStartWork: {
                print("Start Work tapped")
            },
            onCancel: {
                print("Cancel tapped")
            }
        )
        .previewDisplayName("Upload 1 Photo")
    }
    .padding()
}
