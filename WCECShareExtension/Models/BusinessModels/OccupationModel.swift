//
//  OccupationModel.swift
//  WCEC
//
//  Created by GEM on 5/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import SwiftyJSON

class OccupationModel: NSObject {
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
    
    init(_ dto: OccupationDTO) {
        id = dto.id
        job_title = dto.job_title
        user = dto.user
        hq_location = dto.hq_location
        current_location = dto.current_location
        company_name = dto.company_name
        is_current = dto.is_current
        begin_date = dto.begin_date
        end_date = dto.end_date
        desc = dto.desc
        created_at = dto.created_at
        updated_at = dto.updated_at
        deleted_at = dto.deleted_at
    }
}
