//  FormalRow.swift
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

open class FormalRowOf<F: Equatable>: FormalBaseRow {

    private var _value: F? {
        didSet {
            guard _value != oldValue else { return }
            guard let form = section?.form else { return }
            if let delegate = form.delegate {
                delegate.valueHasBeenChanged(for: self, oldValue: oldValue, newValue: value)
                callbackOnChange?()
            }
            guard let t = tag else { return }
            form.tagToValues[t] = (value != nil ? value! : NSNull())
            if let rowObservers = form.rowObservers[t]?[.hidden] {
                for rowObserver in rowObservers {
                    (rowObserver as? FormalHidable)?.evaluateHidden()
                }
            }
            if let rowObservers = form.rowObservers[t]?[.disabled] {
                for rowObserver in rowObservers {
                    (rowObserver as? FormalDisableable)?.evaluateDisabled()
                }
            }
        }
    }

    /// The typed value of this row.
    open var value: F? {
        set (newValue) {
            _value = newValue
            guard let _ = section?.form else { return }
            wasChanged = true
            if validationOptions.contains(.validatesOnChange) || (wasBlurred && validationOptions.contains(.validatesOnChangeAfterBlurred)) ||  (!isValid && validationOptions != .validatesOnDemand) {
                validate()
            }
        }
        get {
            return _value
        }
    }

    /// The untyped value of this row.
    public override var baseValue: Any? {
        get { return value }
        set { value = newValue as? F }
    }

    /// Block variable used to get the String that should be displayed for the value of this row.
    public var displayValueFor: ((F?) -> String?)? = {
        return $0.map { String(describing: $0) }
    }

    required public init(tag: String?) {
        super.init(tag: tag)
    }

    internal var rules: [ValidationRuleHelper<F>] = []

    @discardableResult
    public override func validate() -> [ValidationError] {
        validationErrors = rules.flatMap { $0.validateFn(value) }
        return validationErrors
    }

    /// Add a Validation rule for the FormalRow
    /// - Parameter rule: RuleType object to add
    public func add<Rule: RuleType>(rule: Rule) where F == Rule.RowValueType {
        let validFn: ((F?) -> ValidationError?) = { (val: F?) in
            return rule.isValid(value: val)
        }
        rules.append(ValidationRuleHelper(validateFn: validFn, rule: rule))
    }

    /// Add a Validation rule set for the FormalRow
    /// - Parameter ruleSet: RuleSet<F> set of rules to add
    public func add(ruleSet: RuleSet<F>) {
        rules.append(contentsOf: ruleSet.rules)
    }

    public func remove(ruleWithIdentifier identifier: String) {
        if let index = rules.index(where: { (validationRuleHelper) -> Bool in
            return validationRuleHelper.rule.id == identifier
        }) {
            rules.remove(at: index)
        }
    }

    public func removeAllRules() {
        validationErrors.removeAll()
        rules.removeAll()
    }

}

/// Generic class that represents an Formal row.
open class FormalRow<FormalCell: FormalCellType>: FormalRowOf<FormalCell.Value>, FormalTypedRowType where FormalCell: FormalBaseCell {

    /// Responsible for creating the cell for this row.
    public var cellProvider = FormalCellProvider<FormalCell>()

    /// The type of the cell associated to this row.
    public let cellType: FormalCell.Type! = FormalCell.self

    private var _cell: FormalCell! {
        didSet {
            FormalRowDefaults.cellSetup["\(type(of: self))"]?(_cell, self)
            (callbackCellSetup as? ((FormalCell) -> Void))?(_cell)
        }
    }

    /// The cell associated to this row.
    public var cell: FormalCell! {
        return _cell ?? {
            let result = cellProvider.makeCell(style: self.cellStyle)
            result.row = self
            result.setup()
            _cell = result
            return _cell
        }()
    }

    /// The untyped cell associated to this row
    public override var baseCell: FormalBaseCell { return cell }

    required public init(tag: String?) {
        super.init(tag: tag)
    }

    /**
     Method that reloads the cell
     */
    override open func updateCell() {
        super.updateCell()
        cell.update()
        customUpdateCell()
        FormalRowDefaults.cellUpdate["\(type(of: self))"]?(cell, self)
        callbackCellUpdate?()
    }

    /**
     Method called when the cell belonging to this row was selected. Must call the corresponding method in its cell.
     */
    open override func didSelect() {
        super.didSelect()
        if !isDisabled {
            cell?.didSelect()
        }
        customDidSelect()
        callbackCellOnSelection?()
    }

    /**
     Will be called inside `didSelect` method of the row. Can be used to customize row selection from the definition of the row.
     */
    open func customDidSelect() {}

    /**
     Will be called inside `updateCell` method of the row. Can be used to customize reloading a row from its definition.
     */
    open func customUpdateCell() {}

}
