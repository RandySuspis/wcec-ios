//
//  ChildTagTableViewCell.swift
//  WCEC
//
//  Created by hnc on 5/10/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ChildTagTableViewCell: UITableViewCell {
    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func selected(_ isSelected: Bool) {
        if isSelected {
            selectImageView.image = UIImage(named: "checkboxCheck")
        } else {
            selectImageView.image = UIImage(named: "checkboxUncheck")
        }
    }
}
