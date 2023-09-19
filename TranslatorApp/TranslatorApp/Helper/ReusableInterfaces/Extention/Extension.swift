//
//  Extension.swift
//  BloodPressureApp
//
//  Created by ERASOFT on 11/11/22.
//

import Foundation
import UIKit
import StoreKit


extension String {
    
    var charactersArray: [Character] {
        return Array(self)
    }
    
//    var localized: String {
//        if let _ = UserDefaults.standard.string(forKey: Preference.sharedInstance.App_LANGUAGE_KEY) {} else { }
//
//        let lang = UserDefaults.standard.string(forKey: Preference.sharedInstance.App_LANGUAGE_KEY) ?? "en"
//
//        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
//        let bundle = Bundle(path: path ?? "")
//
//        return NSLocalizedString(self, tableName: nil, bundle: bundle ?? Bundle(), value: "", comment: "")
//    }
    
    func localizeString(string: String) -> String {
        let path = Bundle.main.path(forResource: string, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    public var validPhoneNumber: Bool {
        let types: NSTextCheckingResult.CheckingType = [.phoneNumber]
        guard let detector = try? NSDataDetector(types: types.rawValue) else { return false }
        if let match = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count)).first?.phoneNumber {
            return match == self
        } else {
            return false
        }
    }
    
    
    func attributedStringWithColor(_ strings: [String], color: UIColor, characterSpacing: UInt? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
        
        guard let characterSpacing = characterSpacing else {return attributedString}
        
        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
}

extension Date {
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self)
    }
    
    var startOfDay : Date
    {
       let calendar = Calendar.current
       let unitFlags = Set<Calendar.Component>([.year, .month, .day])
       let components = calendar.dateComponents(unitFlags, from: self)
       return calendar.date(from: components)!
    }
    
    var  creationDateStr:String
    {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "d MMM YYYY"
        return dateFormatterGet.string(from: self)
    }
    
    static func getCurrentDate() -> String {

            let dateFormatter = DateFormatter()

            dateFormatter.dateFormat = "dd/MM/yyyy"

            return dateFormatter.string(from: Date())

        }

    static func getCurrentTime() -> String {

            let dateFormatter = DateFormatter()

            dateFormatter.dateFormat = "hh:mm a"

            return dateFormatter.string(from: Date())

        }

}


extension Bundle
{
    private static var bundle: Bundle!
    class var applicationVersionNumber: String
    {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
            return version
        }
        return "Build short Number Not Available"
    }
    
    class var applicationBuildNumber: String
    {
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "Build Number Not Available"
    }
    
 
}

extension UIView {
    
    func addHeaderRadius(_ cornerRadius:Int)
    {
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
    }
    
    enum Direction: Int {
        case topToBottom = 0
        case bottomToTop
        case leftToRight
        case rightToLeft
    }
    
    func applyGradient(colors: [Any]?, locations: [NSNumber]? = [0.0, 1.0], direction: Direction = .topToBottom) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x:0, y: 9, width: self.frame.width, height: self.frame.height)
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        
        switch direction {
        case .topToBottom:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            
        case .bottomToTop:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
        case .rightToLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        }
        
        self.layer.addSublayer(gradientLayer)
    }
    
    func pulsateRateUs() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.5
        pulse.fromValue = 0.5
        pulse.toValue = 1.0
        pulse.autoreverses = false
         
        //        pulse.repeatCount = 2
        // pulse.initialVelocity = 0.5
        //  pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func applyShadow()
    {
        self.layer.masksToBounds = false
        //self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1.0
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1

        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }

      // OUTPUT 2
      func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius

        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }
}
extension CGSize
{
    
func resize(by scale: CGFloat) -> CGSize {
    return CGSize(width: self.width * scale, height: self.height * scale)
    }
}
extension UIViewController
{
    //MARK: - toast
  func showToast(message:String)
    {
 
        
        let toastLabel = UILabel(frame: CGRect(x:  (appDelegate.window?.rootViewController?.view.frame.size.width)!/2 - 150, y:  (appDelegate.window?.rootViewController?.view.frame.size.height)!-100, width: 300, height: 50))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.numberOfLines = 0
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 17
        toastLabel.clipsToBounds  =  true;
        
       // appDelegate.window?.rootViewController?.view.addSubview(toastLabel);
        
       UIApplication.shared.windows[UIApplication.shared.windows.count - 1].addSubview(toastLabel)
        UIView.animate(withDuration: 4, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
        
    }
    
    func showToast(message : String, font: UIFont)
    {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}


extension UIViewController {
    
    // Not using static as it wont be possible to override to provide custom storyboardID then
    class var storyboardID : String {
        
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        
        return appStoryboard.viewController(viewControllerClass: self)
    }
}

//MARK: - Get AppStoryboard Extension
enum AppStoryboard : String {
    case Main
    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    func viewController<T : UIViewController>(viewControllerClass : T.Type, function : String = #function, line : Int = #line, file : String = #file) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        return scene
    }
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

//MARK: - Edit Image Feature

class CalculateFunctions {
    static func CGRectGetCenter(_ rect: CGRect) -> CGPoint{
        return CGPoint(x: rect.midX, y: rect.midY)
    }
    
    static func CGRectScale(_ rect: CGRect, wScale: CGFloat, hScale: CGFloat) -> CGRect {
        return CGRect(x: rect.origin.x * wScale, y: rect.origin.y * hScale, width: rect.size.width * wScale, height: rect.size.height * hScale)
    }
    
    static func CGpointGetDistance(_ point1: CGPoint, point2: CGPoint) -> CGFloat {
        let fx = point2.x - point1.x
        let fy = point2.y - point1.y
        
        return sqrt((fx * fx + fy * fy))
    }
    
    static func CGAffineTrasformGetAngle(_ t: CGAffineTransform) -> CGFloat{
        return atan2(t.b, t.a)
    }
    
    static func CGAffineTransformGetScale(_ t: CGAffineTransform) -> CGSize {
        return CGSize(width: sqrt(t.a * t.a + t.c + t.c), height: sqrt(t.b * t.b + t.d * t.d))
    }
    
}


class CustomDashedView: UILabel {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0

    var dashBorder: CAShapeLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }
}


func renderTextOnView(_ view: UIView) -> UIImage? {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
    
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    return img
}




func CGRectGetCenter(_ rect:CGRect) -> CGPoint {
    return CGPoint(x: rect.midX, y: rect.midY)
}

func CGRectScale(_ rect:CGRect, wScale:CGFloat, hScale:CGFloat) -> CGRect {
    return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * wScale, height: rect.size.height * hScale)
}

func CGAffineTransformGetAngle(_ t:CGAffineTransform) -> CGFloat {
    return atan2(t.b, t.a)
}

func CGPointGetDistance(point1:CGPoint, point2:CGPoint) -> CGFloat {
    let fx = point2.x - point1.x
    let fy = point2.y - point1.y
    return sqrt(fx * fx + fy * fy)
}


//MARK: - NSNotification
extension UIViewController{
    
    
    func NetworkChecking(){
        do{
            reachability = try Reachability()
        }catch{
            print("Unable to create Reachability")
            return
        }
        NotificationCenter.default.addObserver(AdsManager.shared.topMostViewController, selector: #selector(reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("This is not working.")
            return
        }
    }
    
    @objc func reachabilityChanged(_ note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.connection != .unavailable {
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                Defaults.set(true, forKey: "NetworkConnect")
            } else {
                print("Reachable via Cellular")
                Defaults.set(true, forKey: "NetworkConnect")
            }
        } else {
            print("Not reachable")
            Defaults.set(false, forKey: "NetworkConnect")
        }
    }
    
}

extension DateComponentsFormatter {
    func difference(from fromDate: Date, to toDate: Date) -> String? {
        self.allowedUnits = [.year,.month,.weekOfMonth,.day]
        self.maximumUnitCount = 1
        self.unitsStyle = .full
        return self.string(from: fromDate, to: toDate)
    }
}
