//
//  TotalNotiDetailVC.swift
//  map-app
//
//  Created by Admin on 11/25/21.
//

import AVFoundation
import Kingfisher
import SwiftyJSON
import UIKit
import LSDialogViewController

class TotalNotiDetailVC: BaseVC {
    
    @IBOutlet var tbl_home: UITableView!
    var selected_section: Int?
    var ds_total_noti = [TotalNotiModel]()
    let cellSpacingHeight: CGFloat = 25
    var from_noti: Bool = false
    
    override func viewDidLoad() {
        navigationItem.title = "全体通知の詳細一覧"
        super.viewDidLoad()
        tbl_home.estimatedRowHeight = 40
        addCustomBackButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.ds_total_noti.count > 0{
            let ids = self.ds_total_noti.map{ "\($0.total_noti_id ?? 0)" }
            ApiManager.setTotalNotiRead(ids: ids.joined(separator: ",")) { _ , _  in
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected_section = selected_section {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.tbl_home.scrollToRow(at: IndexPath(row: 0, section: selected_section), at: .top, animated: true)
            }
        }
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
}

extension TotalNotiDetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ds_total_noti.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbl_home.dequeueReusableCell(withIdentifier: "TotalNotiDetailCell", for: indexPath) as! TotalNotiDetailCell
        cell.setDataSource(ds_total_noti[indexPath.section])
        cell.referUrlAction = {() in
            if let str = self.ds_total_noti[indexPath.section].noti_refer_url, !str.isEmpty{
                self.showWebViewWithProgressBar(str, title: self.ds_total_noti[indexPath.section].total_noti_title ?? "参照URL")
            }
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
