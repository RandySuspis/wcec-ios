//
//  SearchTagsSectionModel.swift
//  WCEC
//
//  Created by hnc on 6/18/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class SearchTagsSectionModel: NSObject {
    var category: CategoryModel
    var collapsed: Bool
    
    init(category: CategoryModel,
         collapsed: Bool,
         searchCategoriesSelected: [SubCategoryModel],
         tagListView: TagListView) {
        self.category = category
        self.collapsed = collapsed
        
        guard let data = DataManager.getCurrentUserModel() else {
            return
        }
        
        for sub in category.subcategoryList {
            if searchCategoriesSelected.count > 0{
                for item in searchCategoriesSelected {
                    if sub.id == item.id && sub.type == item.type {
                        sub.isSelected = true
                        self.collapsed = false
                        break
                    }
                }
            }
        }
    }
}
