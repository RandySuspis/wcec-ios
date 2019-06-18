//
//  CommentDTO.swift
//  WCEC
//
//  Created by GEM on 6/20/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommentDTO: NSObject {
    var id: Int
    var content: String
    var created_at: String
    var updated_at: String
    var author: UserDTO
    
    init(_ json: JSON) {
        id                           = json["id"].intValue
        content                      = json["content"].stringValue
        created_at                   = json["created_at"].stringValue
        updated_at                   = json["updated_at"].stringValue
        author                       = UserDTO(json["author"])
    }
}
