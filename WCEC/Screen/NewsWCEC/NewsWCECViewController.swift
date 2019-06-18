//
//  NewsWCECViewController.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import XLActionController

class NewsWCECViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var refreshControl = UIRefreshControl()
    var userService = UserService()
    var viewModel = NewsWCECViewModel()
    var newsFeedService = NewsfeedService()
    var storedOffsets = [Int: CGFloat]()
    var onceOnly = false
    var counterTime: Int = 10
    var timer: Timer!
    var currentIndexBanner = 0
    let max = 999
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
        addRefreshControl()
    }

    override func setupLocalized() {
        self.navigationController?.navigationBar.topItem?.title = "WCEC".localized()
    }
    
    func setupUI() {
        self.navigationItem.leftBarButtonItem = nil
        if DataManager.checkIsGuestUser() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.loginBarButton(target: self, selector: #selector(onSelectLogin))
        }
        let cellList = [NewFeedPhotoTableViewCell.nibName(),
                        NewFeedNoAssetTableViewCell.nibName(),
                        NewFeedEmbedLinkTableViewCell.nibName(),
                        NewFeedVideoTableViewCell.nibName(),
                        CarouselTableViewCell.nibName()]
        cellList.forEach({
            tableView.register(UINib(nibName: $0, bundle: nil),
                               forCellReuseIdentifier: $0)
        })
        tableView.register(UINib(nibName: HeaderSectionNewsWcec.nibName(), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: HeaderSectionNewsWcec.nibName())
    }
    
    @objc func getData() {
        showHud()
        currentPage = 1
        let pager = Pager(page: currentPage, per_page: Constants.kDefaultLimit)
        userService.getWcecContent(pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.parseNewfeed(response.data)
                break
            case .failure(let error):
                self.alertWithError(error)
                break
            }
            self.getBanner()
        }
    }
    
    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(getData), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        tableView?.addSubview(refreshControl)
    }
    
    func getBanner() {
        userService.getListBanner { (result) in
            switch result {
            case .success(let response):
                self.viewModel.listBanner = response.data
                self.startTimer()
                break
            case .failure(_):
                break
            }
            self.hideHude()
            self.tableView.reloadData()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func startTimer() {
        counterTime = 10
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(updateSlider),
                                     userInfo: nil,
                                     repeats: true)
        timer.fire()
    }
    
    @objc func updateSlider() {
        if self.viewModel.listBanner.count == 0 {
            return
        }
        counterTime -= 1
        if counterTime == 0 {
            timer.invalidate()
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CarouselTableViewCell {
                if currentIndexBanner == self.viewModel.listBanner.count * max - 1 {
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                } else {
                    currentIndexBanner += 1
                    cell.collectionView.scrollToItem(at: IndexPath(item: currentIndexBanner,
                                                                   section: 0), at: .centeredHorizontally, animated: true)
                    cell.pageControl.currentPage = currentIndexBanner % self.viewModel.listBanner.count
                    startTimer()
                }
            }
        }
    }
    
    @objc func onSelectLogin() {
        Constants.appDelegate.setupAuthentication()
    }
}

extension NewsWCECViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Constants.screenWidth/(320/183) + 30
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let sectionModel = viewModel.sections[section]
            if sectionModel.header.identifier != nil && !sectionModel.rows.isEmpty {
                let view = HeaderSectionNewsWcec.dequeueReuseHeaderWithNib(in: tableView, reuseIdentifier: HeaderSectionNewsWcec.nibName())
                view.titleLabel?.text = sectionModel.header.title
                return view
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = viewModel.sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                 for: indexPath)
        if let cell = cell as? BaseNewFeedTableViewCell,
            let rowModel = rowModel as? NewFeedRowModel{
            cell.bindingWithModel(rowModel)
            cell.delegate = self
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? CarouselTableViewCell else { return }
        cell.pageControl.numberOfPages = self.viewModel.listBanner.count
        cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        cell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? CarouselTableViewCell else { return }
        storedOffsets[indexPath.row] = cell.collectionViewOffset
    }
}

extension NewsWCECViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let vc = NewfeedDetailViewController()
        let rowModel = viewModel.sections[indexPath.section].rows[indexPath.row]
        vc.newfeedId = rowModel.objectID
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
}

extension NewsWCECViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.listBanner.count * max
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCollectionViewCell.classString(), for: indexPath) as! CarouselCollectionViewCell
        cell.imageView.kf.setImage(with: URL(string: self.viewModel.listBanner[indexPath.row % self.viewModel.listBanner.count].image.file_url),
                                   placeholder: nil,
                                   options: nil,
                                   progressBlock: nil,
                                   completionHandler: nil)
        return cell
    }
    
}

extension NewsWCECViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = WebViewViewController()
        vc.stringUrl = self.viewModel.listBanner[indexPath.row % self.viewModel.listBanner.count].url
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !onceOnly {
            collectionView.scrollToItem(at: IndexPath(item: self.viewModel.listBanner.count * 100, section: 0), at: .centeredHorizontally, animated: false)
            currentIndexBanner = self.viewModel.listBanner.count * 100
            self.onceOnly = true
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CarouselTableViewCell {
                cell.pageControl.currentPage = 100 % self.viewModel.listBanner.count
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        if let collectionView = scrollView as? UICollectionView {
            visibleRect.origin = collectionView.contentOffset
            visibleRect.size = collectionView.bounds.size
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CarouselTableViewCell {
                cell.pageControl.currentPage = indexPath.row % self.viewModel.listBanner.count
                self.currentIndexBanner = indexPath.row
            }
        }
    }
}

extension NewsWCECViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.screenWidth, height: collectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension NewsWCECViewController: BaseNewFeedTableViewCellDelegate {
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
            if let rowModel = self.viewModel.sections[1].rows[indexPath.row] as? NewFeedRowModel {
                self.shareWithLink(rowModel.data.url)
            }
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
                popup.postId = self.viewModel.sections[1].rows[indexPath.row].objectID
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
        newsFeedService.likePost(id: self.viewModel.sections[1].rows[indexPath.row].objectID) { (result) in
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






