//
//  SearchTagsViewController.swift
//  WCEC
//
//  Created by hnc on 6/12/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol SearchTagsDelegate: NSObjectProtocol {
    func didDoneChooseTags(viewController: SearchTagsViewController, tagsSelected: [SubCategoryModel])
}

class SearchTagsViewController: BaseViewController {
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: SearchTagsDelegate?
    
    var searchCategoriesSelected = [SubCategoryModel]()
    
    var sections: [SearchTagsSectionModel] = []
    let newsfeedService = NewsfeedService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
        getAllTags("", isFirstTime: true)
    }
    
    func setupUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.doneBarButton(target: self, selector: #selector(onSelectDoneBarButton))
        tagListView.delegateTag = self
        searchTextField.setLeftPaddingPoints(0)
        searchTextField.delegate = self

        tagListView.isHidden = true
        
        self.view.layoutIfNeeded()
    }
    
    func setupTableView() {
        tableView.register(UINib.init(nibName: ChildTagTableViewCell.classString(), bundle: nil), forCellReuseIdentifier: ChildTagTableViewCell.classString())
        tableView.register(UINib.init(nibName: ParentTagHeaderView.classString(), bundle: nil), forHeaderFooterViewReuseIdentifier: ParentTagHeaderView.classString())
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    override func setupLocalized() {
        searchTextField.placeholder = "Search tags...".localized()
        self.navigationItem.title = "Tags".localized()
    }
    
    @objc func onSelectDoneBarButton() {
        view.endEditing(true)
        self.delegate?.didDoneChooseTags(viewController: self, tagsSelected: searchCategoriesSelected)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK: UITableViewDataSource
extension SearchTagsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].collapsed ? 0 : sections[section].category.subcategoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChildTagTableViewCell.classString(), for: indexPath) as! ChildTagTableViewCell
        
        let item = sections[indexPath.section].category.subcategoryList[indexPath.row] //items[indexPath.row]
        cell.titleLabel.text = item.name
        cell.selected(item.isSelected)
        
        return cell
    }
}

//MARK: UITableViewDelegate
extension SearchTagsViewController: UITableViewDelegate {
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
            tagListView.addTag(model.category.subcategoryList[indexPath.row].name, model.category.subcategoryList[indexPath.row].id, model.category.subcategoryList[indexPath.row].type)
            tagListView.isHidden = false

            var isExist = false
            for i in 0 ..< searchCategoriesSelected.count {
                let sub = searchCategoriesSelected[i]
                if sub.id == model.category.subcategoryList[indexPath.row].id && sub.name == model.category.subcategoryList[indexPath.row].name && sub.type == model.category.subcategoryList[indexPath.row].type {
                    isExist = true
                    break
                }
            }
            if !isExist {
                searchCategoriesSelected.append(model.category.subcategoryList[indexPath.row])
            }
        } else {
            tagListView.removeTag(model.category.subcategoryList[indexPath.row].name)
            if tagListView.tagViews.count == 0 {
                tagListView.isHidden = true
            }
            
            for i in 0 ..< searchCategoriesSelected.count {
                let sub = searchCategoriesSelected[i]
                if sub.id == model.category.subcategoryList[indexPath.row].id && sub.name == model.category.subcategoryList[indexPath.row].name && sub.type == model.category.subcategoryList[indexPath.row].type {
                    searchCategoriesSelected.remove(at: i)
                    break
                }
            }
        }
        
        tableView.reloadData()
    }
}

extension SearchTagsViewController: ParentTagHeaderViewDelegate {
    func onSelectHeaderView(_ header: ParentTagHeaderView, section: Int) {
        let collapsed = !sections[section].collapsed
        sections[section].collapsed = collapsed
        
        tableView.reloadData()
    }
}

extension SearchTagsViewController  {
    func getAllTags(_ searchText: String, isFirstTime: Bool) {
        self.showHud()
        newsfeedService.searchTags(text: searchText) { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                let tags = response.data
                self.sections.removeAll()
                for category in tags {
                    let section = SearchTagsSectionModel(category: category,
                                                       collapsed: true,
                                                       searchCategoriesSelected: self.searchCategoriesSelected,
                                                       tagListView: self.tagListView)
                    for subCategory in section.category.subcategoryList {
                        for item in self.searchCategoriesSelected {
                            if subCategory.id == item.id && subCategory.type == item.type {
                                subCategory.isSelected = true
                                section.collapsed = false
                                break
                            }
                        }
                    }
                    
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
                                self.tagListView.addTag(subCategory.name, subCategory.id, subCategory.type)
                            }
                        }
                    }
                    
                    if self.tagListView.tagViews.count > 0 {
                        self.tagListView.isHidden = false
                    } else {
                        self.tagListView.isHidden = true
                    }
                    self.sections.append(section)
                }
                self.tableView.reloadData()
            case .failure( let error):
                self.alertWithError(error)
            }
        }
    }
}

extension SearchTagsViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
        
        var listCategory = [CategoryModel]()
        for model in self.sections {
            listCategory.append(model.category)
        }
        
        for category in listCategory {
            for sub in category.subcategoryList {
                if sub.id == tagView.tagId && sub.type == tagView.tagType  {
                    if searchCategoriesSelected.count > 0 {
                        for index in 0..<searchCategoriesSelected.count {
                            let selected = searchCategoriesSelected[index]
                            if sub.id == selected.id && sub.type == selected.type {
                                searchCategoriesSelected.remove(at: index)
                                break
                            }
                        }
                    }
                    sub.isSelected = false
                    break
                }
            }
        }
        
        if tagListView.tagViews.count == 0 {
            tagListView.isHidden = true
        }
        self.tableView.reloadData()
    }
}

extension SearchTagsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        getAllTags(textField.text!, isFirstTime: false)
        return true
    }
}
