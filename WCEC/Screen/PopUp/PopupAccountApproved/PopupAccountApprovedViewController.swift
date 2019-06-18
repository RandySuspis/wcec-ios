//
//  PopupAccountApprovedViewController.swift
//  WCEC
//
//  Created by hnc on 8/24/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class PopupAccountApprovedViewController: BaseViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func onSelectLogin(_ sender: Any) {
        Constants.appDelegate.setupAuthentication()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
