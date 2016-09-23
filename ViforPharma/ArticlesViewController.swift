//
//  ArticlesViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 20/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class ArticlesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    var articleList = [ArticleObj]()
    
    var heightTopCell: CGFloat = 260
    var heightNormalCell: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealWidth = 150 //ScreenSize.SCREEN_WIDTH/2
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        }
        
        // Table view config
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        let nib = UINib(nibName: "ArticleTopCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "topCell")
        
        let nib1 = UINib(nibName: "ArticleNormalCell", bundle: nil)
        self.tableView.registerNib(nib1, forCellReuseIdentifier: "reuseCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        if DeviceType.IS_IPHONE_6 {
            heightTopCell = 285
            heightNormalCell = 105
        } else if DeviceType.IS_IPHONE_6P {
            heightTopCell = 300
            heightNormalCell = 105
        }
        
        // Clear old aritlc in list
        articleList.removeAll()
        
        // check load article favourite
        if NSUserDefaults.standardUserDefaults().integerForKey(VIEW_FAVOURITES) == 1 {
            // Get favourite list
            getFavouriteList()
        } else {
            // Get normal list
            getArticle()
        }
    }
    
    // MARK: - Get API Data Function
    func getArticle() {
        showLoading()
        
        // Check have filter or not
        // Get filter data
        var filterTa = NSUserDefaults.standardUserDefaults().objectForKey(FILTER_TA) as? [Int] ?? [Int]()
        var filterLang = NSUserDefaults.standardUserDefaults().objectForKey(FILTER_LANG) as? [Int] ?? [Int]()
        
        if filterTa.count == 0 {
            // Get user ta
            filterTa = NSUserDefaults.standardUserDefaults().objectForKey(USER_TA_KEY) as? [Int] ?? [Int]()
        }
        
        if filterLang.count == 0 {
            // Get user primary and secondary language
            filterLang = NSUserDefaults.standardUserDefaults().objectForKey(USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
            
            filterLang.append(NSUserDefaults.standardUserDefaults().integerForKey(USER_PRIMARY_LANGUAGE_KEY))
        }
        
        var taStr: String = ""
        var langStr: String = ""
        
        for ta in filterTa {
            if !taStr.isEmpty {
                taStr += ","
            }
            taStr += String(ta)
        }
        
        for lang in filterLang {
            if !langStr.isEmpty {
                langStr += ","
            }
            langStr += String(lang)
        }
        
        // Get article from server
        let body: String = "ta=" + taStr + "&lang=" + langStr
        
        RestApiManager.sharedInstance.callApi(GET_ARTICLE_API, body: body, onCompletion: { (json: JSON) in
            self.getFavouriteCallback(json)
        })
        
    }
    
    func getArticleCallback (json: JSON) -> Void {
        if json.isEmpty {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: CONNECTION_ERROR)
            
            return
        }
        
        if IS_DEBUG {
            print ("Article list \(json)")
        }
        
        let code = json["code"]
        
        if code == 1 {
            // login success
            let list = json["articles"].arrayValue
            
            for entry in list {
                self.articleList.append(ArticleObj(json: entry))
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
    
    // get favourite article
    private func getFavouriteList() {
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(USER_ID_KEY)
        
        // Get article from server
        let body: String = "userId=" + String(userId)
        
        showLoading()
        
        RestApiManager.sharedInstance.callApi(GET_FAVOURITE_API, body: body, onCompletion: { (json: JSON) in
            self.getFavouriteCallback(json)
        })
    }
    
    // Callback Function
    func getFavouriteCallback(json: JSON) -> Void {
        if json.isEmpty {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: CONNECTION_ERROR)
            
            return
        }
        
        if IS_DEBUG {
            print ("Favourite list \(json)")
        }
        
        let code = json["code"]
        
        if code == 1 {
            // login success
            let list = json["articles"].arrayValue
            
            for entry in list {
                self.articleList.append(ArticleObj(json: entry))
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView?.reloadData()
            }
            
            // hide loading
            hideLoading()
            
        } else if code == 99 {
            // Close loading
            hideLoading()
            
            // Show error message
            self.showErrorMessageUserNotExist("Iron World", message: json["message"].stringValue)
        } else {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: String(json["message"]))
        }
        
    }
    
    
    // MARK: - TableView Function
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articleList.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return heightTopCell
        }
        
        return heightNormalCell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("topCell") as! ArticleTopCell
            
            cell.name.text = self.articleList[indexPath.row].name
            cell.content.text = self.articleList[indexPath.row].articleContent
            
            // Set image from url
            let url = NSURL(string: self.articleList[indexPath.row].banner)
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            cell.banner.image = UIImage(data: data!)

            
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("reuseCell") as! ArticleNormalCell
            
            cell.name.text = self.articleList[indexPath.row].name
            cell.content.text = self.articleList[indexPath.row].articleContent
            
            // Set image from url
            let url = NSURL(string: self.articleList[indexPath.row].banner)
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            
            cell.banner.image = self.resizeImage(UIImage(data: data!)!, targetSize: CGSizeMake(294.0, 132.5))
            
            //cell.banner.image = UIImage(data: data!)
            
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Save id
        NSUserDefaults.standardUserDefaults().setInteger(articleList[indexPath.row].id, forKey: ARTICLE_ID)
        NSUserDefaults.standardUserDefaults().setInteger(articleList[indexPath.row].articleLangId, forKey: ARTICLE_LANG_ID)
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("ArticleDetailViewController") as? ArticleDetailViewController
        self.navigationController?.pushViewController(detailVC!, animated: true)
        
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
