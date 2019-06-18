//
//  NewfeedCommentTableViewCell.swift
//  WCEC
//
//  Created by GEM on 6/20/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

@objc protocol NewfeedCommentTableViewCellDelegate {
    @objc optional func newfeedCommentTableViewCellShouldDelete(_ cell: NewfeedCommentTableViewCell)
    func newfeedCommentTableViewCellDidTapAvatar(url: String)
}

class NewfeedCommentTableViewCell: BaseTableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var eliteImageView: UIImageView!
    
    weak var delegate: NewfeedCommentTableViewCellDelegate?
    var model: PBaseRowModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func bindingWithModel(_ model: PBaseRowModel) {
        super.bindingWithModel(model)
        self.model = model
        timeAgoLabel.text = model.note
        avatarImageView.kf.setImage(with: URL(string: model.image),
                                    placeholder: #imageLiteral(resourceName: "placeholder"),
                                    options: nil,
                                    progressBlock: nil,
                                    completionHandler: nil)
        if let rowModel = model as? NewfeedCommentRowModel {
            eliteImageView.isHidden = !rowModel.elite
        }
        if  let currentUser = DataManager.getCurrentUserModel(),
            let model = model as? NewfeedCommentRowModel {
            deleteButton.isHidden = !(String(currentUser.id) == model.authorId)
        }
    }
    
    @IBAction func onDelete(_ sender: Any) {
        delegate?.newfeedCommentTableViewCellShouldDelete?(self)
    }
    
    @IBAction func tapAvatar(_ sender: Any) {
        guard let model = model else {
            return;
        }
        delegate?.newfeedCommentTableViewCellDidTapAvatar(url: model.image)
    }
}
