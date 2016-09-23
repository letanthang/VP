//
//  ArticleDetailViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 5/7/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON
import PDFReader

class ArticleDetailViewController: UIViewController, NSURLSessionDownloadDelegate {

    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var banner: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var favouriteBtn: UIButton!
    
    @IBOutlet weak var bgConstraintBot: NSLayoutConstraint!
    
    var pdfFileName: String?
 
    var articleObj: ArticleObj?
    
    var downloadTask: NSURLSessionDownloadTask!
    var backgroundSession: NSURLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }

    override func viewWillAppear(animated: Bool) {
        bgView.layer.cornerRadius = 8
        
        // show loading
        showLoading()
        
        // Get article detail
        getArticleDetai()

    }

    func getArticleDetai() {
        // Get id
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(USER_ID_KEY)
        let articleId = NSUserDefaults.standardUserDefaults().integerForKey(ARTICLE_ID)
        let articleLangId = NSUserDefaults.standardUserDefaults().integerForKey(ARTICLE_LANG_ID)
        
        // Get article from server
        let body: String = "userId=" + String(userId) + "&articleId=" + String(articleId) + "&articleLangId=" + String(articleLangId)
        
        RestApiManager.sharedInstance.callApi(GET_ARTICLE_DETAIL_API, body: body, onCompletion: { (json: JSON) in
            self.getArticleCallback(json)
        })
    }
    
    func getArticleCallback(json: JSON) -> Void {
        if json.isEmpty {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: CONNECTION_ERROR)
            
            return
        }
        
        if IS_DEBUG {
            print ("Article \(json)")
        }
        
        let code = json["code"]
        
        if code == 1 {
            // login success
            let article = json["article"]
            
            articleObj = ArticleObj(json: article)
            
            let favouriteFlg = article["is_favourite"].intValue
            
            dispatch_async(dispatch_get_main_queue()) {
                // Update view
                self.navigationItem.title = self.articleObj?.name
                
                self.name.text = self.articleObj?.name
                self.content.text = self.articleObj?.articleContent
                let font = self.content.font
                
                let style = NSMutableParagraphStyle()
                style.lineBreakMode = NSLineBreakMode.ByWordWrapping
                let size = self.articleObj?.articleContent.sizeForWidth(self.content.frame.size.width, font: font!)
                
                var numberLine = (size?.height)! / (font?.lineHeight)!
                
                if numberLine < 2 {
                    numberLine += 1
                }
                
                // iphone 6 plus -- 300
                // iphone 6 -- 250
                // iphone 5 -- 200
                
                var contentHeight: CGFloat = 120
                
                if DeviceType.IS_IPHONE_5 {
                    contentHeight = 200
                    
                } else if DeviceType.IS_IPHONE_6 {
                    contentHeight = 250
                    
                } else if DeviceType.IS_IPHONE_6P {
                    contentHeight = 300
                }
                
                if numberLine * 18 > contentHeight {
                    self.bgConstraintBot.constant = 20
                } else {
                    self.bgConstraintBot.constant = contentHeight - (numberLine * 18)
                }
                
                // self.bgConstraintBot.constant = 290
                
                // Set image from url
                let url = NSURL(string: self.articleObj!.banner)
                let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                self.banner.image = UIImage(data: data!)
                
                let maskPath = UIBezierPath(roundedRect: self.banner.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSizeMake(8, 8))
                let maskLayer = CAShapeLayer()
                maskLayer.frame = self.banner.bounds
                maskLayer.path  = maskPath.CGPath
                self.banner.layer.mask = maskLayer
                
                if favouriteFlg == 1 {
                    self.favouriteBtn.tag = 1;
                    self.favouriteBtn.setBackgroundImage(UIImage(named: "favourite_on"), forState: UIControlState.Normal)
                } else {
                    self.favouriteBtn.tag = 0;
                    self.favouriteBtn.setBackgroundImage(UIImage(named: "favourite_off"), forState: UIControlState.Normal)
                }
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
    
    @IBAction func didTapFavourite(sender: UIButton) {
        if self.favouriteBtn.tag == 1 {
            // Remove favourite
            self.favouriteBtn.tag = 0
            self.favouriteBtn.setBackgroundImage(UIImage(named: "favourite_off"), forState: UIControlState.Normal)
            
            // call api remove favourite
            removeFavourite()
        } else {
            // Add favourite
            self.favouriteBtn.tag = 1
            self.favouriteBtn.setBackgroundImage(UIImage(named: "favourite_on"), forState: UIControlState.Normal)
            
            // Call api add favourite
            setFavourite()
        }
    }
    
    func setFavourite() {
        showLoading()
        
        // Get id
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(USER_ID_KEY)
        
        // Get article from server
        let body: String = "userId=" + String(userId) + "&articleId=" + String(articleObj!.id)
        
        RestApiManager.sharedInstance.callApi(SET_FAVOURITE_API, body: body, onCompletion: { (json: JSON) in
            self.hideLoading()
            
            if IS_DEBUG {
                print("set favourite \(json)")
            }
            
            let code = json["code"].intValue
            
            if code == 99 {
                // Show error message
                self.showErrorMessageUserNotExist("Iron World", message: json["message"].stringValue)
            } else if code != 1 {
                // login fail --> show error message
                self.showErrorMessage("Iron World", message: json["message"].stringValue)
            }
        })
    }
    
    func removeFavourite() {
        showLoading()
        
        // Get id
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(USER_ID_KEY)
        
        // Get article from server
        let body: String = "userId=" + String(userId) + "&articleId=" + String(articleObj!.id)
        
        RestApiManager.sharedInstance.callApi(REMOVE_FAVOURITE_API, body: body, onCompletion: { (json: JSON) in
            self.hideLoading()
            if IS_DEBUG {
                print("remove favourite \(json)")
            }
            
            let code = json["code"].intValue
            
            if code == 99 {
                // Show error message
                self.showErrorMessageUserNotExist("Iron World", message: json["message"].stringValue)
            } else if code != 1 {
                // login fail --> show error message
                self.showErrorMessage("Iron World", message: json["message"].stringValue)
            }
        })
    }
    
    @IBAction func didTapViewMore(sender: UIButton) {
        // Open browser or PDF
        if articleObj!.type == URL_TYPE {
            // Open browser
            if let checkURL = NSURL(string: articleObj!.link) {
                UIApplication.sharedApplication().openURL(checkURL)
            }
            
        } else {
            
            let backgroundSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundSession" + String(articleObj!.id))
            backgroundSession = NSURLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
            
            // Open pdf
            pdfFileName = "/" + ((articleObj?.link)! as NSString).lastPathComponent
            
            let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentDirectoryPath:String = path[0]
            let fileManager = NSFileManager()
            let destinationURLForFile = NSURL(fileURLWithPath: documentDirectoryPath.stringByAppendingString("/" + ((articleObj?.link)! as NSString).lastPathComponent))
            print("1 \(destinationURLForFile)")
            if fileManager.fileExistsAtPath(destinationURLForFile.path!){
                showFileWithPath(destinationURLForFile.path!)
            } else {
                showLoading()
                startDownload((articleObj?.link)!)
            }
        }
    }
    
    func startDownload(path: String) -> Void {
        let url = NSURL(string: path)!
        downloadTask = backgroundSession.downloadTaskWithURL(url)
        downloadTask.resume()
    }
    
    // 1
    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    didFinishDownloadingToURL location: NSURL){
        
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = NSFileManager()
        let destinationURLForFile = NSURL(fileURLWithPath: documentDirectoryPath.stringByAppendingString("/" + ((articleObj?.link)! as NSString).lastPathComponent))
        
        print("2 \(destinationURLForFile)")
        
        if fileManager.fileExistsAtPath(destinationURLForFile.path!){
            
            print("not move file")
            showFileWithPath(destinationURLForFile.path!)
            
        }
        else{
            do {
                print("move file")
                try fileManager.moveItemAtURL(location, toURL: destinationURLForFile)
                // show file
                showFileWithPath(destinationURLForFile.path!)
            }catch{
                print("An error occurred while moving file to destination url")
            }
        }
    }
    // 2
    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                                 totalBytesWritten: Int64,
                                 totalBytesExpectedToWrite: Int64){
        // Update process download here
    }
    
    // Download error
    func URLSession(session: NSURLSession,
                    task: NSURLSessionTask,
                    didCompleteWithError error: NSError?){
        downloadTask = nil
        
        if (error != nil) {
            print(error?.description)
        }else{
            print("The task finished transferring data successfully")
        }
        
        self.backgroundSession.invalidateAndCancel()
    }
    
    func showFileWithPath(path: String){

        let isFileFound:Bool? = NSFileManager.defaultManager().fileExistsAtPath(path)
        if isFileFound == true{
            
            print("is file found")
            
            //let documentURL = NSBundle.mainBundle().URLForResource("Cupcakes", withExtension: "pdf")!
            let documentURL = NSURL(fileURLWithPath: path)
            let document = PDFDocument(fileURL: documentURL)
            
            let storyboard = UIStoryboard(name: "PDFReader", bundle: NSBundle(forClass: PDFViewController.self))
            let controller = storyboard.instantiateInitialViewController() as! PDFViewController
            controller.document = document
            controller.title = "PDF View"
        
     
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
    }
    
}

extension String {
    func sizeForWidth(width: CGFloat, font: UIFont) -> CGSize {
        let attr = [NSFontAttributeName: font]
        let height = NSString(string: self).boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options:.UsesLineFragmentOrigin, attributes: attr, context: nil).height
        return CGSize(width: width, height: ceil(height))
    }
}
