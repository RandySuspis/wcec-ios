//
//  BannerModel.swift
//  WCEC
//
//  Created by GEM on 8/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class BannerModel: NSObject {

    var id: Int
    var url: String
    var created_at: String
    var updated_at: String
    var image: FileModel
    
    init(_ dto: BannerDTO) {
        id = dto.id
        url = dto.url
        created_at = dto.created_at
        updated_at = dto.updated_at
        image = FileModel(dto.image)
    }
}
