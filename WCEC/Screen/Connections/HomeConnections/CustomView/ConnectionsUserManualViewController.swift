//
//  ConnectionsUserManualViewController.swift
//  WCEC
//
//  Created by GEM on 5/25/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ConnectionsUserManualViewController: BaseViewController {

    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var lblOne: UILabel!
    @IBOutlet weak var lblTwo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        viewOne.layer.masksToBounds = true
        viewOne.layer.cornerRadius = 3.0
        viewTwo.layer.masksToBounds = true
        viewTwo.layer.cornerRadius = 3.0
        btnOk.layer.masksToBounds = true
        btnOk.layer.cornerRadius = 3.0
    }
    
    override func setupLocalized() {
        btnOk.setTitle("OK, Got It".localized(), for: .normal)
        lblOne.text = "Tap Add button to connect".localized()
        lblTwo.text = "Tap on picture to view profile".localized()
    }

    @IBAction func onDissmiss(_ sender: Any) {
        dismiss(animated: true) {
            self.reloadCurrentUser()
        }
    }
    
}
