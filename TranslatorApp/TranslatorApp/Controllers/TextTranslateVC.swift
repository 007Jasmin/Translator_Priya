//
//  TextTranslateVC.swift
//  Translate All
//
//  Created by admin on 09/07/22.
//

import UIKit
import Speech
import MLKit
import SVProgressHUD
import SystemConfiguration
import NetworkExtension

class TextTranslateVC: UIViewController {
    
    // OUTLET
    @IBOutlet weak var btnLang1: UIButton!
    @IBOutlet weak var btnLang2: UIButton!
    @IBOutlet weak var lblLang1: UILabel!
    @IBOutlet weak var lblLang2: UILabel!
    
    @IBOutlet weak var btnClearTxt: UIButton! {
        didSet { btnClearTxt.isHidden = true }
    }
    @IBOutlet weak var btnCamera: Button!
    @IBOutlet weak var btnTranslate: Button! {
        didSet { btnTranslate.isHidden = true }
    }
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnCopy: Button!
    @IBOutlet weak var btnShare: Button!
    @IBOutlet weak var btnFavourite: Button!
    @IBOutlet var lblHeader:UILabel!
    @IBOutlet weak var txtViewInput: UITextView! {
        didSet { txtViewInput.delegate = self }
    }
    @IBOutlet weak var lblPlaceholder: UILabel!
    @IBOutlet weak var txtViewOutput: UITextView!
    @IBOutlet weak var viewOutput: UIView!
    @IBOutlet var constOutputHeight:NSLayoutConstraint! {
        didSet{ constOutputHeight.constant = 0}
    }
    @IBOutlet weak var btnSpeechToText: Button!
    @IBOutlet weak var btnSpeeck: UIButton!
    
    @IBOutlet weak var viewHistory: UIView!
    @IBOutlet weak var tblHistory: UITableView! {
        didSet {
            tblHistory.delegate = self
            tblHistory.dataSource = self
            tblHistory.register(HistoryTVC.nib, forCellReuseIdentifier: HistoryTVC.className)
        }
    }
    @IBOutlet weak var tblHistoryHightConstant: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet { activityIndicator.stopAnimating() }
    }
    @IBOutlet var viewNativeAds: UIView!
    @IBOutlet var nativeAdsHeight: NSLayoutConstraint!
    @IBOutlet var switchOffline: UISwitch!
    @IBOutlet var lblOffline: UILabel!
    @IBOutlet var lblOfflineSubStr: UILabel!
    @IBOutlet var indicator:UIActivityIndicatorView!
    @IBOutlet var lblStatus:UILabel!
    @IBOutlet var indicatorView:UIView!
    
    // VARIABLE
    var langModel1 = getLanuage1()
    var langModel2 = getLanuage2()
    var arrHistory = [HistoryModel]()
    var selectImage = SelectImage()
    var speechToText = SpeetchToText()
    var timerSpeech = Timer()
    var timerTranslate = Timer()
    var timerSpeechBtn = Timer()
    var translator: Translator!
    
    // Speech
    // var utterance = AVSpeechUtterance()
    let synth = AVSpeechSynthesizer()
    let locale = Locale.current
    lazy var allLanguages = TranslateLanguage.allLanguages().sorted {
        return locale.localizedString(forLanguageCode: $0.rawValue)!
        < locale.localizedString(forLanguageCode: $1.rawValue)!
    }
    var reachability: Reachability!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: .normal)
        // UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: .selected)
        
        // setData()
        if #available(iOS 14.0, *) {
            btnFavourite.isHidden = true
            btnCopy.isHidden = true
            btnShare.isHidden = true
            btnMore.isHidden = false
        } else {
            btnFavourite.isHidden = false
            btnCopy.isHidden = false
            btnShare.isHidden = false
            btnMore.isHidden = true
        }
        
//        if !AppDelegate().sharedDelegate().isSubscribed {
//            let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: InAppPremiumVC.className) as! InAppPremiumVC
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //getHistoryData()
        self.indicatorView.isHidden = true
        lblHeader.text = "Translate Now".localized()
      //  lblOffline.text = "Offline Translation".localized()
        lblPlaceholder.text = "Enter text here...".localized()
        //self.nativeAdsHeight.constant = 0
//        if !isUserSubscribe(){
//            if Reachability.isConnectedToNetwork(){
//                if AdsManager.shared.arrNativeAds.count > 0{
//                    showAdsView3(view: self.viewNativeAds)
//                    self.nativeAdsHeight.constant = 320
//                }
//            }
//        }
        
        if isAutoCapitalization() {
            txtViewInput.autocapitalizationType = .words
        } else {
            txtViewInput.autocapitalizationType = .none
        }
        
        // When we change language into setting screen and after we come in home screen at that time previus and new language are not same so translate text
        if langModel2.code != getLanuage2().code {
            setData()
            btnTranslateClicked(UIButton())
        } else {
            setData()
        }
        isLanguageAvailbleForDownload()
        self.setDownloadDeleteButtonLabels()
        //self.switchOffline.isUserInteractionEnabled = true
        NetworkChecking()
    }
    
//    func NetworkChecking(){
//        do{
//            reachability = try Reachability()
//        }catch{
//            print("Unable to create Reachability")
//            return
//        }
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
//
//        do {
//            try reachability?.startNotifier()
//        } catch {
//            print("This is not working.")
//            return
//        }
//    }
//
//    @objc func reachabilityChanged(_ note: NSNotification) {
//
//        let reachability = note.object as! Reachability
//
//        if reachability.connection != .none {
//            if reachability.connection == .wifi {
//                print("Reachable via WiFi")
//                self.switchOffline.isUserInteractionEnabled = true
//            } else {
//                print("Reachable via Cellular")
//                self.switchOffline.isUserInteractionEnabled = true
//            }
//        } else {
//            print("Not reachable")
//            self.switchOffline.isUserInteractionEnabled = false
//        }
//    }
//
    override func viewDidDisappear(_ animated: Bool) {
        self.btnSpeechToText.isSelected = false
        self.speechToText.stopRecording()
        self.stopTextToSpeech()
    }
    
    //MARK: - offline Translation
    
    func translate() {
        var inputLanguage:TranslateLanguage!
        var outputLanguage:TranslateLanguage!
        for i in 0..<allLanguages.count{
            if allLanguages[i].rawValue == langModel1.code{inputLanguage = allLanguages[i]}
            
        }
        for i in 0..<allLanguages.count{
            if allLanguages[i].rawValue == langModel2.code{outputLanguage = allLanguages[i]}
        }
        if let inputLanguage = inputLanguage,let outputLanguage = outputLanguage{
            let options = TranslatorOptions(sourceLanguage: inputLanguage, targetLanguage: outputLanguage)
            translator = Translator.translator(options: options)
            self.setDownloadDeleteButtonLabels()
            let translatorForDownloading = self.translator!
            translatorForDownloading.downloadModelIfNeeded { error in
                guard error == nil else {
                    self.txtViewOutput.text = ""
                    return
                }
                if translatorForDownloading == self.translator {
                    translatorForDownloading.translate(self.txtViewInput.text ?? "") { result, error in
                        guard error == nil else {
                            // self.txtViewOutput.text = "Failed with error \(error!)"
                            AlertWithMSG(mesg: "Not availabel for offline translation".localized())
                            return
                        }
                        if translatorForDownloading == self.translator {
                            self.txtViewOutput.text = result
                            self.btnSpeeck.isUserInteractionEnabled = true
                            self.btnSpeeck.alpha = 0.5
                            self.btnMore.alpha = 0.5
                            self.btnMore.isUserInteractionEnabled = false
                        }
                    }
                }
            }
        }
    }
    
    /* func handleDownloadLanguage1() {
     var language:TranslateLanguage!
     for i in 0..<allLanguages.count{
     print("allLanguages",allLanguages[i].rawValue)
     if allLanguages[i].rawValue == langModel1.code{language = allLanguages[i]}
     }
     if language == .english { return }
     let model = self.model(forLanguage: language)
     let modelManager = ModelManager.modelManager()
     let languageName = Locale.current.localizedString(forLanguageCode: language.rawValue)
     if modelManager.isModelDownloaded(model) {
     print("Deleting \(languageName)")
     modelManager.deleteDownloadedModel(model) { error in
     print("Deleted \(languageName)")
     }
     } else {
     print("Downloading \(languageName)")
     let conditions = ModelDownloadConditions(
     allowsCellularAccess: true,
     allowsBackgroundDownloading: true
     )
     modelManager.download(model, conditions: conditions)
     }
     }*/
    
    func handleDownloadLanguage2(langModal:LanguageModel) {
        var language:TranslateLanguage!
        for i in 0..<allLanguages.count{
            print("allLanguages",allLanguages[i].rawValue)
            if allLanguages[i].rawValue == langModal.code{language = allLanguages[i]}
        }
        if language == .english { return }
        let model = self.model(forLanguage: language)
        let modelManager = ModelManager.modelManager()
        let languageName = Locale.current.localizedString(forLanguageCode: language.rawValue)
        if modelManager.isModelDownloaded(model) {
            
            self.switchOffline.isOn = true
        } else {
            tabBarController?.tabBar.isUserInteractionEnabled = false
            print("Downloading \(languageName)")
            self.indicatorView.isHidden = false
            self.indicator.startAnimating()
            self.lblStatus.text = "\("Downloading".localized()) \(langModal.name)"
            //            SVProgressHUD.show(withStatus: "\("Downloading".localized()) \(langModal.name)")
            let conditions = ModelDownloadConditions(
                allowsCellularAccess: true,
                allowsBackgroundDownloading: true
            )
            modelManager.download(model, conditions: conditions)
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if modelManager.isModelDownloaded(model) {
                    self.switchOffline.isOn = true
                    self.indicatorView.isHidden = true
                    self.tabBarController?.tabBar.isUserInteractionEnabled = true
                    timer.invalidate()
                }
            }
        }
    }
    
    @objc func remoteModelDownloadDidComplete(notification: NSNotification) {
        let userInfo = notification.userInfo!
        guard let remoteModel = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue] as? TranslateRemoteModel else { return }
        weak var weakSelf = self
        DispatchQueue.main.async {
            guard let strongSelf = weakSelf else {
                print("Self is nil!")
                return
            }
            let languageName = Locale.current.localizedString(forLanguageCode: remoteModel.language.rawValue)!
            if notification.name == .mlkitModelDownloadDidSucceed {
                //SVProgressHUD.dismiss()
                self.indicatorView.isHidden = true
                print("Download succeeded for \(languageName)")
            } else {
                self.indicatorView.isHidden = true
                AlertWithMSG(mesg: "Please connet to internet".localized())
                print("Download failed for \(languageName)")
            }
            self.setDownloadDeleteButtonLabels()
        }
    }
    
    func model(forLanguage: TranslateLanguage) -> TranslateRemoteModel {
        return TranslateRemoteModel.translateRemoteModel(language: forLanguage)
    }
    
    func isLanguageDownloaded(_ language: TranslateLanguage) -> Bool {
        let model = self.model(forLanguage: language)
        let modelManager = ModelManager.modelManager()
        return modelManager.isModelDownloaded(model)
    }
    
    func setDownloadDeleteButtonLabels() {
        let inputLanguage =  TranslateLanguage(rawValue: langModel1.code)
        let outputLanguage =  TranslateLanguage(rawValue: langModel2.code)
        if self.isLanguageDownloaded(outputLanguage) && self.isLanguageDownloaded(inputLanguage){
            self.switchOffline.isOn = true
        }
//        else {
//            self.switchOffline.isOn = false
//        }
    }
    
    func isLanguageAvailbleForDownload(){
        
        if allLanguages.contains(where: {$0.rawValue == langModel2.code}){
            print("Availabel offline")
            //self.switchOffline.isOn = true
          //  self.lblOfflineSubStr.text = ""
            //            setDownloadDeleteButtonLabels()
                //self.switchOffline.isUserInteractionEnabled = true
        }else{
            print("Not Availabel offline")
            self.lblOfflineSubStr.text = "\(langModel2.name) \("language is not available for offline Translation".localized())"
            self.switchOffline.isUserInteractionEnabled = false
            self.switchOffline.isOn = false
        }
    }
    
    //MARK: - Switch for Offline translation
    @IBAction func switchDownloadLanguage(_ sender: UISwitch) {
        //        self.switchOffline.isOn != false
        
//        if !isUserSubscribe() {
//            let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: InAppPremiumVC.className) as! InAppPremiumVC
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true)
//        }else{
            if Reachability.isConnectedToNetwork(){
                self.switchOffline.isUserInteractionEnabled = true
                let inputLanguage =  TranslateLanguage(rawValue: langModel1.code)
                let outputLanguage =  TranslateLanguage(rawValue: langModel2.code)
                if !self.isLanguageDownloaded(outputLanguage) || !self.isLanguageDownloaded(inputLanguage){
                    let alertVC: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                    if !self.isLanguageDownloaded(outputLanguage){
                        alertVC.addAction(UIAlertAction(title:"\("Download".localized()) \(langModel2.name)", style:UIAlertAction.Style.default, handler:{
                            [self] action in
                            self.handleDownloadLanguage2(langModal: langModel2)
                        }))
                    }else{
                        alertVC.addAction(UIAlertAction(title:"\("Download".localized()) \(langModel1.name)", style:UIAlertAction.Style.default, handler:{
                            [self] action in
                            self.handleDownloadLanguage2(langModal: langModel1)
                        }))
                    }
                    
                    alertVC.addAction(UIAlertAction(title:"Cancel".localized(), style:UIAlertAction.Style.cancel, handler:{
                        action in
                        self.switchOffline.isOn = false
                    }))
                    self.present(alertVC, animated: true)
                }
            }else{
                APIManager().networkErrorMsg()
                self.switchOffline.isOn = false
            }
       // }
        
    }
    
    // MARK: - Methods
    func setData() {
        langModel1 = getLanuage1()
        langModel2 = getLanuage2()
        
        btnLang1.setTitle(langModel1.name, for: .normal)
        btnLang2.setTitle(langModel2.name, for: .normal)
        lblLang1.text = langModel1.name
        lblLang2.text = langModel2.name
        btnSpeechToText.isEnabled = langModel1.isValidToSpeak
        btnSpeeck.isHidden = !langModel2.isValidToSpeak
        btnSpeeck.isUserInteractionEnabled = false
        btnSpeeck.alpha = 0.5
        self.btnMore.alpha = 0.5
        self.btnMore.isUserInteractionEnabled = false
        self.setDownloadDeleteButtonLabels()
        if !Reachability.isConnectedToNetwork(){
            self.switchOffline.isUserInteractionEnabled = false
        }
//        else{
//            self.switchOffline.isUserInteractionEnabled = false
//        }
    }
    
    func getHistoryData() {
        arrHistory = getHistory().reversed()
        tblHistory.reloadData()
    }
    
    func setHistoryOfTranlate() {
        if txtViewInput.text.trimmed.count != 0 && txtViewOutput.text.trimmed.count != 0 {
            var tempModel = HistoryModel.init()
            tempModel.id = UUID().uuidString
            tempModel.langModel1 = langModel1
            tempModel.langModel2 = langModel2
            tempModel.strSource = txtViewInput.text.trimmed
            tempModel.strDestination = txtViewOutput.text.trimmed
            setHistory(model: tempModel)
            //            getHistoryData()
        }
    }
    
    func translateText(_ sourceLangIOSCode: String, _ translateIOSLang: String, text: String, isSaveFromHistory: Bool) {
        let url = String.init(format: API.TRANSLATE,  translateIOSLang,sourceLangIOSCode, text )
        if let validUrl = convertStringToValidUrl(strUrl: url) {
            activityIndicator.startAnimating()
            if self.txtViewInput.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                self.activityIndicator.stopAnimating()
                self.txtViewOutput.text = ""
                return
            }
            TextTranslateViewModel().translateText(false, validUrl) { translateResponceModel, error in
                if self.txtViewInput.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                    self.activityIndicator.stopAnimating()
                    self.txtViewOutput.text = ""
                    return
                }
                if let data = translateResponceModel {
                    if data.sentences.count > 0 {
                        // self.txtViewOutput.text = data.sentences[0].trans
                        self.activityIndicator.stopAnimating()
                        self.txtViewOutput.text = data.sentences.map({ $0.trans }).joined(separator: "")
                        self.btnSpeeck.isUserInteractionEnabled = true
                        self.btnSpeeck.alpha = 1
                        self.btnMore.alpha = 1
                        self.btnMore.isUserInteractionEnabled = true
                        self.constOutputHeight.constant = 149
                       // showAdsView1(view: self.viewNativeAds)
                       // self.nativeAdsHeight.constant = 140
                        self.btnMoreClicked(self.btnMore)
                        if isSaveFromHistory {
                            self.setHistoryOfTranlate()
                        }
                    }
                } else {
                    displayToast(error?.localizedDescription ?? "")
                }
            }
        } else {
            displayToast("Enter text is invalid !".localized())
        }
    }
    
    func stopTextToSpeech() {
        if synth.isSpeaking {
            synth.stopSpeaking(at: .immediate)
        }
    }
    
    // MARK: - Button Click
    @IBAction func btnPremiumClicked(_ sender: Any) {
//        self.view.endEditing(true)
//        let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: InAppPremiumVC.className) as! InAppPremiumVC
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true)
    }
    
    @IBAction func btnSwipeLanguageClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            sender.transform = sender.transform.rotated(by: CGFloat(CGFloat.pi))
        }
        (langModel1, langModel2) = (langModel2, langModel1) // Swipe Values
        setLanguage1(langModel: langModel1)
        setLanguage2(langModel: langModel2)
        setData()
        txtViewInput.text = txtViewOutput.text
        btnTranslateClicked(UIButton())
    }
    
    @IBAction func btnSelectLanguageClicked(_ sender: UIButton) {
        
        self.view.endEditing(true)
        self.btnSpeechToText.isSelected = false
        self.speechToText.stopRecording()
        self.stopTextToSpeech()
        
        let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: SelectLanguageVC.className) as! SelectLanguageVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.languageModel1 = langModel1
        vc.languageModel2 = langModel2
        vc.selectLanguage = sender.tag
        vc.callBack = { langModel1, langModel2 in
            setLanguage1(langModel: langModel1)
            setLanguage2(langModel: langModel2)
            self.langModel1 = langModel1
            self.langModel2 = langModel2
            self.setData()
            self.isLanguageAvailbleForDownload()
            self.setDownloadDeleteButtonLabels()
            if self.txtViewInput.text.trimmed.count > 0 {
                if !Reachability.isConnectedToNetwork(){
                    self.translate()
                }else{
                    self.translateText(self.langModel1.code, self.langModel2.code, text: self.txtViewInput.text.trimmed, isSaveFromHistory: false)
                }
            }
        }
        self.present(vc, animated: true)
    }
    
    @IBAction func btnClearTxtClicked(_ sender: Any) {
        setHistoryOfTranlate()
        self.btnSpeeck.alpha = 0.5
        self.btnSpeeck.isUserInteractionEnabled = false
        self.btnMore.alpha = 0.5
        self.btnMore.isUserInteractionEnabled = false
        txtViewInput.text = ""
        txtViewOutput.text = ""
        constOutputHeight.constant = 0
        
//        showAdsView3(view: self.viewNativeAds)
//        self.nativeAdsHeight.constant = 320
        stopTextToSpeech()
//        // Show inapp purchas after 6 time translate
//        if arrHistory.count >= 6 && !AppDelegate().sharedDelegate().isSubscribed {
//            let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: InAppPremiumVC.className) as! InAppPremiumVC
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true)
//        }
    }
    
    @IBAction func btnCameraClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        PermissionManager().checkCameraPermission {
            self.selectImage.selectImage(sender.frame, self) { image in
                recognizeTextFromImage(image: image) { recognizeText in
                    if recognizeText.isEmpty {
                        let alert = UIAlertController.init(title: "Alert".localized(), message: "Text not recognize into your image !".localized(), preferredStyle: .alert)
                        alert.addAction(UIAlertAction.init(title: "Ok".localized(), style: .default))
                        self.present(alert, animated: true)
                    } else {
                        self.txtViewInput.text = recognizeText
                    }
                }
            }
        }
    }
    
    @IBAction func btnSpeechToTextClicked(_ sender: Any) {
        self.view.endEditing(true)
//        if arrHistory.count >= 6 && !AppDelegate().sharedDelegate().isSubscribed {
//            let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: InAppPremiumVC.className) as! InAppPremiumVC
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true)
//            return
//        }
        
        func onClick() {
            if !btnSpeechToText.isSelected {
                btnSpeechToText.isSelected = true
                timerSpeechBtn.invalidate()
                timerSpeechBtn = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
                    timer.invalidate()
                    self.timerSpeechBtn.invalidate()
                    self.speechToText = SpeetchToText()
                    self.speechToText.startRecording(languageCode: self.langModel1.code) { string in
                        debugPrint("Text -> \(string)")
                        self.txtViewInput.text = string
                        self.timerSpeech.invalidate()
                        self.timerSpeech = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
                            timer.invalidate()
                            self.timerSpeech.invalidate()
                            self.speechToText.stopRecording()
                            self.btnSpeechToText.isSelected = false
                            if !string.isEmpty {
                                if !Reachability.isConnectedToNetwork(){
                                    self.translate()
                                }else{
                                    self.translateText(self.langModel1.code, self.langModel2.code, text: string, isSaveFromHistory: true)
                                }
                            }
                        })
                    }
                })
            } else {
                timerSpeechBtn.invalidate()
                timerSpeech.invalidate()
                btnSpeechToText.isSelected = false
                speechToText.stopRecording()
                if txtViewInput.text.trimmed.count != 0 {
                    if !Reachability.isConnectedToNetwork(){
                        self.translate()
                    }else{
                        self.translateText(self.langModel1.code, self.langModel2.code, text: txtViewInput.text.trimmed, isSaveFromHistory: true)
                    }
                }
            }
        }
        PermissionManager().checkRecordingPermission {
            PermissionManager().checkSpeechToTextRecognizePermission {
                DispatchQueue.main.async {
                    onClick()
                }
            }
        }
    }
    
    @IBAction func btnTranslateClicked(_ sender: Any) {
        if txtViewInput.text.trimmed.count != 0 {
            if !Reachability.isConnectedToNetwork(){
                if switchOffline.isOn{
                    self.translate()
                }else{
                    displayToast("Please Enable Offline Mode..")
                }
            }else{
                translateText(langModel1.code, langModel2.code, text: txtViewInput.text.trimmed, isSaveFromHistory: false)
            }
        }
    }
    
    @IBAction func btnSpeeckClicked(_ sender: Any) {
        self.view.endEditing(true)
        DispatchQueue.main.async {
            let utterance = AVSpeechUtterance(string: self.txtViewOutput.text.trimmed )
            utterance.voice = AVSpeechSynthesisVoice(language: self.langModel2.code)
            utterance.volume = 100.0
            self.synth.delegate = self
            if self.synth.isSpeaking {
                self.synth.stopSpeaking(at: .immediate)
                self.btnSpeeck.alpha = 0.5
                self.btnSpeeck.isSelected = false
                self.btnMore.alpha = 0.5
                self.btnMore.isUserInteractionEnabled = false
            } else {
                self.synth.speak(utterance)
                self.btnSpeeck.alpha = 1
                self.btnSpeeck.isSelected = true
                self.btnMore.alpha = 1
                self.btnMore.isUserInteractionEnabled = true
            }
        }
    }
    
    @IBAction func btnBookmark(_ sender: Any) {
        if txtViewInput.text.trimmed.count != 0 && txtViewOutput.text.trimmed.count != 0 {
            var tempModel = HistoryModel.init()
            tempModel.id = UUID().uuidString
            tempModel.langModel1 = langModel1
            tempModel.langModel2 = langModel2
            tempModel.strSource = txtViewInput.text.trimmed
            tempModel.strDestination = txtViewOutput.text.trimmed
            
            setBookmark(model: tempModel)
            displayToast("Add to favourite successfully".localized())
        }
    }
    
    @IBAction func btnCopyClicked(_ sender: Any) {
        self.view.endEditing(true)
        copyText(str: txtViewOutput.text ?? "")
    }
    
    @IBAction func btnHistory(_ sender: Any) {
        let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: CameraCaptureVC.className) as! CameraCaptureVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnShareClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        shareText(self, txtViewOutput.text ?? "")
    }
    
    @IBAction func btnMoreClicked(_ sender: UIButton) {
        if #available(iOS 14.0, *) {
            let isFavourite = getBookmark().filter({ $0.strDestination == txtViewOutput.text.trimmed })
            let favorite = UIAction(title: isFavourite.count > 0 ? "Unfavourite".localized() : "Favourite".localized(), image: UIImage(systemName: isFavourite.count > 0 ? "heart.fill" : "heart")) { [self] _ in
                if txtViewInput.text.trimmed.count != 0 && txtViewOutput.text.trimmed.count != 0 {
                    var tempModel = HistoryModel.init()
                    tempModel.id = UUID().uuidString
                    tempModel.langModel1 = langModel1
                    tempModel.langModel2 = langModel2
                    tempModel.strSource = txtViewInput.text.trimmed
                    tempModel.strDestination = txtViewOutput.text.trimmed
                    if isFavourite.count > 0 {
                        setBookmark(model: isFavourite[0])
                        displayToast("Remove to from favourite successfully".localized())
                    } else {
                        setBookmark(model: tempModel)
                        displayToast("Add to favourite successfully".localized())
                    }
                    btnMoreClicked(btnMore)
                }
            }
            
            let copy = UIAction(title: "Copy".localized(), image: UIImage(systemName: "doc.on.doc")) { _ in
                copyText(str: self.txtViewOutput.text ?? "")
            }
            let share = UIAction(title: "Share".localized(), image: UIImage(systemName: "square.and.arrow.up")) { _ in
                let shareStr = "\(self.txtViewInput.text ?? "")\n\(self.txtViewOutput.text ?? "")"
                shareText(self, shareStr)
            }
            btnMore.showsMenuAsPrimaryAction = true
            btnMore.menu = UIMenu(title: "", children: [favorite, copy, share])
        }
    }
    
    @IBAction func btnExitApp(_ sender: UIButton){
        if !APIManager.isConnectedToNetwork() {
            let alert = UIAlertController.init(title: "Alert".localized(), message: "Are you sure you want to exit the app?".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancel".localized(), style: .destructive, handler: nil))
            alert.addAction(UIAlertAction.init(title: "Yes".localized(), style: .default, handler: { ACTION in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                }
            }))
            self.present(alert, animated: true)
        }
//        else{
//            if UserDefaults.standard.bool(forKey: "RatingDone") == false{
//                let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: RatingVc.className) as! RatingVc
//                vc.modalPresentationStyle = .overCurrentContext
//                vc.objCancel = {
//                    //                    self.dismiss(animated: false, completion: nil)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
//                    {
//                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            exit(0)
//                        }
//                    }
//                }
//                self.present(vc, animated: false, completion: nil)
//            }else{
//                self.ExtiApp()
//            }
//        }
    }
    
//    func ExtiApp(){
//        let ExitAppVC = STORYBOARD.MAIN.instantiateViewController(withIdentifier: ExitAppVC.className) as! ExitAppVC
//        ExitAppVC.modalPresentationStyle = .overFullScreen
//        self.present(ExitAppVC, animated: true)
//    }
    
    @IBAction func btnSettingClicked(_ sender: Any) {
        self.view.endEditing(true)
        tabBarController?.selectedIndex = 4
        //        let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: SettingsVC.className) as! SettingsVC
        //        vc.isFromVC = true
        //        vc.modalPresentationStyle = .fullScreen
        //        self.present(vc, animated: true)
    }
}

// MARK: - AVSpeechSynthesizerDelegate -
extension TextTranslateVC: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        btnSpeeck.isSelected = false
    }
}

// MARK: - UITextViewDelegate -
extension TextTranslateVC: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        if textView == txtViewInput {
            
            // Show inapp purchas after 6 time translate
            if arrHistory.count >= 6 && !AppDelegate().sharedDelegate().isSubscribed {
                textView.text = ""
                lblPlaceholder.isHidden = false
                btnClearTxt.isHidden = true
//                let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: InAppPremiumVC.className) as! InAppPremiumVC
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true)
                return
            }
            
            if textView.text.count > 0 {
                lblPlaceholder.isHidden = true
                btnClearTxt.isHidden = false
                // btnCamera.isHidden = true
                // btnTranslate.isHidden = false
                // btnTranslate.isHidden = speechToText.audioEngine.isRunning
                if !speechToText.audioEngine.isRunning {
                    timerTranslate.invalidate()
                    timerTranslate = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { timer in
                        timer.invalidate()
                        self.timerTranslate.invalidate()
                        self.btnTranslateClicked(UIButton())
                    })
                }
            } else {
                lblPlaceholder.isHidden = false
                btnClearTxt.isHidden = true
                self.btnSpeeck.isUserInteractionEnabled = false
                self.btnSpeeck.alpha = 0.5
                self.btnMore.alpha = 0.5
                self.btnMore.isUserInteractionEnabled = false
                // btnCamera.isHidden = false
                // btnTranslate.isHidden = true
                txtViewOutput.text = ""
                constOutputHeight.constant = 0
                
               // showAdsView1(view: self.viewNativeAds)
                //self.nativeAdsHeight.constant = 320
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource -
extension TextTranslateVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewHistory.isHidden = arrHistory.count == 0
        return arrHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblHistory.dequeueReusableCell(withIdentifier: HistoryTVC.className, for: indexPath) as! HistoryTVC
        let temp = arrHistory[indexPath.row]
        cell.setDataForTextTranslateVC(model: temp)
        delay(0.003) {
            // self.tblHistoryHightConstant.constant = self.tblHistory.contentSize.height
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: WordDetailVC.className) as! WordDetailVC
        vc.modalPresentationStyle = .fullScreen
        vc.historyModel = arrHistory[indexPath.row]
        self.present(vc, animated: true)
    }
    
    // Swipe Options
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let temp = arrHistory[indexPath.row]
        let btnDelete = UIContextualAction.init(style: .normal, title: "Delete") { [self] action, view, success in
            setHistory(model: temp)
            tblHistory.beginUpdates()
            tblHistory.deleteRows(at: [indexPath], with: .left)
            arrHistory.remove(at: indexPath.row)
            tblHistory.endUpdates()
            delay(0.003) {
                //self.tblHistoryHightConstant.constant = self.tblHistory.contentSize.height
            }
            success(true)
        }
        btnDelete.backgroundColor = SystemRedColor
        
        let isBookmarked = getBookmark().contains(where: { $0.id == temp.id})
        let btnBookmarkTitle = !isBookmarked ? "Add\nFavourite".localized() : "Remove\nFavourite".localized()
        let btnBookmark = UIContextualAction.init(style: .normal, title: btnBookmarkTitle) { action, view, success in
            setBookmark(model: temp)
            isBookmarked ? displayToast("Remove from favourite successfully !".localized()) : displayToast("Add to favourite successfully !".localized())
            success(true)
        }
        btnBookmark.backgroundColor = SystemBlueColor
        
        return UISwipeActionsConfiguration(actions: [btnDelete, btnBookmark])
    }
}
