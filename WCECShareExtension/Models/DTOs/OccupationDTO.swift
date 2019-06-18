//
//  OccupationDTO.swift
//  WCEC
//
//  Created by GEM on 5/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import SwiftyJSON

class OccupationDTO: NSObject {
    var id: Int
    var job_title: String
    var user: Int
    var hq_location: Int
    var current_location: Int
    var company_name: String
    var is_current: Bool
    var begin_date: String
    var end_date: String
    var desc: String
    var created_at: String
    var updated_at: String
    var deleted_at: String
    
    init(_ json: JSON) {
        id = json["id"].intValue
        job_title = json["job_title"].stringValue
        user = json["user"].intValue
        hq_location = json["hq_location"].intValue
        current_location = json["current_location"].intValue
        company_name = json["company_name"].stringValue
        is_current = json["is_current"].boolValue
        begin_date = json["begin_date"].stringValue
        end_date = json["end_date"].stringValue
        desc = json["description"].stringValue
        created_at = json["created_at"].stringValue
        updated_at = json["updated_at"].stringValue
        deleted_at = json["deleted_at"].stringValue
    }
}

