//
//  GIMediaCommonPicker.swift
//  MediaLibraryWrapper
//
//  Created by daleijn on 06.10.2020.
//  Copyright © 2020 daleijn. All rights reserved.
//

import UIKit

class GIMediaCommonPicker {
    private unowned let parentVC: UIViewController
    
    private lazy var mediaLibraryWrapperOfUIImagePicker = MediaLibraryWrapperOfUIImagePicker(parentVC: parentVC)
    private lazy var mediaLibraryWrapperOfPHPicker = MediaLibraryWrapperOfPHPicker(parentVC: parentVC)
    private lazy var pickerAuthorizationCenter = ImagePickerAuthorizationCenter(presentingViewController: parentVC)
    
    private var currentMediaType: GIMediaType = .images
    
    private var selectedMediaHandler: ((Storage)->())!
    
    
    // MARK: - Init
    
    init(parentVC: UIViewController) {
        self.parentVC = parentVC
        
//        pickerAuthorizationCenter.noAccessAlertsStrings =
//            .init(noPhotoLibraryAccess: .init(title: "", message: ""), noCameraAccess: .init(title: "", message: ""),
//                  settingsCaption: "",
//                  cancelCaption: "")
    }
    
    
    // MARK: - API
    
    func showAlertChooseMediaType(_ mediaType: GIMediaType, completion: @escaping (Storage)->()) {
        currentMediaType = mediaType
        selectedMediaHandler = completion
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let userLibrary = UIAlertAction(title: "Выбрать из галереи", style: .default) { [weak self] alert in
            self?.chooseMediaFromLibrary()
        }
        
        let takePhoto = UIAlertAction(title: "Сделать фото или видео", style: .default) { [weak self] alert in
            self?.makePhotoOrVideo()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(userLibrary)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(takePhoto)
        }
        
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.sourceView = parentVC.view
        
        parentVC.present(alert, animated: true)
    }
    
}


// MARK: - Photo Library

private extension GIMediaCommonPicker {
    
    func chooseMediaFromLibrary() {
    
        if #available(iOS 14, *) {
            mediaLibraryWrapperOfPHPicker.chooseMedia(currentMediaType,
                                                      selectionLimit: 0, completion: selectedMediaHandler)
        }
        else if #available(iOS 11, *) {
            mediaLibraryWrapperOfUIImagePicker.openMediaPickerFor(source: .savedPhotosAlbum,
                                                                  mediaType: currentMediaType,
                                                                  completion: selectedMediaHandler)
        }
        else {
            pickerAuthorizationCenter.checkPhotoLibraryAccess { isGranted in
                guard isGranted else { return }
                
                self.mediaLibraryWrapperOfUIImagePicker.openMediaPickerFor(source: .savedPhotosAlbum,
                                                                           mediaType: self.currentMediaType,
                                                                           completion: self.selectedMediaHandler)
            }
        }
    }
    
}


// MARK: - Make photo or video

private extension GIMediaCommonPicker {
    
    func makePhotoOrVideo() {
        pickerAuthorizationCenter.checkCameraAccess { isGranted in
            guard isGranted else { return }
            
            self.mediaLibraryWrapperOfUIImagePicker.openMediaPickerFor(source: .camera,
                                                                       mediaType: self.currentMediaType,
                                                                       completion: self.selectedMediaHandler)
        }
        
    }
    
}
