//
//  ConnectionsViewController.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ConnectionsViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblConnected: UILabel!
    @IBOutlet weak var lblNumberConnected: UILabel!
    @IBOutlet weak var lblRequest: UILabel!
    @IBOutlet weak var lblNumberRequest: UILabel!
    @IBOutlet weak var ctWidthRightMenu: NSLayoutConstraint!
    @IBOutlet weak var lblScanQr: UILabel!
    @IBOutlet weak var lblInvitePeople: UILabel!
    
    fileprivate var refreshControl = UIRefreshControl()
    var viewModel = ConnectionsViewModel()
    let connectionsService = ConnectionsService()
    var currentPage: Int = 1
    var isShowingSideMenu: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
        addNotificationCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func addNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: .kRefreshConnections, object: nil)
    }
    
    func setupUI() {
        addRefreshControl()
        addScrollToLoadMore()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.searchBarButton(target: self, selector: #selector(btnSearchAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.plusBarButton(target: self, selector: #selector(btnPlusAction))
        
        tableView.register(UINib(nibName: ConnectionsTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: ConnectionsTableViewCell.nibName())
        tableView.register(UINib(nibName: HeaderSectionsConnections.nibName(), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: HeaderSectionsConnections.nibName())
        tableView.register(UINib(nibName: FooterSectionsConnections.nibName(), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: FooterSectionsConnections.nibName())
        tableView.rowHeight = UITableViewAutomaticDimension
        
        ctWidthRightMenu.constant = 0.0
        self.view.layoutIfNeeded()
        if let currentUser = DataManager.getCurrentUserModel() {
            if !currentUser.connection_visited {
                let userManual = ConnectionsUserManualViewController()
                userManual.view.backgroundColor = UIColor.clear
                userManual.modalTransitionStyle = .crossDissolve
                userManual.modalPresentationStyle = .overCurrentContext
                Constants.appDelegate.tabbarController.present(userManual, animated: true, completion: nil)
            }
        }
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Connections".localized()
        self.lblRequest.text = "Requests".localized()
        self.lblConnected.text = "Connected".localized()
        self.lblScanQr.text = "Scan QR Code".localized()
        self.lblInvitePeople.text = "Invite People…".localized()
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
        connectionsService.getNumberTotalRequest { (result) in
            switch result {
            case .success(let response):
                self.viewModel.totalRequestModel = response.data
                self.lblNumberRequest.text = self.viewModel.totalRequest()
                self.lblNumberConnected.text = self.viewModel.totalConected()
            case .failure( let error):
                self.alertWithError(error)
            }
        }
        self.getDataRequest()
    }
    
    func getDataRequest() {
        self.showHud()
        let pager = Pager(page: 1, per_page: Constants.kDefaultLimit)
        connectionsService.getListRequests(param: "new",pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.parseRequest(response.data)
            case .failure( let error):
                self.alertWithError(error)
            }
            self.getDataSuggesstion()
        }
    }
    
    func getDataSuggesstion() {
        currentPage = 1
        let pager = Pager(page: currentPage, per_page: Constants.kDefaultLimit)
        connectionsService.getListSuggestions(pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.parseSuggesstion(response.data)
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
        connectionsService.getListSuggestions(pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.doUpdateSuggesstion(response.data)
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
    
    @objc func btnSearchAction() {
        let searchVc = SearchConnectionsViewController()
        let nav = BaseNavigationController(rootViewController: searchVc)
        nav.modalTransitionStyle = .crossDissolve
        nav.modalPresentationStyle = .overCurrentContext
        Constants.appDelegate.tabbarController.present(nav, animated: true, completion: nil)
    }
    
    @objc func btnPlusAction() {
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {() -> Void in
                        self.ctWidthRightMenu.constant = self.isShowingSideMenu ? 0.0 : 230.0
                        self.view.layoutIfNeeded()},
                       completion: {(finished) -> Void in
                        self.isShowingSideMenu = !self.isShowingSideMenu})
    }
    
    @IBAction func btnConnectedAction(_ sender: Any) {
        let conectedVC = ConnectedViewController()
        self.navigationController?.pushViewController(conectedVC, animated: true)
    }
    
    @IBAction func btnRequestsAction(_ sender: Any) {
        let requestVC = ConnectionsRequestsViewController()
        requestVC.isRefreshConnections = !viewModel.sections[0].rows.isEmpty
        self.navigationController?.pushViewController(requestVC, animated: true)
    }
    
    @IBAction func onPressScanQRCode(_ sender: Any) {
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {() -> Void in
                        self.ctWidthRightMenu.constant = self.isShowingSideMenu ? 0.0 : 230.0
                        self.view.layoutIfNeeded()},
                       completion: {(finished) -> Void in
                        self.isShowingSideMenu = !self.isShowingSideMenu
                        let scanVc = ScanQRCodeViewController()
                        scanVc.delegate = self
                        self.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(scanVc, animated: true)
                        self.hidesBottomBarWhenPushed = false
        })
    }
    
    @IBAction func onPressInvitePeople(_ sender: Any) {
        let activityVC = UIActivityViewController.init(activityItems: ["Please search and download WCEC app in AppStore and PlayStore".localized()], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
}

extension ConnectionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].rows.count
    }

    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard viewModel.sections.count > indexPath.section else {
            return UITableViewCell()
        }
        let rowModel = viewModel.sections[indexPath.section].rows[indexPath.row]
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

extension ConnectionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionModel = viewModel.sections[indexPath.section]
        self.tableView.deselectRow(at: indexPath, animated: true)
        let detail = ProfileDetailViewController()
        let connection = sectionModel.rows[indexPath.row] as! ConnectionsRowModel
        detail.userId = connection.objectID
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = AppColor.colorPinkLow()
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard viewModel.sections.count > section else {
            return CGFloat.leastNormalMagnitude
        }
        let sectionModel = viewModel.sections[section]
        if sectionModel.header.identifier != nil && !sectionModel.rows.isEmpty {
            return 72
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard viewModel.sections.count > section else {
            return CGFloat.leastNormalMagnitude
        }
        let sectionModel = viewModel.sections[section]
        if section == 0 &&
            !sectionModel.rows.isEmpty {
            return 40
        }
       return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard viewModel.sections.count > section else {
            return nil
        }
        let sectionModel = viewModel.sections[section]
        if sectionModel.header.identifier != nil && !sectionModel.rows.isEmpty {
            let view = HeaderSectionsConnections.dequeueReuseHeaderWithNib(in: tableView, reuseIdentifier: HeaderSectionsConnections.nibName())
            view.titleLabel?.text = sectionModel.header.title
            if sectionModel.header.title == "We found some suggestions for you".localized() {
                view.imgHeader.isHidden = true
            } else {
                view.imgHeader.isHidden = false
            }
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard viewModel.sections.count > section else {
            return nil
        }
         let sectionModel = viewModel.sections[section]
        if sectionModel.header.identifier != nil &&
            !sectionModel.rows.isEmpty &&
            section == 0 {
            let view = FooterSectionsConnections.dequeueReuseHeaderWithNib(in: tableView, reuseIdentifier: FooterSectionsConnections.nibName())
            view.btnSeeAll.setTitle("See All".localized(), for: .normal)
            view.btnSeeAll.addTarget(self, action: #selector(onSeeAll), for: .touchUpInside)
            return view
        }
        return nil
    }
    
    @objc func onSeeAll() {
        let requestVC = ConnectionsRequestsViewController()
        requestVC.isRefreshConnections = !viewModel.sections[0].rows.isEmpty
        self.navigationController?.pushViewController(requestVC, animated: true)
    }
    
}

extension ConnectionsViewController: ConnectionsTableViewCellDelegate {
    
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

extension ConnectionsViewController: PopupSendRequestDelegate {
    func popupSendRequest(_ controller: PopupSendRequest, didClose sender: UIButton, success: Bool) {
        controller.dismiss(animated: true, completion: nil)
        if success {
            getData()
        }
    }
}

extension ConnectionsViewController: ScanQRCodeViewControllerDelegate {
    func successScanQrCode(userId: String) {
        let vc = ProfileDetailViewController()
        vc.userId = userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
}














