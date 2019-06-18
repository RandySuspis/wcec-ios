//
//  NewFeedPhotoTableViewCell.swift
//  WCEC
//
//  Created by GEM on 6/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class NewFeedPhotoTableViewCell: BaseNewFeedTableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var countPhotoLabel: UILabel!
    @IBOutlet weak var seeAllLabel: UILabel!
    @IBOutlet weak var counPhotoView: UIView!
    
    var listImage = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        seeAllLabel.text = "See All".localized()
    }
    
    override func bindingWithModel(_ model: NewFeedRowModel) {
        super.bindingWithModel(model)
        guard model.listImage.count > 0 else {
            return
        }
        listImage = model.listImage
        photoImageView.kf.setImage(with: URL(string: model.thumbNail),
                                   placeholder: nil,
                                   options: nil,
                                   progressBlock: nil,
                                   completionHandler: nil)
        counPhotoView.isHidden = listImage.count == 1
        countPhotoLabel.text = "\(listImage.count) " + "photos".localized()
    }
    
    @IBAction func onSeePhoto(_ sender: Any) {
        delegate?.baseNewFeedTableViewCellDidSelectAsset?(self, listImage: listImage)
    }
    
}
