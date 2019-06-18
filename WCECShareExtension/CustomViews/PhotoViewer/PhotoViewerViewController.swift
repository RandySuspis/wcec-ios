//
//  PhotoViewerViewController.swift
//  WCEC
//
//  Created by GEM on 6/8/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Alamofire

class PhotoViewerViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var downloadImageButton: UIButton!
    @IBOutlet weak var photoCounLabel: UILabel!
    
    var listPhoto = ["https://i.imgur.com/3xVXoDUg.jpg","https://i.imgur.com/3xVXoDUg.jpg","https://i.imgur.com/3xVXoDUg.jpg"]
    var currentIndex: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        collectionView.register(UINib(nibName: PhotoViewerCollectionViewCell.classString(), bundle: nil),
                                      forCellWithReuseIdentifier: PhotoViewerCollectionViewCell.classString())
        view.backgroundColor = AppColor.colorTextField()
        photoCounLabel.text = "\(1)/\(listPhoto.count)"
    }
    
    @IBAction func onDownloadImage(_ sender: Any) {
        guard let url = URL(string: listPhoto[currentIndex - 1]) else { return }
        Alamofire.request(url).responseData { response in
            guard let data = response.result.value else { return }
            guard let image = UIImage(data: data) else { return }
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                                           nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error".localized(), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK".localized(), style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!".localized(), message: "Your altered image has been saved to your photos.".localized(), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK".localized(), style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoViewerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listPhoto.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoViewerCollectionViewCell.classString(), for: indexPath) as! PhotoViewerCollectionViewCell
        cell.binding(listPhoto[indexPath.row])
        return cell
    }
}

extension PhotoViewerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("hehe")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        currentIndex = indexPath.row + 1
        photoCounLabel.text = "\(currentIndex)/\(listPhoto.count)"
    }
}

extension PhotoViewerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
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














