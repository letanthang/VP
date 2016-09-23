//
//  ChooseLanguageFilterViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 1/7/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChooseLanguageFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var infoView: UIView!
    var secondaryLangItems = [TaAndLanguageObj]()
    
    let textCellIdentifier = "TextCell"
    
    var heightCell: CGFloat = 62
    
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
        
        calculateCellHeight()
        
        // Get data from server
        let body: String = ""
        
        // Show loading
        showLoading()
        
        RestApiManager.sharedInstance.callApi(GET_LANGUAGE_API, body: body, onCompletion: { (json: JSON) in
            self.getSecondLanguageCallback(json)
        })
    }
    
    func calculateCellHeight() {
        if DeviceType.IS_IPHONE_6 {
            heightCell = 68
        } else if DeviceType.IS_IPHONE_6P {
            heightCell = 75
        }
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
            var userAllLang = NSUserDefaults.standardUserDefaults().objectForKey(USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
            userAllLang.append(userPrimaryLang)
            
            for entry in listLang {
                if userAllLang.contains(entry["id"].intValue) {
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
    
    // Show info
    internal func showInfo () -> Void {
        infoView.hidden = !infoView.hidden
    }
    func hideInfo() ->Void {
        infoView.hidden = true;
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
        let langFilter = NSUserDefaults.standardUserDefaults().objectForKey(FILTER_LANG)  as? [Int] ?? [Int]()
        
        if self.secondaryLangItems.count >= indexPath.row {
            let secondLang = secondaryLangItems[indexPath.row]
            
            cell.cellText.text = secondLang.name
            cell.tag = secondLang.id
            
            for var i = 0; i < langFilter.count; i++ {
                if langFilter[i] == cell.tag {
                    cell.cellBg.image = UIImage(named: "cell_bg_on_blue")
                    cell.cellText.textColor = UIColor.whiteColor()
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
        var langFilter = NSUserDefaults.standardUserDefaults().objectForKey(FILTER_LANG)  as? [Int] ?? [Int]()
        
        if langFilter.count > 0 {
            var indexUnSelect = -1
            
            for var i = 0; i < langFilter.count; i++ {
                if langFilter[i] == selectedCell.tag {
                    indexUnSelect = i;
                    break;
                }
            }
            
            if indexUnSelect >= 0 {
                // UnSelected this row
                selectedCell.cellBg.image = UIImage(named: "cell_bg_off")
                selectedCell.cellText.textColor = UIColor.whiteColor()
                
                langFilter.removeAtIndex(indexUnSelect)
            } else {
                // Selected
                selectedCell.cellBg.image = UIImage(named: "cell_bg_on_blue")
                selectedCell.cellText.textColor = UIColor.whiteColor()
                
                langFilter.append(selectedCell.tag)
            }
            
        } else {
            // Selected
            selectedCell.cellBg.image = UIImage(named: "cell_bg_on_blue")
            selectedCell.cellText.textColor = UIColor.whiteColor()
            
            langFilter.append(selectedCell.tag)
        }
        
        // Save data
        NSUserDefaults.standardUserDefaults().setObject(langFilter, forKey: FILTER_LANG)
    }
}
