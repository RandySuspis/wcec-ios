//
//  HeaderSectionFAQ.swift
//  WCEC
//
//  Created by GEM on 6/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol HeaderSectionFAQDelegate: NSObjectProtocol {
    func headerSectionFAQDelegateDidTap(section: Int)
}

class HeaderSectionFAQ: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    weak var delegate: HeaderSectionFAQDelegate?
    var section: Int?
    
    @IBAction func tapSection(_ sender: Any) {
        guard let section = section else {
            return
        }
        delegate?.headerSectionFAQDelegateDidTap(section: section)
    }
}
