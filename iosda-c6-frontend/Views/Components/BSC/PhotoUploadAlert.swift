import SwiftUI

struct PhotoUploadSheet: View {
    @Binding var title: String
    @Binding var description: String
    @Binding var uploadAmount: Int
    let showTitleField: Bool
    let showDescriptionField: Bool
    let onStartWork: ([UIImage], String?, String?) -> Void
    let onCancel: () -> Void
    
    @StateObject private var viewModel = PhotoUploadAlertViewModel()
    @State private var inputTitle: String = ""
    @State private var inputDescription: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            VStack(alignment:.center, spacing: 8) {
                Text(title)
                    .font(.system(.title2, weight: .semibold))
                
                Text(description)
                    .font(.system(.subheadline))
                    .foregroundColor(.secondary)
            }

            
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
            if showDescriptionField {
                TextField("Enter Description", text: $inputDescription, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                CustomButtonComponent(
                    text: "Cancel",
                    backgroundColor: Color.red,
                    textColor: .white
                ) {
                    viewModel.reset()
                    inputTitle = ""
                    inputDescription = ""
                    onCancel()
                }
                

                CustomButtonComponent(
                    text: "Confirm",
                    backgroundColor: viewModel.canStartWork(uploadAmount: uploadAmount) ? .primaryBlue : .gray,
                    textColor: .white
                ) {
                    let photos = [viewModel.photo1, viewModel.photo2].compactMap { $0 }
                    onStartWork(
                        photos,
                        title,
                        showDescriptionField ? inputDescription.trimmingCharacters(in: .whitespacesAndNewlines) : nil
                    )
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
