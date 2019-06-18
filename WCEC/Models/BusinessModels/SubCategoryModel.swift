//
//  SubCategoryModel.swift
//  WCEC
//
//  Created by hnc on 5/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

// This class using for both Industry and Interest
class SubCategoryModel: NSObject {
    var id: Int
    var name: String
    var placeHolderString: String = ""
    var type: TypeSubCategory = .industries
    var isSelected: Bool = false
    
    init(_ dto: SubCategoryDTO) {
        id = dto.id
        name = dto.name
        type = dto.type == "" ? .industries : TypeSubCategory(rawValue: dto.type)!
    }
    
    init(_ id: Int, _ name: String, _ type: TypeSubCategory) {
        self.id = id
        self.name = name
        self.type = type
        self.placeHolderString = "Please specify..."
    }
    
    required init(coder decoder: NSCoder) {
        id                  = decoder.decodeInteger(forKey: "id")
        name                = decoder.decodeObject(forKey: "name") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
    }
}
