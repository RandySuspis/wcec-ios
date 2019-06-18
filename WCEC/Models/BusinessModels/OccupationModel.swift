//
//  OccupationModel.swift
//  WCEC
//
//  Created by GEM on 5/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import SwiftyJSON

class OccupationModel: NSObject, NSCoding {
    var id: Int
    var job_title: String
    var user: Int
    var hq_location: CountryModel
    var current_location: CountryModel
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
        hq_location = CountryModel(dto.hq_location)
        current_location = CountryModel(dto.current_location)
        company_name = dto.company_name
        is_current = dto.is_current
        begin_date = dto.begin_date
        end_date = dto.end_date
        desc = dto.desc
        created_at = dto.created_at
        updated_at = dto.updated_at
        deleted_at = dto.deleted_at
    }
    
    required init(coder decoder: NSCoder) {
        id                  = decoder.decodeInteger(forKey: "id")
        job_title           = decoder.decodeObject(forKey: "job_title") as? String ?? ""
        user          = decoder.decodeInteger(forKey: "user")
        hq_location            = decoder.decodeObject(forKey: "hq_location") as! CountryModel
        current_location            = decoder.decodeObject(forKey: "current_location") as! CountryModel
        company_name               = decoder.decodeObject(forKey: "company_name") as? String ?? ""
        is_current = decoder.decodeBool(forKey: "is_current")
        desc = decoder.decodeObject(forKey: "desc") as? String ?? ""
        begin_date           = decoder.decodeObject(forKey: "begin_date") as? String ?? ""
        end_date         = decoder.decodeObject(forKey: "end_date") as? String ?? ""
        created_at              = decoder.decodeObject(forKey: "created_at") as? String ?? ""
        updated_at              = decoder.decodeObject(forKey: "updated_at") as? String ?? ""
        deleted_at           = decoder.decodeObject(forKey: "deleted_at") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(job_title, forKey: "job_title")
        coder.encode(user, forKey: "user")
        coder.encode(hq_location, forKey: "hq_location")
        coder.encode(current_location, forKey: "current_location")
        coder.encode(company_name, forKey: "company_name")
        coder.encode(is_current, forKey: "is_current")
        coder.encode(desc, forKey: "desc")
        coder.encode(begin_date, forKey: "begin_date")
        coder.encode(end_date, forKey: "end_date")
        coder.encode(created_at, forKey: "created_at")
        coder.encode(updated_at, forKey: "updated_at")
        coder.encode(deleted_at, forKey: "deleted_at")
    }
}
