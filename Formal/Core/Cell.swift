//  FormalCell.swift
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

/// Base class for the Formal cells
open class FormalBaseCell: UITableViewCell, FormalBaseCellType {

    /// Untyped row associated to this cell.
    public var baseRow: FormalBaseRow! { return nil }

    /// Block that returns the height for this cell.
    public var height: (() -> CGFloat)?

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    /**
     Function that returns the FormalViewController this cell belongs to.
     */
    public func formalViewController() -> FormalViewController? {
        var responder: AnyObject? = self
        while responder != nil {
            if let formVC = responder as? FormalViewController {
              return formVC
            }
            responder = responder?.next
        }
        return nil
    }

    open func setup() {}
    open func update() {}

    open func didSelect() {}

    /**
     If the cell can become first responder. By default returns false
     */
    open func cellCanBecomeFirstResponder() -> Bool {
        return false
    }

    /**
     Called when the cell becomes first responder
     */
    @discardableResult
    open func cellBecomeFirstResponder(withDirection: Direction = .down) -> Bool {
        return becomeFirstResponder()
    }

    /**
     Called when the cell resigns first responder
     */
    @discardableResult
    open func cellResignFirstResponder() -> Bool {
        return resignFirstResponder()
    }
}

/// Generic class that represents the Formal cells.
open class FormalCell<F: Equatable> : FormalBaseCell, FormalTypedCellType {

    public typealias Value = F

    /// The row associated to this cell
    public weak var row: FormalRowOf<F>!

    /// Returns the navigationAccessoryView if it is defined or calls super if not.
    override open var inputAccessoryView: UIView? {
        if let v = formalViewController()?.inputAccessoryView(for: row) {
            return v
        }
        return super.inputAccessoryView
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    /**
     Function responsible for setting up the cell at creation time.
     */
    open override func setup() {
        super.setup()
    }

    /**
     Function responsible for updating the cell each time it is reloaded.
     */
    open override func update() {
        super.update()
        textLabel?.text = row.title
        textLabel?.textColor = row.isDisabled ? .gray : .black
        detailTextLabel?.text = row.displayValueFor?(row.value) ?? (row as? FormalNoValueDisplayTextConformance)?.noValueDisplayText
    }

    /**
     Called when the cell was selected.
     */
    open override func didSelect() {}

    override open var canBecomeFirstResponder: Bool {
        return false
    }

    open override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            formalViewController()?.beginEditing(of: self)
        }
        return result
    }

    open override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            formalViewController()?.endEditing(of: self)
        }
        return result
    }

    /// The untyped row associated to this cell.
    public override var baseRow: FormalBaseRow! { return row }
}
