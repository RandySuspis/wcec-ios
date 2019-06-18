//
//  IntExtension.swift
//  WCEC
//
//  Created by Viet Pham Duc on 6/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    var randomString : String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: self)
        
        for _ in 0 ..< self{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        return randomString as String
    }
}
