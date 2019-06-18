//
//  QuoteDTO.swift
//  WCEC
//
//  Created by GEM on 6/8/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import SwiftyJSON

class QuoteDTO: NSObject {
    var id: Int
    var name: String
    var jobtitle: String
    var avatar: FileDTO
    var quote: String
    var created_at: String
    var updated_at: String
    
    init(_ json: JSON) {
        id = json["id"].intValue
        jobtitle = json["jobtitle"].stringValue
        name = json["name"].stringValue
        quote = json["quote"].stringValue
        created_at = json["created_at"].stringValue
        updated_at = json["updated_at"].stringValue
        avatar = FileDTO.init(json["avatar"])
    }
}
