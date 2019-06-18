//
//  ConnectedViewController.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ConnectedViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var refreshControl = UIRefreshControl()
    var viewModel = ConnectedViewModel()
    let connectionsService = ConnectionsService()
    var currentPage: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        getData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupUI() {
        addRefreshControl()
        addScrollToLoadMore()
        tableView.register(UINib(nibName: ConnectionsTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: ConnectionsTableViewCell.nibName())
        tableView.rowHeight = UITableViewAutomaticDimension
        
        txtSearch.delegate = self
        txtSearch.attributedPlaceholder = NSAttributedString(string: "Search your connections…".localized(),
                                                             attributes: [NSAttributedStringKey.foregroundColor: AppColor.colorTitleTextField()])
        txtSearch.borderStyle = .none
    }
    
    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(getData), for: UIControlEvents.valueChanged)
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
    
    @objc func getData() {
        self.showHud()
        currentPage = 1
        let pager = Pager(page: currentPage, per_page: Constants.kDefaultLimit)
        connectionsService.searchMyConnected(param: txtSearch.text!, pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.parseData(response.data)
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
        self.showHud()
        let pager = Pager(page: currentPage + 1, per_page: Constants.kDefaultLimit)
        connectionsService.searchMyConnected(param: txtSearch.text!, pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.doUpdateData(response.data)
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
            self.tableView?.infiniteScrollingView.stopAnimating()
            self.hideHude()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        getData()
    }
    
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ConnectedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows.count
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = viewModel.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                 for: indexPath) as! BaseTableViewCell
        cell.selectionStyle = .none
        cell.bindingWithModel(rowModel)
        if let cell = cell as? ConnectionsTableViewCell {
            cell.delegate = self
        }
        return cell
    }
    
}

extension ConnectedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let detail = ProfileDetailViewController()
        detail.userId = viewModel.rows[indexPath.row].objectID
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = AppColor.colorPinkLow()
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
}

extension ConnectedViewController: ConnectionsTableViewCellDelegate {

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
                Constants.appDelegate.tabbarController.present(popupRequest, animated: true, completion: nil)
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

extension ConnectedViewController: PopupSendRequestDelegate {
    func popupSendRequest(_ controller: PopupSendRequest, didClose sender: UIButton, success: Bool) {
        controller.dismiss(animated: true, completion: nil)
        if success {
            getData()
        }
    }
}





