//
//  ProfileTableViewCell.swift
//  WCEC
//
//  Created by hnc on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol ProfileTableViewCellDelegate: NSObjectProtocol {
    func profileTableViewCell(_ cell: ProfileTableViewCell, didSelectAcceptButton sender: UIButton)
    func profileTableViewCell(_ cell: ProfileTableViewCell, didSelectRejectButton sender: UIButton)
    func profileTableViewCell(_ cell: ProfileTableViewCell, didSelectAddButton sender: UIButton)
    func profileTableViewCell(_ cell: ProfileTableViewCell, didSelectMessageButton sender: UIButton)
    func profileTableViewCellDidSelectedTab(_ cell: ProfileTableViewCell, index: Int)
    func profileTableViewCellDidSelectedEditIntro(_ cell: ProfileTableViewCell)
    func profileTableViewCellDidSelectedCreateNewPost(_ cell: ProfileTableViewCell)
    func profileTableViewCellDidCancelRequest(_ cell: ProfileTableViewCell)
    func profileTableViewCellDidTapEdit(_ cell: ProfileTableViewCell)
    func profileTableViewCellDidTapAvatar(_ image: String)
}

class ProfileTableViewCell: BaseTableViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var profilePagerView: ProfilePagerView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var ignoreButton: UIButton!
    @IBOutlet weak var addORMessageButton: UIButton!
    @IBOutlet weak var pendingResponseLabel: UILabel!
    @IBOutlet weak var eliteImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var buttonContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editContainerView: UIView!
    @IBOutlet weak var editContainerWidthConstraint: NSLayoutConstraint!
    
    var rowModel: ProfileDetailRowModel?
    
    weak var delegate: ProfileTableViewCellDelegate?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePagerView.delegate = self
        ignoreButton.layer.borderWidth = 1.0
        ignoreButton.layer.borderColor = AppColor.colorBorderRustyOrange().cgColor
        
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 1.0
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.borderColor = AppColor.colorWarmGrey().cgColor
    }

    // MARK: - IBAction
    @IBAction func onSelectAccept(_ sender: Any) {
        delegate?.profileTableViewCell(self, didSelectAcceptButton: sender as! UIButton)
    }
    
    @IBAction func onSelectIgnore(_ sender: Any) {
        delegate?.profileTableViewCell(self, didSelectRejectButton: sender as! UIButton)
    }
    
    @IBAction func onSelectAddOrMessage(_ sender: Any) {
        guard let currentUser = DataManager.getCurrentUserModel() else { return }
        guard let rowModel = rowModel else { return }
        guard String(currentUser.id) != rowModel.objectID else {
            if rowModel.note == TabProfile.basicInfo.rawValue {
                delegate?.profileTableViewCellDidSelectedEditIntro(self)
            } else if rowModel.note == TabProfile.posts.rawValue {
                delegate?.profileTableViewCellDidSelectedCreateNewPost(self)
            }
            return
        }
        if rowModel.type == .notFriend {
            delegate?.profileTableViewCell(self, didSelectAddButton: sender as! UIButton)
        } else if rowModel.type == .friend {
            delegate?.profileTableViewCell(self, didSelectMessageButton: sender as! UIButton)
        }
    }
    
    @IBAction func onCancelRequest(_ sender: Any) {
        delegate?.profileTableViewCellDidCancelRequest(self)
    }
    
    @IBAction func tapEdit(_ sender: Any) {
        delegate?.profileTableViewCellDidTapEdit(self)
    }
    
    // MARK: - Action
    func bindingWithModel(_ model: PBaseRowModel, _ tabIndex: Int) {
        if let rowModel = model as? ProfileDetailRowModel {
            self.rowModel = rowModel
            nameLabel.text = rowModel.title
            let randSplit = randySplitAndLocalized(rawString: rowModel.desc, split: nil);
            descriptionLabel.text = randSplit;
            statusLabel.text = rowModel.location
            eliteImageView.isHidden = !(rowModel.userModel?.elite)!
            avatarImageView.kf.setImage(with: URL(string: rowModel.image),
                                  placeholder: #imageLiteral(resourceName: "placeholder"), options: nil,
                                  progressBlock: nil,
                                  completionHandler: nil)
            guard let currentUser = DataManager.getCurrentUserModel() else { return }
            guard String(currentUser.id) != rowModel.objectID else {
//                addORMessageButton.isHidden = false
                addORMessageButton.isEnabled = true
                addORMessageButton.backgroundColor = AppColor.colorLipStick()
                acceptButton.isHidden = true
                ignoreButton.isHidden = true
                pendingResponseLabel.isHidden = true
                cancelButton.isHidden = true
//                addORMessageButton.setTitle( rowModel.note == TabProfile.basicInfo.rawValue ?
//                    "Edit Intro".localized() : "Create New Post".localized(), for: .normal)
                if tabIndex == TabProfile.basicInfo.hashValue  {
                    addORMessageButton.isHidden = true
                    buttonContainerView.isHidden = true
                    buttonContainerHeightConstraint.constant = 0
                    buttonBottomConstraint.constant = 0
                    if String(currentUser.id) != rowModel.objectID {
                        self.editContainerView.isHidden = true
                        self.editContainerWidthConstraint.constant = 0
                    } else {
                        self.editContainerView.isHidden = false
                        self.editContainerWidthConstraint.constant = 40
                    }
                } else {
                    addORMessageButton.isHidden = false
                    addORMessageButton.setTitle("Create New Post".localized(), for: .normal)
                    self.editContainerView.isHidden = true
                    self.editContainerWidthConstraint.constant = 0
                    if String(currentUser.id) == rowModel.objectID {
                        buttonContainerView.isHidden = false
                        buttonContainerHeightConstraint.constant = 40
                        buttonBottomConstraint.constant = 22
                    } else {
                        buttonContainerView.isHidden = true
                        buttonContainerHeightConstraint.constant = 0
                        buttonBottomConstraint.constant = 0
                    }
                }
                return
            }
            
            switch rowModel.type {
            case .friend:
                addORMessageButton.isHidden = false
                addORMessageButton.setTitle("Message".localized(), for: .normal)
                addORMessageButton.isEnabled = true
                addORMessageButton.backgroundColor = AppColor.colorLipStick()
                acceptButton.isHidden = true
                ignoreButton.isHidden = true
                pendingResponseLabel.isHidden = true
                break
            case .notFriend:
                addORMessageButton.isHidden = false
                addORMessageButton.setTitle("Add".localized(), for: .normal)
                addORMessageButton.isEnabled = true
                addORMessageButton.backgroundColor = AppColor.colorLipStick()
                acceptButton.isHidden = true
                ignoreButton.isHidden = true
                pendingResponseLabel.isHidden = true
                break
            case .requestPending:
                addORMessageButton.isHidden = true
                acceptButton.isHidden = true
                ignoreButton.isHidden = true
                pendingResponseLabel.isHidden = false
                break
            case .requestReceived:
                addORMessageButton.isHidden = true
                acceptButton.isHidden = false
                ignoreButton.isHidden = false
                pendingResponseLabel.isHidden = true
                break
            case .blocked:
                addORMessageButton.isHidden = false
                addORMessageButton.setTitle("Add", for: .normal)
                addORMessageButton.isEnabled = false
                addORMessageButton.backgroundColor = AppColor.colorGrayButton()
                acceptButton.isHidden = true
                ignoreButton.isHidden = true
                pendingResponseLabel.isHidden = true
                break
            }
            if String(currentUser.id) != rowModel.objectID {
                self.editContainerView.isHidden = true
                self.editContainerWidthConstraint.constant = 0
            } else {
                self.editContainerView.isHidden = false
                self.editContainerWidthConstraint.constant = 40
            }
            cancelButton.isHidden = pendingResponseLabel.isHidden
        }
    }

    @IBAction func tapAvatar(_ sender: Any) {
        guard let rowModel = rowModel else {
            return;
        }
        delegate?.profileTableViewCellDidTapAvatar(rowModel.image)
    }
    
}

// MARK: - BaseTabPagerViewDelegate
extension ProfileTableViewCell: BaseTabPagerViewDelegate {
    func baseTabPagerView(_ baseTabPagerView: BaseTabPagerView, didSelectAt index: Int) {
        delegate?.profileTableViewCellDidSelectedTab(self, index: index)
    }
}
