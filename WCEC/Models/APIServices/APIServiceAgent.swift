//
//  APIServiceAgent.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/*
 *  APIServiceAgent takes responsible for
 *  - Convert DataResponse<Any> to JSON object
 *  - Detect and handle application errors such as: token expired, version not support...
 */

let responseCodeSuccess = 0
let errorCodeNoData     = 404

let statusCodeSuccess = "SUCCESS"
let statusCodeFail = "FAIL"

class APIServiceAgent: NSObject {
    /*
     *  perform request
     *  param:
     Add a comment to this line
     *  - request: DataRequest
     *  - completion block (JSON, NSError?)
     */
    
    func startRequest(_ request: DataRequest, completion: @escaping(JSON?,JSON?,NSError?) -> Void) {
        #if DEBUG
            DLog(request.debugDescription)
        #endif
        request
            .validate()
            .responseJSON { (_ response: DataResponse<Any>) in
                #if DEBUG
                    DLog(response.debugDescription)
                #endif
                
                print(request.debugDescription)
                switch response.result {
                case .success:
                    if let responseData = response.result.value {
                        let json            = JSON(responseData)
                        
                        print(json)
                        
                        var data:JSON? = nil
                        if json["data"].exists() {
                            data = json["data"]
                        }
                        var meta:JSON? = nil
                        if json["meta"].exists() {
                            meta = json["meta"]
                        }
                        let errorCode = json["status_code"].intValue
                        let error           = json["error"].boolValue
                        if json["back_to"].stringValue == "email" {
                            let alertView = UIAlertController(title: "Alert".localized(),
                                                              message: json["message"].stringValue,
                                                              preferredStyle: UIAlertControllerStyle.alert)
                            let okAction = UIAlertAction(title: "OK".localized(), style: .cancel) { (_) in
                                // auto logout user
                                DataManager.clearLoginSession()
                                // show login view
                                Constants.appDelegate.setupAuthentication()
                                DataManager.save(boolValue: true, forKey: Constants.kGoToSignUp)
                            }
                            alertView.addAction(okAction)
                            Constants.appDelegate.window?.rootViewController?.present(alertView, animated: true, completion: nil)
                        } else if json["back_to"].stringValue == "mobile" {
                            let alertView = UIAlertController(title: "Alert".localized(),
                                                              message: json["message"].stringValue,
                                                              preferredStyle: UIAlertControllerStyle.alert)
                            let okAction = UIAlertAction(title: "OK".localized(), style: .cancel) { (_) in
                            }
                            alertView.addAction(okAction)
                            Constants.appDelegate.window?.rootViewController?.present(alertView, animated: true, completion: nil)
                        }
                        if error == false  {
                            completion(data, meta, nil)
                        } else {
                            let message         = json["message"].stringValue
                            let title          = json["errors"]["title"].stringValue
                            if errorCode == RestAPIStatusCode.invalidToken.rawValue {
                                if DataManager.getCurrentUserModel() != nil {
                                    // auto logout user
                                    DataManager.clearLoginSession()
                                    // show login view
                                    Constants.appDelegate.setupAuthentication()
                                    // show alert
                                    Constants.appDelegate.window?.rootViewController?.alertWithTitle(nil, message: message)
                                } else {
                                    // do nothing, user has been logged out
                                }
                            } else {
                                let error = self.returnErrorWith(code: errorCode, message: message, title: title)
                                completion(nil,nil, error)
                            }
                        }
                    } else {
                        completion(nil, nil, self.responseNotJSONError())
                    }
                    
                    break
                case .failure(let error as NSError):
                    #if DEBUG
                        print(error.userInfo)
                    #endif
                    if error.code == NSURLErrorCancelled {
                        completion(JSON.null, JSON.null, NSError.errorWith(code: error.code, message: ""))
                    } else {
                        completion(JSON.null, JSON.null, error)
                    }
                    break
                default:
                    break
                }
        }
    }
    
    func returnErrorWith(code: Int = 0, message: String, title: String) -> NSError {
        return NSError(domain: "", code: code, userInfo: ["message": message, "title": title])
    }
    
    func responseNotJSONError() -> NSError {
        return NSError()
    }
}
