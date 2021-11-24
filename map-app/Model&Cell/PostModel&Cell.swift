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

class PostModel {
    var post_id : Int!
    var location_id : Int!
    var post_content: String?
    var post_time: String?
    var post_des: String?
    var post_title: String?
    var media_ratio: Float
    var notes: String?
    
    init() {
        self.post_id = 0
        self.location_id = 0
        self.post_time = nil
        self.post_content = nil
        self.post_des = nil
        self.post_title = nil
        self.notes = nil
        self.media_ratio = 1
    }
    
    init(_ one: JSON){
        self.post_id = one[PARAMS.POST_ID].intValue
        self.location_id = one[PARAMS.LOCATION_ID].intValue
        self.post_time = one[PARAMS.POST_TIME].stringValue
        self.post_content = one[PARAMS.POST_CONTENT].stringValue
        self.post_title = one["post_title"].stringValue
        self.post_des = one[PARAMS.POST_DES].stringValue
        self.media_ratio = one[PARAMS.MEDIA_RATIO].floatValue
        let notes_object = one["comment"].object
        self.notes = JSON(notes_object as Any)["comment_content"].stringValue
    }
}

class PostCell: UITableViewCell{
    @IBOutlet weak var imv_post: UIImageView!
    @IBOutlet weak var cons_h_imv: NSLayoutConstraint!
    @IBOutlet weak var lbl_post_des: UILabel!
    @IBOutlet weak var lbl_post_title: UILabel!
    @IBOutlet weak var indc_imv_post: UIActivityIndicatorView!
    @IBOutlet weak var lbl_post_time: UILabel!
    
    var noteAction: (() -> ())?
    func setDataSource(_ one: PostModel!) {
        lbl_post_title.text = one.post_title
        imv_post.kf.indicatorType = .activity
        imv_post.kf.setImage(with: URL(string: one.post_content ?? ""), placeholder: UIImage.init(named: "ic_logo"))
        lbl_post_des.text = one.post_des
        cons_h_imv.constant = (Constants.SCREEN_WIDTH - 30) * CGFloat(one.media_ratio)
        lbl_post_time.text = getStrDate(one.post_time ?? "")
        /*getData(from: URL(string: one.post_content ?? "")!) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                if let image = UIImage(data: data){
                    let ratio = Float(image.size.height) / Float(image.size.width)
                    self!.cons_h_imv.constant = (Constants.SCREEN_WIDTH - 30) / CGFloat(ratio)
                }
            }
        }*/
    }
    
    @IBAction func noteBtnClicked(_ sender: Any) {
        self.noteAction?()
    }
}



