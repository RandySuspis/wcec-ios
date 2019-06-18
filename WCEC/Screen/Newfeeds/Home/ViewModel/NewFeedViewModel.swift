//
//  NewFeedViewModel.swift
//  WCEC
//
//  Created by GEM on 6/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class NewFeedViewModel: NSObject {
    var rows = [NewFeedRowModel]()
    
    func parseNewfeed(_ data: [NewfeedModel]) {
        data.forEach({
            var identifier: String = ""
            switch $0.post_type {
            case .text:
                if $0.images.count == 0 {
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
            rows.append(NewFeedRowModel($0, identifier: identifier))
        })
    }
    
    func addNewPost(_ model: NewfeedModel) {
        var identifier: String = ""
        switch model.post_type {
        case .text:
            if model.images.count == 0 {
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
        rows.insert(NewFeedRowModel(model, identifier: identifier), at: 0)
    }
    
    func updateCollapse(index: Int) {
        rows[index].isDescCollapse = !rows[index].isDescCollapse
    }
    
    func updateLike(index: Int) {
        rows[index].isLiked = !rows[index].isLiked
        if !rows[index].isLiked && rows[index].likeCount > 0 {
            rows[index].likeCount -= 1
        } else {
            rows[index].likeCount += 1
        }
    }
    
    func updateShare(index: Int) {
        rows[index + 1].shareCount += 1
    }
}
