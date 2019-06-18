//
//  NewPostViewController.swift
//  WCEC
//
//  Created by hnc on 6/5/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import UITextView_Placeholder

class NewPostViewController: BaseViewController {
    
    // MARK: - IBOutlet
    @IBOutlet var toolbarView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var galleryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var galleryCollectionView: UICollectionView!
    
    // MARK: - Variable
    fileprivate var selectedAssets = [TLPHAsset]()
    fileprivate var queue = DispatchQueue(label: "NewPostGalleryQueue")
    fileprivate var photoLibrary = TLPhotoLibrary()
    fileprivate var thumbnailSize = CGSize.zero
    fileprivate var requestIds = [IndexPath:PHImageRequestID]()
    
    let mediaService = MediaService()
    var newPostViewModel = NewPostViewModel.shareInstance
    var imageList = [UIImage]()
    var newFeedModel: NewfeedModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        newPostViewModel.clearData()
        setupUI()
        if newFeedModel != nil {
            newPostViewModel.bindingWithModel(newFeedModel!)
            if newFeedModel?.content.count != 0 {
                textView.textColor = AppColor.colorTextField()
                textView.text = newFeedModel?.content
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }

            if newPostViewModel.currentMedia.count > 0 {
                galleryHeightConstraint.constant = 144
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            galleryCollectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolbarViewBottomConstraint.constant = 0
        NotificationCenter.default.addObserver(self, selector: #selector(keyboarWillShow(sender:)), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        toolbarViewBottomConstraint.constant = 0
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Setup
    override func setupLocalized() {
        self.navigationItem.title = "New Post".localized()
        textView.placeholder = "Write something...".localized()
    }
    
    func setupUI() {
        galleryHeightConstraint.constant = 0

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.nextBarButton(target: self, selector: #selector(onNext))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.closeBarItem(target: self, btnAction: #selector(onSelectClose))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
       
        self.galleryCollectionView.register(UINib(nibName: "NewPostGalleryCollectionViewCell", bundle: Bundle(for: NewPostGalleryCollectionViewCell.self)), forCellWithReuseIdentifier: "NewPostGalleryCollectionViewCell")
        setupCollectionFlowLayout()
        
        textView.setLeftPaddingPoints(16)
        textView.textColor = AppColor.colorTitleTextField()
        textView.delegate = self
    }
    
    func setupCollectionFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        let count = CGFloat(3)
        let width = (UIScreen.main.bounds.size.width-13-(5*(count-1)))/count
        thumbnailSize = CGSize(width: width, height: width)
        layout.itemSize = thumbnailSize
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10)
        layout.scrollDirection = .horizontal
        self.galleryCollectionView.collectionViewLayout = layout
    }
    
    //MARK: Action
    @objc func onNext() {
        newPostViewModel.content = textView.text
        if self.selectedAssets.count == 0 {
            pushtoAddTagView()
        } else {
            var images = [Any]()
            for asset in self.selectedAssets {
                if self.newPostViewModel.mediaType == .video {
                    if let phAsset = asset.phAsset {
                        let options = PHVideoRequestOptions()
                        options.deliveryMode = .fastFormat
                        PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { (avAsset, audioMix, info) in
                            if let urlAsset = avAsset as? AVURLAsset {
                                do {
                                    let videoData = try Data(contentsOf: (urlAsset.url))
                                    print("video data : \(videoData)")
                                    self.newPostViewModel.videoData = videoData
                                } catch  {
                                    print("exception catch at block - while uploading video")
                                }
                                images.append(urlAsset.url)
                                self.newPostViewModel.listGallery = images
                                DispatchQueue.main.async(execute: {
                                    self.pushtoAddTagView()
                                })
                            }
                        }
                    }
                } else {
                    if let phAsset = asset.phAsset {
                        images.append(convertImageFromAsset(asset: phAsset))
                    }
                    if asset == self.selectedAssets.last {
                        self.newPostViewModel.listGallery = images
                        pushtoAddTagView()
                    }
                }
            }
        }
    }
    
    func pushtoAddTagView() {
        let postAddTagsVC = PostAddTagsViewController()
        self.navigationController?.pushViewController(postAddTagsVC, animated: true)
    }
    
    @objc func onSelectClose() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        toolbarViewBottomConstraint.constant = 0
    }
    
    @objc func keyboarWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            toolbarViewBottomConstraint.constant = keyboardSize.height
        }
    }
    
    // MARK: - IBAction
    @IBAction func onSelectGallery(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                let galleryVC = GalleryViewController()
                galleryVC.delegate = self
                galleryVC.selectedAssets = self.selectedAssets
                galleryVC.mediaType = self.newPostViewModel.mediaType
                let navi = BaseNavigationController.init(rootViewController: galleryVC)
                navi.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(navi, animated: true, completion: nil)
                break
            default:
                self.showAlertGoToPhotoSetting()
                break
            }
        }
    }
    
    @IBAction func onSelectSetting(_ sender: Any) {
        let postSettingVC = PostSettingViewController()
        self.navigationController?.pushViewController(postSettingVC, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension NewPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.navigationItem.rightBarButtonItem?.isEnabled = !(textView.text.isEmpty && selectedAssets.isEmpty)
    }
}

// MARK: - GalleryViewControllerDelegate
extension NewPostViewController: GalleryViewControllerDelegate {
    func didSelectGallery(controller: GalleryViewController, withTLPHAssets: [TLPHAsset], mediaType: PHAssetMediaType) {
        controller.dismiss(animated: true, completion: nil)
        setupCollectionFlowLayout()
        self.selectedAssets = withTLPHAssets
        
        if withTLPHAssets.count > 0 {
            if newPostViewModel.mediaType == .video && mediaType == .image {
                newPostViewModel.currentMedia.removeAll()
            } else if mediaType == .video {
                newPostViewModel.currentMedia.removeAll()
            }
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            galleryHeightConstraint.constant = 144
        } else {
            if newPostViewModel.currentMedia.count > 0 {
                galleryHeightConstraint.constant = 144
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                galleryHeightConstraint.constant = 0
                if textView.textColor == AppColor.colorTitleTextField() {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                } else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
        }
        self.newPostViewModel.mediaType = mediaType
        galleryCollectionView.reloadData()
        self.galleryCollectionView.reloadInputViews()
    }
}

// MARK: - UICollectionViewDataSource
extension NewPostViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        func makeCell(nibName: String) -> NewPostGalleryCollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibName, for: indexPath) as! NewPostGalleryCollectionViewCell
            return cell
        }
        let nibName = "NewPostGalleryCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibName, for: indexPath) as! NewPostGalleryCollectionViewCell
        if self.newPostViewModel.mediaType == .video {
            cell.imageView.image = #imageLiteral(resourceName: "videoPlaceholder")
            cell.videoIcon.isHidden = false
        } else {
            cell.imageView.image = #imageLiteral(resourceName: "galleryPlaceholder")
            cell.videoIcon.isHidden = true
        }
        
        if newPostViewModel.currentMedia.count > 0 && self.selectedAssets.count > 0 {
            switch indexPath.section {
            case 0:
                if newPostViewModel.mediaType == .image {
                    cell.imageView.kf.setImage(with: URL(string: self.newPostViewModel.currentMedia[indexPath.row].thumb_file_url),
                                               placeholder: #imageLiteral(resourceName: "galleryPlaceholder"),
                                               options: nil,
                                               progressBlock: nil,
                                               completionHandler: nil)
                } else {
                    cell.imageView.kf.setImage(with: URL(string: self.newPostViewModel.currentMedia[indexPath.row].thumb_file_url),
                                               placeholder: #imageLiteral(resourceName: "galleryPlaceholder"),
                                               options: nil,
                                               progressBlock: nil,
                                               completionHandler: nil)
                }
                
            case 1:
                if let phAsset = self.selectedAssets[indexPath.row].phAsset {
                    if phAsset.mediaType == .video {
                        cell.imageView.image = #imageLiteral(resourceName: "videoPlaceholder")
                        cell.videoIcon.isHidden = false
                    } else {
                        cell.imageView.image = #imageLiteral(resourceName: "galleryPlaceholder")
                        cell.videoIcon.isHidden = true
                    }
                    
                    queue.async { [weak self, weak cell] in
                        guard let `self` = self else { return }
                        let requestId = self.photoLibrary.imageAsset(asset: phAsset, size: self.thumbnailSize, completionBlock: { (image,complete) in
                            DispatchQueue.main.async {
                                if self.requestIds[indexPath] != nil {
                                    cell?.imageView?.image = image
                                    if complete {
                                        self.requestIds.removeValue(forKey: indexPath)
                                    }
                                }
                            }
                        })
                        if requestId > 0 {
                            self.requestIds[indexPath] = requestId
                        }
                    }
                }
            default:
                return cell
            }
        } else if newPostViewModel.currentMedia.count > 0 && self.selectedAssets.count == 0 {
            if newPostViewModel.mediaType == .image {
                cell.imageView.kf.setImage(with: URL(string: self.newPostViewModel.currentMedia[indexPath.row].thumb_file_url),
                                           placeholder: #imageLiteral(resourceName: "galleryPlaceholder"),
                                           options: nil,
                                           progressBlock: nil,
                                           completionHandler: nil)
            } else {
                cell.imageView.kf.setImage(with: URL(string: self.newPostViewModel.currentMedia[indexPath.row].thumb_file_url),
                                           placeholder: #imageLiteral(resourceName: "galleryPlaceholder"),
                                           options: nil,
                                           progressBlock: nil,
                                           completionHandler: nil)
            }
        } else if newPostViewModel.currentMedia.count == 0 && self.selectedAssets.count > 0 {
            if let phAsset = self.selectedAssets[indexPath.row].phAsset {
                if phAsset.mediaType == .video {
                    cell.imageView.image = #imageLiteral(resourceName: "videoPlaceholder")
                    cell.videoIcon.isHidden = false
                } else {
                    cell.imageView.image = #imageLiteral(resourceName: "galleryPlaceholder")
                    cell.videoIcon.isHidden = true
                }
                
                queue.async { [weak self, weak cell] in
                    guard let `self` = self else { return }
                    let requestId = self.photoLibrary.imageAsset(asset: phAsset, size: self.thumbnailSize, completionBlock: { (image,complete) in
                        DispatchQueue.main.async {
                            if self.requestIds[indexPath] != nil {
                                cell?.imageView?.image = image
                                if complete {
                                    self.requestIds.removeValue(forKey: indexPath)
                                }
                            }
                        }
                    })
                    if requestId > 0 {
                        self.requestIds[indexPath] = requestId
                    }
                }
            }
        }
        
        cell.index = indexPath
        cell.delegate = self
        cell.alpha = 0
        UIView.transition(with: cell, duration: 0.1, options: .curveEaseIn, animations: {
            cell.alpha = 1
        }, completion: nil)
        return cell
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        if newPostViewModel.currentMedia.count > 0 && self.selectedAssets.count > 0 {
            return 2
        }
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if newPostViewModel.currentMedia.count > 0 && self.selectedAssets.count > 0 {
            switch section {
            case 0:
                return newPostViewModel.currentMedia.count
            case 1:
                return self.selectedAssets.count
            default:
                return 0
            }
        } else if newPostViewModel.currentMedia.count > 0 && self.selectedAssets.count == 0 {
            return newPostViewModel.currentMedia.count
        } else if newPostViewModel.currentMedia.count == 0 && self.selectedAssets.count > 0 {
            return self.selectedAssets.count
        } else {
            return 0
        }
    }
}

// MARK: - UICollectionViewDelegate
extension NewPostViewController: UICollectionViewDelegate {
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if newPostViewModel.currentMedia.count > 0 && self.selectedAssets.count > 0 {
            var medias = [Any]()
            for item in self.newPostViewModel.currentMedia {
                medias.append(item.file_url)
            }

            for asset in self.selectedAssets {
                if let phAsset = asset.phAsset {
                    medias.append(convertImageFromAsset(asset: phAsset))
                }
            }

            switch indexPath.section {
            case 0:
                if newPostViewModel.mediaType == .image {
                    newPostOpenPhotoViewer(medias, index: indexPath.row)
                } else {
                    self.playVideo(self.newPostViewModel.currentMedia[indexPath.row].file_url, false)
                }
            case 1:
                if let phAsset = self.selectedAssets[indexPath.row].phAsset {
                    if phAsset.mediaType == .video {
                        self.playVideo(phAsset)
                    } else {
                        newPostOpenPhotoViewer(medias, index: indexPath.row + self.newPostViewModel.currentMedia.count)
                    }
                }
            default:
                break
            }
        } else if newPostViewModel.currentMedia.count > 0 && self.selectedAssets.count == 0 {
            if newPostViewModel.mediaType == .image {
                var medias = [String]()
                for item in self.newPostViewModel.currentMedia {
                    medias.append(item.file_url)
                }
                newPostOpenPhotoViewer(medias, index: indexPath.row)
                
            } else {
                self.playVideo(self.newPostViewModel.currentMedia[indexPath.row].file_url, false)
            }
        } else if newPostViewModel.currentMedia.count == 0 && self.selectedAssets.count > 0 {
            if let phAsset = self.selectedAssets[indexPath.row].phAsset {
                if phAsset.mediaType == .video {
                    self.playVideo(phAsset)
                } else {
                    var images = [UIImage]()
                    for asset in self.selectedAssets {
                        if let phAsset = asset.phAsset {
                                images.append(convertImageFromAsset(asset: phAsset))
                        }
                        if asset == self.selectedAssets.last {
                            newPostOpenPhotoViewer(images, index: indexPath.row)
                        }
                    }
                }
            }
        }
    }

    func newPostOpenPhotoViewer(_ listImage: [Any], index: Int) {
        let vc = PhotoViewerViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.canEdit = true
        vc.listPhoto = listImage
        vc.currentIndex = index + 1
        vc.delegate = self
        self.presentVC(vc: vc)
    }
}

extension NewPostViewController: PhotoViewerViewControllerDelegate {

    func photoViewerViewControllerDidEdittedImageUrl(image: FileModel, index: Int) {
        if self.newPostViewModel.currentMedia.count > index  {
            self.newPostViewModel.currentMedia[index] = image
            self.galleryCollectionView.reloadData()
        }
    }

    func photoViewerViewControllerDidEdittedImage(image: PHAsset, index: Int) {
        if newPostViewModel.currentMedia.count > 0 && self.selectedAssets.count > 0 {
            if selectedAssets.count > index - newPostViewModel.currentMedia.count  {
                self.selectedAssets[index - newPostViewModel.currentMedia.count] = TLPHAsset(asset: image)
                self.galleryCollectionView.reloadData()
            }
        } else {
            if selectedAssets.count > index  {
                self.selectedAssets[index] = TLPHAsset(asset: image)
                self.galleryCollectionView.reloadData()
            }
        }
    }
}

// MARK: - NewPostGalleryCollectionViewCellDelegate
extension NewPostViewController: NewPostGalleryCollectionViewCellDelegate {
    func didRemoveItem(cell: NewPostGalleryCollectionViewCell, atIndex: IndexPath) {
        
        if newPostViewModel.currentMedia.count > 0 && self.selectedAssets.count > 0 {
            switch atIndex.section {
            case 0:
                newPostViewModel.currentMedia.remove(at: atIndex.row)
                break
            case 1:
                self.selectedAssets.remove(at: atIndex.row)
                break
            default:
                break
            }
        } else if newPostViewModel.currentMedia.count > 0 && self.selectedAssets.count == 0 {
            newPostViewModel.currentMedia.remove(at: atIndex.row)
        } else if newPostViewModel.currentMedia.count == 0 && self.selectedAssets.count > 0 {
            self.selectedAssets.remove(at: atIndex.row)
        } 
        self.galleryCollectionView.reloadData()
        if newPostViewModel.currentMedia.count == 0 && self.selectedAssets.count == 0 {
            self.galleryHeightConstraint.constant = 0
            if textView.text.isEmpty {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}


