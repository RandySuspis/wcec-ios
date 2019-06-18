//
//  ProfileInterestsTableViewCell.swift
//  WCEC
//
//  Created by GEM on 6/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ProfileInterestsTableViewCell: BaseTableViewCell {

    @IBOutlet weak var tagListView: TagRelationListView!
    @IBOutlet weak var descCellLabel: UILabel!
    @IBOutlet weak var topDescLabelConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindingData(_ data: [SubCategoryModel], type: TypeSubCategory, userId: Int) {
        descCellLabel.text = type == .industries  ?
            "Set your industries to give you more relevant suggestion".localized() :
            "Set your interests to give you more relevant suggestion".localized()
        tagListView.removeAllTags()
        
        guard let currentUser = DataManager.getCurrentUserModel() else { return }
        if currentUser.id != userId {
            descCellLabel.text = ""
            data.forEach({
                tagListView.addTag($0.name.localized(), $0.id, $0.isSelected, $0.isSelected)
            })
            topDescLabelConstraint.constant = 0.0
        } else {
            data.forEach({
                tagListView.addTag($0.name.localized(), $0.id, true, false)
            })
            topDescLabelConstraint.constant = 17.0
        }
        tagListView.scrollRectToVisible(CGRect(x:0, y:0, width: tagListView.frame.size.width, height: tagListView.frame.size.height), animated: false)
//        self.layoutIfNeeded()
    }
}
