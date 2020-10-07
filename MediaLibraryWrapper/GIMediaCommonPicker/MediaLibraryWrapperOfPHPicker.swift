//
//  MediaLibraryWrapper_iOS14.swift
//  MediaLibraryWrapper
//
//  Created by daleijn on 06.10.2020.
//

import PhotosUI
import MobileCoreServices

@available(iOS 14, *)
private extension GIMediaType {
    
    var filters: [PHPickerFilter] {
        var filters = [PHPickerFilter]()
        
        if self.contains(.images) {
            filters.append(.images)
        }
        
        if self.contains(.videos) {
            filters.append(.videos)
        }
        
        return filters
    }
    
}


class MediaLibraryWrapperOfPHPicker {
    private unowned let parentVC: UIViewController
    private let group = DispatchGroup()
    private var selectedMediaHandler: ((Storage)->())?
    
    
    // MARK: - Init
    
    init(parentVC: UIViewController) {
        self.parentVC = parentVC
    }
    
    
    // MARK: - API
    
    @available(iOS 14, *)
    func chooseMedia(_ mediaType: GIMediaType,
                     selectionLimit: Int,
                     completion: @escaping ((Storage)->()))
    {
        self.selectedMediaHandler = completion
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        configuration.filter = .any(of: mediaType.filters)
        
        let phPickerController = PHPickerViewController(configuration: configuration)
        
        phPickerController.delegate = self
        parentVC.present(phPickerController, animated: true, completion: nil)
    }
    
}


@available(iOS 14, *)
extension MediaLibraryWrapperOfPHPicker: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        var images = [UIImage]()
        var videosURLs = [URL]()
        
        for result in results {
            let provider = result.itemProvider
            
            if provider.hasItemConformingToTypeIdentifier(kUTTypeMovie as String) {
                group.enter()
                result.itemProvider.loadItem(forTypeIdentifier: kUTTypeMovie as String, options: nil) { fileURL, _ in
                    if let videoURL = fileURL as? URL {
                        videosURLs.append(videoURL)
                        self.group.leave()
                    }
                }
            }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                self.group.enter()
                provider.loadObject(ofClass: UIImage.self) {  image, error in
                    if let image = image as? UIImage {
                        images.append(image)
                        self.group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.selectedMediaHandler?(Storage(images: images,
                                               videosURLs: videosURLs))
        }
        
    }
    
}



    
class Storage: CustomStringConvertible {
    let images: [UIImage]
    let videosURLs: [URL]
    
    init(images: [UIImage], videosURLs: [URL]) {
        self.images = images
        self.videosURLs = videosURLs
    }
    
    init(images: [UIImage]) {
        self.images = images
        self.videosURLs = []
    }
    
    init(videosURLs: [URL]) {
        self.videosURLs = videosURLs
        self.images = []
    }
    
    
    var description: String {
        """
            \n
            Storage
            "\(images.count) images: \(images)"
            "\(videosURLs.count) videosURLs: \(videosURLs)"
            \n
            """
    }
}


