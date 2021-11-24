//
//  FavoriteLocationListVC.swift
//  map-app
//
//  Created by Admin on 11/22/21.
//

import UIKit
import SwiftyJSON
import Firebase
import FirebaseDatabase

class FavoriteLocationListVC: BaseVC {
    
    @IBOutlet var tbl_locations: UITableView!
    var badge_count: Int = 0
    var ds_favorite_locatoin = [LocationModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tbl_locations.register(UINib(nibName: "LocationCell", bundle: nil), forCellReuseIdentifier: "LocationCell")
        tbl_locations.estimatedRowHeight = 80
    }

    func setDataSource() {
        self.ds_favorite_locatoin.removeAll()
        self.showLoadingView(vc: self)
        ApiManager.getLocations(request_type: .my_favorite_location) { success, response in
            self.hideLoadingView()
            if success {
                let dict = JSON(response as Any)
                if let location_data = dict["location_info"].arrayObject {
                    if location_data.count > 0 {
                        var num = 0
                        for one in location_data {
                            num += 1
                            self.ds_favorite_locatoin.append(LocationModel(JSON(one)))
                            if num == location_data.count {
                                self.tbl_locations.reloadData()
                            }
                        }
                    }else{
                        self.tbl_locations.reloadData()
                    }
                }
            }
        }
    }

    func setUI() {
        showNavBar()
        self.navigationItem.title = Messages.FAVORITE_LOCATION_LIST
        setDataSource()
        addBackButton()
    }
}

extension FavoriteLocationListVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ds_favorite_locatoin.count
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
        let cell = tbl_locations.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.setDataSource(one: ds_favorite_locatoin[indexPath.section])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tovc = self.createVC("LocationDetailVC") as! LocationDetailVC
        tovc.location = ds_favorite_locatoin[indexPath.section]
        self.navigationController?.pushViewController(tovc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}
