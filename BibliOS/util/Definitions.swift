//
//  Type.swift
//  BibliOS
//
//  Created by Salih Topcu on 8.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Foundation

//public typealias KVP = (key: String, value: Any)
public typealias KVP = [String: Any]

public typealias KVPArray = [KVP]

public typealias SomeAction = () -> Void

public typealias SuccessActionWithData = (_ data: Data) -> Void

enum Side {
    case right
    case left
}
