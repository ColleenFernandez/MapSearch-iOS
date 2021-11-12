//
//  LoginVC.swift
//  EveraveUpdate
//
//  Created by Ubuntu on 12/10/19.
//  Copyright © 2019 Ubuntu. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import SwiftyJSON
import SwiftyUserDefaults

class LoginVC: BaseVC,UINavigationControllerDelegate {
    
    @IBOutlet weak var lbl_signin: UILabel!
    @IBOutlet weak var signBtnView: UIView!
    @IBOutlet weak var edt_email: UITextField!
    @IBOutlet weak var edtPwd: UITextField!
    var email = ""
    var password = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        editInit()
        loadLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hideNavBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func closeBtnClicked(_ sender: Any) {
        self.gotoVC("TabBarVC", animated: true)
    }
    
    
    func editInit() {
        setEdtPlaceholder(edt_email, placeholderText: Messages.EMAIL, placeColor: UIColor.lightGray, padding: .left(55))
        setEdtPlaceholder(edtPwd, placeholderText: Messages.PASSWORD, placeColor: UIColor.lightGray, padding: .left(55))
    }
    
    func loadLayout() {
        self.hideKeyboardWhenTappedAround()
        lbl_signin.text = Messages.SIGNIN
        //edt_email.text = "hikari@gmail.com"
        //edtPwd.text = "123"
    }
    
    func setDummy() {
        
    }
    
    @IBAction func signInBtnClicked(_ sender: Any) {
        email = self.edt_email.text ?? ""
        password = self.edtPwd.text ?? ""
        if email.isEmpty{
            self.showToast(Messages.EMAIL_REQUIRE)
            return
        }
        if !email.isValidEmail(){
            self.showToast(Messages.VALID_EMAIL_REQUIRE)
            return
        }
        
        if password.isEmpty{
            self.showToast(Messages.PASSWORD_REQUIRE)
            return
        }
        else{
            self.showLoadingView(vc: self)
            ApiManager.signin(email: self.email, password: self.password) { (isSuccess, msg) in
                self.hideLoadingView()
                let statues = msg as? Int
                if isSuccess{
                    self.gotoTabControllerWithIndex(0)
                }else if statues == 201{
                    self.showAlertMessage(msg: Messages.USERNAME_NONE_EXIST)
                }else if statues == 202{
                    self.showAlertMessage(msg: Messages.PASSWORD_INCORRECT)
                }else {
                    self.showAlertMessage(msg: Messages.NETISSUE)
                }
            }
        }
    }
   
    @IBAction func gotoSignUp(_ sender: Any) {
        gotoNavPresent("SignUpVC",fullscreen: true)
        //self.gotoVC("SignUPVC")
    }
    
    @IBAction func gotoForgot(_ sender: Any) {
        self.gotoNavPresent("ForgotVC", fullscreen: true)
    }
}

extension LoginVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        email = self.edt_email.text ?? ""
        password = self.edtPwd.text ?? ""
        if email.isEmpty{
            self.showToast(Messages.EMAIL_REQUIRE)
            return true
        }
        if !email.isValidEmail(){
            self.showToast(Messages.VALID_EMAIL_REQUIRE)
            return true
        }
        
        if password.isEmpty{
            self.showToast(Messages.PASSWORD_REQUIRE)
            return true
        }
        else{
            self.showLoadingView(vc: self)
            ApiManager.signin(email: self.email, password: self.password) { (isSuccess, msg) in
                self.hideLoadingView()
                let statues = msg as? Int
                if isSuccess{
                    UserDefault.setBool(key: PARAMS.LOGOUT, value: false)
                    self.gotoTabControllerWithIndex(0)
                }else if statues == 201{
                    self.showAlertMessage(msg: Messages.USERNAME_NONE_EXIST)
                }else if statues == 202{
                    self.showAlertMessage(msg: Messages.PASSWORD_INCORRECT)
                }else {
                    self.showAlertMessage(msg: Messages.NETISSUE)
                }
            }
            return false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        textField.isSecureTextEntry = false
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        textField.isSecureTextEntry = true
        return false
    }
}
