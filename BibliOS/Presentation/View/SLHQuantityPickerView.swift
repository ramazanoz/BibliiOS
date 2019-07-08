//
//  SLHQuantityPickerView.swift
//  AkeadMobile
//
//  Created by Salih Topcu on 7.11.2017.
//  Copyright © 2017 Salih Topcu. All rights reserved.
//

import UIKit

public protocol SLHQuantityPickerViewDelegate {
    
    func mayQuantityChange(to value: Int, picker: SLHQuantityPickerView) -> Bool
    
    func quantityDidChange(to value: Int, picker: SLHQuantityPickerView)
    
}

extension SLHQuantityPickerViewDelegate {
    
    func mayQuantityChange(to value: Int, picker: SLHQuantityPickerView) -> Bool {
        return true
    }
    
}

public class SLHQuantityPickerView: UIView {
    
    public var minusButtonCanGoNegative = false
    public var delegate: SLHQuantityPickerViewDelegate?
    private var minusButton: UIButton!
    //    private var label: UILabel!
    private var number: UIButton!
    private var plusButton: UIButton!
    
    public var minusButtonBackgroundColor: UIColor? {
        didSet {
            self.minusButton.backgroundColor = minusButtonBackgroundColor
        }
    }
    
    public var plusButtonBackgroundColor: UIColor? {
        didSet {
            self.plusButton.backgroundColor = plusButtonBackgroundColor
        }
    }
    
    public var fontName: String! {
        didSet {
            //            self.label.font = UIFont(name: fontName, size: min(self.label.width, self.label.height) - 8)
            self.number.titleLabel!.font = UIFont(name: fontName, size: min(self.number.width, self.number.height) * 0.6)
        }
    }
    
    public var textColor: UIColor! {
        didSet {
            self.number.setTitleColor(textColor, for: .normal)
        }
    }
    
    public init(frame: CGRect, minusButtonImage: UIImage, plusButtonImage: UIImage) {
        super.init(frame: frame)
        
        let buttonWidth = (frame.width / 11) * 3
        let labelWidth = (frame.width / 11) * 5
        var left: CGFloat = 0
        
        self.minusButton = UIButton(frame: CGRect(x: left, y: 0, width: buttonWidth, height: frame.height))
        self.minusButton.setImage(minusButtonImage, for: UIControl.State.normal)
        //        self.minusButton.imageView?.fitToSuperview()
        self.minusButton.imageView?.contentMode = .center
        self.minusButton.addTarget(self, action: #selector(minusButtonAction), for: UIControl.Event.touchUpInside)
        self.addSubview(self.minusButton)
        left = buttonWidth
        
        self.number = UIButton(frame: CGRect(x: left, y: 2, width: labelWidth, height: frame.height - 2))
        self.number.addTarget(self, action: #selector(plusButtonAction), for: UIControl.Event.touchUpInside)
        self.number.titleLabel?.font = UIFont.boldSystemFont(ofSize: min(self.number.width, self.number.height) * 0.6)
        self.number.setTitleColor(UIColor.darkGray, for: .normal)
        self.addSubview(self.number)
        left = buttonWidth + labelWidth
        
        //        self.label = UILabel(frame: CGRect(x: left, y: 0, width: labelWidth, height: frame.height))
        //        self.label.numberOfLines = 1
        //        self.label.textAlignment = .center
        //        self.label.isUserInteractionEnabled = true
        //        self.label.font = UIFont.boldSystemFont(ofSize: min(self.label.width, self.label.height) - 8)
        //        self.label.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(plusButtonAction)))
        //        self.addSubview(self.label)
        //        left = buttonWidth + labelWidth
        
        self.plusButton = UIButton(frame: CGRect(x: left, y: 0, width: buttonWidth, height: frame.height))
        self.plusButton.setImage(plusButtonImage, for: UIControl.State.normal)
        self.plusButton.imageView?.contentMode = .scaleAspectFit
        self.plusButton.addTarget(self, action: #selector(plusButtonAction), for: UIControl.Event.touchUpInside)
        self.minusButton.setImage(minusButtonImage, for: UIControl.State.normal)
        self.addSubview(self.plusButton)
        
        self.setQuantity(0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // does not run delegate's quantityDidChange function
    public func setQuantity(_ value: Int) {
        self.number.setTitle(String(value), for: UIControl.State.normal)
    }
    
    // runs delegate's quantityDidChange function
    public func updateQuantity(_ value: Int) {
        self.minusButton.isUserInteractionEnabled = false
        self.number.isUserInteractionEnabled = false
        self.plusButton.isUserInteractionEnabled = false
        self.setQuantity(value)
        self.delegate?.quantityDidChange(to: self.getQuantity(), picker: self)
        self.minusButton.isUserInteractionEnabled = true
        self.number.isUserInteractionEnabled = true
        self.plusButton.isUserInteractionEnabled = true
    }
    
    public func getQuantity() -> Int {
        return Int((self.number.titleLabel?.text)!) ?? 0
    }
    
    @objc private func minusButtonAction() {
        if minusButtonCanGoNegative || self.getQuantity() != 0 {
            if self.delegate?.mayQuantityChange(to: self.getQuantity() - 1, picker: self) ?? true {
                self.updateQuantity(self.getQuantity() - 1)
            }
        }
    }
    
    @objc private func plusButtonAction() {
        if self.delegate?.mayQuantityChange(to: self.getQuantity() + 1, picker: self) ?? true {
            self.updateQuantity(self.getQuantity() + 1)
        }
    }
}
