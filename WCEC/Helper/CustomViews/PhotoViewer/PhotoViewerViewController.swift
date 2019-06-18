//
//  PhotoViewerViewController.swift
//  WCEC
//
//  Created by GEM on 6/8/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Alamofire
import CropViewController
import Photos

protocol PhotoViewerViewControllerDelegate: NSObjectProtocol {
    func photoViewerViewControllerDidEdittedImage(image: PHAsset, index: Int)
    func photoViewerViewControllerDidEdittedImageUrl(image: FileModel, index: Int)
}

class PhotoViewerViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var downloadImageButton: UIButton!
    @IBOutlet weak var photoCounLabel: UILabel!
    @IBOutlet weak var arrowLeftImage: UIImageView!
    @IBOutlet weak var arrowRightImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!

    weak var delegate: PhotoViewerViewControllerDelegate?

    var listPhoto: [Any] = ["https://i.imgur.com/3xVXoDUg.jpg","https://i.imgur.com/3xVXoDUg.jpg","https://i.imgur.com/3xVXoDUg.jpg"]
    var currentIndex: Int = 1
    var canEdit: Bool = false
    var inited: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        collectionView.register(UINib(nibName: PhotoViewerCollectionViewCell.classString(), bundle: nil),
                                      forCellWithReuseIdentifier: PhotoViewerCollectionViewCell.classString())
        view.backgroundColor = AppColor.colorTextField()
        if listPhoto.count <= 1 {
            arrowLeftImage.isHidden = true
            arrowRightImage.isHidden = true
        } else {
            arrowLeftImage.isHidden = false
            arrowRightImage.isHidden = false
        }
        editButton.isHidden = !canEdit
        checkShowHideArrow()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if currentIndex <= listPhoto.count && !inited {
            inited = true
            photoCounLabel.text = "\(currentIndex)/\(listPhoto.count)"
            collectionView.scrollToItem(at: IndexPath.init(row: currentIndex - 1, section: 0), at: .centeredHorizontally, animated: false)
        }
    }

    @IBAction func onDownloadImage(_ sender: Any) {
        if let source = listPhoto as? [String] {
            guard let url = URL(string: source[currentIndex - 1]) else { return }
            self.showHud()
            Alamofire.request(url).responseData { response in
                guard let data = response.result.value else {
                    self.hideHude()
                    return
                }
                guard let image = UIImage(data: data) else {
                    self.hideHude()
                    return
                }
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                                               nil)
            }
        } else {
            UIImageWriteToSavedPhotosAlbum(listPhoto[currentIndex - 1] as! UIImage,
                                           self,
                                           #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                                           nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        self.hideHude()
        if let error = error {
            let ac = UIAlertController(title: "Error".localized(), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK".localized(), style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Success".localized(), message: "Your altered image has been saved to your photos.".localized(), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK".localized(), style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onViewPreviousImage(_ sender: Any) {
        if currentIndex-1 > 0 {
            currentIndex -= 2
            collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .right, animated: true)
        }
    }
    
    @IBAction func onViewForwardImage(_ sender: Any) {
        if currentIndex-1 < listPhoto.count-1 {
            collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .left, animated: true)
            
        }
    }

    @IBAction func tapEdit(_ sender: Any) {
        if let url = listPhoto[currentIndex - 1] as? String {
            Alamofire.request(url).responseData { response in
                guard let data = response.result.value else {
                    return
                }
                guard let image = UIImage(data: data) else {
                    return
                }
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               #selector(self.saveImageWantEdit(_:didFinishSavingWithError:contextInfo:)),
                                               nil)
            }
        } else if let image = listPhoto[currentIndex - 1] as? UIImage {
            let cropViewController = CropViewController(image: image)
            cropViewController.delegate = self
            present(cropViewController, animated: true, completion: nil)
        }
    }

    @objc func saveImageWantEdit(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Error".localized(), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK".localized(), style: .default))
            present(ac, animated: true)
        } else {
            let cropViewController = CropViewController(image: image)
            cropViewController.delegate = self
            present(cropViewController, animated: true, completion: nil)
        }
    }
}

extension PhotoViewerViewController: CropViewControllerDelegate {

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageEditted(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func saveImageEditted(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Error".localized(), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK".localized(), style: .default))
            present(ac, animated: true)
        } else {
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat

            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            if let fechResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) {
                guard fechResult.count > 0 else {
                    return
                }
                if let _ = listPhoto[currentIndex - 1] as? String {
                    let mediaService = MediaService()
                    mediaService.uploadImage(image: image, { (result) in
                        self.hideHude()
                        switch result {
                        case .failure(let error):
                            if let errorDiction = error._userInfo as? NSDictionary {
                                self.alertWithTitle(errorDiction["title"] as? String, message: errorDiction["message"] as? String)
                            }
                        case .success(let response):
                            self.listPhoto[self.currentIndex - 1] = response.data.file_url
                            self.collectionView.reloadData()
                            self.delegate?.photoViewerViewControllerDidEdittedImageUrl(image: response.data,
                                                                                       index: self.currentIndex - 1)
                        }
                    })
                } else if let _ = listPhoto[currentIndex - 1] as? UIImage {
                    listPhoto[currentIndex - 1] = image
                    collectionView.reloadData()
                    delegate?.photoViewerViewControllerDidEdittedImage(image: fechResult[0], index: currentIndex - 1)
                }
            }
        }
    }
}

extension PhotoViewerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listPhoto.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewerCollectionViewCell.classString(), for: indexPath) as! PhotoViewerCollectionViewCell
        if let source = listPhoto[indexPath.row] as? String {
            cell.binding(source)
        } else {
            cell.binding(listPhoto[indexPath.row] as! UIImage)
        }
        return cell
    }
}

extension PhotoViewerViewController: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        currentIndex = indexPath.row + 1
        photoCounLabel.text = "\(currentIndex)/\(listPhoto.count)"
        checkShowHideArrow()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        currentIndex = indexPath.row + 1
        photoCounLabel.text = "\(currentIndex)/\(listPhoto.count)"
        checkShowHideArrow()
    }
    
    func checkShowHideArrow() {
        if currentIndex == listPhoto.count {
            arrowRightImage.isHidden = true
        } else {
            arrowRightImage.isHidden = false
        }
        
        if currentIndex == 1 {
            arrowLeftImage.isHidden = true
        } else {
            arrowLeftImage.isHidden = false
        }
    }
}

extension PhotoViewerViewController: UICollectionViewDelegateFlowLayout {
    
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














