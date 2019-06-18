//
//  ChangePasswordViewController.swift
//  WCEC
//
//  Created by GEM on 6/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ChangePasswordViewController: BaseViewController {

    @IBOutlet weak var currentPassWordView: CustomTextField!
    @IBOutlet weak var newPassWordView: CustomTextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    var userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() 
    }

    override func setupLocalized() {
        self.navigationItem.title = "Change Password".localized()
        currentPassWordView.title = "Current password".localized()
        newPassWordView.title = "New password".localized()
        confirmButton.setTitle("Confirm".localized(), for: .normal)
    }
    
    func setupUI() {
        currentPassWordView.isSecure = true
        currentPassWordView.rightImage = UIImage(named:"eyeInnactive")
        currentPassWordView.delegate = self
        
        newPassWordView.isSecure = true
        newPassWordView.rightImage = UIImage(named:"eyeInnactive")
        newPassWordView.delegate = self
    }
    
    func verifyField() -> Bool {
        var pwd = newPassWordView.textField.text ?? ""
        pwd = pwd.trim()
        if currentPassWordView.textField.text == "" {
            self.alertWithTitle("Alert".localized(), message: "Please input your current password".localized())
            return false
        }
        if !pwd.isValidPassword() {
            self.alertWithTitle("Alert".localized(), message: "** Password Requirement **".localized())
            return false
        }
        
        return true
    }
    
    @IBAction func tapConfirm(_ sender: Any) {
        view.endEditing(true)
        guard verifyField() else { return }
        self.showHud()
        userService.doChangePassword(curerntPassword: currentPassWordView.textField.text!,
                                     newPassword: newPassWordView.textField.text!) { (result) in
                                        self.hideHude()
                                        switch result {
                                        case .success(_):
                                            let popup = PopupPassChanged.init(PopupPassChanged.classString())
                                            popup.delegate = self
                                            self.present(popup, animated: true, completion: nil)
//                                            showAlertAndWithAction(title: "Success".localized(),
//                                                                   message: "Your password has been changed successfully".localized(),
//                                                                   completeHanle: {
//                                            })
                                            break
                                        case .failure(let error):
                                            self.alertWithError(error)
                                            break
                                        }
        }
    }
}

extension ChangePasswordViewController: PopupPassChangedDelegate {
    
    func popupPassChangedDidTapOK() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ChangePasswordViewController: CustomTextFieldDelegate {
    
    func textFieldShowDropDown(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFielDidSelectRightButton(_ textField: UITextField, view: UIView) {
        if view == currentPassWordView {
            currentPassWordView.isSecure = !currentPassWordView.isSecure!
            if currentPassWordView.isSecure! {
                currentPassWordView.rightImage = UIImage(named:"eyeInnactive")
            } else {
                currentPassWordView.rightImage = UIImage(named:"eye")
            }
        } else if view == newPassWordView {
            newPassWordView.isSecure = !newPassWordView.isSecure!
            if newPassWordView.isSecure! {
                newPassWordView.rightImage = UIImage(named:"eyeInnactive")
            } else {
                newPassWordView.rightImage = UIImage(named:"eye")
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







