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
    
    func reSelectPageViewController(_ reSelectPageViewController: ReSelectPageViewController,
                                    didUpdatePageCount count: Int) {
        
    }
    
    func reSelectPageViewController(_ reSelectPageViewController: ReSelectPageViewController,
                                    didUpdatePageIndex index: Int) {
        currentPage = index
        
        if currentPage == 0 {
            btnNextPre.setBackgroundImage(UIImage(named: "secondary_lang_btn"), for: UIControlState())
        } else {
            btnNextPre.setBackgroundImage(UIImage(named: "back_to_primary"), for: UIControlState())
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let reSelectPageViewController = segue.destination as? ReSelectPageViewController {
            self.reSelectPageViewController = reSelectPageViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            
            self.revealViewController().rearViewRevealWidth = 150
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        
        let navigationTitlelabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        navigationTitlelabel.center = CGPoint(x: 160, y: 284)
        navigationTitlelabel.textAlignment = NSTextAlignment.left
        navigationTitlelabel.textColor  = UIColor.white
        navigationTitlelabel.adjustsFontSizeToFitWidth = true
        navigationTitlelabel.text = "SUBSCRIBED LANGUAGES"
        navigationTitlelabel.font = UIFont(name: "HelveticaNeue-Medium",  size: 14)
        
        self.navigationController!.navigationBar.topItem!.titleView = navigationTitlelabel
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapSave(_ sender: UIButton) {
        // Show or hide view info
        if let visibleVC = reSelectPageViewController!.viewControllers?.first as? ReSelectPrimaryViewController {
            visibleVC.savePrimaryLangToServer()
        }
        
        if let visibleVC = reSelectPageViewController!.viewControllers?.first as? ReSelectSecondaryViewController {
            visibleVC.saveSecondaryLangToServer()
        }
    }

    @IBAction func didTapNextOrPrePage(_ sender: UIButton) {
        if currentPage == 0 {
            reSelectPageViewController?.scrollToViewController(index: 1)
        } else {
            reSelectPageViewController?.scrollToViewController(index: 0)
        }
    }
}
