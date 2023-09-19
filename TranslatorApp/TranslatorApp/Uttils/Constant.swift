import Foundation
import UIKit
import MLKit



//App Details
let APPNAME                             = "TranslatorApp"
let APPID                               = "6459739575"
let RateLink                            = "https://itunes.apple.com/app/id\(APPID)?mt=8&action=write-review"
let AppURL                              = "https://itunes.apple.com/app/id\(APPID)?mt=8"
let PRIVACYPOLICY                       = "https://www.privacypolicycenter.com/view_custom.php?v=RlhpdHV5UGV2VnZyN21LNENpZ1dGZz09&n=Privacy-Policy"
let TERM_AND_CONDITION                  = "https://www.privacypolicycenter.com/view_custom.php?v=REZ2RFJOTXpXNllUNnpkWmFvV3MxUT09&n=Whats-Web---Whatsweb-Scan"
let MAIL                                = "erasoft.prachi@gmail.com"
//let ONESIGNAL_ID                        = "c4743f21-2f08-4cef-9cf2-3d5ddc1a6e82"
//let CancelPremium                       = "https://apps.apple.com/account/subscriptions"


/// Metrica Key
/// ////App Metrica
let APPMETRICA = "2b578a66-aab3-4af7-bbdb-3c5c22e09fba"

//let APP_METRICA_KEY = "76135721-83ef-4653-9912-6299c5ee518b"

let IN_APP_PURCHASE_IDS = ["com.erasoft.WebWhatsApp.monthly","com.erasoft.WebWhatsApp.yearly"]
let SHARE_SECRET = "40d6ccaba9ae46e199fc756a2fc6cb7d"
let expiredate = "Expiredate"
var isBackgound = Bool()

/// Storyboards
struct STORYBOARD {
    static var MAIN = UIStoryboard(name: "Main", bundle: nil)
}


//StoryBoatd
var mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)

//Tabbar Object
var tabBarVc = UITabBarController()
var isOnTabClick:Bool = true
//Database Object
//var db : DBHelper = DBHelper()

//Typealise Object
typealias objectCancel = () -> Void
typealias objectSelect = (_ captionText: String, _ name: String, _ colorCode: String) -> Void

//Color
var StartColor = UIColor(hexString: "#FA0000")
var EndColor = UIColor(hexString: "#FF6E1D")
var StartColorlabel = UIColor(hexString: "#FA0000")
var EndColorlabel = UIColor(hexString: "#FF6E1D")

//Contact Model
var contactsData = [ContactsModel]()
var arrContact = [Any]()
var arrOfColor:[String] = ["#4285F4","#FBBC05","#23A159","#9F32C5"]

//Device Time Format
var formatString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
var hasAMPM = formatString.contains("a")

//Ads
//var appOpenAd : GADAppOpenAd?
//var appOpenAdVar : GADAppOpenAd?
var loadTime = Date()
var isFirstTIme : Bool = false



/// Google Ads

struct GOOGLE_ADS { // Google Testing Ads
    static var ADMOB_KEYS_CONFIG = "ca-app-pub-3940256099942544~1458002511"
    static var INTERSITIAL_ADS_ID = "ca-app-pub-3940256099942544/4411468910"
    static var NATIVE_ADS_ID = "ca-app-pub-3940256099942544/3986624511"
    static var BANNER_ADS_ID = "ca-app-pub-3940256099942544/2934735716"
    static var APP_OPEN_AD = "ca-app-pub-3940256099942544/5662855259"
}

//struct GOOGLE_ADS { // Google Live Ads
//    static var ADMOB_KEYS_CONFIG = "ca-app-pub-8252529408738635~5402377286"
//    static var INTERSITIAL_ADS_ID = "ca-app-pub-8252529408738635/8296133936"
//    static var NATIVE_ADS_ID = "ca-app-pub-8252529408738635/3788793159"
//    static var BANNER_ADS_ID = "ca-app-pub-8252529408738635/5090266539"
//    static var APP_OPEN_AD = "ca-app-pub-8252529408738635/2656794448"
//}
 
// MARK: Languages
var ARR_LANGUAGE: [LanguageModel] = []
//typealias objectCancel = () -> Void

var langCode:[String] = ["zh","ar","en","af","ak","am","as","ay","az","be","bg","bh","bm", "bn","bs","ca","co","cs","cy","da",
                        "de","dv","ee","el","eo","es","et","eu","fa","fi","fr","fy","ga","gd","gl","gn","gu","ha","he","hi","hr","ht","hu","hy","id","ig","is","it","ja","jv","ka","kk","km","kn","ko","ku","ky","la","lb","lg","ln","lo","lt","lv","mg","mi","mk","ml","mn","mr","ms","mt","my","nb","ne","nl","no","ny","om","or","pa","pl","ps","pt","qu","ro","ru","rw","sa","sd","si","sk","sl","sm","sn","so","sq","sr","st","su","sv","sw","ta","te","tg","th","ti","tk","tl","tr","ts","tt","tw","ug","uk","ur","uz","vi","xh","yi","yo","zu"]
//MARK: - Offline Langauge
let locale = Locale.current
var allLanguages = TranslateLanguage.allLanguages().sorted {
    return locale.localizedString(forLanguageCode: $0.rawValue)!
    < locale.localizedString(forLanguageCode: $1.rawValue)!
}



