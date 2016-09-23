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
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: textCellIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
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
    @IBAction func didTapNext(sender: AnyObject) {
        if let parentVC = self.parentViewController {
            if let parentVC = parentVC as? SelectPageViewController {
                // parentVC is SelectPageViewController
                
                // this is secondary language --> So need to check validate primary language
                let userPrimaryLang: Int = NSUserDefaults.standardUserDefaults().integerForKey(USER_PRIMARY_LANGUAGE_KEY)
                
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
    func getPrimaryLanguageCallback(json: JSON) -> Void {
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
            let userSecondaryLagnArr: Array = NSUserDefaults.standardUserDefaults().objectForKey(USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
            
            // login success
            let listTa = json["listLanguage"].arrayValue
            
            for entry in listTa {
                if !userSecondaryLagnArr.contains(entry["id"].intValue) {
                    self.primaryLangItems.append(TaAndLanguageObj(json: entry))
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView?.reloadData()
            }
            
            // hide loading
            hideLoading()
            
        } else {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: String(json["message"]))
        }
    }
    
    // Call api save primary language to server
    private func savePrimaryLangToServer() {
        let userPrimaryLang: Int = NSUserDefaults.standardUserDefaults().integerForKey(USER_PRIMARY_LANGUAGE_KEY)
        
        if userPrimaryLang != 0 {
            
            // Get user id
            let userId = NSUserDefaults.standardUserDefaults().integerForKey(USER_ID_KEY)
            
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return primaryLangItems.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return heightCell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(textCellIdentifier) as! CustomTableViewCell
        
        let userPrimaryLang: Int = NSUserDefaults.standardUserDefaults().integerForKey(USER_PRIMARY_LANGUAGE_KEY)
        
        if self.primaryLangItems.count >= indexPath.row {
            let lang = primaryLangItems[indexPath.row]
            
            cell.cellText.text = lang.name
            cell.tag = lang.id
            
            if userPrimaryLang == lang.id {
                cell.cellBg.image = UIImage(named: "cell_bg_on")
                cell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)

            } else {
                cell.cellBg.image = UIImage(named: "cell_bg_off")
                cell.cellText.textColor = UIColor.whiteColor()
            }
        }
        
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if IS_DEBUG {
            print("Row \(indexPath.row) selected")
        }
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! CustomTableViewCell

        let userPrimaryLang: Int = NSUserDefaults.standardUserDefaults().integerForKey(USER_PRIMARY_LANGUAGE_KEY)
        
        if userPrimaryLang == selectedCell.tag {
            // UnSelected this row
            selectedCell.cellBg.image = UIImage(named: "cell_bg_off")
            selectedCell.cellText.textColor = UIColor.whiteColor()
            
            // Set primary language to 0
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: USER_PRIMARY_LANGUAGE_KEY)
        } else {
            // Unselected row before
            for cell in tableView.visibleCells as! [CustomTableViewCell] {
                cell.cellBg.image = UIImage(named: "cell_bg_off")
                cell.cellText.textColor = UIColor.whiteColor()
            }
            
            
            // Selected
            selectedCell.cellBg.image = UIImage(named: "cell_bg_on")
            selectedCell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
            
            NSUserDefaults.standardUserDefaults().setInteger(selectedCell.tag, forKey: USER_PRIMARY_LANGUAGE_KEY)
        }
    }
}
