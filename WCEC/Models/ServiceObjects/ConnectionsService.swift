//
//  ConnectionsService.swift
//  WCEC
//
//  Created by GEM on 5/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ConnectionsService: APIServiceObject {
    func getListSuggestions(pager: Pager, complete: @escaping(Result<APIResponse<[UserModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.listSuggestionsRequest(pager: pager)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [UserModel] = []
                    for item in array {
                        let dto = UserDTO(item)
                        let model = UserModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func getListRequests(param: String, pager: Pager, complete: @escaping(Result<APIResponse<[RequestModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.listRequestsRequest(param, pager: pager)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [RequestModel] = []
                    for item in array {
                        let dto = RequestDTO(item)
                        let model = RequestModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func markSeenAll(complete: @escaping(Result<APIResponse<[RequestModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.markSeenAllRequest()
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [RequestModel] = []
                    for item in array {
                        let dto = RequestDTO(item)
                        let model = RequestModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func getNumberTotalRequest(complete: @escaping(Result<APIResponse<TotalRequestModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.getTotalRequest()
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let dto = TotalRequestDTO(json)
                    let totalModel = TotalRequestModel(dto)
                    complete(Result.success(APIResponse(json, data: totalModel)))
                }
            }
        }
    }
    
    func sendConnection(senderID: Int, receiverID: String, message: String, complete: @escaping(Result<APIResponse<RequestModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.sendConnectionRequest(senderId: "\(senderID)", receiverId: receiverID, message: message)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let dto = RequestDTO(json)
                    complete(Result.success(APIResponse(json, data:RequestModel(dto))))
                }
            }
        }
    }
    
    func sendConnectionQrCode(qrCode: String, currentUserId: String, complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.sendConnectionQRCode(qrCode: qrCode, currentUserId: currentUserId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let userDTO = UserDTO(json)
                    let userModel = UserModel(userDTO)
                    complete(Result.success(APIResponse(json, data: userModel)))
                }
            }
        }
    }
    
    func acceptOrReject(requestId: Int, status: RequestStatus, complete: @escaping(Result<APIResponse<RequestModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.acceptRejectRequest(requestId: "\(requestId)", status: status)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let dto = RequestDTO(json)
                    complete(Result.success(APIResponse(json, data:RequestModel(dto))))
                }
            }
        }
    }
    
    func cancelRequest(requestId: Int, complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.cancelRequest(requestId: "\(requestId)")
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let dto = UserDTO(json)
                    complete(Result.success(APIResponse(json, data:UserModel(dto))))
                }
            }
        }
    }
    
    func searchMyConnected(param: String, pager: Pager, complete: @escaping(Result<APIResponse<[UserModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.searchMyConnected(param, pager: pager)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [UserModel] = []
                    for item in array {
                        let dto = UserDTO(item)
                        let model = UserModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func getSuggestKeywords(text: String, complete: @escaping(Result<APIResponse<[String], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.suggestKeywords(text)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    var keywords = [String]()
                    let array = json.arrayValue
                    for string in array {
                        keywords.append(string.stringValue)
                    }
                    complete(Result.success(APIResponse(json, data: keywords)))
                }
            }
        }
    }
    
    func searchMySuggestion(param: String, listIndustriesSelected: [SubCategoryModel], pager: Pager, complete: @escaping(Result<APIResponse<[UserModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.searchMySuggestion(param,
                                                                          listIndustriesSelected: listIndustriesSelected,
                                                                          pager: pager)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [UserModel] = []
                    for item in array {
                        let dto = UserDTO(item)
                        let model = UserModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func searchAllPeople(param: String,
                         listIndustriesSelected: [SubCategoryModel],
                         listInterestsSelected: [SubCategoryModel],
                         listLocationSelected: [rowModelLocation],
                         pager: Pager,
                         complete: @escaping(Result<APIResponse<[UserModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.searchAllPeopleRequest(param,
                                                                              listIndustriesSelected: listIndustriesSelected,
                                                                              listInterestsSelected: listInterestsSelected,
                                                                              listLocationSelected: listLocationSelected,
                                                                              pager: pager)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [UserModel] = []
                    for item in array {
                        let dto = UserDTO(item)
                        let model = UserModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func doBlockUser(blockUserId: String, currentUserId: String, complete: @escaping(Result<APIResponse<Any, Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.blockUser(blockUserId: blockUserId, currentUserId: currentUserId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                complete(Result.success(APIResponse(JSON.null, data: data?.rawString() ?? "")))
                if let json = data {
                    let requestString = json.stringValue
                    complete(Result.success(APIResponse(json, data: requestString)))
                }
            }
        }
    }
    
    func defaultRequestMessage(complete: @escaping(Result<APIResponse<String, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.defaultRequestMessageRequest()
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                complete(Result.success(APIResponse(JSON.null, data: data?.rawString() ?? "")))
                if let json = data {
                    let requestString = json.stringValue
                    complete(Result.success(APIResponse(json, data: requestString)))
                }
            }
        }
    }
    
    func reportPost(postId: String, message: String, complete: @escaping(Result<APIResponse<Any, Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.reportPost(postId, message: message)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                complete(Result.success(APIResponse(JSON.null, data: data?.rawString() ?? "")))
                if let json = data {
                    let requestString = json.stringValue
                    complete(Result.success(APIResponse(json, data: requestString)))
                }
            }
        }
    }
    
}













