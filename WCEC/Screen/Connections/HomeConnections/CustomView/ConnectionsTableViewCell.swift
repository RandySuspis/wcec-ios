//
//  ConnectionsTableViewCell.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Kingfisher

protocol ConnectionsTableViewCellDelegate: NSObjectProtocol {
    func connectionsTableViewCell(_ cell: ConnectionsTableViewCell,
                                  didSelectActionButton sender: UIButton,
                                  type: RelationType)
    func connectionsTableViewCellDidSelectAvatar(url: String)
}

class ConnectionsTableViewCell: BaseTableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var topMessageConstraint: NSLayoutConstraint!
    @IBOutlet weak var eliteImageView: UIImageView!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    @IBOutlet weak var userChatRoleLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!

    var rowModel: ConnectionsRowModel?
    weak var delegate: ConnectionsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnAdd.layer.cornerRadius = 3.0
        btnAdd.layer.borderWidth = 1.0
        btnAdd.layer.borderColor = AppColor.colorOrange().cgColor
        userChatRoleLabel.text = "Admin".localized()
    }

    override func bindingWithModel(_ model: PBaseRowModel) {
        if let rowModel = model as? ConnectionsRowModel {
            self.rowModel = rowModel
            checkBoxImageView.isHidden = true
            lblName.text = rowModel.title
            lblDesc.text = rowModel.desc
            let randSplit = randySplitAndLocalized(rawString: rowModel.desc, split: nil);
            lblDesc.text = randSplit
            lblStatus.text = rowModel.note
            if rowModel.message == "" {
                messageLabel.text = ""
            } else {
                messageLabel.text = "“\(rowModel.message)”"
            }
            eliteImageView.isHidden = !rowModel.elite
            if rowModel.message == "" {
                topMessageConstraint.constant = 0.0
                self.layoutIfNeeded()
            } else {
                topMessageConstraint.constant = 15.0
                self.layoutIfNeeded()
            }
            imgAvatar.kf.setImage(with: URL(string: rowModel.image),
                                  placeholder: #imageLiteral(resourceName: "placeholder"), options: nil,
                                  progressBlock: nil,
                                  completionHandler: nil)
            removeButton.isHidden = true
            switch rowModel.cellType {
            case .normal:
                btnAdd.isHidden = false
                switch rowModel.type {
                case .notFriend:
                    btnAdd.setTitle("Add".localized(), for: .normal)
                    break
                case .friend:
                    btnAdd.setTitle("Message".localized(), for: .normal)
                    break
                case .requestReceived:
                    btnAdd.setTitle("View".localized(), for: .normal)
                    break
                case .requestPending:
                    btnAdd.isHidden = true
                    break
                case .blocked:
                    btnAdd.isHidden = true
                    break
                }
                guard let currentUser = DataManager.getCurrentUserModel() else { return }
                if String(currentUser.id) == rowModel.objectID {
                    btnAdd.isHidden = true
                }
                break
            case .checkbox:
                checkBoxImageView.image = rowModel.isSelected ? #imageLiteral(resourceName: "checkboxCheck") : #imageLiteral(resourceName: "checkboxUncheck")
                checkBoxImageView.isHidden = false
                btnAdd.isHidden = true
                break
            case .delete:
                removeButton.isHidden = false
                if rowModel.userChannelRoleType == .admin {
                    userChatRoleLabel.isHidden = false
                } else {
                    userChatRoleLabel.isHidden = true
                    checkBoxImageView.image = #imageLiteral(resourceName: "closeGrey")
                    checkBoxImageView.isHidden = false
                }
                btnAdd.isHidden = true
                break
            case .label:
                checkBoxImageView.isHidden = true
                btnAdd.isHidden = true
                userChatRoleLabel.isHidden = !(rowModel.userChannelRoleType == .admin)
                break
            }
        }
    }
    
    @IBAction func tapRemove(_ sender: Any) {
        delegate?.connectionsTableViewCell(self, didSelectActionButton: sender as! UIButton, type: self.rowModel!.type)
    }
    
    @IBAction func btnAdd_Action(_ sender: Any) {
        delegate?.connectionsTableViewCell(self, didSelectActionButton: sender as! UIButton, type: self.rowModel!.type)
    }
    
    @IBAction func tapAvatar(_ sender: Any) {
        delegate?.connectionsTableViewCellDidSelectAvatar(url: self.rowModel!.image)
    }
}
