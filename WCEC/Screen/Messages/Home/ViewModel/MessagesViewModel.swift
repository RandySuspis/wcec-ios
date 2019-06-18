//
//  MessagesViewModel.swift
//  WCEC
//
//  Created by GEM on 6/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

class MessagesViewModel: NSObject {
    var rows = [MessagesRowModel]()
    
    func parseData(_ data: [ChannelModel]) {
        rows = []
        data.forEach({
            rows.append(MessagesRowModel($0))
        })
    }
    
    func doUpdateData(_ data: [ChannelModel]) {
        data.forEach({
            rows.append(MessagesRowModel($0))
        })
    }
    
    func addData(_ item: ChannelModel, index: Int) {
        rows.insert(MessagesRowModel(item), at: index)
    }
}
