//
//  BaseTableViewCell.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol PBaseTableViewCell {
    func bindingWithModel(_ model: PBaseRowModel)
}

class BaseTableViewCell: UITableViewCell, PBaseTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descLabel: UILabel?
    @IBOutlet weak var thumbImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindingWithModel(_ model: PBaseRowModel) {
        titleLabel?.text = model.title
        descLabel?.text = model.desc
        if let image = UIImage(named: model.image) {
            thumbImageView?.image = image
        } else {
            if let url = URL(string: model.image) {
//                thumbImageView?.kf.setImage(with: url,
//                                            placeholder: nil,
//                                            options: nil,
//                                            progressBlock: nil,
//                                            completionHandler: nil)
            }
        }
    }
}

