//
//  Util.swift
//  BibliOS
//
//  Created by Salih Topcu on 8.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Foundation
import SystemConfiguration

// MARK: - BibliOS

public struct MetaUtil {
    
    private static func getValue(of object: MetaObject, with key: String, defaultValue: Any? = nil) -> Any? {
        return object[key] ?? defaultValue
    }
    
    public static func getMetaObject(of object: MetaObject, with key: String, defaultValue: MetaObject? = nil) -> MetaObject? {
        return getValue(of: object, with: key) as? MetaObject ?? defaultValue
    }
    
    public static func getString(of object: MetaObject, with key: String, defaultValue: String? = "") -> String? {
        return getValue(of: object, with: key) as? String ?? defaultValue
    }
    
    public static func getInt(of object: MetaObject, with key: String, defaultValue: Int? = 0) -> Int? {
        var result: Int? = defaultValue
        let value = getValue(of: object, with: key)
        if value != nil {
            if value is Int {
                result = value as? Int
            } else if value is String && Int(value as! String) != nil {
                result = Int(value as! String)!
            }
        }
        return result
    }
    
    public static func getInt64(of object: MetaObject, with key: String, defaultValue: Int64? = 0) -> Int64? {
        var result: Int64? = defaultValue
        let value = getValue(of: object, with: key)
        if value != nil {
            if value is Int64 {
                result = value as? Int64
            } else if value is String && Int64(value as! String) != nil {
                result = Int64(value as! String)!
            }
        }
        return result
    }
    
    public static func getDouble(of object: MetaObject, with key: String, defaultValue: Double? = 0) -> Double? {
        return getValue(of: object, with: key) as? Double ?? defaultValue
    }
    
    public static func getBool(of object: MetaObject, with key: String, defaultValue: Bool = false) -> Bool {
        return getValue(of: object, with: key) as? Bool ?? defaultValue
    }
    
    public static func getDate(of object: MetaObject, with key: String, format: String, defaultValue: Date? = nil) -> Date? {
        return DateUtil.createDate(date: self.getString(of: object, with: key)!, format: format) ?? defaultValue
    }
    
    public static func getMetaArray(of object: MetaObject, with key: String) -> MetaArray {
        return getValue(of: object, with: key) as? MetaArray ?? []
    }
    
    public static func getStringArray(of object: MetaObject, with key: String) -> [String] {
        return getValue(of: object, with: key) as? [String] ?? []
    }
    
    public static func getIntegerArray(of object: MetaObject, with key: String) -> [Int] {
        return getValue(of: object, with: key) as? [Int] ?? []
    }
    
    public static func getDoubleArray(of object: MetaObject, with key: String) -> [Double] {
        return getValue(of: object, with: key) as? [Double] ?? []
    }
    
    public static func decode<T>(from object: MetaObject, to type: T.Type, dateFormat: String? = nil) -> Any where T : Decodable {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)

            let reqJSONStr = String(data: jsonData, encoding: .utf8)
            let utf8data = reqJSONStr?.data(using: .utf8)
            let jsonDecoder = JSONDecoder()
    
            if dateFormat != nil {
                let formatter = DateFormatter()
                formatter.dateFormat = dateFormat!
                jsonDecoder.dateDecodingStrategy = .formatted(formatter)
            }
            
            let result = try jsonDecoder.decode(type.self, from: utf8data!)
            return result
        } catch let jsonErr {
            print("Error serializing json:", jsonErr)
            return jsonErr
        }
    }
}

// MARK: - DispatchQueue

public struct ThreadUtil {
    
    public static func delayOnMainThread(_ delay: Double, action: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: action)
    }
    
}

// MARK: - Foundation

public struct DateUtil {
    
    private static var _dateFormatter: DateFormatter?
    
    private static var dateFormatter: DateFormatter {
        if self._dateFormatter == nil {
            self._dateFormatter = DateFormatter()
            self._dateFormatter!.locale = Locale(identifier:"en_US_POSIX")
        }
        return self._dateFormatter!
    }
    
    public static func getSharedDateFormatter(format: String) -> DateFormatter {
        dateFormatter.dateFormat = format
        return dateFormatter
    }
    
    // TODO: needs to be tested
    public static func createDate(date: String, format: String) -> Date? {
        return self.getSharedDateFormatter(format: format).date(from: date)
    }
    
    
}

// MARK: - Other

public struct DeviceUtil {
    
    public static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
}

// MARK: - Swift

public struct Util {
    
    public static func isEmpty(_ value: Any?) -> Bool {
        if value == nil {
            return true
        } else if value is String {
            return value as! String == ""
        } else if value is Int {
            return value as! Int == 0
        } else if value is Double {
            return value as! Double == 0
        } else if value is Float {
            return value as! Float == 0
		} else if value is Array<Any> {
			return (value as! Array<Any>).isEmpty
		} else if value is Int8 {
            return value as! Int8 == 0
        } else if value is Int16 {
            return value as! Int16 == 0
        } else if value is Int32 {
            return value as! Int32 == 0
        } else if value is Int64 {
            return value as! Int64 == 0
        } else if value is Float32 {
            return value as! Float32 == 0
        } else if value is Float64 {
            return value as! Float64 == 0
        }
        return false
    }
    
    public static func isNotEmpty(_ value: Any?) -> Bool {
        return !Util.isEmpty(value)
    }
    
}
