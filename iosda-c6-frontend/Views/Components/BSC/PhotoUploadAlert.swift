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
    let detailedPhotoLabel: String
    let overallPhotoLabel: String
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
                Text("Before starting, you are required to upload the following two photos:")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• \(detailedPhotoLabel)")
                    Text("• \(overallPhotoLabel)")
                }
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                PhotoUploadCard(
                    title: "Detailed Photo of\nWork Result",
                    image: viewModel.detailedPhoto,
                    onTap: {
                        viewModel.selectPhoto(type: .detailed)
                    },
                    onRemove: {
                        viewModel.removePhoto(type: .detailed)
                    }
                )
                
                PhotoUploadCard(
                    title: "Overall View of\nWork Area",
                    image: viewModel.overallPhoto,
                    onTap: {
                        viewModel.selectPhoto(type: .overall)
                    },
                    onRemove: {
                        viewModel.removePhoto(type: .overall)
                    }
                )
            }
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    viewModel.reset()
                    onCancel()
                }
                .foregroundColor(.blue)
                .font(.system(size: 16))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Button("Start Work") {
                    onStartWork()
                }
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(viewModel.canStartWork ? Color.blue : Color.gray)
                .cornerRadius(8)
                .disabled(!viewModel.canStartWork)
            }
        }
        .padding(20)
        
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
        
        // Image Picker
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
