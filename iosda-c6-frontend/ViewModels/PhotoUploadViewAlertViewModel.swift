//
//  PhotoUploadViewAlertViewModel.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI
import PhotosUI

class PhotoUploadAlertViewModel: ObservableObject {
    @Published var photo1: UIImage?
    @Published var photo2: UIImage?
    @Published var showImagePicker = false
    @Published var showActionSheet = false
    @Published var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var currentPhotoType: PhotoType = .photo1
    
    private var uploadAmount: Int = 2
    
    enum PhotoType {
        case photo1
        case photo2
    }
    
    func setUploadAmount(_ amount: Int) {
        uploadAmount = amount
    }
    
    func canStartWork(uploadAmount: Int) -> Bool {
        if uploadAmount == 1 {
            return photo1 != nil
        } else {
            return photo1 != nil && photo2 != nil
        }
    }
    
    func selectPhoto(type: PhotoType) {
        currentPhotoType = type
        showActionSheet = true
    }
    
    func selectPhotoSource(sourceType: UIImagePickerController.SourceType) {
        self.imageSourceType = sourceType
        showImagePicker = true
    }
    
    func setPhoto(_ image: UIImage) {
        switch currentPhotoType {
        case .photo1:
            photo1 = image
        case .photo2:
            photo2 = image
        }
    }
    
    func removePhoto(type: PhotoType) {
        switch type {
        case .photo1:
            photo1 = nil
        case .photo2:
            photo2 = nil
        }
    }
    
    func reset() {
        photo1 = nil
        photo2 = nil
    }
}
