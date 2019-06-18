//
//  ProfileMutualTableViewCell.swift
//  WCEC
//
//  Created by hnc on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ProfileMutualTableViewCell: BaseTableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func bindingWithModel(_ model: PBaseRowModel) {
        if let rowModel = model as? ProfileDetailRowModel {
            lblName.text = rowModel.title
            lblDesc.text = rowModel.desc
        }
    }
}
