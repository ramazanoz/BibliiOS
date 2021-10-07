//
//  SLHIconButton.swift
//  BibliOS
//
//  Created by Salih Topcu on 2.10.2021.
//  Copyright © 2021 Akead Bilişim. All rights reserved.
//

import UIKit

public typealias Badge = (size: CGFloat, color: UIColor, textColor: UIColor)

public class SLHIconButton: UIButton {
	private var badge: Badge?
	
	private var badgeLabel: UILabel?
	private var badgeCornerRadiusApplied: Bool = false
	
	public var badgeText: String = "" {
		didSet {
			self.badgeLabel?.text = self.badgeText
			self.badgeCornerRadiusApplied = false
		}
	}
	
	public var badgeVisibality: Bool = true {
		didSet {
			self.badgeLabel?.isHidden = !self.badgeVisibality
		}
	}

	public init(withImage image: UIImage?, frame: CGRect? = nil, imageInsets: UIEdgeInsets? = nil) {
		super.init(frame: frame ?? CGRect.null)
		super.setImage(image, for: UIControl.State())
		if let ins = imageInsets {
			super.imageEdgeInsets = ins
		}
	}
	
	public convenience init(withImage
					 image: UIImage?,
					 frame: CGRect? = nil,
					 imageInsetValue: CGFloat? = nil) {
		self.init(
			withImage: image,
			frame: frame,
			imageInsets: imageInsetValue == nil ? nil :
				UIEdgeInsets(
					top: imageInsetValue!,
					left: imageInsetValue!,
					bottom: imageInsetValue!,
					right: imageInsetValue!))
	}
	
	public convenience init(withBadge
					 badge: Badge,
					 image: UIImage?,
					 frame: CGRect? = nil,
					 imageInsets: UIEdgeInsets? = nil) {
		self.init(withImage: image, frame: frame, imageInsets: imageInsets)
		self.badge = badge
		self.badgeLabel = UILabel()
		self.addSubview(self.badgeLabel!)
		self.badgeLabel!.font = UIFont.systemFont(ofSize: badge.size)
		self.badgeLabel!.textAlignment = .center
		self.badgeLabel!.backgroundColor = badge.color
		self.badgeLabel!.textColor = badge.textColor
		self.badgeLabel!.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.badgeLabel!.rightAnchor.constraint(equalTo: self.rightAnchor),
			self.badgeLabel!.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.badgeLabel!.heightAnchor.constraint(equalToConstant: badge.size + 3.6),
			self.badgeLabel!.widthAnchor.constraint(equalToConstant: badge.size + 3.6),
		])
	}
	
	public convenience init(withBadge
					 badge: Badge,
					 image: UIImage?,
					 frame: CGRect? = nil,
					 imageInsetValue: CGFloat? = nil) {
		self.init(
			withBadge: badge,
			image: image,
			frame: frame,
			imageInsets: imageInsetValue == nil ? nil :
				UIEdgeInsets(
					top: imageInsetValue!,
					left: imageInsetValue!,
					bottom: imageInsetValue!,
					right: imageInsetValue!))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		if !self.badgeCornerRadiusApplied && self.badgeLabel != nil {
			self.badgeLabel!.setCornerRadius(
				value: (self.badge!.size + 2) / 2,
				corners: .allCorners)
			self.badgeCornerRadiusApplied = true
		}
	}
}
