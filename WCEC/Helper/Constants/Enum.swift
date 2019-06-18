//
//  Enum.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

enum RestAPIStatusCode: Int {
    case invalidToken = 401
}

enum AccountType {
    case email
    case facebook
    case weibo
    case qq
    case twitter
    case line
    case unknow
    
    func typeString() -> String {
        switch self {
        case .email:
            return "email"
        case .facebook:
            return "facebook"
        case .weibo:
            return "weibo"
        case .qq:
            return "qq"
        case .twitter:
            return "twitter"
        case .line:
            return "line"
        case .unknow:
            return "Unknow"
        default:
            return ""
        }
    }
}


enum RelationType: String {
    case friend = "friend"
    case notFriend = "not_friend"
    case requestReceived = "request_received"
    case requestPending = "request_pending"
    case blocked = "blocked"
}

enum RequestStatus: Int {
    case accept = 1
    case reject = 2
}

enum TypeDateView: String {
    case from = "From"
    case to = "To"
}

public enum TypeSubCategory: String {
    case industries = "industry"
    case interests = "interest"
}

enum StatusUser: String {
    case inactivate = "inactivate"
    case otp_verified = "otp_verified"
    case activate = "activate"
    case social = "social"
    case guest = "guest"
}

enum PostType: String {
    case text = "text"
    case video = "video"
    case link = "link"
}

enum ConnectionsCellType  {
    case normal
    case checkbox
    case delete
    case label
}

enum TabProfile: String {
    case basicInfo = "basicInfo"
    case posts = "posts"
}

enum UserChannelRole: String {
    case member = "member"
    case admin = "admin"
    case invitation = "invitation"
}

enum NotificationType: String {
    case post = "post"
    case connection = "connection"
    case message = "message"
    case newMessage = "newmessage"
}

enum LanguageType: String {
    case english = "en"
    case chinese = "zh"
}

enum RegistrationType {
    case setupIntro
    case beAMember
}

enum VerifiedStatus: String {
    case unverify = "unverify"
    case otpVerified = "otp_verified"
    case setPasswordCompleted = "pw_updated"
    case profileCompleted = "profile_completed"
}

enum TabbarIndex: Int {
    case connectionNav
    case newsfeedNav
    case newsWCECNav
    case messageNav
    case meNav
}
