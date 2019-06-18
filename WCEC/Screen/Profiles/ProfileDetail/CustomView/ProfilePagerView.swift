//
//  ProfilePagerView.swift
//  WCEC
//
//  Created by hnc on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ProfilePagerView: BaseTabPagerView {
    @IBOutlet weak var basicInfoButton: UIButton!
    @IBOutlet weak var postsButton: UIButton!
    
    override func setupView() {
        super.setupView()
        basicInfoButton.setTitle("Basic Info".localized(), for: .normal)
        postsButton.setTitle("Posts".localized(), for: .normal)
    }
    
    override func tabButtonList() -> [UIButton] {
        return [basicInfoButton,postsButton]
    }
    
    @IBAction func onClick(_ sender: UIButton) {
        onButtonClick(sender)
    }
}
