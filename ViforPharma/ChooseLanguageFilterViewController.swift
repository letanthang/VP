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
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: textCellIdentifier)
        
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
            var userAllLang = UserDefaults.standard.object(forKey: USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
            userAllLang.append(userPrimaryLang)
            
            for entry in listLang {
                if userAllLang.contains(entry["id"].intValue) {
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
        return secondaryLangItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: textCellIdentifier) as! CustomTableViewCell
        let langFilter = UserDefaults.standard.object(forKey: FILTER_LANG)  as? [Int] ?? [Int]()
        
        if self.secondaryLangItems.count >= (indexPath as NSIndexPath).row {
            let secondLang = secondaryLangItems[(indexPath as NSIndexPath).row]
            
            cell.cellText.text = secondLang.name
            cell.tag = secondLang.id
            
            for i in 0 ..< langFilter.count {
                if langFilter[i] == cell.tag {
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
        var langFilter = UserDefaults.standard.object(forKey: FILTER_LANG)  as? [Int] ?? [Int]()
        
        if langFilter.count > 0 {
            var indexUnSelect = -1
            
            for i in 0 ..< langFilter.count {
                if langFilter[i] == selectedCell.tag {
                    indexUnSelect = i;
                    break;
                }
            }
            
            if indexUnSelect >= 0 {
                // UnSelected this row
                selectedCell.cellBg.image = UIImage(named: "cell_bg_off")
                selectedCell.cellText.textColor = UIColor.white
                
                langFilter.remove(at: indexUnSelect)
            } else {
                // Selected
                selectedCell.cellBg.image = UIImage(named: "cell_bg_on_blue")
                selectedCell.cellText.textColor = UIColor.white
                
                langFilter.append(selectedCell.tag)
            }
            
        } else {
            // Selected
            selectedCell.cellBg.image = UIImage(named: "cell_bg_on_blue")
            selectedCell.cellText.textColor = UIColor.white
            
            langFilter.append(selectedCell.tag)
        }
        
        // Save data
        UserDefaults.standard.set(langFilter, forKey: FILTER_LANG)
    }
}
