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
    var post: PostModel?
    var delegate: LocationDetailVC?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // adjust height and width of dialog
        // view.bounds.size.height = UIScreen.main.bounds.size.height * 0.7
        view.bounds.size.width = UIScreen.main.bounds.size.width * 0.95
        if let post = self.post{
            if let old_note = post.notes, !old_note.isEmpty{
                self.txv_note.text = old_note
                self.btn_upload.setTitle("更新", for: .normal)
            }else{
                self.btn_upload.setTitle("アップロード", for: .normal)
            }
        }
    }

    // close dialogView
    @IBAction func uploadUpdateBtnClicked(_ sender: AnyObject) {
        if let post = self.post{
            if let old_note = post.notes,!old_note.isEmpty {
                delegate?.manageNotes(.update, notes: self.txv_note.text, post: post)
            }else{
                delegate?.manageNotes(.upload, notes: self.txv_note.text, post: post)
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

