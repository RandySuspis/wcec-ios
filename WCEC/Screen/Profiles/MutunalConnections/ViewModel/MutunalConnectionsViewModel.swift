//
//  MutunalConnectionsViewModel.swift
//  WCEC
//
//  Created by GEM on 6/25/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class MutunalConnectionsViewModel: NSObject {
    var rows = [ConnectionsRowModel]()
    
    func parseData(_ data: [UserModel]) {
        rows = [ConnectionsRowModel]()
        for item in data {
            self.rows.append(ConnectionsRowModel(item, type: .normal))
        }
    }
    
    func doUpdateData(_ data: [UserModel]) {
        for item in data {
            self.rows.append(ConnectionsRowModel(item, type: .normal))
        }
    }
}
