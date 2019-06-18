//
//  FAQDTO.swift
//  WCEC
//
//  Created by GEM on 7/4/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class FAQDTO: NSObject {
    var id: Int
    var title: String
    var answer: String
    var createdAt: String
    var updatedAt: String
    
    init(_ json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        answer = json["answer"].stringValue
        createdAt = json["created_at"].stringValue
        updatedAt = json["updated_at"].stringValue
    }
}
