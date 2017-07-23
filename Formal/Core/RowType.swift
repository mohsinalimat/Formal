//  FormalRowType.swift
//  Formal (https://github.com/Meniny/Formal)
//
//  Copyright (c) 2016 Meniny (https://meniny.cn)
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

protocol FormalDisableable: FormalTaggable {
    func evaluateDisabled()
    var disabled: FormalCondition? { get set }
    var isDisabled: Bool { get }
}

protocol FormalHidable: FormalTaggable {
    func evaluateHidden()
    var hidden: FormalCondition? { get set }
    var isHidden: Bool { get }
}

public protocol FormalKeyboardReturnHandler: BaseRowType {
    var keyboardReturnType: FormalKeyboardReturnTypeConfiguration? { get set }
}

public protocol FormalTaggable: AnyObject {
    var tag: String? { get set }
}

public protocol BaseRowType: FormalTaggable {

    /// The cell associated to this row.
    var baseCell: FormalBaseCell! { get }

    /// The section to which this row belongs.
    var section: FormalSection? { get }

    /// Parameter used when creating the cell for this row.
    var cellStyle: UITableViewCellStyle { get set }

    /// The title will be displayed in the textLabel of the row.
    var title: String? { get set }

    /**
     Method that should re-display the cell
     */
    func updateCell()

    /**
     Method called when the cell belonging to this row was selected. Must call the corresponding method in its cell.
     */
    func didSelect()

    /**
     Typically we don't need to explicitly call this method since it is called by Formal framework. It will validates the row if you invoke it.
     */
    func validate() -> [ValidationError]
}

public protocol FormalTypedRowType: BaseRowType {

    associatedtype FormalCell: FormalBaseCell, FormalTypedCellType

    /// The typed cell associated to this row.
    var cell: FormalCell! { get }

    /// The typed value this row stores.
    var value: FormalCell.Value? { get set }

    func add<Rule: RuleType>(rule: Rule) where Rule.RowValueType == FormalCell.Value
    func remove(ruleWithIdentifier: String)
}

/**
 *  Protocol that every row type has to conform to.
 */
public protocol FormalRowType: FormalTypedRowType {
    init(_ tag: String?, _ initializer: (Self) -> Void)
}

extension FormalRowType where Self: FormalBaseRow {

    /**
     Default initializer for a row
     */
    public init(_ tag: String? = nil, _ initializer: (Self) -> Void = { _ in }) {
        self.init(tag: tag)
        FormalRowDefaults.rowInitialization["\(type(of: self))"]?(self)
        initializer(self)
    }
}

extension FormalRowType where Self: FormalBaseRow {

    /// The default block executed when the cell is updated. Applies to every row of this type.
    public static var defaultCellUpdate: ((FormalCell, Self) -> Void)? {
        set {
            if let newValue = newValue {
                let wrapper: (FormalBaseCell, FormalBaseRow) -> Void = { (baseCell: FormalBaseCell, baseRow: FormalBaseRow) in
                    newValue(baseCell as! FormalCell, baseRow as! Self)
                }
                FormalRowDefaults.cellUpdate["\(self)"] = wrapper
                FormalRowDefaults.rawCellUpdate["\(self)"] = newValue
            } else {
                FormalRowDefaults.cellUpdate["\(self)"] = nil
                FormalRowDefaults.rawCellUpdate["\(self)"] = nil
            }
        }
        get { return FormalRowDefaults.rawCellUpdate["\(self)"] as? ((FormalCell, Self) -> Void) }
    }

    /// The default block executed when the cell is created. Applies to every row of this type.
    public static var defaultCellSetup: ((FormalCell, Self) -> Void)? {
        set {
            if let newValue = newValue {
                let wrapper: (FormalBaseCell, FormalBaseRow) -> Void = { (baseCell: FormalBaseCell, baseRow: FormalBaseRow) in
                    newValue(baseCell as! FormalCell, baseRow as! Self)
                }
                FormalRowDefaults.cellSetup["\(self)"] = wrapper
                FormalRowDefaults.rawCellSetup["\(self)"] = newValue
            } else {
                FormalRowDefaults.cellSetup["\(self)"] = nil
                FormalRowDefaults.rawCellSetup["\(self)"] = nil
            }
        }
        get { return FormalRowDefaults.rawCellSetup["\(self)"] as? ((FormalCell, Self) -> Void) }
    }

    /// The default block executed when the cell becomes first responder. Applies to every row of this type.
    public static var defaultOnCellHighlightChanged: ((FormalCell, Self) -> Void)? {
        set {
            if let newValue = newValue {
                let wrapper: (FormalBaseCell, FormalBaseRow) -> Void = { (baseCell: FormalBaseCell, baseRow: FormalBaseRow) in
                    newValue(baseCell as! FormalCell, baseRow as! Self)
                }
                FormalRowDefaults.onCellHighlightChanged ["\(self)"] = wrapper
                FormalRowDefaults.rawOnCellHighlightChanged["\(self)"] = newValue
            } else {
                FormalRowDefaults.onCellHighlightChanged["\(self)"] = nil
                FormalRowDefaults.rawOnCellHighlightChanged["\(self)"] = nil
            }
        }
        get { return FormalRowDefaults.rawOnCellHighlightChanged["\(self)"] as? ((FormalCell, Self) -> Void) }
    }

    /// The default block executed to initialize a row. Applies to every row of this type.
    public static var defaultRowInitializer: ((Self) -> Void)? {
        set {
            if let newValue = newValue {
                let wrapper: (FormalBaseRow) -> Void = { (baseRow: FormalBaseRow) in
                    newValue(baseRow as! Self)
                }
                FormalRowDefaults.rowInitialization["\(self)"] = wrapper
                FormalRowDefaults.rawRowInitialization["\(self)"] = newValue
            } else {
                FormalRowDefaults.rowInitialization["\(self)"] = nil
                FormalRowDefaults.rawRowInitialization["\(self)"] = nil
            }
        }
        get { return FormalRowDefaults.rawRowInitialization["\(self)"] as? ((Self) -> Void) }
    }

    /// The default block executed to initialize a row. Applies to every row of this type.
    public static var defaultOnRowValidationChanged: ((FormalCell, Self) -> Void)? {
        set {
            if let newValue = newValue {
                let wrapper: (FormalBaseCell, FormalBaseRow) -> Void = { (baseCell: FormalBaseCell, baseRow: FormalBaseRow) in
                    newValue(baseCell as! FormalCell, baseRow as! Self)
                }
                FormalRowDefaults.onRowValidationChanged["\(self)"] = wrapper
                FormalRowDefaults.rawOnRowValidationChanged["\(self)"] = newValue
            } else {
                FormalRowDefaults.onRowValidationChanged["\(self)"] = nil
                FormalRowDefaults.rawOnRowValidationChanged["\(self)"] = nil
            }
        }
        get { return FormalRowDefaults.rawOnRowValidationChanged["\(self)"] as? ((FormalCell, Self) -> Void) }
    }

    /**
     Sets a block to be called when the value of this row changes.

     - returns: this row
     */
    @discardableResult
    public func onChange(_ callback: @escaping (Self) -> Void) -> Self {
        callbackOnChange = { [unowned self] in callback(self) }
        return self
    }

    /**
     Sets a block to be called when the cell corresponding to this row is refreshed.

     - returns: this row
     */
    @discardableResult
    public func cellUpdate(_ callback: @escaping ((_ cell: FormalCell, _ row: Self) -> Void)) -> Self {
        callbackCellUpdate = { [unowned self] in  callback(self.cell, self) }
        return self
    }

    /**
     Sets a block to be called when the cell corresponding to this row is created.

     - returns: this row
     */
    @discardableResult
    public func cellSetup(_ callback: @escaping ((_ cell: FormalCell, _ row: Self) -> Void)) -> Self {
        callbackCellSetup = { [unowned self] (cell: FormalCell) in  callback(cell, self) }
        return self
    }

    /**
     Sets a block to be called when the cell corresponding to this row is selected.

     - returns: this row
     */
    @discardableResult
    public func onCellSelection(_ callback: @escaping ((_ cell: FormalCell, _ row: Self) -> Void)) -> Self {
        callbackCellOnSelection = { [unowned self] in  callback(self.cell, self) }
        return self
    }

    /**
     Sets a block to be called when the cell corresponding to this row becomes or resigns the first responder.

     - returns: this row
     */
    @discardableResult
    public func onCellHighlightChanged(_ callback: @escaping (_ cell: FormalCell, _ row: Self) -> Void) -> Self {
        callbackOnCellHighlightChanged = { [unowned self] in callback(self.cell, self) }
        return self
    }

    @discardableResult
    public func onRowValidationChanged(_ callback: @escaping (_ cell: FormalCell, _ row: Self) -> Void) -> Self {
        callbackOnRowValidationChanged = { [unowned self] in  callback(self.cell, self) }
        return self
    }
}
