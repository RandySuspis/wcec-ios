//
//  BaseSimpleTableViewController.swift
//  MyClip
//
//  Created by Huy Nguyen on 6/13/17.
//  Copyright © 2017 Huy Nguyen. All rights reserved.
//

import UIKit
import SVPullToRefresh

class BaseSimpleTableViewController<T: NSObject>: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    fileprivate var refreshControl = UIRefreshControl()
    var currentOffset = Constants.kFirstOffset
    var currentLimit = Constants.kDefaultLimit
    fileprivate var isFirstTime: Bool = true
    public var viewModel: SimpleTableViewModelProtocol = SimpleTableViewModel()
    public var data = [T]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupView() {
        addRefreshControl()
        addScrollToLoadMore()
        registerNib()
    }
    
    func addRefreshControl() {
//        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        tableView?.addSubview(refreshControl)
    }
    
    func addScrollToLoadMore() {
//        weak var wself = self
//        tableView?.addInfiniteScrolling(actionHandler: {
//            wself?.getNextPage()
//        })
//        tableView?.showsInfiniteScrolling = false
    }
    
    func registerNib() {
        for rowModel in viewModel.data {
            if Bundle.main.path(forResource: rowModel.identifier, ofType: "nib") != nil {
                tableView?.register(UINib(nibName: rowModel.identifier, bundle: nil),
                                    forCellReuseIdentifier: rowModel.identifier)
            }
        }
    }
    
//    override func onRetry(_ view: NoInternetView, sender: UIButton) {
//        refreshData()
//    }
    
//    @objc func refreshData() {
//        if !Singleton.sharedInstance.isConnectedInternet {
//            let error = NSError(domain: "", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
//            reloadData(error)
//            self.hideHude()
//            if self.refreshControl.isRefreshing {
//                self.refreshControl.endRefreshing()
//            }
//            self.tableView?.infiniteScrollingView.stopAnimating()
//            return
//        }
//        
//        if isFirstTime {
//            showHud()
//        }
//        let pager = Pager(offset: Constants.kFirstOffset, limit: currentLimit)
//        getData(pager: pager) { (_ result: Result<APIResponse<[T]>>) in
//            self.isFirstTime = false
//            switch result {
//            case .success(let response):
//                var rowModels = [PBaseRowModel]()
//                for item in response.data {
//                    if let rowModel = self.convertToRowModel(item) {
//                        rowModels.append(rowModel)
//                    }
//                }
//                self.viewModel.data = rowModels
//                self.data = response.data
//                if self.currentOffset == 0 && self.currentLimit == 0 {
//                    // offset and limit = zero when this view is not needed to have paging feature
//                    // infinite Scrolling will not be appeared
//                } else {
//                    if self.data.count < Constants.kDefaultLimit {
//                        self.tableView?.showsInfiniteScrolling = false
//                    } else {
//                        self.tableView?.showsInfiniteScrolling = true
//                    }
//                    self.currentOffset = Constants.kFirstOffset
//                }
//                self.reloadData()
//                break
//            case .failure(let error as NSError):
//                if error.code == NSURLErrorNotConnectedToInternet ||
//                    error.code == NSURLErrorNetworkConnectionLost {
//                    self.reloadData(error)
//                } else {
//                    self.toast(error.localizedDescription)
//                    break
//                }
//            default:
//                break
//            }
//            
//            self.hideHude()
//            if self.refreshControl.isRefreshing {
//                self.refreshControl.endRefreshing()
//            }
//            self.tableView?.infiniteScrollingView.stopAnimating()
//        }
//    }
    
//    func getNextPage() {
//        let pager = Pager(offset: currentOffset + currentLimit, limit: currentLimit)
//        getData(pager: pager) { (_ result: Result<APIResponse<T,Any>>) in
//            switch result {
//            case .success(let response):
//                var rowModels = [PBaseRowModel]()
//                for item in response.data {
//                    if let rowModel = self.convertToRowModel(item) {
//                        rowModels.append(rowModel)
//                    }
//                }
//                self.viewModel.data.append(contentsOf: rowModels)
//                self.data.append(contentsOf: response.data)
//                if self.currentOffset == 0 && self.currentLimit == 0 {
//
//                } else {
//                    if response.data.count < self.currentLimit {
//                        self.tableView?.showsInfiniteScrolling = false
//                    } else {
//                        self.tableView?.showsInfiniteScrolling = true
//                    }
//                    self.currentOffset = pager.offset // update the current page
//                }
//                self.reloadData()
//                break
//            case .failure(let error as NSError):
//                if error.code == NSURLErrorNotConnectedToInternet ||
//                    error.code == NSURLErrorNetworkConnectionLost {
//                    self.reloadData(error)
//                } else {
//                    self.toast(error.localizedDescription)
//                    break
//                }
//            default:
//                break
//            }
//            self.hideHude()
//            if self.refreshControl.isRefreshing {
//                self.refreshControl.endRefreshing()
//            }
//            self.tableView?.infiniteScrollingView.stopAnimating()
//        }
//    }
    
    func getData(pager: Pager, _ completion: @escaping (Result<APIResponse<T,Any>>) -> Void) {
        //mark: should be override in subclasses
        fatalError("Must override in subclasses")
    }
    
    func convertToRowModel(_ item: T) -> PBaseRowModel? {
        fatalError("Must override in subclasses")
    }
    
//    func reloadData(_ error: NSError? = nil) {
//        registerNib()
//        if let error = error {
//            if error.code == NSURLErrorNotConnectedToInternet ||
//                error.code == NSURLErrorNetworkConnectionLost {
//                self.data.removeAll()
//                self.viewModel.data.removeAll()
//                tableView?.backgroundView = offlineView()
//            } else {
//                tableView?.backgroundView = emptyView()
//            }
//        } else if data.isEmpty {
//            tableView?.backgroundView = emptyView()
//        } else {
//            tableView?.backgroundView = nil
//        }
//        tableView?.reloadData()
//    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = viewModel.data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                 for: indexPath) as! BaseTableViewCell
        cell.bindingWithModel(rowModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if !Singleton.sharedInstance.isConnectedInternet {
//            showInternetConnectionError()
//            return
//        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

