//
//  UserDTO.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserDTO: NSObject {
    var id: Int
    var firstName: String
    var familyName: String
    var fullName: String
    var email: String
    var phoneCode: String
    var phoneNumber: String
    var gender: String
    var birthYear: String
    var shortBio: String
    var pushNotification: Int
    var token:String
    var activationCode: String
    var firstTimeLogin: Bool
    var profileCompleted: Int
    var country: CountryDTO
    var avatar: FileDTO
    var industries = [SubCategoryDTO]()
    var interests = [SubCategoryDTO]()
    var relation: String
    var requestId: Int
    var createdAt: String
    var updatedAt: String
    var occupations = [OccupationDTO]()
    var status: String
    var qr_code_id: String
    var mutual_connections: Int
    var elite: Bool
    var connection_visited: Bool
    var new_feed_visited: Bool
    
    init(_ json: JSON) {
        id                  = json["id"].intValue
        firstName           = json["first_name"].stringValue
        familyName          = json["last_name"].stringValue
        fullName            = json["full_name"].stringValue
        email               = json["email"].stringValue
        phoneCode           = json["phone_code"].stringValue
        phoneNumber         = json["phone_number"].stringValue
        gender              = json["gender"].stringValue
        birthYear           = json["birthyear"].stringValue
        shortBio            = json["short_bio"].stringValue
        pushNotification    = json["push_notification"].intValue
        token               = json["persistences"].stringValue
        activationCode      = json["activation_code"].stringValue
        firstTimeLogin      = json["first_time_login"].boolValue
        profileCompleted    = json["profile_completed"].intValue
        country             = CountryDTO.init(json["country"])
        avatar              = FileDTO.init(json["avatar"])
        createdAt           = json["created_at"].stringValue
        updatedAt           = json["updated_at"].stringValue
        relation            = json ["relation"].stringValue
        requestId           = json["request_id"].intValue
        status              = json["status"].stringValue
        qr_code_id          = json["qr_code_id"].stringValue
        mutual_connections  = json["mutual_connections"].intValue
        elite               = json["elite"].boolValue
        connection_visited  = json["connection_visited"].boolValue
        new_feed_visited    = json["new_feed_visited"].boolValue
        for (_,subJson):(String, JSON) in json["industries"] {
            let subCategoryDTO = SubCategoryDTO(subJson)
            self.industries.append(subCategoryDTO)
        }
        for (_,subJson):(String, JSON) in json["interests"] {
            let subCategoryDTO = SubCategoryDTO(subJson)
            self.interests.append(subCategoryDTO)
        }
        for (_,subJson):(String, JSON) in json["occupations"] {
            let occupationDTO = OccupationDTO(subJson)
            self.occupations.append(occupationDTO)
        }
    }
}
