//
//  ProfileDetailViewController.swift
//  WCEC
//
//  Created by hnc on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import XLActionController

class ProfileDetailViewController: BaseViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ctWidthRightMenu: NSLayoutConstraint!
    @IBOutlet weak var lblShare: UILabel!
    @IBOutlet weak var lblBlock: UILabel!
    
    // MARK: - Variable
    fileprivate var refreshControl = UIRefreshControl()
    var currentPage: Int = 1
    var viewModel = ProfileDetailViewModel()
    var userId: String = ""
    var isShowingSideMenu: Bool = false
    let userService = UserService()
    let connectService = ConnectionsService()
    let newsFeedService = NewsfeedService()
    var currentIndex: Int = 0
    var isNoPosts: Bool = false
    var isFromSearchConnections: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getUserData()
        addRefreshControl()
        addScrollToLoadMore()
        addNotificationCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    // MARK: - Setup
    override func setupLocalized() {
        lblShare.text = "Share via".localized()
    }
    
    func addNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getUserData),
                                               name: .kRefreshMyProfile,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getUserData),
                                               name: .kRefreshListNewfeed,
                                               object: nil)

    }
    
    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(getUserData), for: UIControlEvents.valueChanged)
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
    
    func setupUI() {
        self.title = "" //get full name of user
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.customBarItem(image: "othersWhite",
                                                                               target: self,
                                                                               btnAction: #selector(onRightMenu))
        ctWidthRightMenu.constant = 0.0
        self.view.layoutIfNeeded()
        registerTableView()
    }
    
    func registerTableView() {
        let cellList = [NewFeedPhotoTableViewCell.nibName(),
                        NewFeedNoAssetTableViewCell.nibName(),
                        NewFeedEmbedLinkTableViewCell.nibName(),
                        NewFeedVideoTableViewCell.nibName(),
                        ProfileTableViewCell.nibName(),
                        ProfileMutualTableViewCell.nibName(),
                        OccupationTableViewCell.nibName(),
                        ProfileInterestsTableViewCell.nibName(),]
        cellList.forEach({
            tableView.register(UINib(nibName: $0, bundle: nil),
                               forCellReuseIdentifier: $0)
        })
        tableView.register(UINib(nibName: FooterSectionsConnections.nibName(), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: FooterSectionsConnections.nibName())
        tableView.register(UINib(nibName: ProfileHeaderView.nibName(), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: ProfileHeaderView.nibName())
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @objc func getUserData() {
        isNoPosts = false
        self.showHud()
        userService.doGetUserInfo(userId: userId) { (result) in
            switch result {
            case .success(let response):
                self.viewModel = ProfileDetailViewModel()
                self.viewModel.parseProfile(response.data)
                self.updateUI()
                self.getMutualConnections()
                break
            case .failure( let error):
                self.hideHude()
                self.alertWithError(error)
                break
            }
        }
    }

    func updateUI() {
        guard let user = self.viewModel.user else {
            return
        }
        self.title = user.fullName
        if user.relation == RelationType.blocked.rawValue {
            self.lblBlock.text = "Unblock".localized()
        } else {
            self.lblBlock.text = "Block".localized()
        }
        
        guard let currentUser = DataManager.getCurrentUserModel() else {
            return
        }
        if currentUser.id == user.id {
            self.title = "My Profile".localized()
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func getMutualConnections() {
        guard let currentUser = DataManager.getCurrentUserModel() else {
            self.hideHude()
            return
        }
        let pager = Pager(page: 0, per_page: Constants.kDefaultLimit)
        userService.getListMutualConnection(currentId: String(currentUser.id),
                                            userId: userId,
                                            pager: pager) { (result) in
                                                switch result {
                                                case .success(let response):
                                                    self.viewModel.parseBasicInfoMutualFriend(response.data)
                                                    break
                                                case .failure(_):
                                                    break
                                                }
                                                if self.currentIndex == 1 {
                                                    self.getListNewfeed()
                                                } else {
                                                    self.tableView.reloadData()
                                                    self.hideHude()
                                                }
                                                if self.refreshControl.isRefreshing {
                                                    self.refreshControl.endRefreshing()
                                                }
                                                self.tableView?.infiniteScrollingView.stopAnimating()
        }
    }
    
    func getListNewfeed() {
        self.showHud()
        currentPage = 1
        let pager = Pager(page: currentPage, per_page: Constants.kDefaultLimit)
        newsFeedService.getListNewfeed(authorId: self.viewModel.user?.id,
                                       trending: [],
                                       searchText: "",
                                       pager: pager) { (result) in
            switch result {
            case .success(let response):
                if response.data.isEmpty {
                    self.isNoPosts = true
                }
                self.viewModel.posts = response.data
                if response.data.count < Constants.kDefaultLimit {
                    self.tableView.showsInfiniteScrolling = false
                } else {
                    self.tableView.showsInfiniteScrolling = true
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
    
    func getNextPage() {
        self.showHud()
        let pager = Pager(page: currentPage + 1, per_page: Constants.kDefaultLimit)
        newsFeedService.getListNewfeed(authorId: self.viewModel.user?.id,
                                       trending: [],
                                       searchText: "",
                                       pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.updatePost(response.data)
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
    
    // MARK: - Action
    @objc func onRightMenu() {
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {() -> Void in
                        self.ctWidthRightMenu.constant = self.isShowingSideMenu ? 0.0 : 230.0
                        self.view.layoutIfNeeded()},
                       completion: {(finished) -> Void in
                        self.isShowingSideMenu = !self.isShowingSideMenu
        })
    }
    
    // MARK: - IBAction
    @IBAction func onShare(_ sender: Any) {
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {() -> Void in
                        self.ctWidthRightMenu.constant = self.isShowingSideMenu ? 0.0 : 230.0
                        self.view.layoutIfNeeded()},
                       completion: {(finished) -> Void in
                        self.isShowingSideMenu = !self.isShowingSideMenu
                        guard let user = self.viewModel.user else { return }
                        self.shareWithLink(user.url)
                        
        })
    }
    
    @IBAction func onBlock(_ sender: Any) {
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {() -> Void in
                        self.ctWidthRightMenu.constant = self.isShowingSideMenu ? 0.0 : 230.0
                        self.view.layoutIfNeeded()},
                       completion: {(finished) -> Void in
                        self.isShowingSideMenu = !self.isShowingSideMenu
                        if self.viewModel.user?.relation == RelationType.blocked.rawValue {
                            guard let currentUser = DataManager.getCurrentUserModel() else {
                                return
                            }
                            guard let blockUser = self.viewModel.user else {
                                return
                            }
                            self.showHud()
                            self.connectService.doBlockUser(blockUserId: String(blockUser.id),
                                                          currentUserId: String(currentUser.id)) { (result) in
                                                            self.hideHude()
                                                            switch result {
                                                            case .success( _):
                                                                self.getUserData()
                                                                NotificationCenter.default.post(name: .kRefreshConnections,
                                                                                                object: nil,
                                                                                                userInfo: nil)
                                                                break
                                                            case .failure(let error):
                                                                self.alertWithError(error)
                                                                break
                                                            }
                            }
                        } else {
                            let popup = PopupBlock.init(PopupBlock.classString())
                            popup.delegate = self
                            popup.user = self.viewModel.user
                            if self.isFromSearchConnections {
                                self.present(popup, animated: true, completion: nil)
                            } else {
                                Constants.appDelegate.tabbarController.present(popup, animated: true, completion: nil)
                            }
                        }
        })
    }
}

// MARK: - PopupBlockDelegate
extension ProfileDetailViewController: PopupBlockDelegate {
    func popupBlockSuccess() {
        getUserData()
    }
}

// MARK: - UITableViewDataSource
extension ProfileDetailViewController: UITableViewDataSource {
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
        guard viewModel.sections[indexPath.section].rows.count > indexPath.row else {
            return UITableViewCell()
        }
        guard let user = self.viewModel.user else {
            return UITableViewCell()
        }
        let rowModel = viewModel.sections[indexPath.section].rows[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                for: indexPath) as? BaseTableViewCell {
            cell.selectionStyle = .none
            if let cell = cell as? ProfileTableViewCell {
                cell.bindingWithModel(rowModel, currentIndex)
                cell.delegate = self
                if let currentUser = DataManager.getCurrentUserModel() {
                    if currentUser.id == user.id {
                        cell.delegate = self
                    }
                }
            }
            
            if let cell = cell as? ProfileMutualTableViewCell {
                cell.bindingWithModel(viewModel.basicInfoMutualRows[indexPath.row])
            }
            
            if let cell = cell as? ProfileInterestsTableViewCell {
                if viewModel.sections[indexPath.section].header.title == "Interests".localized() {
                    cell.bindingData(viewModel.userInterests, type: .interests, userId: user.id)
                } else if viewModel.sections[indexPath.section].header.title == "Industries".localized() {
                    cell.bindingData(viewModel.userIndustries, type: .industries, userId: user.id)
                }
            }
            
            if let cell = cell as? OccupationTableViewCell {
                cell.bindingWithModel(viewModel.basicInfoOccupationRows[indexPath.row])
            }
            
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                       for: indexPath) as? BaseNewFeedTableViewCell {
            if let rowModelData = rowModel as? NewFeedRowModel {
                cell.bindingWithModel(rowModelData)
                cell.delegate = self
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: - UITableViewDelegate
extension ProfileDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let currentUser = DataManager.getCurrentUserModel() else { return }
        guard let user = viewModel.user else { return }
        if indexPath.section == 1 &&
            currentUser.id != user.id {
            let vc = ProfileDetailViewController()
            vc.userId = viewModel.sections[indexPath.section].rows[indexPath.row].objectID
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 0 && indexPath.row > 0{
            let vc = NewfeedDetailViewController()
            vc.isFromSearchConnections = self.isFromSearchConnections
            vc.newfeedId = viewModel.sections[indexPath.section].rows[indexPath.row].objectID
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            self.hidesBottomBarWhenPushed = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionModel = viewModel.sections[section]
        if sectionModel.header.identifier != nil {
            return 40.0
        } else {
            return 1.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard viewModel.sections.count > section else {
            return nil
        }
        let sectionModel = viewModel.sections[section]
        if sectionModel.header.identifier != nil {
            let view = ProfileHeaderView.dequeueReuseHeaderWithNib(in: tableView, reuseIdentifier: ProfileHeaderView.nibName())
            view.bindingWithModel(sectionModel.header, section: section)
            guard let currentUser = DataManager.getCurrentUserModel() else { return nil }
            guard let user = self.viewModel.user else { return nil }
            if currentUser.id == user.id {
                view.delegate = self
                view.editImageView.isHidden = false
            } else {
                view.editImageView.isHidden = true
            }
            return view
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 && viewModel.mutunalConnection.count > 2 {
            return 40.0
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 && viewModel.mutunalConnection.count > 2 {
            let view = FooterSectionsConnections.dequeueReuseHeaderWithNib(in: tableView, reuseIdentifier: FooterSectionsConnections.nibName())
            view.btnSeeAll.setTitle("See All".localized(), for: .normal)
            view.btnSeeAll.addTarget(self, action: #selector(onSeeAll), for: .touchUpInside)
            return view
        }
        return nil
    }
    
    @objc func onSeeAll() {
        let vc = MutunalConnectionsViewController()
        vc.userId = self.userId
        self.pushViewControllerWithPresentAnimation(vc)
    }
}

// MARK: - ProfileTableViewCellDelegate
extension ProfileDetailViewController: ProfileTableViewCellDelegate {

    func profileTableViewCellDidTapAvatar(_ image: String) {
        openPhotoViewer([image])
    }

    func profileTableViewCellDidSelectedEditIntro(_ cell: ProfileTableViewCell) {
        let vc = SetupIntroViewController()
        vc.isFromMyProfile = true
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    func profileTableViewCellDidSelectedCreateNewPost(_ cell: ProfileTableViewCell) {
        let newPostVC = NewPostViewController()
        let navi = BaseNavigationController.init(rootViewController: newPostVC)
        navi.modalPresentationStyle = .overCurrentContext
        self.presentVC(vc: navi)
    }
    
    func profileTableViewCellDidSelectedTab(_ cell: ProfileTableViewCell, index: Int) {
        currentIndex = index
        self.tableView.showsInfiniteScrolling = index == 0 ? false : true
        if self.viewModel.posts.isEmpty && index == 1 && !isNoPosts{
            getListNewfeed()
        } else {
            viewModel.updateFollowTab(index)
        }
        tableView.reloadData()
    }
    
    func profileTableViewCell(_ cell: ProfileTableViewCell, didSelectAddButton sender: UIButton) {
        let popupRequest = PopupSendRequest.init(PopupSendRequest.classString())
        popupRequest.delegate = self
        if let rowModel = cell.rowModel {
            if self.viewModel.mutunalConnection.isEmpty {
                rowModel.note = ""
            } else {
                rowModel.note = "\(self.viewModel.mutunalConnection.count) " +
                            (self.viewModel.mutunalConnection.count > 1 ?
                        "mutual connections".localized() : "mutual connection".localized())
            }
            popupRequest.connectionRowModel = rowModel
            self.presentVC(vc: popupRequest)
        }
    }
    
    func profileTableViewCell(_ cell: ProfileTableViewCell, didSelectAcceptButton sender: UIButton) {
        if let rowModel = cell.rowModel {
            acceptOrReject(requestId: (rowModel.userModel?.requestId)!, status: .accept)
        }
    }
    
    func profileTableViewCell(_ cell: ProfileTableViewCell, didSelectRejectButton sender: UIButton) {
        if let rowModel = cell.rowModel {
            acceptOrReject(requestId: (rowModel.userModel?.requestId)!, status: .reject)
        }
    }
    
    func profileTableViewCell(_ cell: ProfileTableViewCell, didSelectMessageButton sender: UIButton) {
        guard let rowModel = cell.rowModel else { return }
        self.createNewMessage([rowModel.objectID])
    }
    
    func acceptOrReject(requestId: Int, status: RequestStatus) {
        self.showHud()
        connectService.acceptOrReject(requestId: requestId, status: status, complete: { (result) in
            switch result {
            case .success(let response):
                self.viewModel = ProfileDetailViewModel()
                self.viewModel.parseProfile(response.data.user)
                self.navigationItem.title = response.data.user.fullName
                self.tableView.reloadData()
                if status == .accept {
                    let popup = PopupConnectedViewController.init(PopupConnectedViewController.classString())
                    popup.user = response.data.user
                    self.presentVC(vc: popup)
                }
                NotificationCenter.default.post(name: .kRefreshConnections,
                                                object: nil,
                                                userInfo: nil)
                self.getMutualConnections()
                break
            case .failure( let error):
                self.alertWithError(error)
                self.hideHude()
                break
            }
        })
    }
    
    func profileTableViewCellDidCancelRequest(_ cell: ProfileTableViewCell) {
        if let rowModel = cell.rowModel {
            guard let user = rowModel.userModel else { return }
            let popup = PopupCencelRequest.init(PopupCencelRequest.classString())
            popup.userName = user.fullName
            popup.requestId = user.requestId
            popup.delegate = self
            self.presentVC(vc: popup)
        }
    }
    
    func profileTableViewCellDidTapEdit(_ cell: ProfileTableViewCell) {
        let vc = SetupIntroViewController()
        vc.isFromMyProfile = true
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
}

// MARK: - PopupCencelRequestDelegate
extension ProfileDetailViewController: PopupCencelRequestDelegate {
    func popupCencelRequestDidTapYes(requestId: Int) {
        self.showHud()
        connectService.cancelRequest(requestId: requestId,
                                     complete: { (result) in
                                        switch result {
                                        case .success(let response):
                                            self.viewModel = ProfileDetailViewModel()
                                            self.viewModel.parseProfile(response.data)
                                            self.tableView.reloadData()
                                            NotificationCenter.default.post(name: .kRefreshConnections,
                                                                            object: nil,
                                                                            userInfo: nil)
                                            self.getMutualConnections()
                                            break
                                        case .failure(let error):
                                            self.alertWithError(error)
                                            self.hideHude()
                                            break
                                        }
        })
    }
}

// MARK: - PopupSendRequestDelegate
extension ProfileDetailViewController: PopupSendRequestDelegate {
    
    func popupSendRequest(_ controller: PopupSendRequest, didClose sender: UIButton, success: Bool) {
        controller.dismiss(animated: true, completion: nil)
        if success {
            getUserData()
        }
    }
}

// MARK: - BaseNewFeedTableViewCellDelegate
extension ProfileDetailViewController: BaseNewFeedTableViewCellDelegate {
    func baseNewFeedTableViewCellDidTapAvatar(_ url: String) {
        openPhotoViewer([url])
    }
    
    func baseNewFeedTableViewCellShouldPlayVideo(_ cell: BaseNewFeedTableViewCell, link: String) {
        self.playVideo(link, true)
    }
    
    func baseNewFeedTableViewCellDidSelectLike(_ cell: BaseNewFeedTableViewCell) {
        guard let  indexPath = tableView.indexPath(for: cell) else { return }
        newsFeedService.likePost(id: viewModel.sections[0].rows[indexPath.row].objectID) { (result) in
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
    
    func baseNewFeedTableViewCell(_ cell: BaseNewFeedTableViewCell) {
        UIView.setAnimationsEnabled(false)
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.updateCollapseDesc(index: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        UIView.setAnimationsEnabled(true)
    }
    
    func baseNewFeedTableViewCellDidSelectAsset(_ cell: BaseNewFeedTableViewCell, listImage: [String]) {
        openPhotoViewer(listImage)
    }
    
    func baseNewFeedTableViewCellDidSelectShare(_ cell: BaseNewFeedTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        self.alertButtonWithTitle("Confirm".localized(), message: "Do you want to share this post?".localized(), completion: {
            self.showHud()
            self.newsFeedService.sharePost(postId: "\(cell.model?.data.id.description ?? "")", complete: { (result) in
                self.hideHude()
                switch result {
                case .success(let response):
                    self.viewModel.addNewPost(response.data)
                    self.viewModel.updateShare(index: indexPath.row)
                    UIView.setAnimationsEnabled(false)
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
                    UIView.setAnimationsEnabled(true)
                    break
                case .failure(let error):
                    self.alertWithError(error)
                    break
                }
            })
        })
    }
    
    func baseNewFeedTableViewCellDidSelectMore(_ cell: BaseNewFeedTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let actionController = YoutubeActionController()
        
        actionController.addAction(Action(ActionData(title: "Share via".localized(), image: #imageLiteral(resourceName: "shareWhite")), style: .default, handler: { action in
            guard let rowModel = self.viewModel.sections[0].rows[indexPath.row] as? NewFeedRowModel else {
                return
            }
            self.shareNewfeed(rowModel.data.url,
                              postID: rowModel.objectID)
        }))
        
        if cell.model?.data.author.id == DataManager.getCurrentUserModel()?.id {
            if cell.model?.data.parent == nil {
                actionController.addAction(Action(ActionData(title: "Edit Post".localized(), image: #imageLiteral(resourceName: "editWhite")), style: .default, handler: { action in
                    let editPostVC = NewPostViewController()
                    editPostVC.newFeedModel = cell.model?.data
                    let nav = BaseNavigationController.init(rootViewController: editPostVC)
                    self.present(nav, animated: true, completion: nil)
                }))
            }
            actionController.addAction(Action(ActionData(title: "Delete Post".localized(), image: #imageLiteral(resourceName: "closeWhite")), style: .default, handler: { action in
                self.alertButtonWithTitle("Confirm".localized(), message: "This post will be deleted and you won't be able to find it anymore.".localized(), completion: {
                    self.showHud()
                    self.newsFeedService.deletePost(postId: "\(cell.model?.data.id.description ?? "")", complete: { (result) in
                        self.hideHude()
                        switch result {
                        case .success( _):
                            self.viewModel.deletePost(indexPath.row)
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
                popup.postId = self.viewModel.sections[0].rows[indexPath.row].objectID
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
}

// MARK: - ProfileHeaderViewDelegate
extension ProfileDetailViewController: ProfileHeaderViewDelegate {
    
    func profileHeaderViewDidTapEdit(sectionIndex: Int) {
        switch sectionIndex {
        case 1:
            let vc = MyInterestsViewController()
            vc.isFromMyProfile = true
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            self.hidesBottomBarWhenPushed = false
            break
        case 2:
            let vc = MyIndustryViewController()
            vc.isFromMyProfile = true
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            self.hidesBottomBarWhenPushed = false
            break
        case 3:
            guard let user = self.viewModel.user else { return }
            guard user.occupations.count > 0 else { return }
            let vc = OccupationViewController()
            vc.isFromMyProfile = true
            vc.currentUserOccupation = user.occupations.first
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            self.hidesBottomBarWhenPushed = false
            break
        default:
            break
        }
    }
}

