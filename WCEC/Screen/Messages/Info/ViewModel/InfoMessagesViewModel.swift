//
//  InfoMessagesViewModel.swift
//  WCEC
//
//  Created by GEM on 6/27/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

class InfoMessagesViewModel {
    var rows = [ConnectionsRowModel]()
    
    func parseData(_ data: [UserModel], withType: ConnectionsCellType) {
        rows = [ConnectionsRowModel]()
        for item in data {
            self.rows.append(ConnectionsRowModel(item, type: withType))
        }
    }
    
    func doUpdateData(_ data: [UserModel]) {
        for item in data {
            self.rows.append(ConnectionsRowModel(item, type: .delete))
        }
    }
}
