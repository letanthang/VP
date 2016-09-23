//
//  ReSelectContainerViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 23/7/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit

class ReSelectContainerViewController: UIViewController, ReSelectPageViewControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var btnNextPre: UIButton!
    
    var currentPage: Int?
    
    var reSelectPageViewController: ReSelectPageViewController? {
        didSet {
            reSelectPageViewController?.reSelectDelegate = self
        }
    }
    
    func reSelectPageViewController(reSelectPageViewController: ReSelectPageViewController,
                                    didUpdatePageCount count: Int) {
        
    }
    
    func reSelectPageViewController(reSelectPageViewController: ReSelectPageViewController,
                                    didUpdatePageIndex index: Int) {
        currentPage = index
        
        if currentPage == 0 {
            btnNextPre.setBackgroundImage(UIImage(named: "secondary_lang_btn"), forState: UIControlState.Normal)
        } else {
            btnNextPre.setBackgroundImage(UIImage(named: "back_to_primary"), forState: UIControlState.Normal)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let reSelectPageViewController = segue.destinationViewController as? ReSelectPageViewController {
            self.reSelectPageViewController = reSelectPageViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            
            self.revealViewController().rearViewRevealWidth = 150
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        
        let navigationTitlelabel = UILabel(frame: CGRectMake(0, 0, 200, 21))
        navigationTitlelabel.center = CGPointMake(160, 284)
        navigationTitlelabel.textAlignment = NSTextAlignment.Left
        navigationTitlelabel.textColor  = UIColor.whiteColor()
        navigationTitlelabel.adjustsFontSizeToFitWidth = true
        navigationTitlelabel.text = "SUBSCRIBED LANGUAGES"
        navigationTitlelabel.font = UIFont(name: "HelveticaNeue-Medium",  size: 14)
        
        self.navigationController!.navigationBar.topItem!.titleView = navigationTitlelabel
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapSave(sender: UIButton) {
        // Show or hide view info
        if let visibleVC = reSelectPageViewController!.viewControllers?.first as? ReSelectPrimaryViewController {
            visibleVC.savePrimaryLangToServer()
        }
        
        if let visibleVC = reSelectPageViewController!.viewControllers?.first as? ReSelectSecondaryViewController {
            visibleVC.saveSecondaryLangToServer()
        }
    }

    @IBAction func didTapNextOrPrePage(sender: UIButton) {
        if currentPage == 0 {
            reSelectPageViewController?.scrollToViewController(index: 1)
        } else {
            reSelectPageViewController?.scrollToViewController(index: 0)
        }
    }
}
