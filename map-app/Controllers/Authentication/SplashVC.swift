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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkBackgrouond()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: {
            self.showAlertMessage(msg: Messages.NETISSUE)
        })
    }

    func checkBackgrouond(){
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
