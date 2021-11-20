//
//  PostModel&Cell.swift
//  meets
//
//  Created by top Dev on 9/20/20.
//

import Foundation
import SwiftyUserDefaults
import Kingfisher
import SwiftyJSON
import AVKit
import UIKit

class LocationModel {

    var location_id : Int!
    var location_address: String?
    var location_lat: Double?
    var location_lang: Double?
    var mark: MarkModel?
    var location_description: String?
    var location_memo: String?
    var location_name: String?
    var location_image: String?
    var is_location_like: Bool = false
    var post: [PostModel]?
    var has_new_noti: Bool = false
    
    init() {
        self.location_id = -1
        self.mark = nil
        self.location_address = nil
        self.location_lat = nil
        self.location_lang = nil
        self.location_description = nil
        self.location_name = nil
        self.location_image = nil
        self.is_location_like = false
        self.post = nil
        self.has_new_noti = false
        self.location_memo = nil
    }
    
    init(_ one: JSON){
        self.location_id = one[PARAMS.LOCATION_ID].intValue
        self.location_address = one[PARAMS.LOCACTION_ADDRESS].stringValue
        self.location_lat = one[PARAMS.LOCATION_LAT].doubleValue
        self.location_lang = one[PARAMS.LOCATION_LANG].doubleValue
        self.mark = MarkModel(one)
        self.location_description = one[PARAMS.LOCATION_DESCRIPTION].stringValue
        self.location_memo = JSON(one["memo"].object)["memo"].stringValue
        self.location_name = one[PARAMS.LOCATION_NAME].stringValue
        self.location_image = one[PARAMS.LOCATION_IMAGE].stringValue
        self.is_location_like = one[PARAMS.IS_LOCACTION_LIKE].intValue == 1 ? true : false
        self.post = [PostModel]()
        self.post!.removeAll()
        if let post_data = one["post"].arrayObject{
            if post_data.count > 0{
                for two in post_data{
                    self.post!.append(PostModel(JSON(two as Any)))
                }
            }
        }
        self.has_new_noti = Int64(NSDate().timeIntervalSince1970) - one[PARAMS.LAST_UPDATED].int64Value <= Constants.ONE_WEEK_TIMESTAMP ? true : false
    }
}

class MarkModel {
    var mark_id : Int!
    var mark_name: String?
    var mark_image: String?
    var mark_description: String?
    
    init() {
        self.mark_id = -1
        self.mark_name = nil
        self.mark_image = nil
        self.mark_description = nil
    }
    
    init(_ one: JSON){
        self.mark_id = one[PARAMS.MARK_ID].intValue
        self.mark_name = one[PARAMS.MARK_NAME].stringValue
        self.mark_image = one[PARAMS.MARK_IMAGE].stringValue
        self.mark_description = one[PARAMS.MARK_DESCRIPTION].stringValue
    }
}


