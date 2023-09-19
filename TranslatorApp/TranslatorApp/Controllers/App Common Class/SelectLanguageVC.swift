//
//  SelectLanguageVC.swift
//  Translate All
//
//  Created by admin on 11/07/22.
//

import UIKit
import MLKit
import SVProgressHUD

class SelectLanguageVC: UIViewController {
    
    // OUTLET
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var segmentLanguage: UISegmentedControl!
    @IBOutlet weak var tblView: UITableView! {
        didSet {
            tblView.delegate = self
            tblView.dataSource = self
            tblView.register(SelectLanguageTVC.nib, forCellReuseIdentifier: SelectLanguageTVC.className)
        }
    }
    @IBOutlet var constBtnBackWidth: NSLayoutConstraint!
    @IBOutlet var lblHeader:UILabel!
    @IBOutlet var btnDone:UIButton!
    
    // VARIABLE
    var arrSearchLanguage = [LanguageModel]()
    var languageModel1 = LanguageModel() // Passed
    var languageModel2 = LanguageModel() // Passed
    var selectLanguage = 1 // Passed
    var showOnlySupportedToSpeck = false
    var callBack: ((_ langModel1: LanguageModel, _ langModel2: LanguageModel) -> Void)?
    var isFromSplash:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setSegment()
        // setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setSegment()
        setData()
    }
    
    // MARK: - Methods
    func setSegment() {
        segmentLanguage.selectedSegmentIndex = selectLanguage - 1
        segmentLanguage.setTitle(languageModel1.name, forSegmentAt: 0)
        segmentLanguage.setTitle(languageModel2.name, forSegmentAt: 1)
    }
    
    func setData() {
        self.lblHeader.text = "Select Language".localized()
        self.btnDone.setTitle("Done".localized(), for: .normal)
        self.constBtnBackWidth.constant = 0
        if isFromSplash == false{
            self.constBtnBackWidth.constant = 60
        }
        arrSearchLanguage = ARR_LANGUAGE
        if showOnlySupportedToSpeck {
            arrSearchLanguage = arrSearchLanguage.filter({ $0.isValidToSpeak == true })
        }
        tblView.reloadData()
    }
    
    // MARK: - Segment Click
    
    @IBAction func segmentLanguageClicked(_ sender: UISegmentedControl) {
        txtSearch.text = ""
        arrSearchLanguage = ARR_LANGUAGE
        tblView.reloadData()
    }
    
    // MARK: - Textfield Click
    @IBAction func txtSearchEditingChangeClicked(_ sender: UITextField) {
        let searchText = sender.text?.trimmed ?? ""
        if searchText.trimmed.count > 0 {
            self.arrSearchLanguage = searchText.isEmpty ? ARR_LANGUAGE : ARR_LANGUAGE.filter({ (temp) -> Bool in
                return temp.name.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
            })
            self.tblView.reloadData()
        } else if searchText.trimmed.count == 0 {
            self.arrSearchLanguage = ARR_LANGUAGE
            self.tblView.reloadData()
        }
    }

    // MARK: - Button Click
    @IBAction func btnCloseClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        if isFromSplash == true{
            let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: "tabController") as! UITabBarController
            let nvc = UINavigationController.init(rootViewController: vc)
            nvc.navigationBar.isHidden = true
            AppDelegate().sharedDelegate().window?.rootViewController = nvc
            AppDelegate().sharedDelegate().window?.makeKeyAndVisible()
        }else {
            self.dismiss(animated: true) {
                if let callBack = self.callBack {
                    callBack(self.languageModel1, self.languageModel2)
                }
            }
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource -
extension SelectLanguageVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearchLanguage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: SelectLanguageTVC.className, for: indexPath) as! SelectLanguageTVC
        let temp = arrSearchLanguage[indexPath.row]
        
        if segmentLanguage.selectedSegmentIndex == 0 {
            cell.setDataForSelectLanguageVC(model: arrSearchLanguage[indexPath.row], isSelected: languageModel1.code == temp.code)
        } else {
            cell.setDataForSelectLanguageVC(model: arrSearchLanguage[indexPath.row], isSelected: languageModel2.code == temp.code)
        }
        cell.btnDownload.tag = indexPath.row
        cell.btnDownload.addTarget(self, action: #selector(DownloadLanguage(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentLanguage.selectedSegmentIndex == 0 {
            languageModel1 = arrSearchLanguage[indexPath.row]
        } else if segmentLanguage.selectedSegmentIndex == 1 {
            languageModel2 = arrSearchLanguage[indexPath.row]
        } else {
            debugPrint("Invalid Selection")
        }
        
        segmentLanguage.setTitle(languageModel1.name, forSegmentAt: 0)
        segmentLanguage.setTitle(languageModel2.name, forSegmentAt: 1)
        tblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    @objc func DownloadLanguage(_ sender: UIButton){
        let dic = arrSearchLanguage[sender.tag]
//        if !isUserSubscribe() {
//            let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: InAppPremiumVC.className) as! InAppPremiumVC
//            vc.modalPresentationStyle = .fullScreen
//            self.present(vc, animated: true)
//        }else{
            let alertVC: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            alertVC.addAction(UIAlertAction(title:"\("Download".localized()) \(dic.name)", style:UIAlertAction.Style.default, handler:{ action in
                self.handleDownloadLanguage2(langCode: dic.code, langName: dic.name)
              }))
            alertVC.addAction(UIAlertAction(title:"Cancel".localized(), style:UIAlertAction.Style.cancel, handler:nil))
            self.present(alertVC, animated: true)
        //}
    }
   
    func handleDownloadLanguage2(langCode:String,langName:String) {
        
        var language:TranslateLanguage!
        for i in 0..<allLanguages.count{
//            print("allLanguages",allLanguages[i].rawValue)
            if allLanguages[i].rawValue == langCode{language = allLanguages[i]}
        }
        if language == .english { return }
        let model = self.model(forLanguage: language)
        let modelManager = ModelManager.modelManager()
        let languageName = Locale.current.localizedString(forLanguageCode: language.rawValue)
        if modelManager.isModelDownloaded(model) {
//            self.switchOffline.isOn = true
        } else {
//            print("Downloading \(languageName)")
            SVProgressHUD.show(withStatus: "Downloading \(langName)")
            let conditions = ModelDownloadConditions(
                allowsCellularAccess: true,
                allowsBackgroundDownloading: true
            )
                    
            modelManager.download(model, conditions: conditions)
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if modelManager.isModelDownloaded(model) {
                    self.tblView.reloadData()
                    SVProgressHUD.dismiss()
                    timer.invalidate()
                }
            }
            
        }
        
//        var language:TranslateLanguage!
//        for i in 0..<allLanguages.count{
//            print("allLanguages",allLanguages[i].rawValue)
//            if allLanguages[i].rawValue == langCode{language = allLanguages[i]}
//        }
//        if language == .english { return }
//        let model = self.model(forLanguage: language)
//        let modelManager = ModelManager.modelManager()
//        let languageName = Locale.current.localizedString(forLanguageCode: language.rawValue)
//        if modelManager.isModelDownloaded(model) {
//            print("Deleting \(languageName)")
//            modelManager.deleteDownloadedModel(model) { error in
//                print("Deleted \(languageName)")
//            }
//        } else {
//            print("Downloading \(languageName)")
//            SVProgressHUD.show(withStatus: "Downloading \(langName)")
//            let conditions = ModelDownloadConditions(
//                allowsCellularAccess: true,
//                allowsBackgroundDownloading: true
//            )
//            modelManager.download(model, conditions: conditions)
//        }
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
                SVProgressHUD.dismiss()
                print("Download succeeded for \(languageName)")
            } else {
                AlertWithMSG(mesg: "Please connet to internet".localized())
                print("Download failed for \(languageName)")
            }
            self.tblView.reloadData()
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
}
