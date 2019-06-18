//
//  CountryDTO.swift
//  WCEC
//
//  Created by hnc on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class CountryDTO: NSObject {
    var id: Int
    var name: String
    var initial: String
    var phone: String
    
    init(_ json: JSON) {
        id             = json["id"].intValue
        name           = json["name"].stringValue
        initial        = json["initial"].stringValue
        phone          = json["phone"].stringValue
    }
}
