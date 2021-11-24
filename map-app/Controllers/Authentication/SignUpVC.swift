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
import ActionSheetPicker_3_0

class SignUpVC: BaseVC {
    
    @IBOutlet weak var signBtnView: UIView!
    @IBOutlet weak var edtusername: UITextField!
    @IBOutlet weak var edt_email: UITextField!
    @IBOutlet weak var edtpassword: UITextField!
    @IBOutlet weak var edtconfirmpassword: UITextField!
    @IBOutlet weak var imv_avatar: UIImageView!
    @IBOutlet weak var checkBox: GDCheckbox!
    @IBOutlet weak var uiv_camera: UIView!
    @IBOutlet weak var txv_intro: UITextView!
    
    var usertName = ""
    var useremail = ""
    var password = ""
    var confirmpassword = ""
    var first_number = ""
    var last_number = ""
    var user_description = ""
    var imagePicker: ImagePicker!
    var attachments = [(Data, String, String, String)]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Messages.SIGNUP
        hideNavBar()
        addBackButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editInit()
        uiv_camera.addTapGesture(tapNumber: 1, target: self, action: #selector(onEdtPhoto))
        self.imagePicker = ImagePicker(presentationController: self, delegate: self, is_cropping: true)
    }
    
    func editInit() {
        setEdtPlaceholder(edtusername, placeholderText: Messages.USERNAME, placeColor: UIColor.lightGray, padding: .left(55))
        setEdtPlaceholder(edt_email, placeholderText: Messages.EMAIL, placeColor: UIColor.lightGray, padding: .left(55))
        setEdtPlaceholder(edtpassword, placeholderText: Messages.PASSWORD, placeColor: UIColor.lightGray, padding: .left(55))
        setEdtPlaceholder(edtconfirmpassword, placeholderText: Messages.CONFIRM_PASSWORD, placeColor: UIColor.lightGray, padding: .left(55))
        
    }
    
    @objc func onEdtPhoto(gesture: UITapGestureRecognizer) -> Void {
        self.imagePicker.present(from: view)
    }
    
    func gotoUploadProfile(_ image: UIImage?) {
        self.attachments.removeAll()
        if let image = image{
            attachments.append((image.jpegData(compressionQuality: 0.3)!, "user_photo", "image.png", "image/png"))
            self.imv_avatar.image = image
        }
    }
    
    @IBAction func gotoTerms(_ sender: Any) {
        //showNavBar()
        self.presentWebViewWithProgressBar(Constants.TERMS_LINK)
        //self.showWebViewWithProgressBar(Constants.TERMS_LINK)
    }
    
    @IBAction func gotoPrivacy(_ sender: Any) {
        //showNavBar()
        self.presentWebViewWithProgressBar(Constants.PRIVACY_LINK)
        //self.showWebViewWithProgressBar(Constants.PRIVACY_LINK)
    }
    
    @IBAction func signupBtnClicked(_ sender: Any) {
        usertName = self.edtusername.text ?? ""
        useremail = self.edt_email.text ?? ""
        password = self.edtpassword.text ?? ""
        confirmpassword = self.edtconfirmpassword.text ?? ""
        user_description = self.txv_intro.text ?? ""
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
        if password != confirmpassword{
            self.showToast(Messages.CONFIRM_PASSWORD_MATCH)
            return
        }
        if !self.checkBox.isOn{
            self.showToast(Messages.TERMS_AGREE)
            return
        }
        else{
            self.showLoadingView(vc: self)
            ApiManager.signup(user_name: usertName, email: useremail, user_des: user_description, password: password, token: UserDefault.getString(key: PARAMS.TOKEN) ?? "", attachments:attachments) { success, response in
                self.hideLoadingView()
                if success{
                    UserDefault.setBool(key: PARAMS.LOGOUT, value: false)
                    self.gotoVC("TabBarVC")
                }else{
                    if let data = response{
                        let statue = data  as! Int
                        if statue == 201{
                            self.showAlertMessage(msg: Messages.USER_EMAIL_EXIST)
                        }else if statue == 202{
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
    
    @IBAction func gotoLogin(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension SignUpVC: ImagePickerDelegate{
    
    func didSelect(image: UIImage?) {
        self.gotoUploadProfile(image)
    }
}

extension SignUpVC: UITextFieldDelegate{
   
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        textField.isSecureTextEntry = false
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        textField.isSecureTextEntry = true
        return false
    }
}

