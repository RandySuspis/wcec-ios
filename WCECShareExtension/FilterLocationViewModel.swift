//
//  FilterLocationViewModel.swift
//  WCEC
//
//  Created by GEM on 5/25/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class FilterLocationViewModel: NSObject {
    var dataLocation = [rowModelLocation]()
    
    func parseData(_ data: [CountryModel], dataSelected: [rowModelLocation]) {
        dataLocation = []
        for item in data {
            var isSelected = false
            if dataSelected.count > 0 {
                for itemSelected in dataSelected {
                    if itemSelected.data.id == item.id {
                        isSelected = true
                    }
                }
            } else {
                isSelected = false
            }
            dataLocation.append(rowModelLocation(item, isSelected: isSelected))
        }
    }
    
    func getDataIsSelected() -> [rowModelLocation] {
        var dataIsSelected = [rowModelLocation]()
        for item in dataLocation {
            if item.isSelected {
                dataIsSelected.append(item)
            }
        }
        return dataIsSelected
    }
}

class rowModelLocation {
    var data: CountryModel
    var isSelected: Bool
    
    init(_ data: CountryModel, isSelected: Bool) {
        self.data = data
        self.isSelected = isSelected
    }
}
