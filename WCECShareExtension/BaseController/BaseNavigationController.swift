//
//  BaseNavigationController.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        self.delegate = self
    }
    
    func setUp() {
        self.navigationBar.isOpaque = true
        self.navigationBar.isTranslucent = false
        let titleDict: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                       NSAttributedStringKey.font: AppFont.fontWithType(.bold, size: 16)]
        self.navigationBar.titleTextAttributes = titleDict as! [NSAttributedStringKey : Any]
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    class func initWithDefaultStyle(rootViewController: UIViewController!) -> BaseNavigationController {
        let nav = BaseNavigationController(rootViewController: rootViewController)
        nav.setUp()
        return nav
    }
    
}

extension BaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        if let currentVC = self.topViewController {
            let itemBack = UIBarButtonItem(title: "", style: .done, target: currentVC, action: nil)
            currentVC.navigationItem.backBarButtonItem = itemBack
        }
    }
}
