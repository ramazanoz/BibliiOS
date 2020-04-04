//
//  Dao.swift
//  BibliOS
//
//  Created by Salih Topcu on 8.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Foundation

//public protocol DaoDelegate: NSObjectProtocol {
//    func dao(didSuccess dao: Dao, data: Any?)
//}

public protocol DaoDelegate {
    func dao(didSuccess dao: Dao, data: Any?)
    
    func dao(didFail dao: Dao, error: DaoError)
}

//public extension DaoDelegate {
//    func dao(didFail dao: Dao, error: DaoError) { }
//}

public typealias DaoSuccessAction = (_ dao: Dao, _ data: Any?) -> Void

public typealias DaoFailAction = (_ dao: Dao, _ error: DaoError) -> Void

open class Dao: NSObject {
    var url: String
    var method: HTTPMethod
    var headers: [String: String] = [:]
    var urlData: [String: String] = [:]
    var bodyData: MetaObject = MetaObject()
    var delegate: DaoDelegate?
    private var successAction: DaoSuccessAction?
    private var failAction: DaoFailAction?
    
    var _finalUrl: String?
    var finalUrl: String {
        if self._finalUrl == nil {
            self._finalUrl = self.url
            for (key, value) in self.urlData {
                self._finalUrl! += String(format: "&%@=%@", key, String(value))
            }
            if self._finalUrl!.range(of: "&") != nil && self._finalUrl!.range(of: "?") == nil {
                self._finalUrl = self._finalUrl!.replacingOccurrences(of: "&", with: "?", options: .literal, range: self._finalUrl!.range(of: "&"))
            }
        }
        return self._finalUrl!
    }
    
    // override and run the http request here
    public func execute() { }
    
    public init(url: String, method: HTTPMethod, delegate: DaoDelegate?) {
        self.url = url
        self.method = method
        self.delegate = delegate
    }
    
    public init(url: String, method: HTTPMethod, successAction: DaoSuccessAction?, failAction: DaoFailAction?) {
        self.url = url
        self.method = method
        self.successAction = successAction
        self.failAction = failAction
    }
    
    public func addUrlData(key: String, value: Any) {
        if value is String {
            self.urlData.updateValue(value as! String, forKey: key)
        } else if value is Int {
            self.urlData.updateValue(String(value as! Int), forKey: key)
        } else if value is Double {
            self.urlData.updateValue(String(value as! Double), forKey: key)
        }
        self._finalUrl = nil
    }
    
    public func addHeader(key: String, value: Any) {
        if value is String {
            self.headers.updateValue(value as! String, forKey: key)
        } else if value is Int {
            self.headers.updateValue(String(value as! Int), forKey: key)
        } else if value is Double {
            self.headers.updateValue(String(value as! Double), forKey: key)
        }
    }
    
    public func addBodyData(key: String, value: Any) {
        self.bodyData.updateValue(value, forKey: key)
    }
    
    public func setBodyData(_ data: MetaObject) {
        self.bodyData = data
    }
    
    // Override to customize
    public func pause() { }
    
    // Override to customize
    public func resume() { }
    
    // Override to customize
    public func cancel() { }
    
    // Override to customize
    open func requestDidSuccess(_ data: Any? = nil) {
        self.delegate?.dao(didSuccess: self, data: data) ?? self.successAction?(self, data)
        debugPrint(String(describing: self.classForCoder) + " / requestDidSuccess")
    }
    
    // Override to customize
    open func requestDidFail(_ error: DaoError) {
        self.delegate?.dao(didFail: self, error: error) ?? self.failAction?(self, error)
        debugPrint(String(describing: self.classForCoder) + " / requestDidFail")
        self.cancel()
    }
    
}

public protocol DaoError {
    var code: Int { get }
    var message: String { get }
}

//open class DaoError {
//    public var code: Int
//    private var _message: String?
//    public var message: String {
//        return self._message ?? self.getMessage() ?? HTTPCode.getMessage(of: HTTPCode(rawValue: self.code) ?? .none)
//    }
//
//    public init(code: Int, message: String? = nil) {
//        self.code = code
//        self._message = message
//    }
//
//    // Override to customize message
//    open func getMessage() -> String? {
//        return nil
//    }
//}
