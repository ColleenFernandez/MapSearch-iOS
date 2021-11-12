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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Messages.MY_PAGE
        tbl_setting.register(UINib(nibName: "SettingHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: SettingHeader.reuseIdentifier)
        tbl_setting.tableFooterView = UIView(frame: .zero)
    }
}

extension MyPageVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tbl_setting.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
            cell.entity = SettingOptions.settingOption_section1[indexPath.row]
            return cell
        } else {
            let cell = tbl_setting.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
            cell.entity = SettingOptions.settingOption_section2[indexPath.row]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return SettingOptions.settingOption_section1.count
        } else {
            return SettingOptions.settingOption_section2.count
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
        return 48
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let row = indexPath.row
            switch row {
            case 0:
                if thisuser.isValid{
                    self.gotoNavPresent("MyaccountVC", fullscreen: true)
                }
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
                        self.gotoVC("LoginNav")
                    }
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (_: UIAlertAction!) in
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
