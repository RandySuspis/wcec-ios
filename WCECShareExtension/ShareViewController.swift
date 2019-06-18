//
//  ShareViewController.swift
//  Post Manager Extension
//
//  Created by Tomasz Baranowicz on 13/02/16.
//  Copyright © 2016 Direct Solutions. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import Photos
import PhotosUI

class ShareViewController:  BaseViewController {
    @IBOutlet var toolbarView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var galleryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    fileprivate var queue = DispatchQueue(label: "NewPostGalleryQueue")
    fileprivate var photoLibrary = TLPhotoLibrary()
    fileprivate var thumbnailSize = CGSize.zero
    fileprivate var requestIds = [IndexPath:PHImageRequestID]()
    
    let mediaService = MediaService()
    var newPostViewModel = NewPostViewModel.shareInstance
    var imageList = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        manageShareExtensionData()
        
        if DataManager.getUserToken().isEmpty {
            self.alertWithTitle("Alert", message: "Please login first", completion: {
                let error = NSError(domain: "", code: 400, userInfo: ["message": "Please login first", "title": "Alert"])
                self.extensionContext?.cancelRequest(withError: error)
            })
        }
        self.newPostViewModel.mediaType = .image
        NotificationCenter.default.addObserver(self, selector: #selector(keyboarWillShow(sender:)), name:NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name:NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    func logErrorAndCompleteRequest(error: Error?) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func manageShareExtensionData() {
        let content = extensionContext!.inputItems[0] as! NSExtensionItem
        
        for (index, attachment) in (content.attachments as! [NSItemProvider]).enumerated() {
            if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { [weak self] data, error in
                    if error == nil, let url = data as? URL, let this = self {
                        do {
                            // GETTING RAW DATA
                            let rawData = try Data(contentsOf: url)
                            let rawImage = UIImage(data: rawData)
                            
                            // CONVERTED INTO FORMATTED FILE : OVER COME MEMORY WARNING
                            // YOU USE SCALE PROPERTY ALSO TO REDUCE IMAGE SIZE
//                            let image = UIImage.resizeImage(image: rawImage!, width: 100, height: 100)
//                            let imgData = UIImagePNGRepresentation(image)
                            
                            this.imageList.append( rawImage!)
                            this.newPostViewModel.listGallery = this.imageList
                            if this.imageList.count > 0 {
                                this.galleryHeightConstraint.constant = 144
                                this.navigationItem.rightBarButtonItem?.isEnabled = true
                                this.galleryCollectionView.reloadData()
                            }
                            if index == (content.attachments?.count)! - 1 {
                                DispatchQueue.main.async {
                                    this.galleryCollectionView.reloadData()
                                }
                            }
                        }
                        catch let exp {
                            print("GETTING EXCEPTION \(exp.localizedDescription)")
                        }
                        
                    } else {
                        self?.logErrorAndCompleteRequest(error: error)
                    }
                }
            } else if attachment.hasItemConformingToTypeIdentifier(kUTTypeAudiovisualContent as String) {
                attachment.loadItem(forTypeIdentifier: kUTTypeAudiovisualContent as String, options: nil) { [weak self] data, error in
                    if error == nil, let url = data as? URL, let this = self {
                        do {
                            // GETTING RAW DATA
                            let rawData = try Data(contentsOf: url)
                            let rawImage = UIImage(data: rawData)
                            
                            // CONVERTED INTO FORMATTED FILE : OVER COME MEMORY WARNING
                            // YOU USE SCALE PROPERTY ALSO TO REDUCE IMAGE SIZE
                            //                            let image = UIImage.resizeImage(image: rawImage!, width: 100, height: 100)
                            //                            let imgData = UIImagePNGRepresentation(image)
                            
                            this.imageList.append( rawImage!)
                            this.newPostViewModel.listGallery = this.imageList
                            if this.imageList.count > 0 {
                                this.galleryHeightConstraint.constant = 144
                                this.navigationItem.rightBarButtonItem?.isEnabled = true
                                this.galleryCollectionView.reloadData()
                            }
                            if index == (content.attachments?.count)! - 1 {
                                DispatchQueue.main.async {
                                    this.galleryCollectionView.reloadData()
                                }
                            }
                        }
                        catch let exp {
                            print("GETTING EXCEPTION \(exp.localizedDescription)")
                        }
                        
                    } else {
                        self?.logErrorAndCompleteRequest(error: error)
                    }
                }
            } else if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                attachment.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { [weak self] data, error in
                    if error == nil, let url = data as? URL, let this = self {
                        do {
                            print("Success \(url)")

                            DispatchQueue.main.async {
                                this.textView.text = url.absoluteString
                                this.textView.textColor = AppColor.colorTextField()
                                if url.absoluteString.count > 0 {
                                    this.navigationItem.rightBarButtonItem?.isEnabled = true
                                }
                            }
                        }
                        catch let exp {
                            print("GETTING EXCEPTION \(exp.localizedDescription)")
                        }
                        
                    } else {
                        self?.logErrorAndCompleteRequest(error: error)
                    }
                }
            }
        }
    }
    
    func setupUI() {
        galleryHeightConstraint.constant = 0
        
        self.navigationItem.title = "New Post".localized()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.nextBarButton(target: self, selector: #selector(onNext))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.closeBarItem(target: self, btnAction: #selector(onSelectClose))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.galleryCollectionView.register(UINib(nibName: "NewPostGalleryCollectionViewCell", bundle: Bundle(for: NewPostGalleryCollectionViewCell.self)), forCellWithReuseIdentifier: "NewPostGalleryCollectionViewCell")
        guard let layout = self.galleryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let count = CGFloat(3)
        let width = (self.galleryCollectionView.frame.size.width-(5*(count-1)))/count
        thumbnailSize = CGSize(width: width, height: width)
        layout.itemSize = thumbnailSize
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10)
        self.galleryCollectionView.collectionViewLayout = layout
        
        textView.text = "Write something...".localized()
        textView.setLeftPaddingPoints(16)
        textView.textColor = AppColor.colorTitleTextField()
        textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("keyboard height: %f")
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
    
    @objc func keyboardWillHide(sender: NSNotification) {
        toolbarViewBottomConstraint.constant = 0
    }
    
    @objc func keyboarWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            toolbarViewBottomConstraint.constant = keyboardSize.height
            print("keyboard height: %f", keyboardSize.height)
        }
        
    }
    
    //MARK: Action
    @objc func onNext() {
        newPostViewModel.content = textView.text
        pushtoAddTagView()
    }
    
    func pushtoAddTagView() {
        let postAddTagsVC = PostAddTagsViewController()
        self.navigationController?.pushViewController(postAddTagsVC, animated: true)
    }
    
    @objc func onSelectClose() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func onSelectGallery(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                let galleryVC = GalleryViewController()
                galleryVC.delegate = self
                //        galleryVC.selectedAssets = self.selectedAssets
                let navi = BaseNavigationController.init(rootViewController: galleryVC)
                self.navigationController?.present(navi, animated: true, completion: nil)
                break
            default:
                let alertController = UIAlertController(title: "Start Sending Photos".localized(),
                                                        message: "In iPhone settings, tap WCEC and turn on Photos".localized(), preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Open Settings".localized(),
                                             style: .destructive,
                                             handler: { (action) in
                                                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                                                    return
                                                }
                                                
                                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                                    if #available(iOS 10.0, *) {
                                                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                                        })
                                                    } else {
                                                    }
                                                }
                })
                let cancelAction = UIAlertAction(title: "Cancel".localized(),
                                                 style: .cancel,
                                                 handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                break
            }
        }
    }
    
    @IBAction func onSelectSetting(_ sender: Any) {
        let postSettingVC = PostSettingViewController()
        self.navigationController?.pushViewController(postSettingVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ShareViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == AppColor.colorTitleTextField() {
            textView.text = ""
            textView.textColor = AppColor.colorTextField()
        } else {
        
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.isEmpty {
            if textView.text.count <= 1 {
                if imageList.count == 0 {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                } else {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if imageList.count == 0 {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            textView.text = "Write something...".localized()
            textView.textColor = AppColor.colorTitleTextField()
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}

extension ShareViewController: GalleryViewControllerDelegate {
    func didSelectGallery(controller: GalleryViewController, withTLPHAssets: [TLPHAsset], mediaType: PHAssetMediaType) {
        controller.dismiss(animated: true, completion: nil)
        
    }
}

extension ShareViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    //Delegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    //Datasource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        func makeCell(nibName: String) -> NewPostGalleryCollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibName, for: indexPath) as! NewPostGalleryCollectionViewCell
            return cell
        }
        let nibName = "NewPostGalleryCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibName, for: indexPath) as! NewPostGalleryCollectionViewCell
        
        cell.imageView.image = #imageLiteral(resourceName: "galleryPlaceholder")
        cell.videoIcon.isHidden = true
        cell.imageView.image = self.imageList[indexPath.row]
        
        cell.index = indexPath
        cell.delegate = self
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
        return self.imageList.count
    }
}

extension ShareViewController: NewPostGalleryCollectionViewCellDelegate {
    func didRemoveItem(cell: NewPostGalleryCollectionViewCell, atIndex: IndexPath) {
        self.imageList.remove(at: atIndex.row)
        self.newPostViewModel.listGallery = self.imageList
        self.galleryCollectionView.reloadData()
        if self.imageList.count == 0 {
            self.galleryHeightConstraint.constant = 0
            if textView.textColor == AppColor.colorTitleTextField() {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
    }
}

//NSExtensionActivationSupportsAttachmentsWithMaxCount
//NSExtensionActivationSupportsAttachmentsWithMinCount
//NSExtensionActivationSupportsFileWithMaxCount
//NSExtensionActivationSupportsImageWithMaxCount
//NSExtensionActivationSupportsMovieWithMaxCount
//NSExtensionActivationSupportsText
//NSExtensionActivationSupportsWebURLWithMaxCount
//NSExtensionActivationSupportsWebPageWithMaxCount

