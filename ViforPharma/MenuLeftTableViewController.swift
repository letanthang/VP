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
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }


    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuText.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (ScreenSize.SCREEN_HEIGHT - 20)/6
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let textIndentifier = "menuCell" + String(indexPath.row)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(textIndentifier, forIndexPath: indexPath) as! CustomMenuCell

        let menuPos = NSUserDefaults.standardUserDefaults().integerForKey(MENU_POS)
        
        if menuPos == indexPath.row {
            cell.iconMenu.image = UIImage(named: menuImgActive[indexPath.row])
            cell.textMenu.text = menuText[indexPath.row]
            cell.textMenu.textColor = UIColor.whiteColor()
        } else {
            cell.iconMenu.image = UIImage(named: menuImg[indexPath.row])
            cell.textMenu.text = menuText[indexPath.row]
        }
        
        // set width cell
        // cell.cellWidth.constant = ScreenSize.SCREEN_WIDTH/2
        
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.tag = indexPath.row

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Check case select button logout
        if menuText[indexPath.row] == "Logout" {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(MENU_POS)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(FILTER_TA)
            NSUserDefaults.standardUserDefaults().removeObjectForKey(FILTER_LANG)
            
            // Clear all file pdf temp
            clearPdfTempFile()
            
            
            let next = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.presentViewController(next, animated: false, completion: nil)
        } else if menuText[indexPath.row] == "View Favourites" {
            NSUserDefaults.standardUserDefaults().setInteger(1, forKey: VIEW_FAVOURITES)
        
        } else if menuText[indexPath.row] == "Home" {
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: VIEW_FAVOURITES)
            
        }

        // Save menu postion
        NSUserDefaults.standardUserDefaults().setInteger(indexPath.row, forKey: MENU_POS)
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! CustomMenuCell
        
        selectedCell.iconMenu.image = UIImage(named: menuImgActive[indexPath.row])
        selectedCell.textMenu.textColor = UIColor.whiteColor()
        
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
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = NSFileManager()
        
        do {
            let filePaths = try fileManager.contentsOfDirectoryAtPath(documentDirectoryPath)
            for filePath in filePaths {
                try fileManager.removeItemAtPath(documentDirectoryPath.stringByAppendingString("/" + filePath))
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
}
