//
//  SelectPrimaryLangViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 22/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class SelectPrimaryLangViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var primaryLangItems = [TaAndLanguageObj]()
    let textCellIdentifier = "TextCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var heightCell: CGFloat = 62
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table view config
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: textCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        calculateCellHeight()
        
        // Clear all item in list
        primaryLangItems.removeAll()
        
        // Get ta from server
        let body: String = ""
        
        showLoading()
        
        RestApiManager.sharedInstance.callApi(GET_LANGUAGE_API, body: body, onCompletion: { (json: JSON) in
            self.getPrimaryLanguageCallback(json)
        })
    }
    @IBAction func didTapNext(_ sender: AnyObject) {
        if let parentVC = self.parent {
            if let parentVC = parentVC as? SelectPageViewController {
                // parentVC is SelectPageViewController
                
                // this is secondary language --> So need to check validate primary language
                let userPrimaryLang: Int = UserDefaults.standard.integer(forKey: USER_PRIMARY_LANGUAGE_KEY)
                
                if userPrimaryLang == 0 {
                    self.showErrorMessage("Iron World", message: CHECK_INPUT_SELECT_LANGUAGE);
                } else {
                    // Save primary language
                    savePrimaryLangToServer()
                    
                    // Goto next page
                    parentVC.scrollToNextViewController()
                }
            }
        }
    }
    
    func calculateCellHeight() {
        if DeviceType.IS_IPHONE_6 {
            heightCell = 68
        } else if DeviceType.IS_IPHONE_6P {
            heightCell = 75
        }
    }
    
    // MARK: - Callback Function
    func getPrimaryLanguageCallback(_ json: JSON) -> Void {
        if json.isEmpty {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: CONNECTION_ERROR)
            
            return
        }
        
        if IS_DEBUG {
            print ("Primary language list \(json)")
        }
        
        let code = json["code"]
        
        if code == 1 {
            // Get user secondary language user is selected
            let userSecondaryLagnArr: Array = UserDefaults.standard.object(forKey: USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
            
            // login success
            let listTa = json["listLanguage"].arrayValue
            
            for entry in listTa {
                if !userSecondaryLagnArr.contains(entry["id"].intValue) {
                    self.primaryLangItems.append(TaAndLanguageObj(json: entry))
                }
            }
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
            
            // hide loading
            hideLoading()
            
        } else {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: String(describing: json["message"]))
        }
    }
    
    // Call api save primary language to server
    fileprivate func savePrimaryLangToServer() {
        let userPrimaryLang: Int = UserDefaults.standard.integer(forKey: USER_PRIMARY_LANGUAGE_KEY)
        
        if userPrimaryLang != 0 {
            
            // Get user id
            let userId = UserDefaults.standard.integer(forKey: USER_ID_KEY)
            
            let body: String = "userId=" + String(userId) + "&langId=" + String(userPrimaryLang)
            
            RestApiManager.sharedInstance.callApi(SET_PRIMARY_LANG_API, body: body, onCompletion: { (json: JSON) in
                if IS_DEBUG {
                    print("Save Primary Lang \(json)")
                }
                
                let code = json["code"].intValue
                
                if code == 99 {
                    // Show error message
                    self.showErrorMessageUserNotExist("Iron World", message: json["message"].stringValue)
                } else if code != 1 {
                    // login fail --> show error message
                    self.showErrorMessage("Iron World", message: json["message"].stringValue)
                }
            })
        }
    }
    
    
    // MARK: - TableView Function
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return primaryLangItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: textCellIdentifier) as! CustomTableViewCell
        
        let userPrimaryLang: Int = UserDefaults.standard.integer(forKey: USER_PRIMARY_LANGUAGE_KEY)
        
        if self.primaryLangItems.count >= (indexPath as NSIndexPath).row {
            let lang = primaryLangItems[(indexPath as NSIndexPath).row]
            
            cell.cellText.text = lang.name
            cell.tag = lang.id
            
            if userPrimaryLang == lang.id {
                cell.cellBg.image = UIImage(named: "cell_bg_on")
                cell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)

            } else {
                cell.cellBg.image = UIImage(named: "cell_bg_off")
                cell.cellText.textColor = UIColor.white
            }
        }
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if IS_DEBUG {
            print("Row \((indexPath as NSIndexPath).row) selected")
        }
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell

        let userPrimaryLang: Int = UserDefaults.standard.integer(forKey: USER_PRIMARY_LANGUAGE_KEY)
        
        if userPrimaryLang == selectedCell.tag {
            // UnSelected this row
            selectedCell.cellBg.image = UIImage(named: "cell_bg_off")
            selectedCell.cellText.textColor = UIColor.white
            
            // Set primary language to 0
            UserDefaults.standard.set(0, forKey: USER_PRIMARY_LANGUAGE_KEY)
        } else {
            // Unselected row before
            for cell in tableView.visibleCells as! [CustomTableViewCell] {
                cell.cellBg.image = UIImage(named: "cell_bg_off")
                cell.cellText.textColor = UIColor.white
            }
            
            
            // Selected
            selectedCell.cellBg.image = UIImage(named: "cell_bg_on")
            selectedCell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
            
            UserDefaults.standard.set(selectedCell.tag, forKey: USER_PRIMARY_LANGUAGE_KEY)
        }
    }
}
