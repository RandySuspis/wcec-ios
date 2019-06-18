//
//  NewPostViewModel.swift
//  WCEC
//
//  Created by hnc on 6/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class NewPostViewModel: NSObject {
    var model: NewfeedModel?
    var content: String = ""
    var listGallery: [Any]?
    var mediaType: PHAssetMediaType = .unknown
    var visibility: Bool = true //public
    var videoData: Data = Data()
    var selectedTags = [SubCategoryModel]()
    var currentMedia = [FileModel]()
    
    static var shareInstance: NewPostViewModel = {
        let instance = NewPostViewModel()
        return instance
    }()
    
    override init() {
        content = ""
        listGallery = []
        mediaType = .unknown
        visibility = true
    }
    
    func clearData() {
        content = ""
        listGallery?.removeAll()
        mediaType = .unknown
        visibility = true
        videoData = Data()
        currentMedia.removeAll()
        selectedTags.removeAll()
        model = nil
    }
    
    func bindingWithModel(_ model: NewfeedModel) {
        self.model = model
        content = model.content
        visibility = model.visibility
        switch model.post_type {
        case .video:
            mediaType = .video
            currentMedia.append(model.video)
            break
        case .text:
            mediaType = .image
            for image in model.images {
                currentMedia.append(image)
            }
            break
        case .link:
            break
        }
        for tag in model.industries {
            selectedTags.append(tag)
        }
        
        for tag in model.interests {
            selectedTags.append(tag)
        }
    }
}
