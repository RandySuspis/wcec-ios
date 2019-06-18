//
//  ChildTagOtherTableViewCell.swift
//  WCEC
//
//  Created by hnc on 9/21/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ChildTagOtherTableViewCell: UITableViewCell {
    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func selected(_ isSelected: Bool) {
        if isSelected {
            selectImageView.image = UIImage(named: "checkboxCheck")
        } else {
            selectImageView.image = UIImage(named: "checkboxUncheck")
        }
    }
}
