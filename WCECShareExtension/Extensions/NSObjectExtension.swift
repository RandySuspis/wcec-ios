//
//  NSObjectExtension.swift
//  WCEC
//
//  Created by hnc on 5/10/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

extension NSObject {
    class func classString() -> String! {
        let str = String(describing: self)
        return str
    }
}
