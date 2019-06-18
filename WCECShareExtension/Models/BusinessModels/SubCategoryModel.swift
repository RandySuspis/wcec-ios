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
    var type: TypeSubCategory?
    var isSelected: Bool = false
    
    init(_ dto: SubCategoryDTO) {
        id = dto.id
        name = dto.name
        type = dto.type == "" ? .industries : TypeSubCategory(rawValue: dto.type)
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
