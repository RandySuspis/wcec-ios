//
//  FileModel.swift
//  WCEC
//
//  Created by hnc on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class FileModel: NSObject, NSCoding {
    var avatarId: Int
    var file_name: String
    var file_url: String
    var file_type: String
    var mimetype: String
    var filesize: String
    
    init(_ dto: FileDTO) {
        avatarId = dto.avatarId
        file_name = dto.file_name
        file_url = dto.file_url
        file_type = dto.file_type
        mimetype = dto.mimetype
        filesize = dto.filesize
    }
    
    required init(coder decoder: NSCoder) {
        avatarId  = decoder.decodeInteger(forKey: "avatarId")
        file_name = decoder.decodeObject(forKey: "file_name") as? String ?? ""
        file_url  = decoder.decodeObject(forKey: "file_url") as? String ?? ""
        file_type = decoder.decodeObject(forKey: "file_type") as? String ?? ""
        mimetype  = decoder.decodeObject(forKey: "mimetype") as? String ?? ""
        filesize  = decoder.decodeObject(forKey: "filesize") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(avatarId, forKey: "avatarId")
        coder.encode(file_name, forKey: "file_name")
        coder.encode(file_url, forKey: "file_url")
        coder.encode(file_type, forKey: "file_type")
        coder.encode(mimetype, forKey: "mimetype")
        coder.encode(filesize, forKey: "filesize")
    }
}
