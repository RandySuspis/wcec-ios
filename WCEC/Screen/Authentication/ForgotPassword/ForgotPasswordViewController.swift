//
//  ForgotPasswordViewController.swift
//  WCEC
//
//  Created by GEM on 5/28/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var emailView: CustomTextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        btnSend.layer.cornerRadius = 3.0
        btnSend.layer.masksToBounds = true
        
        btnClose.layer.cornerRadius = 3.0
        btnClose.layer.masksToBounds = true
        btnClose.layer.borderWidth = 1.0
        btnClose.layer.borderColor = AppColor.colorOrange().cgColor
    }
    
    override func setupLocalized() {
        lblTitle.text = "Forgot Password".localized()
        lblDesc.text = "Please enter your e-mail below to reset your password".localized()
        emailView.title = "E-mail Address".localized()
        btnSend.setTitle("Send".localized(), for: .normal)
        btnClose.setTitle("Close".localized(), for: .normal)
    }
    
    @IBAction func onSend(_ sender: Any) {
        guard verifyField() else {
            return
        }
        self.showHud()
        userService.doForgotPassword(email: emailView.text!) { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                print(response)
                let popupRequest = PopupSuccessForgotPWViewController.init(PopupSuccessForgotPWViewController.classString())
                self.present(popupRequest, animated: true, completion: nil)
                break
            case .failure( let error):
                self.alertWithError(error)
                break
            }
        }
    }
    
    func verifyField() -> Bool {
        if let msg = validateMaxCharacter("E-mail Address".localized(),
                                          textCount: emailView.textField.text!.count,
                                          numberMax: 255) {
            self.alertView("Alert".localized(), message: msg)
            return false
        }
        
        if emailView.textField.text?.trim() == "" || emailView.textField.text == nil {
            self.alertView("Alert".localized(), message: "Please input your email.".localized())
            return false
        } else if emailView.textField.text?.trim().isValidEmailAddress() == false {
            self.alertView("Alert".localized(), message: "Wrong email format".localized())
            return false
        }
        
        return true
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
