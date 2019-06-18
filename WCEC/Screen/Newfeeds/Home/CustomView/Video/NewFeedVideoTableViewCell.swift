//
//  NewFeedVideoTableViewCell.swift
//  WCEC
//
//  Created by GEM on 6/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SDWebImage

class NewFeedVideoTableViewCell: BaseNewFeedTableViewCell {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var link: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.thumbnailImageView.image = nil
    }
    
    override func bindingWithModel(_ model: NewFeedRowModel) {
        super.bindingWithModel(model)
        link = model.linkVideo
        thumbnailImageView.kf.setImage(with: URL(string: model.thumbNail),
                                   placeholder: nil,
                                   options: nil,
                                   progressBlock: nil,
                                   completionHandler: nil)
        
        // - use thumbnail from sever
        
//        let key = SDWebImageManager.shared().cacheKey(for: URL.init(string: self.link))
//        if SDImageCache.shared().imageFromCache(forKey: key) != nil {
//        self.thumbnailImageView.image = SDImageCache.shared().imageFromCache(forKey: key)
//        } else {
//            let image = getThumbnailFrom(path: URL.init(string: model.linkVideo)!)
//            SDWebImageManager.shared().saveImage(toCache: image, for: URL.init(string: self.link))
//            self.thumbnailImageView.image = image
//        }
    }
    
    @IBAction func onPlayVideo(_ sender: Any) {
        delegate?.baseNewFeedTableViewCellShouldPlayVideo?(self, link: self.link)
    }
}
