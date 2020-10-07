//
//  GIMediaCommonPicker.swift
//  MediaLibraryWrapper
//
//  Created by daleijn on 06.10.2020.
//

import UIKit
import Photos

extension ImagePickerAuthorizationCenter {
    
    struct NoAccessAlertsStrings {
        var noPhotoLibraryAccess = AlertSrtings()
        var noCameraAccess = AlertSrtings()
        
        var settingsCaption = "Settings"
        var cancelCaption = "Cancel"
        
        
        static let defaultStrings = NoAccessAlertsStrings(
            noPhotoLibraryAccess: .init(title: "NoPhotoLibraryAccess", message: "PleaseGivePhotoLibraryAccessInSettings"),
            noCameraAccess: .init(title: "NoCameraAccess", message: "PleaseGiveCameraAccessInSettings"))
    }
    
    struct AlertSrtings {
        var title = ""
        var message = ""
    }
    
}

/// Класс для проверки доступа к **Галереи** и **Камере**.
class ImagePickerAuthorizationCenter {
    private unowned let presentingViewController: UIViewController
    
    
    // MARK: - Init
    
    /// Инициализация класса.
    /// - Parameter presentingViewController: vc с которого будут показаны алерты о запрете доступа.
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    
    // MARK: - API
    
    var noAccessAlertsStrings: NoAccessAlertsStrings = .defaultStrings
    
    
    /// Проверить доступ к Галерее.
    /// - Parameter completion: Вернет `true` если доступ `authorized`. Вернет `false` в любом другом случае.
    /// Если нет доступа к галерее покажет соответствующий **alert**.
    /// Если дан только `.limited` доступ - покажет `presentLimitedLibraryPicker`.
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
                self.alertImageAuthenticationError(title: self.noAccessAlertsStrings.noPhotoLibraryAccess.title,
                                                   message: self.noAccessAlertsStrings.noPhotoLibraryAccess.message)
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
    
    /// Проверить доступ к Камере.
    /// - Parameter completion: Вернет `true` если доступ `authorized`. Вернет `false` в любом другом случае.
    ///  Если нет доступа к галерее покажет соответствующий **alert**.
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
                self.alertImageAuthenticationError(title: self.noAccessAlertsStrings.noCameraAccess.title,
                                                   message: self.noAccessAlertsStrings.noCameraAccess.message)
                
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

}

private extension ImagePickerAuthorizationCenter {
    
    func alertImageAuthenticationError(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: noAccessAlertsStrings.settingsCaption, style: .default) { (_) in
            let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL)
            }
        }
        
        let cancelAction = UIAlertAction(title: noAccessAlertsStrings.cancelCaption, style: .cancel, handler: nil)
        
        ac.addAction(cancelAction)
        ac.addAction(settingsAction)
        
        presentingViewController.present(ac, animated: true)
    }
    
}
