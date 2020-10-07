//
//  GIMediaCommonPicker.swift
//  MediaLibraryWrapper
//
//  Created by daleijn on 06.10.2020.
//

import UIKit
import Photos

class ImagePickerAuthorizationCenter {
    private unowned let presentingViewController: UIViewController
    
    
    // MARK: - Init
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    
    // MARK: - API
    
    func checkPhotoLibraryAccess(completion: ((_ isGranted: Bool) -> ())?) {
        let status: PHAuthorizationStatus = {
            if #available(iOS 14, *) {
                return PHPhotoLibrary.authorizationStatus(for: .readWrite)
            } else {
                return PHPhotoLibrary.authorizationStatus()
            }
        }()
        
        switch status {
        
        case .authorized:
            DispatchQueue.main.async {
                completion?(true)
            }
            
        case .denied, .restricted :
            DispatchQueue.main.async {
                self.alertImageAuthenticationError(title: "NoPhotoLibraryAccess",
                                                   message: "PleaseGivePhotoLibraryAccessInSettings")
                completion?(false)
            }
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization() { newStatus in
                completion?(newStatus == .authorized)
            }
            
        case .limited:
            guard #available(iOS 14, *) else { return }
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: presentingViewController)
            completion?(false)
        
        @unknown default:
            completion?(false)
        }
    }
    

    func checkCameraAccess(completion: @escaping (_ isGranted: Bool) -> ()) {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        
        case .authorized:
            DispatchQueue.main.async {
                completion(true)
            }
            
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.alertImageAuthenticationError(title: "NoCameraAccess",
                                                   message: "PleaseGiveCameraAccessInSettings")
                
                completion(false)
            }
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
            
        @unknown default:
            completion(false)
        }
    }
    
    /// Работает, как в телеграме. Мы запрашиваем доступ к микрофону 1 раз, при любом статусе - вызывается complletion
    func checkMicrophonePermision(completion: @escaping  () -> ()) {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    
    
}

private extension ImagePickerAuthorizationCenter {
    
    func alertImageAuthenticationError(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        ac.addAction(cancelAction)
        ac.addAction(settingsAction)
        
        presentingViewController.present(ac, animated: true)
    }
    
}
