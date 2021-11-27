//
//  MyPageVC.swift
//  SNKRAPP
//
//  Created by top Dev on 30.09.2021.
//

import UIKit

class MyPageVC: BaseVC {
    @IBOutlet var tbl_setting: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavBar()
        if thisuser.isValid{
            self.tbl_setting.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Messages.MY_PAGE
        tbl_setting.register(UINib(nibName: "SettingHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: SettingHeader.reuseIdentifier)
        tbl_setting.tableFooterView = UIView(frame: .zero)
        tbl_setting.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        tbl_setting.estimatedRowHeight = 80
    }
}

extension MyPageVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if thisuser.isValid{
                let cell = tbl_setting.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
                cell.setProfile()
                return cell
            }else{
                let cell = tbl_setting.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
                cell.entity = SettingOptions.settingOption_section1[indexPath.row]
                return cell
            }
        } else {
            let cell = tbl_setting.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
            if thisuser.isValid{
                cell.entity = SettingOptions.settingOption_section2[indexPath.row]
                if indexPath.row == SettingOptions.settingOption_section2.count - 1{
                    cell.setting_lbl.textColor = .red
                }else{
                    cell.setting_lbl.textColor = .black
                }
            }else{
                cell.entity = SettingOptions.settingOption_section3[indexPath.row]
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if thisuser.isValid{
                return SettingOptions.settingOption_section2.count
            }else{
                return SettingOptions.settingOption_section3.count
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = tbl_setting.dequeueReusableHeaderFooterView(withIdentifier: "SettingHeader") as! SettingHeader
            headerView.headerTitle.text = SettingOptions.setting_section[0]
            return headerView
        } else {
            let headerView = tbl_setting.dequeueReusableHeaderFooterView(withIdentifier: "SettingHeader") as! SettingHeader
            headerView.headerTitle.text = SettingOptions.setting_section[1]
            return headerView
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if thisuser.isValid{
                return UITableView.automaticDimension
            }else{
                return 48
            }
        }else{
            return 48
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let row = indexPath.row
            switch row {
            case 0:
                if thisuser.isValid{
                    self.gotoNavPresent("MyaccountVC", fullscreen: true)
                }else{
                    self.gotoVC("LoginNav")
                }
            case 1:
                print("default")
            default:
                print("default")
            }
        } else {
            let row = indexPath.row
            switch row {
            
            case 0:
                showWebViewWithProgressBar(Constants.TERMS_LINK, title: Messages.TERMS)
            case 1:
                showWebViewWithProgressBar(Constants.PRIVACY_LINK, title: Messages.PRIVACY_KAN)
            case 2:
                gotoNavPresent("SupportVC", fullscreen: true)
            case 3:
                if thisuser.isValid{
                    let alertController = UIAlertController(title: "注意", message: "ログアウトしてもよろしいですか？", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "はい", style: .default) { (_: UIAlertAction!) in
                        thisuser.clearUserInfo()
                        self.gotoTabControllerWithIndex(0)
                    }
                    let cancelAction = UIAlertAction(title: "いいえ", style: .default) { (_: UIAlertAction!) in
                    }
                    alertController.addAction(OKAction)
                    alertController.addAction(cancelAction)
                    present(alertController, animated: true, completion: nil)
                }
            default:
                print("default")
            }
        }
    }
}
