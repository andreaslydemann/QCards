//
//  RxSettingCompatible+Ext.swift
//  Platform
//
//  Created by Andreas Lüdemann on 01/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

extension Int: RxSettingCompatible {
    
    public func toPersistedValue() -> Any {
        return self
    }
    
    public static func fromPersistedValue(value: Any) -> Int {
        return value as! Int
    }
}

extension Bool: RxSettingCompatible {
    
    public func toPersistedValue() -> Any {
        return self
    }
    
    public static func fromPersistedValue(value: Any) -> Bool {
        return value as! Bool
    }
}

extension String: RxSettingCompatible {
    
    public func toPersistedValue() -> Any {
        return self
    }
    
    public static func fromPersistedValue(value: Any) -> String {
        return value as! String
    }
}

public extension RxSettingEnum where Self: RawRepresentable {
    
    func toPersistedValue() -> Any {
        return self.rawValue
    }
    
    static func fromPersistedValue(value: Any) -> Self {
        return Self(rawValue: value as! RawValue)!
    }
}

extension Array: RxSettingCompatible {
    
    public func toPersistedValue() -> Any {
        return self
    }
    
    public static func fromPersistedValue(value: Any) -> [Element] {
        return value as! [Element]
    }
}

// Set is not supported, work around with an array
extension Set: RxSettingCompatible {
    
    public func toPersistedValue() -> Any {
        return Array(self)
    }
    
    public static func fromPersistedValue(value: Any) -> Set<Element> {
        return Set(value as! [Element])
    }
}
