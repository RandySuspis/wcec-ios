//
//  TotalRequestModel.swift
//  WCEC
//
//  Created by GEM on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class TotalRequestModel: NSObject {
    var received: Int
    var sent: Int
    var connected: Int
    
    init(_ dto: TotalRequestDTO) {
        received             = dto.received
        sent                 = dto.sent
        connected            = dto.connected
    }
}

