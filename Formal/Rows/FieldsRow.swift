//  FieldsRow.swift
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

public enum FormalTextType {
    case normal
    case phone
    case account
    case password
    case name
    case email
    case twitter
    case zipCode
    
    public var autocorrectionType: UITextAutocorrectionType {
        switch self {
        case .normal:
            return .default
        default:
            return .no
        }
    }
    
    public var autocapitalizationType: UITextAutocapitalizationType {
        switch self {
        case .name:
            return .words
        case .normal:
            return .sentences
        case .zipCode:
            return .allCharacters
        default:
            return .none
        }
    }
    
    public var keyboardType: UIKeyboardType {
        switch self {
        case .phone:
            return .phonePad
        case .email:
            return .emailAddress
        case .twitter:
            return .twitter
        case .password:
            return .asciiCapable
        case .account:
            return .asciiCapable
        case .zipCode:
            return .numbersAndPunctuation
        default:
            return .default
        }
    }
    
    public var isSecureTextEntry: Bool {
        return self == .password
    }
}

open class FormalTextCell: _TextFieldCell<String>, FormalCellType {
    
    open var contentType: FormalTextType = .normal {
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

open class FormalIntCell: _TextFieldCell<Int>, FormalCellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
    }
}

open class FormalDecimalCell: _TextFieldCell<Double>, FormalCellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.keyboardType = .decimalPad
    }
}

open class FormalURLCell: _TextFieldCell<URL>, FormalCellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .URL
    }
}

/// A String valued row where the user can enter arbitrary text.
public final class FormalTextRow: FormalFieldRow<FormalTextCell>, FormalRowType {
    
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
                _ initializer: ((_ row: FormalTextRow) -> Void)? = nil) {
        super.init(tag: tag)
        FormalRowDefaults.rowInitialization["\(type(of: self))"]?(self)
        initializer?(self)
        self.textType = type
    }
}

/// A row where the user can enter an integer number.
public final class FormalIntRow: FormalFieldRow<FormalIntCell>, FormalRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        formatter = numberFormatter
    }
}

/// A row where the user can enter a decimal number.
public final class FormalDecimalRow: FormalFieldRow<FormalDecimalCell>, FormalRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        formatter = numberFormatter
    }
}

/// A row where the user can enter an URL. The value of this row will be a URL.
public final class FormalURLRow: FormalFieldRow<FormalURLCell>, FormalRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
