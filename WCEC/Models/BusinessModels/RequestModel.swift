//
//  RequestModel.swift
//  WCEC
//
//  Created by GEM on 5/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class RequestModel: NSObject {
    var id: Int
    var message: String
    var created_at: String
    var updated_at: String
    var user: UserModel
    
    init(_ dto: RequestDTO) {
        id                           = dto.id
        message                      = dto.message
        created_at                   = dto.created_at
        updated_at                   = dto.updated_at
        user                         = UserModel(dto.user)
    }
}
