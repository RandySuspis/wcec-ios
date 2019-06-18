//
//  ParentTagHeaderView.swift
//  WCEC
//
//  Created by hnc on 5/10/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
protocol ParentTagHeaderViewDelegate: class {
    func onSelectHeaderView(_ header: ParentTagHeaderView, section: Int)
}

class ParentTagHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: ParentTagHeaderViewDelegate?
    var section: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func didSelectHeaderView(_ sender: Any) {
        delegate?.onSelectHeaderView(self, section: section)
    }
    
    func setCollapsed(_ collapsed: Bool) {
        if collapsed == true {
            imageView.image = UIImage(named:"plusOrange")
        } else {
            imageView.image = UIImage(named:"minusGray")
        }
    }

}
