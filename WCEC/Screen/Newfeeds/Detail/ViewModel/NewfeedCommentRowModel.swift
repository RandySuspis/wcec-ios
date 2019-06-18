//
//  NewfeedCommentRowModel.swift
//  WCEC
//
//  Created by GEM on 6/20/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class NewfeedCommentRowModel: PBaseRowModel {
    
    var title: String
    var desc: String
    var image: String
    var identifier: String
    var objectID: String
    var note: String
    var authorId: String
    var elite: Bool
    
    init(_ data: CommentModel) {
        objectID = String(data.id)
        authorId = String(data.author.id)
        title = data.author.fullName
        image = data.author.avatar.thumb_file_url
        desc = data.content
        elite = data.author.elite
        note = Date.convertUTCToLocal(date: data.updated_at,
                                      fromFormat: "yyyy-MM-dd HH:mm:ss",
                                      toFormat: "yyyy-MM-dd HH:mm:ss")?.wcecTimeAgoSinceNow ?? ""
        identifier = NewfeedCommentTableViewCell.nibName()
    }
}
