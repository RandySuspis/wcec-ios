//
//  BasePagerViewController.swift
//  WCEC
//
//  Created by hnc on 5/7/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class BasePagerViewController: BaseViewController {
    @IBOutlet weak var tabPagerView: BaseTabPagerView!
    @IBOutlet weak var pageView: UIView!
    
    lazy var pagerController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    internal var viewControllers = [UIViewController]()
    internal var currentViewIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func setupView() {
        viewControllers = setupData()
        self.addPagerController()
        reloadData()
        automaticallyAdjustsScrollViewInsets = false
    }
    
    func removeSwipeGesture(){
        for view in pagerController.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }
    
    func setupData() -> [UIViewController] {
        fatalError("Must be override")
    }
    
    func addPagerController() {
        self.pagerController.dataSource = self
        self.addChildViewController(pagerController)
        self.pagerController.view.frame.size = pageView.frame.size
        pagerController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
        pageView.addSubview(pagerController.view)
    }
    
    func reloadData() {
    }
    
}

extension BasePagerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllers.index(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return nil
        }

        guard viewControllers.count > previousIndex else {
            return nil
        }

        return viewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = viewControllers.index(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = viewControllers.count

        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return viewControllers[nextIndex]
    }

    func getIndex() -> Int {
        if let firstView = pagerController.viewControllers?.first,
            let index = viewControllers.index(of: firstView) {
            return index
        }
        return 0
    }

    func getIndex(view: UIViewController) -> Int {
        if let index = viewControllers.index(of: view) {
            return index
        }
        return 0
    }
}

