//
//  AppMacro.swift
//  WCEC
//
//  Created by hnc on 5/4/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit
import Photos

func randySplitAndLocalized(rawString: String, split: String?) -> String{
    let splitUse:String = (split != nil) ? split! : " at "
    let rawStringArray = rawString.components(separatedBy: splitUse);
    var resultString:String = "";
    for theString in rawStringArray {
        if (resultString == ""){
            resultString = theString.localized();
        }else{
            let at = "at".localized();
            resultString = resultString + " " + at + " " + theString.localized();
        }
    }
    return resultString
}
