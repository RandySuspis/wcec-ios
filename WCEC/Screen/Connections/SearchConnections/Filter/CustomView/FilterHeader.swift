//
//  FilterHeader.swift
//  WCEC
//
//  Created by GEM on 5/16/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol FilterHeaderDelegate: NSObjectProtocol {
    func filterHeader(index: Int)
}

class FilterHeader: BaseTableHeaderView {
    weak var delegate: FilterHeaderDelegate?
    
    @IBAction func onPressPlus(_ sender: Any) {
        delegate?.filterHeader(index: sectionIndex)
    }
    
}
