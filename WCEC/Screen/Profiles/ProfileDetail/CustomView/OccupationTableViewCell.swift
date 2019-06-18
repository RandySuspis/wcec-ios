//
//  OccupationTableViewCell.swift
//  WCEC
//
//  Created by hnc on 5/16/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class OccupationTableViewCell: BaseTableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func bindingWithModel(_ model: PBaseRowModel) {
        super.bindingWithModel(model)
        if let rowModel = model as? ProfileOccupationRowModel {
            timeLabel.text = rowModel.time
            headerTitleLabel.text = rowModel.title
            companyLabel.text = rowModel.desc
        }
    }
}
