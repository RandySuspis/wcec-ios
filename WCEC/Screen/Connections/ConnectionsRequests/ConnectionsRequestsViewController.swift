//
//  ConnectionsRequestsViewController.swift
//  WCEC
//
//  Created by GEM on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ConnectionsRequestsViewController: BasePagerViewController {
    
    let connectionService = ConnectionsService()
    var isRefreshConnections = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabPagerView.delegate = self
        self.pagerController.delegate = self
        self.navigationItem.title = "Connection Requests".localized()
        connectionService.markSeenAll { (result) in
            switch result {
            case .success(_):
                if self.isRefreshConnections {
                    NotificationCenter.default.post(name: .kRefreshConnections,
                                                    object: nil,
                                                    userInfo: nil)
                }
                break
            case .failure(_):
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func setupData() -> [UIViewController] {
        let receivedVC = ReceivedViewController()
        let sentVC = SentViewController()
        
        return [receivedVC, sentVC]
    }
}

extension ConnectionsRequestsViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let index = getIndex(view: pendingViewControllers[0])
        tabPagerView.moveTo(Page: index)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed == false {
            let index = getIndex(view: previousViewControllers[0])
            tabPagerView.moveTo(Page: index)
        }
    }
}

extension ConnectionsRequestsViewController: BaseTabPagerViewDelegate {
    func baseTabPagerView(_ baseTabPagerView: BaseTabPagerView, didSelectAt index: Int) {
        let currentIndex = getIndex()
        if currentIndex < index {
            pagerController.setViewControllers([viewControllers[index]], direction: .forward, animated: true, completion: nil)
        } else {
            pagerController.setViewControllers([viewControllers[index]], direction: .reverse, animated: true, completion: nil)
        }
    }
}
