//
//  NewFeedEmbedLinkTableViewCell.swift
//  WCEC
//
//  Created by GEM on 6/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class NewFeedEmbedLinkTableViewCell: BaseNewFeedTableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleEmbedLabel: UILabel!
    @IBOutlet weak var descEmbedLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var linkSourceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func bindingWithModel(_ model: NewFeedRowModel) {
        super.bindingWithModel(model)
        thumbImageView?.kf.setImage(with: URL(string: model.avatar),
                                     placeholder: #imageLiteral(resourceName: "placeholder"),
                                     options: nil,
                                     progressBlock: nil,
                                     completionHandler: nil)
    }
}
