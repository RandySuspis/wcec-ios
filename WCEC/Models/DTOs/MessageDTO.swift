
//
//  MessageDTO.swift
//  WCEC
//
//  Created by hnc on 7/5/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class MessageDTO: NSObject {
    var userId: String
    var avatarUrl: String
    var fullName: String
    var message: String
    var images = [String]()
    var createdDate: Double
    var removed: String
    var identifier: String
    
    init(_ json: JSON) {
        userId = json["user_id"].stringValue
        avatarUrl = json["avatar"].stringValue
        fullName = json["full_name"].stringValue
        message = json["text"].stringValue
        for (_,subJson):(String, JSON) in json["images"] {
            images.append(subJson.stringValue)
        }
        createdDate = json["created_date"].doubleValue
        removed = json["removed"].stringValue
        identifier = json["identifier"].stringValue
    }
}
