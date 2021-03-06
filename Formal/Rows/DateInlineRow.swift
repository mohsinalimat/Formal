//  DateInliuneRow.swift
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

extension DatePickerRowProtocol {

    func configureInlineRow(_ inlineRow: DatePickerRowProtocol) {
        inlineRow.minimumDate = minimumDate
        inlineRow.maximumDate = maximumDate
        inlineRow.minuteInterval = minuteInterval
    }

}

open class _DateInlineRow: _DateInlineFieldRow {

    public typealias FormalInlineRow = FormalDatePickerRow

    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter?.timeStyle = .none
        dateFormatter?.dateStyle = .medium
    }

    open func setupInlineRow(_ inlineRow: FormalDatePickerRow) {
        configureInlineRow(inlineRow)
    }
}

open class _TimeInlineRow: _DateInlineFieldRow {

    public typealias FormalInlineRow = FormalTimePickerRow

    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter?.timeStyle = .short
        dateFormatter?.dateStyle = .none
    }

    open func setupInlineRow(_ inlineRow: FormalTimePickerRow) {
        configureInlineRow(inlineRow)
    }
}

open class _DateTimeInlineRow: _DateInlineFieldRow {

    public typealias FormalInlineRow = FormalDateTimePickerRow

    public required init(tag: String?) {
        super.init(tag: tag)
        dateFormatter?.timeStyle = .short
        dateFormatter?.dateStyle = .short
    }

    open func setupInlineRow(_ inlineRow: FormalDateTimePickerRow) {
        configureInlineRow(inlineRow)
    }
}

open class _CountDownInlineRow: _DateInlineFieldRow {

    public typealias FormalInlineRow = FormalCountDownPickerRow

    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = {
            guard let date = $0 else {
                return nil
            }
            let hour = Calendar.current.component(.hour, from: date)
            let min = Calendar.current.component(.minute, from: date)
            if hour == 1 {
                return "\(hour) hour \(min) min"
            }
            return "\(hour) hours \(min) min"
        }
    }

    public func setupInlineRow(_ inlineRow: FormalCountDownPickerRow) {
        configureInlineRow(inlineRow)
    }
}

/// A row with an Date as value where the user can select a date from an inline picker view.
public final class FormalDateInlineRow_<F>: _DateInlineRow, FormalRowType, FormalInlineRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }

    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
}

public typealias FormalDateInlineRow = FormalDateInlineRow_<Date>

/// A row with an Date as value where the user can select date and time from an inline picker view.
public final class FormalDateTimeInlineRow_<F>: _DateTimeInlineRow, FormalRowType, FormalInlineRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }

    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
}

public typealias FormalDateTimeInlineRow = FormalDateTimeInlineRow_<Date>

/// A row with an Date as value where the user can select a time from an inline picker view.
public final class FormalTimeInlineRow_<F>: _TimeInlineRow, FormalRowType, FormalInlineRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }

    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
}

public typealias FormalTimeInlineRow = FormalTimeInlineRow_<Date>

///// A row with an Date as value where the user can select hour and minute as a countdown timer in an inline picker view.
public final class FormalCountDownInlineRow_<F>: _CountDownInlineRow, FormalRowType, FormalInlineRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }

    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
}

public typealias FormalCountDownInlineRow = FormalCountDownInlineRow_<Date>
