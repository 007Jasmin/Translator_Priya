//
//  SelectLanguageTVC.swift
//  Translate All
//
//  Created by admin on 11/07/22.
//

import UIKit
import MLKit

class SelectLanguageTVC: UITableViewCell {

    // OUTLET
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var imgSelect: UIImageView!
    @IBOutlet weak var imgDownload: UIImageView!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var viewDownload: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // MARK: - Methods
    func setDataForSelectLanguageVC(model: LanguageModel, isSelected: Bool) {
        lbl.text = model.name
        imgSelect.isHidden = !isSelected
        viewDownload.isHidden = true
        if downloadLanguageAvailable(langCode: model.code){
            imgDownload.image = UIImage(named: "ic_downloads")
            viewDownload.isHidden = false
            if setDownloadDeleteButtonLabels(language: model.code){
                imgDownload.image = UIImage(named: "ic_checkDone")
                btnDownload.isHidden = true
            }
        }
    }
    
    func setDownloadDeleteButtonLabels(language:String) -> Bool {
        let inputLanguage = TranslateLanguage(rawValue: language)
        if self.isLanguageDownloaded(inputLanguage) {
            print("Delete Model \(inputLanguage)")
            return true
        } else {
            print("Download Model \(inputLanguage)")
            return false
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
    
    func downloadLanguageAvailable(langCode:String) -> Bool {
        for i in 0..<allLanguages.count{
            print("Language",allLanguages[i].rawValue,langCode)
            if allLanguages[i].rawValue == langCode{return true}
        }
        return false
    }
}
