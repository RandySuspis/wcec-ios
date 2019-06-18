//
//  DataManager.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit

class DataManager: NSObject {
    class func objectForKey(_ key: String) -> Any? {
        let APP_BUNDLE_SUBFIX = Bundle.main.object(forInfoDictionaryKey: "APP_BUNDLE_SUBFIX") as! String
        let suitName = "group.com.gem.WCEC" + APP_BUNDLE_SUBFIX + ".ExtensionSharingData"
        let userDefault = UserDefaults(suiteName: suitName)
        return userDefault?.object(forKey: key)
    }

    class func getUserToken() -> String {
        if let token = DataManager.objectForKey(Constants.kUserTokenKey) {
            return token as! String
        } else {
            return ""
        }
    }
    
    class func deviceToken() -> String {
        let userDefault = UserDefaults.standard
        if let deviceToken = userDefault.value(forKey: Constants.kDeviceTokenKey) {
            return deviceToken as! String
        }
        
        return "56E32C5A309638491CB2EC81D8F775DD501C9B08911418D240032748353131A5"  //for testing on simulator
    }
}
