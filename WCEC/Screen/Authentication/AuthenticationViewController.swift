//
//  AuthenticationViewController.swift
//  WCEC
//
//  Created by hnc on 5/7/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class AuthenticationViewController: BasePagerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabPagerView.delegate = self
        self.pagerController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if DataManager.boolForKey(Constants.kGoToSignUp) {
            self.tabPagerView.moveTo(Page: 1)
            DataManager.save(boolValue: false, forKey: Constants.kGoToSignUp)
        }
    }
    
    override func setupData() -> [UIViewController] {
        let signInVC = SignInViewController()
        let signUpVC = SignUpViewController()
        
        return [signInVC, signUpVC]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension AuthenticationViewController: UIPageViewControllerDelegate {
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

extension AuthenticationViewController: BaseTabPagerViewDelegate {
    func baseTabPagerView(_ baseTabPagerView: BaseTabPagerView, didSelectAt index: Int) {
        let currentIndex = getIndex()
        if currentIndex < index {
            pagerController.setViewControllers([viewControllers[index]], direction: .forward, animated: true, completion: nil)
        } else {
            pagerController.setViewControllers([viewControllers[index]], direction: .reverse, animated: true, completion: nil)
        }
    }
}
