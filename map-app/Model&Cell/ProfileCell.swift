//
//  ProfileCell.swift
//  map-app
//
//  Created by Admin on 11/23/21.
//

import UIKit
import Kingfisher

class ProfileCell: UITableViewCell {
    @IBOutlet var imv_profile: UIImageView!
    @IBOutlet var lbl_username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setProfile() {
        if thisuser.isValid{
            self.imv_profile.kf.indicatorType = .activity
            self.imv_profile.kf.setImage(with: URL(string: thisuser.user_photo ?? ""), placeholder: UIImage.init(named: "ic_user"))
            self.lbl_username.text = thisuser.user_name
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
