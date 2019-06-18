//
//  APIRequestProvider.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let kClientVersionHeaderField = "CLIENT-VERSION"
let kClientOSHeaderField = "DEVICE-TYPE"
let kClientDeviceTokenHeaderField = "DEVICE-TOKEN"
let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String

class APIRequestProvider: NSObject {
    // MARK: SINGLETON
    static var shareInstance: APIRequestProvider = {
        let instance = APIRequestProvider()
        return instance
    }()
    
    // MARK: DEFAULT HEADER & REQUEST URL
    private var _headers: HTTPHeaders = [:]
    var headers: HTTPHeaders {
        set {
            _headers = headers
        }
        get {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            let deviceOS = "ios"
            
            var headers: HTTPHeaders = [
                "Accept": "application/json",
                "Content-Type": "application/json",
                kClientVersionHeaderField: version,
                kClientOSHeaderField: deviceOS,
                kClientDeviceTokenHeaderField: DataManager.deviceToken(),
                "USER-TYPE": "agent"
            ]
            
            if !DataManager.getUserToken().isEmpty {
                headers.updateValue(DataManager.getUserToken(), forKey: "USER-TOKEN")
            }
            return headers
        }
    }
    
    private var _requestURL: String = baseURL
    var requestURL: String {
        set {
            _requestURL = requestURL
        }
        get {
            return _requestURL
        }
    }
    
    var alamoFireManager: SessionManager
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 5 // seconds for testing
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    //Mark: Authentication
    func loginRequest(email: String, password: String) -> DataRequest {
        let url = URL(string: requestURL.appending("user/login"))
        let param = ["email"   : email,
                     "password": password]
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func socialAthenticationRequest(email: String, id: String, type: String, firstName: String, lastName: String, avatarId: Int) -> DataRequest {
        let url = URL(string: requestURL.appending("user/social-login"))
        let param = ["email": email,
                     "id"   : id,
                     "type" : type,
                     "first_name": firstName,
                     "last_name": lastName]
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func logoutRequest() -> DataRequest {
        let url = URL(string: requestURL.appending("appuser/logout"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func signUpRequest(email: String) -> DataRequest {
        let urlString = requestURL.appending("user/register")
        let param = ["email": email]
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func resetPassword(activationCode: String, password: String) -> DataRequest {
        let params = ["code": activationCode,
                      "password": password,]
        let urlString = requestURL.appending("user/password-reset")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .put,
                                        parameters: params,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    
    func firstSetPassword(userId: Int, password: String) -> DataRequest {
        let params = ["password": password]
        let urlString = requestURL.appending("user/\(userId)/password")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .put,
                                        parameters: params,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func forgotPasswordRequest(email: String) -> DataRequest {
        let urlString = requestURL.appending("user/password-request")
        let param = ["email": email]
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func changePasswordRequest(params: [String: Any]) -> DataRequest {
        let urlString = requestURL.appending("appuser/change-password")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: params,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func sendOTP(params: [String: Any]) -> DataRequest {
        let urlString = requestURL.appending("user/send-otp")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: params,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func verifyOTP(params: [String: Any]) -> DataRequest {
        let urlString = requestURL.appending("user/verify-otp")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: params,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func upRootFirstTimeLoginRequest() -> DataRequest {
        let urlString = requestURL.appending("user/agreeTerms")
        let url = URL(string: urlString)
        return Alamofire.request(url!,
                                 method: .post,
                                 parameters: nil,
                                 encoding: JSONEncoding.default,
                                 headers: headers)
    }
    
    //MARK: user profile
    func searchCountryRequest(searchText: String) -> DataRequest {
        let url = URL(string: requestURL.appending("countries?filters[name]=\(searchText.escapedString())"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func searchJobTitles(searchText: String) -> DataRequest {
        let url = URL(string: requestURL.appending("job-titles?filters[name]=\(searchText.escapedString())"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func updateProfileRequest(param: [String: Any], userId: Int) -> DataRequest {
        let url = URL(string: requestURL.appending("user/\(userId)"))
        let request = Alamofire.request(url!,
                                        method: .put,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func getIndustriesRequest(searchText: String) -> DataRequest {
        let url = URL(string: requestURL.appending("industries?filters[name]=\(searchText.escapedString())"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func createIndustryRequest(name: String) -> DataRequest {
        let param = ["name": name]
        let url = URL(string: requestURL.appending("industries"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func getInterestsRequest(searchText: String) -> DataRequest {
        let url = URL(string: requestURL.appending("interests?filters[name]=\(searchText.escapedString())"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func createInterestRequest(name: String) -> DataRequest {
        let param = ["name": name]
        let url = URL(string: requestURL.appending("interests"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func getUserInfoRequest(userId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("user/\(userId)"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }

    func updateOccupation(param: [String: Any], userId: Int, occupationId: Int?) -> DataRequest {
        if let occupationId = occupationId {
            let url = URL(string: requestURL.appending("occupations/\(occupationId)"))
            let request = Alamofire.request(url!,
                                            method: .put,
                                            parameters: param,
                                            encoding: JSONEncoding.default,
                                            headers: headers)
            return request
        } else {
            let url = URL(string: requestURL.appending("user/\(DataManager.getCurrentUserModel()!.id)/occupations"))
            let request = Alamofire.request(url!,
                                            method: .post,
                                            parameters: param,
                                            encoding: JSONEncoding.default,
                                            headers: headers)
            return request
        }
    }
    
    func logOut() -> DataRequest {
        let url = URL(string: requestURL.appending("user/logout"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func listDeviceTokenRequest() -> DataRequest {
        let url = URL(string: requestURL.appending("user/devices"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    //MARK: Connections
    func listSuggestionsRequest(pager: Pager) -> DataRequest {
        let urlString = requestURL.appending("connections/suggestions?page=\(pager.page)&per_page=\(pager.per_page)")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    
    func listRequestsRequest(_ type: String, pager: Pager) -> DataRequest {
        let urlString = requestURL.appending("connections/requests?filters[type]=\(type)&page=\(pager.page)&per_page=\(pager.per_page)")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
        
    }
    
    func markSeenAllRequest() -> DataRequest {
        let urlString = requestURL.appending("connections/requests/all/seen")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .put,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func getTotalRequest() -> DataRequest {
        let urlString = requestURL.appending("connections/requests/total")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
        
    }
    
    func sendConnectionRequest(senderId: String, receiverId: String, message: String) -> DataRequest {
        let urlString = requestURL.appending("connections/requests")
        let url = URL(string: urlString)
        let params = ["sender_id": senderId,
                    "receiver_id": receiverId,
                        "message": message]
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: params,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }

    func sendConnectionQRCode(qrCode: String, currentUserId: String) -> DataRequest {
        let urlString = requestURL.appending("user/\(currentUserId)/connections")
        let url = URL(string: urlString)
        let params = ["qr_code_id": qrCode]
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: params,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func acceptRejectRequest(requestId: String, status: RequestStatus) -> DataRequest {
        let urlString = requestURL.appending("connections/requests/\(requestId)/status")
        let url = URL(string: urlString)
        let param = ["status": "\(status.rawValue)"]
        let request = Alamofire.request(url!,
                                        method: .put,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func cancelRequest(requestId: String) -> DataRequest {
        let urlString = requestURL.appending("connections/requests/\(requestId)")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .delete,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func searchMyConnected(_ text: String, pager: Pager) -> DataRequest {
        let urlString = requestURL.appending("connections/me?filters[keyword]=\(text.escapedString())&page=\(pager.page)&per_page=\(pager.per_page)")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func suggestKeywords(_ text: String) -> DataRequest {
        let urlString = requestURL.appending("search/keywords?filters[keyword]=\(text.escapedString())")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func searchMySuggestion(_ text: String, listIndustriesSelected: [SubCategoryModel], pager: Pager) -> DataRequest {
        var urlString = requestURL.appending("connections/suggestions?filters[keyword]=\(text.escapedString())&page=\(pager.page)&per_page=\(pager.per_page)")
        for item in listIndustriesSelected {
            urlString = urlString.appending("&filters[industries][]=\(item.id)")
        }
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func searchAllPeopleRequest(_ text: String,
                                listIndustriesSelected: [SubCategoryModel],
                                listInterestsSelected: [SubCategoryModel],
                                listLocationSelected: [rowModelLocation],
                                pager: Pager) -> DataRequest {
        var urlString = requestURL.appending("search/users?filters[keyword]=\(text.escapedString())&page=\(pager.page)&per_page=\(pager.per_page)")
        for item in listIndustriesSelected {
            urlString = urlString.appending("&filters[industries][]=\(item.id)")
        }
        for item in listInterestsSelected {
            urlString = urlString.appending("&filters[interests][]=\(item.id)")
        }
        for item in listLocationSelected {
            urlString = urlString.appending("&filters[country][]=\(item.data.id)")
        }
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func blockUser(blockUserId: String, currentUserId: String) -> DataRequest {
        let urlString = requestURL.appending("user/\(currentUserId)/blocks")
        let url = URL(string: urlString)
        let params = ["user_id": blockUserId]
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: params,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func defaultRequestMessageRequest() -> DataRequest {
        let urlString = requestURL.appending("settings/default-request-message")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func getMutualConnections(currentId: String, userId: String, pager: Pager) -> DataRequest {
        let urlString = requestURL.appending("user/\(currentId)/mutual-connections/\(userId)?page=\(pager.page)&per_page=\(pager.per_page)")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    //MARK: Quotes
    
    func quotes() -> DataRequest {
        let urlString = requestURL.appending("spokepersons/quotes")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    //MARK: New Post
    func getSuggestedTagsRequest() -> DataRequest {
        let urlString = requestURL.appending("content/suggested-tags")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func getTrendingTagsRequest() -> DataRequest {
        let urlString = requestURL.appending("content/trending-tags")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func searchTagsRequest(_ text: String) -> DataRequest {
        let urlString = requestURL.appending("content/tags?filters[name]=\(text.escapedString())")
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func createNewPostRequest(param: [String: Any]) -> DataRequest {
        let url = URL(string: requestURL.appending("content/posts"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func likePost(id: String) -> DataRequest {
        let url = URL(string: requestURL.appending("content/posts/\(id)/likes"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func editPostRequest(postId: String, param: [String: Any]) -> DataRequest {
        let url = URL(string: requestURL.appending("content/posts/\(postId)"))
        let request = Alamofire.request(url!,
                                        method: .put,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func deletePostRequest(postId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("content/posts/\(postId)"))
        let request = Alamofire.request(url!,
                                        method: .delete,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func sharePostRequest(postId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("content/posts/\(postId)/shares"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func sharePostVia(postId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("content/posts/\(postId)/shares-external"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    //MARK: Newfeed
    func listNewfeed(authorId: Int?,trending: [SubCategoryModel], searchText: String, pager: Pager) -> DataRequest {
        var urlString = ""
        if let authorId = authorId {
            urlString = requestURL.appending("content/news-feed?filters[author_id]=\(authorId)&page=\(pager.page)&per_page=\(pager.per_page)")
        } else {
            urlString = requestURL.appending("content/news-feed?page=\(pager.page)&per_page=\(pager.per_page)")
            trending.forEach({
                if $0.type == .industries {
                    urlString.append("&filters[industries][]=\($0.id)")
                } else if $0.type == .interests {
                    urlString.append("&filters[interests][]=\($0.id)")
                }
            })
            urlString.append("&filters[keyword]=\(searchText.escapedString())")
        }
        let url = URL(string: urlString)
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func newfeedDetail(_ id: String) -> DataRequest {
        let url = URL(string: requestURL.appending("content/posts/\(id)"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func deleteComment(_ id: String) -> DataRequest {
        let url = URL(string: requestURL.appending("content/comments/\(id)"))
        let request = Alamofire.request(url!,
                                        method: .delete,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func createComment(_ id: String, content: String) -> DataRequest {
        let url = URL(string: requestURL.appending("content/posts/\(id)/comments"))
        let param = ["content": content]
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func reportPost(_ postId: String, message: String) -> DataRequest {
        let url = URL(string: requestURL.appending("content/posts/\(postId)/report"))
        let param = ["message": message]
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    //MARK: Chat Message
    func createChatChannelRequest(param: [String: Any]) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func declineChatChannelRequest(channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)/decline"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func joinChatChannelRequest(channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)/join"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func leftChatChannelRequest(channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)/left"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func removeUserInChannelRequest(channelId: String, removeUserId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)/remove-user/\(removeUserId)"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func inviteUserToChannelRequest(param: [String: Any], channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)/invite"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func updateChannelRequest(param: [String: Any], channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)"))
        let request = Alamofire.request(url!,
                                        method: .put,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func getChannelDetail(channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func deleteChannelRequest(channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)"))
        let request = Alamofire.request(url!,
                                        method: .delete,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func getMessagesInChannelDetail(channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)/messages"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func sendMessageToChannelRequest(param: [String: Any], channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)/messages"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func editMessageInChannelRequest(messageId: String, channelId: String, param: [String: Any]) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)/messages/\(messageId)"))
        let request = Alamofire.request(url!,
                                        method: .put,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func deleteMessageInChannelRequest(messageId: String, channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)/messages/\(messageId)"))
        let request = Alamofire.request(url!,
                                        method: .delete,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func clearChatHistoryInChannelRequest(channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)/clear-chat"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func listChannelMessage(pager: Pager) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/all?page=\(pager.page)&per_page=\(pager.per_page)"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func listChannelIdRequest() -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/allChannelIds"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func grandAccessToChannel(channelId: String) -> DataRequest {
        let url = URL(string: requestURL.appending("chat/channels/\(channelId)/grant-access"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    //MARK: Me Container
    
    func listFaq(pager: Pager) -> DataRequest {
        let url = URL(string: requestURL.appending("faqs?page=\(pager.page)&per_page=\(pager.per_page)"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func changePassword(currentPassword: String, newPassword: String) -> DataRequest {
        let param = ["current_password": currentPassword,
                     "new_password": newPassword]
        let url = URL(string: requestURL.appending("user/change-password"))
        let request = Alamofire.request(url!,
                                        method: .put,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func listNotification(pager: Pager) -> DataRequest {
        let url = URL(string: requestURL.appending("notifications/all?page=\(pager.page)&per_page=\(pager.per_page)"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func seenNotification(_ id: String) -> DataRequest {
        let url = URL(string: requestURL.appending("notifications/\(id)/seen"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func totalNotificationNew() -> DataRequest {
        let url = URL(string: requestURL.appending("notifications/count"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    //MARK: WCEC
    
    func banner() -> DataRequest {
        let url = URL(string: requestURL.appending("banners"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    func wcecContent() -> DataRequest {
        let url = URL(string: requestURL.appending("content/home-articles"))
        let request = Alamofire.request(url!,
                                        method: .get,
                                        parameters: nil,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
    
    
    ///MARK: Guess
    func becomeAMemberRequest(param: [String: Any]) -> DataRequest {
        let url = URL(string: requestURL.appending("user/request-member"))
        let request = Alamofire.request(url!,
                                        method: .post,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        return request
    }
}

















