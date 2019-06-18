//
//  RequestDTO.swift
//  WCEC
//
//  Created by GEM on 5/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class RequestDTO: NSObject {
    var id: Int
    var message: String
    var created_at: String
    var updated_at: String
    var user: UserDTO
    
    init(_ json: JSON) {
        id                           = json["id"].intValue
        message                      = json["message"].stringValue
        created_at                   = json["created_at"].stringValue
        updated_at                   = json["updated_at"].stringValue
        user                         = UserDTO(json["user"])
    }
}

