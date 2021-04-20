//
//  Type.swift
//  BibliOS
//
//  Created by Salih Topcu on 8.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Foundation

//public typealias KVP = (key: String, value: Any)
public typealias MetaObject = [String: Any]

public typealias MetaArray = [MetaObject]

public typealias SomeAction = () -> Void

public class Currency {
    private var _name: String
    public var name: String {
        return self._name
    }
    private var _code: String
    public var code: String {
        return self._code
    }
    private var _symbol: String
    public var symbol: String {
        return self._symbol
    }
    
    private init(name: String, code: String, symbol: String) {
        self._name = name
        self._code = code
        self._symbol = symbol
    }
    
    public static let euro = Currency(name: "Euro", code: "EUR", symbol: "€")
    public static let tl = Currency(name: "Türk Lirası", code: "TL", symbol: "₺")
    public static let usd = Currency(name: "U.S. Dollar", code: "USD", symbol: "$")
    public static let unknown = Currency(name: "Unknown", code: "UNKNOWN", symbol: "*")
    
    private static let list: [Currency] = [Currency.euro, Currency.tl, Currency.usd]
    
    public static func getWith(code: String) -> Currency {
        let filterResult = Currency.list.filter { $0.code == code }
        return filterResult.count > 0 ? filterResult[0] : Currency.unknown
    }
    
    public static func getWith(symbol: String) -> Currency {
        let filterResult = Currency.list.filter { $0.symbol == symbol }
        return filterResult.count > 0 ? filterResult[0] : Currency.unknown
    }
}

public struct AnchorSet {
    let top: NSLayoutYAxisAnchor?
    let right: NSLayoutXAxisAnchor?
    let bottom: NSLayoutYAxisAnchor?
    let left: NSLayoutXAxisAnchor?
    
    public init(top: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }
    
    public init(_ top: NSLayoutYAxisAnchor?, _ right: NSLayoutXAxisAnchor?, _ bottom: NSLayoutYAxisAnchor?, _ left: NSLayoutXAxisAnchor?) {
        self.init(top: top, right: right, bottom: bottom, left: left)
    }
}

public struct PaddingValueSet {
    var top: CGFloat = 0
    var right: CGFloat = 0
    var bottom: CGFloat = 0
    var left: CGFloat = 0
    
    public init(top: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }
    
    public init(_ value: CGFloat) {
        self.init(top: value, right: value, bottom: value, left: value)
    }
}
