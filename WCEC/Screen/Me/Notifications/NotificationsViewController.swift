//
//  NotificationsViewController.swift
//  WCEC
//
//  Created by GEM on 6/28/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class NotificationsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    fileprivate var refreshControl = UIRefreshControl()
    var viewModel = NotificationsViewModel()
    let userService = UserService()
    var currentPage: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Notifications".localized()
    }
    
    func setupUI() {
        addRefreshControl()
        addScrollToLoadMore()
        tableView.register(UINib(nibName: NotificationTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: NotificationTableViewCell.nibName())
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
        userService.getListNotifications(pager: pager) { (result) in
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
        userService.getListNotifications(pager: pager) { (result) in
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
}

extension NotificationsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = viewModel.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier, for: indexPath) as! BaseTableViewCell
        cell.bindingWithModel(rowModel)
        return cell
    }
}

extension NotificationsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowModel = viewModel.rows[indexPath.row]
        self.showHud()
        userService.markSeenNotification(rowModel.objectID) { (result) in
            self.hideHude()
            switch result {
            case .success(_):
                Constants.appDelegate.countNotificationBadge()
                self.viewModel.didSelectedRow(indexPath.row)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                switch rowModel.type {
                case .connection:
                    let vc = ProfileDetailViewController()
                    vc.userId = rowModel.entity_id
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case .post:
                    let vc = NewfeedDetailViewController()
                    vc.newfeedId = rowModel.entity_id
                    self.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.hidesBottomBarWhenPushed = false
                    break
                case .message:
                    let vc = ChatViewController()
                    vc.channelId = rowModel.entity_id
                    self.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    self.hidesBottomBarWhenPushed = false
                    break
                case .newMessage:
                    break
                }
                break
            case .failure(let error):
                self.alertWithError(error)
                break
            }
        }
    }
}
