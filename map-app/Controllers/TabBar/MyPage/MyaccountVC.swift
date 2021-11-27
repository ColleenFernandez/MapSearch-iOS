//
//  SignUpVC.swift
//  EveraveUpdate
//
//  Created by Mac on 5/9/20.
//  Copyright © 2020 Ubuntu. All rights reserved.
//


import Foundation
import UIKit
import IQKeyboardManagerSwift
import SwiftyJSON
import SwiftyUserDefaults
import Photos
import GDCheckbox
import Kingfisher

class MyaccountVC: BaseVC {
    
    @IBOutlet weak var edtusername: UITextField!
    @IBOutlet weak var edt_email: UITextField!
    @IBOutlet weak var edtpassword: UITextField!
    @IBOutlet weak var imv_avatar: UIImageView!
    @IBOutlet weak var uiv_camera: UIView!
    @IBOutlet weak var lbl_username: UILabel!
    @IBOutlet weak var txv_selfintro: UITextView!
    @IBOutlet var uiv_back: UIView!
    @IBOutlet var uiv_modal: UIView!

    @IBOutlet var edt_currentpwd: UITextField!
    @IBOutlet var edt_newpwd: UITextField!
    @IBOutlet var edt_confirmpwd: UITextField!
    
    var usertName = ""
    var useremail = ""
    var password = ""
    var confirmpassword = ""
    var first_number = ""
    var last_number = ""
    var user_des = ""
    var imagePicker: ImagePicker!
    var attachments = [(Data, String, String, String)]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Messages.EDIT_PROFILE
        showNavBar()
        addBackButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editInit()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self, is_cropping: true)
    }
    
    func editInit() {
        setEdtPlaceholder(edtusername, placeholderText: Messages.USERNAME, placeColor: UIColor.lightGray, padding: .left(55))
        setEdtPlaceholder(edt_email, placeholderText: Messages.EMAIL, placeColor: UIColor.lightGray, padding: .left(55))
        setEdtPlaceholder(edtpassword, placeholderText: Messages.PASSWORD, placeColor: UIColor.lightGray, padding: .left(55))
        
        setChangePwd(false)
        lbl_username.text = thisuser.user_name
        imv_avatar.kf.indicatorType = .activity
        imv_avatar.kf.setImage(with: URL(string: thisuser.user_photo ?? ""), placeholder: UIImage.init(named: "ic_user"))
        edtusername.text = thisuser.user_name
        txv_selfintro.text = thisuser.user_description
        edtpassword.isSecureTextEntry = true
        edt_email.text = thisuser.user_email
        edtpassword.text = thisuser.password
        
    }
    
    @IBAction func gotoCamera(_ sender: Any) {
        self.imagePicker.present(from: view)
    }
    
    func gotoUploadProfile(_ image: UIImage?) {
        self.attachments.removeAll()
        if let image = image{
            attachments.append((image.jpegData(compressionQuality: 0.3)!, "user_photo", "image.png", "image/png"))
            self.imv_avatar.image = image
        }
    }
    
    @IBAction func btnBackModelClicked(_ sender: Any) {
        edt_currentpwd.text = nil
        edt_newpwd.text = nil
        edt_confirmpwd.text = nil
        setChangePwd(false)
    }
    
    @IBAction func updateBtnClicked(_ sender: Any) {
        usertName = self.edtusername.text ?? ""
        useremail = self.edt_email.text ?? ""
        password = self.edtpassword.text ?? ""
        user_des = self.txv_selfintro.text ?? ""
        
        if usertName.isEmpty{
            self.showToast(Messages.USERNAME_REQUIRE)
            return
        }
        
        if useremail.isEmpty{
            self.showToast(Messages.EMAIL_REQUIRE)
            return
        }
        if !useremail.isValidEmail(){
            self.showToast(Messages.VALID_EMAIL_REQUIRE)
            return
        }
        if password.isEmpty{
            self.showToast(Messages.PASSWORD_REQUIRE)
            return
        }
        else{
            self.showLoadingView(vc: self)
            ApiManager.editProfile(user_name: usertName, email: useremail, user_des: user_des, password: password, attachments:attachments) { success, response in
                self.hideLoadingView()
                if success{
                    self.navigationController?.popViewController(animated: true)
                }else{
                    if let data = response{
                        let statue = data  as! Int
                        if statue == 202{
                            self.showAlertMessage(msg: Messages.IMAGE_UPLOAD_FAIL)
                        }else {
                            self.showAlertMessage(msg: Messages.NETISSUE)
                        }
                        
                    }else{
                        self.showAlertMessage(msg: Messages.NETISSUE)
                    }
                }
            }
        }
    }
    
    func setChangePwd(_ isShow: Bool) {
        uiv_modal.isHidden = !isShow
        uiv_back.isHidden = !isShow
        if isShow {
            setEdtPlaceholder(edt_currentpwd, placeholderText: Messages.CURRENT_PWD, placeColor: UIColor.lightGray, padding: .left(20))
            setEdtPlaceholder(edt_newpwd, placeholderText: Messages.NEW_PWD, placeColor: UIColor.lightGray, padding: .left(20))
            setEdtPlaceholder(edt_confirmpwd, placeholderText: Messages.NEW_PWD_CONFIRM, placeColor: UIColor.lightGray, padding: .left(20))
        } else {
            
        }
    }
    
    @IBAction func changeBtnClicked(_ sender: Any) {
        let currentpwd = edt_currentpwd.text
        let newpwd = edt_newpwd.text
        let confirmpwd = edt_confirmpwd.text

        if currentpwd != thisuser.password {
            showToast(Messages.INPUT_CORRECT_CURRENT_PWD)
            return
        }
        if let newpwd = newpwd, newpwd.isEmpty {
            showToast(Messages.INPUT_NEW_PWD)
            return
        }
        if let confirmpwd = confirmpwd, confirmpwd.isEmpty {
            showToast(Messages.INPUT_CONFIRM_PWD)
            return
        }
        if newpwd != confirmpwd {
            showToast(Messages.INPUT_MATCHED_CONFIRM_PWD)
            return
        } else {
            self.edtpassword.text = newpwd
            self.setChangePwd(false)
            /**DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.hideLoadingView()
                self.showAlerMessage(message: Messages.PASSWORD_UPDATE_SUCCESS)
                self.setChangePwd(false)
            }*/
        }
    }
    
    @IBAction func changePwdBtnClicked(_ sender: Any) {
        setChangePwd(true)
    }
}

extension MyaccountVC: ImagePickerDelegate{
    
    func didSelect(image: UIImage?) {
        self.gotoUploadProfile(image)
    }
}

extension MyaccountVC: UITextFieldDelegate{
   
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        textField.isSecureTextEntry = false
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        textField.isSecureTextEntry = true
        return false
    }
}



