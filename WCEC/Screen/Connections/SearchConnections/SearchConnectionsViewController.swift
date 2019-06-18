//
//  SearchConnectionsViewController.swift
//  WCEC
//
//  Created by GEM on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class SearchConnectionsViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var ctTableViewTop: NSLayoutConstraint!
    
    fileprivate var refreshControl = UIRefreshControl()
    let connectionsService = ConnectionsService()
    var viewModel = SearchConnectionsViewModel()
    var currentPage: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        ctTableViewTop.constant = tagListView.tagViews.isEmpty ? 0.0 : 56.0
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupUI() {
        addRefreshControl()
        addScrollToLoadMore()
        self.view.backgroundColor = AppColor.colorGray250()
        tfSearch.delegate = self
        tfSearch.attributedPlaceholder = NSAttributedString(string: "Search".localized(),
                                                             attributes: [NSAttributedStringKey.foregroundColor:
                                                                AppColor.colorTitleTextField()])
        tfSearch.borderStyle = .none
        tagListView.delegateTag = self
        tfSearch.addTarget(self,
                                  action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        tableView.register(UINib(nibName: ConnectionsTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: ConnectionsTableViewCell.nibName())
        tableView.register(UINib(nibName: SearchKeyWordTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: SearchKeyWordTableViewCell.nibName())
    }
    
    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(onSearch), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        tableView?.addSubview(refreshControl)
    }
    
    func addScrollToLoadMore() {
        weak var wself = self
        tableView?.addInfiniteScrolling(actionHandler: {
            wself?.getNextPage()
        })
        tableView?.showsInfiniteScrolling = false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        onSearchKeyWord(textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfSearch.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onSearchKeyWord(textField.text!)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func onSearchKeyWord(_ text: String) {
        connectionsService.getSuggestKeywords(text: text) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.parseKeywords(response.data)
                self.ctTableViewTop.constant = 0.0
                self.view.layoutIfNeeded()
                self.tableView.reloadData()
            case .failure( let error):
                print(error.localizedDescription)
                self.viewModel.rowsKeywords = []
                self.onSearch()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func onSearch() {
        if tfSearch.text == "" &&
            viewModel.listLocationSelected.isEmpty &&
            viewModel.listInterestsSelected.isEmpty &&
            viewModel.listIndustriesSelected.isEmpty {
            viewModel.rowsDataSearch = []
            tableView.reloadData()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            return
        }
        self.showHud()
        currentPage = 1
        let pager = Pager(page: currentPage, per_page: Constants.kDefaultLimit)
        connectionsService.searchAllPeople(param: tfSearch.text!,
                                           listIndustriesSelected: viewModel.listIndustriesSelected,
                                           listInterestsSelected: viewModel.listInterestsSelected,
                                           listLocationSelected: viewModel.listLocationSelected,
                                           pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.parseDataSearch(response.data)
                self.ctTableViewTop.constant = self.tagListView.tagViews.isEmpty ? 0.0 : 56.0
                self.view.layoutIfNeeded()
                if response.data.count < Constants.kDefaultLimit {
                    self.tableView.showsInfiniteScrolling = false
                } else {
                    self.tableView.showsInfiniteScrolling = true
                }
                self.tableView.reloadData()
            case .failure( let error):
                self.alertWithError(error)
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.tableView?.infiniteScrollingView.stopAnimating()
            self.hideHude()
        }
    }
    
    func getNextPage() {
        if tfSearch.text == "" &&
            viewModel.listLocationSelected.isEmpty &&
            viewModel.listInterestsSelected.isEmpty &&
            viewModel.listIndustriesSelected.isEmpty {
            viewModel.rowsDataSearch = []
            tableView.reloadData()
            return
        }
        self.showHud()
        let pager = Pager(page: currentPage + 1, per_page: Constants.kDefaultLimit)
        connectionsService.searchAllPeople(param: tfSearch.text!,
                                           listIndustriesSelected: viewModel.listIndustriesSelected,
                                           listInterestsSelected: viewModel.listInterestsSelected,
                                           listLocationSelected: viewModel.listLocationSelected,
                                           pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.doUpdateDataSearch(response.data)
                if response.data.count < Constants.kDefaultLimit {
                    self.tableView.showsInfiniteScrolling = false
                } else {
                    self.tableView.showsInfiniteScrolling = true
                    self.currentPage += 1
                }
                self.tableView.reloadData()
            case .failure( let error):
                self.alertWithError(error)
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.tableView?.infiniteScrollingView.stopAnimating()
            self.hideHude()
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onFilter(_ sender: Any) {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.viewModel.doUpdateLocation(viewModel.listLocationSelected)
        filterVC.viewModel.doUpdateIndustrie(viewModel.listIndustriesSelected)
        filterVC.viewModel.doUpdateInterests(viewModel.listInterestsSelected)
        self.navigationController?.pushViewController(filterVC, animated: true)
    }
    
}

extension SearchConnectionsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.rowsKeywords.count > 0 {
            return viewModel.rowsKeywords.count
        }
        return viewModel.rowsDataSearch.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.rowsKeywords.count > 0 {
            return 48.0
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var rowModel: PBaseRowModel
        if viewModel.rowsKeywords.count > 0 {
            rowModel = viewModel.rowsKeywords[indexPath.row]
        } else {
            rowModel = viewModel.rowsDataSearch[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                 for: indexPath) as! BaseTableViewCell
        cell.selectionStyle = .none
        cell.bindingWithModel(rowModel)
        if let cell = cell as? ConnectionsTableViewCell {
            cell.delegate = self
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.rowsKeywords.count > 0 {
            tfSearch.text = viewModel.rowsKeywords[indexPath.row].title
            ctTableViewTop.constant = tagListView.tagViews.isEmpty ? 0.0 : 56.0
            self.view.layoutIfNeeded()
            onSearch()
        } else if viewModel.rowsDataSearch.count > 0 {
            self.tableView.deselectRow(at: indexPath, animated: true)
            let detail = ProfileDetailViewController()
            detail.isFromSearchConnections = true
            detail.userId = viewModel.rowsDataSearch[indexPath.row].objectID
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 1 && viewModel.rowsKeywords.isEmpty {
            cell.backgroundColor = AppColor.colorPinkLow()
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
}

extension SearchConnectionsViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if tagListView.tagViews.count == 1 {
            ctTableViewTop.constant = 0.0
            self.view.layoutIfNeeded()
        }
        viewModel.removeTagView(title)
        sender.removeTagView(tagView)
        onSearch()
    }
}

extension SearchConnectionsViewController: FilterViewControllerDelegate {
    func didApplyFilter(listIndustriesSelected: [SubCategoryModel],
                        listInterestsSelected: [SubCategoryModel],
                        listLocationSelected: [rowModelLocation]) {
        viewModel.listIndustriesSelected = listIndustriesSelected
        viewModel.listInterestsSelected = listInterestsSelected
        viewModel.listLocationSelected = listLocationSelected
        
        self.tagListView.removeAllTags()
        for item in listLocationSelected {
            self.tagListView.addTag(item.data.name, item.data.id, .interests)
        }
        for item in listIndustriesSelected {
            self.tagListView.addTag(item.name, item.id, item.type)
        }
        for item in listInterestsSelected {
            self.tagListView.addTag(item.name, item.id, item.type)
        }
        onSearch()
    }
}

extension SearchConnectionsViewController: ConnectionsTableViewCellDelegate {

    func connectionsTableViewCellDidSelectAvatar(url: String) {
        openPhotoViewer([url])
    }
    
    func connectionsTableViewCell(_ cell: ConnectionsTableViewCell, didSelectActionButton sender: UIButton, type: RelationType) {
        switch type {
        case .notFriend:
            let popupRequest = PopupSendRequest.init(PopupSendRequest.classString())
            popupRequest.delegate = self
            if let rowModel = cell.rowModel {
                popupRequest.connectionRowModel = rowModel
                self.present(popupRequest, animated: true, completion: nil)
            }
            break
        case .friend:
            guard let rowModel = cell.rowModel else { return }
            self.createNewMessage([rowModel.objectID])
            break
        case .requestPending:
            //do nothing
            break
        case .requestReceived:
            //View button
            let detail = ProfileDetailViewController()
            detail.userId = (cell.rowModel?.objectID)!
            self.navigationController?.pushViewController(detail, animated: true)
            break
        case .blocked:
            //do nothing
            break
        }
    }
}

extension SearchConnectionsViewController: PopupSendRequestDelegate {
    func popupSendRequest(_ controller: PopupSendRequest, didClose sender: UIButton, success: Bool) {
        controller.dismiss(animated: true, completion: nil)
        if success {
            onSearch()
        }
    }
}










