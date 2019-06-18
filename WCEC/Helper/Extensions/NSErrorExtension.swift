//
//  NSErrorExtension.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
extension NSError {
    public static func errorWith(code errorCode: Int, message errorMessage: String) -> NSError {
        return NSError.init(domain: "WCEC",
                            code: errorCode,
                            userInfo: [NSLocalizedDescriptionKey : errorMessage])
    }
}
