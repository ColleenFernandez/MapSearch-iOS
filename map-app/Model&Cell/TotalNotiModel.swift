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

    init(_ json: JSON) {
        self.total_noti_id = json["total_noti_id"].intValue
        self.total_noti_title = json["total_noti_title"].stringValue
        self.total_noti_text = json["total_noti_text"].stringValue
        self.total_noti_time = json["total_noti_time"].stringValue
    }

    init() {
        total_noti_id = -1
        total_noti_time = nil
        total_noti_text = nil
        total_noti_title = nil
    }
}
