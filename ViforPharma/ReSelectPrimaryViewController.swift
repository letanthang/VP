//
//  ReSelectPrimaryViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 30/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReSelectPrimaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var primaryLangItems = [TaAndLanguageObj]()
    let textCellIdentifier = "TextCell"
    
    var primaryLangTemp: Int = 0
    
    var heightCell: CGFloat = 62
    
    var isFirstTime = true
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Table view config
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: textCellIdentifier)
        
        // Calculate Cell Height
        calculateCellHeight()
        
        // Copy list primary language id to array temp
        primaryLangTemp = NSUserDefaults.standardUserDefaults().integerForKey(USER_PRIMARY_LANGUAGE_KEY)
        
        // Get ta from server
        let body: String = ""
        
        showLoading()
        
        RestApiManager.sharedInstance.callApi(GET_LANGUAGE_API, body: body, onCompletion: { (json: JSON) in
            self.getPrimaryLanguageCallback(json)
        })
    }

    override func viewWillAppear(animated: Bool) {
        if isFirstTime {
            isFirstTime = false
        } else {
            // Copy list primary language id to array temp
            primaryLangTemp = NSUserDefaults.standardUserDefaults().integerForKey(USER_PRIMARY_LANGUAGE_KEY)
            
            // Clear all item in list
            primaryLangItems.removeAll()
            
            // Get list language for primary except language chose in secondary language screen
            // Get languages store
            let decoded  = NSUserDefaults.standardUserDefaults().objectForKey(LANGUAGES_SAVE) as! NSData
            let languageList = NSKeyedUnarchiver.unarchiveObjectWithData(decoded) as! [TaAndLanguageObj]
            
            // Get user secondary language user is selected
            let userSecondaryLagnArr: Array = NSUserDefaults.standardUserDefaults().objectForKey(USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
            
            for entry in languageList {
                
                // get language show to choose primary language - except language chose at secondary language
                if !userSecondaryLagnArr.contains(entry.id) {
                    self.primaryLangItems.append(entry)
                }
            }
            
            tableView.reloadData()
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
            var languageItemsSave = [TaAndLanguageObj]()
            
            for entry in listTa {
                // Get all language to store
                languageItemsSave.append(TaAndLanguageObj(json: entry))
                
                
                // get language show to choose primary language - except language chose at secondary language
                if !userSecondaryLagnArr.contains(entry["id"].intValue) {
                    self.primaryLangItems.append(TaAndLanguageObj(json: entry))
                }
            }
            
            // Encode object to to NSData to store
            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(languageItemsSave)
            // Store language item
            NSUserDefaults.standardUserDefaults().setObject(encodedData, forKey: LANGUAGES_SAVE)
            
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
    func savePrimaryLangToServer() {
        if primaryLangTemp != 0 {
            // Get user id
            let userId = NSUserDefaults.standardUserDefaults().integerForKey(USER_ID_KEY)
            
            let body: String = "userId=" + String(userId) + "&langId=" + String(primaryLangTemp)
            
            RestApiManager.sharedInstance.callApi(SET_PRIMARY_LANG_API, body: body, onCompletion: { (json: JSON) in
                let code = json["code"]
                
                if code == 1 {
                    // Store new value on phone
                    NSUserDefaults.standardUserDefaults().setInteger(self.primaryLangTemp, forKey: USER_PRIMARY_LANGUAGE_KEY)
                    
                    // hide loading
                    self.hideLoading()
                    
                    // show success message
                    self.showErrorMessage("Iron World", message: SAVE_SUCCESS)
                    
                } else if code == 99 {
                    // Close loading
                    self.hideLoading()
                    
                    // Show error message
                    self.showErrorMessageUserNotExist("Iron World", message: json["message"].stringValue)
                } else {
                    // Close loading
                    self.hideLoading()
                    
                    // login fail --> show error message
                    self.showErrorMessage("Iron World", message: String(json["message"]))
                }
            })
        } else {
            // Close loading
            self.hideLoading()
            
            self.showErrorMessage("Iron World", message: CHECK_INPUT_SELECT_LANGUAGE);
        }
    }
    
    @IBAction func didTapSave(sender: UIButton) {
        showLoading()
        // Save data to server
        savePrimaryLangToServer()
    }
    
    @IBAction func didTapNext(sender: UIButton) {
        if let parentVC = self.parentViewController {
            if let parentVC = parentVC as? ReSelectPageViewController {
                // parentVC is ReSelectPageViewController
                
                // Go to next page
                parentVC.scrollToNextViewController()
            }
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
        
        if self.primaryLangItems.count >= indexPath.row {
            let lang = primaryLangItems[indexPath.row]
            
            cell.cellText.text = lang.name
            cell.tag = lang.id
            
            if primaryLangTemp == lang.id {
                cell.cellBg.image = UIImage(named: "cell_bg_on")
                cell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
                
            } else {
                cell.cellBg.image = UIImage(named: "cell_bg_off")
                cell.cellText.textColor = UIColor.whiteColor()
            }
        }
        
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.clipsToBounds = true
        cell.layer.zPosition = -1
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if IS_DEBUG {
            print("Row \(indexPath.row) selected")
        }
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! CustomTableViewCell
        
        if primaryLangTemp == selectedCell.tag {
            // UnSelected this row
            selectedCell.cellBg.image = UIImage(named: "cell_bg_off")
            selectedCell.cellText.textColor = UIColor.whiteColor()
            
            // Set primary language to 0
            primaryLangTemp = 0
        } else {
            // Unselected row before
            for cell in tableView.visibleCells as! [CustomTableViewCell] {
                cell.cellBg.image = UIImage(named: "cell_bg_off")
                cell.cellText.textColor = UIColor.whiteColor()
            }
            
            
            // Selected
            selectedCell.cellBg.image = UIImage(named: "cell_bg_on")
            selectedCell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
            
            primaryLangTemp = selectedCell.tag
        }
    }
}
