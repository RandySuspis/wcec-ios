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
        let userDefault = UserDefaults.standard
        return userDefault.object(forKey: key)
    }
    
    class func stringForKey(_ key: String) -> String? {
        let userDefault = UserDefaults.standard
        return userDefault.string(forKey: key)
    }
    
    
    class func boolForKey(_ key: String) -> Bool {
        let userDefault = UserDefaults.standard
        return userDefault.bool(forKey: key)
    }
    
    class func integerForKey(_ key: String) -> Int {
        let userDefault = UserDefaults.standard
        return userDefault.integer(forKey: key)
    }
    
    class func removeObject(forKey key: String) {
        let userDefault = UserDefaults.standard
        userDefault.removeObject(forKey: key)
        userDefault.synchronize()
    }
    
    class func save(object: Any, forKey key: String) {
        let userDefault = UserDefaults.standard
        userDefault.set(object, forKey: key)
        userDefault.synchronize()
    }
    
    class func save(boolValue: Bool, forKey key: String) {
        let userDefault = UserDefaults.standard
        userDefault.set(boolValue, forKey: key)
        userDefault.synchronize()
    }
    
    class func save(integerValue: Int, forKey key: String) {
        let userDefault = UserDefaults.standard
        userDefault.setValue(integerValue, forKey: key)
        userDefault.synchronize()
    }
    
    class func save(floatValue: Float, forKey key: String) {
        let userDefault = UserDefaults.standard
        userDefault.setValue(floatValue, forKey: key)
        userDefault.synchronize()
    }
    
    class func floatForKey(_ key: String) -> Float {
        let userDefault = UserDefaults.standard
        return userDefault.float(forKey: key)
    }
    
    class func saveLanguage(_ languageKey: String) {
        let userDefault = UserDefaults.standard
        userDefault.setValue(languageKey, forKey: "AppleLanguages")
        userDefault.synchronize()
    }
    
    class func saveUserModel(_ model: UserModel) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: model)
        DataManager.save(object: encodedData, forKey: Constants.kUserModelKey)
    }
    
    class func saveUserToken(_ token: String) {
        DataManager.save(object: token, forKey: Constants.kUserTokenKey)
        let APP_BUNDLE_SUBFIX = Bundle.main.object(forInfoDictionaryKey: "APP_BUNDLE_SUBFIX") as! String
        let suitName = "group.com.gem.WCEC" + APP_BUNDLE_SUBFIX + ".ExtensionSharingData"
        let user = UserDefaults(suiteName: suitName)
        user?.set(token, forKey: Constants.kUserTokenKey)
    }

    class func getCurrentUserModel() -> UserModel? {
        if let data = DataManager.objectForKey(Constants.kUserModelKey) {
            let model = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? UserModel
            return model
        } else {
            return nil
        }
    }

    class func getUserToken() -> String {
        if let token = DataManager.objectForKey(Constants.kUserTokenKey) {
            return token as! String
        } else {
            return ""
        }
    }

    class func isLoggedIn() -> Bool {
        let userToken = getUserToken()
        if userToken.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    class func checkIsGuestUser() -> Bool {
        if DataManager.getCurrentUserModel()?.status == .guest || DataManager.getCurrentUserModel()?.status == .social {
            return true
        }
        return false
    }
    
    class func clearLoginSession() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        DataManager.removeObject(forKey: Constants.kUserModelKey)
        DataManager.removeObject(forKey: Constants.kUserTokenKey)
        let APP_BUNDLE_SUBFIX = Bundle.main.object(forInfoDictionaryKey: "APP_BUNDLE_SUBFIX") as! String
        let suitName = "group.com.gem.WCEC" + APP_BUNDLE_SUBFIX + ".ExtensionSharingData"
        let user = UserDefaults(suiteName: suitName)
        user?.removeObject(forKey: Constants.kUserTokenKey)
        DataManager.removeSavedImage()
        Constants.appDelegate.clearNotification()
    }
    
    class func deviceToken() -> String {
        let userDefault = UserDefaults.standard
        if let deviceToken = userDefault.value(forKey: Constants.kDeviceTokenKey) {
            return deviceToken as! String
        }
        
        return "56E32C5A309638491CB2EC81D8F775DD501C9B08911418D240032748353131A5"  //for testing on simulator
    }
    
    class func deviceTokenData() -> Data {
        let userDefault = UserDefaults.standard
        if let deviceToken = userDefault.value(forKey: Constants.kDeviceTokenData) {
            return deviceToken as! Data
        }
        
        return Data()  //for testing on simulator
    }
    
    class func saveSocialAvatarImage(image: UIImage) -> Bool {
        guard let data = UIImageJPEGRepresentation(image, 1) ?? UIImagePNGRepresentation(image) else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("\(Constants.kSocialAvatar).png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    class func removeSavedImage() {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return
        }
        do {
            try FileManager.default.removeItem(at: directory.appendingPathComponent("\(Constants.kSocialAvatar).png")!)
        } catch let error as NSError {
            print("Could not clear temp folder: \(error.debugDescription)")
        }
        
    }
    
    class func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
}
