//
//  KeyValueModel.swift
//  MS_FormControls
//
//  Created by Manoj Shrestha on 4/9/19.
//

import Foundation
public class KeyValueModel
{
   public var key = String()
   public var value = String()
   public var isSelected : Bool = false
    
    public init(key: String, value: String, isSelected: Bool = false)
    {
        self.key = key
        self.value = value
        self.isSelected = isSelected
    }
}
