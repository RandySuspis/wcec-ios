//
//  MutunalConnectionsViewController.swift
//  WCEC
//
//  Created by GEM on 6/25/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class MutunalConnectionsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate var refreshControl = UIRefreshControl()
    var viewModel = MutunalConnectionsViewModel()
    let userService = UserService()
    var currentPage: Int = 1
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
    }
    override func setupLocalized() {
        titleLabel.text = "Mutual Connections".localized()
        self.navigationItem.title = "Mutual Connections".localized()
    }
    func setupUI() {
        var updatedFrame = navImageView.bounds
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.closeBarItem(target: self, btnAction: #selector(onSelectClose))
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == 2436{
                updatedFrame.size.height += 44
            } else {
                updatedFrame.size.height += 20
            }
        }
        
        let gradient = CAGradientLayer()
        gradient.colors = [AppColor.colorFadedRed().cgColor, AppColor.colorlightBurgundy().cgColor, AppColor.colorpurpleBrown().cgColor]
        gradient.frame = updatedFrame
        
        navImageView.image = UIImage.imageWithLayer(layer: gradient)
        
        tableView.register(UINib(nibName: ConnectionsTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: ConnectionsTableViewCell.nibName())
        tableView.rowHeight = UITableViewAutomaticDimension
        
        addRefreshControl()
        addScrollToLoadMore()
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
        guard let currentUser = DataManager.getCurrentUserModel(),
            let userId = userId else {
                self.hideHude()
                return
        }
        
        userService.getListMutualConnection(currentId: String(currentUser.id),
                                            userId: userId,
                                            pager: pager) { (result) in
                                                switch result {
                                                case .success(let response):
                                                    self.viewModel.parseData(response.data)
                                                    if response.data.count < Constants.kDefaultLimit {
                                                        self.tableView.showsInfiniteScrolling = false
                                                    } else {
                                                        self.tableView.showsInfiniteScrolling = true
                                                    }
                                                    self.tableView.reloadData()
                                                    break
                                                case .failure(_):
                                                    break
                                                }
                                                if self.refreshControl.isRefreshing {
                                                    self.refreshControl.endRefreshing()
                                                }
                                                self.tableView?.infiniteScrollingView.stopAnimating()
                                                self.hideHude()
        }
    }
    
    func getNextPage() {
        let pager = Pager(page: currentPage + 1, per_page: Constants.kDefaultLimit)
        guard let currentUser = DataManager.getCurrentUserModel(),
            let userId = userId else {
                self.hideHude()
                return
        }
        
        userService.getListMutualConnection(currentId: String(currentUser.id),
                                            userId: userId,
                                            pager: pager) { (result) in
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
                                                    break
                                                case .failure(_):
                                                    break
                                                }
                                                self.tableView?.infiniteScrollingView.stopAnimating()
                                                self.hideHude()
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onSelectClose() {
        self.dissmissPushViewControllerWithPresentAnimation()
    }
}

extension MutunalConnectionsViewController: UITableViewDataSource {
    
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

extension MutunalConnectionsViewController: UITableViewDelegate {
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

extension MutunalConnectionsViewController: ConnectionsTableViewCellDelegate {

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
        default:
            break
        }
    }
}

extension MutunalConnectionsViewController: PopupSendRequestDelegate {
    func popupSendRequest(_ controller: PopupSendRequest, didClose sender: UIButton, success: Bool) {
        controller.dismiss(animated: true, completion: nil)
        if success {
            getData()
        }
    }
}







