//  Formal.swift
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

/// The delegate of the Formal form.
public protocol FormalDelegate : class {
    func sectionsHaveBeenAdded(_ sections: [FormalSection], at: IndexSet)
    func sectionsHaveBeenRemoved(_ sections: [FormalSection], at: IndexSet)
    func sectionsHaveBeenReplaced(oldSections: [FormalSection], newSections: [FormalSection], at: IndexSet)
    func rowsHaveBeenAdded(_ rows: [FormalBaseRow], at: [IndexPath])
    func rowsHaveBeenRemoved(_ rows: [FormalBaseRow], at: [IndexPath])
    func rowsHaveBeenReplaced(oldRows: [FormalBaseRow], newRows: [FormalBaseRow], at: [IndexPath])
    func valueHasBeenChanged(for: FormalBaseRow, oldValue: Any?, newValue: Any?)
}

// MARK: Formal

/// The class representing the Formal form.
public final class Formal {

    /// Defines the default options of the navigation accessory view.
    public static var defaultNavigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)

    /// The default options that define when an inline row will be hidden. Applies only when `inlineRowHideOptions` is nil.
    public static var defaultInlineRowHideOptions = InlineRowHideOptions.FirstResponderChanges.union(.AnotherInlineRowIsShown)

    /// The options that define when an inline row will be hidden. If nil then `defaultInlineRowHideOptions` are used
    public var inlineRowHideOptions: InlineRowHideOptions?

    /// Which `UIReturnKeyType` should be used by default. Applies only when `keyboardReturnType` is nil.
    public static var defaultKeyboardReturnType = FormalKeyboardReturnTypeConfiguration()

    /// Which `UIReturnKeyType` should be used in this form. If nil then `defaultKeyboardReturnType` is used
    public var keyboardReturnType: FormalKeyboardReturnTypeConfiguration?

    /// This form's delegate
    public weak var delegate: FormalDelegate?

    public init() {}

    /**
     Returns the row at the given indexPath
     */
    public subscript(indexPath: IndexPath) -> FormalBaseRow {
        return self[indexPath.section][indexPath.row]
    }

    /**
     Returns the row whose tag is passed as parameter. Uses a dictionary to get the row faster
     */
    public func rowBy<F: Equatable>(tag: String) -> FormalRowOf<F>? {
        let row: FormalBaseRow? = rowBy(tag: tag)
        return row as? FormalRowOf<F>
    }

    /**
     Returns the row whose tag is passed as parameter. Uses a dictionary to get the row faster
     */
    public func rowBy<FormalRow: FormalRowType>(tag: String) -> FormalRow? {
        let row: FormalBaseRow? = rowBy(tag: tag)
        return row as? FormalRow
    }

    /**
     Returns the row whose tag is passed as parameter. Uses a dictionary to get the row faster
     */
    public func rowBy(tag: String) -> FormalBaseRow? {
        return rowsByTag[tag]
    }

    /**
     Returns the section whose tag is passed as parameter.
     */
    public func sectionBy(tag: String) -> FormalSection? {
        return kvoWrapper._allSections.filter({ $0.tag == tag }).first
    }

    /**
     Method used to get all the values of all the rows of the form. Only rows with tag are included.
     
     - parameter includeHidden: If the values of hidden rows should be included.
     
     - returns: A dictionary mapping the rows tag to its value. [tag: value]
     */
    public func values(includeHidden: Bool = false) -> [String: Any?] {
        if includeHidden {
            return allRows.filter({ $0.tag != nil })
                .reduce([String: Any?]()) {
                    var result = $0
                    result[$1.tag!] = $1.baseValue
                    return result
                }
        }
        return rows.filter({ $0.tag != nil })
            .reduce([String: Any?]()) {
                var result = $0
                result[$1.tag!] = $1.baseValue
                return result
            }
    }

    /**
     Set values to the rows of this form
     
     - parameter values: A dictionary mapping tag to value of the rows to be set. [tag: value]
     */
    public func setValues(_ values: [String: Any?]) {
        for (key, value) in values {
            let row: FormalBaseRow? = rowBy(tag: key)
            row?.baseValue = value
        }
    }

    /// The visible rows of this form
    public var rows: [FormalBaseRow] { return flatMap { $0 } }

    /// All the rows of this form. Includes the hidden rows.
    public var allRows: [FormalBaseRow] { return kvoWrapper._allSections.map({ $0.kvoWrapper._allRows }).flatMap { $0 } }

    /// All the sections of this form. Includes hidden sections.
    public var allSections: [FormalSection] { return kvoWrapper._allSections }

    /**
     * Hides all the inline rows of this form.
     */
    public func hideInlineRows() {
        for row in self.allRows {
            if let inlineRow = row as? FormalBaseInlineRowType {
                inlineRow.collapseInlineRow()
            }
        }
    }

    // MARK: Private

    var rowObservers = [String: [FormalConditionType: [FormalTaggable]]]()
    var rowsByTag = [String: FormalBaseRow]()
    var tagToValues = [String: Any]()
    lazy var kvoWrapper: KVOWrapper = { [unowned self] in return KVOWrapper(form: self) }()
}

extension Formal: Collection {
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return kvoWrapper.sections.count }
}

extension Formal: MutableCollection {

    // MARK: MutableCollectionType

    public subscript (_ position: Int) -> FormalSection {
        get { return kvoWrapper.sections[position] as! FormalSection }
        set {
            if position > kvoWrapper.sections.count {
                assertionFailure("Formal: Index out of bounds")
            }

            if position < kvoWrapper.sections.count {
                let oldSection = kvoWrapper.sections[position]
                let oldSectionIndex = kvoWrapper._allSections.index(of: oldSection as! FormalSection)!
                // Remove the previous section from the form
                kvoWrapper._allSections[oldSectionIndex].willBeRemovedFromForm()
                kvoWrapper._allSections[oldSectionIndex] = newValue
            } else {
                kvoWrapper._allSections.append(newValue)
            }

            kvoWrapper.sections[position] = newValue
            newValue.wasAddedTo(form: self)
        }
    }
    public func index(after i: Int) -> Int {
        return i+1 <= endIndex ? i+1 : endIndex
    }
    public func index(before i: Int) -> Int {
        return i > startIndex ? i-1 : startIndex
    }
    public var last: FormalSection? {
        return reversed().first
    }

}

extension Formal : RangeReplaceableCollection {

    // MARK: RangeReplaceableCollectionType

    public func append(_ formSection: FormalSection) {
        kvoWrapper.sections.insert(formSection, at: kvoWrapper.sections.count)
        kvoWrapper._allSections.append(formSection)
        formSection.wasAddedTo(form: self)
    }

    public func append<S: Sequence>(contentsOf newElements: S) where S.Iterator.Element == FormalSection {
        kvoWrapper.sections.addObjects(from: newElements.map { $0 })
        kvoWrapper._allSections.append(contentsOf: newElements)
        for section in newElements {
            section.wasAddedTo(form: self)
        }
    }

    public func replaceSubrange<C: Collection>(_ subRange: Range<Int>, with newElements: C) where C.Iterator.Element == FormalSection {
        for i in subRange.lowerBound..<subRange.upperBound {
            if let section = kvoWrapper.sections.object(at: i) as? FormalSection {
                section.willBeRemovedFromForm()
                kvoWrapper._allSections.remove(at: kvoWrapper._allSections.index(of: section)!)
            }
        }
        kvoWrapper.sections.replaceObjects(in: NSRange(location: subRange.lowerBound, length: subRange.upperBound - subRange.lowerBound),
                                           withObjectsFrom: newElements.map { $0 })
        kvoWrapper._allSections.insert(contentsOf: newElements, at: indexForInsertion(at: subRange.lowerBound))

        for section in newElements {
            section.wasAddedTo(form: self)
        }
    }

    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        // not doing anything with capacity
        for section in kvoWrapper._allSections {
            section.willBeRemovedFromForm()
        }
        kvoWrapper.sections.removeAllObjects()
        kvoWrapper._allSections.removeAll()
    }

    private func indexForInsertion(at index: Int) -> Int {
        guard index != 0 else { return 0 }

        let row = kvoWrapper.sections[index-1]
        if let i = kvoWrapper._allSections.index(of: row as! FormalSection) {
            return i + 1
        }
        return kvoWrapper._allSections.count
    }

}

extension Formal {

    // MARK: Private Helpers

    class KVOWrapper: NSObject {
        dynamic private var _sections = NSMutableArray()
        var sections: NSMutableArray { return mutableArrayValue(forKey: "_sections") }
        var _allSections = [FormalSection]()
        private weak var form: Formal?

        init(form: Formal) {
            self.form = form
            super.init()
            addObserver(self, forKeyPath: "_sections", options: NSKeyValueObservingOptions.new.union(.old), context:nil)
        }

        deinit {
            removeObserver(self, forKeyPath: "_sections")
            _sections.removeAllObjects()
            _allSections.removeAll()
        }

        public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

            let newSections = change?[NSKeyValueChangeKey.newKey] as? [FormalSection] ?? []
            let oldSections = change?[NSKeyValueChangeKey.oldKey] as? [FormalSection] ?? []
            guard let delegateValue = form?.delegate, let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKey.kindKey] else { return }
            guard keyPathValue == "_sections" else { return }
            switch (changeType as! NSNumber).uintValue {
            case NSKeyValueChange.setting.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as? IndexSet ?? IndexSet(integer: 0)
                delegateValue.sectionsHaveBeenAdded(newSections, at: indexSet)
            case NSKeyValueChange.insertion.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                delegateValue.sectionsHaveBeenAdded(newSections, at: indexSet)
            case NSKeyValueChange.removal.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                delegateValue.sectionsHaveBeenRemoved(oldSections, at: indexSet)
            case NSKeyValueChange.replacement.rawValue:
                let indexSet = change![NSKeyValueChangeKey.indexesKey] as! IndexSet
                delegateValue.sectionsHaveBeenReplaced(oldSections: oldSections, newSections: newSections, at: indexSet)
            default:
                assertionFailure()
            }
        }
    }

    func dictionaryValuesToEvaluatePredicate() -> [String: Any] {
        return tagToValues
    }

    func addRowObservers(to taggable: FormalTaggable, rowTags: [String], type: FormalConditionType) {
        for rowTag in rowTags {
            if rowObservers[rowTag] == nil {
                rowObservers[rowTag] = Dictionary()
            }
            if let _ = rowObservers[rowTag]?[type] {
                if !rowObservers[rowTag]![type]!.contains(where: { $0 === taggable }) {
                    rowObservers[rowTag]?[type]!.append(taggable)
                }
            } else {
                rowObservers[rowTag]?[type] = [taggable]
            }
        }
    }

    func removeRowObservers(from taggable: FormalTaggable, rowTags: [String], type: FormalConditionType) {
        for rowTag in rowTags {
            guard var arr = rowObservers[rowTag]?[type], let index = arr.index(where: { $0 === taggable }) else { continue }
            arr.remove(at: index)
        }
    }

    func nextRow(for row: FormalBaseRow) -> FormalBaseRow? {
        let allRows = rows
        guard let index = allRows.index(of: row) else { return nil }
        guard index < allRows.count - 1 else { return nil }
        return allRows[index + 1]
    }

    func previousRow(for row: FormalBaseRow) -> FormalBaseRow? {
        let allRows = rows
        guard let index = allRows.index(of: row) else { return nil }
        guard index > 0 else { return nil }
        return allRows[index - 1]
    }

    func hideSection(_ section: FormalSection) {
        kvoWrapper.sections.remove(section)
    }

    func showSection(_ section: FormalSection) {
        guard !kvoWrapper.sections.contains(section) else { return }
        guard var index = kvoWrapper._allSections.index(of: section) else { return }
        var formIndex = NSNotFound
        while formIndex == NSNotFound && index > 0 {
            index = index - 1
            let previous = kvoWrapper._allSections[index]
            formIndex = kvoWrapper.sections.index(of: previous)
        }
        kvoWrapper.sections.insert(section, at: formIndex == NSNotFound ? 0 : formIndex + 1 )
    }
}

extension Formal {

    @discardableResult
    public func validate(includeHidden: Bool = false) -> [ValidationError] {
        let rowsToValidate = includeHidden ? allRows : rows
        return rowsToValidate.reduce([ValidationError]()) { res, row in
            var res = res
            res.append(contentsOf: row.validate())
            return res
        }
    }
}
