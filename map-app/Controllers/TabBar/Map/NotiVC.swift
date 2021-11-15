//
//  NotiVC.swift
//  SNKRAPP
//
//  Created by Admin on 10/7/21.
//

import UIKit
import SwiftyJSON
import Firebase
import FirebaseDatabase

class NotiVC: BaseVC {
    
    @IBOutlet var tbl_noti: UITableView!
    var badge_count: Int = 0
    var ds_noti = [NotiModel]()
    let badgePath = Database.database().reference().child("badge").child("\(thisuser.user_id ?? 0)")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    func addCustomBackButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let btn_back = UIButton(type: .custom)
        btn_back.setImage(UIImage.init(systemName: "chevron.left")!.withConfiguration(largeConfig).withRenderingMode(.alwaysTemplate), for: .normal)
        btn_back.addTarget(self, action: #selector(addCustomBackButtonClicked), for: .touchUpInside)
        btn_back.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        btn_back.tintColor = .black
        let barButtonItemBack = UIBarButtonItem(customView: btn_back)
        self.navigationItem.leftBarButtonItem = barButtonItemBack
    }
    
    @objc func addCustomBackButtonClicked() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            self.badgePath.removeAllObservers()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addCustomBackButton()
    }

    func setDataSource() {
        self.ds_noti.removeAll()
        self.showLoadingView(vc: self)
        ApiManager.getNoti { (isSuccess, data) in
            self.hideLoadingView()
            if isSuccess{
                let json = JSON(data as Any)
                if let array = json["noti_info"].arrayObject{
                    var num = 0
                    for one in array{
                        num += 1
                        self.ds_noti.append(NotiModel(JSON(one)))
                    }
                    if num == array.count{
                        ApiManager.setNotiRead { (isSuccess, data) in
                            if isSuccess{
                                UIApplication.shared.applicationIconBadgeNumber = 0
                                self.badgePath.updateChildValues(["badge":0])
                                if self.ds_noti.count > 0{
                                }else{
                                    self.showToast("通知はありません")
                                }
                            }else{
                                self.showToast(Messages.NETISSUE)
                            }
                        }
                        self.tbl_noti.reloadData()
                    }
                }else{
                    self.tbl_noti.reloadData()
                }
            }else{
                self.showToast(Messages.NETISSUE)
            }
        }
    }

    func setUI() {
        showNavBar()
        self.navigationItem.title = Messages.NOTIFICATION
        setDataSource()
    }
}

extension NotiVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ds_noti.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbl_noti.dequeueReusableCell(withIdentifier: "NotiCell", for: indexPath) as! NotiCell
        cell.setDataSource(one: ds_noti[indexPath.section])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

