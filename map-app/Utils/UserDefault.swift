//
//  UserDefault.swift
//  shopadvisor
//
//  Created by Elite on 03/11/16.
//  Copyright © 2016 Luna srls. All rights reserved.
//

import UIKit

private let CBDefaults = UserDefaults.standard
class UserDefault: NSObject {

    class func getObject(key: String) -> AnyObject? {
        return CBDefaults.object(forKey: key) as AnyObject?
    }
    
    class func getInt(key: String) -> Int {
        return CBDefaults.integer(forKey: key)
    }
    
    class func getBool(key: String) -> Bool {
        return CBDefaults.bool(forKey: key)
    }
    
    class func getFloat(key: String) -> Float {
        return CBDefaults.float(forKey: key)
    }
    
    class func getString(key: String) -> String? {
        return CBDefaults.string(forKey: key)
    }
    
    class func getData(key: String) -> NSData? {
        return CBDefaults.data(forKey: key) as NSData?
    }
    
    class func getArray(key: String) -> NSArray? {
        return CBDefaults.array(forKey: key) as NSArray?
    }
    
    class func getDictionary(key: String) -> NSDictionary? {
        return CBDefaults.dictionary(forKey: key) as NSDictionary?
    }
    
    // MARK: - getter 获取 Value 带上默认值
    class func getObject(key: String, defaultValue: AnyObject) -> AnyObject? {
        if getObject(key: key) == nil {
            return defaultValue 
        }
        return getObject(key: key)
    }
    
    class func getInt(key: String, defaultValue: Int) -> Int {
        if getObject(key: key) == nil {
            return defaultValue
        }
        return getInt(key: key)
    }
    
    class func getBool(key: String, defaultValue: Bool) -> Bool {
        if getObject(key: key) == nil {
            return defaultValue
        }
        return getBool(key: key)
    }
    
    class func getFloat(key: String, defaultValue: Float) -> Float {
        if getObject(key: key) == nil {
            return defaultValue
        }
        return getFloat(key: key)
    }
    
    class func getString(key: String, defaultValue: String) -> String? {
        if getObject(key: key) == nil {
            return defaultValue
        }
        return getString(key: key)
    }
    
    class func getData(key: String, defaultValue: NSData) -> NSData? {
        if getObject(key: key) == nil {
            return defaultValue
        }
        return getData(key: key)
    }
    
    class func getArray(key: String, defaultValue: NSArray) -> NSArray? {
        if getObject(key: key) == nil {
            return defaultValue
        }
        return getArray(key: key)
    }
    
    class func getDictionary(key: String, defaultValue: NSDictionary) -> NSDictionary? {
        if getObject(key: key) == nil {
            return defaultValue
        }
        return getDictionary(key: key)
    }
    
    
    // MARK: - Setter
    class func setObject(key: String, value: AnyObject?) {
        if value == nil {
            CBDefaults.removeObject(forKey: key)
        } else {
            CBDefaults.set(value, forKey: key)
        }
        CBDefaults.synchronize()
    }
    
    class func setInt(key: String, value: Int) {
        CBDefaults.set(value, forKey: key)
        CBDefaults.synchronize()
    }
    
    class func setBool(key: String, value: Bool) {
        CBDefaults.set(value, forKey: key)
        CBDefaults.synchronize()
    }
    
    class func setFloat(key: String, value: Float) {
        CBDefaults.set(value, forKey: key)
        CBDefaults.synchronize()
    }
    
    class func setString(key: String, value: String?) {
        if (value == nil) {
            CBDefaults.removeObject(forKey: key)
        } else {
            CBDefaults.set(value, forKey: key)
        }
        CBDefaults.synchronize()
    }
    
    class func setData(key: String, value: NSData) {
        setObject(key: key, value: value)
    }
    
    class func setArray(key: String, value: NSArray) {
        setObject(key: key, value: value)
    }
    
    class func setDictionary(key: String, value: NSDictionary) {
        setObject(key: key, value: value)
    }
    
    // MARK: - Synchronize
    class func Sync() {
        CBDefaults.synchronize()
    }
}
