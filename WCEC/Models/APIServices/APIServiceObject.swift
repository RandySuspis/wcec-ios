//
//  APIServiceObject.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import Alamofire

class APIServiceObject: NSObject {
    var requests = [DataRequest]()
    var serviceAgent = APIServiceAgent()
    
    /*
     * cancel all request for the certain service object
     * and remove all request from requests
     */
    func cancelAllRequests() {
        for request in requests {
            request.cancel()
        }
        requests.removeAll()
    }
    
    /*
     *  add request to request array
     *  @param request  DataRequest
     */
    
    func addToQueue(_ request: DataRequest) {
        requests.append(request)
    }
}
