//
//  WorkDetailVC.swift
//  Translate All
//
//  Created by admin on 12/07/22.
//

import UIKit
import Speech

class WordDetailVC: UIViewController {
    
    // OUTLET
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLanguage1: UILabel!
    @IBOutlet weak var lblLanguage2: UILabel!
    @IBOutlet weak var lblSource: UILabel!
    @IBOutlet weak var lblDestination: UILabel!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet var nativeAdsHeight: NSLayoutConstraint!
    @IBOutlet var viewNativeAds: UIView!
    
    // VARIABLE
    var historyModel = HistoryModel()
    
    // Speech
    var utterance = AVSpeechUtterance()
    let synth = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()

        setData()
        self.nativeAdsHeight.constant = 0
        if !isUserSubscribe(){
            if Reachability.isConnectedToNetwork(){
                if AdsManager.shared.arrNativeAds.count > 0{
                   // showAdsView3(view: self.viewNativeAds)
                    self.nativeAdsHeight.constant = 260
                }
            }
        }
        
        // When we use SpeechToText and TextToSpeech Functionality at that time one functionality stop so use this configuration
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            debugPrint("audioSession properties weren't set because of an error.")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if synth.isSpeaking {
            synth.stopSpeaking(at: .immediate)
        }
    }
    
    // MARK: - Methods
    func setData() {
        self.nativeAdsHeight.constant = 0
        lblTitle.text = "\(historyModel.langModel1.name) - \(historyModel.langModel2.name)"
        lblLanguage1.text = historyModel.langModel1.name
        lblLanguage2.text = historyModel.langModel2.name
        lblSource.text = historyModel.strSource
        lblDestination.text = historyModel.strDestination
        btnBookmark.isSelected = getBookmark().contains(where: { $0.id == historyModel.id })
        btnPlay.isHidden = !historyModel.langModel2.isValidToSpeak
    }
    
    // MARK: - Button Clicked
    @IBAction func btnBackClicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
    @IBAction func btnPlayClicked(_ sender: Any) {
        self.view.endEditing(true)
        
        DispatchQueue.main.async { [self] in
            utterance = AVSpeechUtterance(string: self.historyModel.strDestination)
            utterance.voice = AVSpeechSynthesisVoice(language: self.historyModel.langModel2.code)
            utterance.volume = 1.0
            self.synth.delegate = self
            if self.synth.isSpeaking {
                self.synth.stopSpeaking(at: .immediate)
                self.btnPlay.isSelected = false
            } else {
                self.synth.speak(utterance)
                self.btnPlay.isSelected = true
            }
        }
    }
    
    @IBAction func btndeleteClicked(_ sender: Any) {
        self.view.endEditing(true)
        let alert = UIAlertController.init(title: "Alert".localized(), message: "Are you sure you want to delete this data ?".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Cancel".localized(), style: .destructive, handler: nil))
        alert.addAction(UIAlertAction.init(title: "Delete".localized(), style: .default, handler: { ACTION in
            let indexForHistory = getHistory().contains(where: { $0.id == self.historyModel.id })
            if indexForHistory {
                setHistory(model: self.historyModel)
            }
            
            let indexForBookmark = getBookmark().contains(where: { $0.id == self.historyModel.id })
            if indexForBookmark {
                setBookmark(model: self.historyModel)
            }
            
            displayToast("Delete data successfully !".localized())
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func btnBookmarkClicked(_ sender: Any) {
        self.view.endEditing(true)
        let isBookmark = getBookmark().contains(where: { $0.id == historyModel.id })
        if isBookmark {
            btnBookmark.isSelected = false
            setBookmark(model: historyModel)
            displayToast("Remove from favourites !".localized())
        } else {
            btnBookmark.isSelected = true
            setBookmark(model: historyModel)
            displayToast("Add into favourites !".localized())
        }
    }
    
    @IBAction func btnShareClicked(_ sender: Any) {
        self.view.endEditing(true)
        let shareStr = "\(historyModel.strSource)\n\(historyModel.strDestination)"
        shareText(self, shareStr)
    }
    
    @IBAction func btnCopyClicked(_ sender: Any) {
        self.view.endEditing(true)
        copyText(str: historyModel.strDestination)
    }
}

// MARK: - AVSpeechSynthesizerDelegate -
extension WordDetailVC: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        btnPlay.isSelected = false
    }
}
