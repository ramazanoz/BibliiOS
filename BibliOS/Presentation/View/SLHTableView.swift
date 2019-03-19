//
//  SLHTableView.swift
//  SafranStore
//
//  Created by RDC Partner on 27.05.2015.
//  Copyright (c) 2015 RDC Partner. All rights reserved.
//

import UIKit

public protocol SLHTableViewDelegate : NSObjectProtocol {
    func numberOfRowsInSection(_ tableView: SLHTableView, section: Int) -> Int
    func cellForRowAtIndexPath(_ tableView: SLHTableView, indexPath: IndexPath, cellIdentifier: String) -> UITableViewCell
}

public extension SLHTableViewDelegate {
    func didCellPressedLong(_ tableView: SLHTableView, cell: SLHTableViewCell, indexPath: IndexPath) {}
    func didActivateSelectionMode(_ tableView: SLHTableView) {}
    func onRefreshTableView(_ tableView: SLHTableView) {}
    func willBeginEditingRowAtIndexPath(_ tableView: SLHTableView, indexPath: IndexPath) {}
    func didEndEditingRowAtIndexPath(_ tableView: SLHTableView, indexPath: IndexPath?) {}
    
    // UITableViewDelegate
    func heightForHeaderInSection(_ tableView: SLHTableView, section: Int) -> CGFloat { return 0 }
    func heightForRowAtIndexPath(_ tableView: SLHTableView, indexPath: IndexPath) -> CGFloat { return 50 }
    func heightForFooterInSection(_ tableView: SLHTableView, section: Int) -> CGFloat { return 0 }
    func didSelectRowAtIndexPath(_ tableView: SLHTableView, indexPath: IndexPath) {}
    func didDeselectRowAtIndexPath(_ tableView: SLHTableView, indexPath: IndexPath) {}
    func canEditForRow(_ tableView: SLHTableView, indexPath: IndexPath) -> Bool { return false }
    func editingStyleForRow(_ tableView: SLHTableView, indexPath: IndexPath, style: UITableViewCell.EditingStyle) {}
    func editActionsForRow(_ tableView: SLHTableView, indexPath: IndexPath) -> [UITableViewRowAction]? { return nil }
    
    // UITableViewDataSource
    func numberOfSectionsInTableView(_ tableView: SLHTableView) -> Int { return 1 }
    func viewForHeaderInSection(_ tableView: SLHTableView, section: Int) -> UIView? { return nil }
    func viewForFooterInSection(_ tableView: SLHTableView, section: Int) -> UIView? { return nil }
    
    // UIScrollViewDelegate
    func didScroll(_ tableView: SLHTableView) {}
}

public class SLHTableView: UITableView, UITableViewDelegate, UITableViewDataSource, TableViewCellDelegate, UIScrollViewDelegate {
    var myRefreshControl: UIRefreshControl?
    var beforeRefreshText: String = ""
    var onRefreshText: String = ""
    var animColor: UIColor
    fileprivate var selectable: Bool = false
    fileprivate var selectionMode: Bool = false
    var reloadCounter = 0
    public var slhDelegate: SLHTableViewDelegate?
    var cellIdentifierFormat: String!
    fileprivate var messageLabel: UILabel?
    var messageText = "There is no item to display"
    
    var headerHeight: CGFloat?
    var rowHeight2: CGFloat?
    var footerHeight: CGFloat?
    
    public init(frame: CGRect, hasPullRefresh: Bool = false, animColor: UIColor = UIColor.darkGray) {
        self.animColor = animColor
        super.init(frame: frame, style: UITableView.Style.plain)
        self.delegate = self
        self.dataSource = self
        //        self.editing = false
        self.separatorStyle = .none
        self.backgroundColor = UIColor.clear
        self.setCellIdentifierPrefix("Cell")
        if hasPullRefresh {
            self.myRefreshControl = UIRefreshControl()
            self.myRefreshControl!.attributedTitle = NSAttributedString(string: beforeRefreshText, attributes: [NSAttributedString.Key.foregroundColor: animColor])
            self.myRefreshControl!.addTarget(self, action: #selector(SLHTableView.startRefresh(_:)), for: UIControl.Event.valueChanged)
            self.addSubview(self.myRefreshControl!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadData(_ increaseReloadCounter: Bool = false) {
        if increaseReloadCounter {
            self.reloadCounter += 1
        }
        self.hideMessage()
        super.reloadData()
    }
    
    func setCellIdentifierPrefix(_ prefix: String) {
        self.cellIdentifierFormat = prefix + "_%d_%d_%d"
    }
    
    func getCellItentifer(_ indexPath: IndexPath) -> String {
        return String(format: self.cellIdentifierFormat, self.reloadCounter, indexPath.section, indexPath.row)
    }
    
    func setSelectableStatus(_ value: Bool) {
        self.selectable = value
        self.allowsMultipleSelection = value
    }
    
    func getSelectableStatus() -> Bool {
        return self.selectable
    }
    
    func setSelectionMode(_ value: Bool) {
        self.selectionMode = value
        self.reloadData(true)
    }
    
    func getSelectionMode() -> Bool {
        return self.selectionMode
    }
    
    func setItemHeights(headerHeight: CGFloat?, rowHeight: CGFloat?, footerHeight: CGFloat?) {
        self.headerHeight = headerHeight
        self.rowHeight2 = rowHeight
        self.footerHeight = footerHeight
    }
    
    @objc func startRefresh(_ sender: Any) {
        self.myRefreshControl!.attributedTitle = NSAttributedString(string: self.onRefreshText, attributes: [NSAttributedString.Key.foregroundColor: animColor])
        if self.slhDelegate != nil && self.slhDelegate?.onRefreshTableView != nil {
            self.slhDelegate?.onRefreshTableView(self)
        } else {
            self.endRefresh()
        }
    }
    
    func endRefresh() {
        if self.refreshing {
            self.myRefreshControl!.endRefreshing()
            self.myRefreshControl!.attributedTitle = NSAttributedString(string: beforeRefreshText, attributes: [NSAttributedString.Key.foregroundColor: animColor])
        }
    }
    
    func activateSelectionMode() {
        if !self.selectionMode {
            self.selectionMode = true
            for cell in self.visibleCells {
                if cell is SLHTableViewCell {
                    (cell as! SLHTableViewCell).showCheckBox()
                }
            }
            if self.slhDelegate != nil && self.slhDelegate?.didActivateSelectionMode != nil {
                self.slhDelegate!.didActivateSelectionMode(self)
            }
        }
    }
    
    func deactivateSelectionMode() {
        self.selectionMode = false
        if let selectedIndexPaths = self.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                self.deselectRow(at: indexPath, animated: false)
            }
        }
        for cell in self.visibleCells {
            if cell is SLHTableViewCell {
                (cell as! SLHTableViewCell).hideCheckBox()
            }
        }
    }
    
    func getSelectedCells() -> [UITableViewCell] {
        var selectedCells = [UITableViewCell]()
        if let selectedIndexPaths = self.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                selectedCells.append(self.cellForRow(at: indexPath)!)
            }
        }
        return selectedCells
    }
    
    /// Displays SLHTableView's messageText.
    func showMessage(_ text: String = "") {
        if self.messageLabel == nil {
            self.messageLabel = UILabel(frame: CGRect(x: 10, y: 20, width: self.width - 20, height: self.height - 40))
            self.messageLabel!.textAlignment = .center
            self.addSubview(self.messageLabel!)
        }
        self.messageLabel!.text = text.isEmpty ? self.messageText : text
        self.messageLabel!.isHidden = false
    }
    
    /// Hides SLHTableView's messageText if visible.
    func hideMessage() {
        if self.messageLabel != nil {
            self.messageLabel!.isHidden = true
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    
    private func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight ?? self.slhDelegate?.heightForHeaderInSection(self, section: section) ?? 0
    }
    
    private func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight2 ?? self.slhDelegate?.heightForRowAtIndexPath(self, indexPath: indexPath) ?? 50
    }
    
    private func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.footerHeight ?? self.slhDelegate?.heightForFooterInSection(self, section: section) ?? 0
    }
    
    private func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell is SLHTableViewCell && self.selectable && self.selectionMode {
            (cell as! SLHTableViewCell).setSelected()
        }
        self.slhDelegate?.didSelectRowAtIndexPath(self, indexPath: indexPath)
    }
    
    private func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell is SLHTableViewCell {
            (cell as! SLHTableViewCell).setUnselected()
        }
        self.slhDelegate?.didDeselectRowAtIndexPath(self, indexPath: indexPath)
    }
    
    private func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.slhDelegate?.canEditForRow(self, indexPath: indexPath) ?? false
    }
    
    private func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.slhDelegate?.willBeginEditingRowAtIndexPath(self, indexPath: indexPath)
    }
    
    private func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.slhDelegate?.didEndEditingRowAtIndexPath(self, indexPath: indexPath)
    }
    
    private func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return self.slhDelegate?.editActionsForRow(self, indexPath: indexPath) ?? nil
    }
    
    private func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        debugPrint("commit")
    }
    
    // MARK: - UITableViewDataSource Methods
    
    private func numberOfSections(in tableView: UITableView) -> Int {
        return self.slhDelegate?.numberOfSectionsInTableView(self) ?? 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.slhDelegate?.numberOfRowsInSection(self, section: section) ?? 0
    }
    
    private func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.slhDelegate?.viewForHeaderInSection(self, section: section) ?? nil
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = self.getCellItentifer(indexPath)
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            if self.slhDelegate != nil {
                cell = self.slhDelegate!.cellForRowAtIndexPath(self, indexPath: indexPath, cellIdentifier: identifier)
                if cell is SLHTableViewCell {
                    (cell as! SLHTableViewCell).tvcDelegate = self
                }
            } else {
                cell = UITableViewCell()
            }
        }
        return cell!
    }
    
    private func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.slhDelegate?.viewForFooterInSection(self, section: section) ?? nil
    }
    
    //    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    //        if tableView.editing
    //        {
    //            return .Delete;
    //        }
    //        return .None;
    //    }
    
    // MARK: - TableViewCellDelegateMeethods
    
    @objc(didCellPressedLong:touctPoint:) func didCellPressedLong(_ cell: SLHTableViewCell, touctPoint touchPoint: CGPoint) {
        if self.selectable {
            self.activateSelectionMode()
        }
        if let indexPath = self.indexPathForRow(at: touchPoint) {
            self.slhDelegate?.didCellPressedLong(self, cell: cell, indexPath: indexPath)
        }
    }
    
    // UIScrollViewDelegate methods
    
    private func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.slhDelegate?.didScroll(self)
    }
}

extension SLHTableView {
    var refreshing: Bool {
        return self.myRefreshControl != nil && self.myRefreshControl!.isRefreshing
    }
}

// MARK: -
// MARK: - SLHTableViewCell

open class SLHTableViewCell: UITableViewCell {
    var tvcDelegate: TableViewCellDelegate?
    var selectModeEnabled: Bool = false
    fileprivate var longPressable: Bool = true
    fileprivate var checkBox: SLHCheckBox?
    fileprivate var firstLoad = true
    private var tableView: SLHTableView
    
    public init(tableView: SLHTableView, reuseIdentifier: String, selectMode: Bool = false, longPressable: Bool = true) {
        self.tableView = tableView
        self.selectModeEnabled = selectMode
        self.longPressable = longPressable
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        
        if self.selectModeEnabled {
            self.showCheckBox()
        }
        
        //        let tgr = UITapGestureRecognizer(target: self, action: "cellTapAction:")
        //        self.addGestureRecognizer(tgr)
        
        if self.longPressable {
            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(SLHTableViewCell.cellLongPressAction(_:)))
            lpgr.minimumPressDuration = 0.7
            self.addGestureRecognizer(lpgr)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if self.firstLoad {
            self.drawCell()
            self.firstLoad = false
        }
    }
    
    open func drawCell() {
        //        debugPrint("This method must be overriden.")
    }
    
    func setSelected() {
        if self.selectModeEnabled {
            if super.isSelected {
                self.checkBox!.check()
            } else {
                self.checkBox!.uncheck()
            }
        }
    }
    
    func setUnselected() {
        if self.checkBox != nil {
            self.checkBox!.uncheck()
        }
    }
    
    // Override to customize
    func cellTapAction() {
        if !self.selectModeEnabled {
            self.setSelected()
        }
    }
    
    // Override to customize
    @objc func cellLongPressAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if !self.selectModeEnabled && self.tvcDelegate != nil && self.tvcDelegate!.didCellPressedLong != nil {
            let touchPoint = gestureRecognizer.location(in: self.tableView)
            self.tvcDelegate!.didCellPressedLong!(self, touctPoint: touchPoint)
        }
    }
    
    func showCheckBox() {
        self.selectModeEnabled = true
        if self.checkBox == nil {
            self.checkBox = SLHCheckBox(frame: CGRect(x: 0, y: 0, width: 18, height: 18), status: self.isSelected, clickable: false)
            self.accessoryView = self.checkBox
        }
        self.setSelected() // Cell'in tekrar çizildiği durumlarda bazen selected olmayan cell önceki duruma göre check'li çizildiği için eklendi.
        self.checkBox!.isHidden = true
        self.checkBox!.fadeIn(0.1)
    }
    
    func hideCheckBox() {
        self.selectModeEnabled = false
        if self.checkBox != nil {
            self.checkBox!.fadeOut(0.1)
        }
    }
}

@objc protocol TableViewCellDelegate : NSObjectProtocol {
    @objc optional func didCellPressedLong(_ cell: SLHTableViewCell, touctPoint: CGPoint)
}

// MARK: -
// MARK: - SLHCheckBox

class SLHCheckBox: UIView {
    var status: Bool
    fileprivate var mode: CheckBoxMode
    fileprivate var innerCircle: UIView!
    fileprivate var image1: UIImageView!
    fileprivate var image2: UIImageView!
    
    fileprivate enum CheckBoxMode { case image, circle }
    
    var cbDelegate: CheckBoxDelegate?
    
    init(frame: CGRect, color1: UIColor, color2: UIColor, status: Bool = false, clickable: Bool = true) {
        self.status = status
        self.mode = CheckBoxMode.circle
        super.init(frame: frame)
        self.makeCircle()
        self.backgroundColor = color1
        
        let thickness = min(frame.width, frame.height) / 8
        self.innerCircle = UIView(frame: CGRect(x: thickness, y: thickness, width: self.width - 2 * thickness, height: self.height - 2 * thickness))
        self.innerCircle.makeCircle()
        self.innerCircle.backgroundColor = color2
        self.addSubview(self.innerCircle)
        if status {
            self.check()
        }
        
        if clickable {
            self.isUserInteractionEnabled = true
            let tapEvent = UITapGestureRecognizer(target: self, action: #selector(SLHCheckBox.tapEvent))
            self.addGestureRecognizer(tapEvent)
        }
    }
    
    init(frame: CGRect, status: Bool = false, clickable: Bool = true) {
        self.status = status
        self.mode = CheckBoxMode.image
        super.init(frame: frame)
        
        self.image1 = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.image1.image = UIImage(named: "checkbox_unchecked")
        
        self.image2 = UIImageView(frame: self.image1.frame)
        self.image2.image = UIImage(named: "checkbox_checked")
        
        if status {
            self.addSubview(self.image2)
        } else {
            self.addSubview(self.image1)
        }
        
        if clickable {
            self.isUserInteractionEnabled = true
            let tapEvent = UITapGestureRecognizer(target: self, action: #selector(SLHCheckBox.tapEvent))
            self.addGestureRecognizer(tapEvent)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Only sets check status. Doesn't run CheckBoxDelegate functions.
    func setCheckStatus(_ status: Bool) {
        self.status = status
        if self.mode == CheckBoxMode.circle {
            self.innerCircle.isHidden = status
        } else if self.mode == CheckBoxMode.image {
            if status {
                self.image1.replaceWith(self.image2)
            } else {
                self.image2.replaceWith(self.image1)
            }
        }
    }
    
    /// Sets check status true and runs CheckBoxDelegate didChecked function.
    func check() {
        self.setCheckStatus(true)
        if self.cbDelegate != nil && self.cbDelegate!.didChecked != nil {
            self.cbDelegate!.didChecked!(checkBox: self)
        }
    }
    
    /// Sets check status false and runs CheckBoxDelegate didUnchecked function.
    func uncheck() {
        self.setCheckStatus(false)
        if self.cbDelegate != nil && self.cbDelegate!.didUnchecked != nil {
            self.cbDelegate!.didUnchecked!(checkBox: self)
        }
    }
    
    @objc func tapEvent() {
        if self.status {
            self.uncheck()
        } else {
            self.check()
        }
    }
}

@objc protocol CheckBoxDelegate : NSObjectProtocol {
    @objc optional func didChecked(checkBox cb: SLHCheckBox)
    @objc optional func didUnchecked(checkBox cb: SLHCheckBox)
}
