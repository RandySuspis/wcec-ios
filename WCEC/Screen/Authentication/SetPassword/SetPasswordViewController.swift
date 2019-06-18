//
//  SetPasswordViewController.swift
//  WCEC
//
//  Created by hnc on 5/7/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import AMPopTip
import TPKeyboardAvoiding

class SetPasswordViewController: BaseViewController {
    @IBOutlet weak var passwordViewContainer: CustomTextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var titleDescriptionLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var containerView: TPKeyboardAvoidingScrollView!
    let userService = UserService()
    
    var activationCode: String = ""
    var popTip = PopTip()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordViewContainer.isSecure = true
        passwordViewContainer.delegate = self
        passwordViewContainer.rightImage = UIImage(named:"eyeInnactive")
        confirmButton.disabled()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func backAction() {
        Constants.appDelegate.setupAuthentication()
    }
    
    override func setupLocalized() {
        emailLabel.text = "(Name / E-mail)".localized()
        titleDescriptionLabel.text = "Thank you for joining us. \nPlease set up your password.".localized()
        passwordViewContainer.title = "Set your password".localized()
        passwordViewContainer.textPlaceHolder = "Enter password".localized()
    }
    
    ///Mark: IBAction
    @IBAction func onSelectConfirm(_ sender: Any) {
        guard let currentUser = DataManager.getCurrentUserModel() else {
            return
        }
        if verifyField() {
            self.showHud()
            userService.doSetPassword(password: passwordViewContainer.textField.text!,
                                      userId: currentUser.id, complete: { (result) in
                                        self.hideHude()
                                        switch result {
                                        case .success(let response):
                                            DataManager.saveUserModel(response.data)
                                            let vc = QuoteViewController()
                                            self.navigationController?.pushViewController(vc, animated: true)
                                            break
                                        case .failure( let error):
                                            self.alertWithError(error)
                                            break
                                        }
            })
        }
    }
    
    func verifyField() -> Bool {
        var pwd = passwordViewContainer.textField.text ?? ""
        pwd = pwd.trim()

        if !pwd.isValidPassword() {
            self.alertWithTitle("Alert".localized(), message: "** Password Requirement **".localized())
            return false
        }
        
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SetPasswordViewController: CustomTextFieldDelegate {
    func textFieldShowDropDown(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFielDidSelectRightButton(_ textField: UITextField, view: UIView) {
        passwordViewContainer.isSecure = !passwordViewContainer.isSecure!
        if passwordViewContainer.isSecure! {
            passwordViewContainer.rightImage = UIImage(named:"eyeInnactive")
        } else {
            passwordViewContainer.rightImage = UIImage(named:"eye")
        }
    }
    
    func textFieldEndEdit(_ textField: UITextField, view: UIView) {
        popTip.hide(forced: true)
        if textField.text != "" {
            confirmButton.enabled()
        } else {
            confirmButton.disabled()
        }
    }
    
    func textFieldBeginEdit(_ textField: UITextField, view: UIView) {
        popTip = PopTip()
        popTip.bubbleColor = UIColor.white
        popTip.borderWidth = 1.0
        popTip.borderColor = AppColor.colorBorderBlack()
        popTip.textColor = AppColor.colorTextField()
        let customView = UIView(frame: CGRect(x: popTip.frame.origin.x, y: popTip.frame.origin.y, width: self.passwordViewContainer.frame.size.width, height: 120))
        let label = UILabel()
        label.numberOfLines = 0
        label.frame = CGRect(x: 0, y: 0, width: customView.frame.width, height: customView.frame.height)
        label.textColor = AppColor.colorTextField()
        label.font = AppFont.fontWithType(.regular, size: 14.0)
        label.text = "** Password Requirement **".localized()
        customView.addSubview(label)
        self.popTip.show(customView: customView, direction: .down, in: containerView, from: self.passwordViewContainer.frame)
        
        popTip.tapOutsideHandler = { popTip in
            textField.endEditing(true)
        }
    }
    
    func textFieldReturn(_ textField: UITextField, view: UIView) {
        textField.endEditing(true)
    }
    
    func textFieldDidSelectSearchOption(_ text: String, view: UIView) {
        
    }
}
