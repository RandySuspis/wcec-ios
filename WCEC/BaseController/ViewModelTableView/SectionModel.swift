//
//  SectionModel.swift
//  MyClip
//
//  Created by Huy Nguyen on 3/20/17.
//  Copyright © 2017 Huy Nguyen. All rights reserved.
//

import Foundation
struct SectionModel: PBaseSectionModel {
    typealias Header = PBaseHeaderModel
    var header: Header
    typealias Cell = PBaseRowModel
    var rows: [Cell]
    
    init(rows: [PBaseRowModel],
         header: HeaderModel) {
        self.rows = rows
        self.header = header
    }
    
    init(rows: [PBaseRowModel]) {
        self.rows = rows
        self.header = HeaderModel()
    }
    
    init(rows: [PBaseRowModel],
         header: PBaseHeaderModel) {
        self.rows = rows
        self.header = header
    }
}

