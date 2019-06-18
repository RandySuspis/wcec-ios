//
//  MeViewController.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class MeViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Me".localized()
    }
}
