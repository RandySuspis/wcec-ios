//
//  FilterRowModel.swift
//  WCEC
//
//  Created by GEM on 5/16/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

struct FilterRowModel: PBaseRowModel {
    var desc: String
    var image: String
    var identifier: String
    var note: String
    var objectID: String
    var title: String
    
    init(_ data: SubCategoryModel, identifier: String = FilterTableViewCell.nibName()) {
        self.objectID = String(data.id)
        self.title = data.name
        self.desc = ""
        self.image = ""
        self.note = ""
        self.identifier = identifier
    }
    
    init(_ data: rowModelLocation, identifier: String = FilterTableViewCell.nibName()) {
        self.objectID = String(data.data.id)
        self.title = data.data.name
        self.desc = ""
        self.image = ""
        self.note = ""
        self.identifier = identifier
    }
}
