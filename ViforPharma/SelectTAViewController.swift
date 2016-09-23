//
//  SelectTAViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 20/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class SelectTAViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var taItems = [TaAndLanguageObj]()
    
    let textCellIdentifier = "TextCell"
    
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
    @IBAction func didTabNext(_ sender: AnyObject) {
        if let parentVC = self.parent {
            if let parentVC = parentVC as? SelectPageViewController {
                // parentVC is SelectPageViewController
                
                // this is primary language screen --> So need to check validate TA
                let userTaArr: Array = UserDefaults.standard.object(forKey: USER_TA_KEY) as? [Int] ?? [Int]()
                
                if userTaArr.count <= 0 {
                    self.showErrorMessage("Iron World", message: CHECK_INPUT_SELECT_TA);
                } else {
                    // Save Ta
                    saveTaToServer()
                    
                    // Go to next page
                    parentVC.scrollToNextViewController()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        calculateCellHeight()
        
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
    fileprivate func getTa() {
        // Get ta from server
        let body: String = ""
        
        showLoading()
        
        RestApiManager.sharedInstance.callApi(GET_SUBSCRIBE_TA_API, body: body, onCompletion: { (json: JSON) in
            self.getTaCallback(json)
        })
    }
    
    // Callback Function
    func getTaCallback(_ json: JSON) -> Void {
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
    
    // Save TA to server
    fileprivate func saveTaToServer() {
        let userTaArr: Array = UserDefaults.standard.object(forKey: USER_TA_KEY) as? [Int] ?? [Int]()
        
        if userTaArr.count > 0 {
            var taIdStr = ""
            
            for i in 0 ..< userTaArr.count {
                if !taIdStr.isEmpty {
                    taIdStr += ","
                }
                taIdStr += String(userTaArr[i])
            }
            
            
            // Get user id
            let userId = UserDefaults.standard.integer(forKey: USER_ID_KEY)
            
            let body: String = "userId=" + String(userId) + "&subscribeTAId=" + taIdStr
            
            RestApiManager.sharedInstance.callApi(SET_TA_API, body: body, onCompletion: { (json: JSON) in
                if IS_DEBUG {
                    print("Save TA \(json)")
                }
                
                let code = json["code"].intValue
                
                if code == 99 {
                    // Close loading
                    self.hideLoading()
                    
                    // Show error message
                    self.showErrorMessageUserNotExist("Iron World", message: json["message"].stringValue)
                } else if code != 1 {
                    // Close loading
                    self.hideLoading()
                    
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
        return taItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: textCellIdentifier) as! CustomTableViewCell
        
        let userTaArr: Array = UserDefaults.standard.object(forKey: USER_TA_KEY) as? [Int] ?? [Int]()
        
        if self.taItems.count >= (indexPath as NSIndexPath).row {
            let ta = taItems[(indexPath as NSIndexPath).row]
            
            cell.cellText.text = ta.name
            cell.tag = ta.id
            
            for i in 0 ..< userTaArr.count {
                if userTaArr[i] == cell.tag {
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
        var userTaArr: Array = UserDefaults.standard.object(forKey: USER_TA_KEY) as? [Int] ?? [Int]()
        
        if userTaArr.count > 0 {
            var indexUnSelect = -1
            
            for i in 0 ..< userTaArr.count {
                if userTaArr[i] == selectedCell.tag {
                    indexUnSelect = i;
                    break;
                }
            }
            
            if indexUnSelect >= 0 {
                // UnSelected this row
                selectedCell.cellBg.image = UIImage(named: "cell_bg_off")
                selectedCell.cellText.textColor = UIColor.white
                
                userTaArr.remove(at: indexUnSelect)
            } else {
                // Selected
                selectedCell.cellBg.image = UIImage(named: "cell_bg_on")
                selectedCell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
                
                userTaArr.append(selectedCell.tag)
            }
            
        } else {
            // Selected
            selectedCell.cellBg.image = UIImage(named: "cell_bg_on")
            selectedCell.cellText.textColor = UIColor(red: 44/255, green: 73/255, blue: 130/255, alpha: 1)
            
            userTaArr.append(selectedCell.tag)
        }
        
        // Save data
        UserDefaults.standard.set( userTaArr, forKey: USER_TA_KEY)
        
    }

}
