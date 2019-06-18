//
//  PhotosViewController.swift
//  WCEC
//
//  Created by hnc on 6/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

public protocol PhotosViewControllerDelegate: class {
    func dismissPhotoPicker(withPHAssets: [PHAsset])
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset])
    func didSelectPhotoPicker(picker: PhotosViewController, withTLPHAssets: [TLPHAsset])
    func dismissComplete()
    func photoPickerDidCancel()
    func didExceedMaximumNumberOfSelection(picker: PhotosViewController)
    func handleNoAlbumPermissions(picker: PhotosViewController)
    func handleNoCameraPermissions(picker: PhotosViewController)
}

extension PhotosViewControllerDelegate {
    public func deninedAuthoization() { }
    public func dismissPhotoPicker(withPHAssets: [PHAsset]) { }
    public func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) { }
    public func didSelectPhotoPicker(picker: PhotosViewController, withTLPHAssets: [TLPHAsset]) { }
    public func dismissComplete() { }
    public func photoPickerDidCancel() { }
    public func didExceedMaximumNumberOfSelection(picker: PhotosViewController) { }
    public func handleNoAlbumPermissions(picker: PhotosViewController) { }
    public func handleNoCameraPermissions(picker: PhotosViewController) { }
}

//for log
public protocol PhotosViewControllerLogDelegate: class {
    func selectedCameraCell(picker: PhotosViewController)
    func deselectedPhoto(picker: PhotosViewController, at: Int)
    func selectedPhoto(picker: PhotosViewController, at: Int)
    func selectedAlbum(picker: PhotosViewController, title: String, at: Int)
}

extension PhotosViewControllerLogDelegate {
    func selectedCameraCell(picker: PhotosViewController) { }
    func deselectedPhoto(picker: PhotosViewController, at: Int) { }
    func selectedPhoto(picker: PhotosViewController, at: Int) { }
    func selectedAlbum(picker: PhotosViewController, collections: [TLAssetsCollection], at: Int) { }
}

open class PhotosViewController: UIViewController {
    public weak var delegate: PhotosViewControllerDelegate? = nil
    
    @IBOutlet weak var collectionView: UICollectionView!
    public weak var logDelegate: PhotosViewControllerLogDelegate? = nil
    public var selectedAssets = [TLPHAsset]()
    public var configure = TLPhotosPickerConfigure()

    fileprivate var thumbnailSize = CGSize.zero
    fileprivate var queue = DispatchQueue(label: "tilltue.photos.pikcker.queue")
    fileprivate var placeholderThumbnail: UIImage? = nil
    fileprivate var cameraImage: UIImage? = nil
    fileprivate var photoLibrary = TLPhotoLibrary()
    
    fileprivate var collections = [TLAssetsCollection]()
    fileprivate var focusedCollection: TLAssetsCollection? = nil
    fileprivate var requestIds = [IndexPath:PHImageRequestID]()
    fileprivate var cloudRequestIds = [IndexPath:PHImageRequestID]()
    fileprivate var playRequestId: (indexPath: IndexPath, requestId: PHImageRequestID)? = nil
    fileprivate var selectedIndex: Int = -1
    fileprivate var usedCameraButton: Bool {
        get {
            return self.configure.usedCameraButton
        }
    }
    fileprivate var allowedVideo: Bool {
        get {
            return self.configure.allowedVideo
        }
    }
    fileprivate var usedPrefetch: Bool {
        get {
            return self.configure.usedPrefetch
        }
        set {
            self.configure.usedPrefetch = newValue
        }
    }
    fileprivate var allowedLivePhotos: Bool {
        get {
            return self.configure.allowedLivePhotos
        }
        set {
            self.configure.allowedLivePhotos = newValue
        }
    }
    
    @objc open var didExceedMaximumNumberOfSelection: ((PhotosViewController) -> Void)? = nil
    @objc open var handleNoAlbumPermissions: ((PhotosViewController) -> Void)? = nil
    @objc open var handleNoCameraPermissions: ((PhotosViewController) -> Void)? = nil
    @objc open var dismissCompletion: (() -> Void)? = nil
    fileprivate var completionWithPHAssets: (([PHAsset]) -> Void)? = nil
    fileprivate var completionWithTLPHAssets: (([TLPHAsset]) -> Void)? = nil
    fileprivate var didCancel: (() -> Void)? = nil
    
    @objc convenience public init(withPHAssets: (([PHAsset]) -> Void)? = nil, didCancel: (() -> Void)? = nil) {
        self.init()
        self.completionWithPHAssets = withPHAssets
        self.didCancel = didCancel
    }
    
    convenience public init(withTLPHAssets: (([TLPHAsset]) -> Void)? = nil, didCancel: (() -> Void)? = nil) {
        self.init()
        self.completionWithTLPHAssets = withTLPHAssets
        self.didCancel = didCancel
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.stopPlay()
    }
    
    func checkAuthorization() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                switch status {
                case .authorized:
                    self?.initPhotoLibrary()
                default:
                    self?.handleDeniedAlbumsAuthorization()
                }
            }
        case .authorized:
            self.initPhotoLibrary()
        case .restricted: fallthrough
        case .denied:
            handleDeniedAlbumsAuthorization()
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        checkAuthorization()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.thumbnailSize == CGSize.zero {
            initItemSize()
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.photoLibrary.delegate == nil {
            initPhotoLibrary()
        }
    }
 
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopPlay()
    }
}

extension PhotosViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching {
    fileprivate func getSelectedAssets(_ asset: TLPHAsset) -> TLPHAsset? {
        if let index = self.selectedAssets.index(where: { $0.phAsset == asset.phAsset }) {
            return self.selectedAssets[index]
        }
        return nil
    }
    
    fileprivate func orderUpdateCells() {
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted(by: { $0.row < $1.row })
        for indexPath in visibleIndexPaths {
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? TLPhotoCollectionViewCell else { continue }
            guard let asset = self.focusedCollection?.getTLAsset(at: indexPath.row) else { continue }
            if let selectedAsset = getSelectedAssets(asset) {
                cell.selectedAsset = true
                cell.orderLabel?.text = "\(selectedAsset.selectedOrder)"
            }else {
                cell.selectedAsset = false
            }
        }
    }
    
    //Delegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collection = self.focusedCollection, let cell = self.collectionView.cellForItem(at: indexPath) as? TLPhotoCollectionViewCell else { return }
        if collection.useCameraButton && indexPath.row == 0 {
            if Platform.isSimulator {
                print("not supported by the simulator.")
                return
            }else {
                if self.configure.cameraCellNibSet?.nibName != nil {
                    cell.selectedCell()
                }else {
                    showCameraIfAuthorized()
                }
                self.logDelegate?.selectedCameraCell(picker: self)
                return
            }
        }
        guard var asset = collection.getTLAsset(at: indexPath.row) else { return }
        cell.popScaleAnim()
        
        
        if let index = self.selectedAssets.index(where: { $0.phAsset == asset.phAsset }) {
            //deselect
            self.logDelegate?.deselectedPhoto(picker: self, at: indexPath.row)
            self.selectedAssets.remove(at: index)
            #if swift(>=4.1)
                self.selectedAssets = self.selectedAssets.enumerated().compactMap({ (offset,asset) -> TLPHAsset? in
                var asset = asset
                asset.selectedOrder = offset + 1
                return asset
                })
            #else
                self.selectedAssets = self.selectedAssets.enumerated().flatMap({ (offset,asset) -> TLPHAsset? in
                    var asset = asset
                    asset.selectedOrder = offset + 1
                    return asset
                })
            #endif
            cell.selectedAsset = false
            cell.stopPlay()
            self.orderUpdateCells()
            //cancelCloudRequest(indexPath: indexPath)
            if self.playRequestId?.indexPath == indexPath {
                stopPlay()
            }
            selectedIndex = -1
        }else {
            //select
            self.logDelegate?.selectedPhoto(picker: self, at: indexPath.row)
            guard !maxCheck() else { return }
            
            checkJustAllowSelect1Video()
            asset.selectedOrder = self.selectedAssets.count + 1
            self.selectedAssets.append(asset)
            //requestCloudDownload(asset: asset, indexPath: indexPath)
            cell.selectedAsset = true
            cell.orderLabel?.text = "\(asset.selectedOrder)"
            if asset.type != .photo, self.configure.autoPlay {
                playVideo(asset: asset, indexPath: indexPath)
            }
            selectedIndex = indexPath.row
        }
        
        self.delegate?.didSelectPhotoPicker(picker: self, withTLPHAssets: self.selectedAssets)
    }
    
    func checkJustAllowSelect1Video() {
        if self.configure.mediaType == .video && self.selectedAssets.count != 0{
            let tempSelectedAssets = self.selectedAssets
            for i in 0..<tempSelectedAssets.count {
                if tempSelectedAssets[i].phAsset?.mediaType == .image {
                    self.selectedAssets.remove(at: i)
                    break
                }
            }
            guard let selectedCell = collectionView.cellForItem(at: IndexPath.init(item: selectedIndex, section: 0)) as? TLPhotoCollectionViewCell else { return }
            selectedCell.selectedAsset = false
            selectedCell.layoutIfNeeded()
            selectedCell.setNeedsLayout()
//            collectionView.reloadItems(at: [IndexPath.init(item: selectedIndex, section: 0)])
            self.selectedAssets.removeAll()
            return
        }
        
        //in case mediatype = image
        let tempSelectedAssets = self.selectedAssets
        for i in 0..<tempSelectedAssets.count {
            if tempSelectedAssets[i].phAsset?.mediaType == .video {
                self.selectedAssets.remove(at: i)
                break
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? TLPhotoCollectionViewCell {
            cell.endDisplayingCell()
            cell.stopPlay()
            if indexPath == self.playRequestId?.indexPath {
                self.playRequestId = nil
            }
        }
        guard let requestId = self.requestIds[indexPath] else { return }
        self.requestIds.removeValue(forKey: indexPath)
        self.photoLibrary.cancelPHImageRequest(requestId: requestId)
    }
    
    //Datasource
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        func makeCell(nibName: String) -> TLPhotoCollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibName, for: indexPath) as! TLPhotoCollectionViewCell
            cell.configure = self.configure
            cell.imageView?.image = self.placeholderThumbnail
            cell.liveBadgeImageView = nil
            return cell
        }
        let nibName = self.configure.nibSet?.nibName ?? "TLPhotoCollectionViewCell"
        var cell = makeCell(nibName: nibName)
        guard let collection = self.focusedCollection else { return cell }
        cell.isCameraCell = collection.useCameraButton && indexPath.row == 0
        if cell.isCameraCell {
            if let nibName = self.configure.cameraCellNibSet?.nibName {
                cell = makeCell(nibName: nibName)
            }else{
                cell.imageView?.image = self.cameraImage
            }
            cell.willDisplayCell()
            return cell
        }
        guard let asset = collection.getTLAsset(at: indexPath.row) else { return cell }
        if asset.type == .video {
            self.placeholderThumbnail = #imageLiteral(resourceName: "videoPlaceholder")
        } else {
            self.placeholderThumbnail = #imageLiteral(resourceName: "galleryPlaceholder")
        }
        cell.imageView?.image = self.placeholderThumbnail
        
        if let selectedAsset = getSelectedAssets(asset) {
            selectedIndex = indexPath.row
            cell.selectedAsset = true
            cell.orderLabel?.text = "\(selectedAsset.selectedOrder)"
        }else{
            cell.selectedAsset = false
        }
        if asset.state == .progress {
            cell.indicator?.startAnimating()
        }else {
            cell.indicator?.stopAnimating()
        }
        if let phAsset = asset.phAsset {
            if self.usedPrefetch {
                let options = PHImageRequestOptions()
                options.deliveryMode = .opportunistic
                options.resizeMode = .exact
                options.isNetworkAccessAllowed = true
                let requestId = self.photoLibrary.imageAsset(asset: phAsset, size: self.thumbnailSize, options: options) { [weak self, weak cell] (image,complete) in
                    guard let `self` = self else { return }
                    DispatchQueue.main.async {
                        if self.requestIds[indexPath] != nil {
                            cell?.imageView?.image = image
                            if self.allowedVideo {
                                cell?.durationView?.isHidden = asset.type != .video
                                cell?.duration = asset.type == .video ? phAsset.duration : nil
                            }
                            if complete {
                                self.requestIds.removeValue(forKey: indexPath)
                            }
                        }
                    }
                }
                if requestId > 0 {
                    self.requestIds[indexPath] = requestId
                }
            }else {
                queue.async { [weak self, weak cell] in
                    guard let `self` = self else { return }
                    let requestId = self.photoLibrary.imageAsset(asset: phAsset, size: self.thumbnailSize, completionBlock: { (image,complete) in
                        DispatchQueue.main.async {
                            if self.requestIds[indexPath] != nil {
                                cell?.imageView?.image = image
                                if self.allowedVideo {
                                    cell?.durationView?.isHidden = asset.type != .video
                                    cell?.duration = asset.type == .video ? phAsset.duration : nil
                                }
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
            if self.allowedLivePhotos {
                cell.liveBadgeImageView?.image = asset.type == .livePhoto ? PHLivePhotoView.livePhotoBadgeImage(options: .overContent) : nil
                cell.livePhotoView?.delegate = asset.type == .livePhoto ? self : nil
            }
        }
        cell.alpha = 0
        UIView.transition(with: cell, duration: 0.1, options: .curveEaseIn, animations: {
            cell.alpha = 1
        }, completion: nil)
        return cell
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collection = self.focusedCollection else { return 0 }
        return collection.count
    }
    
    //Prefetch
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if self.usedPrefetch {
            queue.async { [weak self] in
                guard let `self` = self, let collection = self.focusedCollection else { return }
                var assets = [PHAsset]()
                for indexPath in indexPaths {
                    if let asset = collection.getAsset(at: indexPath.row) {
                        assets.append(asset)
                    }
                }
                let scale = max(UIScreen.main.scale,2)
                let targetSize = CGSize(width: self.thumbnailSize.width*scale, height: self.thumbnailSize.height*scale)
                self.photoLibrary.imageManager.startCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        if self.usedPrefetch {
            for indexPath in indexPaths {
                guard let requestId = self.requestIds[indexPath] else { continue }
                self.photoLibrary.cancelPHImageRequest(requestId: requestId)
                self.requestIds.removeValue(forKey: indexPath)
            }
            queue.async { [weak self] in
                guard let `self` = self, let collection = self.focusedCollection else { return }
                var assets = [PHAsset]()
                for indexPath in indexPaths {
                    if let asset = collection.getAsset(at: indexPath.row) {
                        assets.append(asset)
                    }
                }
                let scale = max(UIScreen.main.scale,2)
                let targetSize = CGSize(width: self.thumbnailSize.width*scale, height: self.thumbnailSize.height*scale)
                self.photoLibrary.imageManager.stopCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
            }
        }
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.usedPrefetch, let cell = cell as? TLPhotoCollectionViewCell, let collection = self.focusedCollection, let asset = collection.getTLAsset(at: indexPath.row) {
            if let selectedAsset = getSelectedAssets(asset) {
                cell.selectedAsset = true
                cell.orderLabel?.text = "\(selectedAsset.selectedOrder)"
            }else{
                cell.selectedAsset = false
            }
        }
    }
}

// MARK: - Camera Picker
extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    fileprivate func showCameraIfAuthorized() {
        let cameraAuthorization = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorization {
        case .authorized:
            self.showCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (authorized) in
                DispatchQueue.main.async { [weak self] in
                    if authorized {
                        self?.showCamera()
                    } else {
                        self?.handleDeniedCameraAuthorization()
                    }
                }
            })
        case .restricted, .denied:
            self.handleDeniedCameraAuthorization()
        }
    }
    
    fileprivate func showCamera() {
        guard !maxCheck() else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [kUTTypeImage as String]
        if self.configure.allowedVideoRecording {
            picker.mediaTypes.append(kUTTypeMovie as String)
            picker.videoQuality = self.configure.recordingVideoQuality
            if let duration = self.configure.maxVideoDuration {
                picker.videoMaximumDuration = duration
            }
        }
        picker.allowsEditing = true
        picker.delegate = self
        picker.modalPresentationStyle = .overCurrentContext
        self.present(picker, animated: true, completion: nil)
    }
    
    fileprivate func handleDeniedAlbumsAuthorization() {
        self.delegate?.handleNoAlbumPermissions(picker: self)
        self.handleNoAlbumPermissions?(self)
    }
    
    fileprivate func handleDeniedCameraAuthorization() {
        self.delegate?.handleNoCameraPermissions(picker: self)
        self.handleNoCameraPermissions?(self)
    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = (info[UIImagePickerControllerOriginalImage] as? UIImage) {
            var placeholderAsset: PHObjectPlaceholder? = nil
            PHPhotoLibrary.shared().performChanges({
                let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                placeholderAsset = newAssetRequest.placeholderForCreatedAsset
            }, completionHandler: { [weak self] (sucess, error) in
                if sucess, let `self` = self, let identifier = placeholderAsset?.localIdentifier {
                    guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else { return }
                    var result = TLPHAsset(asset: asset)
                    result.selectedOrder = self.selectedAssets.count + 1
                    self.selectedAssets.append(result)
                    self.logDelegate?.selectedPhoto(picker: self, at: 1)
                    self.delegate?.didSelectPhotoPicker(picker: self, withTLPHAssets: self.selectedAssets)
                }
            })
        } else if let image = (info[UIImagePickerControllerEditedImage] as? UIImage) {
            var placeholderAsset: PHObjectPlaceholder? = nil
            PHPhotoLibrary.shared().performChanges({
                let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                placeholderAsset = newAssetRequest.placeholderForCreatedAsset
            }, completionHandler: { [weak self] (sucess, error) in
                if sucess, let `self` = self, let identifier = placeholderAsset?.localIdentifier {
                    guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else { return }
                    var result = TLPHAsset(asset: asset)
                    result.selectedOrder = self.selectedAssets.count + 1
                    self.selectedAssets.append(result)
                    self.logDelegate?.selectedPhoto(picker: self, at: 1)
                    self.delegate?.didSelectPhotoPicker(picker: self, withTLPHAssets: self.selectedAssets)
                }
            })
        } else if (info[UIImagePickerControllerMediaType] as? String) == kUTTypeMovie as String {
            var placeholderAsset: PHObjectPlaceholder? = nil
            PHPhotoLibrary.shared().performChanges({
                let newAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: info[UIImagePickerControllerMediaURL] as! URL)
                placeholderAsset = newAssetRequest?.placeholderForCreatedAsset
            }) { [weak self] (sucess, error) in
                if sucess, let `self` = self, let identifier = placeholderAsset?.localIdentifier {
                    guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else { return }
                    var result = TLPHAsset(asset: asset)
                    self.checkJustAllowSelect1Video()
                    result.selectedOrder = self.selectedAssets.count + 1
                    self.selectedAssets.append(result)
                    self.logDelegate?.selectedPhoto(picker: self, at: 1)
                    self.delegate?.didSelectPhotoPicker(picker: self, withTLPHAssets: self.selectedAssets)
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UI & UI Action
extension PhotosViewController {
    
    @objc public func registerNib(nibName: String, bundle: Bundle) {
        self.collectionView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier: nibName)
    }
    
    fileprivate func centerAtRect(image: UIImage?, rect: CGRect, bgColor: UIColor = UIColor.white) -> UIImage? {
        guard let image = image else { return nil }
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image.scale)
        bgColor.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        image.draw(in: CGRect(x:rect.size.width/2 - image.size.width/2, y:rect.size.height/2 - image.size.height/2, width:image.size.width, height:image.size.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    fileprivate func initItemSize() {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let count = CGFloat(self.configure.numberOfColumn)
        let width = (UIScreen.main.bounds.size.width-(5*(count-1)))/count
        self.thumbnailSize = CGSize(width: width, height: width)
        layout.itemSize = self.thumbnailSize
        self.collectionView.collectionViewLayout = layout
        self.placeholderThumbnail = centerAtRect(image: self.configure.placeholderIcon, rect: CGRect(x: 0, y: 0, width: width, height: width))
        self.cameraImage = centerAtRect(image: self.configure.cameraIcon, rect: CGRect(x: 0, y: 0, width: width, height: width), bgColor: self.configure.cameraBgColor)
    }
    
    @objc open func makeUI() {
        registerNib(nibName: "TLPhotoCollectionViewCell", bundle: Bundle(for: TLPhotoCollectionViewCell.self))
        if let nibSet = self.configure.nibSet {
            registerNib(nibName: nibSet.nibName, bundle: nibSet.bundle)
        }
        if let nibSet = self.configure.cameraCellNibSet {
            registerNib(nibName: nibSet.nibName, bundle: nibSet.bundle)
        }
        self.showHud()

        if #available(iOS 10.0, *), self.usedPrefetch {
            self.collectionView.isPrefetchingEnabled = true
            self.collectionView.prefetchDataSource = self
        } else {
            self.usedPrefetch = false
        }
        if #available(iOS 9.0, *), self.allowedLivePhotos {
        }else {
            self.allowedLivePhotos = false
        }
    }
    
    fileprivate func updateTitle() {
        guard self.focusedCollection != nil else { return }
    }
    
    fileprivate func reloadCollectionView() {
        guard self.focusedCollection != nil else { return }
        self.collectionView.reloadData()
    }
    
    fileprivate func initPhotoLibrary() {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.photoLibrary.delegate = self
            self.photoLibrary.fetchCollection(configure: self.configure)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func registerChangeObserver() {
        PHPhotoLibrary.shared().register(self)
    }
    
    fileprivate func getfocusedIndex() -> Int {
        guard let focused = self.focusedCollection, let result = self.collections.index(where: { $0 == focused }) else { return 0 }
        return result
    }
    
    fileprivate func focused(collection: TLAssetsCollection) {
        func resetRequest() {
            cancelAllCloudRequest()
            cancelAllImageAssets()
        }
        resetRequest()
        self.collections[getfocusedIndex()].recentPosition = self.collectionView.contentOffset
        var reloadIndexPaths = [IndexPath(row: getfocusedIndex(), section: 0)]
        self.focusedCollection = collection
        self.focusedCollection?.fetchResult = self.photoLibrary.fetchResult(collection: collection, configure: self.configure)
        reloadIndexPaths.append(IndexPath(row: getfocusedIndex(), section: 0))
        self.updateTitle()
        self.reloadCollectionView()
        self.collectionView.contentOffset = collection.recentPosition
    }
    
    // Asset Request
    fileprivate func requestCloudDownload(asset: TLPHAsset, indexPath: IndexPath) {
        if asset.state != .complete {
            var asset = asset
            asset.state = .ready
            guard let phAsset = asset.phAsset else { return }
            let requestId = TLPhotoLibrary.cloudImageDownload(asset: phAsset, progressBlock: { [weak self] (progress) in
                guard let `self` = self else { return }
                if asset.state == .ready {
                    asset.state = .progress
                    if let index = self.selectedAssets.index(where: { $0.phAsset == phAsset }) {
                        self.selectedAssets[index] = asset
                    }
                    guard self.collectionView.indexPathsForVisibleItems.contains(indexPath) else { return }
                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? TLPhotoCollectionViewCell else { return }
                    cell.indicator?.startAnimating()
                }
                }, completionBlock: { [weak self] image in
                    guard let `self` = self else { return }
                    asset.state = .complete
                    if let index = self.selectedAssets.index(where: { $0.phAsset == phAsset }) {
                        self.selectedAssets[index] = asset
                    }
                    self.cloudRequestIds.removeValue(forKey: indexPath)
                    guard self.collectionView.indexPathsForVisibleItems.contains(indexPath) else { return }
                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? TLPhotoCollectionViewCell else { return }
                    cell.imageView?.image = image
                    cell.indicator?.stopAnimating()
            })
            if requestId > 0 {
                self.cloudRequestIds[indexPath] = requestId
            }
        }
    }
    
    fileprivate func cancelCloudRequest(indexPath: IndexPath) {
        guard let requestId = self.cloudRequestIds[indexPath] else { return }
        self.cloudRequestIds.removeValue(forKey: indexPath)
        self.photoLibrary.cancelPHImageRequest(requestId: requestId)
    }
    
    fileprivate func cancelAllCloudRequest() {
        for (_,requestId) in self.cloudRequestIds {
            self.photoLibrary.cancelPHImageRequest(requestId: requestId)
        }
        self.cloudRequestIds.removeAll()
    }
    
    fileprivate func cancelAllImageAssets() {
        for (_,requestId) in self.requestIds {
            self.photoLibrary.cancelPHImageRequest(requestId: requestId)
        }
        self.requestIds.removeAll()
    }
    
    @IBAction open func cancelButtonTap() {
        self.stopPlay()
        self.dismiss(done: false)
    }
    
    @IBAction open func doneButtonTap() {
        self.stopPlay()
        self.dismiss(done: true)
    }
    
    fileprivate func dismiss(done: Bool) {
        if done {
            #if swift(>=4.1)
                self.delegate?.dismissPhotoPicker(withPHAssets: self.selectedAssets.compactMap{ $0.phAsset })
            #else
                self.delegate?.dismissPhotoPicker(withPHAssets: self.selectedAssets.flatMap{ $0.phAsset })
            #endif
            self.delegate?.dismissPhotoPicker(withTLPHAssets: self.selectedAssets)
            self.completionWithTLPHAssets?(self.selectedAssets)
            #if swift(>=4.1)
                self.completionWithPHAssets?(self.selectedAssets.compactMap{ $0.phAsset })
            #else
                self.completionWithPHAssets?(self.selectedAssets.flatMap{ $0.phAsset })
            #endif
        }else {
            self.delegate?.photoPickerDidCancel()
            self.didCancel?()
        }
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.dismissComplete()
            self?.dismissCompletion?()
        }
    }
    
    fileprivate func maxCheck() -> Bool {
        if self.configure.singleSelectedMode {
            self.selectedAssets.removeAll()
            self.orderUpdateCells()
        }
        if let max = self.configure.maxSelectedAssets, max <= self.selectedAssets.count {
            self.delegate?.didExceedMaximumNumberOfSelection(picker: self)
            self.didExceedMaximumNumberOfSelection?(self)
            return true
        }
        return false
    }
}

// MARK: - Video & LivePhotos Control PHLivePhotoViewDelegate
extension PhotosViewController: PHLivePhotoViewDelegate {
    fileprivate func stopPlay() {
        guard let playRequest = self.playRequestId else { return }
        self.playRequestId = nil
        guard let cell = self.collectionView.cellForItem(at: playRequest.indexPath) as? TLPhotoCollectionViewCell else { return }
        cell.stopPlay()
    }
    
    fileprivate func playVideo(asset: TLPHAsset, indexPath: IndexPath) {
        stopPlay()
        guard let phAsset = asset.phAsset else { return }
        if asset.type == .video {
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? TLPhotoCollectionViewCell else { return }
            let requestId = self.photoLibrary.videoAsset(asset: phAsset, completionBlock: { (playerItem, info) in
                DispatchQueue.main.sync { [weak self, weak cell] in
                    guard let `self` = self, let cell = cell, cell.player == nil else { return }
                    let player = AVPlayer(playerItem: playerItem)
                    cell.player = player
                    player.play()
                    player.isMuted = self.configure.muteAudio
                }
            })
            if requestId > 0 {
                self.playRequestId = (indexPath,requestId)
            }
        }else if asset.type == .livePhoto {
            
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? TLPhotoCollectionViewCell else { return }
            let requestId = self.photoLibrary.livePhotoAsset(asset: phAsset, size: self.thumbnailSize, completionBlock: { [weak cell] (livePhoto,complete) in
                cell?.livePhotoView?.isHidden = false
                cell?.livePhotoView?.livePhoto = livePhoto
                cell?.livePhotoView?.isMuted = true
                cell?.livePhotoView?.startPlayback(with: .hint)
            })
            if requestId > 0 {
                self.playRequestId = (indexPath,requestId)
            }
        }
    }
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        livePhotoView.isMuted = true
        livePhotoView.startPlayback(with: .hint)
    }
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension PhotosViewController: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard getfocusedIndex() == 0 else { return }
        guard let changeFetchResult = self.focusedCollection?.fetchResult else { return }
        guard let changes = changeInstance.changeDetails(for: changeFetchResult) else { return }
        let addIndex = self.usedCameraButton ? 1 : 0
        DispatchQueue.main.sync {
            if changes.hasIncrementalChanges {
                var deletedSelectedAssets = false
                var order = 0
                #if swift(>=4.1)
                    self.selectedAssets = self.selectedAssets.enumerated().compactMap({ (offset,asset) -> TLPHAsset? in
                    var asset = asset
                    if let phAsset = asset.phAsset, changes.fetchResultAfterChanges.contains(phAsset) {
                    order += 1
                    asset.selectedOrder = order
                    return asset
                    }
                    deletedSelectedAssets = true
                    return nil
                    })
                #else
                    self.selectedAssets = self.selectedAssets.enumerated().flatMap({ (offset,asset) -> TLPHAsset? in
                        var asset = asset
                        if let phAsset = asset.phAsset, changes.fetchResultAfterChanges.contains(phAsset) {
                            order += 1
                            asset.selectedOrder = order
                            return asset
                        }
                        deletedSelectedAssets = true
                        return nil
                    })
                #endif
                if deletedSelectedAssets {
                    self.focusedCollection?.fetchResult = changes.fetchResultAfterChanges
                    self.collectionView.reloadData()
                }else {
                    self.collectionView.performBatchUpdates({ [weak self] in
                        guard let `self` = self else { return }
                        self.focusedCollection?.fetchResult = changes.fetchResultAfterChanges
                        if let removed = changes.removedIndexes, removed.count > 0 {
                            self.collectionView.deleteItems(at: removed.map { IndexPath(item: $0+addIndex, section:0) })
                        }
                        if let inserted = changes.insertedIndexes, inserted.count > 0 {
                            self.collectionView.insertItems(at: inserted.map { IndexPath(item: $0+addIndex, section:0) })
                        }
                        if let changed = changes.changedIndexes, changed.count > 0 {
                            self.collectionView.reloadItems(at: changed.map { IndexPath(item: $0+addIndex, section:0) })
                        }
                    })
                }
            }else {
                self.focusedCollection?.fetchResult = changes.fetchResultAfterChanges
                self.collectionView.reloadData()
            }
            if let collection = self.focusedCollection {
                self.collections[getfocusedIndex()] = collection
            }
        }
    }
}

// MARK: - TLPhotoLibraryDelegate
extension PhotosViewController: TLPhotoLibraryDelegate {
    func loadCameraRollCollection(collection: TLAssetsCollection) {
        if let focused = self.focusedCollection, focused == collection {
            focusCollection(collection: collection)
        }
        self.collections = [collection]
        self.hideHude()
        self.reloadCollectionView()
    }
    
    func loadCompleteAllCollection(collections: [TLAssetsCollection]) {
        self.collections = collections
        let isEmpty = self.collections.count == 0
        self.hideHude()
        self.registerChangeObserver()
    }
    
    func focusCollection(collection: TLAssetsCollection) {
        self.focusedCollection = collection
    }
}
