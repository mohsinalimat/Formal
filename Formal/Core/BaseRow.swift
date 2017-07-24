//  FormalBaseRow.swift
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

open class FormalBaseRow: BaseRowType {

    open var callbackOnChange: (() -> Void)?
    open var callbackCellUpdate: (() -> Void)?
    open var callbackCellSetup: Any?
    open var callbackCellOnSelection: (() -> Void)?
    open var callbackOnExpandInlineRow: Any?
    open var callbackOnCollapseInlineRow: Any?
    open var callbackOnCellHighlightChanged: (() -> Void)?
    open var callbackOnRowValidationChanged: (() -> Void)?
    open var _inlineRow: FormalBaseRow?
    
    open var _cachedOptionsData: Any?

    public var validationOptions: ValidationOptions = .validatesOnBlur
    // validation state
    public internal(set) var validationErrors = [ValidationError]() {
        didSet {
            guard validationErrors != oldValue else { return }
            FormalRowDefaults.onRowValidationChanged["\(type(of: self))"]?(baseCell, self)
            callbackOnRowValidationChanged?()
            updateCell()
        }
    }

    public internal(set) var wasBlurred = false
    public internal(set) var wasChanged = false

    public var isValid: Bool { return validationErrors.isEmpty }
    public var isHighlighted: Bool = false

    /// The title will be displayed in the textLabel of the row.
    public var title: String?

    /// Parameter used when creating the cell for this row.
    public var cellStyle = UITableViewCellStyle.value1

    /// String that uniquely identifies a row. Must be unique among rows and sections.
    public var tag: String?

    /// The untyped cell associated to this row.
    public var baseCell: FormalBaseCell! { return nil }

    /// The untyped value of this row.
    public var baseValue: Any? {
        set {}
        get { return nil }
    }

    public func validate() -> [ValidationError] {
        return []
    }

    public static var estimatedRowHeight: CGFloat = 44.0

    /// FormalCondition that determines if the row should be disabled or not.
    public var disabled: FormalCondition? {
        willSet { removeFromDisabledRowObservers() }
        didSet { addToDisabledRowObservers() }
    }

    /// FormalCondition that determines if the row should be hidden or not.
    public var hidden: FormalCondition? {
        willSet { removeFromHiddenRowObservers() }
        didSet { addToHiddenRowObservers() }
    }

    /// Returns if this row is currently disabled or not
    public var isDisabled: Bool { return disabledCache }

    /// Returns if this row is currently hidden or not
    public var isHidden: Bool { return hiddenCache }

    /// The section to which this row belongs.
    public weak var section: FormalSection?

    public required init(tag: String? = nil) {
        self.tag = tag
    }

    /**
     Method that reloads the cell
     */
    open func updateCell() {}

    /**
     Method called when the cell belonging to this row was selected. Must call the corresponding method in its cell.
     */
    open func didSelect() {}

    open func prepare(for segue: UIStoryboardSegue) {}

    /**
     Returns the IndexPath where this row is in the current form.
     */
    public final var indexPath: IndexPath? {
        guard let sectionIndex = section?.index, let rowIndex = section?.index(of: self) else { return nil }
        return IndexPath(row: rowIndex, section: sectionIndex)
    }

    var hiddenCache = false
    var disabledCache = false {
        willSet {
            if newValue && !disabledCache {
                baseCell.cellResignFirstResponder()
            }
        }
    }
}

extension FormalBaseRow {

    /**
     Evaluates if the row should be hidden or not and updates the form accordingly
     */
    public final func evaluateHidden() {
        guard let h = hidden, let form = section?.form else { return }
        switch h {
        case .closure(_, let callback):
            hiddenCache = callback(form)
        case .predicate(let predicate):
            hiddenCache = predicate.evaluate(with: self, substitutionVariables: form.dictionaryValuesToEvaluatePredicate())
        }
        if hiddenCache {
            section?.hide(row: self)
        } else {
            section?.show(row: self)
        }
    }

    /**
     Evaluates if the row should be disabled or not and updates it accordingly
     */
    public final func evaluateDisabled() {
        guard let d = disabled, let form = section?.form else { return }
        switch d {
        case .closure(_, let callback):
            disabledCache = callback(form)
        case .predicate(let predicate):
            disabledCache = predicate.evaluate(with: self, substitutionVariables: form.dictionaryValuesToEvaluatePredicate())
        }
        updateCell()
    }

    final func wasAddedTo(section: FormalSection) {
        self.section = section
        if let t = tag {
            assert(section.form?.rowsByTag[t] == nil, "Duplicate tag \(t)")
            self.section?.form?.rowsByTag[t] = self
            self.section?.form?.tagToValues[t] = baseValue != nil ? baseValue! : NSNull()
        }
        addToRowObservers()
        evaluateHidden()
        evaluateDisabled()
    }

    final func addToHiddenRowObservers() {
        guard let h = hidden else { return }
        switch h {
        case .closure(let tags, _):
            section?.form?.addRowObservers(to: self, rowTags: tags, type: .hidden)
        case .predicate(let predicate):
            section?.form?.addRowObservers(to: self, rowTags: predicate.predicateVars, type: .hidden)
        }
    }

    final func addToDisabledRowObservers() {
        guard let d = disabled else { return }
        switch d {
        case .closure(let tags, _):
            section?.form?.addRowObservers(to: self, rowTags: tags, type: .disabled)
        case .predicate(let predicate):
            section?.form?.addRowObservers(to: self, rowTags: predicate.predicateVars, type: .disabled)
        }
    }

    final func addToRowObservers() {
        addToHiddenRowObservers()
        addToDisabledRowObservers()
    }

    final func willBeRemovedFromForm() {
        (self as? FormalBaseInlineRowType)?.collapseInlineRow()
        if let t = tag {
            section?.form?.rowsByTag[t] = nil
            section?.form?.tagToValues[t] = nil
        }
        removeFromRowObservers()
    }

    final func willBeRemovedFromSection() {
        willBeRemovedFromForm()
        section = nil
    }

    final func removeFromHiddenRowObservers() {
        guard let h = hidden else { return }
        switch h {
        case .closure(let tags, _):
            section?.form?.removeRowObservers(from: self, rowTags: tags, type: .hidden)
        case .predicate(let predicate):
            section?.form?.removeRowObservers(from: self, rowTags: predicate.predicateVars, type: .hidden)
        }
    }

    final func removeFromDisabledRowObservers() {
        guard let d = disabled else { return }
        switch d {
        case .closure(let tags, _):
            section?.form?.removeRowObservers(from: self, rowTags: tags, type: .disabled)
        case .predicate(let predicate):
            section?.form?.removeRowObservers(from: self, rowTags: predicate.predicateVars, type: .disabled)
        }
    }

    final func removeFromRowObservers() {
        removeFromHiddenRowObservers()
        removeFromDisabledRowObservers()
    }
}

extension FormalBaseRow: Equatable, FormalHidable, FormalDisableable {}

extension FormalBaseRow {

    public func reload(with rowAnimation: UITableViewRowAnimation = .none) {
        guard let tableView = baseCell?.formalViewController()?.tableView ?? (section?.form?.delegate as? FormalViewController)?.tableView, let indexPath = indexPath else { return }
        tableView.reloadRows(at: [indexPath], with: rowAnimation)
    }

    public func deselect(animated: Bool = true) {
        guard let indexPath = indexPath,
            let tableView = baseCell?.formalViewController()?.tableView ?? (section?.form?.delegate as? FormalViewController)?.tableView  else { return }
        tableView.deselectRow(at: indexPath, animated: animated)
    }

    public func select(animated: Bool = false, scrollPosition: UITableViewScrollPosition = .none) {
        guard let indexPath = indexPath,
            let tableView = baseCell?.formalViewController()?.tableView ?? (section?.form?.delegate as? FormalViewController)?.tableView  else { return }
        tableView.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
}

public func == (lhs: FormalBaseRow, rhs: FormalBaseRow) -> Bool {
    return lhs === rhs
}
