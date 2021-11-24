//
//  BaseVC.swift
//  SNKRAPP
//
//  Created by top Dev on 9/20/20.
//

import UIKit
import Toast_Swift
import SwiftyUserDefaults
import SwiftyJSON
import MBProgressHUD
import Foundation


class BaseVC: UIViewController {

    var hud: MBProgressHUD?
    var alertController : UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !(self.hud?.isHidden ?? false){
            self.hideLoadingView()
        }
    }
    
    func setEdtPlaceholder(_ edittextfield : UITextField , placeholderText : String, placeColor : UIColor, padding: UITextField.PaddingSide)  {
        edittextfield.attributedPlaceholder = NSAttributedString(string: placeholderText,
        attributes: [NSAttributedString.Key.foregroundColor: placeColor])
        edittextfield.addPadding(padding)
    }
    
    func showNavBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func hideNavBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // for general part for common project
    func gotoVC(_ nameVC: String, animated: Bool = true){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let toVC = storyBoard.instantiateViewController( withIdentifier: nameVC)
        toVC.modalPresentationStyle = .fullScreen
        self.present(toVC, animated: animated, completion: nil)
    }
    
    func showProgressHUDHUD(view : UIView, mode: MBProgressHUDMode = .annularDeterminate) -> MBProgressHUD {
        let hud = MBProgressHUD .showAdded(to:view, animated: true)
        hud.mode = mode
        hud.label.text = "Loading";
        hud.animationType = .zoomIn
        hud.contentColor = .white
        return hud
    }
    
    func hideLoadingView() {
       if let hud = hud {
           hud.hide(animated: true)
       }
    }
    
    func showLoadingView(vc: UIViewController, label: String = "") {
        hud = MBProgressHUD .showAdded(to: vc.view, animated: true)
        if label != "" {
            hud!.label.text = label
        }
        hud!.mode = .indeterminate
        hud!.animationType = .zoomIn
        hud!.bezelView.color = .clear
        hud!.contentColor = .black
        hud!.bezelView.style = .solidColor
    }
    
    //MARK:- Toast function
    func showToast(_ message : String) {
        self.view.makeToast(message)
    }
    
    func showToast(_ message : String, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = .bottom) {
        self.view.makeToast(message, duration: duration, position: position)
    }
    
    func showToastCenter(_ message : String, duration: TimeInterval = ToastManager.shared.duration) {
        showToast(message, duration: duration, position: .center)
    }
    
    func gotoNavPresent(_ storyname : String, fullscreen: Bool) {
        let toVC = self.storyboard?.instantiateViewController(withIdentifier: storyname)
        if fullscreen{
            toVC?.modalPresentationStyle = .fullScreen
        }else{
            toVC?.modalPresentationStyle = .pageSheet
        }
        self.navigationController?.pushViewController(toVC!, animated: true)
    }
    
    // MARK: UIAlertView Controller
    func showAlertMessage(title: String? = nil, msg : String){
        alertController = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alertController!.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController!, animated: true, completion: nil)
    }
    
    func createVC(_ controller_name: String, storyboard_name: String = "Main", is_fullscreen: Bool = true) -> UIViewController {
        let storyBoard : UIStoryboard = UIStoryboard(name: storyboard_name, bundle: nil)
        let toVC = storyBoard.instantiateViewController(withIdentifier: controller_name)
        if is_fullscreen{
            toVC.modalPresentationStyle = .fullScreen
        }else{
            toVC.modalPresentationStyle = .pageSheet
        }
        return toVC
    }
    
    func gotoTabControllerWithIndex(_ index: Int) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let toVC = storyBoard.instantiateViewController( withIdentifier: "TabBarVC") as! UITabBarController
        toVC.selectedIndex = index
        toVC.modalPresentationStyle = .fullScreen
        self.present(toVC, animated: false, completion: nil)
    }
    
    func addBackButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        let btn_back = UIButton(type: .custom)
        btn_back.setImage(UIImage.init(systemName: "chevron.left")!.withConfiguration(largeConfig).withRenderingMode(.alwaysTemplate).withTintColor(.black), for: .normal)
        
        btn_back.addTarget(self, action: #selector(btnActionBackClicked), for: .touchUpInside)
        btn_back.imageEdgeInsets = UIEdgeInsets(top: 6.5, left: 5, bottom: 6.5, right: 5)
        btn_back.tintColor = .black
        let barButtonItemBack = UIBarButtonItem(customView: btn_back)
        self.navigationItem.leftBarButtonItem = barButtonItemBack
    }
    
    @objc func btnActionBackClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func presentWebViewWithProgressBar(_ link: String, title: String = "")  {
        let browser = KAWebBrowser()
        browser.str_title = title
        present(browser, animated: true, completion: nil)
        browser.loadURLString(link)
    }
    
    func showWebViewWithProgressBar(_ link: String, title: String = "")  {
        let browser = KAWebBrowser()
        browser.str_title = title
        show(browser, sender: nil)
        browser.loadURLString(link)
    }
    
    func requireLogin(){
        let alertController = UIAlertController(title: "サインインが必要", message: "このアクションを実行するには、サインインする必要があります。", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "いいえ", style: .default) { (_: UIAlertAction!) in
            
        }
        let OKAction = UIAlertAction(title: "はい", style: .default) { (_: UIAlertAction!) in
            self.gotoVC("LoginNav")
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
