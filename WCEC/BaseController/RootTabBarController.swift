//
//  RootTabBarController.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Localize_Swift

class RootTabBarController: BaseTabBarController, UITabBarControllerDelegate {
    var connectionsViewController = ConnectionsViewController()
    var newFeedsViewController = NewfeedsViewController()
    var newsWCECController = NewsWCECViewController()
    var messagesViewController = MessagesViewController()
    var meViewController = MeViewController.initWithDefautlNib()
    var connectionsNav = BaseNavigationController()
    var newFeedsNav = BaseNavigationController()
    var newsWCECNav = BaseNavigationController()
    var messagesNav = BaseNavigationController()
    var meNav = BaseNavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(setupLocalized), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        connectionsViewController = ConnectionsViewController()
        newFeedsViewController = NewfeedsViewController()
        newsWCECController = NewsWCECViewController()
        messagesViewController = MessagesViewController()
        meViewController = MeViewController.initWithDefautlNib()
        
        connectionsNav = BaseNavigationController(rootViewController: connectionsViewController)
        newFeedsNav = BaseNavigationController(rootViewController: newFeedsViewController)
        newsWCECNav = BaseNavigationController(rootViewController: newsWCECController)
        messagesNav = BaseNavigationController(rootViewController: messagesViewController)
        meNav = BaseNavigationController(rootViewController: meViewController)
        setupLocalized()
        
        self.viewControllers = [connectionsNav, newFeedsNav, newsWCECNav, messagesNav, meNav]
        self.tabBar.isTranslucent = false
        self.delegate = self
        self.view.backgroundColor = AppColor.colorFadedWhiteBg()
        self.selectedIndex = 2;
    }
    
    @objc func setupLocalized() {
        let connectionsTabbarItem = UITabBarItem(title: "Connections".localized(), image: UIImage(named:"network")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named:"fill")?.withRenderingMode(.alwaysOriginal))
        let newFeedsTabbarItem = UITabBarItem(title: "Newsfeed".localized(), image: UIImage(named:"newsfeed")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named:"newsfeedAccent")?.withRenderingMode(.alwaysOriginal))
        let newsWCECTabbarItem = UITabBarItem(title: nil, image: UIImage(named:"navLogoInnactive")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named:"navLogoAccent")?.withRenderingMode(.alwaysOriginal))
        newsWCECTabbarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        let messagesTabbarItem = UITabBarItem(title: "Messages".localized(), image: UIImage(named:"message")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named:"messageAccent")?.withRenderingMode(.alwaysOriginal))
        let meTabbarItem = UITabBarItem(title: "Me".localized(), image: UIImage(named:"profile")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named:"meAccent")?.withRenderingMode(.alwaysOriginal))
        
        connectionsViewController.tabBarItem = connectionsTabbarItem
        newFeedsViewController.tabBarItem = newFeedsTabbarItem
        newsWCECController.tabBarItem = newsWCECTabbarItem
        messagesViewController.tabBarItem = messagesTabbarItem
        meViewController.tabBarItem = meTabbarItem
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if !viewController.isKind(of: NewsWCECViewController.self) {
            if DataManager.checkIsGuestUser() || DataManager.getUserToken().isEmpty {
                if self.selectedIndex != 2 {
                    if DataManager.getCurrentUserModel()?.status == .social{
                        let vc = CheckSocialBeMemberViewController()
                        vc.modalTransitionStyle = .crossDissolve
                        vc.modalPresentationStyle = .overCurrentContext
                        Constants.appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    } else  {
                        let vc = SubmittedBeAMemberViewController()
                        vc.modalTransitionStyle = .crossDissolve
                        vc.modalPresentationStyle = .overCurrentContext
                        Constants.appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                    }
                    Constants.appDelegate.tabbarController.selectedIndex = 2
                }
            }  else if !viewController.isKind(of: NewfeedsViewController.self) {
                NotificationCenter.default.post(name: .kScrollToTopListNewfeed,
                                                object: nil,
                                                userInfo: nil)
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if !viewController.isKind(of: NewsWCECViewController.self) {
            if DataManager.checkIsGuestUser() || DataManager.getUserToken().isEmpty {
                if DataManager.getCurrentUserModel()?.status == .social{
                    let vc = CheckSocialBeMemberViewController()
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overCurrentContext
                    Constants.appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                } else  {
                    let vc = SubmittedBeAMemberViewController()
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overCurrentContext
                    Constants.appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
}
