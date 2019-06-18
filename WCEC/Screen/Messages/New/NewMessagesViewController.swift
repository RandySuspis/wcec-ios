//
//  NewMessagesViewController.swift
//  WCEC
//
//  Created by GEM on 6/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol NewMessagesViewControllerDelegate: NSObjectProtocol {
    func createNewGroupSuccess(_ viewController: BaseViewController, withChannelModel: ChannelModel)
}

class NewMessagesViewController: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var selectedUserLabel: UILabel!
    @IBOutlet weak var selectedUserLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var newMessageButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var refreshControl = UIRefreshControl()
    var viewModel = NewMessagesViewModel()
    let connectionsService = ConnectionsService()
    let chatService = ChatService()
    var currentPage: Int = 1
    var connectionAdded = [UserModel]()
    var existChannelId: String?
    
    weak var delegate: NewMessagesViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func setupLocalized() {
        newMessageButton.setTitle("Add".localized(), for: .normal)
    }
    
    func setupUI() {
        newMessageButton.layer.cornerRadius = 3.0
        newMessageButton.layer.masksToBounds = true
        
        addRefreshControl()
        addScrollToLoadMore()
        tableView.register(UINib(nibName: ConnectionsTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: ConnectionsTableViewCell.nibName())
        tableView.rowHeight = UITableViewAutomaticDimension
        
        searchTextField.delegate = self
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search your connections…".localized(),
                                                             attributes: [NSAttributedStringKey.foregroundColor: AppColor.colorTitleTextField()])
        searchTextField.borderStyle = .none
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
        connectionsService.searchMyConnected(param: searchTextField.text!, pager: pager) { (result) in
            switch result {
            case .success(let response):
                var data = response.data
                for item in self.connectionAdded {
                    data = data.filter({ $0.id != item.id})
                }
                self.viewModel.parseData(data)
                if response.data.count < Constants.kDefaultLimit {
                    self.tableView.showsInfiniteScrolling = false
                } else {
                    self.tableView.showsInfiniteScrolling = true
                }
                self.tableView.reloadData()
                if self.viewModel.rows.count > 0 {
                    self.tableView.scrollToTop(animated: false)
                }
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
        connectionsService.searchMyConnected(param: searchTextField.text!, pager: pager) { (result) in
            switch result {
            case .success(let response):
                var data = response.data
                for item in self.connectionAdded {
                    data = data.filter({ $0.id != item.id})
                }
                self.viewModel.doUpdateData(data)
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
        searchTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        getData()
    }
    
    @IBAction func onNewMessage(_ sender: Any) {
        if viewModel.rowsSelected.count == 0 {
            return
        }
        
        //need input all user id into invitations list
        if viewModel.rowsSelected.count == 0 {
            self.alertView("Alert".localized(), message: "")
            return
        }
        
        var invitedIds = [String]()
        viewModel.rowsSelected.forEach({
            invitedIds.append($0.objectID)
        })
        showHud()
        if let existChannelId = existChannelId,
            connectionAdded.count > 0 {
            chatService.inviteUserToChannel(channelId: existChannelId,
                                            listInviteIds: invitedIds,
                                            complete: { (result) in
                                                self.hideHude()
                                                switch result {
                                                case .success(let response):
                                                    self.delegate?.createNewGroupSuccess(self, withChannelModel: response.data)
                                                    break
                                                case .failure(let error):
                                                    self.alertWithError(error)
                                                    break
                                                }
            })
        } else {
            chatService.createChatChannel(name: "New Conversation".localized(), invitations: invitedIds) { (result) in
                switch result {
                case .success(let response):
                    self.delegate?.createNewGroupSuccess(self, withChannelModel: response.data)
                    self.registerDeviceTokenWithPubnub([String(response.data.id)])
                case .failure( let error):
                    self.alertWithError(error)
                }
                self.tableView?.infiniteScrollingView.stopAnimating()
                self.hideHude()
            }
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dissmissPushViewControllerWithPresentAnimation()
    }
}

extension NewMessagesViewController: UITableViewDataSource {
    
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
        return cell
    }
    
}

extension NewMessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectedRows(indexPath.row)
        selectedUserLabel.text = viewModel.userSelected()
        if viewModel.userSelected().count > 0 {
            selectedUserLabelHeightConstraint.constant = (selectedUserLabel.text?.height(withConstrainedWidth: selectedUserLabel.frame.size.width, font: selectedUserLabel.font))! + 20
        } else {
            selectedUserLabelHeightConstraint.constant = 0
        }
        
        UIView.setAnimationsEnabled(false)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        UIView.setAnimationsEnabled(true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = AppColor.colorPinkLow()
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
}













