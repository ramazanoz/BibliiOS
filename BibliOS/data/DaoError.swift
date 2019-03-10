//
//  DaoError.swift
//  BibliOS
//
//  Created by Salih Topcu on 8.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

//
//  DaoError.swift
//  AkeadPro
//
//  Created by Salih Topcu on 20/02/2017.
//  Copyright © 2017 Akead Bilisim. All rights reserved.
//

public class DaoError {
    var code: Int
    var message: String
    
    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
    
    init(code: Int) {
        self.code = code
        self.message = DaoError.getErrorMessage(code: code)
    }
    
    private static func getErrorMessage(code: Int) -> String {
        switch code {
        case 400: return "Bad Request"
        case 404: return "Not Found"
        case 500: return "Internal Server Error"
        default: return ""
        }
    }
}
