//
//  OccupationViewController.swift
//  WCEC
//
//  Created by GEM on 5/21/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import Localize_Swift

class OccupationViewController: BaseViewController {
    @IBOutlet weak var jobView: CustomTextField!
    @IBOutlet weak var companyView: CustomTextField!
    @IBOutlet weak var hqLocationView: CustomTextField!
    @IBOutlet weak var currentLocationView: CustomTextField!
    @IBOutlet weak var dateFromView: CustomDateView!
    @IBOutlet weak var dateToView: CustomDateView!
    @IBOutlet weak var descView: CustomTextView!
    @IBOutlet weak var contentView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var sendRequestButton: UIButton! //using for case submit be a member request
    
    fileprivate var pickerFrom: SMDatePicker = SMDatePicker()
    fileprivate var pickerTo: SMDatePicker = SMDatePicker()
    let userService = UserService()
    var countrySource: [CountryModel] = []
    var jobTitleSource: [String] = []
    var hqCountrySelected: CountryModel?
    var currentCountrySelected: CountryModel?
    var isFromMyProfile = false
    var currentUserOccupation: OccupationModel? {
        didSet {
            guard let arr = currentUserOccupation?.begin_date.components(separatedBy: " ") else { return }
            guard arr.count > 1 else { return }
            monthSelected = arr[0].getIntFromShortMonthSymbols()
            yearSelected = Int(arr[1])
        }
    }
    var monthSelected: Int?
    var yearSelected: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindData()
        setupUI()
        getJobTitles()
        getCoutries()
    }
    
    func setupUI() {
        dateFromView.delegate = self
        dateToView.delegate = self
        dateToView.date = "Present".localized()
        dateToView.imgDate.isHidden = true
        
        pickerFrom.delegate = self
        pickerFrom.pickerMode = .date
        pickerFrom.title = TypeDateView.from.rawValue
        
        pickerTo.delegate = self
        pickerTo.pickerMode = .date
        pickerTo.title = TypeDateView.to.rawValue
        
        jobView.delegate = self
        companyView.delegate = self
        hqLocationView.delegate = self
        currentLocationView.delegate = self
        
        hqLocationView.isSearchText = true
        jobView.isSearchText = true
        currentLocationView.isSearchText = true
        if isFromMyProfile {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.saveBarButton(target: self, selector: #selector(onSelectNextBarButton))
        } else {
            if !DataManager.checkIsGuestUser() {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.nextBarButton(target: self, selector: #selector(onSelectNextBarButton))
                sendRequestButton.isHidden = true
            } else {
                self.navigationItem.rightBarButtonItem = nil
                sendRequestButton.isHidden = false
            }
        }
        
        guard let currentOccupation = currentUserOccupation else { return }
        jobView.searchTextField.text = currentOccupation.job_title
        companyView.textField.text = currentOccupation.company_name
        hqLocationView.searchTextField.text = currentOccupation.hq_location.name
        currentLocationView.searchTextField.text = currentOccupation.current_location.name
        dateFromView.date = currentOccupation.begin_date
        descView.text = currentOccupation.desc
        hqCountrySelected = currentOccupation.hq_location
        currentCountrySelected = currentOccupation.current_location
    }
    
    func bindData() {
        if let userModel = DataManager.getCurrentUserModel() {
            if userModel.occupations.count > 0 {
                if let occupation = DataManager.getCurrentUserModel()?.occupations.first {
                    self.currentUserOccupation = occupation
                    setupUI()
                }
            }
        }
    }

    override func setupLocalized() {
        self.title = isFromMyProfile ? "Edit Occupation".localized() : "Current Occupation".localized()
        jobView.title = "Job Title".localized()
        companyView.title = "Company Name".localized()
        hqLocationView.title = "HQ Location".localized()
        currentLocationView.title = "Current Location".localized()
        dateFromView.title = "From".localized()
        dateToView.title = "To".localized()
        descView.title = "Description".localized()
        dateToView.date = "Present".localized()
    }
    
    func getJobTitles() {
        userService.doSearchJobTitles(searchText: "") { (result) in
            switch result {
            case .success(let response):
                self.jobView.searchDataSource = response.data
                self.jobTitleSource = response.data
                break
            case .failure(let error):
                #if DEBUG
                    print(error.localizedDescription)
                #endif
                break
            }
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
                self.hqLocationView.searchDataSource = dataSource
                self.currentLocationView.searchDataSource = dataSource
                break
            case .failure( let error):
                #if DEBUG
                    print(error.localizedDescription)
                #endif
                break
            }
        }
    }
    
    
    @IBAction func onSelectSendRequestButton(_ sender: Any) {
        self.submit()
    }
    
    @objc func onSelectNextBarButton() {
        self.submit()
    }
    
    func submit() {
        view.endEditing(true)
        if verifyField() != "" {
            self.alertView("Alert".localized(), message: verifyField())
            return
        }
        guard let month = monthSelected,
            let year = yearSelected else {
                self.alertView("Alert".localized(), message: "Please select from date".localized())
                return
        }
        self.showHud()
        userService.doUpdateOccupation(userId: (DataManager.getCurrentUserModel()?.id)!,
                                       job_title: jobView.searchTextField.text!,
                                       hq_location: hqCountrySelected!.id,
                                       current_location: currentCountrySelected!.id,
                                       company_name: companyView.textField.text!,
                                       begin_date: "\(month)/\(year)",
            is_current: 1,
            description: descView.textView.text!,
            occupationId: currentUserOccupation?.id) { (result) in
                self.hideHude()
                switch result {
                case .success(let response):
                    DataManager.saveUserModel(response.data)
                    if DataManager.checkIsGuestUser() {
                        let vc = VerificationViewController()
                        vc.modalTransitionStyle = .crossDissolve
                        vc.modalPresentationStyle = .overCurrentContext
                        self.present(vc, animated: true, completion: nil)
                    } else {
                        if self.isFromMyProfile {
                            NotificationCenter.default.post(name: .kRefreshMyProfile,
                                                            object: nil,
                                                            userInfo: nil)
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            Constants.appDelegate.setupRootViewController()
                            Localize.setCurrentLanguage("en")
                        }
                    }
                    break
                case .failure( let error):
                    self.alertWithError(error)
                    break
                }
        }
    }
    
    func verifyField() -> String {
        if jobView.searchTextField.text == "" ||
           !jobTitleSource.contains(jobView.searchTextField.text!){
            return "Please select job title.".localized()
        }
        
        if companyView.textField.text == "" {
            return "Please input company name.".localized()
        }
        
        if let msg = validateMaxCharacter("Company Name".localized(),
                                          textCount: companyView.textField.text!.count,
                                          numberMax: 255) {
            return msg
        }
        
        if  hqCountrySelected == nil ||
            hqCountrySelected?.name == "" ||
            hqLocationView.searchTextField.text != hqCountrySelected?.name {
            return "Please select hq location.".localized()
        }
        
        if  currentCountrySelected == nil ||
            currentCountrySelected?.name == "" ||
            currentLocationView.searchTextField.text != currentCountrySelected?.name {
            return "Please select current location.".localized()
        }
        
        if  dateFromView.date == "" ||
            dateFromView.date == nil {
            return "Please select from date".localized()
        }
        
        if descView.textView.text == "" {
            return "Please input description.".localized()
        }
        
        if let msg = validateMaxCharacter("Description".localized(),
                                          textCount: descView.textView.text!.count,
                                          numberMax: 1000) {
            return msg
        }
        
        return ""
    }
}

extension OccupationViewController: CustomDateViewDelegate {
    func didSelectView(title: String) {
        if title == TypeDateView.from.rawValue {
            dateFromView.isHightLight = true
            pickerFrom.showPickerInView(view, animated: true)
        }
    }
}

extension OccupationViewController: SMDatePickerDelegate {
    func datePickerWillAppear(_ picker: SMDatePicker) {
        contentView.contentOffset = CGPoint(x: 0, y: 300)
    }
    
    func datePickerWillDisappear(_ picker: SMDatePicker) {
        contentView.contentOffset = CGPoint(x: 0, y: 0)
        dateFromView.isHightLight = false
        dateToView.isHightLight = false
    }
    
    func datePicker(_ picker: SMDatePicker, month: Int, year: Int) {
        monthSelected = month
        yearSelected = year
        if picker.title == TypeDateView.from.rawValue {
            if Constants.currentYearInt <= year &&
                Constants.currentMonthInt < month {
                dateFromView.date = ""
                self.alertView("Alert".localized(), message: "Please select from date valid")
                return
            }
            let monthString = DateFormatter().shortMonthSymbols[(month - 1)]
            dateFromView.date = monthString + " " + String(year)
        } else if picker.title == TypeDateView.to.rawValue {
            let monthString = DateFormatter().shortMonthSymbols[(month - 1)]
            dateToView.date = monthString + " " + String(year)
        }
    }
}

extension OccupationViewController: CustomTextFieldDelegate {
    func textFieldReturn(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldShowDropDown(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFielDidSelectRightButton(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldBeginEdit(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldEndEdit(_ textField: UITextField, view: UIView) {
        
    }
    
    func textFieldDidSelectSearchOption(_ text: String, view: UIView) {
        switch view {
        case hqLocationView:
            for model in countrySource {
                if model.name == text {
                    hqCountrySelected = model
                    break
                }
            }
            break
        case currentLocationView:
            for model in countrySource {
                if model.name == text {
                    currentCountrySelected = model
                    break
                }
            }
            break
        default:
            break
        }
    }
    
    func textFieldReturn(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}






