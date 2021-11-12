
//
//  LocationDetailVC.swift
//  MapApp
//
//  Created by top Dev on 14.01.2021.
//
import AVFoundation
import Kingfisher
import SwiftyJSON
import UIKit
import LSDialogViewController

class LocationDetailVC: BaseVC {
    @IBOutlet var imv_location_image: UIImageView!
    @IBOutlet var lbl_location_name: UILabel!
    @IBOutlet var lbl_location_address: UILabel!
    @IBOutlet var lbl_location_lat: UILabel!
    @IBOutlet var lbl_location_lang: UILabel!
    @IBOutlet var lbl_location_detail: UILabel!
    @IBOutlet var scr_container: UIScrollView!
    @IBOutlet var btn_favorite: UIButton!
    @IBOutlet var tbl_home: UITableView!
    @IBOutlet var cons_tbl_post: NSLayoutConstraint!
    @IBOutlet var cons_h_imv_location: NSLayoutConstraint!
    @IBOutlet weak var indc_imv_location: UIActivityIndicatorView!
    
    var location: LocationModel?
    var ds_post = [PostModel]()
    let cellSpacingHeight: CGFloat = 25
    
    override func viewDidLoad() {
        navigationItem.title = "場所の詳細"
        super.viewDidLoad()
        addBackButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLocation()
    }

    func setLocation() {
        if let one = location {
            getData(from: URL(string: one.location_image ?? "")!) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() { [weak self] in
                    if let image = UIImage(data: data){
                        let ratio = Float(image.size.height) / Float(image.size.width)
                        self!.indc_imv_location.stopAnimating()
                        self!.imv_location_image.image = image
                        self!.cons_h_imv_location.constant = (Constants.SCREEN_WIDTH - 30) * CGFloat(ratio)
                    }
                }
            }
            
            lbl_location_name.text = one.location_name
            lbl_location_address.text = one.location_address
            lbl_location_lat.text = "\(one.location_lat ?? 0)"
            lbl_location_lang.text = "\(one.location_lang ?? 0)"
            lbl_location_detail.text = one.location_description
            btn_favorite.setImage(one.is_location_like ? UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate).withTintColor(.red) : UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate).withTintColor(.white), for: .normal)
            btn_favorite.tintColor = one.is_location_like ? .red : .white
            ds_post.removeAll()
            if let posts = one.post {
                if posts.count > 0 {
                    ds_post = posts
                    tbl_home.reloadData()
                } else {
                    cons_tbl_post.constant = 0
                }
            } else {
                cons_tbl_post.constant = 0
            }
        }
    }
    
    func manageNotes(_ action: NoteActionType, notes: String, post: PostModel){
        self.showLoadingView(vc: self)
        ApiManager.manageComment(post_id: post.post_id, comment_content: notes, request_type: action) { success, response in
            self.hideLoadingView()
            post.notes = notes
        }
    }

    @IBAction func favoriteBtnClicked(_ sender: Any) {
        if let one = location {
            if one.is_location_like {
                ApiManager.manageLocationLike(location_id: one.location_id, request_type: .unlike) { success, _ in
                    if success {
                        one.is_location_like = false
                        self.btn_favorite.setImage(one.is_location_like ? UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate).withTintColor(.red) : UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate).withTintColor(.white), for: .normal)
                        self.btn_favorite.tintColor = one.is_location_like ? .red : .white
                    }
                }
            } else {
                ApiManager.manageLocationLike(location_id: one.location_id, request_type: .like) { success, _ in
                    if success {
                        one.is_location_like = true
                        self.btn_favorite.setImage(one.is_location_like ? UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate).withTintColor(.red) : UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate).withTintColor(.white), for: .normal)
                        self.btn_favorite.tintColor = one.is_location_like ? .red : .white
                    }
                }
            }
        }
    }
    
    func dismissDialog() {
        dismissDialogViewController(LSAnimationPattern.fadeInOut)
    }
}

extension LocationDetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ds_post.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbl_home.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.setDataSource(ds_post[indexPath.section])
        cell.noteAction = {() in
            let dialogViewController = NoteDialogUV(nibName: "NoteDialogUV", bundle: nil)
            dialogViewController.delegate = self
            dialogViewController.post = self.ds_post[indexPath.section]
            self.presentDialogViewController(dialogViewController, animationPattern: .fadeInOut)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}
