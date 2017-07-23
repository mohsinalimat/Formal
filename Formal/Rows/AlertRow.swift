//  AlertRow.swift
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


open class _AlertRow<FormalCell: FormalCellType>: FormalOptionsRow<FormalCell>, FormalPresenterRowType where FormalCell: FormalBaseCell {

    public typealias PresentedController = FormalSelectorAlertController<_AlertRow<FormalCell>>
    
    open var onPresentCallback: ((FormalViewController, PresentedController) -> Void)?
    lazy open var presentationMode: FormalPresentationMode<PresentedController>? = {
        return .presentModally(controllerProvider: FormalControllerProvider<PresentedController>.callback { [weak self] in
            let vc = PresentedController(title: self?.selectorTitle, message: nil, preferredStyle: .alert)
            vc.row = self
            return vc
        }, onDismiss: { [weak self] in
            $0.dismiss(animated: true)
            self?.cell?.formalViewController()?.tableView?.reloadData()
        })
    }()

    required public init(tag: String?) {
        super.init(tag: tag)
    }

    open override func customDidSelect() {
        super.customDidSelect()
        if let presentationMode = presentationMode, !isDisabled {
            if let controller = presentationMode.makeController() {
                controller.row = self
                onPresentCallback?(cell.formalViewController()!, controller)
                presentationMode.present(controller, row: self, presentingController: cell.formalViewController()!)
            } else {
                presentationMode.present(nil, row: self, presentingController: cell.formalViewController()!)
            }
        }
    }
}

/// An options row where the user can select an option from a modal Alert
public final class FormalAlertRow<F: Equatable>: _AlertRow<FormalAlertSelectorCell<F>>, FormalRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public typealias FormalTextAlertRow = FormalAlertRow<String>
