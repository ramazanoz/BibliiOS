//
//  Extension.swift
//  BibliOS
//
//  Created by Salih Topcu on 8.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Foundation
import UIKit

// MARK: -
extension String {
    
    var length: Int { return self.count }
    
    var isNotEmpty: Bool { return !self.isEmpty }
    
    var floatValue: Float { return (self as NSString).floatValue }
    
    var doubleValue: Double { return (self as NSString).doubleValue }
    
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let range = self.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    var isNotEmail: Bool { return !self.isEmail }
    
    func trim() -> String { return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
    
    func toUrlString() -> String { return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! }
    
    func toUIColor() -> UIColor {
        let cString = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercase()
        if cString.count != 6 && cString.count != 8 { return UIColor.gray }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        var aString = ""
        if (cString.count == 8) { aString = ((cString as NSString).substring(from: 6) as NSString).substring(to: 2) }
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0, a:CUnsignedInt = 1;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        if aString.isNotEmpty { Scanner(string: aString).scanHexInt32(&a) }
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a))
    }
    
    func toDate(_ format: String) -> Date? { // sample: "yyyy.MM.dd hh:mm:ss"
        return DateUtil.createDate(date: self, format: format)
    }
    
    func replace(_ from: String, to: String) -> String { return self.replacingOccurrences(of: from, with: to, options: NSString.CompareOptions.literal, range: nil) }
    
    private func uppercase(languageCode: String = "en") -> String {
        return self.uppercased(with: Locale(identifier: languageCode))
    }
    
    // index and range functions:
    //    let str = "Hello, playground, playground, playground"
    
    //    str.index(of: "play")      // 7
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    
    //    str.endIndex(of: "play")   // 11
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    
    //    str.indexes(of: "play")    // [7, 19, 31]
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    
    //    str.ranges(of: "play")     // [{lowerBound 7, upperBound 11}, {lowerBound 19, upperBound 23}, {lowerBound 31, upperBound 35}]
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
}

// MARK: -
extension Bool {
    var intValue: Int { return self ? 1 : 0 }
}

// MARK: -
extension Int {
    var boolValue: Bool { return self > 0 ? true : false }
}

// MARK: -
extension Float {
    
    var isInteger: Bool { return floor(self) == self }
    
    func formattedStringValue(_ decimalCount: Int) -> String {
        return String(format: "%.\(decimalCount)f", self)
    }
    
    func formattedValue(_ decimalCount: Int) -> Float {
        return String(format: "%.\(decimalCount)f", self).floatValue
    }
}

// MARK: -
extension Double {
    
    var intValue: Int { return Int(self) }
    
    var isInteger: Bool { return floor(self) == self }
    
    func formattedValueAsString(_ decimalCount: Int) -> String {
        return String(format: "%.\(decimalCount)f", self)
    }
    
    func formattedValue(_ decimalCount: Int) -> Double {
        return String(format: "%.\(decimalCount)f", self).doubleValue
    }
    
    func formattedStringValue(_ decimalCount: Int) -> String {
        return String(format: "%.\(decimalCount)f", self)
    }
}


// MARK: -
extension NSCoder {
    func decodeString(forKey: String) -> String {
        return self.decodeObject(forKey: forKey) as? String ?? ""
    }
}

// MARK: -
extension Array {
    
    func forEach(_ doThis: (_ element: Element) -> Void) {
        for e in self {
            doThis(e)
        }
    }
    
    public func toString(container: String = "", seperator: String = ",") -> String {
        var result = ""
        for i in 0..<self.count {
            result += container + "\(self[i])" + container
            if i < self.count - 1 {
                result += seperator
            }
        }
        return result
    }
}

// MARK: -
extension Date {
    func toString(_ format: String = "yyyy-MM-dd hh:mm:ss") -> String {
        return DateUtil.getDateFormatter(format: format).string(from: self)
    }
}

// MARK: -
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) { self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff) }
}

// MARK: -
extension CALayer {
    func addShadow(_ color: UIColor? = UIColor.black, opacity: Float? = 0.2, x: CGFloat? = 0, y: CGFloat? = 0, radius: CGFloat? = 3, spread: CGFloat? = 0, masksToBounds: Bool? = false) -> CALayer {
        self.masksToBounds = masksToBounds!
        self.shadowColor = color?.cgColor
        self.shadowOffset = CGSize(width: x!, height: y!)
        self.shadowOpacity = opacity!
        self.shadowRadius = radius!
        if (spread == 0) {
            self.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        } else {
            self.shadowPath = UIBezierPath(rect: CGRect(x: self.bounds.origin.x - spread!, y: self.bounds.origin.y - spread!, width: self.bounds.width + 2 * spread!, height: self.bounds.height + 2 * spread!)).cgPath
        }
        return self
    }
}

// MARK: -
extension CAGradientLayer {
    func getLayerWithColors(top: UIColor, bottom: UIColor) -> CAGradientLayer {
        let gradientColors: [CGColor] = [top.cgColor, bottom.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        //        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        return gradientLayer
    }
    
    func getGradientLayer(top: UIColor, bottom: UIColor, frame: CGRect, cornerRadius: CGFloat) -> CAGradientLayer {
        let gradientColors: [CGColor] = [top.cgColor, bottom.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        gradientLayer.frame = frame
        gradientLayer.cornerRadius = cornerRadius
        //        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        return gradientLayer
    }
}

// MARK: -
extension UIView {

    var width: CGFloat {
        get { return self.frame.size.width }
        set(value) { self.frame.size.width = value }
    }
    
    var height: CGFloat {
        get { return self.frame.height }
        set(value) { self.frame.size.height = value }
    }
    
    var left: CGFloat {
        get { return self.frame.origin.x }
        set(value) { self.frame.origin.x = value }
    }
    
    var top: CGFloat {
        get { return self.frame.origin.y }
        set(value) { self.frame.origin.y = value }
    }
    
    var right: CGFloat {
        get { return self.left + self.width }
        set(value) { self.left = value + self.width }
    }
    
    var bottom: CGFloat {
        get { return self.top + self.height }
        set(value) { self.top = value - self.height }
    }
    
    var isVisible: Bool {
        get { return self.isHidden }
        set(value) { self.isHidden = !value }
    }

    func addShadow(_ color: UIColor? = UIColor.black, opacity: Float? = 0.2, x: CGFloat? = 0, y: CGFloat? = 0, radius: CGFloat? = 3, spread: CGFloat? = 0, masksToBounds: Bool? = false) {
        _ = self.layer.addShadow(color, opacity: opacity, x: x, y: y, radius: radius, spread: spread, masksToBounds: masksToBounds)
    }
    
    func addBorder(color clr: UIColor = UIColor.gray, size: CGFloat = 1) {
        self.layer.borderColor = clr.cgColor
        self.layer.borderWidth = size
    }
    
    func makeCircle() {
        self.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2
        self.layer.masksToBounds = true
    }
    
    func setCornerRadius(value: CGFloat, corners: UIRectCorner) {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: value, height: value)).cgPath
        self.layer.mask = rectShape
    }
    
    func fadeIn(_ duration: Double = 0.3, alpha: CGFloat = 1) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        })
    }
    
    func fadeOut(_ duration: Double = 0.3, alpha: CGFloat = 0) {
        self.isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        }, completion: { value in
            self.isHidden = true
        })
    }
    
    func replaceWith(_ view: UIView, duration: TimeInterval = 0.1) {
        UIView.transition(from: self, to: view, duration: duration, options: UIView.AnimationOptions.transitionCrossDissolve, completion: nil)
    }
    
    func addGradientBackground(topColor: UIColor, bottomColor: UIColor, bgFrame: CGRect? = nil) {
        let bg = CAGradientLayer().getLayerWithColors(top: topColor, bottom: bottomColor)
        bg.frame = bgFrame ?? CGRect(x: -0.5, y: 0, width: self.width + 1, height: self.height)
        self.layer.insertSublayer(bg, at: 0)
    }
}

// MARK: -
extension UIImageView {
    func fillToSuperview() {
        if self.image != nil && self.superview != nil {
            self.width = self.image!.size.width
            self.height = self.image!.size.height
            let imageRatio = self.width / self.height
            let containerRatio = self.superview!.width / self.superview!.height
            if imageRatio > containerRatio {
                let newWidth = self.width * (self.superview!.height / self.height)
                self.top = 0
                self.left = -(newWidth - self.superview!.width) / 2
                self.frame = CGRect(
                    x: -(newWidth - self.superview!.width) / 2,
                    y: 0,
                    width: self.width * (self.superview!.height / self.height),
                    height: self.superview!.height
                )
            } else {
                let newHeight = self.height * (self.superview!.width / self.width)
                self.left = 0
                self.top = -(newHeight - self.superview!.height) / 2
                self.frame = CGRect(
                    x: 0,
                    y: -(newHeight - self.superview!.height) / 2,
                    width: self.superview!.width,
                    height: newHeight)
            }
            self.superview!.layer.masksToBounds = true
        }
    }
    
    func fitToSuperview() {
        if self.image != nil && self.superview != nil {
            let superViewSizeRate = self.superview!.width / self.superview!.height
            let sizeRate = self.image!.size.width / self.image!.size.height
            if sizeRate > superViewSizeRate {
                self.frame = CGRect(
                    x: 0,
                    y: (self.superview!.height - self.height) / 2,
                    width: self.superview!.width,
                    height: self.height * (self.superview!.width / self.width)
                )
            } else {
                self.frame = CGRect(
                    x: (self.superview!.width - self.width) / 2,
                    y: 0,
                    width: self.width * (self.superview!.height / self.height),
                    height: self.superview!.height
                )
            }
        }
    }
    
    func overlayWithColor(color: UIColor) {
        if self.image != nil {
            self.image = self.image!.withRenderingMode(.alwaysTemplate)
            self.tintColor = color
        }
    }
}

// MARK: -
extension UIImage {
    func fitToSize(_ size: CGSize) -> UIImage {
        let newWidth: CGFloat!
        let newHeight: CGFloat!
        let imageRatio = self.size.width / self.size.height
        let sizeRatio = size.width / size.height
        if imageRatio > sizeRatio {
            newWidth = size.width // min(size.width, self.width)
            newHeight = self.size.height * (newWidth / self.size.width)
        } else {
            newHeight = size.height // min(size.height, self.height)
            newWidth = self.size.width * (newHeight / self.size.height)
        }
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

// MARK: -
extension UILabel {
    
    func setRequiredSize() {
        let frame = self.frame
        self.width = CGFloat.greatestFiniteMagnitude
        self.height = CGFloat.greatestFiniteMagnitude
        self.sizeToFit()
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: self.width, height: self.height)
    }
    
    func setRequiredHeight() {
        let frame = self.frame
        self.height = CGFloat.greatestFiniteMagnitude
        self.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.sizeToFit()
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: self.height)
    }
    
    func setRequiredWidth() {
        let frame = self.frame
        self.width = CGFloat.greatestFiniteMagnitude
        self.sizeToFit()
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: self.width, height: frame.size.height)
    }
    
    func setFont(_ name: String? = nil, size: CGFloat? = nil) {
        if name != nil || size != nil {
            self.font = UIFont(name: name ?? self.font.fontName, size: size ?? self.font.pointSize)
        }
    }
    
    func setFont(for targetText: String, fontName: String? = nil, fontSize: CGFloat? = nil, color: UIColor? = nil) {
        if self.attributedText != nil {
            let attributedString = NSMutableAttributedString(attributedString: self.attributedText!)
            let mainText: NSString = (self.text ?? "") as NSString
            let range: NSRange = mainText.range(of: targetText)
            let font = UIFont(name: fontName ?? self.font.fontName, size: fontSize ?? self.font.pointSize)
            if font != nil {
                
                attributedString.addAttribute(NSAttributedString.Key.font, value: font!, range: range)
            }
            if color != nil {
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color!, range: range)
            }
            self.attributedText = attributedString
        }
    }
    
    func setFontSize(_ size: CGFloat) {
        if self.font != nil {
            self.font = UIFont(name: self.font!.fontName, size: size)
        }
    }
    
    func increaseFontSize(_ sizeDifference: CGFloat = 1) {
        if self.font != nil {
            self.font = UIFont(name: self.font!.fontName, size: self.font.pointSize + sizeDifference)
        }
    }
    
    func decreaseFontSize(_ sizeDifference: CGFloat = 1) {
        self.increaseFontSize(-sizeDifference)
    }
}
