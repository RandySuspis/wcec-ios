//
//  MessageModel.swift
//  WCEC
//
//  Created by hnc on 7/5/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class MessageModel: NSObject {
    var userId: String
    var avatarUrl: String
    var fullName: String
    var message: String
    var images = [String]()
    var createdDate: Date
    var removed: String
    var identifier: String
    
    init(_ dto: MessageDTO) {
        userId = dto.userId
        avatarUrl = dto.avatarUrl
        fullName = dto.fullName
        message = dto.message
        for imgString in dto.images {
            images.append(imgString)
        }
        createdDate = Date.dateFromMiliseconds(miliSecond: dto.createdDate)
        removed = dto.removed
        identifier = dto.identifier
    }
}
