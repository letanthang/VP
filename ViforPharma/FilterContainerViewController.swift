//
//  FilterContainerViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 24/7/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit

class FilterContainerViewController: UIViewController, FilterPageViewControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var infoButton: UIBarButtonItem!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var labelNote: UILabel!
    
    
    var currentPage: Int?
    
    var filterPageViewController: FilterPageViewController? {
        didSet {
            filterPageViewController?.filterDelegate = self
        }
    }
    
    func filterPageViewController(filterPageViewController: FilterPageViewController,
                                    didUpdatePageCount count: Int) {
        
    }
    
    func filterPageViewController(filterPageViewController: FilterPageViewController,
                                    didUpdatePageIndex index: Int) {
        currentPage = index
        
        // update page control 
        pageControl.currentPage = index
        
        // after next or pre page, need to close Info view
        infoButton.tag = 0
        infoButton.image = UIImage(named: "inactive_info")
        
        if currentPage == 0 {
            labelNote.text = "Slide left to edit languages."
            
            if let vc = filterPageViewController.orderedViewControllers[1] as? ChooseLanguageFilterViewController {
                if vc.infoView != nil {
                    vc.hideInfo()
                }
            }
            
        } else {
            labelNote.text = "Slide right to edit TA."
            
            if let vc = filterPageViewController.orderedViewControllers[0] as? ChooseTaFilterViewController {
                if vc.infoView != nil {
                    vc.hideInfo()
                }
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let filterPageViewController = segue.destinationViewController as? FilterPageViewController {
            self.filterPageViewController = filterPageViewController
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapInfo(sender: UIBarButtonItem) {
        // Set image for button
        if infoButton.tag == 0 {
            infoButton.tag = 1
            infoButton.image = UIImage(named: "active_info")
        } else {
            infoButton.tag = 0
            infoButton.image = UIImage(named: "inactive_info")
        }
        
        // Show or hide view info
        if let visibleVC = filterPageViewController?.viewControllers!.first as? ChooseTaFilterViewController {
            visibleVC.showInfo()
        }
        
        if let visibleVC = filterPageViewController?.viewControllers!.first as? ChooseLanguageFilterViewController {
            visibleVC.showInfo()
        }
        
    }
    

}
