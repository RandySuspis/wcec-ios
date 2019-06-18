//
//  CommentModel.swift
//  WCEC
//
//  Created by GEM on 6/20/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommentModel: NSObject {
    var id: Int
    var content: String
    var created_at: String
    var updated_at: String
    var author: UserModel
    
    init(_ dto: CommentDTO) {
        id                           = dto.id
        content                      = dto.content
        created_at                   = dto.created_at
        updated_at                   = dto.updated_at
        author                       = UserModel(dto.author)
    }
}

