//
//  SettingModel.swift
//  SNKRAPP
//
//  Created by Ubuntu on 12/18/19.
//  Copyright © 2019 Ubuntu. All rights reserved.
//

import Foundation
import UIKit

class SettingCell: UITableViewCell {
    @IBOutlet var setting_lbl: UILabel!

    var entity: String! {
        didSet {
            setting_lbl.text = entity
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
