//
//  NewfeedDTO.swift
//  WCEC
//
//  Created by GEM on 6/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import SwiftyJSON

class NewfeedDTO: NSObject {
    var id: Int
    var title: String
    var content: String
    var published_at: String
    var url: String
    var author: UserDTO
    var post_type: String
    var images = [FileDTO]()
    var video: FileDTO
    var parent: NewfeedDTO?
    var interests = [SubCategoryDTO]()
    var industries = [SubCategoryDTO]()
    var visibility: Bool
    var liked: Bool
    var shared: Bool
    var userLikes = [UserDTO]()
    var shares = [UserDTO]()
    var comments = [CommentDTO]()
    
    init(_ json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        content = json["content"].stringValue
        url = json["url"].stringValue
        published_at = json["published_at"].stringValue
        author = UserDTO.init(json["author"])
        post_type = json["post_type"].stringValue
        liked = json["liked"].boolValue
        shared = json["shared"].boolValue
        visibility = json["visibility"].boolValue
        video = FileDTO.init(json["video"])
        if json["parent"].rawString() != "null" {
            parent = NewfeedDTO.init(json["parent"])
        }
        
        for (_,subJson):(String, JSON) in json["userLikes"] {
            self.userLikes.append(UserDTO(subJson))
        }
        
        for (_,subJson):(String, JSON) in json["shares"] {
            self.shares.append(UserDTO(subJson))
        }
        
        for (_,subJson):(String, JSON) in json["comments"] {
            self.comments.append(CommentDTO(subJson))
        }
        
        for (_,subJson):(String, JSON) in json["images"] {
            self.images.append(FileDTO(subJson))
        }
        
        for (_,subJson):(String, JSON) in json["industries"] {
            self.industries.append(SubCategoryDTO(subJson))
        }
        
        for (_,subJson):(String, JSON) in json["interests"] {
            self.interests.append(SubCategoryDTO(subJson))
        }
    }
}

