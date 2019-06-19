//
//  FileDownloader.swift
//  AkeadPro
//
//  Created by Salih Topcu on 08/03/2017.
//  Copyright © 2017 Akead Bilisim. All rights reserved.
//

import Alamofire

public class AlamofireFileDownloader: Dao {
    private var request: DataRequest!
    
    public init(url: String, successAction: @escaping DaoSuccessAction, failAction: DaoFailAction?) {
        super.init(url: url, method: .get, successAction: successAction, failAction: failAction)
    }
    
    override public func execute() {
        self.request = Alamofire.request(self.url)
        self.request.responseData(completionHandler: { response in
            if response.data != nil {
                super.requestDidSuccess(response.data)
            } else {
                super.requestDidFail(AlamofireDaoError(code: HTTPCode.notFound.rawValue, message: nil))
            }
        })
    }
}
