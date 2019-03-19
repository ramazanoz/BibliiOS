//
//  SLHSigningView.swift
//  AkeadMobile
//
//  Created by Salih Topcu on 16.03.2018.
//  Copyright © 2018 Salih Topcu. All rights reserved.
//

import UIKit

class SLHSigningView: UIView {
    private var lastPoint = CGPoint.zero
    private var brushWidth: CGFloat = 2.0
    private var opacity: CGFloat = 1.0
    private var imageView: UIImageView!
    private var swiped = false
    public var imageFormat: ImageFormat = .jpg
    public var image: UIImage? {
        return lastPoint == CGPoint.zero ? nil : self.imageView.image
    }
    public var imageData: Data? {
        if self.image != nil {
            if self.imageFormat == .jpg {
                return lastPoint == CGPoint.zero ? nil : self.image?.jpegData(compressionQuality: 0.5)
            } else {
                return lastPoint == CGPoint.zero ? nil : self.image?.pngData()
            }
        }
        return nil
    }
    private var text: NSString!
    
    init(frame: CGRect, text: NSString) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.text = text
        self.imageView = UIImageView(frame: super.bounds)
        self.addSubview(self.imageView)
        self.buildImage()
    }
    
    public func clear() {
        lastPoint = CGPoint.zero
        self.buildImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.swiped = false
        if let touch = touches.first {
            self.lastPoint = touch.location(in: self.imageView)
        }
        self.addDot(to: self.lastPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.imageView)
            drawLineFrom(from: lastPoint, to: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    func addDot(to point: CGPoint) {
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        self.imageView.image?.draw(in: self.imageView.bounds)
        
        context?.addArc(center: point, radius: self.brushWidth / 3, startAngle: 0, endAngle: 360, clockwise: true)
        context?.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
        context?.setBlendMode(.normal)
        context?.strokePath()
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        self.imageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    func drawLineFrom(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.imageView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        self.imageView.image?.draw(in: self.imageView.bounds)
        
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(self.brushWidth)
        context?.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
        context?.setBlendMode(.normal)
        context?.strokePath()
        
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        self.imageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    private func buildImage() {
        let dummyImage = UIImage()
        let point = CGPoint(x: 16, y: 16)
        let size = self.imageView.frame.size
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let textFontAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        dummyImage.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let rect = CGRect(origin: point, size: size)
        self.text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.imageView.image = newImage
    }
}
