//
//  PhotoViewerCollectionViewCell.swift
//  WCEC
//
//  Created by GEM on 6/8/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoViewerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: ZoomImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func binding(_ image: String) {
        guard let url = URL(string: image) else {
            return
        }
        UIImageView().kf.setImage(with: url,
                                  placeholder: UIImage(named: "placeholder_image"),
                                  options: nil,
                                  progressBlock: nil) { (image, _, _, _) in
                                    self.imageView.image = image
        }
    }
    
    func binding(_ image: UIImage) {
        imageView.image = image
    }
}

