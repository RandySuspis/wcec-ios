//
//  NewfeedModel.swift
//  WCEC
//
//  Created by GEM on 6/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewfeedModel: NSObject {
    var id: Int
    var title: String
    var content: String
    var published_at: String
    var post_type: PostType
    var author: UserModel
    var images = [FileModel]()
    var video: FileModel
    var parent: NewfeedModel?
    var interests = [SubCategoryModel]()
    var industries = [SubCategoryModel]()
    var visibility: Bool
    var liked: Bool
    var shared: Bool
    var userLikes = [UserModel]()
    var shares = [UserModel]()
    var comments = [UserModel]()
    
    init(_ dto: NewfeedDTO) {
        id = dto.id
        title = dto.title
        content = dto.content
        published_at = dto.published_at
        author = UserModel(dto.author)
        post_type = PostType(rawValue: dto.post_type) ?? .text
        video = FileModel(dto.video)
        liked = dto.liked
        shared = dto.shared
        
        for item in dto.userLikes {
            self.userLikes.append(UserModel(item))
        }
        
        for item in dto.shares {
            self.shares.append(UserModel(item))
        }
        
        for item in dto.comments {
            self.comments.append(UserModel(item))
        }
        
        if let parent = dto.parent {
            self.parent = NewfeedModel(parent)
        }
        for item in dto.images {
            self.images.append(FileModel(item))
        }
        
        for tag in dto.industries {
            self.industries.append(SubCategoryModel(tag))
        }
        
        for tag in dto.interests {
            self.interests.append(SubCategoryModel(tag))
        }
        
        visibility = dto.visibility
    }
}
