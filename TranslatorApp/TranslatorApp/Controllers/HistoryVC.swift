//
//  HistoryVC.swift
//  Translate All
//
//  Created by Jasmin Upadhyay on 12/04/23.
//

import UIKit

class HistoryVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblHistory: UITableView! {
        didSet {
            tblHistory.delegate = self
            tblHistory.dataSource = self
            tblHistory.register(HistoryTVC.nib, forCellReuseIdentifier: HistoryTVC.className)
        }
    }
    @IBOutlet var lblHeader:UILabel!
    @IBOutlet var viewNativeAds: UIView!
    @IBOutlet var nativeAdsHeight: NSLayoutConstraint!
    
    var arrHistory = [HistoryModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getHistoryData()
        lblHeader.text = "History".localized()
        self.nativeAdsHeight.constant = 0
        if !isUserSubscribe(){
            if Reachability.isConnectedToNetwork(){
//                if AdsManager.shared.arrNativeAds.count > 0{
//                    showAdsView3(view: self.viewNativeAds)
//                    self.nativeAdsHeight.constant = 320
//                }
            }
        }
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getHistoryData() {
        arrHistory = getHistory().reversed()
        tblHistory.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblHistory.dequeueReusableCell(withIdentifier: HistoryTVC.className, for: indexPath) as! HistoryTVC
        let temp = arrHistory[indexPath.row]
        cell.setDataForTextTranslateVC(model: temp)
       
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
        let btnDelete = UIContextualAction.init(style: .normal, title: "Delete".localized()) { [self] action, view, success in
            let alert = UIAlertController.init(title: "Alert".localized(), message: "Are you sure you want to delete this data ??".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Cancel".localized(), style: .destructive, handler: { ACTION in
                self.tblHistory.beginUpdates()
                self.tblHistory.endUpdates()
                success(true)
            }))
            alert.addAction(UIAlertAction.init(title: "Delete".localized(), style: .default, handler: { ACTION in
                setHistory(model: temp)
                self.tblHistory.beginUpdates()
                self.tblHistory.deleteRows(at: [indexPath], with: .left)
                self.arrHistory.remove(at: indexPath.row)
                self.tblHistory.endUpdates()
                success(true)
            }))
            self.present(alert, animated: true, completion: nil)
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
