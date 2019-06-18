//
//  GalleryPagerView.swift
//  WCEC
//
//  Created by hnc on 6/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class GalleryPagerView: BaseTabPagerView {
    @IBOutlet weak var photosBtn: UIButton!
    @IBOutlet weak var videosBtn: UIButton!

    override func setupView() {
        super.setupView()
        photosBtn.setTitle("Photos".localized(), for: .normal)
        videosBtn.setTitle("Videos".localized(), for: .normal)
    }
    
    override func tabButtonList() -> [UIButton] {
        self.isButtonEqual = true
        return [photosBtn,videosBtn]
    }
    
    @IBAction func onClick(_ sender: UIButton) {
        onButtonClick(sender)
    }
}
