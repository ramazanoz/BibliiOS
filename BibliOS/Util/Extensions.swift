//
//  Extensions.swift
//  BibliOS
//
//  Created by Salih Topcu on 10.03.2019.
//  Copyright © 2019 Akead Bilişim. All rights reserved.
//

import Foundation

// MARK: - Foundation

public extension Date {
    
    func toString(_ format: String = "yyyy-MM-dd hh:mm:ss") -> String {
        return DateUtil.getSharedDateFormatter(format: format).string(from: self)
    }
    
    func toDayDate(_ format: String = "yyyy-MM-dd") -> Date? { return DateUtil.createDate(date: self.addingTimeInterval(86400).toString(format), format: format) }
    
}

public extension NSCoder {
    
    func decodeString(forKey: String) -> String {
        return self.decodeObject(forKey: forKey) as? String ?? ""
    }
    
}

public extension URL {
    
    func deleteFile() {
        do {
            try FileManager.default.removeItem(at: self)
        } catch {
            NSLog("File could not be deleted.")
        }
    }
    
    func getKeyVals() -> Dictionary<String, String>? {
        var results = [String:String]()
        let keyValues = self.query?.components(separatedBy: "&")
        if keyValues?.count ?? 0 > 0 {
            for pair in keyValues! {
                let kv = pair.components(separatedBy: "=")
                if kv.count > 1 {
                    results.updateValue(kv[1], forKey: kv[0])
                }
            }
        }
        return results
    }
    
    func getQuerystring(_ key: String) -> String? {
        let dict: Dictionary? = self.getKeyVals()
        if dict != nil {
            return dict![key]
        } else {
            return nil
        }
    }
}

// MARK: - QuartzCore

public extension CAGradientLayer {
    
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

public extension CALayer {
    
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

// MARK: - Swift

public extension Array {
    
    func forEach(_ doThis: (_ item: Element) -> Void) {
        for i in self {
            doThis(i)
        }
    }
    
    func getItem(at index: Int) -> Any? {
        return self.count > index ? self[index] : nil
    }
    
    func toString(container: String = "", seperator: String = ",") -> String {
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

public extension Bool {
    
    var intValue: Int { return self ? 1 : 0 }
    
}

public extension Double {
    
    var intValue: Int { return Int(self) }
    
    var isInteger: Bool { return floor(self) == self }
	
	func formattedStringValue(_ decimalCount: Int) -> String {
		return String(format: "%.\(decimalCount)f", self.formattedValue(decimalCount))
	}
	
	func formattedValue(_ decimalCount: Int) -> Double {
		return (self * pow(10.0, Double(decimalCount))).rounded() / pow(10.0, Double(decimalCount))
	}
    
	func stringValue(trimDecimalIfInt: Bool = false) -> String {
		return self.isInteger ? String(self.intValue) : String(self)
	}
}

public extension Float {
    
    var isInteger: Bool { return floor(self) == self }
    
    func formattedStringValue(_ decimalCount: Int) -> String {
        return String(format: "%.\(decimalCount)f", self)
    }
    
    func formattedValue(_ decimalCount: Int) -> Float {
        return String(format: "%.\(decimalCount)f", self).floatValue
    }
}

public extension Int {
    
    var boolValue: Bool { return self > 0 ? true : false }
    
}

public extension String {
    
    var length: Int { return self.count }
    
    var doubleValue: Double { return (self as NSString).doubleValue }
    
    var floatValue: Float { return (self as NSString).floatValue }
    
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let range = self.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    var isNotEmail: Bool { return !self.isEmail }
    
    var isNotEmpty: Bool { return !self.isEmpty }
    
    var trimmed: String { return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
    
    var uiColor: UIColor {
        let cString = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercase()
        if cString.length != 6 && cString.length != 8 { return UIColor.gray }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        var aString = ""
        if (cString.length == 8) { aString = ((cString as NSString).substring(from: 6) as NSString).substring(to: 2) }
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0, a:CUnsignedInt = 1;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        if aString.isNotEmpty { Scanner(string: aString).scanHexInt32(&a) }
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a))
    }
    
    var urlEncoded: String { return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! }
    
    func replace(_ from: String, to: String) -> String { return self.replacingOccurrences(of: from, with: to, options: NSString.CompareOptions.literal, range: nil) }
    
    func toDate(_ format: String) -> Date? { // sample: "yyyy.MM.dd hh:mm:ss"
        return DateUtil.createDate(date: self, format: format)
    }
    
    func localize(languageCode: String) -> String {
        let lang = languageCode.isNotEmpty ? languageCode : "en"
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = path != nil ? Bundle(path: path!) : nil
        return bundle != nil ? self.localize(bundle: bundle!) : self
    }
    
    func localize(bundle: Bundle) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value:"", comment: "")
    }
    
    func uppercase(languageCode: String = "en") -> String {
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

// MARK: - UIKit

public extension UIApplication {
    
    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 384824583
            if let statusBar = self.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBarView.tag = tag
                self.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else {
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
    
}

public extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) { self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff) }
    
}

public extension UIImage {
    
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
	
	func withInset(_ insets: UIEdgeInsets) -> UIImage? {
		let cgSize = CGSize(width: self.size.width + insets.left * self.scale + insets.right * self.scale,
							height: self.size.height + insets.top * self.scale + insets.bottom * self.scale)
		
		UIGraphicsBeginImageContextWithOptions(cgSize, false, self.scale)
		defer { UIGraphicsEndImageContext() }
		
		let origin = CGPoint(x: insets.left * self.scale, y: insets.top * self.scale)
		self.draw(at: origin)
		
		return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(self.renderingMode)
	}
    
}

public extension UIImageView {
    
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
                self.height = self.height * (self.superview!.width / self.width)
                self.top = (self.superview!.height - self.height) / 2
                self.left = 0
                self.width = self.superview!.width
            } else {
                self.width = self.width * (self.superview!.height / self.height)
                self.left = (self.superview!.width - self.width) / 2
                self.top = 0
                self.height = self.superview!.height
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

public extension UILabel {
    
    func decreaseFontSize(_ sizeDifference: CGFloat = 1) {
        self.increaseFontSize(-sizeDifference)
    }
    
    func increaseFontSize(_ sizeDifference: CGFloat = 1) {
        if self.font != nil {
            self.font = UIFont(name: self.font!.fontName, size: self.font.pointSize + sizeDifference)
        }
    }
    
    func setFont(_ name: String? = nil, size: CGFloat? = nil) {
        if name != nil || size != nil {
            self.font = UIFont(name: name ?? self.font.fontName, size: size ?? self.font.pointSize)
        }
    }
    
    func setFont(ofTargetText targetText: String, fontName: String? = nil, fontSize: CGFloat? = nil, color: UIColor? = nil) {
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
    
    func setRequiredHeight() {
        let frame = self.frame
        self.height = CGFloat.greatestFiniteMagnitude
        self.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.sizeToFit()
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: self.height)
    }
    
    func setRequiredSize() {
        let frame = self.frame
        self.width = CGFloat.greatestFiniteMagnitude
        self.height = CGFloat.greatestFiniteMagnitude
        self.sizeToFit()
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: self.width, height: self.height)
    }
    
	func setRequiredWidth(insetSize: CGFloat = 0) {
        let frame = self.frame
        self.width = CGFloat.greatestFiniteMagnitude
        self.sizeToFit()
		self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: self.width + insetSize, height: frame.size.height)
    }
    
}

public extension UINavigationController {
    func popAllViewConterollers(animated: Bool) {
        let viewControllers: [UIViewController]? = self.navigationController?.viewControllers
        if viewControllers != nil {
            for i in viewControllers!.count...1 {
                self.navigationController!.popToViewController(viewControllers![i - 1], animated: animated)
            }
        }
    }
    
    func setStatusBarColor(_ color: UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = color
        view.addSubview(statusBarView)
    }
}

public extension UISwitch {
    
    var isOff: Bool { return !self.isOn }
    
}

public extension UIView {
    
    var bottom: CGFloat {
        get { return self.top + self.height }
        set(value) { self.top = value - self.height }
    }
    
    var height: CGFloat {
        get { return self.frame.height }
        set(value) { self.frame.size.height = value }
    }
    
    var isVisible: Bool {
        get { return self.isHidden }
        set(value) { self.isHidden = !value }
    }
    
    var left: CGFloat {
        get { return self.frame.origin.x }
        set(value) { self.frame.origin.x = value }
    }
    
    var right: CGFloat {
        get { return self.left + self.width }
        set(value) { self.left = value - self.width }
    }
    
    var top: CGFloat {
        get { return self.frame.origin.y }
        set(value) { self.frame.origin.y = value }
    }
    
    var width: CGFloat {
        get { return self.frame.size.width }
        set(value) { self.frame.size.width = value }
    }
    
    func addBorder(color clr: UIColor = UIColor.gray, size: CGFloat = 1) {
        self.layer.borderColor = clr.cgColor
        self.layer.borderWidth = size
    }
    
    func addGradientBackground(topColor: UIColor, bottomColor: UIColor, bgFrame: CGRect? = nil) {
        let bg = CAGradientLayer().getLayerWithColors(top: topColor, bottom: bottomColor)
        bg.frame = bgFrame ?? CGRect(x: -0.5, y: 0, width: self.width + 1, height: self.height)
        self.layer.insertSublayer(bg, at: 0)
    }
    
    func addShadow(_ color: UIColor? = UIColor.black, opacity: Float? = 0.2, x: CGFloat? = 0, y: CGFloat? = 0, radius: CGFloat? = 3, spread: CGFloat? = 0, masksToBounds: Bool? = false) {
        _ = self.layer.addShadow(color, opacity: opacity, x: x, y: y, radius: radius, spread: spread, masksToBounds: masksToBounds)
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
    
    func makeCircle() {
        self.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2
        self.layer.masksToBounds = true
    }
    
    func moveTo(left: CGFloat? = nil, top: CGFloat? = nil, duration: Double = 0.3, completion: SomeAction? = nil) {
        UIView.animate(withDuration: duration, animations: {
            if left != nil {
                self.left = left!
            }
            if top != nil {
                self.top = top!
            }
        }, completion: { finished in
            completion?()
        })
    }
    
    func replaceWith(_ view: UIView, duration: TimeInterval = 0.1) {
        UIView.transition(from: self, to: view, duration: duration, options: UIView.AnimationOptions.transitionCrossDissolve, completion: nil)
    }
    
    private func resize(width: CGFloat? = nil, height: CGFloat? = nil, duration: Double, completion: SomeAction?) {
        UIView.animate(withDuration: duration, animations: {
            if width != nil {
                self.width = width!
            }
            if height != nil {
                self.height = height!
            }
        }, completion: { finished in
            completion?()
        })
    }
    
    func resizeTo(width: CGFloat, duration: Double = 0.3, completion: SomeAction? = nil) {
        self.resize(width: width, height: nil, duration: duration, completion: completion)
    }
    
    func resizeTo(height: CGFloat, duration: Double = 0.3, completion: SomeAction? = nil) {
        self.resize(width: nil, height: height, duration: duration, completion: completion)
    }
    
    func resizeTo(width: CGFloat, height: CGFloat, duration: Double = 0.3, completion: SomeAction? = nil) {
        self.resize(width: width, height: height, duration: duration, completion: completion)
    }
    
    func setCornerRadius(value: CGFloat, corners: UIRectCorner) {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: value, height: value)).cgPath
        self.layer.mask = rectShape
    }
    
    @discardableResult func setConstraints(anchorSet: AnchorSet, paddingValueSet: PaddingValueSet? = nil, enableInsets: Bool = false) -> (NSLayoutConstraint?, NSLayoutConstraint?, NSLayoutConstraint?, NSLayoutConstraint?) {
        var topConstraint: NSLayoutConstraint?
        var rightConstraint: NSLayoutConstraint?
        var bottomConstraint: NSLayoutConstraint?
        var leftConstraint: NSLayoutConstraint?
        
        var topInset = CGFloat(0)
        var bottomInset = CGFloat(0)
        
        if #available(iOS 11, *), enableInsets {
            let insets = self.safeAreaInsets
            topInset = insets.top
            bottomInset = insets.bottom
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = anchorSet.top {
            topConstraint = self.topAnchor.constraint(equalTo: top, constant: paddingValueSet?.top ?? 0 + topInset)
            topConstraint?.activate()
        }
        if let right = anchorSet.right {
            rightConstraint = rightAnchor.constraint(equalTo: right, constant: -(paddingValueSet?.right ?? 0))
            rightConstraint?.activate()
        }
        if let bottom = anchorSet.bottom {
            bottomConstraint = bottomAnchor.constraint(equalTo: bottom, constant: -(paddingValueSet?.bottom ?? 0) - bottomInset)
            bottomConstraint?.activate()
        }
        if let left = anchorSet.left {
            leftConstraint = self.leftAnchor.constraint(equalTo: left, constant: paddingValueSet?.left ?? 0)
            leftConstraint?.activate()
        }
        return (topConstraint, rightConstraint, bottomConstraint, leftConstraint)
    }
    
    @discardableResult func setConstraints(_ anchorSet: AnchorSet, _ paddingValueSet: PaddingValueSet? = nil, enableInsets: Bool = false) -> (NSLayoutConstraint?, NSLayoutConstraint?, NSLayoutConstraint?, NSLayoutConstraint?) {
        return self.setConstraints(anchorSet: anchorSet, paddingValueSet: paddingValueSet, enableInsets: enableInsets)
    }
    
    @discardableResult func setConstraintView(_ view: UIView, paddingValueSet: PaddingValueSet? = nil, enableInsets: Bool = false) -> (NSLayoutConstraint?, NSLayoutConstraint?, NSLayoutConstraint?, NSLayoutConstraint?) {
        return self.setConstraints(anchorSet: AnchorSet(top: view.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor), paddingValueSet: paddingValueSet)
    }
    
    @discardableResult func setSuperViewAsConstraint(paddingValueSet: PaddingValueSet? = nil) -> (NSLayoutConstraint?, NSLayoutConstraint?, NSLayoutConstraint?, NSLayoutConstraint?) {
        if self.superview != nil {
            return self.setConstraintView(self.superview!, paddingValueSet: paddingValueSet)
        } else {
            return (nil, nil, nil, nil)
        }
    }
    
    func setSizeConstraints(width: CGFloat?, height: CGFloat?) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if height != nil {
            heightAnchor.constraint(equalToConstant: height!).activate()
        }
        if width != nil {
            widthAnchor.constraint(equalToConstant: width!).activate()
        }
    }
    
}

extension NSLayoutConstraint {
    
    func activate() {
        self.isActive = true
    }
    
    func deactivate() {
        self.isActive = false
    }
    
}

public extension UIViewController {
    
    func dismissPresentedViewController(animated: Bool = false, forceToDismiss: Bool = true, completion: (() -> Void)? = nil) {
        debugPrint("UIViewController.dismissPresentedViewController")
        if self.presentedViewController == nil {
//            debugPrint("no presentedViewController")
            completion?()
        } else {
            if self.presentedViewController!.presentedViewController == nil {
//                debugPrint("presentedViewController dismissed")
                self.presentedViewController!.dismiss(animated: animated, completion: completion)
            } else if (forceToDismiss) {
//                debugPrint("will try to dismiss grand presentedViewController")
                self.presentedViewController!.dismissPresentedViewController(animated: false, completion: {
                    self.presentedViewController!.dismiss(animated: animated, completion: completion)
                })
            } else {
//                debugPrint("won't dismiss any presentedViewController")
            }
        }
    }
    
    func isPresented(ownerViewController: UIViewController) -> Bool {
        return ownerViewController.presentedViewController != nil && ownerViewController.presentedViewController == self
    }
    
    func isDismissed(ownerViewController: UIViewController) -> Bool {
        return ownerViewController.presentedViewController != self
    }
    
    func isPresentable(viewController: UIViewController) -> Bool {
        return self.presentedViewController == nil && self.presentingViewController == nil && !viewController.isBeingDismissed
    }
    
    func isDismissable(viewController: UIViewController) -> Bool {
        return self.presentedViewController == viewController
    }
    
}
