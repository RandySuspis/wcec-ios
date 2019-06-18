//
//  AvatarReceiveMessageTableViewCell.swift
//  WCEC
//
//  Created by GEM on 7/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol AvatarReceiveMessageTableViewCellDelegate: NSObjectProtocol {
    func avatarReceiveMessageTableViewCellDidSelectAvatar(url: String)
}

class AvatarReceiveMessageTableViewCell: BaseTableViewCell {
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    var rowModel: ChatRowModel?
    weak var delegate: AvatarReceiveMessageTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.message.text = ""
        self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.messageBackground.layer.cornerRadius = 8
        self.messageBackground.clipsToBounds = true
        self.avatarImageView.image = #imageLiteral(resourceName: "placeholder")
        self.nameLabel.text = ""
    }
    
    override func bindingWithModel(_ model: PBaseRowModel) {
        super.bindingWithModel(model)
        if let rowModel = model as? ChatRowModel {
            self.rowModel = rowModel
            self.message.text = rowModel.message
            self.avatarImageView.kf.setImage(with: URL(string: rowModel.avatarUrl), placeholder: #imageLiteral(resourceName: "placeholder"), options: nil, progressBlock: nil, completionHandler: nil)
            self.nameLabel.text = rowModel.fullName
        }
    }
    
    @IBAction func tapAvatar(_ sender: Any) {
        guard let rowModel = rowModel else {
            return
        }
        delegate?.avatarReceiveMessageTableViewCellDidSelectAvatar(url: rowModel.avatarUrl)
    }
}
