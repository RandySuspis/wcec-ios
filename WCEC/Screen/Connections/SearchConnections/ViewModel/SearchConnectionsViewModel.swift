//
//  SearchConnectionsViewModel.swift
//  WCEC
//
//  Created by GEM on 5/16/18.
//  Copyright © 2018 hnc. All rights reserved.
//

class SearchConnectionsViewModel {
    var rowsKeywords = [PBaseRowModel]()
    var rowsDataSearch = [ConnectionsRowModel]()
    var listIndustriesSelected = [SubCategoryModel]()
    var listInterestsSelected = [SubCategoryModel]()
    var listLocationSelected = [rowModelLocation]()
    
    func parseKeywords(_ data: [String]) {
        rowsKeywords = [PBaseRowModel]()
        rowsDataSearch = [ConnectionsRowModel]()
        for item in data {
            rowsKeywords.append(ConnectionsRowModel(item))
        }
    }
    
    func parseDataSearch(_ data: [UserModel]) {
        rowsKeywords = [PBaseRowModel]()
        rowsDataSearch = [ConnectionsRowModel]()
        for item in data {
            rowsDataSearch.append(ConnectionsRowModel(item, type: .normal))
        }
    }
    
    func doUpdateDataSearch(_ data: [UserModel]) {
        rowsKeywords = [PBaseRowModel]()
        for item in data {
            rowsDataSearch.append(ConnectionsRowModel(item, type: .normal))
        }
    }
    
    func removeTagView(_ param: String) {
        if let index = listIndustriesSelected.index(where: {$0.name == param}) {
            listIndustriesSelected.remove(at: index)
        }
        if let index = listLocationSelected.index(where: {$0.data.name == param}) {
            listLocationSelected.remove(at: index)
        }
        if let index = listInterestsSelected.index(where: {$0.name == param}) {
            listInterestsSelected.remove(at: index)
        }
    }
}
