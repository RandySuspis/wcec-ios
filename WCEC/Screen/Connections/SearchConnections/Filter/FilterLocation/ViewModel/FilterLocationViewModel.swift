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
    var dataLocationSelected = [rowModelLocation]()
    
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
    
    func didSelected(_ index: Int) {
        dataLocation[index].isSelected = !dataLocation[index].isSelected
        if self.dataLocationSelected.contains(where: {$0.data.id == dataLocation[index].data.id}) {
            dataLocationSelected = dataLocationSelected.filter({ $0.data.id != dataLocation[index].data.id})
        } else {
            dataLocationSelected.append(dataLocation[index])
        }
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
