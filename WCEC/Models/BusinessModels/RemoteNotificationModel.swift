//
//  RemoteNotificationModel.swift
//  WCEC
//
//  Created by GEM on 7/4/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import SwiftyJSON

class RemoteNotificationModel {
    var notificationType: NotificationType
    var id: Int
    var userId: Int
    init(_ userInfo: [AnyHashable: Any]) {
        let jsonData = try! JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        let json = try! JSON(data: jsonData)
        id = json["custom"]["a"]["id"].intValue
        notificationType = NotificationType(rawValue: json["custom"]["a"]["type"].stringValue) ?? .connection
        userId = json["custom"]["a"]["user_id"].intValue
    }
}
