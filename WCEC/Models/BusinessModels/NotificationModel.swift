//
//  NotificationModel.swift
//  WCEC
//
//  Created by GEM on 7/9/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class NotificationModel: NSObject {
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
    
    init(_ dto: NotificationDTO) {
        id = dto.id
        title = dto.title
        type = dto.type
        entity_id = dto.entity_id
        content = dto.content
        status = dto.status
        created_at = dto.created_at
        updated_at = dto.updated_at
        countNotification = dto.countNotification
        countMsgNotification = dto.countMsgNotification
    }
}
