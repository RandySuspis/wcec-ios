//
//  BaseTableHeaderView.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class BaseTableHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel?
    var sectionIndex: Int = 0
    func bindingWithModel(_ model: PBaseHeaderModel, section index: Int) {
        sectionIndex = index
        titleLabel?.text = model.title
    }
}
