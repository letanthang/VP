//
//  SelectSecondaryLangViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 22/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class SelectSecondaryLangViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    var secondaryLangItems = [TaAndLanguageObj]()
    
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
        secondaryLangItems.removeAll()
        
        // Get ta from server
        let body: String = ""
        
        showLoading()
        
        RestApiManager.sharedInstance.callApi(GET_LANGUAGE_API, body: body, onCompletion: { (json: JSON) in
            self.getSecondLanguageCallback(json)
        })
    }
    @IBAction func didTapRegister(_ sender: AnyObject) {
        // Show loading
        showLoading()
        // Save data to server
        saveSecondaryLangToServer()
    }
    
    @IBAction func didTapSkip(_ sender: AnyObject) {
        // Init menu postion
        UserDefaults.standard.set(0, forKey: MENU_POS)
        
        // Go to article list
        let next = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.present(next, animated: true, completion: nil)
    }
    
    // MARK: - Callback Function
    func getSecondLanguageCallback(_ json: JSON) -> Void {
        if json.isEmpty {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: CONNECTION_ERROR)
            
            return
        }
        
        if IS_DEBUG {
            print ("Secondary language list \(json)")
        }
        
        let code = json["code"]
        
        if code == 1 {
            // login success
            let listLang = json["listLanguage"].arrayValue
            
            // Get primary language user seleted
            let userPrimaryLang: Int = UserDefaults.standard.integer(forKey: USER_PRIMARY_LANGUAGE_KEY)
            
            for entry in listLang {
                if userPrimaryLang != entry["id"].intValue {
                    self.secondaryLangItems.append(TaAndLanguageObj(json: entry))
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
    
    // Call api save secondary language to server
    fileprivate func saveSecondaryLangToServer() {
        let userSecondaryLagnArr: Array = UserDefaults.standard.object(forKey: USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
        
        if userSecondaryLagnArr.count > 0 {
            var langIdStr = ""
            
            for i in 0 ..< userSecondaryLagnArr.count {
                if !langIdStr.isEmpty {
                    langIdStr += ","
                }
                langIdStr += String(userSecondaryLagnArr[i])
            }
            
            
            // Get user id
            let userId = UserDefaults.standard.integer(forKey: USER_ID_KEY)
            
            let body: String = "userId=" + String(userId) + "&secondaryLangId=" + langIdStr
            
            RestApiManager.sharedInstance.callApi(SET_SECONDARY_LANG_API, body: body, onCompletion: { (json: JSON) in
                self.saveSecondaryLangCallback(json)
            })
        } else {
            // Init menu postion
            UserDefaults.standard.set(0, forKey: MENU_POS)
            UserDefaults.standard.set(0, forKey: VIEW_FAVOURITES)
            
            let next = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
            self.present(next, animated: true, completion: nil)
        }
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
            // Init menu postion
            UserDefaults.standard.set(0, forKey: MENU_POS)
            UserDefaults.standard.set(0, forKey: VIEW_FAVOURITES)
            
            // Save success and go to article list
            DispatchQueue.main.async {
                let next = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                self.present(next, animated: true, completion: nil)
            }
            
        } else if code == 99 {
            // Close loading
            hideLoading()
            
            // Show error message
            self.showErrorMessageUserNotExist("Iron World", message: json["message"].stringValue)
        } else {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: json["message"].stringValue)
        }
    }

    func calculateCellHeight() {
        if DeviceType.IS_IPHONE_6 {
            heightCell = 68
        } else if DeviceType.IS_IPHONE_6P {
            heightCell = 75
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
        let userSecondaryLagnArr: Array = UserDefaults.standard.object(forKey: USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
        
        if self.secondaryLangItems.count >= (indexPath as NSIndexPath).row {
            let secondLang = secondaryLangItems[(indexPath as NSIndexPath).row]
            
            cell.cellText.text = secondLang.name
            cell.tag = secondLang.id
            
            for i in 0 ..< userSecondaryLagnArr.count {
                if userSecondaryLagnArr[i] == cell.tag {
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
        var userSecondaryLagnArr: Array = UserDefaults.standard.object(forKey: USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
        
        if userSecondaryLagnArr.count > 0 {
            var indexUnSelect = -1
            
            for i in 0 ..< userSecondaryLagnArr.count {
                if userSecondaryLagnArr[i] == selectedCell.tag {
                    indexUnSelect = i;
                    break;
                }
            }
            
            if indexUnSelect >= 0 {
                // UnSelected this row
                selectedCell.cellBg.image = UIImage(named: "cell_bg_off")
                selectedCell.cellText.textColor = UIColor.white
                
                userSecondaryLagnArr.remove(at: indexUnSelect)
            } else {
                // Selected
                selectedCell.cellBg.image = UIImage(named: "cell_bg_on")
                selectedCell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
                
                userSecondaryLagnArr.append(selectedCell.tag)
            }
            
        } else {
            // Selected
            selectedCell.cellBg.image = UIImage(named: "cell_bg_on")
            selectedCell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
            
            userSecondaryLagnArr.append(selectedCell.tag)
        }
        
        // Save data
        UserDefaults.standard.set( userSecondaryLagnArr, forKey: USER_SECONDARY_LANGUAGE_KEY)
        
    }
}
