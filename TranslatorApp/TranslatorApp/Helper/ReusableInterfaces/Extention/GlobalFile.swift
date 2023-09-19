////
////  GlobalFile.swift
////  BloodPressureApp
////
////  Created by ERASOFT on 12/11/22.
////
//
import Foundation
import UIKit
import Contacts
import ContactsUI


let MainScreenWidth: CGFloat = UIScreen.main.bounds.size.width
let MainScreenHeight: CGFloat = UIScreen.main.bounds.size.height
let Defaults = UserDefaults.standard;
let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
let DEVICE_ID           = UIDevice.current.identifierForVendor!.uuidString
var langVal:String = Defaults.string(forKey: Preference.sharedInstance.App_LANGUAGE_KEY) ?? ""
var Flag = false
let when = DispatchTime.now() + 2.2
var reachability: Reachability!


class ActualGradientView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [StartColorlabel.cgColor, EndColorlabel.cgColor]
        l.startPoint = CGPoint(x: 0.25, y: 0.5)
        l.endPoint = CGPoint(x: 0.75, y: 0.5)
        l.cornerRadius = self.frame.height / 2
        layer.insertSublayer(l, at: 0)
        return l
    }()
}


class ActualGradientLabel: UILabel {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [StartColor.cgColor, EndColor.cgColor]
        l.startPoint = CGPoint(x: 0.25, y: 0.5)
        l.endPoint = CGPoint(x: 0.75, y: 0.5)
        l.cornerRadius = self.frame.height / 2
        layer.insertSublayer(l, at: 0)
        return l
    }()
}


//var arrLanguage: [LanguageModel] = [
//    .init(name: "Default", code: "en",subName: "System Language",colorCode: UIColor(hexString: "#005CCE")),
//    .init(name: "English", code: "en",subName: "English",colorCode: UIColor(hexString: "#005CCE")),
//    .init(name: "Español", code: "es",subName: "Spanish",colorCode: UIColor(hexString: "#FFB115")),
//    .init(name: "Françias", code: "fr",subName: "French",colorCode: UIColor(hexString: "#1D7CF0")),
//    .init(name: "Deutsch", code: "de",subName: "German",colorCode: UIColor(hexString: "#FF6E1A")),
//    .init(name: "Italiano", code: "it",subName: "Italian",colorCode: UIColor(hexString: "#57CC6A")),
//    .init(name: "Português ", code: "pt",subName: "Portuguese",colorCode: UIColor(hexString:"#00A719")),
//    .init(name: "한국어 ", code: "ko",subName: "Korean",colorCode: UIColor(hexString: "#F2002C")),
//]

var deviceLang :[String] = Locale.preferredLanguages

class themeImageView : UIImageView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup()
    {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor(named: "themeColor")
    }
}

class WhiteImageView : UIImageView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup()
    {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor.white
    }
}

class GrayImageView : UIImageView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup()
    {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor.lightGray
    }
}

class BlackImageView : UIImageView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup()
    {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor.black
    }
}

class ViewBorderRadius : UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup()
    {
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor(hexString: "#131412").withAlphaComponent(0.1).cgColor
        self.layer.cornerRadius = 18
    }
}

func AlertWithMessage(_ vc:UIViewController,message:String)
{
    let dialogBox = UIAlertController(title: "Alert!".localized(), message: message, preferredStyle: .alert)
    dialogBox.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: nil))
    vc.present(dialogBox, animated: true, completion: nil)
}

func AlertWithMessageForApp(_ vc:UIViewController,message:String)
{
    let dialogBox = UIAlertController(title: APPNAME.localized(), message: message, preferredStyle: .alert)
    dialogBox.addAction(UIAlertAction(title: "Ok".localized(), style: .default, handler: nil))
    vc.present(dialogBox, animated: true, completion: nil)
}
func AlertWithMessageTitle(title:String,message:String)
{
    let dialogBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
    dialogBox.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: nil))
    AdsManager.shared.topMostViewController?.present(dialogBox, animated: true, completion: nil)
}

func getContactsPermission()
{
    DispatchQueue.global(qos: .background).async {
        let store = CNContactStore()
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined || CNContactStore.authorizationStatus(for: .contacts) == .restricted {
            store.requestAccess(for: .contacts) { (Bool, error) in
                if Bool
                {
                    DispatchQueue.main.async
                      {
                    retrieveContactsWithStore()
                    }
                }
                else{
                    DispatchQueue.main.async
                    {
                        openSetting()
                    }
                }
            }
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            //   DispatchQueue.main.async {
            retrieveContactsWithStore()
            //   }
        } else if CNContactStore.authorizationStatus(for: .contacts) == .denied {
            DispatchQueue.main.async {
                openSetting()
            }
        }
    }
}

func openSetting()
{
    let alert = UIAlertController(title: "This app requires access to Contacts to proceed".localized(), message: "Would you like to open settings and grant permission to contacts?".localized(), preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok".localized(), style: .default) { action in
            // UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    })
//    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
//    })
    appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    
}
func retrieveContactsWithStore()
{
    getContactList()
}
//
func getContactList()
{
    contactsData = []
    let contactStore = CNContactStore()
    
    let key = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactImageDataKey,CNContactThumbnailImageDataKey,CNContactPhoneNumbersKey,CNContactEmailAddressesKey] as [CNKeyDescriptor]
    let request = CNContactFetchRequest(keysToFetch: key)
    request.sortOrder = CNContactSortOrder.givenName
    try? contactStore.enumerateContacts(with: request, usingBlock: { (contact, stoppingPointer) in
        let givenName = contact.givenName
        let familyName = contact.familyName
        let emailAddress = contact.emailAddresses.first?.value ?? ""
        let phoneNumber: [String] = contact.phoneNumbers.map{ $0.value.stringValue }
        let identifier = contact.identifier
        // var image = UIImage()a
        
        /* if contact.thumbnailImageData != nil{
         image = UIImage(data: contact.thumbnailImageData!)!
         
         }else if  contact.thumbnailImageData == nil ,givenName.isEmpty || familyName.isEmpty{
         // image = UIImage(named: "usertwo")!
         }*/
        if givenName != nil{
        contactsData.append(ContactsModel(givenName: givenName, familyName: familyName, phoneNumber: phoneNumber, emailAddress: emailAddress as String, identifier: identifier))
        }
    })
    
    print(contactsData)
    
}


func AlertWithMSG(mesg:String) {
    let alert = UIAlertController(title: "Alert".localized(), message: mesg, preferredStyle: .alert)
    let ok = UIAlertAction(title: "Ok".localized(), style: .default, handler: nil)
    alert.addAction(ok)
    let window :UIWindow = UIApplication.shared.keyWindow!
    window.rootViewController?.present(alert, animated: true)
}


//func NetworkChecking(){
//    do{
//        reachability = try Reachability()
//    }catch{
//        print("Unable to create Reachability")
//        return
//    }
//    NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
//
//    do {
//        try reachability?.startNotifier()
//    } catch {
//        print("This is not working.")
//        return
//    }
//}

//@objc func reachabilityChanged(_ note: NSNotification) {
//
//    let reachability = note.object as! Reachability
//
//    if reachability.connection != .none {
//        if reachability.connection == .wifi {
//            print("Reachable via WiFi")
//            self.switchOffline.isUserInteractionEnabled = true
//        } else {
//            print("Reachable via Cellular")
//            self.switchOffline.isUserInteractionEnabled = true
//        }
//    } else {
//        print("Not reachable")
//        self.switchOffline.isUserInteractionEnabled = false
//    }
//}
//
//override func viewDidDisappear(_ animated: Bool) {
//    self.btnSpeechToText.isSelected = false
//    self.speechToText.stopRecording()
//    self.stopTextToSpeech()
//}
