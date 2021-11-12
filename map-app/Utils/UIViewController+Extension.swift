//
//  UIViewController+Extension.swift
//  EveraveUpdate
//
//  Created by Mac on 6/19/20.
//  Copyright © 2020 Ubuntu. All rights reserved.
//

import UIKit
import AVFoundation

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
