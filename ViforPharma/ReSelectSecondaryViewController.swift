//
//  ReSelectSecondaryViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 30/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReSelectSecondaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    var secondaryLangItems = [TaAndLanguageObj]()
    
    let textCellIdentifier = "TextCell"
    
    var secondaryLangTemp = [Int]()
    
    var heightCell: CGFloat = 62
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Table view config
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: textCellIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        calculateCellHeight()
        
        // Copy secondary language to temp
        secondaryLangTemp = UserDefaults.standard.object(forKey: USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
        
        // Clear all item in list
        secondaryLangItems.removeAll()
        
        // Get languages store
        let decoded  = UserDefaults.standard.object(forKey: LANGUAGES_SAVE) as! Data
        let languageList = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [TaAndLanguageObj]
        
        // Get primary language user seleted
        let userPrimaryLang: Int = UserDefaults.standard.integer(forKey: USER_PRIMARY_LANGUAGE_KEY)
        
        for entry in languageList {
            if userPrimaryLang != entry.id {
                self.secondaryLangItems.append(entry)
            }
        }
        
        tableView.reloadData()
    }
    
    func calculateCellHeight() {
        if DeviceType.IS_IPHONE_6 {
            heightCell = 68
        } else if DeviceType.IS_IPHONE_6P {
            heightCell = 75
        }
    }
    
    // Call api save secondary language to server
    func saveSecondaryLangToServer() {
        
        var langIdStr = ""
            
        for i in 0 ..< secondaryLangTemp.count {
            if !langIdStr.isEmpty {
                langIdStr += ","
            }
            langIdStr += String(secondaryLangTemp[i])
        }
            
        // Get user id
        let userId = UserDefaults.standard.integer(forKey: USER_ID_KEY)
            
        let body: String = "userId=" + String(userId) + "&secondaryLangId=" + langIdStr
            
        RestApiManager.sharedInstance.callApi(SET_SECONDARY_LANG_API, body: body, onCompletion: { (json: JSON) in
            self.saveSecondaryLangCallback(json)
        })
    }
    
    func saveSecondaryLangCallback(_ json: JSON) -> Void {
        if json.isEmpty {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: CONNECTION_ERROR)
            
            return
        }
        
        if IS_DEBUG {
            print ("Save secondary language id \(json)")
        }
        
        let code = json["code"]
        
        if code == 1 {
            // Store new list secondary language to phone
            UserDefaults.standard.set( secondaryLangTemp, forKey: USER_SECONDARY_LANGUAGE_KEY)
            
            // hide loading
            self.hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: SAVE_SUCCESS)
        } else if code == 99 {
            // Close loading
            hideLoading()
            
            // Show error message
            self.showErrorMessageUserNotExist("Iron World", message: json["message"].stringValue)
        } else {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: String(describing: json["message"]))
        }
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        showLoading()
        
        saveSecondaryLangToServer()
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        if let parentVC = self.parent {
            if let parentVC = parentVC as? ReSelectPageViewController {
                // parentVC is ReSelectPageViewController
                
                // Go to next page
                parentVC.scrollToViewController(index: 0)
            }
        }
    }
    
    // MARK: - TableView Function
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return secondaryLangItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: textCellIdentifier) as! CustomTableViewCell

        if self.secondaryLangItems.count >= (indexPath as NSIndexPath).row {
            let secondLang = secondaryLangItems[(indexPath as NSIndexPath).row]
            
            cell.cellText.text = secondLang.name
            cell.tag = secondLang.id
            
            for i in 0 ..< secondaryLangTemp.count {
                if secondaryLangTemp[i] == cell.tag {
                    cell.cellBg.image = UIImage(named: "cell_bg_on")
                    cell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
                    break
                } else {
                    cell.cellBg.image = UIImage(named: "cell_bg_off")
                    cell.cellText.textColor = UIColor.white
                }
            }
        }
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row \((indexPath as NSIndexPath).row) selected")
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell

        if secondaryLangTemp.count > 0 {
            var indexUnSelect = -1
            
            for i in 0 ..< secondaryLangTemp.count {
                if secondaryLangTemp[i] == selectedCell.tag {
                    indexUnSelect = i;
                    break;
                }
            }
            
            if indexUnSelect >= 0 {
                // UnSelected this row
                selectedCell.cellBg.image = UIImage(named: "cell_bg_off")
                selectedCell.cellText.textColor = UIColor.white
                
                secondaryLangTemp.remove(at: indexUnSelect)
            } else {
                // Selected
                selectedCell.cellBg.image = UIImage(named: "cell_bg_on")
                selectedCell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
                
                secondaryLangTemp.append(selectedCell.tag)
            }
            
        } else {
            // Selected
            selectedCell.cellBg.image = UIImage(named: "cell_bg_on")
            selectedCell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
            
            secondaryLangTemp.append(selectedCell.tag)
        }
    }
}
