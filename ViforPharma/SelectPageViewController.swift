//
//  PageViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 22/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class SelectPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return [self.newViewController("SelectTA"),
            self.newViewController("SelectPrimaryLang"),
            self.newViewController("SelectSecondaryLang")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(initialViewController)
        }
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self,
                viewControllerAfterViewController: visibleViewController) {
                    scrollToViewController(nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.indexOf(firstViewController) {
                let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .Forward : .Reverse
                let nextViewController = orderedViewControllers[newIndex]
                scrollToViewController(nextViewController, direction: direction)
        }
    }
    
    private func newViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("\(name)ViewController")
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController,
        direction: UIPageViewControllerNavigationDirection = .Forward) {
            setViewControllers([viewController],
                direction: direction,
                animated: true,
                completion: { (finished) -> Void in
                    // Setting the view controller programmatically does not fire
                    // any delegate methods, so we have to manually notify the
                    // 'tutorialDelegate' of the new index.
            })
    }
    
    var isNeedToCheck = true;
    
    // MARK: UIPageViewControllerDelegate
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if pendingViewControllers.first?.view.tag == 1 {
            isNeedToCheck = false;
        } else {
            isNeedToCheck = true;
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // Save data
            if previousViewControllers.first?.view.tag == 1 {
                // Save TA to server
                saveTaToServer()
                
            } else if previousViewControllers.first?.view.tag == 2 && isNeedToCheck {
                // Save primary language
                savePrimaryLangToServer()
            }
        }
        
        if previousViewControllers.first?.view.tag == 1 {
            // this is primary language screen --> So need to check validate TA
            let userTaArr: Array = NSUserDefaults.standardUserDefaults().objectForKey(USER_TA_KEY) as? [Int] ?? [Int]()
            
            if userTaArr.count <= 0 {
                self.showErrorMessageWithAction("Iron World", message: CHECK_INPUT_SELECT_TA, pageIndex: 0);
            }
            
        } else if previousViewControllers.first?.view.tag == 2 && isNeedToCheck {
            // this is secondary language --> So need to check validate primary language
            let userPrimaryLang: Int = NSUserDefaults.standardUserDefaults().integerForKey(USER_PRIMARY_LANGUAGE_KEY)
            
            if userPrimaryLang == 0 {
                self.showErrorMessageWithAction("Iron World", message: CHECK_INPUT_SELECT_LANGUAGE, pageIndex: 1);
            }
        }
    }

    // Call api save Ta to server
    private func saveTaToServer() {
        let userTaArr: Array = NSUserDefaults.standardUserDefaults().objectForKey(USER_TA_KEY) as? [Int] ?? [Int]()
        
        if userTaArr.count > 0 {
            var taIdStr = ""
            
            for var i = 0; i < userTaArr.count; i++ {
                if !taIdStr.isEmpty {
                    taIdStr += ","
                }
                taIdStr += String(userTaArr[i])
            }
            
            
            // Get user id
            let userId = NSUserDefaults.standardUserDefaults().integerForKey(USER_ID_KEY)
            
            let body: String = "userId=" + String(userId) + "&subscribeTAId=" + taIdStr
            
            RestApiManager.sharedInstance.callApi(SET_TA_API, body: body, onCompletion: { (json: JSON) in
                if IS_DEBUG {
                    print("Save TA \(json)")
                }
                
                let code = json["code"]
                
                if code == 99 {
                    // Show error message
                    self.showErrorMessageUserNotExist("Iron World", message: json["message"].stringValue)
                } else if code != 1 {
                    // show error message
                    self.showErrorMessage("Iron World", message: json["message"].stringValue)
                }
            })
        }
    }
    
    // Call api save primary language to server
    private func savePrimaryLangToServer() {
        let userPrimaryLang: Int = NSUserDefaults.standardUserDefaults().integerForKey(USER_PRIMARY_LANGUAGE_KEY)
        
        if userPrimaryLang != 0 {
            
            // Get user id
            let userId = NSUserDefaults.standardUserDefaults().integerForKey(USER_ID_KEY)
            
            let body: String = "userId=" + String(userId) + "&langId=" + String(userPrimaryLang)
            
            RestApiManager.sharedInstance.callApi(SET_PRIMARY_LANG_API, body: body, onCompletion: { (json: JSON) in
                if IS_DEBUG {
                    print("Save Primary Lang \(json)")
                }
                
                let code = json["code"]
                
                if code == 99 {
                    // Show error message
                    self.showErrorMessageUserNotExist("Iron World", message: json["message"].stringValue)
                } else if code != 1 {
                    // show error message
                    self.showErrorMessage("Iron World", message: json["message"].stringValue)
                }
            })
        }
    }
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            // User is on the first view controller and swiped left to loop to
            // the last view controller.
            guard previousIndex >= 0 else {
                // return orderedViewControllers.last
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            // User is on the last view controller and swiped right to loop to
            // the first view controller.
            guard orderedViewControllersCount != nextIndex else {
                //return orderedViewControllers.first
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
    func showErrorMessageWithAction(title: String, message: String, pageIndex: Int) {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.scrollToViewController(index: pageIndex)
        }))
        
        // show the alert
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

}