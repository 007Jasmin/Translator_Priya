//
//  PermissionManager.swift
//  Simple Demo
//
//  Created by Sagar Lukhi on 28/12/22.
//

import UIKit
import Photos
import Speech

class PermissionManager: NSObject {
    // static let shared = PermissionManager()
    
    // MARK: - Camera Permission
    func isCameraPemissionGranted() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
    }
    
    func checkCameraPermission(completionHandler: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            case .authorized:
                DispatchQueue.main.async { completionHandler() }
                
            case .denied:
                DispatchQueue.main.async {
                    self.showPermissionAlert(title: "Can't access camera", msg: "Please go to Settings -> MyApp to enable camera permission")
                }
                
            case .restricted, .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                    if granted {
                        DispatchQueue.main.async { completionHandler() }
                    } else {
                        DispatchQueue.main.async {
                            self.showPermissionAlert(title: "Can't access camera", msg: "Please go to Settings -> MyApp to enable camera permission")
                        }
                    }
                }
                
            @unknown default:
                fatalError("Camera Permission Error")
        }
    }
    
    // MARK: - Photo Liberary Permission
    func isPhotoLiberaryPemissionGranted() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    func checkPhotoLiberaryPermission(completionHandler: @escaping () -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                DispatchQueue.main.async { completionHandler() }
                
            case .denied:
                DispatchQueue.main.async {
                    self.showPermissionAlert(title: "Can't access photo liberary", msg: "Please go to Settings -> MyApp to enable photo liberary permission")
                }
                
            case .restricted, .notDetermined:
                PHPhotoLibrary.requestAuthorization { phAuthorizationStatus in
                    if phAuthorizationStatus == .authorized {
                        DispatchQueue.main.async { completionHandler() }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.showPermissionAlert(title: "Can't access photo liberary", msg: "Please go to Settings -> MyApp to enable photo liberary permission")
                        }
                    }
                }
                
            case .limited:
                print("Limited Photos Access")
                
            @unknown default:
                fatalError("Photo Liberary Permission Error")
        }
    }
    
    // Permission Alert Dialog
    
    func showPermissionAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Open Setting", style: UIAlertAction.Style.default, handler: { (ACTION) in
            guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        UIApplication.topViewController()!.present(alert, animated: true, completion: nil)
    }
    
    func getAllPermission(){
        self.checkPhotoLiberaryPermission {
            self.checkCameraPermission {
                
            }
        }
    }
    
    // MARK: - Notification Permission
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
            if granted {
                DispatchQueue.main.async { completion(granted) }
            } else {
                DispatchQueue.main.async {
                    self.showPermissionAlert(title: "Can't access notification".localized(), msg: "Please go to Settings -> MyApp to enable notification permission".localized())
                }
            }
        }
    }

    // MARK: - Recording Permission
    func checkRecordingPermission(completion: @escaping () -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                DispatchQueue.main.async { completion() }
            } else {
                DispatchQueue.main.async {
                    self.showPermissionAlert(title: "Can't access recording".localized(), msg: "Please go to Settings -> MyApp to enable recording permission".localized())
                }
            }
        }
    }

    // MARK: - Speech to Text Recoginze
    func checkSpeechToTextRecognizePermission(completion: @escaping () -> Void) {
        SFSpeechRecognizer.requestAuthorization { (granted) in
            if granted == .authorized {
                DispatchQueue.main.async { completion() }
            } else {
                DispatchQueue.main.async {
                    self.showPermissionAlert(title: "Can't access speech recognition".localized(), msg: "Please go to Settings -> MyApp to enable speech recognition permission".localized())
                }
            }
        }
    }
//
//    // MARK: - Permission Alert Dialog -
//    func showPermissionAlert(title: String, msg: String) {
//        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: nil))
//        alert.addAction(UIAlertAction(title: "Open Setting".localized(), style: UIAlertAction.Style.default, handler: { (ACTION) in
//            guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
//                assertionFailure("Not able to open App privacy settings")
//                return
//            }
//
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }))
//        UIApplication.topViewController()!.present(alert, animated: true, completion: nil)
//    }


}

extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
