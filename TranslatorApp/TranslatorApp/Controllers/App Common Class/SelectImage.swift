import UIKit
import Toaster
import MobileCoreServices

class SelectImage: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // static let shared = SelectImage()
    
    var vc: UIViewController!
    var complition: ((UIImage) -> Void)?
    
    
    // MARK: - Select Image
    func selectImage(_ cgRact: CGRect, _ vc: UIViewController, _ complition: @escaping ((UIImage) -> Void))
    {
        self.vc = vc
        self.complition = complition
        
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel) { _ in
            debugPrint("Cancel")
        })
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo".localized(), style: .default) { _ in
            debugPrint("Camera")
            self.onCaptureImageThroughCamera()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Choose Existing Photo".localized(), style: .default) { _ in
            debugPrint("Gallery")
            self.onCaptureImageThroughGallery()
        })
        
        if let presenter = actionSheet.popoverPresentationController {
            presenter.sourceView = vc.view
            presenter.sourceRect = cgRact
        }
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    func selectImageFromCamera(_ vc: UIViewController, _ complition: @escaping ((UIImage) -> Void)) {
        self.vc = vc
        self.complition = complition
        self.onCaptureImageThroughCamera()
    }
    
    func selectImageFromGallary(_ vc: UIViewController, _ complition: @escaping ((UIImage) -> Void)) {
        self.vc = vc
        self.complition = complition
        self.onCaptureImageThroughGallery()
    }
    
    @objc open func onCaptureImageThroughCamera() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displayToast("Your device has no camera".localized())
        } else {
            let imgPicker = UIImagePickerController()
            imgPicker.delegate = self
            imgPicker.allowsEditing = true
            imgPicker.sourceType = .camera
            imgPicker.cameraCaptureMode = .photo
            imgPicker.showsCameraControls = true
            imgPicker.cameraFlashMode = .auto
            
            vc.present(imgPicker, animated: true, completion: nil)
        }
    }
    
    @objc open func onCaptureImageThroughGallery() {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.sourceType = .photoLibrary
        imgPicker.mediaTypes = [kUTTypeImage as String]
        
        vc.present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        vc.dismiss(animated: true, completion: nil)
        
        if let choosenImage: UIImage = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) {
            complition!(choosenImage)
            return
        }
        
        if let choosenImage: UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) {
            complition!(choosenImage)
            return
        }
    }
}
