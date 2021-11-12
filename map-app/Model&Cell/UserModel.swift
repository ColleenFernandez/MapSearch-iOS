//
//  UserModel.swift
//  SNKRAPP
//
//  Created by Ubuntu on 1/18/20.
//  Copyright © 2020 Ubuntu. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserModel: NSObject {
    var user_id: Int!
    var user_name: String?
    var user_photo: String?
    var phone_number: String?
    var user_email: String?
    var password: String?
    var user_description: String?

    override init() {
        super.init()
        user_id           = -1
        user_name         = nil
        user_photo        = nil
        user_email        = nil
        password          = nil
        phone_number = nil
        user_description = nil
    }

    init(_ json: JSON) { // for setting for myself
        user_id           = json[PARAMS.USER_ID].intValue
        user_name         = json[PARAMS.USER_NAME].stringValue
        phone_number      = json[PARAMS.PHONE_NUMBER].stringValue
        user_email        = json[PARAMS.EMAIL].stringValue
        user_photo        = json[PARAMS.USER_PHOTO].stringValue
        password          = json[PARAMS.PASSWORD].stringValue
        user_description          = json[PARAMS.USER_DES].stringValue
    }

    init(user_id: Int, user_name: String, user_photo: String) {
        self.user_id    = user_id
        self.user_name  = user_name
        self.user_photo = user_photo
    }

    init(json1: JSON) { // for other user
        user_id           = json1[PARAMS.USER_ID].intValue
        user_name         = json1[PARAMS.USER_NAME].stringValue
        phone_number      = json1[PARAMS.PHONE_NUMBER].stringValue
        user_email        = json1[PARAMS.EMAIL].stringValue
        user_photo        = json1[PARAMS.USER_PHOTO].stringValue
        user_description          = json1[PARAMS.USER_DES].stringValue
    }

    // for comment
    init(comment: Dictionary<String, Any>) {
        user_id           = comment[PARAMS.USER_ID] as? Int
        user_name         = comment[PARAMS.USER_NAME] as? String
        user_photo        = comment[PARAMS.USER_PHOTO] as? String
        user_email        = comment[PARAMS.EMAIL] as? String
        user_description          = comment[PARAMS.USER_DES] as? String
    }

    // Check and returns if user is valid user or not
    var isValid: Bool {
        return user_id != nil && user_id != -1 && user_email != nil
    }

    // Recover user credential from UserDefault
    func loadUserInfo() {
        user_id           = UserDefault.getInt(key: PARAMS.USER_ID, defaultValue: -1)
        user_name         = UserDefault.getString(key: PARAMS.USER_NAME, defaultValue: "")
        phone_number      = UserDefault.getString(key: PARAMS.PHONE_NUMBER, defaultValue: "")
        user_photo        = UserDefault.getString(key: PARAMS.USER_PHOTO, defaultValue: "")
        user_email        = UserDefault.getString(key: PARAMS.EMAIL, defaultValue: "")
        password          = UserDefault.getString(key: PARAMS.PASSWORD, defaultValue: "")
        user_description          = UserDefault.getString(key: PARAMS.USER_DES, defaultValue: "")
    }

    // Save user credential to UserDefault
    func saveUserInfo() {
        UserDefault.setInt(key: PARAMS.USER_ID, value: user_id)
        UserDefault.setString(key: PARAMS.USER_NAME, value: user_name)
        UserDefault.setString(key: PARAMS.EMAIL, value: user_email)
        UserDefault.setString(key: PARAMS.USER_PHOTO, value: user_photo)
        UserDefault.setString(key: PARAMS.PHONE_NUMBER, value: phone_number)
        UserDefault.setString(key: PARAMS.PASSWORD, value: password)
        UserDefault.setString(key: PARAMS.USER_DES, value: user_description)
    }

    // Clear save user credential
    func clearUserInfo() {
        user_id      = -1
        user_name    = nil
        user_photo   = nil
        user_email   = nil
        password     = nil
        user_description     = nil
        phone_number = nil
        UserDefault.setInt(key: PARAMS.USER_ID, value: -1)
        UserDefault.setString(key: PARAMS.USER_NAME, value: nil)
        UserDefault.setString(key: PARAMS.PHONE_NUMBER, value: nil)
        UserDefault.setString(key: PARAMS.USER_PHOTO, value: nil)
        UserDefault.setString(key: PARAMS.USER_LOCATION, value: nil)
        UserDefault.setString(key: PARAMS.EMAIL, value: nil)
        UserDefault.setString(key: PARAMS.USER_DES, value: nil)
    }
}
