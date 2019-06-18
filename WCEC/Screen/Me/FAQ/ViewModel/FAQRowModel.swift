//
//  FAQRowModel.swift
//  WCEC
//
//  Created by GEM on 6/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

class FAQRowModel: PBaseRowModel {
    
    var title: String
    var desc: String
    var image: String
    var identifier: String
    var objectID: String
    var note: String
    
    init(_ data: FAQModel) {
        self.title = ""
        self.desc = data.answer
        self.image = ""
        self.identifier = FAQTableViewCell.nibName()
        self.objectID = ""
        self.note = ""
    }
    
}
