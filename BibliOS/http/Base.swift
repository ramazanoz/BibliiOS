//
//  Base.swift
//  BibliOS
//
//  Created by Salih Topcu on 10.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

public enum HTTPCode: Int {
    case ok = 200
    case created = 201
    case accepted = 202
    case resourceNotFound = 204
    case badRequest = 400
    case unauthorized = 401
    case notFound = 404
    case notAcceptable = 406
    case internalServerError = 500
    case none = 0
    
    private static let messages: [HTTPCode: String] = [
        .ok: "OK",
        .created: "Access forbidden",
        .accepted: "File not found",
        .resourceNotFound: "Internal server error",
        .badRequest: "Bad request",
        .unauthorized: "Unauthorized",
        .notFound: "Not found",
        .notAcceptable: "Not acceptable",
        .internalServerError: "Internal server error"
    ]
    
    public static func getMessage(of code: HTTPCode) -> String? {
        return self.messages[code]
    }
}
