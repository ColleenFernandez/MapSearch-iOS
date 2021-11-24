
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
    @IBOutlet weak var lbl_location_memo: UILabel!
    @IBOutlet var scr_container: UIScrollView!
    @IBOutlet var btn_favorite: UIButton!
    @IBOutlet var tbl_home: DynamicSizeTableView!
    //@IBOutlet var cons_tbl_post: NSLayoutConstraint!
    @IBOutlet var cons_h_imv_location: NSLayoutConstraint!
    @IBOutlet weak var indc_imv_location: UIActivityIndicatorView!
    var is_last_post: Bool = false
    var location: LocationModel?
    var ds_post = [PostModel]()
    let cellSpacingHeight: CGFloat = 25
    var from_noti: Bool = false
    
    override func viewDidLoad() {
        navigationItem.title = "場所の詳細"
        super.viewDidLoad()
        addCustomBackButton()
    }
    
    func addCustomBackButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        let btn_back = UIButton(type: .custom)
        btn_back.setImage(UIImage.init(systemName: "chevron.left")!.withConfiguration(largeConfig).withRenderingMode(.alwaysTemplate).withTintColor(.black), for: .normal)
        
        btn_back.addTarget(self, action: #selector(btnCustomActionBackClicked), for: .touchUpInside)
        btn_back.imageEdgeInsets = UIEdgeInsets(top: 6.5, left: 5, bottom: 6.5, right: 5)
        btn_back.tintColor = .black
        let barButtonItemBack = UIBarButtonItem(customView: btn_back)
        self.navigationItem.leftBarButtonItem = barButtonItemBack
    }
    
    @objc func btnCustomActionBackClicked() {
        if from_noti{
            self.gotoTabControllerWithIndex(0)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
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
                        self?.indc_imv_location.stopAnimating()
                        self?.imv_location_image.image = image
                        self?.cons_h_imv_location.constant = (Constants.SCREEN_WIDTH - 30) * CGFloat(ratio)
                    }
                }
            }
            
            lbl_location_name.text = one.location_name
            lbl_location_address.text = one.location_address
            lbl_location_lat.text = "\(one.location_lat ?? 0)"
            lbl_location_lang.text = "\(one.location_lang ?? 0)"
            lbl_location_detail.text = one.location_description
            lbl_location_memo.text = one.location_memo
            btn_favorite.setImage(one.is_location_like ? UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate).withTintColor(.red) : UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate).withTintColor(.white), for: .normal)
            btn_favorite.tintColor = one.is_location_like ? .red : .white
            ds_post.removeAll()
            if let posts = one.post {
                if posts.count > 0 {
                    ds_post = posts
                    tbl_home.reloadData()
                    tbl_home.invalidateIntrinsicContentSize()
                    print("this is tableview height ===> ", tbl_home.intrinsicContentSize)
                    print("this is tableview contentsize ===> ", tbl_home.contentSize)
//                    if is_last_post{
//                        DispatchQueue.main.async {
//                            let bottomOffset = CGPoint(x: 0, y: self.scr_container.contentSize.height - self.scr_container.bounds.size.height)
//                            self.scr_container.setContentOffset(bottomOffset, animated: true)
//                            self.tbl_home.scrollToBottomRow()
//                        }
//                    }
                } else {
                    //cons_tbl_post.constant = 0
                }
            } else {
                //cons_tbl_post.constant = 0
            }
        }
    }
    
    func manageNotes(_ action: NoteActionType, memo: String, location: LocationModel){
        self.showLoadingView(vc: self)
        ApiManager.manageMemo(location_id: location.location_id, memo: memo, request_type: action) { success, response in
            self.hideLoadingView()
            self.lbl_location_memo.text = memo
            location.location_memo = memo
        }
    }
    
    @IBAction func memoBtnClicked(_ sender: Any) {
        if thisuser.isValid{
            let dialogViewController = NoteDialogUV(nibName: "NoteDialogUV", bundle: nil)
            dialogViewController.delegate = self
            dialogViewController.location = self.location
            self.presentDialogViewController(dialogViewController, animationPattern: .fadeInOut)
        }else{
            self.requireLogin()
        }
    }
    
    @IBAction func favoriteBtnClicked(_ sender: Any) {
        if thisuser.isValid{
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
        }else{
            self.requireLogin()
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

extension UITableView {
    func scrollToBottomRow() {
        DispatchQueue.main.async {
            guard self.numberOfSections > 0 else { return }

            // Make an attempt to use the bottom-most section with at least one row
            var section = max(self.numberOfSections - 1, 0)
            var row = max(self.numberOfRows(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)

            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            while !self.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(self.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)

                // If we're down to the last section, attempt to use the first row
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }

            // In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
            // exception here
            guard self.indexPathIsValid(indexPath) else { return }

            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return section < self.numberOfSections && row < self.numberOfRows(inSection: section)
    }
}

public class DynamicSizeTableView: UITableView
{
    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }

    override public var intrinsicContentSize: CGSize {
        return contentSize
    }
}
