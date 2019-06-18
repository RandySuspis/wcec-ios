//
//  SendImageMessageTableViewCell.swift
//  WCEC
//
//  Created by GEM on 7/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class SendImageMessageTableViewCell: BaseTableViewCell {
    @IBOutlet weak var greyView: UIView!
    @IBOutlet weak var photoCountLabel: UILabel!
    @IBOutlet weak var msgImageView: UIImageView!
    var listImage = [String]()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        photoCountLabel.isHidden = true
        msgImageView.image = #imageLiteral(resourceName: "galleryPlaceholder")
    }
    
    override func bindingWithModel(_ model: PBaseRowModel) {
        super.bindingWithModel(model)
        if let rowModel = model as? ChatRowModel {
            if rowModel.images.count > 0 {
                listImage = rowModel.images
                msgImageView.kf.setImage(with: URL(string: rowModel.images.first!), placeholder: #imageLiteral(resourceName: "galleryPlaceholder"), options: nil, progressBlock: nil, completionHandler: nil)
                if rowModel.images.count > 1 {
                    photoCountLabel.isHidden = false
                    photoCountLabel.text = "\(rowModel.images.count) " + "Photos".localized()
                    greyView.isHidden = false
                } else {
                    photoCountLabel.isHidden = true
                    greyView.isHidden = true
                }
            }
        }
    }
    
    @IBAction func tapViewImage(_ sender: Any) {
        let vc = PhotoViewerViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.listPhoto = self.listImage
        Constants.appDelegate.tabbarController.present(vc, animated: true, completion: nil)
    }
    
}
