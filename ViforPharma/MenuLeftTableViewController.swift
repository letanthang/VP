//
//  MenuLeftTableViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 29/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit

class MenuLeftTableViewController: UITableViewController {
    
    let menuText: [String] = ["Home", "Select TA", "Select Languages", "View Favourites", "Filter Search", "Logout"]
    let menuImg: [String] = ["inactive_home", "inactive_articles", "inactive_language", "inactive_favourite", "inactive_filter_search-1", "inactive_logout-1"]
    let menuImgActive: [String] = ["active_home", "active_articles", "active_language", "active_favourite", "active_filter_search-1", "inactive_logout-1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor(red: 14/255, green: 34/255, blue: 74/255, alpha: 1)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }


    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuText.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (ScreenSize.SCREEN_HEIGHT - 20)/6
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let textIndentifier = "menuCell" + String((indexPath as NSIndexPath).row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: textIndentifier, for: indexPath) as! CustomMenuCell

        let menuPos = UserDefaults.standard.integer(forKey: MENU_POS)
        
        if menuPos == (indexPath as NSIndexPath).row {
            cell.iconMenu.image = UIImage(named: menuImgActive[(indexPath as NSIndexPath).row])
            cell.textMenu.text = menuText[(indexPath as NSIndexPath).row]
            cell.textMenu.textColor = UIColor.white
        } else {
            cell.iconMenu.image = UIImage(named: menuImg[(indexPath as NSIndexPath).row])
            cell.textMenu.text = menuText[(indexPath as NSIndexPath).row]
        }
        
        // set width cell
        // cell.cellWidth.constant = ScreenSize.SCREEN_WIDTH/2
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.tag = (indexPath as NSIndexPath).row

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check case select button logout
        if menuText[(indexPath as NSIndexPath).row] == "Logout" {
            UserDefaults.standard.removeObject(forKey: MENU_POS)
            UserDefaults.standard.removeObject(forKey: FILTER_TA)
            UserDefaults.standard.removeObject(forKey: FILTER_LANG)
            
            // Clear all file pdf temp
            clearPdfTempFile()
            
            
            let next = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(next, animated: false, completion: nil)
        } else if menuText[(indexPath as NSIndexPath).row] == "View Favourites" {
            UserDefaults.standard.set(1, forKey: VIEW_FAVOURITES)
        
        } else if menuText[(indexPath as NSIndexPath).row] == "Home" {
            UserDefaults.standard.set(0, forKey: VIEW_FAVOURITES)
            
        }

        // Save menu postion
        UserDefaults.standard.set((indexPath as NSIndexPath).row, forKey: MENU_POS)
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! CustomMenuCell
        
        selectedCell.iconMenu.image = UIImage(named: menuImgActive[(indexPath as NSIndexPath).row])
        selectedCell.textMenu.textColor = UIColor.white
        
        // Get all list cell visible
        // Unselected row before
        for cell in self.tableView.visibleCells as! [CustomMenuCell] {
            if cell.tag != selectedCell.tag {
                cell.iconMenu.image = UIImage(named: menuImg[cell.tag])
                cell.textMenu.textColor = UIColor(red: 67/255, green: 85/255, blue: 121/255, alpha: 1)
            }
        }
    }
    
    func clearPdfTempFile() -> Void {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: documentDirectoryPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: documentDirectoryPath + ("/" + filePath))
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
}
