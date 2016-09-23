//
//  ReSelectTAViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 30/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReSelectTAViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var taItems = [TaAndLanguageObj]()
    
    let textCellIdentifier = "TextCell"
    
    var taTemp = [Int]()
    
    var heightCell: CGFloat = 62
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            
            self.revealViewController().rearViewRevealWidth = 150
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        // Table view config
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: textCellIdentifier)
    }
    
    @IBAction func didTapSave(sender: AnyObject) {
        // Show loading
        showLoading()
        // Save TA to server
        saveTaToServer()
    }

    
    override func viewWillAppear(animated: Bool) {
        calculateCellHeight()
        
        // Copy secondary language to temp
        taTemp = NSUserDefaults.standardUserDefaults().objectForKey(USER_TA_KEY) as? [Int] ?? [Int]()
        
        // Clear all item in ta list
        taItems.removeAll()
        
        // Get ta from server
        getTa()
    }
    
    func calculateCellHeight() {
        if DeviceType.IS_IPHONE_6 {
            heightCell = 68
        } else if DeviceType.IS_IPHONE_6P {
            heightCell = 75
        }
    }
    
    // MARK: - Get API Data Function
    private func getTa() {
        // Get ta from server
        let body: String = ""
        
        showLoading()
        
        RestApiManager.sharedInstance.callApi(GET_SUBSCRIBE_TA_API, body: body, onCompletion: { (json: JSON) in
            self.getTaCallback(json)
        })
    }
    
    // Callback Function
    func getTaCallback(json: JSON) -> Void {
        if json.isEmpty {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: CONNECTION_ERROR)
            
            return
        }
        
        if IS_DEBUG {
            print ("TA list \(json)")
        }
        
        let code = json["code"]
        
        if code == 1 {
            // login success
            let listTa = json["listTA"].arrayValue
            
            for entry in listTa {
                self.taItems.append(TaAndLanguageObj(json: entry))
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
    
    // Save TA to server
    private func saveTaToServer() {
        if taTemp.count > 0 {
            var taIdStr = ""
            
            for var i = 0; i < taTemp.count; i++ {
                if !taIdStr.isEmpty {
                    taIdStr += ","
                }
                taIdStr += String(taTemp[i])
            }
            
            // Get user id
            let userId = NSUserDefaults.standardUserDefaults().integerForKey(USER_ID_KEY)
            
            let body: String = "userId=" + String(userId) + "&subscribeTAId=" + taIdStr
            
            RestApiManager.sharedInstance.callApi(SET_TA_API, body: body, onCompletion: { (json: JSON) in
                let code = json["code"]
                
                if code == 1 {
                    // Save data
                    NSUserDefaults.standardUserDefaults().setObject(self.taTemp, forKey: USER_TA_KEY)
                    
                    // hide loading
                    self.hideLoading()
                    
                    // login fail --> show error message
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
            
            self.showErrorMessage("Iron World", message: CHECK_INPUT_SELECT_TA);
        }
    }
    
    // MARK: - TableView Function
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taItems.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return heightCell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier(textCellIdentifier) as! CustomTableViewCell
        
        if self.taItems.count >= indexPath.row {
            let ta = taItems[indexPath.row]
            
            cell.cellText.text = ta.name
            cell.tag = ta.id
            
            for var i = 0; i < taTemp.count; i++ {
                if taTemp[i] == cell.tag {
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

        if taTemp.count > 0 {
            var indexUnSelect = -1
            
            for var i = 0; i < taTemp.count; i++ {
                if taTemp[i] == selectedCell.tag {
                    indexUnSelect = i;
                    break;
                }
            }
            
            if indexUnSelect >= 0 {
                // UnSelected this row
                selectedCell.cellBg.image = UIImage(named: "cell_bg_off")
                selectedCell.cellText.textColor = UIColor.whiteColor()
                
                taTemp.removeAtIndex(indexUnSelect)
            } else {
                // Selected
                selectedCell.cellBg.image = UIImage(named: "cell_bg_on")
                selectedCell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
                
                taTemp.append(selectedCell.tag)
            }
            
        } else {
            // Selected
            selectedCell.cellBg.image = UIImage(named: "cell_bg_on")
            selectedCell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
            
            taTemp.append(selectedCell.tag)
        }
        
    }
}
