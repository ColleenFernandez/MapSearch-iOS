
//
//  ForgotPwdVC.swift
//  SNKRAPP
//
//  Created by Mac on 6/29/20.
//  Copyright © 2020 Ubuntu. All rights reserved.
//
import Foundation
import UIKit
import IQKeyboardManagerSwift
import SwiftyJSON
import SwiftyUserDefaults
import KAPinField

class ForgotVC: BaseVC {

    @IBOutlet weak var otpCodeView: KAPinField!
    @IBOutlet weak var edt_email: UITextField!
    //@IBOutlet weak var edt_userName: UITextField!
    @IBOutlet weak var btn_submit: UIButton!
    //var verificationID = ""
    @IBOutlet weak var uiv_dlg: UIView!
    @IBOutlet weak var uiv_dlgBack: UIView!
    
    @IBOutlet weak var edt_newPwd: UITextField!
    @IBOutlet weak var confirmPwd: UITextField!
    
    var pincode = ""
    var email = ""
                 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStyle()
        self.setDlg()
        //self.edt_email.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavBar()
        self.title = Messages.RESET_PASSWORD
        addBackButton()
    }
    
    func setDlg()  {
        self.uiv_dlgBack.isHidden = true
        self.uiv_dlg.isHidden = true
        self.edt_newPwd.text = ""
        self.confirmPwd.text = ""
    }
    
    @IBAction func gotoSend(_ sender: Any) {
        //self.username = self.edt_userName.text!
        self.email = self.edt_email.text!
        if email.isEmpty{
            self.showToast("ピンコードを受け取るには、メールアドレスを入力してください。")
            return
        }
        
        if !(email.isValidEmail()){
            self.showToast("無効なメール")
            //self.progShowInfo(true, msg: "Invalid phone number")
            return
        }
        else{
            self.showLoadingView(vc: self)
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.hideLoadingView()
                self.edt_email.text = ""
                self.pincode = "123456"
                print(self.pincode)
                self.refreshPinField()
                self.sendOTP()
            }*/
            ApiManager.forgot(email: self.email ) { (isSuccess, data) in
                self.hideLoadingView()
                self.edt_email.text = ""
                if isSuccess{
                    self.pincode = data as! String
                    print(self.pincode)
                    self.refreshPinField()
                    self.sendOTP()
                }else{
                    self.showAlertMessage(msg: Messages.USER_EMAIL_NOT_EXIST)// username not exist
                    //メールが存在しません。
                }
            }
        }
    }
    
    @IBAction func sendNewPwd(_ sender: Any) {
        let newPwd = self.edt_newPwd.text
        let confirmPwd = self.confirmPwd.text
        if newPwd == "" || confirmPwd == ""{
            self.showAlertMessage(msg: "パスワードを入力してください。")
            return
        }
        if confirmPwd != newPwd{
            self.showAlertMessage(msg: "あなたのパスワードを確認。")
            return
        }else{
            self.showLoadingView(vc: self)
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.uiv_dlgBack.isHidden = true
                self.uiv_dlg.isHidden = true
                self.edt_newPwd.text = ""
                self.confirmPwd.text = ""
                print("success")
                //self.navigationController?.popViewController(animated: true)
                //self.showAlerMessage(message: "更新に成功。")
                let alertController = UIAlertController(title: nil, message:"更新に成功。", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(action1)
                self.present(alertController, animated: true, completion: nil)
            }*/
            ApiManager.resetPassword(email: self.email, password: newPwd ?? "") { (isSuccess, data) in
                self.hideLoadingView()
                if isSuccess{
                    self.uiv_dlgBack.isHidden = true
                    self.uiv_dlg.isHidden = true
                    self.edt_newPwd.text = ""
                    self.confirmPwd.text = ""
                    print("success")
                    UserDefault.setString(key: PARAMS.PASSWORD, value: newPwd)
                    UserDefault.Sync()
                    thisuser.loadUserInfo()
                    thisuser.saveUserInfo()
                    
                    //self.navigationController?.popViewController(animated: true)
                    //self.showAlerMessage(message: "更新に成功。")
                    let alertController = UIAlertController(title: nil, message:"更新に成功。", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alertController.addAction(action1)
                    self.present(alertController, animated: true, completion: nil)
                }else{
                    print("network problem.")
                    self.showAlertMessage(msg: Messages.NETISSUE)
                    self.uiv_dlgBack.isHidden = true
                    self.uiv_dlg.isHidden = true
                    self.edt_newPwd.text = ""
                    self.confirmPwd.text = ""
                }
            }
        }
    }
    
    @IBAction func cancelPwd(_ sender: Any) {
        self.uiv_dlgBack.isHidden = true
        self.uiv_dlg.isHidden = true
        self.edt_newPwd.text = ""
        self.confirmPwd.text = ""
    }
    
    @IBAction func backtoLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func sendOTP()  {
        if self.btn_submit.currentTitle == Messages.SENT{
            print("input pincode.")
            self.otpCodeView.becomeFirstResponder()
            self.showAlertMessage(msg: "PINコードをメールでお送りしました。メールボックスをご確認ください。")
            //self.showAlerMessage(message: "Please input your verification code.")
            self.btn_submit.setTitle("再送", for: .normal)
            self.dismissKeyboard()
            
        }else{
            refreshPinField()
            self.email = self.edt_email.text!
            if !(email.isValidEmail()){
                self.showToast("無効なメール")
                //self.progShowInfo(true, msg: "Invalid phone number")
                return
            }else if self.email != ""{
                self.showLoadingView(vc: self)
                /*DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.hideLoadingView()
                    self.edt_email.text = ""
                    self.pincode = "123456"
                    self.sendOTP()
                }*/
                ApiManager.forgot(email: email) { (isSuccess, data) in
                    self.hideLoadingView()
                    self.edt_email.text = ""
                    if isSuccess{
                        self.pincode = data as! String
                        self.sendOTP()
                    }else{
                        self.showAlertMessage(msg: "メールが存在しません。")
                        //メールが存在しません。
                    }
                }
            }
            self.dismissKeyboard()
        }
    }
    
    func setStyle() {
        otpCodeView.properties.delegate = self
//        otpCodeView.properties.token = "-"
        otpCodeView.properties.animateFocus = true
        otpCodeView.text = ""
        otpCodeView.keyboardType = .numberPad
        otpCodeView.properties.numberOfCharacters = 6
        otpCodeView.appearance.tokenColor = UIColor.black.withAlphaComponent(0.2)
        otpCodeView.appearance.tokenFocusColor = UIColor.black.withAlphaComponent(0.2)
        otpCodeView.appearance.textColor = UIColor.black
        otpCodeView.appearance.font = .menlo(40)
        otpCodeView.appearance.kerning = 24
        otpCodeView.appearance.backOffset = 5
        otpCodeView.appearance.backColor = UIColor.clear
        otpCodeView.appearance.backBorderWidth = 1
        otpCodeView.appearance.backBorderColor = UIColor.black.withAlphaComponent(0.2)
        otpCodeView.appearance.backCornerRadius = 4
        otpCodeView.appearance.backFocusColor = UIColor.clear
        otpCodeView.appearance.backBorderFocusColor = UIColor.black.withAlphaComponent(0.8)
        otpCodeView.appearance.backActiveColor = UIColor.clear
        otpCodeView.appearance.backBorderActiveColor = UIColor.black
        otpCodeView.appearance.backRounded = false
        
    }
    
     func refreshPinField() {
        otpCodeView.text = ""
        setStyle()
    }
}

extension ForgotVC : KAPinFieldDelegate {
    
    func pinField(_ field: KAPinField, didChangeTo string: String, isValid: Bool) {
        if isValid {
            print("Valid input: \(string) ")
        } else {
            print("Invalid input: \(string) ")
            self.otpCodeView.animateFailure()
        }
    }
    
    func pinField(_ field: KAPinField, didFinishWith code: String) {
        print("didFinishWith : \(code)")
        if self.pincode == code{
            field.animateSuccess(with: "👍") {
                print("OK")
                self.uiv_dlg.isHidden = false
                self.uiv_dlgBack.isHidden = false
            }
        }else{
            self.showAlertMessage(msg: "PINコードが正しくありません。")
            field.animateFailure()
            self.otpCodeView.becomeFirstResponder()
            return
        }
    }
}

