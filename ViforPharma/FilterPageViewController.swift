//
//  FilterPageViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 1/7/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit

class FilterPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    weak var filterDelegate: FilterPageViewControllerDelegate?
    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return [self.newViewController("ChooseTaFilter"),
            self.newViewController("ChooseLanguageFilter")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(initialViewController)
        }
        
        filterDelegate?.filterPageViewController(self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self,
                viewControllerAfter: visibleViewController) {
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
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
                let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
                let nextViewController = orderedViewControllers[newIndex]
                scrollToViewController(nextViewController, direction: direction)
        }
    }
    
    fileprivate func newViewController(_ name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(name)ViewController")
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    fileprivate func scrollToViewController(_ viewController: UIViewController,
        direction: UIPageViewControllerNavigationDirection = .forward) {
            setViewControllers([viewController],
                direction: direction,
                animated: true,
                completion: { (finished) -> Void in
                    // Setting the view controller programmatically does not fire
                    // any delegate methods, so we have to manually notify the
                    // 'tutorialDelegate' of the new index.
                    self.notifyTutorialDelegateOfNewIndex()
            })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    fileprivate func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            filterDelegate?.filterPageViewController(self,
                                                         didUpdatePageIndex: index)
        }
    }
    
    // MARK: UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            self.notifyTutorialDelegateOfNewIndex()
        }
        
//        if completed {
//            infoButton.tag = 0
//            infoButton.image = UIImage(named: "inactive_info")
//            
//            // Show or hide view info
//            if let visibleVC = previousViewControllers.first as? ChooseTaFilterViewController {
//                visibleVC.hideInfo()
//            }
//            
//            if let visibleVC = previousViewControllers.first as? ChooseLanguageFilterViewController {
//                visibleVC.hideInfo()
//            }
//        }
    }
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
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
    
    func pageViewController(_ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
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

}

protocol FilterPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func filterPageViewController(_ filterPageViewController: FilterPageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func filterPageViewController(_ filterPageViewController: FilterPageViewController,
                                    didUpdatePageIndex index: Int)
    
}
