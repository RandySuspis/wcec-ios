//
//  FAQViewController.swift
//  WCEC
//
//  Created by GEM on 6/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class FAQViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = FAQViewModel()
    fileprivate var refreshControl = UIRefreshControl()
    let userService = UserService()
    var currentPage: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "FAQ".localized()
    }
    
    func setupUI() {
        addRefreshControl()
        addScrollToLoadMore()
        tableView.register(UINib(nibName: FAQTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: FAQTableViewCell.nibName())
        tableView.register(UINib(nibName: HeaderSectionFAQ.nibName(), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: HeaderSectionFAQ.nibName())
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 48.0
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
        userService.getListFaq(pager: pager) { (result) in
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
        userService.getListFaq(pager: pager) { (result) in
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

extension FAQViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].isCollapse ? 0 : viewModel.sections[section].section.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = viewModel.sections[indexPath.section].section.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier, for: indexPath) as! BaseTableViewCell
        cell.bindingWithModel(rowModel)
        return cell
    }
}

extension FAQViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionModel = viewModel.sections[section]
        let view = HeaderSectionFAQ.dequeueReuseHeaderWithNib(in: tableView, reuseIdentifier: HeaderSectionFAQ.nibName())
        view.titleLabel.text = sectionModel.section.header.title
        view.section = section
        view.iconImageView.image = sectionModel.isCollapse ? #imageLiteral(resourceName: "arrowDown") : #imageLiteral(resourceName: "arrowUp")
        view.delegate = self
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension FAQViewController: HeaderSectionFAQDelegate {
    
    func headerSectionFAQDelegateDidTap(section: Int) {
        viewModel.didSelectSection(section)
        self.tableView.reloadData()
    }
}






