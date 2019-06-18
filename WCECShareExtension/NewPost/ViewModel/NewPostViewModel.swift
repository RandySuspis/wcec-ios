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
    var content: String = ""
    var listGallery: [Any]?
    var mediaType: PHAssetMediaType = .unknown
    var visibility: Bool = true //public
    var videoData: Data = Data()
    var selectedTags = [SubCategoryModel]()
    
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
        selectedTags.removeAll()
    }
}
