//
//  DateSeperatorTableViewCell.swift
//  WCEC
//
//  Created by hnc on 7/10/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class DateSeperatorTableViewCell: BaseTableViewCell {
    @IBOutlet weak var dateSeperatorView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    
    @IBOutlet weak var dateSeperatorViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewBottomMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateSeperatorLabel.text = ""
    }

    override func bindingWithModel(_ model: PBaseRowModel) {
        super.bindingWithModel(model)
        if let rowModel = model as? ChatRowModel {
            dateSeperatorLabel.text = rowModel.createdDate.stringFromDate()
        }
    }
    
}
