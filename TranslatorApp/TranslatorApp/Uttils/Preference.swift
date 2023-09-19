import UIKit
class Preference: NSObject {
static let sharedInstance = Preference()

let IS_SUBSCRIBE                      = "IS_SUBSCRIBE_KEY"
let App_LANGUAGE_KEY                  = "AppLanguageKey"
let App_LANGUAGE_NAME                 = "AppLanguageName"
let App_LANGUAGE_SELECTEDINDEX        = "AppLanguageINDEX"
let FRIST_TIME                        = "FristTime"
let SHOW_LANGUAGE                     = "SHOW_LANGUAGE"
let SHOW_PARMISSION                   = "SHOW_PARMISSION"
let SHOW_CONFIRM_PRIVACY_SCREEN       = "SHOW_CONFIRM_PRIVACY_SCREEN_KEY"
let REPORT_COUNT                      = "REPORT_COUNT"
let SHOW_DARKMODE                     = "SHOW_DARKMODE"
let SHOW_RATE_US                      = "SHOW_RATE_US"
let HIDDEN_URLS                       = "HIDDEN_URLS"
let REVIEW_ADD                        = "IS_REVIEW_ADD"
let STORE_DATE                        = "DATE_UPDATE"
let STORE_TIME                        = "TIME_UPDATE"
let HISTORY                           = "HISTORY_KEY"
let BOOKMARK                          = "BOOKMARK_KEY"
let LANGUAGE1                         = "LANGEAGE_1_KEY"
let LANGUAGE2                         = "LANGEAGE_2_KEY"
let AUTO_CAPITALIZATION               = "AUTO_CAPITALIZATION_KEY"
}

func setDataToPreference(data: AnyObject, forKey key: String) {
UserDefaults.standard.set(data, forKey: key)
UserDefaults.standard.synchronize()
}

func getDataFromPreference(key: String) -> AnyObject? {
return UserDefaults.standard.object(forKey: key) as AnyObject?
}

func removeDataFromPreference(key: String) {
UserDefaults.standard.removeObject(forKey: key)
UserDefaults.standard.synchronize()
}

func removeUserDefaultValues() {
UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
UserDefaults.standard.synchronize()
}

// MARK: - Subscribe Methods
func setIsUserSubscribe(isSubscribe: Bool) {
setDataToPreference(data: isSubscribe as AnyObject, forKey: Preference.sharedInstance.IS_SUBSCRIBE)
}

func isUserSubscribe() -> Bool {
let isAccepted = getDataFromPreference(key: Preference.sharedInstance.IS_SUBSCRIBE)
return isAccepted == nil ? false : (isAccepted as! Bool)
}

// Show Language Screen

func setLanguageCode(str:String){
UserDefaults.standard.set(str, forKey: Preference.sharedInstance.App_LANGUAGE_KEY)
}

func setLanguageName(str:String){
UserDefaults.standard.set(str, forKey: Preference.sharedInstance.App_LANGUAGE_NAME)
}

func setLanguageIndex(int:Int){
UserDefaults.standard.set(int, forKey: Preference.sharedInstance.App_LANGUAGE_SELECTEDINDEX)
}


func getLanguageCode() -> String{
let code = UserDefaults.standard.object(forKey: Preference.sharedInstance.App_LANGUAGE_KEY) as? String
if code == nil {
    return "en"
}else{
    return code!
}
}

// Show Intro Screen
func setIsFristTime(status:Bool){
UserDefaults.standard.set(status, forKey: Preference.sharedInstance.FRIST_TIME)
}

func isShowFristTime() -> Bool{
let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.FRIST_TIME)
return status
}

// Rate Review
func setReview(status:Bool){
UserDefaults.standard.set(status, forKey: Preference.sharedInstance.REVIEW_ADD)
}

func isReviewAdd() -> Bool{
let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.REVIEW_ADD)
return status
}
//Store Date
func storeDate(str:String){
UserDefaults.standard.set(str, forKey: Preference.sharedInstance.STORE_DATE)
}

//store Time
func storeTime(str:String){
UserDefaults.standard.set(str, forKey: Preference.sharedInstance.STORE_TIME)
}



// Show Parmission Screen
func setIsParmission(status:Bool){
UserDefaults.standard.set(status, forKey: Preference.sharedInstance.SHOW_PARMISSION)
}

func isShowPermission() -> Bool{
let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.SHOW_PARMISSION)
return status
}

// Show Lan Screen

func setIsLanguage(status:Bool){
UserDefaults.standard.set(status, forKey: Preference.sharedInstance.SHOW_LANGUAGE)
}

func isShowLanguage() -> Bool{
let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.SHOW_LANGUAGE)
return status
}


// Show Config Screen
func setIsShowConfirmPrivacyScreen(isShow: Bool) {
setDataToPreference(data: isShow as AnyObject, forKey: Preference.sharedInstance.SHOW_CONFIRM_PRIVACY_SCREEN)
}

func isShowConfirmPrivacyScreen() -> Bool {
let isAccepted = getDataFromPreference(key: Preference.sharedInstance.SHOW_CONFIRM_PRIVACY_SCREEN)
return isAccepted == nil ? false : (isAccepted as! Bool)
}


// Show Intro Screen

func setIsDarkMode(status:Bool){
UserDefaults.standard.set(status, forKey: Preference.sharedInstance.SHOW_DARKMODE)
}

func isShowDarkMode() -> Bool{
let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.SHOW_DARKMODE)
return status
}


// Show Rate Us Screen

func setIsRateUS(status:Bool){
UserDefaults.standard.set(status, forKey: Preference.sharedInstance.SHOW_RATE_US)
}

func isShowRateUs() -> Bool{
let status = UserDefaults.standard.bool(forKey: Preference.sharedInstance.SHOW_RATE_US)
return status
}


// MARK: History
func setHistory(model: HistoryModel) {
    var arrModel = getHistory()
    let index = arrModel.firstIndex { temp in
        temp.id == model.id
    }
    if index == nil {
        arrModel.append(model)
    } else {
        arrModel.remove(at: index!)
    }
    
    UserDefaults.standard.set(encodable: arrModel, forKey: Preference.sharedInstance.HISTORY)
}

func getHistory() -> [HistoryModel] {
    if let data = UserDefaults.standard.get([HistoryModel].self, forKey: Preference.sharedInstance.HISTORY) {
        return data
    }
    return [HistoryModel]()
}

// MARK: Bookmark
func setBookmark(model: HistoryModel) {
    var arrModel = getBookmark()
    let index = arrModel.firstIndex { temp in
        temp.id == model.id
    }
    if index == nil {
        arrModel.append(model)
    } else {
        arrModel.remove(at: index!)
    }
    
    UserDefaults.standard.set(encodable: arrModel, forKey: Preference.sharedInstance.BOOKMARK)
}

func getBookmark() -> [HistoryModel] {
    if let data = UserDefaults.standard.get([HistoryModel].self, forKey: Preference.sharedInstance.BOOKMARK) {
        return data
    }
    return [HistoryModel]()
}


// MARK: - Set Selected Defalut Language
func getLanuage1() -> LanguageModel {
    if let data = UserDefaults.standard.get(LanguageModel.self, forKey: Preference.sharedInstance.LANGUAGE1) {
        return data
    }
    return LanguageModel.init(code: "en", name: "English", img: "English", isValidToSpeak: true) // Return Default English Language
}

func setLanguage1(langModel: LanguageModel) {
    UserDefaults.standard.set(encodable: langModel, forKey: Preference.sharedInstance.LANGUAGE1)
}

func getLanuage2() -> LanguageModel {
    if let data = UserDefaults.standard.get(LanguageModel.self, forKey: Preference.sharedInstance.LANGUAGE2) {
        return data
    }
    return LanguageModel.init(code: "hi", name: "Hindi", img: "Hindi", isValidToSpeak: true) // Return Default Hindi Language
}

func setLanguage2(langModel: LanguageModel) {
    UserDefaults.standard.set(encodable: langModel, forKey: Preference.sharedInstance.LANGUAGE2)
}


func isAutoCapitalization() -> Bool {
    let isEnable = getDataFromPreference(key: Preference.sharedInstance.AUTO_CAPITALIZATION)
    return isEnable == nil ? false : (isEnable as! Bool)
}
