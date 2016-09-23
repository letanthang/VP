//
//  ChooseTaFilterViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 1/7/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChooseTaFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var infoView: UIView!
    
    var taItems = [TaAndLanguageObj]()
    
    let textCellIdentifier = "TextCell"
    
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
        
        calculateCellHeight()
        
        // get data from server
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
            // get data success
            let listTa = json["listTA"].arrayValue
            let userTaList = UserDefaults.standard.object(forKey: USER_TA_KEY) as? [Int] ?? [Int]()
            
            for entry in listTa {
                
                if userTaList.contains(entry["id"].intValue) {
                    self.taItems.append(TaAndLanguageObj(json: entry))
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
    
    // Show info
    internal func showInfo () -> Void {
        infoView.isHidden = !infoView.isHidden
    }
    
    func hideInfo() ->Void {
        infoView.isHidden = true;
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
        
        let taFilter = UserDefaults.standard.object(forKey: FILTER_TA) as? [Int] ?? [Int]()
        
        if self.taItems.count >= (indexPath as NSIndexPath).row {
            let ta = taItems[(indexPath as NSIndexPath).row]
            
            cell.cellText.text = ta.name
            cell.tag = ta.id
            
            for i in 0 ..< taFilter.count {
                if taFilter[i] == cell.tag {
                    cell.cellBg.image = UIImage(named: "cell_bg_on_blue")
                    cell.cellText.textColor = UIColor.white
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
        var taFilter = UserDefaults.standard.object(forKey: FILTER_TA) as? [Int] ?? [Int]()
        
        if taFilter.count > 0 {
            var indexUnSelect = -1
            
            for i in 0 ..< taFilter.count {
                if taFilter[i] == selectedCell.tag {
                    indexUnSelect = i;
                    break;
                }
            }
            
            if indexUnSelect >= 0 {
                // UnSelected this row
                selectedCell.cellBg.image = UIImage(named: "cell_bg_off")
                selectedCell.cellText.textColor = UIColor.white
                
                taFilter.remove(at: indexUnSelect)
            } else {
                // Selected
                selectedCell.cellBg.image = UIImage(named: "cell_bg_on_blue")
                selectedCell.cellText.textColor = UIColor.white
                
                taFilter.append(selectedCell.tag)
            }
            
        } else {
            // Selected
            selectedCell.cellBg.image = UIImage(named: "cell_bg_on_blue")
            selectedCell.cellText.textColor = UIColor.white
            
            taFilter.append(selectedCell.tag)
        }
        
        // Save data
        UserDefaults.standard.set(taFilter, forKey: FILTER_TA)
    }
}
