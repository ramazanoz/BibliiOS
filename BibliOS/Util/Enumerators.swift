//
//  Enumerators.swift
//  BibliOS
//
//  Created by Salih Topcu on 11.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Foundation

//public enum Currency: String {
//    case eur = "EUR"
//    case tl = "TL"
//    case usd = "USD"
//    case other = ""
//    
//    private static let symbols: [Currency: String] = [
//        .eur: "€",
//        .tl: "₺",
//        .usd: "$",
//        .other: ""
//    ]
//    
//    public static func getSymbol(of currency: Currency) -> String {
//        return self.symbols[currency] ?? ""
//    }
//}

public enum ImageFormat {
    case jpg
    case png
    case bmp
}

public enum PhoneScreenType: Int {
    case iPhone4 = 480
    case iPhone5 = 568
    case iPhone6 = 667
    case iPhone6Plus = 736
    case iPhoneX = 812
    case other = 813
    
    static func initWithScreenHeight(_ height: CGFloat) -> PhoneScreenType {
        return PhoneScreenType(rawValue: Int(height)) ?? .other
    }
}

public enum Side {
    case right
    case left
}

enum Status: Int {
    case passive = 0
    case active = 1
}
