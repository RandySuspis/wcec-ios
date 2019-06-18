//
//  SubCategoryDTO.swift
//  WCEC
//
//  Created by hnc on 5/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

// This class using for both Industry and Interest
class SubCategoryDTO: NSObject {
    var id: Int
    var type: String
    var name: String
    
    init(_ json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        type = json["type"].stringValue
    }
}
