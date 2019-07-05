//
//  SetupIntroViewController.swift
//  WCEC
//
//  Created by hnc on 5/9/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import DropDown
import Kingfisher
import CropViewController
import Localize_Swift

class SetupIntroViewController: BaseViewController {
    @IBOutlet weak var fisrtNameViewContainer: CustomTextField!
    @IBOutlet weak var familyNameContainer: CustomTextField!
    @IBOutlet weak var yearOfBirthViewContainer: CustomTextField!
    @IBOutlet weak var mobileNoViewContainer: CustomTextField!
    @IBOutlet weak var locationViewContainer: CustomTextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var shortBioViewContainer: CustomTextView!
    
    let phoneCodeDropdown = DropDown()
    let userService = UserService()
    var countrySource: [CountryModel] = []
    var selectedCountry: CountryModel?
    var avatarId: Int = -1
    let mediaService = MediaService()
    var isFromMyProfile = false
    var isRetryUploadAvatar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getCoutries()
        bindData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupUI() {
        mobileNoViewContainer.isShowPreTextField = true
        mobileNoViewContainer.delegate = self
        mobileNoViewContainer.preTextField.keyboardType = .phonePad
        mobileNoViewContainer.textField.keyboardType = .phonePad
        
        locationViewContainer.isSearchText = true
        locationViewContainer.delegate = self
//        shortBioViewContainer.textView.delegate = self
        yearOfBirthViewContainer.textField.keyboardType = .numberPad
        
        if isFromMyProfile {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.saveBarButton(target: self, selector: #selector(onSelectNextBarButton))
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.nextBarButton(target: self, selector: #selector(onSelectNextBarButton))
        }
    }
    
    func bindData() {
        if let userModel = DataManager.getCurrentUserModel() {
            guard userModel.status == .activate || userModel.status == .guest || userModel.status == .social else {
                let vc = SetPasswordViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            fisrtNameViewContainer.textField.text = userModel.firstName
            familyNameContainer.textField.text = userModel.familyName
            if userModel.birthYear != "0" {
                yearOfBirthViewContainer.textField.text = userModel.birthYear
            }
            mobileNoViewContainer.preTextField.text = userModel.phoneCode
            mobileNoViewContainer.textField.text = userModel.phoneNumber
            shortBioViewContainer.textView.text = userModel.shortBio
            if userModel.avatar.file_url == "" {
                if DataManager.getSavedImage(named: Constants.kSocialAvatar) != nil {
                    self.showHud()
                    self.profileImageView.image = DataManager.getSavedImage(named: Constants.kSocialAvatar)!
                    self.uploadAvatar();
                } else {
                    profileImageView.image = UIImage(named: "placeholder")
                }
            } else {
                let url = URL(string: userModel.avatar.file_url)
                avatarId = userModel.avatar.avatarId
                profileImageView.kf.setImage(with: url)
            }
            if userModel.country.name != "" {
                selectedCountry = userModel.country
                locationViewContainer.searchTextField.text = userModel.country.name
            }
        }
    }
    
    func uploadAvatar() {
        self.mediaService.uploadImage(image: DataManager.getSavedImage(named: Constants.kSocialAvatar)!, { (result) in
            self.hideHude()
            switch result {
            case .failure(let error):
                if !self.isRetryUploadAvatar {
                    self.uploadAvatar()
                    self.isRetryUploadAvatar = true
                } else {
                    if let errorDiction = error._userInfo as? NSDictionary {
                        self.alertWithTitle(errorDiction["title"] as? String, message: errorDiction["message"] as? String)
                    }
                }
            case .success(let response):
                #if DEBUG
                    print(response.data)
                #endif
                self.avatarId = response.data.avatarId
            }
        })
    }
    
    func getCoutries() {
        userService.doSearchCountry(searchText: "") { (result) in
            switch result {
            case .success(let response):
                self.countrySource = response.data
                var dataSource = [String]()
                Localize.setCurrentLanguage("zh-Hans")
                for model in self.countrySource {
                    let countryCh = model.name.localized();
                    if (model.name != countryCh){
                        dataSource.append(model.name + " - " + countryCh)
                    }else{
                        dataSource.append(model.name)
                    }
                    
                }
                Localize.setCurrentLanguage("en")
                self.locationViewContainer.searchDataSource = dataSource
                break
            case .failure( let error):
                #if DEBUG
                print(error.localizedDescription)
                #endif
                break
            }
        }
    }
    
    override func setupLocalized() {
        self.navigationItem.title = isFromMyProfile ? "Edit Intro".localized() : "Intro".localized()
        fisrtNameViewContainer.title = "First Name".localized()
        familyNameContainer.title = "Family Name".localized()
        yearOfBirthViewContainer.title = "Year of Birth".localized()
        mobileNoViewContainer.title = "Mobile No.".localized()
        locationViewContainer.title = "Location".localized()
        shortBioViewContainer.title = "Short Bio".localized()
    }
    
    func setupPhoneCodeDropDown(view: UIView) {
        var countries: [String] = []
        
        for country in Countries.getAllCountries() {
            if let phone = country.phoneExtension {
                countries.append("+" + phone)
            }
        }
        
        phoneCodeDropdown.dataSource = countries
        phoneCodeDropdown.anchorView = view
        phoneCodeDropdown.width = view.frame.size.width
        phoneCodeDropdown.bottomOffset = CGPoint(x: 0, y: view.frame.size.height)
        phoneCodeDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            #if DEBUG
                print("Selected item: \(item) at index: \(index)")
            #endif
            self.mobileNoViewContainer.preText = item
        }
    }
    
    /// Mark: IBAction
    @objc func onSelectNextBarButton() {
        view.endEditing(true)
        
        if verifyField() != "" {
            self.alertView("Alert".localized(), message: verifyField())
            return
        }
        self.showHud()
        if mobileNoViewContainer.preTextField.text?.first != "+" {
            mobileNoViewContainer.preTextField.text = "+" + mobileNoViewContainer.preTextField.text!
        }
        userService.doUpdateProfile(userId: (DataManager.getCurrentUserModel()?.id)!, section: "intro", firstName: fisrtNameViewContainer.textField.text!, lastName: familyNameContainer.textField.text!, birthYear: yearOfBirthViewContainer.textField.text!, phoneCode: mobileNoViewContainer.preTextField.text!, phoneNumber: mobileNoViewContainer.textField.text!, countryId: (selectedCountry?.id)!, shortBio: shortBioViewContainer.textView.text!, avatarId: avatarId) { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                DataManager.saveUserModel(response.data)
                guard let user = DataManager.getCurrentUserModel() else {
                    return
                }
                if  user.phoneCode != "" &&
                    user.phoneNumber != "" &&
                    (user.phoneCode != self.mobileNoViewContainer.preTextField.text! ||
                    user.phoneNumber != self.mobileNoViewContainer.textField.text!) {
                    self.sendOTP(user: user)
                } else {
                    if self.isFromMyProfile {
                        NotificationCenter.default.post(name: .kRefreshMyProfile, object: nil, userInfo: nil)
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        let myIndustryVC = MyIndustryViewController()
                        self.navigationController?.pushViewController(myIndustryVC, animated: true)
                    }
                }
                break
            case .failure( let error):
                self.alertWithError(error)
                break
            }
        }
    }
    
    func sendOTP(user: UserModel) {
        if mobileNoViewContainer.preTextField.text?.first != "+" {
            mobileNoViewContainer.preTextField.text = "+" + mobileNoViewContainer.preTextField.text!
        }
        userService.doSendOTP(email: nil,
                              social_type: nil,
                              social_id: nil,
                              phone_number: self.mobileNoViewContainer.textField.text!,
                              phone_code: mobileNoViewContainer.preTextField.text!,
                              complete: { (result) in
                                self.hideHude()
                                switch result {
                                case .success(let response):
                                    let vc = EnterOTPViewController()
                                    vc.user = response.data
                                    vc.fromType = .setupIntro
                                    self.hidesBottomBarWhenPushed = true
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    break
                                case .failure(let error):
                                    self.alertWithError(error)
                                    break
                                }
        })
    }
    
    func verifyField() -> String {
        if fisrtNameViewContainer.textField.text == "" {
            return "Please input first name.".localized()
        }
        
        if let msg = validateMaxCharacter("First Name".localized(),
                                          textCount: fisrtNameViewContainer.textField.text!.count,
                                          numberMax: 255) {
            return msg
        }
        
        if familyNameContainer.textField.text == "" {
            return "Please input family name.".localized()
        }
        
        
        if let msg = validateMaxCharacter("Family Name".localized(),
                                          textCount: familyNameContainer.textField.text!.count,
                                          numberMax: 255) {
            return msg
        }
        
        if yearOfBirthViewContainer.textField.text == "" {
            return "Please input year of birth.".localized()
        }
        
        if yearOfBirthViewContainer.textField.text?.count != 4 {
            return "Please input year with format YYYY.".localized()
        }
        
        if  selectedCountry == nil ||
            selectedCountry?.name == "" ||
            locationViewContainer.searchTextField.text != selectedCountry?.name {
            return "Please select your country.".localized()
        }
        
        var isValidCountryPhoneCode: Bool = false
        for countryModel in countrySource {
            if countryModel.phone.replacingOccurrences(of: "+", with: "") == mobileNoViewContainer.preTextField.text?.replacingOccurrences(of: "+", with: "") {
                isValidCountryPhoneCode = true
                break
            }
        }
        
        if !isValidCountryPhoneCode || mobileNoViewContainer.preTextField.text == ""{
            return "Please input valid phone code.".localized()
        }
        
        let numberOfMobileNo: Int = mobileNoViewContainer.textField.text?.count ?? 0
        
        if mobileNoViewContainer.textField.text?.isValidPhoneNumber() == false || numberOfMobileNo <= 0 || numberOfMobileNo > 14{
            return "Please input valid mobile no.".localized()
        }
        
        if shortBioViewContainer.textView.text == "" {
            return "Please input short bio.".localized()
        }
        
        if let msg = validateMaxCharacter("Short Bio".localized(),
                                          textCount: shortBioViewContainer.textView.text!.count,
                                          numberMax: 1000) {
            return msg
        }
        
        if avatarId == -1 {
            return "Please setup your profile picture.".localized()
        }
        
        return ""
    }
    
    @IBAction func onSelectPhoto(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Select Image".localized(), preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera".localized(), style: .default) { (action) in
            self.showPickerImage(fromGallery: false)
        }
        let galleryAction = UIAlertAction(title: "Collection".localized(), style: .default) { (action) in
            self.showPickerImage(fromGallery: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel) { (action) in
        }
        
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showPickerImage(fromGallery: Bool) {
        let imagePicker = UIImagePickerController()
        view.endEditing(true)
        imagePicker.delegate = self
        if (fromGallery) {
            imagePicker.sourceType = .photoLibrary
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
            } else {
                self.alertWithTitle("Error".localized(), message: "Camera not available. Please try again.".localized())
                return
            }
        }
        imagePicker.modalPresentationStyle = .overCurrentContext
        present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: UIImagePickerControllerDelegate
extension SetupIntroViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        var pickedImage : UIImage!
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            pickedImage = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImage = image
        }
        let cropViewController = CropViewController(image: pickedImage)
        cropViewController.delegate = self
        cropViewController.modalPresentationStyle = .currentContext
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        // add image to array image and binding data
        self.showHud()
        self.mediaService.uploadImage(image: image.fixedOrientation(), { (result) in
            self.hideHude()
            switch result {
            case .failure(let error):
                self.alertWithError(error)
                break
            case .success(let response):
                #if DEBUG
                    print(response.data)
                #endif
                self.avatarId = response.data.avatarId
                self.profileImageView.image = image
                break
            }
        })
    }
}

//MARK: CustomTextFieldDelegate
extension SetupIntroViewController: CustomTextFieldDelegate, UITextViewDelegate {
    func textFieldShowDropDown(_ textField: UITextField, view: UIView) {
        setupPhoneCodeDropDown(view: textField)
        phoneCodeDropdown.show()
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
                self.mobileNoViewContainer.preTextField.text = selectedCountry?.phone
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
