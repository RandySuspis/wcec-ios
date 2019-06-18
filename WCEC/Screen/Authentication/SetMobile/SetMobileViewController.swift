//
//  SetMobileViewController.swift
//  WCEC
//
//  Created by GEM on 5/22/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class SetMobileViewController: BaseViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var mobileView: CustomTextField!
    @IBOutlet weak var btnSend: UIButton!
    
    var countrySource: [CountryModel] = []
    var emailRegister: String?
    var social_type: String?
    var social_id: String?
    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getCoutries()
        
        if !DataManager.getUserToken().isEmpty {
            if let user = DataManager.getCurrentUserModel() {
                if !user.phoneCode.isEmpty {
                    self.mobileView.preTextField.text = user.phoneCode
                }
                
                if !user.phoneNumber.isEmpty {
                    self.mobileView.textField.text = user.phoneNumber
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func setupLocalized() {
        if let user = DataManager.getCurrentUserModel() {
            lblTitle.text = user.fullName
        } else {
            lblTitle.text = "(Name / E-mail)".localized()
        }
        lblDesc.text = "Thank you for joining us.\nFirst, we need to verify your mobile no.".localized()
        btnSend.setTitle("Send OTP".localized(), for: .normal)
        mobileView.title = "Country Code".localized()
        mobileView.secondTitle = "Mobile No.".localized()
    }
    
    func setupUI() {
        btnSend.backgroundColor = AppColor.colorLipStick()
        btnSend.layer.cornerRadius = 3.0
        btnSend.layer.masksToBounds = true
        mobileView.isShowPreTextField = true
        mobileView.delegate = self
        mobileView.preTextField.keyboardType = .phonePad
        mobileView.textField.keyboardType = .phonePad
        
    }
    
    @IBAction func onSend(_ sender: Any) {
        if verifyField() != "" {
            alertView("Alert".localized(), message: verifyField())
        } else {
            self.showHud()
            if mobileView.preTextField.text?.first != "+" {
                mobileView.preTextField.text = "+" + mobileView.preTextField.text!
            }
            userService.doSendOTP(email: emailRegister,
                                  social_type: social_type,
                                  social_id: social_id,
                                  phone_number: mobileView.textField.text!,
                                  phone_code: mobileView.preTextField.text!,
                                  complete: { (result) in
                                    self.hideHude()
                                    switch result {
                                    case .success(let response):
                                        let vc = EnterOTPViewController()
                                        vc.user = response.data
                                        vc.social_type = self.social_type
                                        vc.social_id = self.social_id
                                        self.navigationController?.pushViewController(vc, animated: true)
                                        break
                                    case .failure(let error):
                                        self.alertWithError(error)
                                        break
                                    }
            })
        }
    }
    
    func getCoutries() {
        userService.doSearchCountry(searchText: "") { (result) in
            switch result {
            case .success(let response):
                self.countrySource = response.data
                break
            case .failure( let error):
                #if DEBUG
                    print(error.localizedDescription)
                #endif
                break
            }
        }
    }
    
    func verifyField() -> String {
        var isValidCountryPhoneCode: Bool = false
        for countryModel in countrySource {
            if countryModel.phone.replacingOccurrences(of: "+", with: "") == mobileView.preTextField.text?.replacingOccurrences(of: "+", with: "") {
                isValidCountryPhoneCode = true
                break
            }
        }
        
        if !isValidCountryPhoneCode || mobileView.preTextField.text == ""{
            return "Please input valid phone code.".localized()
        }
        
        let numberOfMobileNo: Int = mobileView.textField.text?.count ?? 0
        
        if mobileView.textField.text?.isValidPhoneNumber() == false || numberOfMobileNo <= 0 || numberOfMobileNo > 14{
            return "Please input valid mobile no.".localized()
        }
        
        return ""
    }
}

extension SetMobileViewController: CustomTextFieldDelegate {
    func textFielDidSelectRightButton(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldShowDropDown(_ textField: UITextField, view: UIView) {
        
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
