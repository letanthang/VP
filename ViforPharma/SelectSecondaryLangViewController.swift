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
        secondaryLangItems.removeAll()
        
        // Get ta from server
        let body: String = ""
        
        showLoading()
        
        RestApiManager.sharedInstance.callApi(GET_LANGUAGE_API, body: body, onCompletion: { (json: JSON) in
            self.getSecondLanguageCallback(json)
        })
    }
    @IBAction func didTapRegister(sender: AnyObject) {
        // Show loading
        showLoading()
        // Save data to server
        saveSecondaryLangToServer()
    }
    
    @IBAction func didTapSkip(sender: AnyObject) {
        // Init menu postion
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: MENU_POS)
        
        // Go to article list
        let next = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        self.presentViewController(next, animated: true, completion: nil)
    }
    
    // MARK: - Callback Function
    func getSecondLanguageCallback(json: JSON) -> Void {
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
            let userPrimaryLang: Int = NSUserDefaults.standardUserDefaults().integerForKey(USER_PRIMARY_LANGUAGE_KEY)
            
            for entry in listLang {
                if userPrimaryLang != entry["id"].intValue {
                    self.secondaryLangItems.append(TaAndLanguageObj(json: entry))
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
    
    // Call api save secondary language to server
    private func saveSecondaryLangToServer() {
        let userSecondaryLagnArr: Array = NSUserDefaults.standardUserDefaults().objectForKey(USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
        
        if userSecondaryLagnArr.count > 0 {
            var langIdStr = ""
            
            for var i = 0; i < userSecondaryLagnArr.count; i++ {
                if !langIdStr.isEmpty {
                    langIdStr += ","
                }
                langIdStr += String(userSecondaryLagnArr[i])
            }
            
            
            // Get user id
            let userId = NSUserDefaults.standardUserDefaults().integerForKey(USER_ID_KEY)
            
            let body: String = "userId=" + String(userId) + "&secondaryLangId=" + langIdStr
            
            RestApiManager.sharedInstance.callApi(SET_SECONDARY_LANG_API, body: body, onCompletion: { (json: JSON) in
                self.saveSecondaryLangCallback(json)
            })
        } else {
            // Init menu postion
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: MENU_POS)
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: VIEW_FAVOURITES)
            
            let next = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
            self.presentViewController(next, animated: true, completion: nil)
        }
    }
    
    func saveSecondaryLangCallback(json: JSON) -> Void {
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
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: MENU_POS)
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: VIEW_FAVOURITES)
            
            // Save success and go to article list
            dispatch_async(dispatch_get_main_queue()) {
                let next = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
                self.presentViewController(next, animated: true, completion: nil)
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return secondaryLangItems.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return heightCell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(textCellIdentifier) as! CustomTableViewCell
        let userSecondaryLagnArr: Array = NSUserDefaults.standardUserDefaults().objectForKey(USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
        
        if self.secondaryLangItems.count >= indexPath.row {
            let secondLang = secondaryLangItems[indexPath.row]
            
            cell.cellText.text = secondLang.name
            cell.tag = secondLang.id
            
            for var i = 0; i < userSecondaryLagnArr.count; i++ {
                if userSecondaryLagnArr[i] == cell.tag {
                    cell.cellBg.image = UIImage(named: "cell_bg_on")
                    cell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
                    break
                } else {
                    cell.cellBg.image = UIImage(named: "cell_bg_off")
                    cell.cellText.textColor = UIColor.whiteColor()
                }
            }
        }
        
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Row \(indexPath.row) selected")
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! CustomTableViewCell
        var userSecondaryLagnArr: Array = NSUserDefaults.standardUserDefaults().objectForKey(USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
        
        if userSecondaryLagnArr.count > 0 {
            var indexUnSelect = -1
            
            for var i = 0; i < userSecondaryLagnArr.count; i++ {
                if userSecondaryLagnArr[i] == selectedCell.tag {
                    indexUnSelect = i;
                    break;
                }
            }
            
            if indexUnSelect >= 0 {
                // UnSelected this row
                selectedCell.cellBg.image = UIImage(named: "cell_bg_off")
                selectedCell.cellText.textColor = UIColor.whiteColor()
                
                userSecondaryLagnArr.removeAtIndex(indexUnSelect)
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
        NSUserDefaults.standardUserDefaults().setObject( userSecondaryLagnArr, forKey: USER_SECONDARY_LANGUAGE_KEY)
        
    }
}
