//
//  TestViewController.swift
//  LSDialogViewController
//
//  Created by Daisuke Hasegawa on 2016/05/17.
//  Copyright © 2016年 Libra Studio, Inc. All rights reserved.
//

import UIKit

class NoteDialogUV: BaseVC {
    
    @IBOutlet weak var txv_note: UITextView!
    @IBOutlet weak var btn_upload: UIButton!
    var location: LocationModel?
    var delegate: LocationDetailVC?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // adjust height and width of dialog
        // view.bounds.size.height = UIScreen.main.bounds.size.height * 0.7
        view.bounds.size.width = UIScreen.main.bounds.size.width * 0.95
        if let location = self.location{
            if let old_note = location.location_memo, !old_note.isEmpty{
                self.txv_note.text = old_note
                self.btn_upload.setTitle("更新", for: .normal)
            }else{
                self.btn_upload.setTitle("アップロード", for: .normal)
            }
        }
    }

    // close dialogView
    @IBAction func uploadUpdateBtnClicked(_ sender: AnyObject) {
        if let location = self.location{
            if let old_note = location.location_memo,!old_note.isEmpty {
                delegate?.manageNotes(.update, memo: self.txv_note.text,location: location)
            }else{
                delegate?.manageNotes(.upload, memo: self.txv_note.text,location: location)
            }
        }
        self.delegate?.dismissDialog()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func closeBtnClicked(_ sender: Any) {
        delegate?.dismissDialog()
    }
}

