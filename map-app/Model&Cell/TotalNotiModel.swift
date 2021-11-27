//
//  TotalNotiModel.swift
//  map-app
//
//  Created by Admin on 11/23/21.
//

import Foundation
import SwiftyJSON

class TotalNotiModel {
    var total_noti_id: Int!
    var total_noti_time: String?
    var total_noti_text: String?
    var total_noti_title: String?
    var total_noti_image: String?
    var noti_refer_url: String?
    var media_ratio:Float! = 1

    init(_ json: JSON) {
        self.total_noti_id = json["total_noti_id"].intValue
        self.total_noti_title = json["total_noti_title"].stringValue
        self.total_noti_text = json["total_noti_text"].stringValue
        self.total_noti_time = json["total_noti_time"].stringValue
        self.total_noti_image = json["total_noti_image"].stringValue
        self.noti_refer_url = json["noti_refer_url"].stringValue
        self.media_ratio = json["media_ratio"].floatValue
    }

    init() {
        total_noti_id = -1
        total_noti_time = nil
        total_noti_text = nil
        total_noti_title = nil
        total_noti_image = nil
        noti_refer_url = nil
        media_ratio = 1
    }
}
