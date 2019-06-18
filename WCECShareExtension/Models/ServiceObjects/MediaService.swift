//
//  MediaService.swift
//  WCEC
//
//  Created by hnc on 6/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class MediaService: APIServiceObject {
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
                "Content-Type": "multipart/form-data",
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
    
    func uploadImage(image: UIImage, _ complete: @escaping(Result<APIResponse<FileModel, Any>>) -> Void) {
        let url = APIRequestProvider.shareInstance.requestURL.appending("files")
        
        let dateTimeStamp = Int64(Date().timeIntervalSince1970 * 1000)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "file", fileName: "file_\(dateTimeStamp).jpg", mimeType: "image/jpg")
        }, to: url,
           method: .post,
           headers: headers) { (_ result: SessionManager.MultipartFormDataEncodingResult) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let error = response.error {
                        complete(Result.failure(error))
                    } else {
                        if let responseData = response.result.value {
                            let json            = JSON(responseData)
                            
                            print(json)
                            
                            var data:JSON? = nil
                            if json["data"].exists() {
                                data = json["data"]
                            }
                            
                            let array = data?.arrayValue
                            var models: [FileModel] = []
                            for item in array! {
                                let dto = FileDTO(item)
                                let model = FileModel(dto)
                                models.append(model)
                            }
                            complete(Result.success(APIResponse(json, data: models.first!)))
                        }
                    }
                }
            case .failure(let encodingError):
                complete(Result.failure(encodingError))
                break
            }
        }
    }
    
    func uploadMultipleImage(images: [UIImage], _ complete: @escaping(Result<APIResponse<[FileModel], Any>>) -> Void) {
        let url = APIRequestProvider.shareInstance.requestURL.appending("files")
       
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for image in images{
                let imageData1 = UIImageJPEGRepresentation(image, 0.1)!
                let dateTimeStamp = Int64(Date().timeIntervalSince1970 * 1000)
                multipartFormData.append(imageData1, withName: "file[]", fileName: "file_\(dateTimeStamp).jpg", mimeType: "image/jpg")
            }
        }, to: url,
           method: .post,
           headers: headers) { (_ result: SessionManager.MultipartFormDataEncodingResult) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let error = response.error {
                        complete(Result.failure(error))
                    } else {
                        if let responseData = response.result.value {
                            let json            = JSON(responseData)

                            print(json)

                            var data:JSON? = nil
                            if json["data"].exists() {
                                data = json["data"]
                            }

                            let array = data?.arrayValue
                            var models: [FileModel] = []
                            for item in array! {
                                let dto = FileDTO(item)
                                let model = FileModel(dto)
                                models.append(model)
                            }
                            complete(Result.success(APIResponse(json, data: models)))
                        }
                    }
                }
            case .failure(let encodingError):
                complete(Result.failure(encodingError))
                break
            }
        }
    }
    
    func uploadVideo(videoData: Data, _ complete: @escaping(Result<APIResponse<FileModel, Any>>) -> Void) {
        let url = APIRequestProvider.shareInstance.requestURL.appending("files")
        let dateTimeStamp = Int64(Date().timeIntervalSince1970 * 1000)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(videoData, withName: "file", fileName:"file_video_\(dateTimeStamp).mp4", mimeType:  "video/mp4")
        }, to: url,
           method: .post,
           headers: headers) { (_ result: SessionManager.MultipartFormDataEncodingResult) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let error = response.error {
                        complete(Result.failure(error))
                    } else {
                        if let responseData = response.result.value {
                            let json            = JSON(responseData)
                            
                            print(json)
                            
                            var data:JSON? = nil
                            if json["data"].exists() {
                                data = json["data"]
                            }
                            
                            let array = data?.arrayValue
                            var models: [FileModel] = []
                            for item in array! {
                                let dto = FileDTO(item)
                                let model = FileModel(dto)
                                models.append(model)
                            }
                            complete(Result.success(APIResponse(json, data: models.first!)))
                        }
                    }
                }
            case .failure(let encodingError):
                complete(Result.failure(encodingError))
                break
            }
        }
    }
}
