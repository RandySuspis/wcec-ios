//
//  TotalRequestDTO.swift
//  WCEC
//
//  Created by GEM on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class TotalRequestDTO: NSObject {
    var received: Int
    var sent: Int
    var connected: Int
    
    init(_ json: JSON) {
        received             = json["received"].intValue
        sent                 = json["sent"].intValue
        connected            = json["connected"].intValue
    }
}
