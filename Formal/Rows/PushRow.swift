//  PushRow.swift
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

open class _PushRow<FormalCell: FormalCellType>: FormalSelectorRow<FormalCell> where FormalCell: FormalBaseCell {

    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: FormalControllerProvider.callback {
            return FormalSelectorViewController<FormalSelectorRow<FormalCell>> { _ in
            }}, onDismiss: { vc in
            let _ = vc.navigationController?.popViewController(animated: true)
        })
    }
}

/// A selector row where the user can pick an option from a pushed view controller
public final class FormalPushSelectorRow<F: Equatable> : _PushRow<FormalPushSelectorCell<F>>, FormalRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

public typealias FormalPushTextSelectorRow = FormalPushSelectorRow<String>
