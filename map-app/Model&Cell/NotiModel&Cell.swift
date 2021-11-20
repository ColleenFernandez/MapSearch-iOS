//
//  NotiModel&Cell.swift
//  SNKRAPP
//
//  Created by Admin on 10/7/21.
//

import Foundation
import SwiftyJSON

class NotiModel {
    var noti_id: Int!
    var noti_time: String?
    var noti_text: String?
    var location_info: LocationModel?

    init(_ json: JSON) {
        self.noti_id = json["noti_id"].intValue
        self.noti_time = json["noti_time"].stringValue
        self.noti_text = json["noti_text"].stringValue
        self.location_info = LocationModel(JSON(json["location_info"].object))
    }

    init() {
        noti_id = -1
        noti_time = ""
        noti_text = ""
        location_info = nil
    }
}

class NotiCell: UITableViewCell {
    @IBOutlet var imv_noti: UIImageView!
    @IBOutlet var lbl_noti_time: UILabel!
    @IBOutlet var lbl_noti_text: UILabel!

    func setDataSource(one: NotiModel) {
        if let url = URL(string: one.location_info?.location_image ?? "") {
            imv_noti.kf.setImage(with: url, placeholder: UIImage(named: "logo"))
        }
        lbl_noti_time.text = getDiffTimestamp(one.noti_time ?? "")
        lbl_noti_text.text = one.noti_text
    }
}
