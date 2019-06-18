//
//  CountryModel.swift
//  WCEC
//
//  Created by hnc on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class CountryModel: NSObject, NSCoding {
    var id: Int
    var name: String
    var initial: String
    var phone: String
    
    init(_ dto: CountryDTO) {
        id        = dto.id
        name      = dto.name
        initial   = dto.initial
        phone     = dto.phone
    }
    
    required init(coder decoder: NSCoder) {
        id                  = decoder.decodeInteger(forKey: "id")
        name           = decoder.decodeObject(forKey: "name") as? String ?? ""
        initial          = decoder.decodeObject(forKey: "initial") as? String ?? ""
        phone            = decoder.decodeObject(forKey: "phone") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(initial, forKey: "initial")
        coder.encode(phone, forKey: "phone")
    }
}
