//
//  ChannelDTO.swift
//  WCEC
//
//  Created by hnc on 6/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChannelDTO: NSObject {
    var id: Int
    var name: String
    var createdAt: String
    var updatedAt: String
    var members = [UserDTO]()
    var lastMessage: String
    var lastTimeClearHistory: String
    var leftChannelDate : String
    var new: Bool
    var images = [String]()
    
    init(_ json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        createdAt = json["created_at"].stringValue
        updatedAt = json["updated_at"].stringValue
        new = json["new"].boolValue
        
        for (_,subJson):(String, JSON) in json["members"] {
            let memberDTO = UserDTO(subJson)
            members.append(memberDTO)
        }
        for (_,subJson):(String, JSON) in json["images"] {
            images.append(subJson.stringValue)
        }
        lastMessage = json["last_message"].stringValue
        leftChannelDate     = json["left_date"].stringValue
        lastTimeClearHistory = json["last_time_clear_history"].stringValue
    }
}
