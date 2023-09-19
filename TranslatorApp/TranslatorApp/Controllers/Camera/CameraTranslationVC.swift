//
//  CameraTranslationVC.swift
//  Translate All
//
//  Created by Jasmin Upadhyay on 12/04/23.
//

import UIKit
import MobileCoreServices
import Vision
import VisionKit
import NaturalLanguage
import MLKit

class CameraTranslationVC: UIViewController {
    
    @IBOutlet var txtText:UITextView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var btnLang1: UIButton!
    @IBOutlet weak var btnLang2: UIButton!
    @IBOutlet var lblHeader:UILabel!
    @IBOutlet var cameraView:UIView!
    @IBOutlet var galleryView:UIView!
    @IBOutlet var lblGallery:UILabel!
    @IBOutlet var lblStr1:UILabel!
    @IBOutlet var lblCamera:UILabel!
    @IBOutlet var lblStr2:UILabel!
    @IBOutlet var btnOkay1: UIButton!
    @IBOutlet var btnOkay2: UIButton!
    @IBOutlet var image1: UIImageView!
    
    var langModel1 = getLanuage1()
    var langModel2 = getLanuage2()
    var arrSearchLanguage = [LanguageModel]()
    var strVal:String = ""
    var translator: Translator!
    var img1:UIImage = UIImage()
    let locale = Locale.current
    lazy var allLanguages = TranslateLanguage.allLanguages().sorted {
        return locale.localizedString(forLanguageCode: $0.rawValue)!
        < locale.localizedString(forLanguageCode: $1.rawValue)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityLoader.isHidden = true
        setData()
    }
}

//MARK: - IBAction & Functuion Calling
extension CameraTranslationVC{
    func setData() {
        if UserDefaults.standard.bool(forKey: "FirstTime"){
            self.galleryView.isHidden = false
            self.cameraView.isHidden = true
        }
        else{
            self.galleryView.isHidden = true
            self.cameraView.isHidden = true
        }
        lblGallery.text = "Choose from Gallery".localized()
        lblStr1.text = "Select image from gallery and translate tex".localized()
        lblCamera.text = "Choose from Camera".localized()
        lblStr2.text = "Click image from camera and translate text".localized()
        btnOkay1.setTitle("Okay".localized(), for: .normal)
        btnOkay2.setTitle("Okay".localized(), for: .normal)
        lblHeader.text = "Camera Translation".localized()
        langModel1 = getLanuage1()
        langModel2 = getLanuage2()
        self.btnLang1.setTitle(self.langModel1.name, for: .normal)
        self.btnLang2.setTitle(self.langModel2.name, for: .normal)
        arrSearchLanguage = ARR_LANGUAGE
        self.textFromImage(imgVal: img1.fixOrientation()!)
    }
    
    func textFromImage(imgVal:UIImage){
        guard let cgImage = imgVal.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.recognitionLevel = .accurate
        request.recognitionLanguages = langCode
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else { return }
        let recognizedStrings = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
        print(recognizedStrings)
        self.strVal = recognizedStrings.joined(separator: "\n")
        if self.strVal.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            activityLoader.isHidden = true
            AlertWithMSG(mesg: "Unable to fetch text Please check the image.".localized())
            return
        }
        let strLang:String = detectedLanguage(for: strVal) ?? ""
        //self.btnLang1.setTitle(strLang, for: .normal)
        DispatchQueue.main.async {
            self.findLangCode(langName: strLang, strVal: self.strVal)
        }
    }
    
    func detectedLanguage(for string: String) -> String? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(string)
        guard let languageCode = recognizer.dominantLanguage?.rawValue else { return nil }
        let detectedLanguage = Locale.current.localizedString(forIdentifier: languageCode)
        return detectedLanguage
    }
    
    func findLangCode(langName:String,strVal:String)
    {
        print("Detect lang",langName)
        for i in 0..<arrSearchLanguage.count{
            let dic = arrSearchLanguage[i]
            print("Lang Name",dic.name)
            if langName.contains(dic.name){
                print("Lang Match",langName,dic.name)
                //langModel1 = dic
               // self.btnLang1.setTitle(self.langModel1.name, for: .normal)
                translateText(langModel1.code, langModel2.code, text: strVal, isSaveFromHistory: false)
                break
            }
        }
    }
    
    func translateText(_ sourceLangIOSCode: String, _ translateIOSLang: String, text: String, isSaveFromHistory: Bool) {
        let url = String.init(format: API.TRANSLATE, sourceLangIOSCode, translateIOSLang, text)
        if let validUrl = convertStringToValidUrl(strUrl: url) {
            activityLoader.startAnimating()
            TextTranslateViewModel().translateText(false, validUrl) { translateResponceModel, error in
                if let data = translateResponceModel {
                    if data.sentences.count > 0 {
                        self.activityLoader.stopAnimating()
                        self.activityLoader.isHidden = true
                        self.txtText.text = data.sentences.map({ $0.trans }).joined(separator: "")
                    }
                } else {
                    displayToast(error?.localizedDescription ?? "")
                }
            }
        } else {
            displayToast("Enter text is invalid !".localized())
        }
    }
    
    func translate() {
        var inputLanguage:TranslateLanguage!
        var outputLanguage:TranslateLanguage!
        for i in 0..<allLanguages.count{
            if allLanguages[i].rawValue == langModel1.code{inputLanguage = allLanguages[i]}
        }
        for i in 0..<allLanguages.count{
            if allLanguages[i].rawValue == langModel2.code{outputLanguage = allLanguages[i]}
        }
        let options = TranslatorOptions(sourceLanguage: inputLanguage, targetLanguage: outputLanguage)
        translator = Translator.translator(options: options)
        //self.setDownloadDeleteButtonLabels()
        let translatorForDownloading = self.translator!
        translatorForDownloading.downloadModelIfNeeded { error in
            guard error == nil else {
                AlertWithMSG(mesg: "Not availabel for offline translation".localized())
                print("Failed to ensure model downloaded with error \(error!)")
                return
            }
            if translatorForDownloading == self.translator {
                translatorForDownloading.translate(self.strVal) { result, error in
                    guard error == nil else {
                       // self.txtViewOutput.text = "Failed with error \(error!)"
                        AlertWithMSG(mesg: "Not availabel for offline translation".localized())
                        return
                    }
                    if translatorForDownloading == self.translator {
                        self.txtText.text = result
                    }
                }
            }
        }
    }
    
    @IBAction func btnSelectLanguageClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = STORYBOARD.MAIN.instantiateViewController(withIdentifier: SelectLanguageVC.className) as! SelectLanguageVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.selectLanguage = sender.tag
        vc.languageModel1 = langModel1
        vc.languageModel2 = langModel2
        vc.callBack = { langModel1, langModel2 in
            self.langModel2 = langModel2
            self.btnLang2.setTitle(self.langModel2.name, for: .normal)
            self.translateText(self.langModel1.code, self.langModel2.code, text: self.strVal, isSaveFromHistory: false)
        }
        self.present(vc, animated: true)
    }
    
    @IBAction func btnPhotoSelect(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        self.present(imagePicker, animated: true, completion: {
            self.activityLoader.stopAnimating()
        })
    }
    
    @IBAction func btnOpenCamera(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = [kUTTypeImage as String]
        self.present(imagePicker, animated: true, completion: {
            self.activityLoader.stopAnimating()
        })
    }
    
    @IBAction func btnSettingClicked(_ sender: Any) {
        self.view.endEditing(true)
        tabBarController?.selectedIndex = 4
    }
    
    @IBAction func btnGuideClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender.tag == 10{
            self.galleryView.isHidden = true
            self.cameraView.isHidden = false
        }
        else{
            self.cameraView.isHidden = true
            UserDefaults.standard.set(false, forKey: "FirstTime")
        }
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

//MARK: - UINavigationControllerDelegate

extension CameraTranslationVC: UINavigationControllerDelegate { }

//MARK: - UIImagePickerControllerDelegate

extension CameraTranslationVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedPhoto =
                info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        self.activityLoader.isHidden = false
        activityLoader.startAnimating()
        dismiss(animated: true) {
            self.textFromImage(imgVal: selectedPhoto)
        }
    }
}
