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

    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func binding(_ image: String) {
        guard let url = URL(string: image) else {
            return
        }
        photoImageView.kf.setImage(with: url,
                                   placeholder: nil,
                                   options: nil,
                                   progressBlock: nil,
                                   completionHandler: nil)
    }
    

}

