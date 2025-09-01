//
//  PhotoUploadViewAlertViewModel.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI
import PhotosUI

class PhotoUploadAlertViewModel: ObservableObject {
    @Published var detailedPhoto: UIImage?
    @Published var overallPhoto: UIImage?
    @Published var showImagePicker = false
    @Published var showActionSheet = false
    @Published var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var currentPhotoType: PhotoType = .detailed
    
    enum PhotoType {
        case detailed
        case overall
    }
    
    var canStartWork: Bool {
        return detailedPhoto != nil && overallPhoto != nil
    }
    
    func selectPhoto(type: PhotoType) {
        currentPhotoType = type
        showActionSheet = true
    }
    
    func selectPhotoSource(sourceType: UIImagePickerController.SourceType) {
        self.imageSourceType = sourceType
        showImagePicker = true
    }
    
//    var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func setPhoto(_ image: UIImage) {
        switch currentPhotoType {
        case .detailed:
            detailedPhoto = image
        case .overall:
            overallPhoto = image
        }
    }
    
    func removePhoto(type: PhotoType) {
        switch type {
        case .detailed:
            detailedPhoto = nil
        case .overall:
            overallPhoto = nil
        }
    }
    
    func reset() {
        detailedPhoto = nil
        overallPhoto = nil
    }
}

//#Preview {
//    PhotoUploadViewAlertViewModel()
//}
