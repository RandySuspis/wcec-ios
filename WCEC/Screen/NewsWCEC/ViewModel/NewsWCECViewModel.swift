//
//  NewsWCECViewModel.swift
//  WCEC
//
//  Created by GEM on 8/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class NewsWCECViewModel: NSObject {
    var sections = [SectionModel]()
    var listBanner = [BannerModel]()
    
    func parseNewfeed(_ data: [NewfeedModel]) {
        sections.removeAll()
        let headerCarousel = HeaderModel(title: "carousel".localized())
        var rowsCarousel = [CarouselRowModel]()
        rowsCarousel.append(CarouselRowModel())
        let carouselSection = SectionModel(rows: rowsCarousel, header: headerCarousel)
        sections.append(carouselSection)
        
        let headerNewfeed = HeaderModel(title: "Featured Posts".localized(), identifier: HeaderSectionNewsWcec.nibName())
        var rowsNewfeed = [NewFeedRowModel]()
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
            rowsNewfeed.append(NewFeedRowModel($0, identifier: identifier))
        })
        let newfeedSection = SectionModel(rows: rowsNewfeed, header: headerNewfeed)
        sections.append(newfeedSection)
    }
    
    func updateCollapse(index: Int) {
        var row: NewFeedRowModel?
        if let rowModel = sections[1].rows[index] as? NewFeedRowModel {
            row = rowModel
        }
        if row != nil {
            row!.isDescCollapse = !row!.isDescCollapse
            sections[1].rows[index] = row!
        }
    }
    
    func updateLike(index: Int) {
        var row: NewFeedRowModel?
        if let rowModel = sections[1].rows[index] as? NewFeedRowModel {
            row = rowModel
        }
        if row != nil {
            row!.isLiked = !row!.isLiked
            if !row!.isLiked && row!.likeCount > 0 {
                row!.likeCount -= 1
            } else {
                row!.likeCount += 1
            }
            sections[1].rows[index] = row!
        }
    }
    
    func updateShare(index: Int) {
        var row: NewFeedRowModel?
        if let rowModel = sections[1].rows[index] as? NewFeedRowModel {
            row = rowModel
        }
        if row != nil {
            row!.shareCount += 1
            sections[1].rows[index] = row!
        }
    }
}

struct CarouselRowModel: PBaseRowModel {
    
    var title: String
    var desc: String
    var image: String
    var identifier: String
    var objectID: String
    var note: String
    
    init() {
        self.title = ""
        self.desc = ""
        self.image = ""
        self.identifier = CarouselTableViewCell.nibName()
        self.objectID = ""
        self.note = ""
    }
}
