//
//  TotalNotiDetailCell.swift
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

class TotalNotiDetailCell: UITableViewCell{
    @IBOutlet weak var imv_total_noti: UIImageView!
    @IBOutlet weak var cons_h_imv: NSLayoutConstraint!
    @IBOutlet weak var lbl_noti_text: UILabel!
    @IBOutlet weak var lbl_noti_title: UILabel!
    @IBOutlet weak var indc_imv_post: UIActivityIndicatorView!
    @IBOutlet weak var lbl_noti_time: UILabel!
    @IBOutlet weak var lbl_refer_url: UILabel!
    
    var referUrlAction: (() -> ())?
    
    
    func setDataSource(_ one: TotalNotiModel!) {
        lbl_noti_title.text = one.total_noti_title
        imv_total_noti.kf.indicatorType = .activity
        imv_total_noti.kf.setImage(with: URL(string: one.total_noti_image ?? ""), placeholder: UIImage.init(named: "ic_logo"))
        lbl_noti_text.text = one.total_noti_text
        cons_h_imv.constant = (Constants.SCREEN_WIDTH - 30) * CGFloat(one.media_ratio)
        lbl_noti_time.text = getStrDate(one.total_noti_time ?? "")
        lbl_refer_url.text = one.noti_refer_url
        lbl_refer_url.addTapGesture(tapNumber: 1, target: self, action: #selector(onClickUrl))
    }
    
    @objc func onClickUrl(gesture: UITapGestureRecognizer) -> Void {
        self.referUrlAction?()
    }
}



