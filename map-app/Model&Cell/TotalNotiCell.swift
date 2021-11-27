//
//  TotalNotiCell.swift
//  map-app
//
//  Created by Admin on 11/23/21.
//

import UIKit

class TotalNotiCell: UITableViewCell {
    
    @IBOutlet var lbl_noti_title: UILabel!
    @IBOutlet var lbl_noti_time: UILabel!
    
    
    func setDataSource(one: TotalNotiModel) {
        lbl_noti_title.text = one.total_noti_title
        lbl_noti_time.text = getDiffTimestamp(one.total_noti_time ?? "")
        
    }
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
