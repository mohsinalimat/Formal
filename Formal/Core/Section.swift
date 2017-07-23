//  FormalSection.swift
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

/// The delegate of the Formal sections.
public protocol SectionDelegate: class {
    func rowsHaveBeenAdded(_ rows: [FormalBaseRow], at: IndexSet)
    func rowsHaveBeenRemoved(_ rows: [FormalBaseRow], at: IndexSet)
    func rowsHaveBeenReplaced(oldRows: [FormalBaseRow], newRows: [FormalBaseRow], at: IndexSet)
}

// MARK: FormalSection

extension FormalSection : Equatable {}

public func == (lhs: FormalSection, rhs: FormalSection) -> Bool {
    return lhs === rhs
}

extension FormalSection : FormalHidable, SectionDelegate {}

extension FormalSection {

    public func reload(with rowAnimation: UITableViewRowAnimation = .none) {
        guard let tableView = (form?.delegate as? FormalViewController)?.tableView, let index = index else { return }
        tableView.reloadSections(IndexSet(integer: index), with: rowAnimation)
    }
}

extension FormalSection {

    internal class KVOWrapper: NSObject {

        dynamic private var _rows = NSMutableArray()
        var rows: NSMutableArray {
            return mutableArrayValue(forKey: "_rows")
        }
        var _allRows = [FormalBaseRow]()

        private weak var section: FormalSection?

        init(section: FormalSection) {
            self.section = section
            super.init()
            addObserver(self, forKeyPath: "_rows", options: NSKeyValueObservingOptions.new.union(.old), context:nil)
        }

        deinit {
            removeObserver(self, forKeyPath: "_rows")
            _rows.removeAllObjects()
            _allRows.removeAll()
        }

        public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            let newRows = change![NSKeyValueChangeKey.newKey] as? [FormalBaseRow] ?? []
            let oldRows = change![NSKeyValueChangeKey.oldKey] as? [FormalBaseRow] ?? []
            guard let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKey.kindKey] else { return }
            let delegateValue = section?.form?.delegate
            guard keyPathValue == "_rows" else { return }
            switch (changeType as! NSNumber).uintValue {
            case NSKeyValueChange.setting.rawValue:
                section?.rowsHaveBeenAdded(newRows, at: IndexSet(integer: 0))
                delegateValue?.rowsHaveBeenAdded(newRows, at:[IndexPath(index: 0)])
            case NSKeyValueChange.insertion.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                section?.rowsHaveBeenAdded(newRows, at: indexSet)
                if let _index = section?.index {
                    delegateValue?.rowsHaveBeenAdded(newRows, at: indexSet.map { IndexPath(row: $0, section: _index ) })
                }
            case NSKeyValueChange.removal.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                section?.rowsHaveBeenRemoved(oldRows, at: indexSet)
                if let _index = section?.index {
                    delegateValue?.rowsHaveBeenRemoved(oldRows, at: indexSet.map { IndexPath(row: $0, section: _index ) })
                }
            case NSKeyValueChange.replacement.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                section?.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, at: indexSet)
                if let _index = section?.index {
                    delegateValue?.rowsHaveBeenReplaced(oldRows: oldRows, newRows: newRows, at: indexSet.map { IndexPath(row: $0, section: _index)})
                }
            default:
                assertionFailure()
            }
        }
    }

    /**
     *  If this section contains a row (hidden or not) with the passed parameter as tag then that row will be returned.
     *  If not, it returns nil.
     */
    public func rowBy<FormalRow: FormalRowType>(tag: String) -> FormalRow? {
        guard let index = kvoWrapper._allRows.index(where: { $0.tag == tag }) else { return nil }
        return kvoWrapper._allRows[index] as? FormalRow
    }
}

/// The class representing the sections in a Formal form.
open class FormalSection {

    /// The tag is used to uniquely identify a FormalSection. Must be unique among sections and rows.
    public var tag: String?

    /// The form that contains this section
    public internal(set) weak var form: Formal?

    /// The header of this section.
    public var header: HeaderFooterViewRepresentable? {
        willSet {
            headerView = nil
        }
    }

    /// The footer of this section
    public var footer: HeaderFooterViewRepresentable? {
        willSet {
            footerView = nil
        }
    }

    /// Index of this section in the form it belongs to.
    public var index: Int? { return form?.index(of: self) }

    /// FormalCondition that determines if the section should be hidden or not.
    public var hidden: FormalCondition? {
        willSet { removeFromRowObservers() }
        didSet { addToRowObservers() }
    }

    /// Returns if the section is currently hidden or not
    public var isHidden: Bool { return hiddenCache }

    public required init() {}

    public init(_ initializer: (FormalSection) -> Void) {
        initializer(self)
    }

    public init(_ header: String, _ initializer: (FormalSection) -> Void = { _ in }) {
        self.header = HeaderFooterView(stringLiteral: header)
        initializer(self)
    }

    public init(header: String, footer: String, _ initializer: (FormalSection) -> Void = { _ in }) {
        self.header = HeaderFooterView(stringLiteral: header)
        self.footer = HeaderFooterView(stringLiteral: footer)
        initializer(self)
    }

    public init(footer: String, _ initializer: (FormalSection) -> Void = { _ in }) {
        self.footer = HeaderFooterView(stringLiteral: footer)
        initializer(self)
    }

    // MARK: SectionDelegate

    /**
     *  Delegate method called by the framework when one or more rows have been added to the section.
     */
    open func rowsHaveBeenAdded(_ rows: [FormalBaseRow], at: IndexSet) {}

    /**
     *  Delegate method called by the framework when one or more rows have been removed from the section.
     */
    open func rowsHaveBeenRemoved(_ rows: [FormalBaseRow], at: IndexSet) {}

    /**
     *  Delegate method called by the framework when one or more rows have been replaced in the section.
     */
    open func rowsHaveBeenReplaced(oldRows: [FormalBaseRow], newRows: [FormalBaseRow], at: IndexSet) {}

    // MARK: Private
    lazy var kvoWrapper: KVOWrapper = { [unowned self] in return KVOWrapper(section: self) }()
    
    var headerView: UIView?
    var footerView: UIView?
    var hiddenCache = false
}

extension FormalSection : MutableCollection, BidirectionalCollection {

    // MARK: MutableCollectionType

    public var startIndex: Int { return 0 }
    public var endIndex: Int { return kvoWrapper.rows.count }
    public subscript (position: Int) -> FormalBaseRow {
        get {
            if position >= kvoWrapper.rows.count {
                assertionFailure("FormalSection: Index out of bounds")
            }
            return kvoWrapper.rows[position] as! FormalBaseRow
        }
        set {
            if position > kvoWrapper.rows.count {
                assertionFailure("FormalSection: Index out of bounds")
            }

            if position < kvoWrapper.rows.count {
                let oldRow = kvoWrapper.rows[position]
                let oldRowIndex = kvoWrapper._allRows.index(of: oldRow as! FormalBaseRow)!
                // Remove the previous row from the form
                kvoWrapper._allRows[oldRowIndex].willBeRemovedFromSection()
                kvoWrapper._allRows[oldRowIndex] = newValue
            } else {
                kvoWrapper._allRows.append(newValue)
            }

            kvoWrapper.rows[position] = newValue
            newValue.wasAddedTo(section: self)
        }
    }

    public subscript (range: Range<Int>) -> [FormalBaseRow] {
        get { return kvoWrapper.rows.objects(at: IndexSet(integersIn: range)) as! [FormalBaseRow] }
        set {
            replaceSubrange(range, with: newValue)
        }
    }

    public func index(after i: Int) -> Int {return i + 1}
    public func index(before i: Int) -> Int {return i - 1}

}

extension FormalSection : RangeReplaceableCollection {

    // MARK: RangeReplaceableCollectionType

    public func append(_ formRow: FormalBaseRow) {
        kvoWrapper.rows.insert(formRow, at: kvoWrapper.rows.count)
        kvoWrapper._allRows.append(formRow)
        formRow.wasAddedTo(section: self)
    }

    public func append<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == FormalBaseRow {
        kvoWrapper.rows.addObjects(from: newElements.map { $0 })
        kvoWrapper._allRows.append(contentsOf: newElements)
        for row in newElements {
            row.wasAddedTo(section: self)
        }
    }

    public func replaceSubrange<C: Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == FormalBaseRow {
        for i in subRange.lowerBound..<subRange.upperBound {
            if let row = kvoWrapper.rows.object(at: i) as? FormalBaseRow {
                row.willBeRemovedFromSection()
                kvoWrapper._allRows.remove(at: kvoWrapper._allRows.index(of: row)!)
            }
        }

        kvoWrapper.rows.replaceObjects(in: NSRange(location: subRange.lowerBound, length: subRange.upperBound - subRange.lowerBound),
                                       withObjectsFrom: newElements.map { $0 })

        kvoWrapper._allRows.insert(contentsOf: newElements, at: indexForInsertion(at: subRange.lowerBound))
        for row in newElements {
            row.wasAddedTo(section: self)
        }
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        // not doing anything with capacity
        for row in kvoWrapper._allRows {
            row.willBeRemovedFromSection()
        }
        kvoWrapper.rows.removeAllObjects()
        kvoWrapper._allRows.removeAll()
    }

    @discardableResult
    public func remove(at position: Int) -> FormalBaseRow {
        let row = kvoWrapper.rows.object(at: position) as! FormalBaseRow
        row.willBeRemovedFromSection()
        kvoWrapper.rows.removeObject(at: position)
        if let index = kvoWrapper._allRows.index(of: row) {
            kvoWrapper._allRows.remove(at: index)
        }

        return row
    }

    private func indexForInsertion(at index: Int) -> Int {
        guard index != 0 else { return 0 }

        let row = kvoWrapper.rows[index-1]
        if let i = kvoWrapper._allRows.index(of: row as! FormalBaseRow) {
            return i + 1
        }
        return kvoWrapper._allRows.count
    }
}

extension FormalSection /* FormalCondition */{

    // MARK: Hidden/Disable Engine

    /**
     Function that evaluates if the section should be hidden and updates it accordingly.
     */
    public final func evaluateHidden() {
        if let h = hidden, let f = form {
            switch h {
            case .closure(_, let callback):
                hiddenCache = callback(f)
            case .predicate(let predicate):
                hiddenCache = predicate.evaluate(with: self, substitutionVariables: f.dictionaryValuesToEvaluatePredicate())
            }
            if hiddenCache {
                form?.hideSection(self)
            } else {
                form?.showSection(self)
            }
        }
    }

    /**
     Internal function called when this section was added to a form.
     */
    func wasAddedTo(form: Formal) {
        self.form = form
        addToRowObservers()
        evaluateHidden()
        for row in kvoWrapper._allRows {
            row.wasAddedTo(section: self)
        }
    }

    /**
     Internal function called to add this section to the observers of certain rows. Called when the hidden variable is set and depends on other rows.
     */
    func addToRowObservers() {
        guard let h = hidden else { return }
        switch h {
        case .closure(let tags, _):
            form?.addRowObservers(to: self, rowTags: tags, type: .hidden)
        case .predicate(let predicate):
            form?.addRowObservers(to: self, rowTags: predicate.predicateVars, type: .hidden)
        }
    }

    /**
     Internal function called when this section was removed from a form.
     */
    func willBeRemovedFromForm() {
        for row in kvoWrapper._allRows {
            row.willBeRemovedFromForm()
        }
        removeFromRowObservers()
        self.form = nil
    }

    /**
     Internal function called to remove this section from the observers of certain rows. Called when the hidden variable is changed.
     */
    func removeFromRowObservers() {
        guard let h = hidden else { return }
        switch h {
        case .closure(let tags, _):
            form?.removeRowObservers(from: self, rowTags: tags, type: .hidden)
        case .predicate(let predicate):
            form?.removeRowObservers(from: self, rowTags: predicate.predicateVars, type: .hidden)
        }
    }

    func hide(row: FormalBaseRow) {
        row.baseCell.cellResignFirstResponder()
        (row as? FormalBaseInlineRowType)?.collapseInlineRow()
        kvoWrapper.rows.remove(row)
    }

    func show(row: FormalBaseRow) {
        guard !kvoWrapper.rows.contains(row) else { return }
        guard var index = kvoWrapper._allRows.index(of: row) else { return }
        var formIndex = NSNotFound
        while formIndex == NSNotFound && index > 0 {
            index = index - 1
            let previous = kvoWrapper._allRows[index]
            formIndex = kvoWrapper.rows.index(of: previous)
        }
        kvoWrapper.rows.insert(row, at: formIndex == NSNotFound ? 0 : formIndex + 1)
    }
}

/**
 *  Navigation options for a form view controller.
 */
public struct FormalMultivaluedOptions: OptionSet {

    private enum Options: Int {
        case none = 0, insert = 1, delete = 2, reorder = 4
    }
    public let rawValue: Int
    public  init(rawValue: Int) { self.rawValue = rawValue}
    private init(_ options: Options) { self.rawValue = options.rawValue }

    /// No multivalued.
    public static let None = FormalMultivaluedOptions(.none)

    /// Allows user to insert rows.
    public static let Insert = FormalMultivaluedOptions(.insert)

    /// Allows user to delete rows.
    public static let Delete = FormalMultivaluedOptions(.delete)

    /// Allows user to reorder rows
    public static let Reorder = FormalMultivaluedOptions(.reorder)
}

/**
 *  Multivalued sections allows us to easily create insertable, deletable and reorderable sections. By using a multivalued section we can add multiple values for a certain field, such as telephone numbers in a contact.
 */
open class FormalMultivaluedSection: FormalSection {

    public var multivaluedOptions: FormalMultivaluedOptions
    public var showInsertIconInAddButton = true
    public var addButtonProvider: ((FormalMultivaluedSection) -> FormalButtonRow) = { _ in
        return FormalButtonRow {
            $0.title = "Add"
            $0.cellStyle = .value1
        }.cellUpdate { cell, _ in
            cell.textLabel?.textAlignment = .left
        }
    }

    public var multivaluedRowToInsertAt: ((Int) -> FormalBaseRow)?

    public required init(multivaluedOptions: FormalMultivaluedOptions = FormalMultivaluedOptions.Insert.union(.Delete),
                header: String = "",
                footer: String = "",
                _ initializer: (FormalMultivaluedSection) -> Void = { _ in }) {
        self.multivaluedOptions = multivaluedOptions
        super.init(header: header, footer: footer, {section in initializer(section as! FormalMultivaluedSection) })
        guard multivaluedOptions.contains(.Insert) else { return }
        let addRow = addButtonProvider(self)
        addRow.onCellSelection { cell, row in
            guard let tableView = cell.formalViewController()?.tableView, let indexPath = row.indexPath else { return }
            cell.formalViewController()?.tableView(tableView, commit: .insert, forRowAt: indexPath)
        }
        self <<< addRow
    }

    public required init() {
        self.multivaluedOptions = FormalMultivaluedOptions.Insert.union(.Delete)
        super.init()
        let addRow = addButtonProvider(self)
        addRow.onCellSelection { cell, row in
            guard let tableView = cell.formalViewController()?.tableView, let indexPath = row.indexPath else { return }
            cell.formalViewController()?.tableView(tableView, commit: .insert, forRowAt: indexPath)
        }
        self <<< addRow
    }
}
