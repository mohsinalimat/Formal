//
//  CaveCell.swift
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
//import SDWebImage
import Imagery

public struct FormalProduct: Equatable {
    
    /// URL or UIImage name
    public var image: String
    public var title: String
    public var brief: String
    
    public static func ==(lhs: FormalProduct, rhs: FormalProduct) -> Bool {
        return lhs.image == rhs.image && lhs.title == rhs.title && lhs.brief == rhs.brief
    }
}

// FormalProductCell with value type: Bool
// The cell is defined using a .xib, so we can set outlets :)
open class FormalProductCell: FormalCell<FormalProduct>, FormalCellType {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func update() {
        super.update()
        selectionStyle = .none
        if let st = row.value {
            if let url = URL(string: st.image) {
//                iconView.sd_setImage(with: url, placeholderImage: nil)
                iconView.imagery.setImage(with: url, placeholder: nil)
            } else {
                iconView.image = UIImage(named: st.image)
            }
        } else {
            iconView.image = nil
        }
        titleLabel.text = row.value?.title
        descriptionLabel.text = row.value?.brief
    }
}

// The ProductRow also has the cell: FormalProductCell and its correspond value
public final class FormalProductRow: FormalRow<FormalProductCell>, FormalRowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = FormalCellProvider<FormalProductCell>(nibName: "FormalProductCell", bundle: nil)
    }
}

