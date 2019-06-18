//
//  CategoryModel.swift
//  WCEC
//
//  Created by hnc on 5/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

// This class using for both Industry and Interest
class CategoryModel: NSObject {
    var id: Int
    var name: String
    var type: TypeSubCategory?
    var subcategoryList = [SubCategoryModel]()
    
    init(_ dto: CategoryDTO) {
        id = dto.id
        name = dto.name
        type = dto.type == "" ? .industries : TypeSubCategory(rawValue: dto.type)
        for subDTO in dto.subcategoryList {
            let subModel = SubCategoryModel(subDTO)
            subcategoryList.append(subModel)
        }
        
        if id == 0 {
            let subModel = SubCategoryModel(0, "Please specify...", type!)
            subcategoryList.insert(subModel, at: 0)
        }
    }
    
    init(_ id: Int, _ name: String, _ type: TypeSubCategory) {
        self.id = id
        self.name = name
        self.type = type
    }
    
    func getSubCategorySelected() -> [String] {
        var result = [String]()
        for subCategory in self.subcategoryList {
            if subCategory.isSelected == true {
                result.append("\(subCategory.id.description)")
            }
        }
        return result
    }
    
    func getSubCategorySelectedModel() -> [SubCategoryModel] {
        var result = [SubCategoryModel]()
        for subCategory in self.subcategoryList {
            if subCategory.isSelected == true {
                result.append(subCategory)
            }
        }
        return result
    }
    
    required init(coder decoder: NSCoder) {
        id                  = decoder.decodeInteger(forKey: "id")
        name                = decoder.decodeObject(forKey: "name") as? String ?? ""
        subcategoryList     = decoder.decodeObject(forKey: "subcategoryList") as! [SubCategoryModel]
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(subcategoryList, forKey: "subcategoryList")
    }
}
