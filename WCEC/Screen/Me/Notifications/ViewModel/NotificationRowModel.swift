//
//  NotificationRowModel.swift
//  WCEC
//
//  Created by GEM on 6/28/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

class NotificationRowModel: PBaseRowModel {
    var title: String
    var desc: String
    var image: String
    var identifier: String
    var objectID: String
    var note: String
    var isSeen: Bool
    var type: NotificationType
    var entity_id: String
    
    init(_ data: NotificationModel) {
        self.objectID = String(data.id)
        self.title = data.content
        self.desc = Date.convertUTCToLocal(date: data.updated_at,
                                           fromFormat: "yyyy-MM-dd HH:mm:ss",
                                           toFormat: "yyyy-MM-dd HH:mm:ss")?.wcecTimeAgoSinceNow ?? ""
        self.image = ""
        self.identifier = NotificationTableViewCell.nibName()
        self.note = ""
        self.isSeen = data.status
        self.type = data.type
        self.entity_id = String(data.entity_id)
    }
}
