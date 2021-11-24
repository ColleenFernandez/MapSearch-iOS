//
//  LocationCell.swift
//  map-app
//
//  Created by Admin on 11/22/21.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet var imv_location: UIImageView!
    @IBOutlet var lbl_loction_name: UILabel!
    @IBOutlet var lbl_location_address: UILabel!

    func setDataSource(one: LocationModel) {
        if let url = URL(string: one.location_image ?? "") {
            imv_location.kf.setImage(with: url, placeholder: UIImage(named: "logo"))
        }
        lbl_loction_name.text = one.location_name
        lbl_location_address.text = one.location_address
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
