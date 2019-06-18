//
//  NotificationsViewModel.swift
//  WCEC
//
//  Created by GEM on 6/28/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

class NotificationsViewModel: NSObject {
    var rows = [NotificationRowModel]()
    
    func parseData(_ data: [NotificationModel]) {
        rows = [NotificationRowModel]()
        for item in data {
            self.rows.append(NotificationRowModel(item))
        }
    }
    
    func doUpdateData(_ data: [NotificationModel]) {
        for item in data {
            self.rows.append(NotificationRowModel(item))
        }
    }
    
    func didSelectedRow(_ index: Int) {
        rows[index].isSeen = true
    }
}
