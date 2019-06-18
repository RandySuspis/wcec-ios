//
//  UserModel.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserModel: NSObject, NSCoding {
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
    var token: String
    var activationCode: String
    var firstTimeLogin: Bool
    var profileCompleted: Int
    var country: CountryModel
    var avatar: FileModel
    var relation: String
    var requestId: Int = 0
    var createdAt: String
    var updatedAt: String
    var industries: String = ""
    var interests: String = ""
    var listInterestsModel: [SubCategoryModel]?
    var occupations = [OccupationModel]()
    var status: StatusUser?
    var qr_code_id: String
    var mutual_connections: Int
    var elite: Bool
    var connection_visited: Bool
    var new_feed_visited: Bool
    
    init(_ dto: UserDTO) {
        id                  = dto.id
        firstName           = dto.firstName
        familyName          = dto.familyName
        fullName            = dto.fullName
        if fullName == "" {
            fullName = firstName + " " + familyName
        }
        email               = dto.email
        phoneCode           = dto.phoneCode
        phoneNumber         = dto.phoneNumber
        gender              = dto.gender
        birthYear           = dto.birthYear
        shortBio            = dto.shortBio
        pushNotification    = dto.pushNotification
        token               = dto.token
        activationCode      = dto.activationCode
        firstTimeLogin      = dto.firstTimeLogin
        profileCompleted    = dto.profileCompleted
        country             = CountryModel(dto.country)
        avatar              = FileModel(dto.avatar)
        createdAt           = dto.createdAt
        updatedAt           = dto.updatedAt
        qr_code_id          = dto.qr_code_id
        mutual_connections  = dto.mutual_connections
        elite               = dto.elite
        connection_visited  = dto.connection_visited
        new_feed_visited    = dto.new_feed_visited
        status              = dto.status == "" ? .inactivate : StatusUser(rawValue: dto.status)
        var subCategoriesSelected: String = ""
        for subIndustryDTO in dto.industries {
            let industryModel = SubCategoryModel(subIndustryDTO)
            subCategoriesSelected.append("\(industryModel.id.description),")
            
        }
        if subCategoriesSelected.count >= 1 && subCategoriesSelected.last == ","{
            subCategoriesSelected.removeLast()
        }
        industries = subCategoriesSelected
        
        var interestsSelected: String = ""
        var listInterestsSelected = [SubCategoryModel]()
        for subInterestDTO in dto.interests {
            let interestsModel = SubCategoryModel(subInterestDTO)
            interestsSelected.append("\(interestsModel.id.description),")
            listInterestsSelected.append(interestsModel)
        }
        listInterestsModel = listInterestsSelected
        
        for occupationDTO in dto.occupations {
            let occupationModel = OccupationModel(occupationDTO)
            occupations.append(occupationModel)
        }
        if interestsSelected.count >= 1 && interestsSelected.last == ","{
            interestsSelected.removeLast()
        }
        
        interests = interestsSelected
        requestId = dto.requestId
        relation = dto.relation
    }
    
    required init(coder decoder: NSCoder) {
        id                  = decoder.decodeInteger(forKey: "id")
        firstName           = decoder.decodeObject(forKey: "firstName") as? String ?? ""
        familyName          = decoder.decodeObject(forKey: "familyName") as? String ?? ""
        fullName            = decoder.decodeObject(forKey: "fullName") as? String ?? ""
        email               = decoder.decodeObject(forKey: "email") as? String ?? ""
        phoneCode           = decoder.decodeObject(forKey: "phoneCode") as? String ?? ""
        phoneNumber         = decoder.decodeObject(forKey: "phoneNumber") as? String ?? ""
        gender              = decoder.decodeObject(forKey: "gender") as? String ?? ""
        birthYear           = decoder.decodeObject(forKey: "birthYear") as? String ?? ""
        shortBio            = decoder.decodeObject(forKey: "shortBio") as? String ?? ""
        pushNotification    = decoder.decodeInteger(forKey: "pushNotification")
        token               = decoder.decodeObject(forKey: "token") as? String ?? ""
        activationCode      = decoder.decodeObject(forKey: "activationCode") as? String ?? ""
        firstTimeLogin      = decoder.decodeBool(forKey: "firstTimeLogin")
        profileCompleted    = decoder.decodeInteger(forKey: "profileCompleted")
        country             = decoder.decodeObject(forKey: "country") as! CountryModel
        avatar              = decoder.decodeObject(forKey: "avatar") as! FileModel
        createdAt           = decoder.decodeObject(forKey: "createdAt") as? String ?? ""
        updatedAt           = decoder.decodeObject(forKey: "updatedAt") as? String ?? ""
        industries          = decoder.decodeObject(forKey: "industries") as? String ?? ""
        interests           = decoder.decodeObject(forKey: "interests") as? String ?? ""
        relation            = decoder.decodeObject(forKey: "relation") as? String ?? ""
        qr_code_id          = decoder.decodeObject(forKey: "qr_code_id") as? String ?? ""
        elite               = decoder.decodeBool(forKey: "elite")
        connection_visited  = decoder.decodeBool(forKey: "connection_visited")
        new_feed_visited    = decoder.decodeBool(forKey: "new_feed_visited")
        mutual_connections  = decoder.decodeInteger(forKey: "mutual_connections")
        status              = StatusUser(rawValue: decoder.decodeObject(forKey: "status") as? String ?? "")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(firstName, forKey: "firstName")
        coder.encode(familyName, forKey: "familyName")
        coder.encode(fullName, forKey: "fullName")
        coder.encode(email, forKey: "email")
        coder.encode(phoneCode, forKey: "phoneCode")
        coder.encode(phoneNumber, forKey: "phoneNumber")
        coder.encode(gender, forKey: "gender")
        coder.encode(birthYear, forKey: "birthYear")
        coder.encode(shortBio, forKey: "shortBio")
        coder.encode(pushNotification, forKey: "pushNotification")
        coder.encode(firstTimeLogin, forKey: "firstTimeLogin")
        coder.encode(profileCompleted, forKey: "profileCompleted")
        coder.encode(token, forKey: "token")
        coder.encode(activationCode, forKey: "activationCode")
        coder.encode(country, forKey: "country")
        coder.encode(avatar, forKey: "avatar")
        coder.encode(createdAt, forKey: "createdAt")
        coder.encode(updatedAt, forKey: "updatedAt")
        coder.encode(industries, forKey: "industries")
        coder.encode(interests, forKey: "interests")
        coder.encode(relation, forKey: "relation")
        coder.encode(status?.rawValue, forKey: "status")
        coder.encode(qr_code_id, forKey: "qr_code_id")
        coder.encode(mutual_connections, forKey: "mutual_connections")
        coder.encode(elite, forKey: "elite")
        coder.encode(connection_visited, forKey: "connection_visited")
        coder.encode(new_feed_visited, forKey: "new_feed_visited")
    }
}
