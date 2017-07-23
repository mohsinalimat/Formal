//  FloatingTextRow.swift
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
import UIKit

//MARK: FloatingFieldCell

public class _FloatingFieldCell<F>: FormalCell<F>, UITextFieldDelegate, FormalTextFieldCell where F: Equatable, F: InputTypeInitiable {

    public var textField: UITextField! { return floatingTextField }

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    lazy public var floatingTextField: FormalFloatingTextField = { [unowned self] in
        let floatTextField = FormalFloatingTextField()
        floatTextField.translatesAutoresizingMaskIntoConstraints = false
        floatTextField.font = .preferredFont(forTextStyle: .body)
        floatTextField.titleFont = .boldSystemFont(ofSize: 11.0)
        floatTextField.clearButtonMode = .whileEditing
        return floatTextField
        }()


    open override func setup() {
        super.setup()
        height = { 55 }
        selectionStyle = .none
        contentView.addSubview(floatingTextField)
        floatingTextField.delegate = self
        floatingTextField.addTarget(self, action: #selector(_FloatingFieldCell.textFieldDidChange(_:)), for: .editingChanged)
        contentView.addConstraints(layoutConstraints())
    }

    open override func update() {
        super.update()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        floatingTextField.attributedPlaceholder = NSAttributedString(string: row.title ?? "", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        floatingTextField.text =  row.displayValueFor?(row.value)
        floatingTextField.isEnabled = !row.isDisabled
        floatingTextField.titleTextColour = .lightGray
        floatingTextField.alpha = row.isDisabled ? 0.6 : 1
    }

    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && floatingTextField.canBecomeFirstResponder
    }

    open override func cellBecomeFirstResponder(withDirection direction: Direction) -> Bool {
        return floatingTextField.becomeFirstResponder()
    }

    open override func cellResignFirstResponder() -> Bool {
        return floatingTextField.resignFirstResponder()
    }

    private func layoutConstraints() -> [NSLayoutConstraint] {
        let views = ["floatingTextField": floatingTextField]
        let metrics = ["vMargin":8.0]
        return NSLayoutConstraint.constraints(withVisualFormat: "H:|-[floatingTextField]-|", options: .alignAllLastBaseline, metrics: metrics, views: views) + NSLayoutConstraint.constraints(withVisualFormat: "V:|-(vMargin)-[floatingTextField]-(vMargin)-|", options: .alignAllLastBaseline, metrics: metrics, views: views)
    }

    public func textFieldDidChange(_ textField : UITextField){
        guard let textValue = textField.text else {
            row.value = nil
            return
        }
        if let fieldRow = row as? FormalFormatterConformance, let formatter = fieldRow.formatter {
            if fieldRow.useFormatterDuringInput {
                let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<F>.allocate(capacity: 1))
                let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
                if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                    row.value = value.pointee as? F
                    if var selStartPos = textField.selectedTextRange?.start {
                        let oldVal = textField.text
                        textField.text = row.displayValueFor?(row.value)
                        if let f = formatter as? FormalFormatterProtocol {
                            selStartPos = f.getNewPosition(forPosition: selStartPos, inTextInput: textField, oldValue: oldVal, newValue: textField.text)
                        }
                        textField.selectedTextRange = textField.textRange(from: selStartPos, to: selStartPos)
                    }
                    return
                }
            }
            else {
                let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<F>.allocate(capacity: 1))
                let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
                if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                    row.value = value.pointee as? F
                }
                return
            }
        }
        guard !textValue.isEmpty else {
            row.value = nil
            return
        }
        guard let newValue = F.init(stringValue: textValue) else {
            return
        }
        row.value = newValue
    }


    //Mark: Helpers

    private func displayValue(useFormatter: Bool) -> String? {
        guard let v = row.value else { return nil }
        if let formatter = (row as? FormalFormatterConformance)?.formatter, useFormatter {
            return textField?.isFirstResponder == true ? formatter.editingString(for: v) : formatter.string(for: v)
        }
        return String(describing: v)
    }

    //MARK: TextFieldDelegate

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        formalViewController()?.beginEditing(of: self)
        if let fieldRowConformance = row as? FormalFormatterConformance, let _ = fieldRowConformance.formatter, fieldRowConformance.useFormatterOnDidBeginEditing ?? fieldRowConformance.useFormatterDuringInput {
            textField.text = displayValue(useFormatter: true)
        } else {
            textField.text = displayValue(useFormatter: false)
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        formalViewController()?.endEditing(of: self)
        formalViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)
        textField.text = displayValue(useFormatter: (row as? FormalFormatterConformance)?.formatter != nil)
    }
}

public class FormalTextFloatingFieldCell : _FloatingFieldCell<String>, FormalCellType {

    public var contentType: FormalTextType = .normal {
        didSet {
            updateFieldSettings()
        }
    }
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(_ type: FormalTextType, style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentType = type
    }

    open override func setup() {
        super.setup()
        updateFieldSettings()
    }
    
    open func updateFieldSettings() {
        textField.autocorrectionType = contentType.autocorrectionType
        textField.autocapitalizationType = contentType.autocapitalizationType
        textField.keyboardType = contentType.keyboardType
        textField.isSecureTextEntry = contentType.isSecureTextEntry
    }
}

public class FormalIntFloatingFieldCell : _FloatingFieldCell<Int>, FormalCellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func setup() {
        super.setup()
        textField?.autocorrectionType = .default
        textField?.autocapitalizationType = .none
        textField?.keyboardType = .numberPad
    }
}

public class FormalDecimalFloatingFieldCell : _FloatingFieldCell<Float>, FormalCellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func setup() {
        super.setup()
        textField?.keyboardType = .decimalPad
    }
}

public class FormalURLFloatingFieldCell : _FloatingFieldCell<URL>, FormalCellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func setup() {
        super.setup()
        textField?.keyboardType = .URL
    }
}

//MARK: FloatLabelRow

open class _FormalFloatingFieldRow<Cell: FormalCellType>: FormalFormatteableRow<Cell> where Cell: FormalBaseCell, Cell: FormalTextFieldCell {
    
    public var placeholder: String? {
        get {
            return title
        }
        set {
            title = newValue
        }
    }
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class FormalTextFloatingFieldRow: _FormalFloatingFieldRow<FormalTextFloatingFieldCell>, FormalRowType {
    public var textType: FormalTextType {
        get {
            return cell.contentType
        }
        set {
            cell.contentType = newValue
        }
    }
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
    public init(_ type: FormalTextType,
                tag: String?,
                _ initializer: ((_ row: FormalTextFloatingFieldRow) -> Void)? = nil) {
        super.init(tag: tag)
        FormalRowDefaults.rowInitialization["\(type(of: self))"]?(self)
        initializer?(self)
        self.textType = type
    }
}

public final class FormalIntFloatingFieldRow: _FormalFloatingFieldRow<FormalIntFloatingFieldCell>, FormalRowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class FormalDecimalingFloatLabelRow: _FormalFloatingFieldRow<FormalDecimalFloatingFieldCell>, FormalRowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public final class FormalURLFloatingFieldRow: _FormalFloatingFieldRow<FormalURLFloatingFieldCell>, FormalRowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
