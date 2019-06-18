//
//  Constants.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

let defaultLimit = 10
let defaultOffset = 1
let defaultChatLimit = 50

struct Constants {
    static let appDelegate         = UIApplication.shared.delegate as! AppDelegate
    static let screenWidth         = UIScreen.main.bounds.size.width
    static let screenHeight        = UIScreen.main.bounds.size.height
    static let isIphone5           = UIScreen.main.bounds.size.height < 667
    static let isIphone            = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    static let isIpad              = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    static let iPhone              = "iPhone"
    static let iPad                = "iPad"
    static let loggedIn            = "logged_in"
    static let loggedOut           = "logged_out"
    
    static let kToastDuration: Float  = 3.0
    
    static let kDeviceTokenKey = "AppDeviceTokenKey"
    static let kDeviceTokenData = "AppDeviceTokenData"
    static let kUserTokenKey = "AppUserTokenKey"
    static let kUserModelKey = "AppUserModelKey"
    
    static let kDefaultLimit          = 15
    static let kFirstOffset           = 0
    
    static let kSocialAvatar = "socialAvatar"
    
    static let kConnectionUserManual = "ConnectionUserManual"
    
    static let kGoToSignUp = "goToSignUp"
    
    static let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
    static let currentMonthInt = (calendar?.component(NSCalendar.Unit.month, from: Date()))!
    static let currentYearInt = (calendar?.component(NSCalendar.Unit.year, from: Date()))!
}
