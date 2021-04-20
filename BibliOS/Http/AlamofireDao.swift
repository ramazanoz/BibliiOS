//
//  AlamofireDao.swift
//  BibliOS
//
//  Created by Salih Topcu on 8.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Alamofire

open class AlamofireDao: Dao {
    private var request: DataRequest?
    var encoding: ParameterEncoding = URLEncoding.default
    
    public override init(url: String, method: HTTPMethod, delegate: DaoDelegate?) {
        super.init(url: url, method: method, delegate: delegate)
        if (method == .post || method == .put) {
            self.encoding = JSONEncoding.default
        }
    }
    
    open override func execute() {
        self.request = SessionManager.default.daoRequest(super.finalUrl, method: Alamofire.HTTPMethod(rawValue: super.method.rawValue) ?? .get, parameters: super.bodyData, encoding: self.encoding, headers: super.headers, disableCache: true)
        self.request!.responseJSON() { response in
            let data: Any? = response.result.value as? MetaObject ?? response.result.value as? MetaArray ?? nil
            let error: DaoError? = self.handleError(response: response, data: data)
            if error == nil {
                self.requestDidSuccess(data)
            } else {
                self.requestDidFail(error!)
            }
        }
    }
    
    override public func pause() {
        self.request?.suspend()
    }
    
    override public func resume() {
        self.request?.resume()
    }
    
    override public func cancel() {
        self.request?.cancel()
    }
    
    // MARK: - Error Handling Methods
    
    private func handleError(response: DataResponse<Any>, data: Any?) -> DaoError? {
        var error: DaoError?
        if response.result.isSuccess {
            if data is MetaObject {
                error = self.handleDataError(data as! MetaObject)
                if error != nil {
                    NSLog("\n---- DATA ERROR ----\nCODE:\(error!.code) \nMESSAGE:\(error!.message) \nDATA:\(String(describing: String.init(data: response.data!, encoding: .utf8)))")
                }
            }
        } else {
            if response.response == nil {
                error = AlamofireDaoError(code: 0, message: "No response")
            } else {
                error = self.handleResponseError(response: response.response!) ?? AlamofireDaoError(code: 0, message: "Unhandled error")
            }
            if error != nil {
                if response.data == nil {
                    NSLog("\n---- DATA ERROR ----\nCODE:\(error!.code) \nMESSAGE:\(error!.message)")
                } else {
                    NSLog("\n---- DATA ERROR ----\nCODE:\(error!.code) \nMESSAGE:\(error!.message) \nDATA:\(String(describing: String.init(data: response.data!, encoding: .utf8)))")
                }
            }
        }
        return error
    }

    // Override to customize
    open func handleDataError(_ data: MetaObject) -> DaoError? {
        return nil
    }
    
    private func handleResponseError(response: HTTPURLResponse) -> AlamofireDaoError? {
        if response.statusCode != HTTPCode.ok.rawValue && response.statusCode != HTTPCode.created.rawValue && response.statusCode != HTTPCode.accepted.rawValue {
            return AlamofireDaoError(code: response.statusCode, message: nil)
        }
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

open class AlamofireDaoError: DaoError {
    public var code: Int
    public var message: String
    
    public required init(code: Int, message: String?) {
        self.code = code
        self.message = message ?? HTTPCode.getMessage(of: HTTPCode(rawValue: code) ?? .none)
    }
}
