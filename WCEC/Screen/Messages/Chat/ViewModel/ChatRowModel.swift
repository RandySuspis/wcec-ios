//
//  ChatRowModel.swift
//  WCEC
//
//  Created by hnc on 7/9/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ChatRowModel: PBaseRowModel {
    var title: String
    
    var desc: String
    
    var image: String
    
    var note: String
    
    var objectID: String
    var fullName: String
    var avatarUrl: String
    var identifier: String
    var message: String
    var images = [String]()
    var createdDate: Date
    var messageModel: MessageModel
    
    init(_ data: MessageModel, identifier: String) {
        self.objectID = data.userId
        self.fullName = data.fullName
        self.avatarUrl = data.avatarUrl
        self.message = data.message
        self.images = data.images
        self.identifier = identifier
        self.title = ""
        self.desc = ""
        self.image = ""
        self.note = ""
        self.createdDate = data.createdDate
        self.messageModel = data
    }
}
