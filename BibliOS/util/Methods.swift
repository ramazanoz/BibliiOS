//
//  Util.swift
//  BibliOS
//
//  Created by Salih Topcu on 8.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Foundation

public struct KVPUtil {
    
    static func getValue(data: KVP, key: String, defaultValue: Any? = nil) -> Any? {
        return data[key] ?? defaultValue
    }
    
    static func getKVP(data: KVP, key: String, defaultValue: KVP? = nil) -> KVP? {
        return getValue(data: data, key: key) as? KVP ?? defaultValue
    }
    
    static func getString(data: KVP, key: String, defaultValue: String? = "") -> String? {
        return getValue(data: data, key: key) as? String ?? defaultValue
    }
    
    static func getInt(data: KVP, key: String, defaultValue: Int? = 0) -> Int? {
        var result: Int? = defaultValue
        let value = getValue(data: data, key: key)
        if value != nil {
            if value is Int {
                result = value as? Int
            } else if value is String && Int(value as! String) != nil {
                result = Int(value as! String)!
            }
        }
        return result
    }
    
    static func getDouble(data: KVP, key: String, defaultValue: Double? = 0) -> Double? {
        return getValue(data: data, key: key) as? Double ?? defaultValue
    }
    
    static func getBool(data: KVP, key: String, defaultValue: Bool = false) -> Bool {
        return getValue(data: data, key: key) as? Bool ?? defaultValue
    }
    
    static func getDate(data: KVP, key: String, format: String, defaultValue: Date? = nil) -> Date? {
        return DateUtil.createDate(date: self.getString(data: data, key: key)!, format: format) ?? defaultValue
    }
    
    static func getDataArray(data: KVP, key: String) -> KVPArray {
        return getValue(data: data, key: key) as? KVPArray ?? []
    }
    
    static func getStringArray(data: KVP, key: String) -> [String] {
        return getValue(data: data, key: key) as? [String] ?? []
    }
    
    static func getIntegerArray(data: KVP, key: String) -> [Int] {
        return getValue(data: data, key: key) as? [Int] ?? []
    }
    
    static func getDoubleArray(data: KVP, key: String) -> [Double] {
        return getValue(data: data, key: key) as? [Double] ?? []
    }
}

public struct DateUtil {
    private static var _dateFormatter: DateFormatter?
    private static var dateFormatter: DateFormatter {
        if self._dateFormatter == nil {
            self._dateFormatter = DateFormatter()
            self._dateFormatter!.locale = Locale(identifier:"en_US_POSIX")
        }
        return self._dateFormatter!
    }
    static func getDateFormatter(format: String) -> DateFormatter {
        dateFormatter.dateFormat = format
        return dateFormatter
    }
    
    // TODO: needs to be tested
    static func createDate(date: String, format: String) -> Date? {
        return self.getDateFormatter(format: format).date(from: date)
    }
    
    
}
