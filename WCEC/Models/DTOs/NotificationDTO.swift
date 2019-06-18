//
//  NotificationDTO.swift
//  WCEC
//
//  Created by GEM on 7/9/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationDTO: NSObject {
    var id: Int
    var title: String
    var type: NotificationType
    var entity_id: Int
    var content: String
    var status: Bool
    var created_at: String
    var updated_at: String
    var countNotification: Int
    var countMsgNotification: Int
    
    init(_ json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        type = NotificationType(rawValue: json["type"].stringValue) ?? .connection
        entity_id = json["entity_id"].intValue
        content = json["content"].stringValue
        status = json["status"].boolValue
        created_at = json["created_at"].stringValue
        updated_at = json["updated_at"].stringValue
        countNotification = json["notifications"].intValue
        countMsgNotification = json["messages"].intValue
    }
}
