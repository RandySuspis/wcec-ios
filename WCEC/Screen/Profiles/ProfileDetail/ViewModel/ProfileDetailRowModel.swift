//
//  ProfileDetailRowModel.swift
//  WCEC
//
//  Created by hnc on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ProfileDetailRowModel: PBaseRowModel {
    var objectID: String
    var title: String
    var desc: String
    var image: String
    var identifier: String
    var location: String
    var note: String
    var type: RelationType = .notFriend
    var userModel: UserModel?
    
    init(_ data: UserModel, identifier: String) {
        if identifier == ProfileTableViewCell.nibName() {
            self.userModel = data
        }
        self.objectID = String(data.id)
        self.title = data.fullName
        if data.occupations.isEmpty {
            self.desc = ""
            self.location = ""
        } else if let data = data.occupations.first {
            self.desc = data.job_title + " at ".localized() + data.company_name
            self.location = data.current_location.name
        } else {
            self.desc = ""
            self.location = ""
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
        self.type = RelationType(rawValue: data.relation) ?? .notFriend
        self.identifier = identifier
    }
    
    init(_ data: Any, identifier: String) {
        self.objectID = ""
        self.title = "Johnathan Lim"
        self.desc = "Managing Director at International AnimaCall Coorporation"
        self.image = ""
        self.location = ""
        self.note = ""
        self.identifier = identifier
    }
}
