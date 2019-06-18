//
//  ReceivedModel.swift
//  WCEC
//
//  Created by GEM on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

class ReceivedModel {
    var rows = [ConnectionsRowModel]()
    
    func parseData(_ data: [RequestModel]) {
        rows = [ConnectionsRowModel]()
        for item in data {
            self.rows.append(ConnectionsRowModel(item, type: .normal))
        }
    }
    
    func doUpdateData(_ data: [RequestModel]) {
        for item in data {
            self.rows.append(ConnectionsRowModel(item, type: .normal))
        }
    }
    
}
