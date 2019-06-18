//
//  EnterOTPViewController.swift
//  WCEC
//
//  Created by GEM on 5/22/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class EnterOTPViewController: BaseViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var otpView: CustomTextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblDidntReceiveCode: UILabel!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var btnRetry: UIButton!
    
    var timer: Timer!
    var counterTime: Int = 60
    var fromType: RegistrationType = .beAMember
    var user: UserModel?
    var social_type: String?
    var social_id: String?
    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setupUI()
    }
    
    func setupUI() {
        otpView.textField.keyboardType = .phonePad
        
        btnSubmit.layer.cornerRadius = 3.0
        btnSubmit.layer.masksToBounds = true
        
        btnRetry.layer.cornerRadius = 3.0
        btnRetry.layer.masksToBounds = true
        btnRetry.layer.borderWidth = 1.0
        btnRetry.layer.borderColor = AppColor.colorOrange().cgColor
        
        btnRetry.isHidden = true
        
        startTimer()
    }
    
    func startTimer() {
        counterTime = 60
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
        timer.fire()
    }
    
    @objc func updateTimer() {
        lblTimer.text = "00:\(counterTime)"
        counterTime -= 1
        if counterTime == 0 {
            timer.invalidate()
            btnRetry.isHidden = false
            lblTimer.isHidden = true
        }
    }
    
    override func setupLocalized() {
        if let user = DataManager.getCurrentUserModel() {
            lblTitle.text = user.fullName
        } else {
            lblTitle.text = "(Name / E-mail)".localized()
        }
        lblDesc.text = "We sent you an OTP code to your mobile no. Please key in the code below.".localized()
        btnSubmit.setTitle("Submit".localized(), for: .normal)
        otpView.title = "Enter OTP".localized()
        lblDidntReceiveCode.text = "Didn't receive a code?".localized()
        btnRetry.setTitle("Retry".localized(), for: .normal)
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        guard otpView.text != "" else {
            alertWithTitle("Alert".localized(), message: "Please input otp".localized())
            return
        }
        guard let userModel = user else {
            return
        }
        
        self.showHud()
        userService.doVerifyOTP(otp: otpView.text!,
                                phone_number: userModel.phoneNumber,
                                phone_code: userModel.phoneCode) { (result) in
                                    self.hideHude()
                                    switch result {
                                    case .success(let response):
                                        DataManager.saveUserModel(response.data)
                                        if self.social_type != nil &&
                                            self.social_id != nil {
                                            if !response.data.token.isEmpty {
                                                DataManager.saveUserToken(response.data.token)
                                            }
                                            let vc = QuoteViewController()
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        } else if self.fromType == .setupIntro {
                                            self.navigationController?.popViewController(animated: true)
                                        } else if self.fromType == .beAMember {
                                            if !response.data.token.isEmpty {
                                                DataManager.saveUserToken(response.data.token)
                                            }
                                            let vc = SetPasswordViewController()
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        } else {
                                            if !response.data.token.isEmpty {
                                                DataManager.saveUserToken(response.data.token)
                                            }
                                            let vc = SetPasswordViewController()
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }
                                        break
                                    case .failure(let error):
                                        self.alertWithError(error)
                                        break
                                    }
        }
    }
    
    @IBAction func onRetry(_ sender: Any) {
        guard let userModel = user else {
            return
        }
        
        self.showHud()
        userService.doSendOTP(email: userModel.email,
                              social_type: social_type,
                              social_id: social_id,
                              phone_number: userModel.phoneNumber,
                              phone_code: userModel.phoneCode) { (result) in
                                self.hideHude()
                                switch result {
                                case .success(let response):
                                    showAlertAndWithAction(title: "Success".localized(),
                                                           message: "Resent OTP success, please check again".localized(),
                                                           completeHanle: {
                                                            self.btnRetry.isHidden = true
                                                            self.lblTimer.isHidden = false
                                                            self.startTimer()
                                    })
                                    break
                                case .failure(let error):
                                    self.alertWithError(error)
                                    break
                                }
        }
    }
    
}









