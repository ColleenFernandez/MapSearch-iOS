//
//  ApiManager.swift
//  Everave Update
//
//  Created by Ubuntu on 16/01/2020
//  Copyright © 2020 Ubuntu. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit
// ************************************************************************//
                            // MAP app project //
// ************************************************************************//

//let SERVER_URL = "http://192.168.101.105:1119/api/"
let SERVER_URL = "https://map-app.tutu-sol.com/api/"
let SUCCESSTRUE = 200

class ApiManager {
    class func signup(user_name: String, email: String, user_des: String, password: String, token: String, attachments: [(Data, String, String, String)]?, completion: @escaping (_ success: Bool, _ response: Any?) -> Void) {
        let requestURL = SERVER_URL + "signup"
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(user_name.data(using: .utf8)!, withName: PARAMS.USER_NAME)
                multipartFormData.append(email.data(using: .utf8)!, withName: PARAMS.EMAIL)
                multipartFormData.append(user_des.data(using: .utf8)!, withName: PARAMS.USER_DES)
                multipartFormData.append(password.data(using: .utf8)!, withName: PARAMS.PASSWORD)
                multipartFormData.append(token.data(using: .utf8)!, withName: PARAMS.TOKEN)
                if let attachments = attachments {
                    for i in 0 ..< attachments.count {
                        multipartFormData.append(attachments[i].0, withName: attachments[i].1, fileName: attachments[i].2, mimeType: attachments[i].3)
                    }
                }
            },
            to: requestURL,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case let .success(upload, _, _):
                    upload.responseJSON { response in
                        switch response.result {
                        case .failure: completion(false, nil)
                        case let .success(data):
                            let dict = JSON(data)
                            let status = dict[PARAMS.RESULTCODE].intValue
                            if status == SUCCESSTRUE {
                                if let user_data = dict[PARAMS.USER_INFO].arrayObject {
                                    thisuser.clearUserInfo()
                                    thisuser = UserModel(JSON(user_data.first!))
                                    thisuser.saveUserInfo()
                                    thisuser.loadUserInfo()
                                    completion(true, status)
                                }
                            } else if status == 201 { // email exist
                                completion(false, status)
                            } else if status == 202 { // pictuer upload fail
                                completion(false, status)
                            } else {
                                completion(false, status)
                            }
                        }
                    }
                case .failure:
                    completion(false, nil)
                }
            }
        )
    }
    
    class func editProfile(user_name: String, email: String, user_des: String, password: String, attachments: [(Data, String, String, String)]?, completion: @escaping (_ success: Bool, _ response: Any?) -> Void) {
        let requestURL = SERVER_URL + "editProfile"
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                let token = UserDefault.getString(key: PARAMS.TOKEN, defaultValue: "") ?? ""
                multipartFormData.append("\(thisuser.user_id ?? 0)".data(using: .utf8)!, withName: PARAMS.USER_ID)
                multipartFormData.append(user_name.data(using: .utf8)!, withName: PARAMS.USER_NAME)
                multipartFormData.append(email.data(using: .utf8)!, withName: PARAMS.EMAIL)
                multipartFormData.append(user_des.data(using: .utf8)!, withName: PARAMS.USER_DES)
                multipartFormData.append(password.data(using: .utf8)!, withName: PARAMS.PASSWORD)
                multipartFormData.append(token.data(using: .utf8)!, withName: PARAMS.TOKEN)
                if let attachments = attachments {
                    for i in 0 ..< attachments.count {
                        multipartFormData.append(attachments[i].0, withName: attachments[i].1, fileName: attachments[i].2, mimeType: attachments[i].3)
                    }
                }
            },
            to: requestURL,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case let .success(upload, _, _):
                    upload.responseJSON { response in
                        switch response.result {
                        case .failure: completion(false, nil)
                        case let .success(data):
                            let dict = JSON(data)
                            let status = dict[PARAMS.RESULTCODE].intValue
                            if status == SUCCESSTRUE {
                                if let user_data = dict[PARAMS.USER_INFO].arrayObject {
                                    thisuser.clearUserInfo()
                                    thisuser = UserModel(JSON(user_data.first!))
                                    thisuser.saveUserInfo()
                                    thisuser.loadUserInfo()
                                    completion(true, status)
                                }
                            } else if status == 201 { // email exist
                                completion(false, status)
                            } else if status == 202 { // pictuer upload fail
                                completion(false, status)
                            } else {
                                completion(false, status)
                            }
                        }
                    }
                case .failure:
                    completion(false, nil)
                }
            }
        )
    }

    class func signin(email: String, password: String, completion: @escaping (_ success: Bool, _ response: Any?) -> Void) {
        let params = [PARAMS.EMAIL: email, PARAMS.PASSWORD: password, PARAMS.TOKEN: UserDefault.getString(key: PARAMS.TOKEN, defaultValue: "") ?? ""] as [String: Any]
        Alamofire.request(SERVER_URL + "signin", method: .post, parameters: params)
            .responseJSON { response in
                switch response.result {
                case .failure:
                    completion(false, nil)
                case let .success(data):
                    let dict = JSON(data)
                    let status = dict[PARAMS.RESULTCODE].intValue // 0,1,2
                    if status == SUCCESSTRUE {
                        if let user_data = dict[PARAMS.USER_INFO].arrayObject {
                            if let data = user_data.first, JSON(data)[PARAMS.USER_ID].intValue != 0{
                                thisuser.clearUserInfo()
                                thisuser = UserModel(JSON(user_data.first!))
                                thisuser.saveUserInfo()
                                thisuser.loadUserInfo()
                                completion(true, status)
                            }else{
                                thisuser.clearUserInfo()
                                completion(false, status)
                            }
                        }
                    } else if status == 201 { // email exist
                        completion(false, status)
                    } else if status == 202 { // pictuer upload fail
                        completion(false, status)
                    } else {
                        completion(false, status)
                    }
                }
            }
    }

    class func manageLocationLike(location_id: Int, request_type: LikeType, completion: @escaping (_ success: Bool, _ response: Any?) -> Void) {
        let params = [PARAMS.USER_ID: thisuser.user_id ?? 0, PARAMS.LOCATION_ID: location_id, PARAMS.REQUEST_TYPE: request_type.rawValue] as [String: Any]

        Alamofire.request(SERVER_URL + "manageLocationLike", method: .post, parameters: params)
        .responseJSON { response in
            switch response.result {
            case .failure:
                completion(false, nil)
            case let .success(data):
                let dict = JSON(data)
                let status = dict[PARAMS.RESULTCODE].intValue // 0,1,2
                if status == SUCCESSTRUE {
                    completion(true, status)
                } else {
                    completion(false, status)
                }
            }
        }
    }
    
    class func getLocations(request_type:LocationRequestType! = .all_location , completion: @escaping (_ success: Bool, _ response: Any?) -> Void) {
        let params = [PARAMS.USER_ID: thisuser.user_id ?? 0, PARAMS.REQUEST_TYPE: request_type.rawValue, PARAMS.UUID: Constants.uuid ?? "0"] as [String: Any]

        Alamofire.request(SERVER_URL + "getLocations", method: .post, parameters: params)
        .responseJSON { response in
            switch response.result {
            case .failure:
                completion(false, nil)
            case let .success(data):
                let dict = JSON(data)
                let status = dict[PARAMS.RESULTCODE].intValue // 0,1,2
                if status == SUCCESSTRUE {
                    completion(true, dict)
                } else {
                    completion(false, status)
                }
            }
        }
    }
    
    class func setTotalNotiRead(ids: String, completion: @escaping (_ success: Bool, _ response: Any?) -> Void) {
        let params = ["total_noti_ids": ids, PARAMS.UUID: Constants.uuid ?? "0"] as [String: Any]
        Alamofire.request(SERVER_URL + "setTotalNotiRead", method: .post, parameters: params)
        .responseJSON { response in
            switch response.result {
            case .failure:
                completion(false, nil)
            case let .success(data):
                let dict = JSON(data)
                let status = dict[PARAMS.RESULTCODE].intValue // 0,1,2
                if status == SUCCESSTRUE {
                    completion(true, dict)
                } else {
                    completion(false, status)
                }
            }
        }
    }
    
    
    class func forgot(email: String, completion :  @escaping (_ success: Bool, _ response : Any?) -> ()) {
        let params = [PARAMS.EMAIL: email] as [String : Any]
        Alamofire.request(SERVER_URL + "forgot", method:.post, parameters:params)
        .responseJSON { response in
            switch response.result {
                case .failure:
                completion(false, nil)
                case .success(let data):
                let dict = JSON(data)
                //print("sellers =====> ",dict)
                let status = dict[PARAMS.RESULTCODE].intValue// 0,1,2
                let pin_code = dict[PARAMS.PIN_CODE].stringValue// 0,1,2
                if status == SUCCESSTRUE {
                    completion(true,pin_code)
                } else {
                    completion(false, status)
                }
            }
        }
    }
    
    class func resetPassword(email: String,password: String, completion :  @escaping (_ success: Bool, _ response : Any?) -> ()) {
            let params = [PARAMS.EMAIL: email, PARAMS.PASSWORD: password] as [String : Any]
            Alamofire.request(SERVER_URL + "resetPassword", method:.post, parameters:params)
            .responseJSON { response in
                switch response.result {
                    case .failure:
                    completion(false, nil)
                    case .success(let data):
                    let dict = JSON(data)
                    //print("sellers =====> ",dict)
                    let status = dict[PARAMS.RESULTCODE].intValue// 0,1,2
                    if status == SUCCESSTRUE {
                        completion(true,status)
                    } else {
                        completion(false, status)
                    }
                }
            }
        }

    class func changePassword(password: String, completion :  @escaping (_ success: Bool, _ response : Any?) -> ()) {
        let params = [PARAMS.USER_ID: "\(thisuser.user_id ?? 0)", PARAMS.PASSWORD: password] as [String : Any]
        Alamofire.request(SERVER_URL + "changePassword", method:.post, parameters:params)
        .responseJSON { response in
            switch response.result {
                case .failure:
                completion(false, nil)
                case .success(let data):
                let dict = JSON(data)
                //print("sellers =====> ",dict)
                let status = dict[PARAMS.RESULTCODE].intValue// 0,1,2
                if status == SUCCESSTRUE {
                    completion(true,status)
                } else {
                    completion(false, status)
                }
            }
        }
    }

    class func closeAccount(completion :  @escaping (_ success: Bool, _ response : Any?) -> ()) {
        let params = [PARAMS.USER_ID: "\(thisuser.user_id ?? 0)" ] as [String : Any]
        Alamofire.request(SERVER_URL + "closeAccount", method:.post, parameters:params)
        .responseJSON { response in
            switch response.result {
                case .failure:
                completion(false, nil)
                case .success(let data):
                let dict = JSON(data)
                let status = dict[PARAMS.RESULTCODE].intValue // 0,1,2
                //let seller_infoJSON = JSON(seller_info as Any)
                if status == SUCCESSTRUE {
                    completion(true,dict)
                } else {
                    completion(false, status)
                }
            }
        }
    }
    
    class func getNoti(completion :  @escaping (_ success: Bool, _ response : Any?) -> ()) {
        let params = [PARAMS.USER_ID: thisuser.user_id ?? 0] as [String : Any]
        Alamofire.request(SERVER_URL + "getNoti", method:.post, parameters: params)
        .responseJSON { response in
            switch response.result {
                case .failure:
                completion(false, nil)
                case .success(let data):
                let dict = JSON(data)
                let status = dict[PARAMS.RESULTCODE].intValue// 0,1,2
                if status == SUCCESSTRUE {
                    completion(true,dict)
                } else{
                    completion(false, status)
                }
            }
        }
    }
    
    class func setNotiRead(completion :  @escaping (_ success: Bool, _ response : Any?) -> ()) {
        let params = [PARAMS.USER_ID: thisuser.user_id ?? 0] as [String : Any]
        Alamofire.request(SERVER_URL + "setNotiRead", method:.post, parameters: params)
        .responseJSON { response in
            switch response.result {
                case .failure:
                completion(false, nil)
                case .success(let data):
                let dict = JSON(data)
                let status = dict[PARAMS.RESULTCODE].intValue// 0,1,2
                if status == SUCCESSTRUE {
                    completion(true,dict)
                } else{
                    completion(false, status)
                }
            }
        }
    }
    
    class func manageMemo(location_id: Int, memo: String?, request_type: NoteActionType, completion :  @escaping (_ success: Bool, _ response : Any?) -> ()) {
        let params = [PARAMS.USER_ID: thisuser.user_id ?? 0, "memo": memo ?? "", PARAMS.LOCATION_ID: location_id, PARAMS.REQUEST_TYPE: request_type.rawValue] as [String : Any]
        Alamofire.request(SERVER_URL + "manageMemo", method:.post, parameters: params)
        .responseJSON { response in
            switch response.result {
                case .failure:
                completion(false, nil)
                case .success(let data):
                let dict = JSON(data)
                let status = dict[PARAMS.RESULTCODE].intValue// 0,1,2
                if status == SUCCESSTRUE {
                    completion(true,dict)
                } else {
                    completion(false, status)
                }
            }
        }
    }
    
    class func getNotiLocations(_ location_id: Int, completion: @escaping (_ success: Bool, _ response: Any?) -> Void) {
        let params = [PARAMS.USER_ID: thisuser.user_id ?? 0, PARAMS.LOCATION_ID: location_id] as [String: Any]

        Alamofire.request(SERVER_URL + "getNotiLocations", method: .post, parameters: params)
        .responseJSON { response in
            switch response.result {
            case .failure:
                completion(false, nil)
            case let .success(data):
                let dict = JSON(data)
                let status = dict[PARAMS.RESULTCODE].intValue // 0,1,2
                if status == SUCCESSTRUE {
                    completion(true, dict)
                } else {
                    completion(false, status)
                }
            }
        }
    }
}
