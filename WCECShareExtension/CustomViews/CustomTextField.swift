//
//  CustomTextField.swift
//  WCEC
//
//  Created by hnc on 5/7/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol CustomTextFieldDelegate: class {
    func textFieldShowDropDown(_ textField: UITextField, view: UIView)
    func textFielDidSelectRightButton(_ textField: UITextField, view: UIView)
    func textFieldBeginEdit(_ textField: UITextField, view: UIView)
    func textFieldEndEdit(_ textField: UITextField, view: UIView)
    func textFieldReturn(_ textField: UITextField, view: UIView)
    func textFieldDidSelectSearchOption(_ text: String, view: UIView)
}

class CustomTextField: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var preTextField: UITextField!
    @IBOutlet weak var leadingTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowDropdownImageView: UIImageView!
    @IBOutlet weak var searchTextField: SearchTextField!
    @IBOutlet weak var lblSecondTitle: UILabel!
    
    weak var delegate: CustomTextFieldDelegate?
    
    var title: String? {
        didSet {
            titleLabel.text = title
            titleLabel.textColor = AppColor.colorTitleTextField()
        }
    }
    
    var secondTitle: String? {
        didSet {
            lblSecondTitle.text = secondTitle
        }
    }
    var text: String? {
        didSet {
            textField.text = text
//            textField.textColor = AppColor.colorTitleTextField()
//            textField.font = AppFont.fontWithType(.regular, size: 16)
        }
    }
    
    var preText:String? {
        didSet {
            preTextField.text = preText
        }
    }
    
    var isDropDown:Bool? {
        didSet {

//            if isDropDown == true {
//
//                preTextField.isUserInteractionEnabled = false
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDropDown(_:)))
//                tapGesture.numberOfTapsRequired = 1
//                tapGesture.numberOfTouchesRequired = 1
//                self.addGestureRecognizer(tapGesture)
//                self.isUserInteractionEnabled = true
//            }
        }
    }
    
    var isSearchText:Bool? {
        didSet {
            if isSearchText == true {
                searchTextField.isHidden = false
                searchTextField.delegate = self
                searchTextField.itemSelectionHandler = { (filteredResults: [SearchTextFieldItem], _ index: Int) in
                    self.searchTextField.text = filteredResults[index].title
                    self.delegate?.textFieldDidSelectSearchOption(filteredResults[index].title, view: self)
                }
            }
        }
    }
    
    var isShowPreTextField: Bool? {
        didSet {
            if isShowPreTextField == true {
                leadingTextFieldConstraint.constant = 104
                preTextField.isHidden = false
            } else {
                leadingTextFieldConstraint.constant = 0
                preTextField.isHidden = true
            }
        }
    }
    
    var textPlaceHolder: String? {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(string:textPlaceHolder ?? "",
                                                                 attributes: [NSAttributedStringKey.foregroundColor: AppColor.colorTitleTextField()])
            textField.borderStyle = .none
        }
    }
    
    var rightImage: UIImage? {
        didSet {
            if let image = rightImage {
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                button.setImage(image, for: .normal)
                button.addTarget(self, action: #selector(onClickRightButton(_:)), for: .touchUpInside)
                textField.rightView = button
                textField.rightViewMode = .always
                textField.clearButtonMode = .never
            }
        }
    }
    
    var searchDataSource: [String]? {
        didSet {
            if searchDataSource?.count != 0 {
                searchTextField.filterStrings(searchDataSource!)
            }
        }
    }
    
    var isSecure: Bool? {
        didSet{
            textField.isSecureTextEntry = isSecure ?? false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        Bundle.main.loadNibNamed("CustomTextField", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        textField.setLeftPaddingPoints(10)
        textField.delegate = self
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = AppColor.colorBorderBlack().cgColor
        preTextField.setLeftPaddingPoints(10)
        preTextField.delegate = self
        preTextField.layer.borderWidth = 1.0
        preTextField.layer.borderColor = AppColor.colorBorderBlack().cgColor
        isShowPreTextField = false
        searchTextField.setLeftPaddingPoints(10)
        searchTextField.layer.borderWidth = 1.0
        searchTextField.layer.borderColor = AppColor.colorBorderBlack().cgColor
        searchTextField.theme = .darkTheme()
        searchTextField.comparisonOptions = [.anchored]
    }
    
    func setText(_ textString: String) {
        textField.text = textString
    }
    
    @objc func onClickRightButton(_ sender: UIButton) {
        delegate?.textFielDidSelectRightButton(textField, view: self)
    }
    
    @objc func showDropDown(_ tapGes: UITapGestureRecognizer) {
        delegate?.textFieldShowDropDown(self.textField, view: self)
    }
    
    fileprivate func localCountries() -> [String] {
        if let path = Bundle.main.path(forResource: "countries", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .dataReadingMapped)
                let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [[String:String]]
                
                var countryNames = [String]()
                for country in jsonResult {
                    countryNames.append(country["name"]!)
                }
                
                return countryNames
            } catch {
                print("Error parsing jSON: \(error)")
                return []
            }
        }
        return []
    }
}

extension CustomTextField: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == preTextField {
            preText = textField.text
        } else {
            text = textField.text
        }
        textField.layer.borderColor = AppColor.colorBorderBlack().cgColor
        delegate?.textFieldEndEdit(textField, view: self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = AppColor.colorBorderRustyOrange().cgColor
        delegate?.textFieldBeginEdit(textField, view: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldReturn(textField, view: self)
        return true
    }
}
