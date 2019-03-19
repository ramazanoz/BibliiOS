//
//  Shortcuts.swift
//  BibliOS
//
//  Created by Salih Topcu on 11.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import UIKit

public struct DeviceInfo {
    public static var name: String { return UIDevice.current.name }
    public static var uuid: String? { return UIDevice.current.identifierForVendor?.uuidString }
    public static var screenType: PhoneScreenType { return PhoneScreenType.initWithScreenHeight(UIScreen.main.bounds.size.height) }
    public static var isIpad: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

public struct OperatingSystemInfo {
    public static var version: Float = UIDevice.current.systemVersion.floatValue
    public static var isIos9: Bool = version >= 9 && version < 10
    public static var isIos10: Bool = version >= 10 && version < 11
    public static var isIos11: Bool = version >= 11 && version < 12
    public static var isIos12: Bool = version >= 12 && version < 13
}
