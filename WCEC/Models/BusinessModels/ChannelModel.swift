//
//  ChannelModel.swift
//  WCEC
//
//  Created by hnc on 6/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ChannelModel: NSObject {
    var id: Int
    var name: String
    var createdAt: String
    var updatedAt: String
    var lastMessage: String
    var members = [UserModel]()
    var leftChannelDate : String
    var lastTimeClearHistory: String
    var new: Bool
    var images = [String]()
    
    init(_ dto: ChannelDTO) {
        id = dto.id
        name = dto.name
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
        new = dto.new
        for memberDTO in dto.members {
            let member = UserModel(memberDTO)
            members.append(member)
        }
        for item in dto.images {
            images.append(item)
        }
        lastMessage = dto.lastMessage
        leftChannelDate = dto.leftChannelDate
        lastTimeClearHistory = dto.lastTimeClearHistory
    }
}
