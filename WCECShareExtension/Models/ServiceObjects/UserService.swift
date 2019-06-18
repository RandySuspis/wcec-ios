//
//  UserService.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class UserService: APIServiceObject {
    func doLogin(email: String, password: String,
                 complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.loginRequest(email: email, password: password)
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
    
    func doLogout(complete: @escaping(Result<APIResponse<Any, Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.logoutRequest()
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                complete(Result.success(APIResponse(JSON.null, data: true)))
            }
        }
    }
    
    func doSocialAuthen(email: String, id: String, type: String, firstName: String, lastName: String, avatarId: Int, complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.socialAthenticationRequest(email: email, id: id, type: type, firstName: firstName, lastName: lastName, avatarId: avatarId)
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
    
    func doSetPassword(password: String, userId: Int, complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.firstSetPassword(userId: userId,password: password)
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
    
    func doResetPassword(password: String, activationCode: String, complete: @escaping(Result<APIResponse<Any, Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.resetPassword(activationCode: activationCode,
                                                                          password: password)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                complete(Result.success(APIResponse(JSON.null, data: data?.rawString() ?? "")))
            }
        }
    }
    
    func doSignup(email: String,
                  complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.signUpRequest(email: email)
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
    
    func doForgotPassword(email: String, complete: @escaping(Result<APIResponse<Any, Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.forgotPasswordRequest(email: email)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                complete(Result.success(APIResponse(JSON.null, data: data?.rawString() ?? "")))
            }
        }
    }
    
    func doChangePassword(oldPassword: String, newPassword: String, confirmNewPass: String,
                          complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void ) {
        let param = ["now_password": oldPassword,
                     "password": newPassword,
                     "password_confirmation": confirmNewPass]
        let request = APIRequestProvider.shareInstance.changePasswordRequest(params: param)
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
    
    func doSendOTP(email: String, phone_number: String, phone_code: String, complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void ) {
        let param = ["email": email,
                     "phone_number": phone_number,
                     "phone_code":phone_code]
        let request = APIRequestProvider.shareInstance.sendOTP(params: param)
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
    
    func doVerifyOTP(otp: String, phone_number: String, phone_code: String, complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void ) {
        let param = ["otp": otp,
                     "phone_number": phone_number,
                     "phone_code":phone_code]
        let request = APIRequestProvider.shareInstance.verifyOTP(params: param)
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
    
    //MARK: User Profile
    func doSearchCountry(searchText: String,
                         complete: @escaping(Result<APIResponse<[CountryModel], Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.searchCountryRequest(searchText: searchText)
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [CountryModel] = []
                    for item in array {
                        let dto = CountryDTO(item)
                        let model = CountryModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    func doSearchJobTitles(searchText: String,
                         complete: @escaping(Result<APIResponse<[String], Any>>) -> Void ) {
        let request = APIRequestProvider.shareInstance.searchJobTitles(searchText: searchText)
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
    
    func doUpdateProfile(userId: Int, section: String, firstName: String, lastName: String, birthYear: String, phoneCode: String, phoneNumber: String, countryId: Int, shortBio: String, avatarId: Int,
                          complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void ) {
        let param = ["section": section,
                     "first_name": firstName,
                     "last_name": lastName,
                     "birthyear": birthYear,
                     "phone_number": phoneNumber,
                     "phone_code": phoneCode,
                     "country_id": "\(countryId)",
                     "short_bio": shortBio,
                     "avatar": "\(avatarId)"]
        let request = APIRequestProvider.shareInstance.updateProfileRequest(param: param, userId: userId)
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
    
    func doUpdateOccupation(userId: Int,
                            job_title: String,
                            hq_location: Int,
                            current_location: Int,
                            company_name: String,
                            begin_date: String,
                            is_current: Int,
                            description: String,
                            complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void ) {
        let param = ["job_title": job_title,
                     "hq_location": "\(hq_location)",
                     "current_location": "\(current_location)",
                     "company_name": company_name,
                     "begin_date": begin_date,
                     "is_current": "\(is_current)",
                     "description": description]
        let request = APIRequestProvider.shareInstance.updateOccupation(param: param, userId: userId)
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
    
    func doGetUserInfo(userId: String, complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.getUserInfoRequest(userId: userId)
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
    
    //Mark: Industries
    func getListIndustries(searchText: String, complete: @escaping(Result<APIResponse<[CategoryModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.getIndustriesRequest(searchText: searchText)
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
    
    func doUpdateIndustry(userId: Int, section: String, industries: [String],
                         complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void ) {
        let param = ["section": section,
                     "industries": industries] as [String : Any]
        let request = APIRequestProvider.shareInstance.updateProfileRequest(param: param, userId: userId)
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
    //Mark: Interests
    func getListInterests(searchText: String, complete: @escaping(Result<APIResponse<[CategoryModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.getInterestsRequest(searchText: searchText)
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
    
    func doUpdateInterests(userId: Int, section: String, interests: [String],
                          complete: @escaping(Result<APIResponse<UserModel, Any>>) -> Void ) {
        let param = ["section": section,
                     "interests": interests] as [String : Any]
        let request = APIRequestProvider.shareInstance.updateProfileRequest(param: param, userId: userId)
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
    
    //MARK: Quotes
    func getListQuotes(complete: @escaping(Result<APIResponse<[QuoteModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.quotes()
        self.serviceAgent.startRequest(request) { (data, meta, error) in
            if let err = error {
                complete(Result.failure(err))
            } else {
                if let json = data {
                    let array = json.arrayValue
                    var models: [QuoteModel] = []
                    for item in array {
                        let dto = QuoteDTO(item)
                        let model = QuoteModel(dto)
                        models.append(model)
                    }
                    complete(Result.success(APIResponse(json, data: models)))
                }
            }
        }
    }
    
    //MARK :Mutual Connections
    func getListMutualConnection(currentId: String, userId: String, pager: Pager, complete: @escaping(Result<APIResponse<[UserModel], Any>>) -> Void) {
        let request = APIRequestProvider.shareInstance.getMutualConnections(currentId: currentId, userId: userId, pager: pager)
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
}











