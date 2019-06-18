//
//  CategoryDTO.swift
//  WCEC
//
//  Created by hnc on 5/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

// This class using for both Industry and Interest
class CategoryDTO: NSObject {
    var id: Int
    var name: String
    var type: String
    var subcategoryList = [SubCategoryDTO]()
    
    init(_ json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        type = json["type"].stringValue
        for (_,subJson):(String, JSON) in json["children"] {
            let subcategoryDTO = SubCategoryDTO(subJson)
            subcategoryList.append(subcategoryDTO)
        }
    }
}
