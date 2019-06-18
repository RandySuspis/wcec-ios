//
//  BaseNewFeedTableViewCell.swift
//  WCEC
//
//  Created by GEM on 6/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Kingfisher

@objc protocol BaseNewFeedTableViewCellDelegate: NSObjectProtocol {
    @objc optional func baseNewFeedTableViewCell(_ cell: BaseNewFeedTableViewCell)
    @objc optional func baseNewFeedTableViewCellDidSelectAsset(_ cell: BaseNewFeedTableViewCell, listImage: [String])
    @objc optional func baseNewFeedTableViewCellDidSelectMore(_ cell: BaseNewFeedTableViewCell)
    @objc optional func baseNewFeedTableViewCellDidSelectShare(_ cell: BaseNewFeedTableViewCell)
    @objc optional func baseNewFeedTableViewCellDidSelectLike(_ cell: BaseNewFeedTableViewCell)
    @objc optional func baseNewFeedTableViewCellShouldPlayVideo(_ cell: BaseNewFeedTableViewCell, link: String)
    @objc optional func baseNewFeedTableViewCellDidSelectedTags(_ cell: BaseNewFeedTableViewCell)
    func baseNewFeedTableViewCellDidTapAvatar(_ url: String)
}

class BaseNewFeedTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var countStatusLabel: UILabel?
    @IBOutlet weak var descLabel: UILabel?
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var likeButton: UIButton?
    @IBOutlet weak var commentButton: UIButton?
    @IBOutlet weak var shareButton: UIButton?
    @IBOutlet weak var eliteImageView: UIImageView?
    @IBOutlet weak var shareLabel: UILabel?
    @IBOutlet weak var tagsLabel: UILabel?
    @IBOutlet weak var constraintBetweenTagsAndLike: NSLayoutConstraint!
    
    weak var delegate: BaseNewFeedTableViewCellDelegate?
    var model: NewFeedRowModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeButton?.setTitle("Like".localized(), for: .normal)
        commentButton?.setTitle("Comment".localized(), for: .normal)
        shareButton?.setTitle("Share".localized(), for: .normal)
        
        let tapDesc = UITapGestureRecognizer(target: self, action: #selector(onPressDesc(sender:)))
        descLabel?.isUserInteractionEnabled = true
        descLabel?.addGestureRecognizer(tapDesc)
        
        let tapTag = UITapGestureRecognizer(target: self, action: #selector(onPressTag(sender:)))
        tagsLabel?.isUserInteractionEnabled = true
        tagsLabel?.addGestureRecognizer(tapTag)
    }

    func bindingWithModel(_ model: NewFeedRowModel) {
        self.model = model
        nameLabel?.text = model.name
        timeLabel?.text = model.time
        var arrStatus = [String]()
        if model.likeCount > 0 {
            var countString = "\(model.likeCount) "
            countString += model.likeCount == 1 ? "Like".localized() : "Likes".localized()
            arrStatus.append(countString)
        }
        if model.commentCount > 0 {
            var countString = "\(model.commentCount) "
            countString += model.commentCount == 1 ? "Comment".localized() : "Comments".localized()
            arrStatus.append(countString)
        }
        if model.shareCount > 0 {
            var countString = "\(model.shareCount) "
            countString += model.shareCount == 1 ? "Share".localized() : "Shares".localized()
            arrStatus.append(countString)
        }
        countStatusLabel?.text = arrStatus.joined(separator: " • ")
        if model.isLiked {
            self.likeButton?.setImage(#imageLiteral(resourceName: "liked"), for: .normal)
        } else {
            self.likeButton?.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        }
        eliteImageView?.isHidden = !model.elite
        avatarImageView?.kf.setImage(with: URL(string: model.avatar),
                                     placeholder: #imageLiteral(resourceName: "placeholder"),
                                     options: nil,
                                     progressBlock: nil,
                                     completionHandler: nil)
        if model.nameParentPost == "" {
            self.shareLabel?.text = ""
        } else {
            self.shareLabel?.text = "Original Post by".localized() + " \(model.nameParentPost)"
        }
        parseDescLabel(model)
        parseTagLabel(model)
    }
    
    func parseDescLabel(_ model: NewFeedRowModel) {
        descLabel?.text = model.desc
        if let numberOfVisibleLines = descLabel?.numberOfVisibleLines {
            guard numberOfVisibleLines > 3 else {
                return
            }
            if model.isDescCollapse {
                self.descLabel?.addSeeMore(with: "...  ",
                                           moreText: "See more".localized(),
                                           moreTextFont: AppFont.fontWithType(.regular, size: 12),
                                           moreTextColor: AppColor.colorTitleTextField())
            } else {
                self.descLabel?.text = model.desc
            }
        }
    }
    
    func parseTagLabel(_ model: NewFeedRowModel) {
        tagsLabel?.text = model.isShowTags ? model.tags : ""
        if tagsLabel?.text?.count == 0 {
            constraintBetweenTagsAndLike.constant = 0
        } else {
            constraintBetweenTagsAndLike.constant = 10
        }
        if let numberOfVisibleLines = tagsLabel?.numberOfVisibleLines {
            guard numberOfVisibleLines > 1 else {
                return
            }
            if model.isTagCollapse {
                self.tagsLabel?.numberOfLines = 1
            } else {
                self.tagsLabel?.numberOfLines = 0
                self.tagsLabel?.text = model.isShowTags ? model.tags : ""
            }
        }
    }
    
    @objc func onPressDesc(sender:UITapGestureRecognizer) {
        delegate?.baseNewFeedTableViewCell?(self)
    }
    
    @objc func onPressTag(sender:UITapGestureRecognizer) {
        delegate?.baseNewFeedTableViewCellDidSelectedTags?(self)
    }
    
    @IBAction func onLike(_ sender: Any) {
        if !DataManager.checkIsGuestUser() {
            delegate?.baseNewFeedTableViewCellDidSelectLike?(self)
        }
    }
    
    @IBAction func onComment(_ sender: Any) {
        
    }
    
    @IBAction func onShare(_ sender: Any) {
        if !DataManager.checkIsGuestUser() {
            delegate?.baseNewFeedTableViewCellDidSelectShare?(self)
        }
    }
    
    @IBAction func onOthers(_ sender: Any) {
        if !DataManager.checkIsGuestUser() {
            delegate?.baseNewFeedTableViewCellDidSelectMore?(self)
        }
    }

    @IBAction func tapAvatar(_ sender: Any) {
        guard let model = model else {
            return
        }
        delegate?.baseNewFeedTableViewCellDidTapAvatar(model.avatar)
    }
    
}
