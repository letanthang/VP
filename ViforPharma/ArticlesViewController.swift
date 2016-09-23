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
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }
        
        // Table view config
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        let nib = UINib(nibName: "ArticleTopCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "topCell")
        
        let nib1 = UINib(nibName: "ArticleNormalCell", bundle: nil)
        self.tableView.register(nib1, forCellReuseIdentifier: "reuseCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        if UserDefaults.standard.integer(forKey: VIEW_FAVOURITES) == 1 {
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
        var filterTa = UserDefaults.standard.object(forKey: FILTER_TA) as? [Int] ?? [Int]()
        var filterLang = UserDefaults.standard.object(forKey: FILTER_LANG) as? [Int] ?? [Int]()
        
        if filterTa.count == 0 {
            // Get user ta
            filterTa = UserDefaults.standard.object(forKey: USER_TA_KEY) as? [Int] ?? [Int]()
        }
        
        if filterLang.count == 0 {
            // Get user primary and secondary language
            filterLang = UserDefaults.standard.object(forKey: USER_SECONDARY_LANGUAGE_KEY) as? [Int] ?? [Int]()
            
            filterLang.append(UserDefaults.standard.integer(forKey: USER_PRIMARY_LANGUAGE_KEY))
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
    
    func getArticleCallback (_ json: JSON) -> Void {
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
    
    // get favourite article
    fileprivate func getFavouriteList() {
        let userId = UserDefaults.standard.integer(forKey: USER_ID_KEY)
        
        // Get article from server
        let body: String = "userId=" + String(userId)
        
        showLoading()
        
        RestApiManager.sharedInstance.callApi(GET_FAVOURITE_API, body: body, onCompletion: { (json: JSON) in
            self.getFavouriteCallback(json)
        })
    }
    
    // Callback Function
    func getFavouriteCallback(_ json: JSON) -> Void {
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
            
            DispatchQueue.main.async {
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
            self.showErrorMessage("Iron World", message: String(describing: json["message"]))
        }
        
    }
    
    
    // MARK: - TableView Function
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articleList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0 {
            return heightTopCell
        }
        
        return heightNormalCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "topCell") as! ArticleTopCell
            
            cell.name.text = self.articleList[(indexPath as NSIndexPath).row].name
            cell.content.text = self.articleList[(indexPath as NSIndexPath).row].articleContent
            
            // Set image from url
            let url = URL(string: self.articleList[(indexPath as NSIndexPath).row].banner)
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            cell.banner.image = UIImage(data: data!)

            
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "reuseCell") as! ArticleNormalCell
            
            cell.name.text = self.articleList[(indexPath as NSIndexPath).row].name
            cell.content.text = self.articleList[(indexPath as NSIndexPath).row].articleContent
            
            // Set image from url
            let url = URL(string: self.articleList[(indexPath as NSIndexPath).row].banner)
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            
            cell.banner.image = self.resizeImage(UIImage(data: data!)!, targetSize: CGSize(width: 294.0, height: 132.5))
            
            //cell.banner.image = UIImage(data: data!)
            
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Save id
        UserDefaults.standard.set(articleList[(indexPath as NSIndexPath).row].id, forKey: ARTICLE_ID)
        UserDefaults.standard.set(articleList[(indexPath as NSIndexPath).row].articleLangId, forKey: ARTICLE_LANG_ID)
        
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "ArticleDetailViewController") as? ArticleDetailViewController
        self.navigationController?.pushViewController(detailVC!, animated: true)
        
        
    }
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
