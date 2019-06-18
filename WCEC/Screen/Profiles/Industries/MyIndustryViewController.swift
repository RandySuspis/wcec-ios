//
//  MyIndustryViewController.swift
//  WCEC
//
//  Created by hnc on 5/10/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol MyIndustryDelegate: NSObjectProtocol {
    func didDoneChoseIndutry(listIndustriesSelected: [SubCategoryModel])
}

class MyIndustryViewController: BaseViewController {
    
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notHaveTagLabel: UILabel!
    @IBOutlet weak var ctNavigationHeight: NSLayoutConstraint!
    @IBOutlet weak var ctSearchMyIndustryHeight: NSLayoutConstraint!
    @IBOutlet weak var tfSearchNav: UITextField!
    @IBOutlet weak var searchMyIndustryContainer: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    weak var delegate: MyIndustryDelegate?
    
    var searchCategoriesSelected = [SubCategoryModel]()
    
    var sections: [CategorySectionModel] = []
    let userService = UserService()
    var isFromSearch = false
    var isFromMyProfile = false
    var subCategoriesSelected = [String]()
    var otherText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        subCategoriesSelected.removeAll()
        otherText = ""
        getIndustries("", isFirstTime: true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height+60, 0)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    func setupUI() {
        if isFromMyProfile {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.saveBarButton(target: self, selector: #selector(onSelectNextBarButton))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.nextBarButton(target: self, selector: #selector(onSelectNextBarButton))
        }
        tagListView.delegateTag = self
        searchTextField.setLeftPaddingPoints(0)
        searchTextField.delegate = self
    
        notHaveTagLabel.isHidden = false
        tagListView.isHidden = true

        tfSearchNav.attributedPlaceholder = NSAttributedString(string: "Search".localized(),
                                                            attributes: [NSAttributedStringKey.foregroundColor: AppColor.colorTitleTextField()])
        tfSearchNav.borderStyle = .none
        
        ctSearchMyIndustryHeight.constant = isFromSearch ? 0.0 : 105.0
        searchMyIndustryContainer.isHidden = isFromSearch
        ctNavigationHeight.constant = isFromSearch ? 74.0 : 0.0
        self.view.layoutIfNeeded()
    }
    
    func setupTableView() {
        tableView.register(UINib.init(nibName: ChildTagTableViewCell.classString(), bundle: nil), forCellReuseIdentifier: ChildTagTableViewCell.classString())
        tableView.register(UINib.init(nibName: ChildTagOtherTableViewCell.classString(), bundle: nil), forCellReuseIdentifier: ChildTagOtherTableViewCell.classString())
        tableView.register(UINib.init(nibName: ParentTagHeaderView.classString(), bundle: nil), forHeaderFooterViewReuseIdentifier: ParentTagHeaderView.classString())
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    override func setupLocalized() {
        searchTextField.placeholder = "Search tags...".localized()
        notHaveTagLabel.text = isFromSearch ? "" : "Choose at least one to get you more relevant connections".localized()
        self.navigationItem.title = "My Industries".localized()
        doneButton.setTitle("Done".localized(), for: .normal)
    }
    
    //Mark: Action
    @objc func onSelectNextBarButton() {
        view.endEditing(true)
        if subCategoriesSelected.contains("0") {
            subCategoriesSelected.removeAll()
            subCategoriesSelected.append("0")
        }
        for item in tagListView.tagViews {
            subCategoriesSelected.append(String(item.tagId))
        }
        
        guard subCategoriesSelected.count > 0 else {
            self.alertView("Alert".localized(), message: "The industries field is required".localized())
            return
        }
        
        
        if subCategoriesSelected.contains("0") {
            if otherText.count == 0 {
                self.alertView("Alert".localized(), message: "Please specify your other industry".localized())
            } else {
                self.showHud()
                userService.createNewIndustry(name: otherText, complete: { (result) in
                    switch result {
                    case .success(let response):
                        let tempSelectedList = self.subCategoriesSelected
                        for index in 0...tempSelectedList.count-1 {
                            let selected = tempSelectedList[index]
                            if selected == "0" {
                                self.subCategoriesSelected.remove(at: index)
                                break
                            }
                        }
                        self.subCategoriesSelected.append(response.data.id.description)
                        self.saveIndustries()
                        break
                    case .failure( let error):
                        self.hideHude()
                        self.alertWithError(error)
                        break
                    }
                })
            }
        } else {
            self.showHud()
            saveIndustries()
        }
    }
    
    func saveIndustries() {
        userService.doUpdateIndustry(userId: (DataManager.getCurrentUserModel()?.id)!, section: "industries", industries: subCategoriesSelected) { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                DataManager.saveUserModel(response.data)
                if self.isFromMyProfile {
                    NotificationCenter.default.post(name: .kRefreshMyProfile, object: nil, userInfo: nil)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let vc = MyInterestsViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                break
            case .failure( let error):
                self.alertWithError(error)
                break
            }
        }
    }

    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        view.endEditing(true)
        var listCategory = [CategoryModel]()
        for model in self.sections {
            listCategory.append(model.category)
        }
        
        var subCategoriesSelected = [SubCategoryModel]()
        for category in listCategory {
            let selected = category.getSubCategorySelectedModel()
            if selected.count != 0 {
                subCategoriesSelected.append(contentsOf: selected)
            }
        }
        dismiss(animated: true) {
            self.delegate?.didDoneChoseIndutry(listIndustriesSelected: subCategoriesSelected)
        }
    }
}

//MARK: UITableViewDataSource
extension MyIndustryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].collapsed ? 0 : sections[section].category.subcategoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].category.subcategoryList[indexPath.row] //items[indexPath.row]
        if item.id == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChildTagOtherTableViewCell.classString(), for: indexPath) as! ChildTagOtherTableViewCell
            
            cell.textField.attributedPlaceholder = NSAttributedString(string: item.placeHolderString, attributes: [NSAttributedStringKey.foregroundColor: AppColor.colorTextField()])
            cell.textField.text = otherText
            cell.textField.delegate = self
            cell.selected(item.isSelected)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChildTagTableViewCell.classString(), for: indexPath) as! ChildTagTableViewCell

            cell.titleLabel.text = item.name
            cell.selected(item.isSelected)
            
            return cell
        }
    }
}

//MARK: UITableViewDelegate
extension MyIndustryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ParentTagHeaderView.classString()) as! ParentTagHeaderView
        let sectionModel = sections[section]
        headerView.titleLabel.text = sectionModel.category.name

        headerView.setCollapsed(sectionModel.collapsed)
        headerView.section = section
        headerView.delegate = self
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = sections[indexPath.section]
        model.category.subcategoryList[indexPath.row].isSelected = !model.category.subcategoryList[indexPath.row].isSelected
        if model.category.subcategoryList[indexPath.row].isSelected == true {
            if model.category.subcategoryList[indexPath.row].id > 0 {
                tagListView.addTag(model.category.subcategoryList[indexPath.row].name, model.category.subcategoryList[indexPath.row].id, model.category.subcategoryList[indexPath.row].type)
                notHaveTagLabel.isHidden = true
                tagListView.isHidden = false
            } else {
                subCategoriesSelected.append("0")
            }
        } else {
            if model.category.subcategoryList[indexPath.row].id > 0 {
                tagListView.removeTag(model.category.subcategoryList[indexPath.row].name)
            } else {
                let tempSelectedList = subCategoriesSelected
                for index in 0...tempSelectedList.count-1 {
                    let selected = tempSelectedList[index]
                    if selected == "0" {
                        subCategoriesSelected.remove(at: index)
                        break
                    }
                }
            }
            if tagListView.tagViews.count == 0 {
                notHaveTagLabel.isHidden = false
                tagListView.isHidden = true
            }
        }
        
        tableView.reloadData()
    }
}

extension MyIndustryViewController: ParentTagHeaderViewDelegate {
    func onSelectHeaderView(_ header: ParentTagHeaderView, section: Int) {
        let collapsed = !sections[section].collapsed
        sections[section].collapsed = collapsed
        
        tableView.reloadData()
    }
}

extension MyIndustryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if textField == searchTextField {
            getIndustries(textField.text!, isFirstTime: false)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField != searchTextField {
            if let text = textField.text,
                let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange,
                                                           with: string)
                otherText = updatedText
            }
        }
        return true
    }
}

extension MyIndustryViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
        
        var listCategory = [CategoryModel]()
        for model in self.sections {
            listCategory.append(model.category)
        }
        
        for category in listCategory {
            for sub in category.subcategoryList {
                if sub.id == tagView.tagId {
                    sub.isSelected = false
                    break
                }
            }
        }
        
        if tagListView.tagViews.count == 0 {
            notHaveTagLabel.isHidden = false
            tagListView.isHidden = true
        }
        self.tableView.reloadData()
    }
}

extension MyIndustryViewController  {
    func getIndustries(_ searchText: String, isFirstTime: Bool) {
        self.showHud()
        userService.getListIndustries(searchText: searchText) { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                let industries = response.data
                self.sections.removeAll()
                var isExistOthers: Bool = false
                for category in industries {
                    if category.id == 0 {
                        isExistOthers = true
                    }
                    self.setupCategorySectionModel(category: category, isFirstTime: isFirstTime)
                }
                
                if !isExistOthers {
                    let category = CategoryModel(0, "Others", .industries)
                    let subCategory = SubCategoryModel(0, "Please specify...", .industries)
                    category.subcategoryList.append(subCategory)
                    self.setupCategorySectionModel(category: category, isFirstTime: isFirstTime)
                }
                
                self.tableView.reloadData()
            case .failure( let error):
                self.alertWithError(error)
            }
        }
    }
    
    func setupCategorySectionModel(category: CategoryModel, isFirstTime: Bool) {
        let section = CategorySectionModel(type: .industries,
                                           category: category,
                                           collapsed: true,
                                           isFromSearch: self.isFromSearch,
                                           searchCategoriesSelected: self.searchCategoriesSelected,
                                           tagListView: self.tagListView,
                                           isFirstTime: isFirstTime)
        for subCategory in section.category.subcategoryList {
            if subCategory.isSelected {
                var isExist: Bool = false
                for tag in self.tagListView.tagViews {
                    if tag.label.text == subCategory.name {
                        isExist = true
                        break
                    }
                }
                if !isExist {
                    if subCategory.id != 0 {
                        self.tagListView.addTag(subCategory.name, subCategory.id, subCategory.type)
                    }
                }
            }
        }
        if self.tagListView.tagViews.count > 0 {
            self.notHaveTagLabel.isHidden = true
            self.tagListView.isHidden = false
        } else {
            self.notHaveTagLabel.isHidden = false
            self.tagListView.isHidden = true
        }
        self.sections.append(section)
    }
}
