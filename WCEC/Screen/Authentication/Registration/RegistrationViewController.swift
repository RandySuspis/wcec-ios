//
//  RegistrationViewController.swift
//  WCEC
//
//  Created by GEM on 8/3/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class RegistrationViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailAdressView: CustomTextField!
    @IBOutlet weak var firstNameView: CustomTextField!
    @IBOutlet weak var familyNameView: CustomTextField!
    @IBOutlet weak var birthdayView: CustomTextField!
    @IBOutlet weak var mobileView: CustomTextField!
    @IBOutlet weak var locationView: CustomTextField!
    @IBOutlet weak var reasonView: CustomTextView!
    @IBOutlet weak var sendRequestButton: UIButton!
    
    let userService = UserService()
    var countrySource: [CountryModel] = []
    var selectedCountry: CountryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if DataManager.checkIsGuestUser() && DataManager.getCurrentUserModel() != nil {
            bindingData()
        }
        getCoutries()
    }

    override func setupLocalized() {
        self.title = "Registration".localized()
        emailAdressView.title = "E-mail Adress".localized()
        firstNameView.title = "First Name".localized()
        familyNameView.title = "Family Name".localized()
        birthdayView.title = "Year of Birth".localized()
        mobileView.title = "Mobile No.".localized()
        locationView.title = "Location".localized()
        reasonView.title = "Where did you hear about us?".localized()
    }
    
    func setupUI() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.backBarItem(target: self, btnAction: #selector(regisBackAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.nextBarButton(target: self, selector: #selector(onSelectNextBarButton))
        mobileView.isShowPreTextField = true
        mobileView.delegate = self
        mobileView.preTextField.keyboardType = .phonePad
        mobileView.textField.keyboardType = .phonePad
        birthdayView.textField.keyboardType = .numberPad
        locationView.isSearchText = true
        locationView.delegate = self
    }
    
    func bindingData() {
        let user = DataManager.getCurrentUserModel()
        emailAdressView.text = user?.email
        firstNameView.text = user?.firstName
        familyNameView.text = user?.familyName
        if user?.birthYear.trim().count == 4 {
            birthdayView.textField.text = user?.birthYear
        }
    }
    
    func getCoutries() {
        userService.doSearchCountry(searchText: "") { (result) in
            switch result {
            case .success(let response):
                self.countrySource = response.data
                var dataSource = [String]()
                for model in self.countrySource {
                    dataSource.append(model.name)
                }
                self.locationView.searchDataSource = dataSource
                break
            case .failure( let error):
                #if DEBUG
                    print(error.localizedDescription)
                #endif
                break
            }
        }
    }
    
    ///MARK: Action
    @objc func onSelectNextBarButton() {
        view.endEditing(true)
        if verifyField() != "" {
            self.alertView("Alert".localized(), message: verifyField())
            return
        }
        self.showHud()
        if mobileView.preTextField.text?.first != "+" {
            mobileView.preTextField.text = "+" + mobileView.preTextField.text!
        }
        userService.doBeComeAMember(email: emailAdressView.textField.text!, firstName: firstNameView.textField.text!, lastName: familyNameView.textField.text!, birthYear: birthdayView.textField.text!, phoneCode: mobileView.preTextField.text!, phoneNumber: mobileView.textField.text!, countryId: (selectedCountry?.id)!, hearAboutUs: reasonView.textView.text) { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                DataManager.saveUserModel(response.data)
                DataManager.saveUserToken(response.data.token)
                guard let user = DataManager.getCurrentUserModel() else {
                    return
                }
                
                let myIndustryVC = MyIndustryViewController()
                self.navigationController?.pushViewController(myIndustryVC, animated: true)
                
                break
            case .failure( let error):
                guard let errorDiction = error._userInfo as? NSDictionary else {
                    self.alertDefault()
                    return
                }
                
                guard errorDiction["message"] != nil &&
                    errorDiction["message"] as! String != "" else {
                    self.alertDefault()
                    return
                }
                let message = error._userInfo!["message"] as? String
                
                if message?.lowercased().range(of: "e-mail") != nil && message?.lowercased().range(of: "submitted") != nil {
                    let vc = SubmittedBeAMemberViewController()
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overCurrentContext
                    Constants.appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
                } else {
                    self.alertWithError(error)
                }
                
                break
            }
        }
    }
    
    @objc func regisBackAction() {
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            let viewController = navController.viewControllers[navController.viewControllers.count - 2]
            if viewController.isKind(of: SignInViewController.self) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            Constants.appDelegate.setupAuthentication()
        }
    }
    
    ///MARK: Validate
    func verifyField() -> String {
        if emailAdressView.text?.trim() == "" || emailAdressView.text == nil {
            return "Please input your email.".localized()
        } else {
            if emailAdressView.text?.trim().isValidEmailAddress() == false {
                return "Wrong email format".localized()
            }
        }
        
        if firstNameView.textField.text == "" {
            return "Please input first name.".localized()
        }
        
        if let msg = validateMaxCharacter("First Name".localized(),
                                          textCount: firstNameView.textField.text!.count,
                                          numberMax: 255) {
            return msg
        }
        
        if familyNameView.textField.text == "" {
            return "Please input family name.".localized()
        }
        
        
        if let msg = validateMaxCharacter("Family Name".localized(),
                                          textCount: familyNameView.textField.text!.count,
                                          numberMax: 255) {
            return msg
        }
        
        if birthdayView.textField.text == "" {
            return "Please input year of birth.".localized()
        }
        
        if birthdayView.textField.text?.count != 4 {
            return "Please input year with format YYYY.".localized()
        }
        
        if  selectedCountry == nil ||
            selectedCountry?.name == "" ||
            locationView.searchTextField.text != selectedCountry?.name {
            return "Please select your country.".localized()
        }
        
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

        if reasonView.textView.text == "" {
            return "Please input Where did you hear about us.".localized()
        }
        
        if let msg = validateMaxCharacter("Where did you hear about us".localized(),
                                          textCount: reasonView.textView.text!.count,
                                          numberMax: 1000) {
            return msg
        }
        
        return ""
    }
}

//MARK: CustomTextFieldDelegate
extension RegistrationViewController: CustomTextFieldDelegate, UITextViewDelegate {
    
    func textFieldShowDropDown(_ textField: UITextField, view: UIView) {
//        setupPhoneCodeDropDown(view: textField)
//        phoneCodeDropdown.show()
    }
    
    func textFielDidSelectRightButton(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldBeginEdit(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldEndEdit(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldReturn(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldDidSelectSearchOption(_ text: String, view: UIView) {
        for model in countrySource {
            if model.name == text {
                selectedCountry = model
                self.mobileView.preTextField.text = selectedCountry?.phone
                break
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
        return numberOfChars < 1000;
    }
}

