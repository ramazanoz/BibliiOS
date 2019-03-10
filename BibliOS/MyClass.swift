//
//  MyClass.swift
//  BibliOS
//
//  Created by Salih Topcu on 8.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Foundation

public class MyClass {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public extension MyClass {
    var doubleName: String {
        return self.name + self.name
    }
}

public struct StaticClass {
    public static let VAL_ONE: String = "asd"
}
