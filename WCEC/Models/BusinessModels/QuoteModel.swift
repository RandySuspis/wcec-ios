//
//  QuoteModel.swift
//  WCEC
//
//  Created by GEM on 6/8/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import SwiftyJSON

class QuoteModel: NSObject {
    var id: Int
    var name: String
    var jobtitle: String
    var avatar: FileModel
    var quote: String
    var created_at: String
    var updated_at: String
    
    init(_ dto: QuoteDTO) {
        id = dto.id
        jobtitle = dto.jobtitle
        name = dto.name
        quote = dto.quote
        created_at = dto.created_at
        updated_at = dto.updated_at
        avatar = FileModel(dto.avatar)
    }
}
