//
//  MessageTableViewCell.swift
//  WCEC
//
//  Created by GEM on 6/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var notiView: UIView!

    var rowModel: MessagesRowModel?

    override func awakeFromNib() {
        super.awakeFromNib()
//        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width/2
//        avatarImageView.layer.masksToBounds = true
        notiView.layer.cornerRadius = notiView.bounds.size.width/2
        notiView.layer.masksToBounds = true
    }
    
    func bindingWithModel(_ rowModel: MessagesRowModel) {
        self.rowModel = rowModel
        titleLabel.text = rowModel.title.localized()
        userLabel.text = rowModel.nameUser
        descLabel.text = rowModel.desc
        timeLabel.text = rowModel.time
        notiView.isHidden = !rowModel.isNew
        avatarImageView.kf.setImage(with: URL(string: rowModel.image),
                                    placeholder: #imageLiteral(resourceName: "galleryPlaceholder"),
                                    options: nil,
                                    progressBlock: nil,
                                    completionHandler: nil)
    }

    @IBAction func tapAvatar(_ sender: Any) {
        guard let rowModel = rowModel else {
            return
        }
        let vc = PhotoViewerViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.listPhoto = [rowModel.image]
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
    }
}
