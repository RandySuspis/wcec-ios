//
//  NewMessagesViewModel.swift
//  WCEC
//
//  Created by GEM on 6/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

class NewMessagesViewModel {
    
    var rows = [ConnectionsRowModel]()
    var rowsSelected = [ConnectionsRowModel]()
    
    func parseData(_ data: [UserModel]) {
        rows = [ConnectionsRowModel]()
        for item in data {
            var rowModel = ConnectionsRowModel(item, type: .checkbox)
            rowsSelected.forEach({
                if String(item.id) == $0.objectID {
                    rowModel.isSelected = true
                }
            })
            self.rows.append(rowModel)
        }
    }
    
    func doUpdateData(_ data: [UserModel]) {
        for item in data {
            self.rows.append(ConnectionsRowModel(item, type: .checkbox))
        }
    }
    
    func didSelectedRows(_ index: Int) {
        if self.rowsSelected.contains(where: {$0.objectID == rows[index].objectID}) {
            rowsSelected = rowsSelected.filter({ $0.objectID != rows[index].objectID})
        } else {
            rowsSelected.append(rows[index])
        }
        rows[index].isSelected = !rows[index].isSelected
    }
    
    func userSelected() -> String {
        var arr = [String]()
        rowsSelected.forEach({
            arr.append($0.title)
        })
        return arr.joined(separator: ", ")
    }
}
