//
//  ConnectionsRequestTabPagesView.swift
//  WCEC
//
//  Created by GEM on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ConnectionsRequestTabPagesView: BaseTabPagerView {
    @IBOutlet weak var btnReceived: UIButton!
    @IBOutlet weak var btnSent: UIButton!
    
    override func setupView() {
        super.setupView()
        btnReceived.setTitle("Received".localized(), for: .normal)
        btnSent.setTitle("Sent".localized(), for: .normal)
    }
    
    override func tabButtonList() -> [UIButton] {
        return [btnReceived,btnSent]
    }
    
    @IBAction func onClick(_ sender: UIButton) {
        onButtonClick(sender)
    }
}
