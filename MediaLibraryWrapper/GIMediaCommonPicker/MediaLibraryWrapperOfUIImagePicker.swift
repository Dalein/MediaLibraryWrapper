//
//  MediaLibraryWrapperOfUIImagePicker.swift
//  MediaLibraryWrapper
//
//  Created by daleijn on 06.10.2020.
//  Copyright © 2020 daleijn. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices


extension MediaLibraryWrapperOfUIImagePicker {
    
    enum Media {
        case image(UIImage)
        case video(URL)
    }
    
}

class MediaLibraryWrapperOfUIImagePicker: NSObject {
    
    private lazy var imagePickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()
    
    
    private unowned let parentVC: UIViewController
    
    private var selectedMediaHandler: ((Storage)->())?
    
    
    // MARK: - Init
    
    init(parentVC: UIViewController) {
        self.parentVC = parentVC
    }
    
    
    // MARK: - API
    
    func openMediaPickerFor(source: UIImagePickerController.SourceType,
                            mediaType: GIMediaType,
                            completion: @escaping ((Storage)->()))
    {
        selectedMediaHandler = completion
        
        imagePickerController.sourceType = source
        
        imagePickerController.mediaTypes = mediaType.utTypes
        imagePickerController.videoQuality = .typeIFrame1280x720
        
        parentVC.present(imagePickerController, animated: true)
    }
    
}


extension MediaLibraryWrapperOfUIImagePicker: (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer { picker.dismiss(animated: true, completion: nil) }
        
        let mediaType = info[.mediaType] as AnyObject
        
        if mediaType as! String == kUTTypeMovie as String {
            guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
            
            // letisItFromCamera = picker.sourceType == .camera
            selectedMediaHandler?(Storage(videosURLs: [videoURL]))
        }
        else if let tempImage = info[.originalImage] as? UIImage {
            selectedMediaHandler?(Storage(images: [tempImage]))
        }
    }
    
}
