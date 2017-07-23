//  PopoverSelectorRow.swift
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

open class _PopoverSelectorRow<FormalCell: FormalCellType> : FormalSelectorRow<FormalCell> where FormalCell: FormalBaseCell, FormalCell: FormalTypedCellType {

    public required init(tag: String?) {
        super.init(tag: tag)
        onPresentCallback = { [weak self] (_, viewController) -> Void in
            guard let porpoverController = viewController.popoverPresentationController, let tableView = self?.baseCell.formalViewController()?.tableView, let cell = self?.cell else {
                fatalError()
            }
            porpoverController.sourceView = tableView
            porpoverController.sourceRect = tableView.convert(cell.detailTextLabel?.frame ?? cell.textLabel?.frame ?? cell.contentView.frame, from: cell)
        }
        presentationMode = .popover(controllerProvider: FormalControllerProvider.callback { return FormalSelectorViewController<FormalSelectorRow<FormalCell>> { _ in } }, onDismiss: { [weak self] in
            $0.dismiss(animated: true)
            self?.reload()
        })
    }

    open override func didSelect() {
        deselect()
        super.didSelect()
    }
}

public final class FormalPopoverSelectorRow<F: Equatable> : _PopoverSelectorRow<FormalPushSelectorCell<F>>, FormalRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public typealias FormalPopoverTextSelectorRow = FormalPopoverSelectorRow<String>
