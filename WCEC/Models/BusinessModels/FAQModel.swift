//
//  FAQModel.swift
//  WCEC
//
//  Created by GEM on 7/4/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class FAQModel: NSObject {
    var id: Int
    var title: String
    var answer: String
    var createdAt: String
    var updatedAt: String
    
    init(_ dto: FAQDTO) {
        id = dto.id
        title = dto.title
        answer = dto.answer
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
    }
}
