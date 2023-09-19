//
//  LanguageTVC.swift
//  Call Blocker App
//
//  Created by admin on 17/11/22.
//

import UIKit

class LanguageTVC: UITableViewCell {

    // MARK: - OUTLET
    @IBOutlet var imgFlag: UIImageView!
    @IBOutlet var lbl: UILabel!
    @IBOutlet var btnSelect: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
