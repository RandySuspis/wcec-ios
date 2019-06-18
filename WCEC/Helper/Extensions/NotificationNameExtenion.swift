//
//  NotificationNameExtenion.swift
//  WCEC
//
//  Created by GEM on 6/28/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
extension Notification.Name {
    static let kScrollToTopListNewfeed   = Notification.Name("kScrollToTopListNewfeed")          // Scroll To Top List Newfeed
    static let kRefreshListNewfeed      = Notification.Name("kRefreshListNewfeed")          // Refresh List Newfeed
    static let kRefreshNewfeedDetail    = Notification.Name("kRefreshNewfeedDetail")        // Refresh Newfeed detail
    static let kRefreshMyProfile        = Notification.Name("kRefreshMyProfile")            // Refresh Profile
    static let kRefreshConnections      = Notification.Name("kRefreshConnections")          // Refresh List Connections
    static let kRefreshListMessage      = Notification.Name("kRefreshListMessage")          // Refresh List Message
    static let kRefreshNotificationRedDot = Notification.Name("kRefreshNotificationRedDot") // RefreshNotification red dot
}
