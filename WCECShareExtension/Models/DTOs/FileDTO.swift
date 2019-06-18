//
//  FileDTO.swift
//  WCEC
//
//  Created by hnc on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class FileDTO: NSObject {
    var avatarId: Int
    var file_name: String
    var file_url: String
    var file_type: String
    var mimetype: String
    var filesize: String
    
    init(_ json: JSON) {
        avatarId = json["id"].intValue
        file_name = json["file_name"].stringValue
        file_url = json["file_url"].stringValue
        file_type = json["extension"].stringValue
        mimetype = json["mimetype"].stringValue
        filesize = json["filesize"].stringValue
    }
    
    init(_ info: [AnyHashable: Any]) {
        if let custom = info[AnyHashable("picture")] as? NSDictionary {
            let jsonData = try! JSONSerialization.data(withJSONObject: custom["data"], options: .prettyPrinted)
            let json = try! JSON(data: jsonData)
            avatarId = 0
            file_name = ""
            filesize = ""
            mimetype = ""
            file_type = ""
            file_url = json["url"].stringValue
        } else {
            avatarId = 0
            file_name = ""
            filesize = ""
            mimetype = ""
            file_type = ""
            file_url = ""
        }
    }
}
