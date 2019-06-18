//
//  CategorySectionModel.swift
//  WCEC
//
//  Created by hnc on 5/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class CategorySectionModel: NSObject {
    var category: CategoryModel
    var collapsed: Bool
    
    init(type: TypeSubCategory,
         category: CategoryModel,
         collapsed: Bool,
         isFromSearch: Bool,
         searchCategoriesSelected: [SubCategoryModel],
         tagListView: TagListView,
         isFirstTime: Bool) {
        self.category = category
        self.collapsed = collapsed
        var selected = ""
        var firstTimeSelected = ""
        var selectedFromSearch = ""
        guard let data = DataManager.getCurrentUserModel() else {
            return
        }
        
        if isFirstTime {
            switch type {
            case .industries:
                selected = data.industries
                firstTimeSelected = data.industries
                break
            case .interests:
                selected = data.interests
                firstTimeSelected = data.interests
                break
            }
        }
        
        if  tagListView.tagViews.count > 0 &&
            !isFirstTime {
            selected = ""
            for item in tagListView.tagViews {
                selected += "\(item.tagId),"
                print(item.tagId)
            }
            selected.removeLast()
            selectedFromSearch = selected.replacingOccurrences(of: firstTimeSelected, with: "")
        }
        
        guard selected.count > 0 else {
            return
        }
        
        for sub in category.subcategoryList {
            if !isFromSearch{
                for subSelected in selected.components(separatedBy: ",") {
                    if sub.id.description == subSelected {
                        sub.isSelected = true
                        break
                    }
                }
            } else {
                for item in searchCategoriesSelected {
                    if sub.id == item.id {
                        sub.isSelected = true
                        self.collapsed = false
                        break
                    }
                }
                for subSelected in selectedFromSearch.components(separatedBy: ",") {
                    if sub.id.description == subSelected {
                        sub.isSelected = true
                        break
                    }
                }
            }
        }
    }
}
