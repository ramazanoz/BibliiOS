//
//  AlamofireDao.swift
//  BibliOS
//
//  Created by Salih Topcu on 8.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Alamofire

public class AlamofireDao: Dao {
    private var request: DataRequest?
    var encoding: ParameterEncoding = URLEncoding.default
    
    override init(url: String, method: HTTPMethod, delegate: DaoDelegate?) {
        super.init(url: url, method: method, delegate: delegate)
        if (method == .post || method == .put) {
            self.encoding = JSONEncoding.default
        }
    }
    
    public override func execute() {
        self.request = SessionManager.default.daoRequest(super.finalUrl, method: Alamofire.HTTPMethod(rawValue: super.method.rawValue) ?? .get, parameters: super.bodyData, encoding: self.encoding, headers: super.headers, disableCache: true)
        self.startJsonRequest()
    }
    
    private func startJsonRequest() {
        self.request!.responseJSON() { response in
            let data: Any? = response.result.value as? KVPArray ?? response.result.value as? [KVPArray] ?? nil
            let error: DaoError? = self.handleError(response: response, data: data)
            if error == nil {
                self.requestDidSuccess(data)
            } else {
                self.requestDidFail(error!)
            }
        }
    }
    
    func pause() {
        self.request?.suspend()
    }
    
    func resume() {
        self.request?.resume()
    }
    
    func cancel() {
        self.request?.cancel()
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
    
    private func handleError(response: DataResponse<Any>, data: Any?) -> DaoError? {
        var error: DaoError?
        if response.result.isSuccess {
            if data is KVP {
                error = self.handleDataError(data as! KVP)
                if error != nil {
                    NSLog("\n---- DATA ERROR ----\nCODE:\(error!.code.rawValue) \nMESSAGE:\(error!.message) \nDATA:\(String(describing: String.init(data: response.data!, encoding: .utf8)))")
                }
            }
        } else {
            if response.response == nil {
                error = DaoError(intCode: 0, message: "No response!")
            } else {
//                error = self.handleResponseError(response.response!)
            }
            if error != nil {
                if response.data == nil {
                    NSLog("\n---- DATA ERROR ----\nCODE:\(error!.code.rawValue) \nMESSAGE:\(error!.message)")
                } else {
                    NSLog("\n---- DATA ERROR ----\nCODE:\(error!.code.rawValue) \nMESSAGE:\(error!.message) \nDATA:\(String(describing: String.init(data: response.data!, encoding: .utf8)))")
                }
            }
        }
        return error
    }

    // Override to customize
    func handleDataError(_ data: KVP) -> DaoError? {
        return nil
    }
    
}

extension Alamofire.SessionManager {
    @discardableResult open func daoRequest(
        _ url: URLConvertible,
        method: Alamofire.HTTPMethod = .get,
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

extension Alamofire.HTTPMethod {
    public static func initFrom(_ method: HTTPMethod) -> Alamofire.HTTPMethod {
        return Alamofire.HTTPMethod(rawValue: method.rawValue) ?? .get
    }
}
