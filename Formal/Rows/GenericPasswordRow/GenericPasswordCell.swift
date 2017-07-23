//
//  FormalGenericPasswordCell.swift
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

open class FormalGenericPasswordCell: _TextFieldCell<String>, FormalCellType {

    @IBOutlet weak var visibilityButton: UIButton?
    @IBOutlet weak var passwordStrengthView: FormalPasswordStrengthView?
    @IBOutlet public weak var hintLabel: UILabel?

    @IBOutlet public weak var leading: NSLayoutConstraint!
    @IBOutlet public weak var trailing: NSLayoutConstraint!

    var genericPasswordRow: _GenericPasswordRow! {
        return row as? _GenericPasswordRow
    }

    open var visibilityImage: (on: UIImage?, off: UIImage?) {
        didSet {
            setVisibilityButtonImage()
        }
    }

    open var dynamicHeight = (collapsed: UITableViewAutomaticDimension, expanded: UITableViewAutomaticDimension) {
        didSet {
            let value = dynamicHeight
            height = { [weak self] in
                self?.hintLabel?.isHidden == true ? value.collapsed : value.expanded
            }
        }
    }

    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        dynamicHeight = (collapsed: 48, expanded: 64)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .asciiCapable
        textField.isSecureTextEntry = true
        selectionStyle = .none
        textField.clearsOnInsertion = false
        textField.clearsOnBeginEditing = false
        textField.addTarget(self, action: #selector(FormalGenericPasswordCell.textFieldDidChange(_:)), for: .editingChanged)

        visibilityButton?.addTarget(self, action: #selector(FormalGenericPasswordCell.togglePasswordVisibility), for: .touchUpInside)
        visibilityButton?.tintColor = .gray

        let on = UIImage.formalResource(named: "visibility")?.withRenderingMode(.alwaysTemplate)
        let off = UIImage.formalResource(named: "visibility_off")?.withRenderingMode(.alwaysTemplate)
        visibilityImage = (on: on, off: off)
        hintLabel?.alpha = 0
        passwordStrengthView?.setPasswordValidator(genericPasswordRow.passwordValidator)
        updatePasswordStrengthIfNeeded(animated: false)
    }

    override open func update() {
        super.update()
        textLabel?.text = nil
        textField.text = genericPasswordRow.value
        textField.placeholder = genericPasswordRow.placeholder
    }

    open func togglePasswordVisibility() {
        textField.isSecureTextEntry = !textField.isSecureTextEntry
        setVisibilityButtonImage()
        // workaround to update cursor position
        let tmpString = textField.text
        textField.text = nil
        textField.text = tmpString
    }

    fileprivate func setVisibilityButtonImage() {
        visibilityButton?.setImage(textField.isSecureTextEntry ? visibilityImage.on : visibilityImage.off, for: .normal)
    }

    open override func textFieldDidChange(_ textField: UITextField) {
        genericPasswordRow.value = textField.text
        updatePasswordStrengthIfNeeded()

        formalViewController()?.tableView?.beginUpdates()
        // this updates the height of the cell
        formalViewController()?.tableView?.endUpdates()

        UIView.animate(withDuration: 0.3, delay: 0.2, options: [], animations: { [weak self] in
            guard let me = self else { return }
            me.hintLabel?.alpha = me.hintLabel?.isHidden == true ? 0 : 1
            }, completion: nil)

        // make the cell full visible
        if let indexPath = row?.indexPath {
            UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: { [weak self] in
                self?.formalViewController()?.tableView?.scrollToRow(at: indexPath, at: .none, animated: false)
                }, completion: nil)
        }
    }

    open func updatePasswordStrengthIfNeeded(animated: Bool = true) {
        guard let password = genericPasswordRow.value else {
            return
        }
        if textField.text == nil {
            textField.text = password
        }
        passwordStrengthView?.updateStrength(password: password, animated: animated)
        let hint = genericPasswordRow.passwordValidator.hintForPassword(password)
        hintLabel?.text = hint
        hintLabel?.isHidden = hint == nil || password.isEmpty
    }

}
