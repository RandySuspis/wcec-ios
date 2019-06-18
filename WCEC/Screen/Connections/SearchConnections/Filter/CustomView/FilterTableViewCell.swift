//
//  FilterTableViewCell.swift
//  WCEC
//
//  Created by GEM on 5/16/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol FilterTableViewCellDelegate: NSObjectProtocol {
    func didDelete(_ cell: FilterTableViewCell, didSelectActionButton sender: UIButton)
}

class FilterTableViewCell: BaseTableViewCell {

    weak var delegate: FilterTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onPressDelete(_ sender: UIButton) {
        delegate?.didDelete(self, didSelectActionButton: sender)
    }
    
}
