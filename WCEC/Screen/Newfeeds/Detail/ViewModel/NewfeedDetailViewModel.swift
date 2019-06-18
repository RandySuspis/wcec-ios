//
//  NewfeedDetailViewModel.swift
//  WCEC
//
//  Created by GEM on 6/20/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class NewfeedDetailViewModel: NSObject {
    var sections = [SectionModel]()
    
    func parseData(_ data: NewfeedModel) {
        sections.removeAll()
        var rowDetail = [PBaseRowModel]()
        var identifier: String = ""
        switch data.post_type {
        case .text:
            if data.images.count == 0 {
                identifier = NewFeedNoAssetTableViewCell.nibName()
            } else {
                identifier = NewFeedPhotoTableViewCell.nibName()
            }
            break
        case .video:
            identifier = NewFeedVideoTableViewCell.nibName()
            break
        case .link:
            identifier = NewFeedEmbedLinkTableViewCell.nibName()
            break
        }
        var newfeedRowModel = NewFeedRowModel(data, identifier: identifier)
        newfeedRowModel.isDescCollapse = false
        newfeedRowModel.isShowTags = true
        rowDetail.append(newfeedRowModel)
        let detailSection = SectionModel(rows: rowDetail)
        sections.append(detailSection)
        
        var rowsComment = [PBaseRowModel]()
        data.comments.forEach({
            rowsComment.append(NewfeedCommentRowModel($0))
        })
        let commentsSection = SectionModel(rows: rowsComment)
        if !DataManager.checkIsGuestUser() {
            sections.append(commentsSection)
        }
    }
    
    func updateLike() {
        var newRowModel: NewFeedRowModel?
        if let rowModel = sections[0].rows[0] as? NewFeedRowModel {
            newRowModel = rowModel
            newRowModel!.isLiked = !newRowModel!.isLiked
            if !newRowModel!.isLiked && newRowModel!.likeCount > 0 {
                newRowModel!.likeCount -= 1
            } else {
                newRowModel!.likeCount += 1
            }
        }
        if let newRowModel = newRowModel {
            sections[0].rows[0] = newRowModel
        }
    }
    
    func updateShare() {
        var newRowModel: NewFeedRowModel?
        if let rowModel = sections[0].rows[0] as? NewFeedRowModel {
            newRowModel = rowModel
            newRowModel?.shareCount += 1
        }
        if let newRowModel = newRowModel {
            sections[0].rows[0] = newRowModel
        }
    }
    
    func deleteComment(_ index: Int) {
        sections[1].rows.remove(at: index)
        updateCommentCount(false)
    }
    
    func addComment(_ data: CommentModel) {
        sections[1].rows.append(NewfeedCommentRowModel(data))
        updateCommentCount(true)
    }
    
    func updateCommentCount(_ plus: Bool) {
        var newRowModel: NewFeedRowModel?
        if let rowModel = sections[0].rows[0] as? NewFeedRowModel {
            newRowModel = rowModel
            if plus {
                newRowModel!.commentCount += 1
            } else {
                newRowModel!.commentCount -= 1
            }
        }
        if let newRowModel = newRowModel {
            sections[0].rows[0] = newRowModel
        }
    }
    
    func updateCollapse() {
        var profileRow: NewFeedRowModel?
        if let rowModel = sections[0].rows[0] as? NewFeedRowModel {
            profileRow = rowModel
            profileRow!.isTagCollapse = !profileRow!.isTagCollapse
        }
        if let profileRow = profileRow {
            sections[0].rows[0] = profileRow
        }
    }
    
}







