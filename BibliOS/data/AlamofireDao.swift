//
//  AlamofireDao.swift
//  BibliOS
//
//  Created by Salih Topcu on 8.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Alamofire

public class AlamofireDao: Dao {
    private var method: HTTPMethod
    private var request: DataRequest?
    var encoding: ParameterEncoding = URLEncoding.default
    
    var errorCodeKey: String?
    var errorMessageKey: String?
    
    init(url: String, method: HTTPMethod, delegate: DaoDelegate?) {
        self.method = method
        super.init(url: url, delegate: delegate)
        if (method == .post || method == .put) {
            //            self.encoding = .httpBody
            self.encoding = JSONEncoding.default
        }
        self.request = nil
    }
    
    public override func execute() {
        self.request = SessionManager.default.daoRequest(super.finalUrl, method: self.method, parameters: super.bodyData, encoding: self.encoding, headers: self.headers, disableCache: true)
        self.startJsonRequest()
    }
    
    private func startJsonRequest() {
        self.request!.responseJSON() { response in
            let jsonResult: Any? = response.result.value is KVPArray ? response.result.value as? KVPArray : response.result.value as? [KVPArray]
            
            //            let jsonResult = value is KVPArray ? value as! KVPArray : value as! [KVPArray]
            var error: DaoError! = nil
            if response.result.isSuccess {
                if jsonResult is KVPArray {
                    error = self.handleDataError(jsonResult as! KVPArray)
                    if error != nil {
                        NSLog("\n---- DATA ERROR ----\nCODE:\(error.code) \nMESSAGE:\(error.message) \nDATA:\(String(describing: String.init(data: response.data!, encoding: .utf8)))")
                    }
                }
            } else {
                if response.response == nil {
                    error = DaoError(code: 0, message: "No response!")
                } else {
                    error = self.handleResponseError(response.response!)
                }
                if error != nil {
                    if response.data == nil {
                        NSLog("\n---- DATA ERROR ----\nCODE:\(error.code) \nMESSAGE:\(error!.message)")
                    } else {
                        NSLog("\n---- DATA ERROR ----\nCODE:\(error.code) \nMESSAGE:\(error!.message) \nDATA:\(String(describing: String.init(data: response.data!, encoding: .utf8)))")
                    }
                }
            }
            if error == nil {
                if response.result.isSuccess {
                    self.requestDidSuccess(jsonResult)
                } else {
                    self.requestDidFail(DaoError(code: 0))
                }
            } else {
                self.requestDidFail(error)
            }
        }
    }
    
    func pause() {
        if (self.request != nil) {
            self.request?.suspend()
        }
    }
    
    func resume() {
        if (self.request != nil) {
            self.request?.resume()
        }
    }
    
    func cancel() {
        if (self.request != nil) {
            self.request?.cancel()
        }
    }
    
    // Override to customize
    func requestDidSuccess(_ data: Any? = nil) {
        super.delegate?.dao(didSuccess: self, data: data)
        debugPrint(String(describing: self.classForCoder) + " / requestDidSuccess")
    }
    
    // Override to customize
    func requestDidFail(_ error: DaoError) {
        super.delegate?.dao(didFail: self, error: error)
        debugPrint(String(describing: self.classForCoder) + " / requestDidFail")
        self.cancel()
    }
    
    // MARK: - Error Handling Methods
    
    func handleDataError(_ data: KVPArray) -> DaoError? {
        var error: DaoError? = nil
        if self.errorCodeKey != nil && self.errorMessageKey != nil {
            let errorCode = Method.getInt(data: data, key: self.errorCodeKey!, defaultValue: nil)
            if errorCode != nil {
                error = DaoError(code: errorCode!)
                if let message = Method.getString(data: data, key: self.errorMessageKey!) {
                    error!.message = message
                }
            }
        }
        return error
    }
    
    func handleResponseError(_ response: HTTPURLResponse) -> DaoError? {
        var error: DaoError? = nil
        let code: Int = response.statusCode
        if code != 200 && code != 201 && code != 202 {
            error = DaoError(code: code)
        }
        return error
    }
}

extension Alamofire.SessionManager {
    @discardableResult open func daoRequest(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        disableCache: Bool)
        -> DataRequest
    {
        var originalRequest: URLRequest?
        
        do {
            originalRequest = try URLRequest(url: url, method: method, headers: headers)
            let encodedURLRequest = try encoding.encode(originalRequest!, with: parameters)
            if disableCache {
                originalRequest?.cachePolicy = .reloadIgnoringCacheData
            }
            //            originalRequest?.timeoutInterval = 90
            return request(encodedURLRequest)
        } catch {
            return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
        }
    }
}
