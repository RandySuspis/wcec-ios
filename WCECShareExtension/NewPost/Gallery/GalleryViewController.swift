//
//  GalleryViewController.swift
//  WCEC
//
//  Created by hnc on 6/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Photos

protocol GalleryViewControllerDelegate: class {
    func didSelectGallery(controller: GalleryViewController, withTLPHAssets: [TLPHAsset], mediaType: PHAssetMediaType)
}

extension GalleryViewControllerDelegate {
    public func didSelectGallery(controller: GalleryViewController, withTLPHAssets: [TLPHAsset], mediaType: PHAssetMediaType) { }
}

class GalleryViewController: BasePagerViewController {

    var selectedAssets = [TLPHAsset]()
    let videosVC = PhotosViewController()
    let photosVC = PhotosViewController()
    var mediaType: PHAssetMediaType = .unknown
    
    public weak var delegate: GalleryViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tabPagerView.delegate = self
        self.pagerController.delegate = self
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = "All Photos".localized()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.cancelBarButton(target: self, selector: #selector(onSelectCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.addBarButton(target: self, selector: #selector(onSelectAdd))
    }
    
    @objc func onSelectCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onSelectAdd() {
        self.delegate?.didSelectGallery(controller: self, withTLPHAssets: self.selectedAssets, mediaType: self.mediaType)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func setupData() -> [UIViewController] {
        var configure = TLPhotosPickerConfigure()
        configure.numberOfColumn = 3
        configure.mediaType = .image
        configure.maxSelectedAssets = 10
        //        if #available(iOS 10.2, *) {
        //            configure.cameraCellNibSet = (nibName: "CustomCameraCell", bundle: Bundle.main)
        //        }
        
        photosVC.delegate = self
        photosVC.logDelegate = self
        photosVC.selectedAssets = self.selectedAssets
        photosVC.configure = configure
        
        videosVC.delegate = self
        videosVC.logDelegate = self
        videosVC.selectedAssets = self.selectedAssets
        configure.mediaType = .video
        videosVC.configure = configure
        
        return [photosVC, videosVC]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension GalleryViewController: PhotosViewControllerDelegate {
    func didSelectPhotoPicker(picker: PhotosViewController, withTLPHAssets: [TLPHAsset]) {
        self.selectedAssets.removeAll()
        if picker.configure.mediaType == .video {
            photosVC.selectedAssets.removeAll()
            self.selectedAssets = videosVC.selectedAssets
            if let photoCollection = photosVC.collectionView {
                photoCollection.reloadData()
            }
            self.mediaType = .video
        } else {
            videosVC.selectedAssets.removeAll()
            self.selectedAssets = photosVC.selectedAssets
            if let videoCollection = videosVC.collectionView {
                videoCollection.reloadData()
            }
            self.mediaType = .image
        }
    }
    
    func didExceedMaximumNumberOfSelection(picker: PhotosViewController) {
        self.showExceededMaximumAlert(vc: picker)
    }
    
    func handleNoAlbumPermissions(picker: PhotosViewController) {
        picker.dismiss(animated: true) {
            let alert = UIAlertController(title: "", message: "Denied albums permissions granted", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func handleNoCameraPermissions(picker: PhotosViewController) {
        let alert = UIAlertController(title: "", message: "Denied camera permissions granted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        picker.present(alert, animated: true, completion: nil)
    }
    
    func showExceededMaximumAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "", message: "Please select at most 10 photos".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}

extension GalleryViewController: PhotosViewControllerLogDelegate {
    //For Log User Interaction
    func selectedCameraCell(picker: PhotosViewController) {
        print("selectedCameraCell")
    }
    
    func selectedPhoto(picker: PhotosViewController, at: Int) {
        print("selectedPhoto")
    }
    
    func deselectedPhoto(picker: PhotosViewController, at: Int) {
        print("deselectedPhoto")
    }
    
    func selectedAlbum(picker: PhotosViewController, title: String, at: Int) {
        print("selectedAlbum")
    }
}

extension GalleryViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let index = getIndex(view: pendingViewControllers[0])
        tabPagerView.moveTo(Page: index)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed == false {
            let index = getIndex(view: previousViewControllers[0])
            tabPagerView.moveTo(Page: index)
        }
    }
}

extension GalleryViewController: BaseTabPagerViewDelegate {
    func baseTabPagerView(_ baseTabPagerView: BaseTabPagerView, didSelectAt index: Int) {
        let currentIndex = getIndex()
        if currentIndex < index {
            pagerController.setViewControllers([viewControllers[index]], direction: .forward, animated: true, completion: nil)
        } else {
            pagerController.setViewControllers([viewControllers[index]], direction: .reverse, animated: true, completion: nil)
        }
        switch index {
        case 1:
            self.navigationItem.title = "All Videos".localized()
            break
        default:
            self.navigationItem.title = "All Photos".localized()
            break
        }
    }
}
