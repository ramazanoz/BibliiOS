//
//  SLHTabView.swift
//  AkeadMobile
//
//  Created by Salih Topcu on 09/03/2017.
//  Copyright © 2017 Akead Bilisim. All rights reserved.
//

import UIKit

public protocol SLHTabViewDelegate: NSObjectProtocol {
    func numberOfTabs(view: SLHTabView) -> Int
    func titleForTab(view: SLHTabView, index: Int) -> String
    func viewForTabContent(view: SLHTabView, index: Int, bounds: CGRect) -> UIView?
}

public extension SLHTabViewDelegate {
    func didDisplayTab(view: SLHTabView, oldIndex: Int, newIndex: Int) { }
}


public class SLHTabView: UIView {
    private var delegate: SLHTabViewDelegate
    
    private var isFirstLoad = true
    private var tabButtonsScrollView: UIScrollView!
    private var buttonIndicator: UIView!
    private var tabButtons = [UIButton]()
    private var tabContents = [UIView]()
    private var currentTabIndex: Int = -1
    //    private var contentContainer: UIView!
    
    public var tabButtonHeight: CGFloat = 40
    public var tabButtonMinWidth: CGFloat = 100
    public var tabButtonBackgroundColor: UIColor = UIColor.darkGray
    public var tabButtonSelectedBackgroundColor: UIColor = UIColor.gray
    public var tabButtonTitleColor: UIColor = UIColor.white
    public var tabButtonSelectedTitleColor: UIColor = UIColor.white
    public var tabButtonTitleFontSize: CGFloat = 12
    public var activeTabButtonIndicatorColor = UIColor.red
    
    
    public init(frame: CGRect, delegate: SLHTabViewDelegate) {
        self.delegate = delegate
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        if isFirstLoad {
            self.tabButtonsScrollView = UIScrollView(frame: self.bounds)
            self.tabButtonsScrollView.height = self.tabButtonHeight
            self.tabButtonsScrollView.bounces = false
            self.tabButtonsScrollView.showsHorizontalScrollIndicator = false
            self.addSubview(self.tabButtonsScrollView)
            
            let tabCount = self.delegate.numberOfTabs(view: self)
            let buttonWidth = max(self.frame.width / CGFloat(tabCount), self.tabButtonMinWidth)
            var buttonLeft: CGFloat = 0
            
            self.tabButtons = [UIButton]()
            for i in 0 ..< tabCount {
                let button = UIButton(frame: CGRect(x: buttonLeft, y: 0, width: buttonWidth, height: self.tabButtonHeight))
                button.setTitle(self.delegate.titleForTab(view: self, index: i), for: .normal)
                button.backgroundColor = self.tabButtonBackgroundColor
                button.setTitleColor(self.tabButtonTitleColor, for: .normal)
                button.titleLabel!.textAlignment = .center
                button.titleLabel?.numberOfLines = 2
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: self.tabButtonTitleFontSize)
                button.tag = i
                button.addTarget(self, action: #selector(tabButtonAction(_:)), for: .touchUpInside)
                self.tabButtonsScrollView.addSubview(button)
                self.tabButtons.append(button)
                
                buttonLeft += buttonWidth
            }
            tabButtonsScrollView.contentSize = CGSize(width: buttonLeft, height: self.tabButtonHeight)
            
            self.buttonIndicator = UIView(frame: CGRect(x: 0, y: self.tabButtonHeight - 2.5, width: buttonWidth, height: 2.5))
            self.buttonIndicator.backgroundColor = self.activeTabButtonIndicatorColor
            self.tabButtonsScrollView.addSubview(self.buttonIndicator)
            
            //            self.contentContainer = UIView(frame: CGRect(x: 0, y: self.tabButtonHeight, width: self.frame.width, height: self.frame.height - self.tabButtonHeight))
            //            self.contentContainer.layer.masksToBounds = true
            //            self.addSubview(contentContainer)
            
            self.tabContents = [UIView]()
            let contentFrame = CGRect(x: 0, y: self.tabButtonHeight, width: self.frame.width, height: self.frame.height - self.tabButtonHeight)
            for _ in 0 ..< tabCount {
                let contentView = UIView(frame: contentFrame)
                contentView.layer.masksToBounds = true
                self.addSubview(contentView)
                self.tabContents.append(contentView)
            }
            
            if tabCount > 0 {
                if self.currentTabIndex < 0 {
                    currentTabIndex = 0
                }
                self.displayTab(index: currentTabIndex)
            }
            self.isFirstLoad = false
        }
    }
    
    @objc private func tabButtonAction(_ sender: UIButton) {
        self.displayTab(index: sender.tag)
    }
    
    private func displayTab(index: Int) {
        if index >= 0 && index < self.tabButtons.count && (self.tabContents[index].subviews.count == 0 || index != self.currentTabIndex) {
            for i in 0 ..< self.tabButtons.count {
                self.tabButtons[i].backgroundColor = self.tabButtonBackgroundColor
                self.tabButtons[i].setTitleColor(self.tabButtonTitleColor, for: .normal)
                if i < self.tabContents.count {
                    self.tabContents[i].isHidden = true
                }
            }
            self.tabButtons[index].backgroundColor = self.tabButtonSelectedBackgroundColor
            self.tabButtons[index].setTitleColor(self.tabButtonSelectedTitleColor, for: .normal)
            self.tabContents[index].isHidden = false
            let oldIndex = self.currentTabIndex
            self.currentTabIndex = index
            if self.tabContents[index].subviews.count == 0 {
                self.refreshTabContent(index: index)
            }
            self.delegate.didDisplayTab(view: self, oldIndex: oldIndex, newIndex: index)
            self.tabButtonsScrollView.scrollRectToVisible(self.tabButtons[index].frame, animated: true)
            SLHAnimationManager(view: self.buttonIndicator, hasLoop: false, milestones: [AnimationMilestone(duration: 0.3, frame: CGRect(x: self.tabButtons[index].frame.origin.x, y: self.buttonIndicator.top, width: self.buttonIndicator.width, height: self.buttonIndicator.height))]).animate()
        }
    }
    
    public func refreshTabContent(index: Int) {
        if index >= 0 && index < self.tabButtons.count {
            for view in self.tabContents[index].subviews {
                view.removeFromSuperview()
            }
            let innerContent = self.delegate.viewForTabContent(view: self, index: index, bounds: self.tabContents[index].bounds)
            if innerContent != nil {
                self.tabContents[index].addSubview(innerContent!)
                if (innerContent!.frame == CGRect.null) {
                    innerContent?.setSuperViewAsConstraint()
                }
            }
        }
    }
    
    public func getCurrentTabIndex() -> Int {
        return self.currentTabIndex
    }
    
    public func redrawView() {
        self.isFirstLoad = true
    }
}
