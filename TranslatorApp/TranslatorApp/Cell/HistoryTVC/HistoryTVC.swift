//
//  HistoryTVC.swift
//  Translate All
//
//  Created by admin on 11/07/22.
//

import UIKit

class HistoryTVC: UITableViewCell {
    
    // OUTLET
    @IBOutlet weak var lblLangInfo: UILabel!
    @IBOutlet weak var lblLanguage1: UILabel!
    @IBOutlet weak var lblLanguage2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Methods
    func setDataForTextTranslateVC(model: HistoryModel) {
        lblLangInfo.text = "\(model.langModel1.name) - \(model.langModel2.name)"
        lblLanguage1.text = model.strSource
        lblLanguage2.text = model.strDestination
    }
    
    func setDataForBookmarkVC(model: HistoryModel) {
        lblLangInfo.text = "\(model.langModel1.name) - \(model.langModel2.name)"
        lblLanguage1.text = model.strSource
        lblLanguage2.text = model.strDestination
    }
    
}
