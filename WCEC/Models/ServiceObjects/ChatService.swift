//
//  ChatService.swift
//  WCEC
//
//  Created by hnc on 6/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ChatService: APIServiceObject {
    func createChatChannel(name: String, invitations: [String], complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let param = ["name": name,
                     "invitations": invitations] as [String : Any]
        let request = APIRequestProvider.shareInstance.createChatChannelRequest(param: param)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func declineChannel(channelId: String, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.declineChatChannelRequest(channelId: channelId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func joinChannel(channelId: String, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.joinChatChannelRequest(channelId: channelId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func leftChannel(channelId: String, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.leftChatChannelRequest(channelId: channelId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func removeUserFromChannel(channelId: String, removeUserId: String, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.removeUserInChannelRequest(channelId: channelId, removeUserId: removeUserId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func inviteUserToChannel(channelId: String, listInviteIds: [String], complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let param = ["ids": listInviteIds] as [String : Any]
        let request = APIRequestProvider.shareInstance.inviteUserToChannelRequest(param: param, channelId: channelId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func updateChannel(channelId: String, name: String, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let param = ["name": name] as [String : Any]
        let request = APIRequestProvider.shareInstance.updateChannelRequest(param: param, channelId: channelId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func getChannelDetail(channelId: String, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.getChannelDetail(channelId: channelId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func deleteChannel(channelId: String, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.deleteChannelRequest(channelId: channelId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func getMessagesInChannel(channelId: String, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.getMessagesInChannelDetail(channelId: channelId)

        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func sendMessageToChannel(channelId: String, message: String, images: [Int], pubnubTime: NSNumber, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let param = ["message": message,
                     "images": images,
                     "pubnub_time": pubnubTime.stringValue] as [String : Any]
        let request = APIRequestProvider.shareInstance.sendMessageToChannelRequest(param: param, channelId: channelId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func editMessageInChannel(channelId: String, messageId: String, newMessage: String, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let param = ["message": newMessage] as [String : Any]
        let request = APIRequestProvider.shareInstance.editMessageInChannelRequest(messageId: messageId, channelId: channelId, param: param)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func deleteMessageInChannel(channelId: String, messageId: String, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.deleteMessageInChannelRequest(messageId: messageId, channelId: channelId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func clearChatHistoryInChannel(channelId: String, complete: @escaping(Result<APIResponse<ChannelModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.clearChatHistoryInChannelRequest(channelId: channelId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let channelDTO = ChannelDTO(json)
                    let channelModel = ChannelModel(channelDTO)
                    complete(Result.success(APIResponse(json, data: channelModel)))
                }
            }
        }
    }
    
    func getListChannelMessage(pager: Pager, complete: @escaping(Result<APIResponse<[ChannelModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.listChannelMessage(pager: pager)
        let currentDate = Date()
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            #if DEBUG
            let difference = Calendar.current.dateComponents([.hour, .minute, .second], from: currentDate, to: Date())
            let formattedString = String(format: "%02ld, %02ld, %02ld", difference.hour!, difference.minute!, difference.second!)
            print("how long get list channel api take? " + formattedString)
            #endif
            
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models = [ChannelModel]()
                    array.forEach({
                        let dto = ChannelDTO($0)
                        let model = ChannelModel(dto)
                        models.append(model)
                    })
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func getListChannelId(complete: @escaping(Result<APIResponse<[String], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.listChannelIdRequest()
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var channelIDs = [String]()
                    array.forEach({
                        channelIDs.append($0.stringValue)
                    })
                    complete(Result.success(APIResponse(json, data: channelIDs)))
                }
            }
        }
    }
    
    func grandAccessManage(channelId: String, complete: @escaping(Result<APIResponse<String, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.grandAccessToChannel(channelId: channelId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    complete(Result.success(APIResponse(json, data: json.stringValue)))
                }
            }
        }
    }
}




