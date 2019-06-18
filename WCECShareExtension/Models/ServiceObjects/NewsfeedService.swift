//
//  NewsfeedService.swift
//  WCEC
//
//  Created by hnc on 6/12/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class NewsfeedService: APIServiceObject {
    func getSuggestedTags(complete: @escaping(Result<APIResponse<[SubCategoryModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.getSuggestedTagsRequest()
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [SubCategoryModel] = []
                    for item in array {
                        let dto = SubCategoryDTO(item)
                        let model = SubCategoryModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func getTrendingTags(complete: @escaping(Result<APIResponse<[SubCategoryModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.getTrendingTagsRequest()
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [SubCategoryModel] = []
                    for item in array {
                        let dto = SubCategoryDTO(item)
                        let model = SubCategoryModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func searchTags(text: String, complete: @escaping(Result<APIResponse<[CategoryModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.searchTagsRequest(text)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [CategoryModel] = []
                    for item in array {
                        let dto = CategoryDTO(item)
                        let model = CategoryModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func getListNewfeed(authorId: Int? = nil, pager: Pager, complete: @escaping(Result<APIResponse<[NewfeedModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.listNewfeed(authorId: authorId, pager: pager)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [NewfeedModel] = []
                    for item in array {
                        let dto = NewfeedDTO(item)
                        let model = NewfeedModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func createNewPost(content: String, listIndustryTag: [String], listInterestTag: [String], listPhoto: [String], videoId: String, visibility: Bool,
                       complete: @escaping(Result<APIResponse<NewfeedModel, Any>>) -> Void ) {
        var param = ["content": content] as [String : Any]
        if listPhoto.count != 0 {
            param.updateValue(listPhoto, forKey: "images")
        }
        if videoId.count > 0 {
            param.updateValue(videoId, forKey: "video")
        }
        
        if listIndustryTag.count > 0 {
            param.updateValue(listIndustryTag, forKey: "industries")
        }
        
        if listInterestTag.count > 0 {
            param.updateValue(listInterestTag, forKey: "interests")
        }
        
        param.updateValue(visibility, forKey: "visibility")
        
        let request = APIRequestProvider.shareInstance.createNewPostRequest(param: param)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let newsfeedDTO = NewfeedDTO(json)
                    let model = NewfeedModel(newsfeedDTO)
                    complete(Result.success(APIResponse(json, data: model)))
                }
            }
        }
    }
    
    func likePost(id: String, complete: @escaping(Result<APIResponse<Any, Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.likePost(id: id)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                complete(Result.success(APIResponse(JSON.null, data: data?.rawString() ?? "")))
            }
        }
    }
    
    func editPost(postId: String, content: String, listIndustryTag: [String], listInterestTag: [String], listPhoto: [String], videoId: String, visibility: Bool,
                  complete: @escaping(Result<APIResponse<NewfeedModel, Any>>) -> Void ) {
        var param = ["content": content] as [String : Any]
        if listPhoto.count != 0 {
            param.updateValue(listPhoto, forKey: "images")
        }
        if videoId.count > 0 {
            param.updateValue(videoId, forKey: "video")
        }
        
        if listIndustryTag.count > 0 {
            param.updateValue(listIndustryTag, forKey: "industries")
        }
        
        if listInterestTag.count > 0 {
            param.updateValue(listInterestTag, forKey: "interests")
        }
        
        param.updateValue(visibility, forKey: "visibility")
        
        let request = APIRequestProvider.shareInstance.editPostRequest(postId: postId, param: param)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let newsfeedDTO = NewfeedDTO(json)
                    let model = NewfeedModel(newsfeedDTO)
                    complete(Result.success(APIResponse(json, data: model)))
                }
            }
        }
    }
    
    func deletePost(postId: String, complete: @escaping(Result<APIResponse<NewfeedModel, Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.deletePostRequest(postId: postId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let newsfeedDTO = NewfeedDTO(json)
                    let model = NewfeedModel(newsfeedDTO)
                    complete(Result.success(APIResponse(json, data: model)))
                }
            }
        }
    }
    
    func sharePost(postId: String, complete: @escaping(Result<APIResponse<NewfeedModel, Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.sharePostRequest(postId: postId)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let newsfeedDTO = NewfeedDTO(json)
                    let model = NewfeedModel(newsfeedDTO)
                    complete(Result.success(APIResponse(json, data: model)))
                }
            }
        }
    }
}














