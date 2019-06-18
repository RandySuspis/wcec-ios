//
//  NotificationTableViewCell.swift
//  WCEC
//
//  Created by GEM on 6/28/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class NotificationTableViewCell: BaseTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func bindingWithModel(_ model: PBaseRowModel) {
        super.bindingWithModel(model)
        guard let rowModel = model as? NotificationRowModel else { return }
        self.backgroundColor = rowModel.isSeen ? UIColor.white : AppColor.colorPinkLow()
    }
    
}
