//
//  ResetPasswordViewController.swift
//  WCEC
//
//  Created by GEM on 5/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ResetPasswordViewController: BaseViewController {

    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var viewNewPW: CustomTextField!
    @IBOutlet weak var viewConfirmPW: CustomTextField!
    
    var activationCode: String?
    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.backBarItem(target: self, btnAction: #selector(backAction))
        
        viewNewPW.isSecure = true
        viewNewPW.rightImage = UIImage(named:"eyeInnactive")
        viewNewPW.delegate = self
        
        viewConfirmPW.isSecure = true
        viewConfirmPW.rightImage = UIImage(named:"eyeInnactive")
        viewConfirmPW.delegate = self
    }
    
    override func backAction() {
        Constants.appDelegate.setupAuthentication()
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Reset Password".localized()
        btnConfirm.setTitle("Confirm".localized(), for: .normal)
        viewNewPW.title = "Set New Password".localized()
        viewConfirmPW.title = "Confirm New Password".localized()
    }
    
    func verifyField() -> Bool {
        var pwd = viewNewPW.textField.text ?? ""
        pwd = pwd.trim()

        if  pwd == "" {
            self.alertWithTitle("Alert".localized(), message: "Please input your new password".localized())
            return false
        }
        
        if !pwd.isValidPassword() {
            self.alertWithTitle("Alert".localized(), message: "** Password Requirement **".localized())
            return false
        }
        
        if viewConfirmPW.textField.text == "" {
            self.alertWithTitle("Alert".localized(), message: "Please input confirm new password".localized())
            return false
        }
        
        if viewNewPW.textField.text != viewConfirmPW.textField.text {
            self.alertWithTitle("Alert".localized(), message: "The confirm password doesn't match!".localized())
            return false
        }
        
        if let msg = validateMaxCharacter("Set New Password".localized(),
                                          textCount: viewNewPW.textField.text!.count,
                                          numberMax: 255) {
            self.alertView("Alert".localized(), message: msg)
            return false
        }
        
        return true
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        guard verifyField() && (activationCode != nil) else {
            return
        }
        self.showHud()
        userService.doResetPassword(password: viewNewPW.text!,
                                  activationCode: activationCode!,
                                  complete: { (result) in
                                    self.hideHude()
                                    switch result {
                                    case .success(let response):
                                        print(response)
                                        showAlertAndWithAction(title: "Success".localized(),
                                                               message: "Your password has been reset successfully".localized(),
                                                               completeHanle: {
                                                                Constants.appDelegate.setupAuthentication()
                                        })
                                        break
                                    case .failure( let error):
                                        self.alertWithError(error)
                                        break
                                    }
        })
    }
}

extension ResetPasswordViewController: CustomTextFieldDelegate {
    
    func textFieldShowDropDown(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFielDidSelectRightButton(_ textField: UITextField, view: UIView) {
        if view == viewNewPW {
            viewNewPW.isSecure = !viewNewPW.isSecure!
            if viewNewPW.isSecure! {
                viewNewPW.rightImage = UIImage(named:"eyeInnactive")
            } else {
                viewNewPW.rightImage = UIImage(named:"eye")
            }
        } else if view == viewConfirmPW {
            viewConfirmPW.isSecure = !viewConfirmPW.isSecure!
            if viewConfirmPW.isSecure! {
                viewConfirmPW.rightImage = UIImage(named:"eyeInnactive")
            } else {
                viewConfirmPW.rightImage = UIImage(named:"eye")
            }
        }
    }
    
    func textFieldBeginEdit(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldEndEdit(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldReturn(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldDidSelectSearchOption(_ text: String, view: UIView) {
        
    }
    
}













