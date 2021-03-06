//
//  SLHSimpleTableView.swift
//  BibliOS
//
//  Created by Salih Topcu on 19.04.2019.
//  Copyright © 2019 Salih Topcu. All rights reserved.
//

import UIKit

public struct SLHSimpleColumn {
	let title: String
	let widthRate: CGFloat
	let alignment: NSTextAlignment?
	
	public init(title: String, widthRate: CGFloat, alignment: NSTextAlignment? = nil) {
		self.title = title
		self.widthRate = widthRate
		self.alignment = alignment
	}
}

public class SLHSimpleCell { }

public class SLHSimpleTextCell: SLHSimpleCell {
	let text: String
	let color: UIColor?
	let alignment: NSTextAlignment?
	
	public init(text: String, color: UIColor? = nil, alignment: NSTextAlignment? = nil) {
		self.text = text
		self.color = color
		self.alignment = alignment
	}
}

class SLHSimpleViewCell: SLHSimpleCell {
	let view: UIView
//	let alignment: NSTextAlignment?
	
	init(view: UIView) {
		self.view = view
	}
}

public struct SLHSimpleRow {
	let cells: [SLHSimpleCell]
	let item: Any?
	
	public init(cells: [SLHSimpleCell], item: Any? = nil) {
		self.cells = cells
		self.item = item
	}
}

public struct SLHSimpleFooter {
	let cells: [SLHSimpleCell]
	let widthRates: [CGFloat]
	let bottomPadding: CGFloat
	
	public init(cells: [SLHSimpleCell], widthRates: [CGFloat], bottomPadding: CGFloat = 0) {
		self.cells = cells
		self.widthRates = widthRates
		self.bottomPadding = bottomPadding
	}
}

public typealias SLHTableTitle = (text: String, font: String?, fontSize: CGFloat?, backgroundColor: UIColor?, fontColor: UIColor?)

public struct SLHSimpleTable {
	let columns: [SLHSimpleColumn]
	let rows: [SLHSimpleRow]
	let footer: SLHSimpleFooter?
	let noItemInfo: String?
	let hideHeaderWhenHasNoItem: Bool
	let hideFooterWhenHasNoItem: Bool
	let title: SLHTableTitle?
	
	public init(
		columns: [SLHSimpleColumn],
		rows: [SLHSimpleRow],
		footer: SLHSimpleFooter? = nil,
		noItemInfo: String? = nil,
		hideHeaderWhenHasNoItem: Bool = true,
		hideFooterWhenHasNoItem: Bool = true,
		title: SLHTableTitle? = nil) {
		self.columns = columns
		self.rows = rows
		self.footer = footer
		self.noItemInfo = noItemInfo
		self.hideHeaderWhenHasNoItem = hideHeaderWhenHasNoItem
		self.hideFooterWhenHasNoItem = hideFooterWhenHasNoItem
		self.title = title
	}
}

open class  SLHSimpleTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
	
	public typealias SLHSimpleSelectAction = (_ item: Any?) -> Void
	
	public typealias SLHSimpleDeselectAction = (_ item: Any?) -> Void
	
	private let identifier: String
	private var reloadCounter: Int = 0
	
	private var _tables: [SLHSimpleTable] = []
	public var tables: [SLHSimpleTable] {
		get {
			return self._tables
		}
		set(value) {
			self._tables = value
			self.reloadCounter += 1
			self.reloadData()
		}
	}
	public var selectAction: SLHSimpleSelectAction?
	public var deselectAction: SLHSimpleDeselectAction?
	
	public var selectedIndexPaths = [IndexPath]()
	var selectedItems: [Any] {
		var items = [Any]()
		for indexPath in self.selectedIndexPaths {
			let item = self.tables[indexPath.section].rows[indexPath.row].item
			if item != nil {
				items.append(item!)
			}
		}
		return items
	}
	
	var horizontalPadding: CGFloat = 16
	
	public var heights: ( header: CGFloat, row: CGFloat, footer: CGFloat ) = ( header: 50, row: 50, footer: 50 )
	public var backgroundColors: ( header: UIColor, row: UIColor, footer: UIColor ) = ( header: UIColor.darkGray, row: UIColor.white, footer: UIColor.lightGray )
	public var textColors: ( header: UIColor, row: UIColor, footer: UIColor ) = ( header: UIColor.white, row: UIColor.darkGray, footer: UIColor.darkGray )
	public var fonts: ( header: String?, row: String?, footer: String? )
	public var fontSizes: ( header: CGFloat, row: CGFloat, footer: CGFloat ) = ( header: 16, row: 16, footer: 16 )
	public var hasSeparators: Bool = false
	
    public init(frame: CGRect = CGRect.null, identifier: String, didSelect: SLHSimpleSelectAction? = nil, didDeselect: SLHSimpleDeselectAction? = nil) {
		self.identifier = identifier
        super.init(frame: frame, style: UITableView.Style.plain)
		self.selectAction = didSelect
		self.deselectAction = didDeselect
		super.delegate = self
		super.dataSource = self
		super.separatorStyle = .none
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: UITableViewDatasource Methods
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return self.tables.count
	}
	
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tables[section].rows.count == 0 && self.tables[section].noItemInfo != nil ? 1 : self.tables[section].rows.count
	}
	
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		let table = self.tables[section]
		return (table.title == nil ? 0 : self.heights.header) + (table.hideHeaderWhenHasNoItem && table.rows.count == 0 ? 0 : self.heights.header)
	}
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.tables[indexPath.section].rows.count == 0 && self.tables[indexPath.section].noItemInfo == nil ? 0 : self.heights.row
	}
	
	public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return self.tables[section].footer == nil || (self.tables[section].hideFooterWhenHasNoItem && self.tables[section].rows.count == 0) ? 0 : (self.heights.footer + (self.tables[section].footer?.bottomPadding ?? 0))
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if self.tables[section].hideHeaderWhenHasNoItem && self.tables[section].rows.count == 0 {
			return nil
		} else {
			let reuseIdentifier = "header_\(self.identifier)_\(self.reloadCounter)_\(section)"
			let header = super.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)
			return header ?? SLHSimpleHeaderView(
				frame: CGRect(
					x: 0,
					y: 0,
					width: tableView.width,
					height: self.tableView(tableView, heightForHeaderInSection: section)),
				tableView: self,
				table: self.tables[section]
			)
		}
	}
	
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if self.tables[indexPath.section].rows.count == 0 && self.tables[indexPath.section].noItemInfo != nil && indexPath.row == 0 {
			let reuseIdentifier = "noitemrow_\(self.identifier)_\(self.reloadCounter)_\(indexPath.section)_\(indexPath.row)"
			let cell = super.dequeueReusableCell(withIdentifier: reuseIdentifier)
			return cell ?? SLHNoItemInfoRow(
				frame: CGRect(x: 0, y: 0, width: tableView.width, height: self.heights.row),
				infoText: self.tables[indexPath.section].noItemInfo!,
				tableView: self,
				reuseIdentifier: reuseIdentifier)
		} else {
			let reuseIdentifier = "row_\(self.identifier)_\(self.reloadCounter)_\(indexPath.section)_\(indexPath.row)"
			let cell = super.dequeueReusableCell(withIdentifier: reuseIdentifier)
			return cell ?? SLHSimpleRowView(
				frame: CGRect(x: 0, y: 0, width: tableView.width, height: self.heights.row),
				tableView: self,
				table: self.tables[indexPath.section],
				row: self.tables[indexPath.section].rows[indexPath.row],
				reuseIdentifier: reuseIdentifier
			)
		}
	}
	
	public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		if self.tables[section].footer == nil || (self.tables[section].hideFooterWhenHasNoItem && self.tables[section].rows.count == 0) {
			return nil
		} else {
			let reuseIdentifier = "footer_\(self.identifier)_\(self.reloadCounter)_\(section)"
			let view = super.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)
			return view ?? SLHSimpleFooterView(
				frame: CGRect(x: 0, y: 0, width: tableView.width, height: self.heights.footer),
				tableView: self,
				table: self.tables[section]
			)
		}
	}
	
	// MARK: UITableViewDelegate Methods
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if self.tables[indexPath.section].rows.count > 0 {
			self.selectedIndexPaths.append(indexPath)
			self.selectAction?(self.tables[indexPath.section].rows[indexPath.row].item)
		}
	}
	
	public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		if self.tables[indexPath.section].rows.count > 0 {
			for i in 0..<self.selectedIndexPaths.count {
				if self.selectedIndexPaths[i] == indexPath {
					self.selectedIndexPaths.remove(at: i)
					break
				}
			}
			self.deselectAction?(self.tables[indexPath.section].rows[indexPath.row].item)
		}
	}
	
}

fileprivate class SLHSimpleHeaderView: UIView {
	
	init(frame: CGRect, tableView: SLHSimpleTableView, table: SLHSimpleTable) {
		super.init(frame: frame)
		let partHeight = table.title == nil ? frame.size.height : (frame.size.height / 2)
		
		if let title = table.title {
			let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: partHeight))
			titleLabel.text = title.text
			titleLabel.textAlignment = .center
			if let font = title.font {
				titleLabel.font = UIFont(name: font, size: title.fontSize ?? tableView.fontSizes.header)
			} else {
				titleLabel.font = UIFont.systemFont(ofSize: title.fontSize ?? tableView.fontSizes.header)
			}
			if let bgColor = title.backgroundColor {
				titleLabel.backgroundColor = bgColor
			}
			if let color = title.fontColor {
				titleLabel.textColor = color
			}
			self.addSubview(titleLabel)
		}
		
		self.backgroundColor = tableView.backgroundColors.header
		
		let top = table.title == nil ? 0 : partHeight
		var totalWidthRate: CGFloat = 0
		for column in table.columns {
			totalWidthRate += column.widthRate
		}
		var left = tableView.horizontalPadding
		let partWidth: CGFloat = (frame.width - 2 * left) / totalWidthRate
		
		for column in table.columns {
			let label = UILabel(frame: CGRect(x: left, y: top, width: partWidth * column.widthRate, height: partHeight))
			label.text = column.title
			label.textColor = tableView.textColors.header
			if tableView.fonts.header == nil {
				label.font = UIFont.systemFont(ofSize: tableView.fontSizes.header)
			} else {
				label.font = UIFont(name: tableView.fonts.header!, size: tableView.fontSizes.header)
			}
			label.textAlignment = column.alignment ?? .left
			self.addSubview(label)
			left = label.right
		}
        
        let separator = UIView(frame: CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5))
            separator.backgroundColor = UIColor.darkGray
            self.addSubview(separator)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

fileprivate class SLHSimpleRowView: UITableViewCell {
	
	init(frame: CGRect, tableView: SLHSimpleTableView, table: SLHSimpleTable, row: SLHSimpleRow, reuseIdentifier: String) {
		super.init(style: .default, reuseIdentifier: reuseIdentifier)
		self.backgroundColor = backgroundColor
		if tableView.deselectAction == nil {
			self.selectionStyle = .none
		}
		
		var totalWidthRate: CGFloat = 0
		for column in table.columns {
			totalWidthRate += column.widthRate
		}
		var left = tableView.horizontalPadding
		let partWidth: CGFloat = (frame.width - 2 * left) / totalWidthRate
        
        if tableView.hasSeparators {
                let separator = UIView(frame: CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5))
                separator.backgroundColor = tableView.separatorColor
                self.addSubview(separator)
            }
		
		for i in 0..<row.cells.count {
			if row.cells[i] is SLHSimpleTextCell {
				let label = UILabel(frame: CGRect(x: left, y: 0, width: partWidth * table.columns[i].widthRate, height: frame.height))
				label.text = (row.cells[i] as! SLHSimpleTextCell).text
				label.textColor = (row.cells[i] as! SLHSimpleTextCell).color ?? tableView.textColors.row
				if tableView.fonts.row == nil {
					label.font = UIFont.systemFont(ofSize: tableView.fontSizes.row)
				} else {
					label.font = UIFont(name: tableView.fonts.row!, size: tableView.fontSizes.row)
				}
                label.textAlignment = (row.cells[i] as! SLHSimpleTextCell).alignment  ?? .left
				self.addSubview(label)
				left = label.right
			} else if row.cells[i] is SLHSimpleViewCell {
				self.addSubview((row.cells[i] as! SLHSimpleViewCell).view)
			}
		}
		
		if tableView.hasSeparators {
			let separator = UIView(frame: CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5))
			separator.backgroundColor = tableView.separatorColor
			self.addSubview(separator)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

fileprivate class SLHSimpleFooterView: UIView {
	
	init(frame: CGRect, tableView: SLHSimpleTableView, table: SLHSimpleTable) {
		super.init(frame: frame)
		self.backgroundColor = tableView.backgroundColors.footer
		
		var totalWidthRate: CGFloat = 0
		for rate in table.footer?.widthRates ?? [] {
			totalWidthRate += rate
		}
		var left = tableView.horizontalPadding
		let partWidth: CGFloat = (frame.width - 2 * left) / totalWidthRate
		
		for i in 0..<(table.footer?.cells.count ?? 0) {
			if table.footer!.cells[i] is SLHSimpleTextCell {
				let label = UILabel(frame: CGRect(x: left, y: 0, width: partWidth * table.footer!.widthRates[i], height: frame.height))
				label.text = (table.footer!.cells[i] as! SLHSimpleTextCell).text
				label.textColor = tableView.textColors.footer
				if tableView.fonts.footer == nil {
					label.font = UIFont.systemFont(ofSize: tableView.fontSizes.footer)
				} else {
					label.font = UIFont(name: tableView.fonts.footer!, size: tableView.fontSizes.footer)
				}
				label.textAlignment = (table.footer!.cells[i] as! SLHSimpleTextCell).alignment ?? .left
				self.addSubview(label)
				left = label.right
			} else if table.footer!.cells[i] is SLHSimpleViewCell {
				self.addSubview((table.footer!.cells[i] as! SLHSimpleViewCell).view)
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

fileprivate class SLHNoItemInfoRow: UITableViewCell {
	init(frame: CGRect, infoText: String, tableView: SLHSimpleTableView, reuseIdentifier: String) {
		super.init(style: .value1, reuseIdentifier: reuseIdentifier)
		super.selectionStyle = .none
		super.textLabel?.frame = CGRect(
			x: tableView.horizontalPadding,
			y: super.textLabel?.frame.origin.y ?? 0,
			width: tableView.width - 2 * tableView.horizontalPadding,
			height: super.textLabel?.frame.size.height ?? tableView.heights.row
		)
		super.textLabel?.textColor = tableView.textColors.row
		if tableView.fonts.row == nil {
			super.textLabel?.font = UIFont.systemFont(ofSize: tableView.fontSizes.row)
		} else {
			super.textLabel?.font = UIFont(name: tableView.fonts.row!, size: tableView.fontSizes.row)
		}
		super.textLabel?.text = infoText
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
