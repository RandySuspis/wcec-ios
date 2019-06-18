//
//  NewfeedsViewController.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import XLActionController

class NewfeedsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trendingLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var heightSearchViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var noResultLabel: UILabel!
    
    fileprivate var refreshControl = UIRefreshControl()
    var states : Array<Bool>!
    var viewModel = NewFeedViewModel()
    var newsFeedService = NewsfeedService()
    var trendingTags = [SubCategoryModel]()
    var currentPage: Int = 1
    var isSearching: Bool = false
    var trendingTagsSelected = [SubCategoryModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getListNewfeed()
        addRefreshControl()
        addScrollToLoadMore()
        addNotificationCenter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(isSearching, animated: false)
        states = [Bool](repeating: true, count: viewModel.rows.count)
        tableView.reloadData()
        getTrendingTags()
    }

    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(getListNewfeed), for: UIControlEvents.valueChanged)
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
    
    func addNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getListNewfeed),
                                               name: .kRefreshListNewfeed,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(scrollToTop),
                                               name: .kScrollToTopListNewfeed,
                                               object: nil)
    }
    
    @objc func scrollToTop() {
        if viewModel.rows.count > 0 {
            tableView.scrollToTop(animated: true)
        }
    }
    
    func setupUI() {
        noResultView.isHidden = true
        noResultLabel.isHidden = true
        
        heightSearchViewConstraint.constant = 0.0
        searchView.isHidden = true

        self.view.layoutIfNeeded()
    
        searchTextField.delegate = self
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search".localized(),
                                                            attributes: [NSAttributedStringKey.foregroundColor:
                                                                AppColor.colorTitleTextField()])
        searchTextField.borderStyle = .none
        
        tagListView.delegateTag = self
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.searchBarButton(target: self, selector: #selector(onSearchAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.plusBarButton(target: self, selector: #selector(onSelectCreateNewPost))
        
        let cellList = [NewFeedPhotoTableViewCell.nibName(),
                        NewFeedNoAssetTableViewCell.nibName(),
                        NewFeedEmbedLinkTableViewCell.nibName(),
                        NewFeedVideoTableViewCell.nibName()]
        cellList.forEach({
            tableView.register(UINib(nibName: $0, bundle: nil),
                               forCellReuseIdentifier: $0)
        })
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180
        
        if let currentUser = DataManager.getCurrentUserModel() {
            if !currentUser.new_feed_visited {
                let userManual = NewfeedUserManualViewController()
                userManual.view.backgroundColor = UIColor.clear
                userManual.modalTransitionStyle = .crossDissolve
                userManual.modalPresentationStyle = .overCurrentContext
                Constants.appDelegate.tabbarController.present(userManual, animated: true, completion: nil)
            }
        }

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dragNavigationBarDown(_:)))
        swipeGesture.direction = .down
        navigationController!.view.addGestureRecognizer(swipeGesture)
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "News Feed".localized()
        self.trendingLabel.text = "Trending now".localized()
        self.noResultLabel.text = "No Result" .localized()
    }

    @IBAction func dragNavigationBarDown(_ gesture: UIPanGestureRecognizer) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        view.window!.layer.add(transition, forKey: kCATransition)

        let trendingTagVC = TrendingTagViewController()
        trendingTagVC.trendingTags = self.trendingTags
        trendingTagVC.trendingTagsSelected = self.trendingTagsSelected
        trendingTagVC.delegate = self
        let navi = BaseNavigationController.init(rootViewController: trendingTagVC)
        navi.modalPresentationStyle = .overCurrentContext
        Constants.appDelegate.tabbarController.present(navi, animated: false, completion: nil)
    }

    @objc func onSelectCreateNewPost() {
        let newPostVC = NewPostViewController()
        let navi = BaseNavigationController.init(rootViewController: newPostVC)
        navi.modalPresentationStyle = .overCurrentContext
        Constants.appDelegate.tabbarController.present(navi, animated: true, completion: nil)
    }
    
    @objc func onSearchAction() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        isSearching = true
        self.heightSearchViewConstraint.constant = 74.0
        searchView.isHidden = false
        self.searchTextField.becomeFirstResponder()
        self.view.layoutIfNeeded()
    }
    
    @IBAction func onDismissSearch(_ sender: Any) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        isSearching = false
        self.heightSearchViewConstraint.constant = 0.0
        searchView.isHidden = true
        self.view.layoutIfNeeded()
        searchTextField.text = ""
        getListNewfeed()
    }
}

extension NewfeedsViewController: TrendingTagViewControllerDelegate {

    func trendingTagViewController(trendingTagsSelected: [SubCategoryModel]) {
        self.trendingTagsSelected = trendingTagsSelected
        self.getListNewfeed()
    }
}

extension NewfeedsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        getListNewfeed()
        searchTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        getListNewfeed()
    }
}

extension NewfeedsViewController {
    
    @objc func getListNewfeed() {
        self.showHud()
        currentPage = 1
        let pager = Pager(page: currentPage, per_page: Constants.kDefaultLimit)
        newsFeedService.getListNewfeed(trending: trendingTagsSelected,
                                       searchText: searchTextField.text!,
                                       pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.rows.removeAll()
                self.viewModel.parseNewfeed(response.data)
                if response.data.count < Constants.kDefaultLimit {
                    self.tableView.showsInfiniteScrolling = false
                } else {
                    self.tableView.showsInfiniteScrolling = true
                }
                self.tableView.reloadData()
                self.noResultLabel.isHidden = !(response.data.count == 0 && self.isSearching)
                self.noResultView.isHidden = !(response.data.count == 0 && self.isSearching)
                break
            case .failure(let error):
                self.alertWithError(error)
                break
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.tableView?.infiniteScrollingView.stopAnimating()
            self.hideHude()
        }
    }
    
    func getTrendingTags() {
        newsFeedService.getTrendingTags { (result) in
            switch result {
            case .success(let response):
                self.trendingTags = response.data
                for tag in self.trendingTags {
                    self.tagListView.addTag(tag.name, tag.id, tag.type)
                }
            case .failure( let error):
                self.alertWithError(error)
            }
        }
    }
    
    func getNextPage() {
        self.showHud()
        let pager = Pager(page: currentPage + 1, per_page: Constants.kDefaultLimit)
        newsFeedService.getListNewfeed(trending: trendingTagsSelected,
                                       searchText: searchTextField.text!,
                                       pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.parseNewfeed(response.data)
                if response.data.count < Constants.kDefaultLimit {
                    self.tableView.showsInfiniteScrolling = false
                } else {
                    self.tableView.showsInfiniteScrolling = true
                    self.currentPage += 1
                }
                self.tableView.reloadData()
                break
            case .failure(let error):
                self.alertWithError(error)
                break
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.tableView?.infiniteScrollingView.stopAnimating()
            self.hideHude()
        }
    }
}

extension NewfeedsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = viewModel.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                 for: indexPath) as! BaseNewFeedTableViewCell
        cell.bindingWithModel(rowModel)
        cell.delegate = self
        return cell
    }
}

extension NewfeedsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = NewfeedDetailViewController()
        vc.newfeedId = viewModel.rows[indexPath.row].objectID
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
}

extension NewfeedsViewController: BaseNewFeedTableViewCellDelegate {
    func baseNewFeedTableViewCellDidTapAvatar(_ url: String) {
        openPhotoViewer([url])
    }

    func baseNewFeedTableViewCell(_ cell: BaseNewFeedTableViewCell) {
        UIView.setAnimationsEnabled(false)
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.updateCollapse(index: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        UIView.setAnimationsEnabled(true)
    }
    
    func baseNewFeedTableViewCellDidSelectAsset(_ cell: BaseNewFeedTableViewCell, listImage: [String]) {
        openPhotoViewer(listImage)
    }
    
    func baseNewFeedTableViewCellShouldPlayVideo(_ cell: BaseNewFeedTableViewCell, link: String) {
        self.playVideo(link, true)
    }
    
    func baseNewFeedTableViewCellDidSelectMore(_ cell: BaseNewFeedTableViewCell) {
        guard let  indexPath = self.tableView.indexPath(for: cell) else { return }
        let actionController = YoutubeActionController()
        actionController.addAction(Action(ActionData(title: "Share via".localized(), image: #imageLiteral(resourceName: "shareWhite")), style: .default, handler: { action in
            self.shareNewfeed(self.viewModel.rows[indexPath.row].data.url,
                              postID: self.viewModel.rows[indexPath.row].objectID)
        }))
        
        if cell.model?.data.author.id == DataManager.getCurrentUserModel()?.id {
            if cell.model?.data.parent == nil {
                actionController.addAction(Action(ActionData(title: "Edit Post".localized(), image: #imageLiteral(resourceName: "editWhite")), style: .default, handler: { action in
                    let editPostVC = NewPostViewController()
                    editPostVC.newFeedModel = cell.model?.data
                    let nav = BaseNavigationController.init(rootViewController: editPostVC)
                    nav.modalPresentationStyle = .overCurrentContext
                    Constants.appDelegate.tabbarController.present(nav, animated: true, completion: nil)
                }))
            }
            actionController.addAction(Action(ActionData(title: "Delete Post".localized(), image: #imageLiteral(resourceName: "closeWhite")), style: .default, handler: { action in
                self.alertButtonWithTitle("Confirm".localized(), message: "This post will be deleted and you won't be able to find it anymore.".localized(), completion: {
                    self.showHud()
                    self.newsFeedService.deletePost(postId: "\(cell.model?.data.id.description ?? "")", complete: { (result) in
                        self.hideHude()
                        switch result {
                        case .success( _):
                            self.viewModel.rows.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            break
                        case .failure(let error):
                            self.alertWithError(error)
                            break
                        }
                    })
                })
            }))
        } else {
            actionController.addAction(Action(ActionData(title: "Report Post".localized(), image: #imageLiteral(resourceName: "warn")), style: .default, handler: { action in
                let popup = PopupReportPost.init(PopupReportPost.classString())
                popup.postId = self.viewModel.rows[indexPath.row].objectID
                self.presentVC(vc: popup)
            }))
        }
        
        actionController.addAction(Action(ActionData(title: "Close".localized()), style: .default, handler: { action in
        }))
        
        for cell in actionController.collectionView.visibleCells {
            cell.backgroundColor = AppColor.colorCellBgBlack()
        }
        present(actionController, animated: true, completion: nil)
    }
    
    func baseNewFeedTableViewCellDidSelectShare(_ cell: BaseNewFeedTableViewCell) {
        guard let  indexPath = tableView.indexPath(for: cell) else { return }
        self.alertButtonWithTitle("Confirm".localized(), message: "Do you want to share this post?".localized(), completion: {
            self.showHud()
            self.newsFeedService.sharePost(postId: "\(cell.model?.data.id.description ?? "")", complete: { (result) in
                self.hideHude()
                switch result {
                case .success(let response):
                    self.viewModel.addNewPost(response.data)
                    self.viewModel.updateShare(index: indexPath.row)
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    break
                case .failure(let error):
                    self.alertWithError(error)
                    break
                }
            })
        })
    }
    
    func baseNewFeedTableViewCellDidSelectLike(_ cell: BaseNewFeedTableViewCell) {
        guard let  indexPath = tableView.indexPath(for: cell) else { return }
        newsFeedService.likePost(id: viewModel.rows[indexPath.row].objectID) { (result) in
            switch result {
            case .success(_):
                self.viewModel.updateLike(index: indexPath.row)
                UIView.setAnimationsEnabled(false)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                UIView.setAnimationsEnabled(true)
                break
            case .failure(_):
                break
            }
        }
    }
}

extension NewfeedsViewController: TagListViewDelegate {
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        tagView.label.backgroundColor = UIColor.clear
        getListNewfeed()
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        guard !tagView.enableRemoveButton else {
            return
        }
        DispatchQueue.main.async {
            self.getListNewfeed()
        }
    }
}








