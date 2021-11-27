//
//  TotalNotiVC.swift
//  map-app
//
//  Created by Admin on 11/23/21.
//

import UIKit
import SwiftyJSON
import Firebase
import FirebaseDatabase

class TotalNotiVC: BaseVC {
    
    @IBOutlet var tbl_total_noti: UITableView!
    var badge_count: Int = 0
    var ds_total_noti = [TotalNotiModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tbl_total_noti.register(UINib(nibName: "TotalNotiCell", bundle: nil), forCellReuseIdentifier: "TotalNotiCell")
        tbl_total_noti.estimatedRowHeight = 80
        if self.ds_total_noti.count > 0{
            let ids = self.ds_total_noti.map{ "\($0.total_noti_id ?? 0)" }
            ApiManager.setTotalNotiRead(ids: ids.joined(separator: ",")) { _ , _  in
                
            }
        }
    }

    func setUI() {
        showNavBar()
        self.navigationItem.title = Messages.TOTAL_NOTI
        addBackButton()
    }
}

extension TotalNotiVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ds_total_noti.count
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
        let cell = tbl_total_noti.dequeueReusableCell(withIdentifier: "TotalNotiCell", for: indexPath) as! TotalNotiCell
        cell.setDataSource(one: ds_total_noti[indexPath.section])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tovc = self.createVC("TotalNotiDetailVC") as! TotalNotiDetailVC
        tovc.ds_total_noti = self.ds_total_noti
        tovc.selected_section = indexPath.section
        self.navigationController?.pushViewController(tovc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

