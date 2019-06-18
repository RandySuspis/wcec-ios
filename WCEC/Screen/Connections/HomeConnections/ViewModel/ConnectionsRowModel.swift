//
//  ConnectionsRowModel.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

struct ConnectionsRowModel: PBaseRowModel {
    var objectID: String
    var title: String
    var desc: String
    var image: String
    var identifier: String
    var note: String
    var message: String
    var type: RelationType = .notFriend
    var elite: Bool
    var isSelected: Bool = false
    var cellType: ConnectionsCellType
    var userChannelRoleType: UserChannelRole = .member
    
    init(_ data: RequestModel, type: ConnectionsCellType, identifier: String = ConnectionsTableViewCell.nibName()) {
        self.objectID = String(data.user.id)
        self.title = data.user.fullName
        if data.user.occupations.isEmpty {
            self.desc = ""
        } else if let data = data.user.occupations.first {
            self.desc = data.job_title + " at ".localized() + data.company_name
        } else {
            self.desc = ""
        }
        self.image = data.user.avatar.thumb_file_url
        if data.user.mutual_connections == 0 {
            self.note = ""
        } else {
            self.note = String(data.user.mutual_connections) +
                (data.user.mutual_connections == 1 ?
                    " mutual connection".localized() :
                    " mutual connections".localized())
        }
        self.identifier = identifier
        self.message = data.message
        self.type = RelationType(rawValue: data.user.relation) ?? .notFriend
        self.elite = data.user.elite
        self.cellType = type
    }
    
    init(_ data: UserModel, type: ConnectionsCellType, identifier: String = ConnectionsTableViewCell.nibName()) {
        self.objectID = String(data.id)
        self.title = data.fullName
        if data.occupations.isEmpty {
            self.desc = ""
        } else if let data = data.occupations.first {
            self.desc = data.job_title + " at ".localized() + data.company_name
        } else {
            self.desc = ""
        }
        self.image = data.avatar.thumb_file_url
        if data.mutual_connections == 0 {
            self.note = ""
        } else {
            self.note = String(data.mutual_connections) +
                (data.mutual_connections == 1 ?
                    " mutual connection".localized() :
                    " mutual connections".localized())
        }
        self.identifier = identifier
        self.message = ""
        self.type = RelationType(rawValue: data.relation) ?? .notFriend
        self.elite = data.elite
        self.cellType = type
        self.userChannelRoleType = data.userChannelRoleType ?? .member
    }
    
    init(_ text: String, identifier: String = SearchKeyWordTableViewCell.nibName()) {
        self.objectID = ""
        self.title = text
        self.desc = ""
        self.image = ""
        self.note = ""
        self.message = ""
        self.elite = false
        self.identifier = identifier
         self.cellType = .normal
    }
}






