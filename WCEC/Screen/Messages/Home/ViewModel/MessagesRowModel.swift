//
//  MessagesRowModel.swift
//  WCEC
//
//  Created by GEM on 6/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

class MessagesRowModel: PBaseRowModel {
    var title: String
    var desc: String
    var image: String
    var identifier: String
    var objectID: String
    var note: String
    var nameUser: String
    var time: String
    var isNew: Bool
    var channelModel: ChannelModel?
    
    init(_ data: ChannelModel) {
        self.channelModel = data
        self.objectID = String(data.id)
        self.title = data.name
        if data.images.isEmpty {
            self.desc = data.lastMessage
        } else {
            self.desc = "\(data.images.count) " +
                (data.images.count > 1 ? "photos".localized() : "photo".localized())
        }
        
        if !data.leftChannelDate.isEmpty {
            self.desc = "You left".localized()
        } else {
            for member in data.members {
                if member.id == DataManager.getCurrentUserModel()?.id {
                    if member.userChannelRoleType == .invitation {
                        self.desc = "Invited you to this group chat".localized()
                        break
                    }
                }
            }
        }
        
        var members: String = ""
        for index in 0..<data.members.count {
            let member = data.members[index]
            if member.id != DataManager.getCurrentUserModel()?.id {
                members.append(member.fullName + ", ")
            }
        }
        if members.count > 2 {
            members.removeLast()
            members.removeLast()
        }
        
        self.nameUser = members
        
        self.image = ""
        if data.members.count == 2 {
            for member in data.members {
                if member.id != DataManager.getCurrentUserModel()?.id {
                    self.image = member.avatar.thumb_file_url
                    break
                }
            }
        }
        
        self.time =  Date.convertUTCToLocal(date: data.updatedAt,
                                            fromFormat: "yyyy-MM-dd HH:mm:ss",
                                            toFormat: "yyyy-MM-dd HH:mm:ss")?.wcecTimeAgoSinceNow ?? ""
        self.isNew = data.new
        self.identifier = MessageTableViewCell.nibName()
        self.note = ""
    }
}
