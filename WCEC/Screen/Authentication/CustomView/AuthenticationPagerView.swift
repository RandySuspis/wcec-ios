//
//  AuthenticationPagerView.swift
//  WCEC
//
//  Created by hnc on 5/7/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class AuthenticationPagerView: BaseTabPagerView {
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    
    override func setupView() {
        super.setupView()
        loginBtn.setTitle("Login".localized(), for: .normal)
        signUpBtn.setTitle("Sign Up".localized(), for: .normal)
    }
    override func tabButtonList() -> [UIButton] {
        self.isButtonEqual = true
        return [loginBtn,signUpBtn]
    }
    
    @IBAction func onClick(_ sender: UIButton) {
        onButtonClick(sender)
    }
}
