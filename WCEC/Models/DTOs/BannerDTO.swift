
//
//  BannerDTO.swift
//  WCEC
//
//  Created by GEM on 8/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class BannerDTO: NSObject {
    
    var id: Int
    var url: String
    var created_at: String
    var updated_at: String
    var image: FileDTO
    
    init(_ json: JSON) {
        id = json["id"].intValue
        url = json["url"].stringValue
        created_at = json["created_at"].stringValue
        updated_at = json["updated_at"].stringValue
        image = FileDTO(json["image"])
    }
}
