//  PickerInputRow.swift
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

// MARK: FormalPickerInputCell

open class FormalPickerInputCell<F: Equatable> : FormalCell<F>, FormalCellType, UIPickerViewDataSource, UIPickerViewDelegate where F: Equatable, F: InputTypeInitiable {

    lazy public var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private var pickerInputRow: _PickerInputRow<F>? { return row as? _PickerInputRow<F> }

    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        accessoryType = .none
        editingAccessoryType = .none
        picker.delegate = self
        picker.dataSource = self
    }

    deinit {
        picker.delegate = nil
        picker.dataSource = nil
    }

    open override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .none : .default

        if row.title?.isEmpty == false {
            detailTextLabel?.text = row.displayValueFor?(row.value) ?? (row as? FormalNoValueDisplayTextConformance)?.noValueDisplayText
        } else {
            textLabel?.text = row.displayValueFor?(row.value) ?? (row as? FormalNoValueDisplayTextConformance)?.noValueDisplayText
            detailTextLabel?.text = nil
        }

        textLabel?.textColor = row.isDisabled ? .gray : .black
        if row.isHighlighted {
            textLabel?.textColor = tintColor
        }

        picker.reloadAllComponents()
        if let selectedValue = pickerInputRow?.value, let index = pickerInputRow?.options.index(of: selectedValue) {
            picker.selectRow(index, inComponent: 0, animated: true)
        }

    }

    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }

    open override var inputView: UIView? {
        return picker
    }

    open override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder
    }

    override open var canBecomeFirstResponder: Bool {
        return !row.isDisabled
    }

    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerInputRow?.options.count ?? 0
    }

    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerInputRow?.displayValueFor?(pickerInputRow?.options[row])
    }

    open func pickerView(_ pickerView: UIPickerView, didSelectRow rowNumber: Int, inComponent component: Int) {
        if let picker = pickerInputRow, picker.options.count > rowNumber {
            picker.value = picker.options[rowNumber]
            update()
        }
    }
}

// MARK: PickerInputRow

open class _PickerInputRow<F> : FormalRow<FormalPickerInputCell<F>>, FormalNoValueDisplayTextConformance where F: Equatable, F: InputTypeInitiable {
    open var noValueDisplayText: String? = nil

    open var options = [F]()

    required public init(tag: String?) {
        super.init(tag: tag)

    }
}

/// A generic row where the user can pick an option from a picker view displayed in the keyboard area
public final class FormalPickerInputRow<F>: _PickerInputRow<F>, FormalRowType where F: Equatable, F: InputTypeInitiable {

    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public typealias FormalTextPickerInputRow = FormalPickerInputRow<String>
