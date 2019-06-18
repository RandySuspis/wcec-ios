//
//  ProfileHeaderView.swift
//  WCEC
//
//  Created by hnc on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol ProfileHeaderViewDelegate: NSObjectProtocol {
    func profileHeaderViewDidTapEdit(sectionIndex: Int)
}

class ProfileHeaderView: BaseTableHeaderView {
    
    @IBOutlet weak var editImageView: UIImageView!

    weak var delegate: ProfileHeaderViewDelegate?
    
    @IBAction func tapEdit(_ sender: Any) {
        delegate?.profileHeaderViewDidTapEdit(sectionIndex: sectionIndex)
    }
}
