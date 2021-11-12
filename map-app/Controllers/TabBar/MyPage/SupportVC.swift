//
//  SupportVC.swift
//  meets
//
//  Created by top Dev on 10/10/20.
//


import UIKit
import MessageUI
import ActiveLabel

class SupportVC: BaseVC ,MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var cus_label: ActiveLabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    
    func setUI() {
        self.title = Messages.CONTACT_US
        addBackButton()
        let customType = ActiveType.custom(pattern: "\\stutu.map.app@gmail.com\\b") //Looks for "are"
        cus_label.enabledTypes.append(customType)
        cus_label.customize { label in
            label.text = "お問い合わせの際は大変お手数ですが\n下記メールアドレスをクリックください\n（ご意見・ご要望のある方も下記メールで承っております） tutu.map.app@gmail.com"
            label.numberOfLines = 0
            label.lineSpacing = 4
            
            label.textColor = .darkGray
            label.URLSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)

            
            //Custom types

            label.customColor[customType] = .systemBlue
            label.customSelectedColor[customType] = .darkGray
            
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                return attributes
            }

            label.handleCustomTap(for: customType) {_ in
                //self.alert("Custom type", message: $0)
                self.sendEmail()
            }
        }
    }
    
    func sendEmail() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let subject = "保カツMAP　サポートチーム"
        let body = ""
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["tutu.map.app@gmail.com"])
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody(body, isHTML: false)
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        self.showAlertMessage(msg: "デバイスは電子メールを送信できませんでした。メールの設定を確認して、もう一度お試しください。")
    }
}

extension MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
            
            case MFMailComposeResult.cancelled.rawValue:
                print("Cancelled")
            case MFMailComposeResult.saved.rawValue:
                print("Saved")
            case MFMailComposeResult.sent.rawValue:
                print("Sent")
            case MFMailComposeResult.failed.rawValue:
                print("Error: \(String(describing: error?.localizedDescription))")
            default:
                break
            }
        controller.dismiss(animated: true, completion: nil)
    }
}
