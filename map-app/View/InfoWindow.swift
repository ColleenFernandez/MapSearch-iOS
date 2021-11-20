//
//  InfoWindow.swift
//  Queen
//
//  Created by Admin on 12/11/20.
//

import UIKit
//import Cosmos

class InfoWindow: UIView {
    
    @IBOutlet weak var imv_avatar: UIImageView!
    @IBOutlet weak var lbl_username: UILabel!
    @IBOutlet weak var lbl_location: UILabel!
    @IBOutlet weak var lbl_email: UILabel!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnShowDetail: UIButton!
    @IBOutlet weak var viewButtonContainer: UIView!
    @IBOutlet weak var btn_favorite: UIButton!
    
    @IBOutlet weak var lbl_recenttitle: UILabel!
    @IBOutlet weak var uiv_direction: UIView!
    @IBOutlet weak var btn_measure: UIButton!
    @IBOutlet weak var lbl_distance_info: UILabel!
    
    var didTappedCancel : (() -> Void)? = nil
    var didTappedShowDetail : (() -> Void)? = nil
    var didTappedFavorite : (() -> Void)? = nil
    var didTappedShowRecent: (() -> Void)? = nil
    var didTappedFinish: (() -> Void)? = nil
    var didTappedMeasure: (() -> Void)? = nil
    let cellSpacingHeight: CGFloat = 0
    
    @IBOutlet weak var lbl_post_time: UILabel!
    @IBOutlet weak var cons_h_scr: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func loadView() -> InfoWindow {
        let infoWindow = Bundle.main.loadNibNamed("InfoWindow", owner: self, options: nil)! [0] as! InfoWindow
        return infoWindow
    }
    
    func loadData(location : LocationModel)  {
        imv_avatar.kf.indicatorType = .activity
        imv_avatar.kf.setImage(with: URL(string: location.location_image ?? ""), placeholder:UIImage.init(named: "ic_logo"))
        viewButtonContainer.roundCorners([.bottomLeft, .bottomRight], radius: 10)
        lbl_location.text = location.location_address
        lbl_username.text = location.location_name
        lbl_email.text = location.location_description
        btn_favorite.setImage(location.is_location_like ? UIImage.init(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate).withTintColor(.red) : UIImage.init(systemName: "heart")?.withRenderingMode(.alwaysTemplate).withTintColor(.white), for: .normal)
        btn_favorite.tintColor = location.is_location_like ? .red : .white
        
        if let post = location.post{
            if post.count == 0{
                self.lbl_recenttitle.text = nil
                self.cons_h_scr.constant = 0
            }else{
                if let one = post.last{
                    self.lbl_recenttitle.text! = "\(one.post_title ?? "")"
                    self.lbl_post_time.text = getStrDate(one.post_time ?? "")
                }
            }
        }else{
            self.lbl_recenttitle.text = nil
            self.cons_h_scr.constant = 0
        }
        uiv_direction.isHidden = true
    }
    
    @IBAction func tappedCancel(_ sender: Any) {
        didTappedCancel?()
    }
    
    @IBAction func tappedShowDetail(_ sender: Any) {
        didTappedShowDetail?()
    }
    
    @IBAction func tapRecentPost(_ sender: Any) {
        didTappedShowRecent?()
    }
    
    @IBAction func measureBtnClicked(_ sender: Any) {
        didTappedMeasure?()
    }
    
    @IBAction func finishBtnClicked(_ sender: Any) {
        didTappedFinish?()
    }
    
    @IBAction func tapFavorite(_ sender: Any) {
        didTappedFavorite?()
        if let mapvc = gMapVC as? MapVC{
            mapvc.delegate = self
        }
    }
}

extension InfoWindow: InfoChangeDelegate{
    func updateStatus(status: Bool) {
        DispatchQueue.main.async {
            self.btn_favorite.setImage(status ? UIImage.init(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate).withTintColor(.red) : UIImage.init(systemName: "heart")?.withRenderingMode(.alwaysTemplate).withTintColor(.white), for: .normal)
            self.btn_favorite.tintColor = status ? .red : .white
        }
    }
}



