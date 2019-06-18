//
//  IndustryItemModel.swift
//  WCEC
//
//  Created by hnc on 5/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class IndustryItemModel: NSObject {
    var isSelected: Bool
    var subCategory: SubCategoryModel
    
    init(subCategory: SubCategoryModel, isSelected: Bool) {
        self.subCategory = subCategory
        self.isSelected = isSelected
    }
}
