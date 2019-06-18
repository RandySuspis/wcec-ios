//
//  NewFeedRowModel.swift
//  WCEC
//
//  Created by GEM on 6/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

struct NewFeedRowModel: PBaseRowModel {
    var title: String
    var image: String
    var note: String
    var objectID: String
    var name: String
    var time: String
    var desc: String
    var avatar: String
    var listImage = [String]()
    var identifier: String
    var isDescCollapse: Bool
    var isTagCollapse: Bool = true
    var elite: Bool
    var isLiked: Bool
    var linkVideo: String
    var thumbNail: String
    var nameParentPost: String
    var likeCount: Int
    var commentCount: Int
    var shareCount: Int
    var data: NewfeedModel
    var tags: String = ""
    var isShowTags: Bool = false
    
    init(_ data: NewfeedModel, identifier: String) {
        self.objectID = String(data.id)
        self.name = data.author.fullName
        self.time = Date.convertUTCToLocal(date: data.published_at,
                                           fromFormat: "yyyy-MM-dd HH:mm:ss",
                                           toFormat: "yyyy-MM-dd HH:mm:ss")?.wcecTimeAgoSinceNow ?? ""
        self.desc = data.content
        self.avatar = data.author.avatar.thumb_file_url
        self.isDescCollapse = true
        self.elite = data.author.elite
        self.identifier = identifier
        self.linkVideo = data.video.file_url
        for item in data.images {
            self.listImage.append(item.file_url)
        }
        self.thumbNail = data.video.thumb_file_url
        if !data.images.isEmpty {
            self.thumbNail = data.images.first!.thumb_file_url
        }
        self.isLiked = data.liked
        self.title = ""
        self.image = ""
        self.note = ""
        self.likeCount = data.userLikes.count
        self.commentCount = data.comments.count
        self.shareCount = data.shares.count
        if let parent = data.parent {
            self.nameParentPost = parent.author.fullName
        } else {
            self.nameParentPost = ""
        }
        self.data = data
        data.interests.forEach({
            self.tags += "\($0.name), "
        })
        data.industries.forEach({
            self.tags += "\($0.name), "
        })
        if self.tags.count > 0 {
            self.tags.removeLast()
            self.tags.removeLast()
            self.tags = "Tags: ".localized() + self.tags
        }
    }
}
