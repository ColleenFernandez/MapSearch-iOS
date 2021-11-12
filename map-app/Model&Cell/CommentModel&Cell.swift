//
//  CommentModel.swift
//  Chikakunoko
//
//  Created by top Dev on 13.01.2021.
//

import Foundation
import SwiftyJSON

class CommentModel {
    var usermodel: UserModel
    var comment_time: String?
    var comment_text: String?

    init(usermodel: UserModel, comment_time: String, comment_text: String) {
        self.usermodel = usermodel
        self.comment_time = comment_time
        self.comment_text = comment_text
    }

    init(_ json: JSON) {
        usermodel = UserModel(json1: json)
        comment_time = json[PARAMS.COMMENT_TIME].stringValue
        comment_text = json[PARAMS.COMMENT_CONTENT].stringValue
    }

    init(comment: Dictionary<String, Any>) {
        comment_time = comment[PARAMS.COMMENT_TIME] as? String
        comment_text = comment[PARAMS.COMMENT_CONTENT] as? String
        usermodel = UserModel(comment: comment)
    }

    init() {
        usermodel = UserModel()
        comment_time = ""
        comment_text = ""
    }
}

class CommentCell: UITableViewCell {
    @IBOutlet var imv_partner: UIImageView!
    @IBOutlet var lbl_comment_time: UILabel!
    @IBOutlet var lbl_comment_text: UILabel!
    @IBOutlet var lbl_user_name: UILabel!

    func setDataSource(one: CommentModel) {
        if let url = URL(string: one.usermodel.user_photo ?? "") {
            imv_partner.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
        }
        lbl_user_name.text = one.usermodel.user_name
        lbl_comment_time.text = getStrDateVariousTimeFormat(one.comment_time ?? "\(Int(NSDate().timeIntervalSince1970))")
        // self.lbl_comment_time.font = self.lbl_comment_time.font.italic
        lbl_comment_text.text = one.comment_text
    }
}
