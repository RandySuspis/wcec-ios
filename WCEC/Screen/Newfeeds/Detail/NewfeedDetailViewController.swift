//
//  NewfeedDetailViewController.swift
//  WCEC
//
//  Created by GEM on 6/20/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import XLActionController
import RSKKeyboardAnimationObserver
import AVKit

class NewfeedDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var growTextView: RSKGrowingTextView!
    @IBOutlet weak var bottomInputCommentConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentInputContainer: UIView!
    
    fileprivate var refreshControl = UIRefreshControl()
    private var isVisibleKeyboard = true
    let newfeedService = NewsfeedService()
    var viewModel = NewfeedDetailViewModel()
    var newfeedId: String?
    var isFromSearchConnections = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getNewfeedDetail(false)
        addRefreshControl()
        addNotificationCenter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.registerForKeyboardNotifications()
        growTextView.maximumNumberOfLines = 3
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.unregisterForKeyboardNotifications()
    }
    
    func addNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshData),
                                               name: .kRefreshNewfeedDetail,
                                               object: nil)
    }
    
    func setupUI() {
        growTextView.layer.masksToBounds = true
        growTextView.layer.cornerRadius = 5.0
        growTextView.placeholder = "Leave comments…".localized() as NSString
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.backBarItem(target: self, btnAction: #selector(backAction))
        
        let cellList = [NewFeedPhotoTableViewCell.nibName(),
                        NewFeedNoAssetTableViewCell.nibName(),
                        NewFeedEmbedLinkTableViewCell.nibName(),
                        NewFeedVideoTableViewCell.nibName(),
                        NewfeedCommentTableViewCell.nibName()]
        cellList.forEach({
            tableView.register(UINib(nibName: $0, bundle: nil),
                               forCellReuseIdentifier: $0)
        })
        
        if !DataManager.checkIsGuestUser() {
            commentInputContainer.isHidden = false
        } else {
            commentInputContainer.isHidden = true
        }
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        tableView?.addSubview(refreshControl)
    }
    
    @objc func pullToRefresh() {
        getNewfeedDetail(false)
    }
    
    @objc func refreshData() {
        getNewfeedDetail(true)
    }
    
    @objc func getNewfeedDetail(_ isScrollToBottom: Bool) {
        guard let newfeedId = newfeedId else { return }
        self.showHud()
        newfeedService.getDetailPost(newfeedId) { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                self.viewModel.parseData(response.data)
                self.tableView.reloadData()
                if isScrollToBottom && response.data.comments.count > 1 {
                    self.tableView.scrollToBottom()
                }
                break
            case .failure(let error):
                self.alertWithError(error)
                break
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - Comment Keyboard
    
    @IBAction func onSendComment(_ sender: Any) {
        guard growTextView.text != "" else {
            alertWithTitle("Alert".localized(), message: "Please input comment".localized())
            return
        }
        guard let newfeedId = newfeedId else { return }
        showHud()
        newfeedService.createComment(newfeedId,
                                     content: growTextView.text) { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                self.growTextView.resignFirstResponder()
                self.growTextView.text = ""
                self.growTextView.placeholder = "Leave comments…".localized() as NSString
                self.viewModel.addComment(response.data)
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: self.viewModel.sections[1].rows.count - 1,
                                                         section: 1),
                                           at: .bottom,
                                           animated: true)
                self.postNotificationCenterRefresh()
                break
            case . failure(let error):
                self.alertWithError(error)
                break
            }
        }
    }
    
    private func registerForKeyboardNotifications() {
        self.rsk_subscribeKeyboardWith(beforeWillShowOrHideAnimation: nil,
                                       willShowOrHideAnimation: { [unowned self] (keyboardRectEnd, duration, isShowing) -> Void in
                                        self.isVisibleKeyboard = isShowing
                                        self.adjustContent(for: keyboardRectEnd)
            }, onComplete: { (finished, isShown) -> Void in
                self.isVisibleKeyboard = isShown
        }
        )
        
        self.rsk_subscribeKeyboard(willChangeFrameAnimation: { [unowned self] (keyboardRectEnd, duration) -> Void in
            self.adjustContent(for: keyboardRectEnd)
            }, onComplete: nil)
    }
    
    private func adjustContent(for keyboardRect: CGRect) {
        let keyboardHeight = keyboardRect.height
        let keyboardYPosition = self.isVisibleKeyboard ?
            keyboardHeight : 0.0;
        self.bottomInputCommentConstraint.constant = keyboardYPosition
        self.view.layoutIfNeeded()
    }
    
    private func unregisterForKeyboardNotifications() {
        self.rsk_unsubscribeKeyboard()
    }
    
    @IBAction func handleTapGesture(_ sender: Any) {
        self.growTextView.resignFirstResponder()
    }

    func openPhotoViewer(_ listImage: [Any]) {
        let vc = PhotoViewerViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.listPhoto = listImage
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
}

extension NewfeedDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let rowModel = viewModel.sections[indexPath.section].rows[indexPath.row] as? NewFeedRowModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                     for: indexPath) as! BaseNewFeedTableViewCell
            cell.bindingWithModel(rowModel)
            cell.delegate = self
            
            return cell
        } else if let rowModel = viewModel.sections[indexPath.section].rows[indexPath.row] as? NewfeedCommentRowModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                     for: indexPath) as! NewfeedCommentTableViewCell
            cell.bindingWithModel(rowModel)
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
}

extension NewfeedDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: Constants.screenWidth, height: 2))
            view.backgroundColor = AppColor.colorGray250()
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else if section == 1 {
            return 2.0
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = AppColor.colorPinkLow()
            } else {
                cell.backgroundColor = UIColor.white
            }
        }
    }
}

extension NewfeedDetailViewController: BaseNewFeedTableViewCellDelegate {
    func baseNewFeedTableViewCellDidTapAvatar(_ url: String) {
        openPhotoViewer([url])
    }
    
    func baseNewFeedTableViewCellDidSelectedTags(_ cell: BaseNewFeedTableViewCell) {
        UIView.setAnimationsEnabled(false)
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.updateCollapse()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        UIView.setAnimationsEnabled(true)
    }
    
    func baseNewFeedTableViewCellDidSelectAsset(_ cell: BaseNewFeedTableViewCell, listImage: [String]) {
        openPhotoViewer(listImage)
    }

    func baseNewFeedTableViewCellShouldPlayVideo(_ cell: BaseNewFeedTableViewCell, link: String) {
        guard let videoUrl = URL(string: link) else { return }
        let player = AVPlayer(url: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.modalTransitionStyle = .crossDissolve
        playerViewController.modalPresentationStyle = .overCurrentContext
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(playerViewController, animated: true, completion: {
                playerViewController.player?.play()
            })
        }
    }

    func baseNewFeedTableViewCellDidSelectMore(_ cell: BaseNewFeedTableViewCell) {
        guard let  indexPath = self.tableView.indexPath(for: cell) else { return }
        let actionController = YoutubeActionController()
        actionController.addAction(Action(ActionData(title: "Share via".localized(), image: #imageLiteral(resourceName: "shareWhite")), style: .default, handler: { action in
            guard let rowModel = self.viewModel.sections[0].rows[indexPath.row] as? NewFeedRowModel else {
                return
            }
            if let url = URL(string: rowModel.data.url) {
                let controller = UIActivityViewController(activityItems: [url],
                                                          applicationActivities: nil)
                if let wPPC = controller.popoverPresentationController {
                    wPPC.sourceView = self.view
                }
                controller.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                    if completed {
                        self.newfeedService.sharePostVia(postId: rowModel.objectID,
                                                         complete: { (_) in
                        })
                    }
                }
                self.present(controller, animated: true, completion: nil)
            } else {
                self.alertDefault()
            }
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
                    self.newfeedService.deletePost(postId: "\(cell.model?.data.id.description ?? "")", complete: { (result) in
                        self.hideHude()
                        switch result {
                        case .success( _):
                            self.postNotificationCenterRefresh()
                            self.navigationController?.popViewController(animated: true)
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
                // becase not inherit baseviewcontroller
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    
                    // topController should now be your topmost view controller
                    topController.present(popup, animated: true, completion: nil)
                }
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
            self.newfeedService.sharePost(postId: "\(cell.model?.data.id.description ?? "")", complete: { (result) in
                self.hideHude()
                switch result {
                case .success(_):
                    self.alertView("Success".localized(), message: "Post has been shared successfully".localized())
                    self.viewModel.updateShare()
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.postNotificationCenterRefresh()
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
        newfeedService.likePost(id: viewModel.sections[0].rows[indexPath.row].objectID) { (result) in
            switch result {
            case .success(_):
                self.viewModel.updateLike()
                UIView.setAnimationsEnabled(false)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                UIView.setAnimationsEnabled(true)
                self.postNotificationCenterRefresh()
                break
            case .failure(_):
                break
            }
        }
    }
}

extension NewfeedDetailViewController: NewfeedCommentTableViewCellDelegate {
    func newfeedCommentTableViewCellDidTapAvatar(url: String) {
        openPhotoViewer([url])
    }

    
    func newfeedCommentTableViewCellShouldDelete(_ cell: NewfeedCommentTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        self.alertButtonWithTitle("Confirm".localized(), message: "This comment will be deleted and you won't be able to find it anymore.".localized(), completion: {
            self.showHud()
            self.newfeedService.deleteComment(self.viewModel.sections[indexPath.section].rows[indexPath.row].objectID,
                                              complete: { (result) in
                                                self.hideHude()
                                                switch result {
                                                case .success(_):
                                                    self.viewModel.deleteComment(indexPath.row)
                                                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                                                    self.tableView.reloadData()
                                                    self.postNotificationCenterRefresh()
                                                    break
                                                case .failure(let error):
                                                    self.alertWithError(error)
                                                    break
                                                }
            })
        })
    }
}

extension NewfeedDetailViewController {
    
    func postNotificationCenterRefresh() {
        NotificationCenter.default.post(name: .kRefreshMyProfile,
                                        object: nil,
                                        userInfo: nil)
        NotificationCenter.default.post(name: .kRefreshListNewfeed,
                                        object: nil,
                                        userInfo: nil)
    }
}











