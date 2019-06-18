//
//  AvatarReceiveImageTableViewCell.swift
//  WCEC
//
//  Created by hnc on 7/9/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class AvatarReceiveImageTableViewCell: BaseTableViewCell {
    @IBOutlet weak var photoCountLabel: UILabel!
    @IBOutlet weak var msgImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var greyView: UIView!

    var listImage = [String]()
    var rowModel: ChatRowModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        photoCountLabel.isHidden = true
        msgImageView.image = #imageLiteral(resourceName: "galleryPlaceholder")
        avatarImageView.image = #imageLiteral(resourceName: "placeholder")
        nameLabel.text = ""
    }
    
    override func bindingWithModel(_ model: PBaseRowModel) {
        super.bindingWithModel(model)
        if let rowModel = model as? ChatRowModel {
            self.rowModel = rowModel
            self.avatarImageView.kf.setImage(with: URL(string: rowModel.avatarUrl), placeholder: #imageLiteral(resourceName: "placeholder"), options: nil, progressBlock: nil, completionHandler: nil)
            self.nameLabel.text = rowModel.fullName
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
    
    @IBAction func tapAvatar(_ sender: Any) {
        guard let rowModel = rowModel else {
            return
        }
        openPhotoViewer([rowModel.avatarUrl])
    }

    @IBAction func tapViewImage(_ sender: Any) {
        openPhotoViewer(listImage)
    }

    func openPhotoViewer(_ listImage: [Any]) {
        let vc = PhotoViewerViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.listPhoto = listImage
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
    }
}
