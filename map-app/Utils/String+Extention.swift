//
//  String+Extention.swift
//  bumerang
//
//  Created by RMS on 2019/10/2.
//  Copyright © 2019 RMS. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var numberValue:NSNumber? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self)
    }
    
    //Converts String to Int
    public func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }

    //Converts String to Double
    public func toDouble() -> Double? {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }

    /// EZSE: Converts String to Float
    public func toFloat() -> Float? {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return nil
        }
    }

    //Converts String to Bool
    public func toBool() -> Bool? {
        return (self as NSString).boolValue
    }
    
    private static var digitsPattern = UnicodeScalar("0")..."9"
//    var digits: String {
//        return unicodeScalars.filter { String.digitsPattern ~= $0 }.string
//    }
    var integer: Int { return Int(self) ?? 0 }
}

extension String
{
    func trim() -> String{
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    func isValidUsername() -> Bool {
       let RegEx = "^[0-9a-zA-Z\\_.]{5,32}$"
       //  let RegEx = "^(?=.*[A-Z])(?=.*[0-9])[A-Za-z\\d$@$#!%*?&]{8,}"
    
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: self)
    }
    func isValidPassword() -> Bool {
        //        let RegEx = "\\w{5,32}"
        let RegEx = "^(?=.*[A-Z])(?=.*[0-9])[A-Za-z\\d$@$#!%*?&]{8,}"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: self)
    }
}
