//  FormalSelectorViewController.swift
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


/**
 *  Responsible for the options passed to a selector view controller
 */

public protocol FormalOptionsProviderRow: FormalTypedRowType {
    associatedtype OptionsProviderType: OptionsProviderConformance
    
    var optionsProvider: OptionsProviderType? { get set }
    
    var cachedOptionsData: [OptionsProviderType.Option]? { get set }
}

extension FormalOptionsProviderRow where Self: FormalBaseRow, OptionsProviderType.Option: Equatable {
    
    public var options: [OptionsProviderType.Option]? {
        set (newValue){
            let optProvider = OptionsProviderType.init(array: newValue)
            optionsProvider = optProvider
        }
        get {
            return self.cachedOptionsData ?? optionsProvider?.optionsArray
        }
    }
    
    public var cachedOptionsData: [OptionsProviderType.Option]? {
        get {
            return self._cachedOptionsData as? [OptionsProviderType.Option]
        }
        set {
            self._cachedOptionsData = newValue
        }
    }
}

public protocol OptionsProviderConformance: ExpressibleByArrayLiteral {
    associatedtype Option: Equatable
    
    init(array: [Option]?)
    func options(for selectorViewController: FormalViewController, completion: @escaping ([Option]?) -> Void)
    var optionsArray: [Option]? { get }
    
}

/// Provider of selectable options.
public enum OptionsProvider<F: Equatable>: OptionsProviderConformance {
    
    /// Synchronous provider that provides array of options it was initialized with
    case array([F]?)
    /// Provider that uses closure it was initialized with to provide options. Can be synchronous or asynchronous.
    case lazy((FormalViewController, @escaping ([F]?) -> Void) -> Void)
    
    public init(array: [F]?) {
        self = .array(array)
    }
    
    public init(arrayLiteral elements: F...) {
        self = .array(elements)
    }
    
    public func options(for selectorViewController: FormalViewController, completion: @escaping ([F]?) -> Void) {
        switch self {
        case let .array(array):
            completion(array)
        case let .lazy(fetch):
            fetch(selectorViewController, completion)
        }
    }
    
    public var optionsArray: [F]?{
        switch self {
        case let .array(arrayData):
            return arrayData
        default:
            return nil
        }
    }
}

open class _SelectorViewController<FormalRow: SelectableRowType, FormalOptionsRow: FormalOptionsProviderRow>: FormalViewController, FormalTypedRowControllerType where FormalRow: FormalBaseRow, FormalRow: FormalTypedRowType, FormalRow.FormalCell.Value == FormalOptionsRow.OptionsProviderType.Option {

    /// The row that pushed or presented this controller
    public var row: FormalRowOf<FormalRow.FormalCell.Value>!
    public var enableDeselection = true
    public var dismissOnSelection = true
    public var dismissOnChange = true

    public var selectableRowCellUpdate: ((_ cell: FormalRow.FormalCell, _ row: FormalRow) -> Void)?
    public var selectableRowCellSetup: ((_ cell: FormalRow.FormalCell, _ row: FormalRow) -> Void)?

    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> Void)?

    /// A closure that should return key for particular row value.
    /// This key is later used to break options by sections.
    public var sectionKeyForValue: ((FormalRow.FormalCell.Value) -> (String))?

    /// A closure that returns header title for a section for particular key.
    /// By default returns the key itself.
    public var sectionHeaderTitleForKey: ((String) -> String?)? = { $0 }

    /// A closure that returns footer title for a section for particular key.
    public var sectionFooterTitleForKey: ((String) -> String?)?
    
    public var optionsProviderRow: FormalOptionsRow {
        return row as! FormalOptionsRow
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience public init(_ callback: ((UIViewController) -> Void)?) {
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
    }

    open func setupForm() {
        let optProvider = optionsProviderRow.optionsProvider
        optProvider?.options(for: self) { [weak self] (options: [FormalRow.FormalCell.Value]?) in
            guard let strongSelf = self, let options = options else { return }
            strongSelf.optionsProviderRow.cachedOptionsData = options
            strongSelf.setupForm(with: options)
        }
    }
    
    open func setupForm(with options: [FormalRow.FormalCell.Value]) {
        if let optionsBySections = optionsBySections(with: options) {
            for (sectionKey, options) in optionsBySections {
                formal +++ section(with: options,
                                 header: sectionHeaderTitleForKey?(sectionKey),
                                 footer: sectionFooterTitleForKey?(sectionKey))
            }
        } else {
            formal +++ section(with: options, header: row.title, footer: nil)
        }
    }
    
    func optionsBySections(with options: [FormalRow.FormalCell.Value]) -> [(String, [FormalRow.FormalCell.Value])]? {
        guard let sectionKeyForValue = sectionKeyForValue else { return nil }

        let sections = options.reduce([:]) { (reduced, option) -> [String: [FormalRow.FormalCell.Value]] in
            var reduced = reduced
            let key = sectionKeyForValue(option)
            reduced[key] = (reduced[key] ?? []) + [option]
            return reduced
        }

        return sections.sorted(by: { (lhs, rhs) in lhs.0 < rhs.0 })
    }

    func section(with options: [FormalRow.FormalCell.Value], header: String?, footer: String?) -> FormalSelectableSection<FormalRow> {
        let header = header ?? ""
        let footer = footer ?? ""
        let section = FormalSelectableSection<FormalRow>(header: header, footer: footer, selectionType: .singleSelection(enableDeselection: enableDeselection)) { [weak self] section in
            section.onSelectSelectableRow = { _, row in
                let changed = self?.row.value != row.value
                self?.row.value = row.value
                
                if let form = row.section?.form {
                    for section in form where section !== row.section {
                        let section = section as! FormalSelectableSection<FormalRow>
                        if let selectedRow = section.selectedRow(), selectedRow !== row {
                            selectedRow.value = nil
                            selectedRow.updateCell()
                        }
                    }
                }
                
                if self?.dismissOnSelection == true || (changed && self?.dismissOnChange == true) {
                    self?.onDismissCallback?(self!)
                }
            }
        }
        for option in options {
            section <<< FormalRow.init(String(describing: option)) { lrow in
                lrow.title = self.row.displayValueFor?(option)
                lrow.selectableValue = option
                lrow.value = self.row.value == option ? option : nil
            }.cellSetup { [weak self] cell, row in
                self?.selectableRowCellSetup?(cell, row)
            }.cellUpdate { [weak self] cell, row in
                self?.selectableRowCellUpdate?(cell, row)
            }
        }
        return section
    }

}

/// Selector Controller (used to select one option among a list)
open class FormalSelectorViewController<FormalOptionsRow: FormalOptionsProviderRow>: _SelectorViewController<FormalListCheckRow<FormalOptionsRow.OptionsProviderType.Option>, FormalOptionsRow> {
}
