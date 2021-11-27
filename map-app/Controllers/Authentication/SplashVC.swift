//
//  SplashVC.swift
//  SNKRAPP
//
//  Created by Ubuntu on 12/10/19.
//  Copyright © 2021 Admin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Foundation
import _SwiftUIKitOverlayShims


class SplashVC: BaseVC {

    var from_noti: Bool = false
    
    var location: LocationModel?
    var total_noti: [TotalNotiModel]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTopColor()
        hideNavBar()
        checkBackgrouond()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: {
            //self.showAlertMessage(msg: Messages.NETISSUE)
        })
    }
    
    func setNavigationTopColor(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.init(named: "color_primary")
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
    }

    func checkBackgrouond(){
        if thisuser.isValid && self.from_noti{
            if let location = self.location{
                let tovc = self.createVC("LocationDetailVC") as! LocationDetailVC
                tovc.location = location
                tovc.from_noti = true
                self.showNavBar()
                self.navigationController?.pushViewController(tovc, animated: true)
            }
            if self.from_noti{
                if let total_noti = total_noti {
                    let tovc = self.createVC("TotalNotiDetailVC") as! TotalNotiDetailVC
                    tovc.ds_total_noti = total_noti
                    tovc.from_noti = true
                    self.showNavBar()
                    self.navigationController?.pushViewController(tovc, animated: true)
                }
            }
        }else{
            if self.from_noti{
                if let total_noti = total_noti {
                    let tovc = self.createVC("TotalNotiDetailVC") as! TotalNotiDetailVC
                    tovc.ds_total_noti = total_noti
                    tovc.from_noti = true
                    self.showNavBar()
                    self.navigationController?.pushViewController(tovc, animated: true)
                }
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    if thisuser.isValid{
                        self.showLoadingView(vc: self)
                        ApiManager.signin(email: thisuser.user_email ?? "", password: thisuser.password ?? "") { success, response in
                            self.hideLoadingView()
                            self.gotoVC("TabBarVC")
                        }
                    }else{
                        self.showLoadingView(vc: self)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.hideLoadingView()
                            self.gotoVC("TabBarVC")
                        }
                    }
                })
            }
        }
    }
}
