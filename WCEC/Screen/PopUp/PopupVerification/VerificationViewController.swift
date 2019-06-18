//
//  VerificationViewController.swift
//  WCEC
//
//  Created by GEM on 8/3/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class VerificationViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descOneLabel: UILabel!
    @IBOutlet weak var descTwoLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var gotoMainButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupLocalized() {
        
    }
    
    @IBAction func tapLogin(_ sender: Any) {
        Constants.appDelegate.setupAuthentication()
    }
    
    @IBAction func tapGotoMainPage(_ sender: Any) {
        Constants.appDelegate.setupRootViewController()
        Constants.appDelegate.tabbarController.selectedIndex = 2
    }
}
