import Foundation
import UIKit
import Photos
import QuickLook
import SDWebImage
import AVFoundation
import AVKit
import Toaster
import VisionKit
import Vision
import AudioToolbox

// MARK: - Delay Features
func delay(_ delay: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
}

// MARK: - Open Url
func openUrlInSafari(strUrl: String) {
    if let url = URL(string: strUrl) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { (isOpen) in }
        } else {
            debugPrint("System can't open this URL!")
        }
    } else {
        debugPrint("URL invalid")
    }
}

// MARK: - Toast
func displayToast(_ message: String) {
    Toast.init(text: message).show()
}

// MARK: - Show loader
func showLoader() {
    appDelegate.window?.isUserInteractionEnabled = false
    ProgressHUD.animationType = .systemActivityIndicator
    ProgressHUD.colorAnimation = UIColor.init(named: "AppColor") ?? UIColor.black
    ProgressHUD.show()
}

func removeLoader() {
    appDelegate.window?.isUserInteractionEnabled = true
    ProgressHUD.dismiss()
}

// MARK: - Debug
func debugPrint(_ str: Any) {
    #if DEBUG
        print("➡️", str)
    #endif
}

// MARK: - Display view into subview
func displaySubViewtoParentView(_ parentview: UIView! , subview: UIView!) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    parentview.addSubview(subview);
    parentview.addConstraint(NSLayoutConstraint(item: subview!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))
    parentview.addConstraint(NSLayoutConstraint(item: subview!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
    parentview.layoutIfNeeded()
}

func displaySubViewWithScaleOutAnim(_ view: UIView) {
    view.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
    view.alpha = 1
    UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.55, initialSpringVelocity: 1.0, options: [], animations: {() -> Void in
        view.transform = CGAffineTransform.identity
    }, completion: {(_ finished: Bool) -> Void in
    })
}

func displaySubViewWithScaleInAnim(_ view: UIView) {
    UIView.animate(withDuration: 0.25, animations: {() -> Void in
        view.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        view.alpha = 0.0
    }, completion: {(_ finished: Bool) -> Void in
        view.removeFromSuperview()
    })
}

// MARK: - Date Time
func getCurrentTimeStampValue() -> String {
    return String(format: "%0.0f", Date().timeIntervalSince1970*1000)
}

func convertTimeStampToDate(timeStamp: Float) -> Date {
    let epocTime = TimeInterval(timeStamp)
    let date = NSDate(timeIntervalSince1970: epocTime)
    return date as Date
}

func getDateFromTimeStamp(timeStamp : Int) -> String {
    let date = NSDate(timeIntervalSince1970: TimeInterval(timeStamp))
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.dateFormat = "hh:mm a"
    let dateString = dayTimePeriodFormatter.string(from: date as Date)
    return dateString
}

func getDateFromTimeStamp1(timeStamp : Int) -> String {
    let date = NSDate(timeIntervalSince1970: TimeInterval(timeStamp))
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.dateFormat = "dd,MMM yy hh:mm a"
    let dateString = dayTimePeriodFormatter.string(from: date as Date)
    return dateString
}

func getDateFromTimeStamp2(timeStamp : Int) -> String {
    let date = NSDate(timeIntervalSince1970: TimeInterval(timeStamp))
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.dateFormat = "dd,MMM yy"
    let dateString = dayTimePeriodFormatter.string(from: date as Date)
    return dateString
}

func getDateInCurrentTimeZone(_ date: Date = Date(), formate: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = formate
    return dateFormatter.string(from: date)
}

func getLocalTime() -> Date {
    let nowUTC = Date()
    let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
    guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}
    return localDate
}


// MARK: - Share
func shareText(_ vc: UIViewController, _ text: Any) {
    let textToShare = [ text ]
    let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = vc.view
    activityViewController.popoverPresentationController?.sourceRect = CGRect.init(x: vc.view.frame.midX / 2, y: vc.view.frame.midY, width: 0, height: 0)
    activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
    vc.present(activityViewController, animated: true, completion: nil)
}

// MARK: - Alert
func showAlert(_ title:String, message:String, completion: @escaping () -> Void) {
    let myAlert = UIAlertController(title:NSLocalizedString(title, comment: ""), message:NSLocalizedString(message, comment: ""), preferredStyle: UIAlertController.Style.alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler:{ (action) in
        completion()
    })
    myAlert.addAction(okAction)
    appDelegate.window?.rootViewController?.present(myAlert, animated: true, completion: nil)
}

// MARK: - Get thumb image for any files

@available(iOS 13.0, *)
func getThumbImageForFile(fileUrl: URL ,_ complition: @escaping (UIImage) -> Void) {
    let request = QLThumbnailGenerator.Request(
        fileAt: fileUrl,
        size: CGSize.init(width: 100, height: 100),
        scale: UIScreen.main.scale,
        representationTypes: .all)

    let generator = QLThumbnailGenerator.shared
    generator.generateRepresentations(for: request) { thumbnail, _, error in
        if let thumbnail = thumbnail {
            DispatchQueue.main.async {
                complition(thumbnail.uiImage)
            }
        } else if let error = error {
            debugPrint(error.localizedDescription)
        }
    }
}

// MARK: Get Image Form URL
func clearSDImageCache() {
    SDImageCache.shared.clearMemory()
    SDImageCache.shared.clearDisk()
}

func setImageFromUrl(_ picPath: String, img: UIImageView, placeHolder: String) {
    if picPath == "" {
        img.image = UIImage.init(named: placeHolder)
        return
    }
    
    img.sd_imageIndicator = SDWebImageActivityIndicator.gray
    img.sd_setImage(with: URL(string : picPath), placeholderImage: nil, options: []) { image, error, type, url in
        if error == nil {
            img.image = image
        } else {
            img.image = UIImage.init(named: placeHolder)
        }
    }
}

// MARK: - App Detail
func getAppVersion() -> String {
    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        return appVersion
    } else {
        return "0.0"
    }
}

// Convert To Valid URL
func convertStringToValidUrl(strUrl: String) -> String? {
    return strUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
}

// Convart Data to Dictionary
func convertDataToDict(data: Data) -> [String: Any]? {
    do {
        let dictJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        return dictJson
    } catch {
        return nil
    }
}

// MARK: - Get image from PHAssets data type
func getUIImage(asset: PHAsset, size: CGSize) -> UIImage? {
    let imageManager = PHCachingImageManager()
    let option = PHImageRequestOptions()
    var img: UIImage?
    
    option.deliveryMode = .opportunistic
    option.resizeMode = .exact
    option.isSynchronous = true
    option.isNetworkAccessAllowed = true

    imageManager.requestImage(for: asset, targetSize: size, contentMode: .default, options: option, resultHandler: { image, _ in
        if image != nil {
            img = image!
        }
    })
    return img
}


// MARK: - recognize Text From Image
func recognizeTextFromImage(image: UIImage? ,_ complition: @escaping (String) -> Void) {
    guard let cgimage = image?.cgImage else { return }
    let handler = VNImageRequestHandler(cgImage: cgimage, options: [:])
    let request = VNRecognizeTextRequest {request, error in
        guard let observation = request.results as? [VNRecognizedTextObservation], error == nil else { return }
        let text = observation.compactMap({
            $0.topCandidates(1).first?.string
        }).joined(separator: ", ")
        
        complition(text)
    }
   
    // Process Request
    do {
        try handler.perform([request])
    } catch {
        debugPrint(error.localizedDescription)
    }
}

// MARK: - Copy To Clipboard
func copyText(str: String) {
    UIPasteboard.general.string = str
    displayToast("Copied to Clipboard".localized())
}
