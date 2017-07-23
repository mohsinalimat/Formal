//  FormalInlineRowType.swift
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

public protocol FormalBaseInlineRowType {
    /**
     Method that can be called to expand (open) an inline row
     */
    func expandInlineRow()

    /**
     Method that can be called to collapse (close) an inline row
     */
    func collapseInlineRow()

    /**
     Method that can be called to change the status of an inline row (expanded/collapsed)
     */
    func toggleInlineRow()
}

/**
 *  Protocol that every inline row type has to conform to.
 */
public protocol FormalInlineRowType: FormalTypedRowType, FormalBaseInlineRowType {

    associatedtype FormalInlineRow: FormalBaseRow, FormalRowType, FormalTypedRowType

    /**
     This function is responsible for setting up an inline row before it is first shown.
     */
    func setupInlineRow(_ inlineRow: FormalInlineRow)
}

extension FormalInlineRowType where Self: FormalBaseRow, Self.FormalInlineRow : FormalBaseRow, Self.FormalCell.Value ==  Self.FormalInlineRow.FormalCell.Value {

    /// The row that will be inserted below after the current one when it is selected.
    public var inlineRow: Self.FormalInlineRow? { return _inlineRow as? Self.FormalInlineRow }

    /**
     Method that can be called to expand (open) an inline row.
     */
    public func expandInlineRow() {
        if let _ = inlineRow { return }
        if var section = section, let form = section.form {
            let inline = FormalInlineRow.init { _ in }
            inline.value = value
            inline.onChange { [weak self] in
                self?.value = $0.value
                self?.updateCell()
            }
            setupInlineRow(inline)
            if (form.inlineRowHideOptions ?? Formal.defaultInlineRowHideOptions).contains(.AnotherInlineRowIsShown) {
                for row in form.allRows {
                    if let inlineRow = row as? FormalBaseInlineRowType {
                        inlineRow.collapseInlineRow()
                    }
                }
            }
            if let onExpandInlineRowCallback = onExpandInlineRowCallback {
                onExpandInlineRowCallback(cell, self, inline)
            }
            if let indexPath = indexPath {
                _inlineRow = inline
                section.insert(inline, at: indexPath.row + 1)
                cell.formalViewController()?.makeRowVisible(inline)
            }
        }
    }

    /**
     Method that can be called to collapse (close) an inline row.
     */
    public func collapseInlineRow() {
        if let selectedRowPath = indexPath, let inlineRow = _inlineRow {
            if let onCollapseInlineRowCallback = onCollapseInlineRowCallback {
                onCollapseInlineRowCallback(cell, self, inlineRow as! FormalInlineRow)
            }
            _inlineRow = nil
            section?.remove(at: selectedRowPath.row + 1)
        }
    }

    /**
     Method that can be called to change the status of an inline row (expanded/collapsed).
     */
    public func toggleInlineRow() {
        if let _ = inlineRow {
            collapseInlineRow()
        } else {
            expandInlineRow()
        }
    }

    /**
     Sets a block to be executed when a row is expanded.
     */
    @discardableResult
    public func onExpandInlineRow(_ callback: @escaping (FormalCell, Self, FormalInlineRow) -> Void) -> Self {
        callbackOnExpandInlineRow = callback
        return self
    }

    /**
     Sets a block to be executed when a row is collapsed.
     */
    @discardableResult
    public func onCollapseInlineRow(_ callback: @escaping (FormalCell, Self, FormalInlineRow) -> Void) -> Self {
        callbackOnCollapseInlineRow = callback
        return self
    }

    /// Returns the block that will be executed when this row expands
    public var onCollapseInlineRowCallback: ((FormalCell, Self, FormalInlineRow) -> Void)? {
        return callbackOnCollapseInlineRow as! ((FormalCell, Self, FormalInlineRow) -> Void)?
    }

    /// Returns the block that will be executed when this row collapses
    public var onExpandInlineRowCallback: ((FormalCell, Self, FormalInlineRow) -> Void)? {
        return callbackOnExpandInlineRow as! ((FormalCell, Self, FormalInlineRow) -> Void)?
    }

    public var isExpanded: Bool { return _inlineRow != nil }
    public var isCollapsed: Bool { return !isExpanded }
}
