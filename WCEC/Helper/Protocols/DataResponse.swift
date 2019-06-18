//
//  DataResponse.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct APIResponse<T, A> {
    var errorCode: Int
    var message: String
    var data: T
    init(_ json: JSON, data: T) {
        errorCode = json["errorCode"].intValue
        message = json["message"].stringValue
        self.data = data
    }
}

public struct Pager {
    var page: Int
    var per_page: Int
}

