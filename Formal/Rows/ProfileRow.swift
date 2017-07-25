//
//  ProfileHeaderTableViewCell.swift
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

import UIKit
import Foundation

public struct FormalProfile: Equatable {
    
    /// URL or UIImage name
    public var avatar: String
    public var name: String
    public var brief: String
    
    public static func ==(lhs: FormalProfile, rhs: FormalProfile) -> Bool {
        return lhs.avatar == rhs.avatar && lhs.name == rhs.name && lhs.brief == rhs.brief
    }
}

// Profile Cell with value type: Bool
// The cell is defined using a .xib, so we can set outlets :)
open class FormalProfileCell: FormalCell<FormalProfile>, FormalCellType {
    
    @IBOutlet public weak var avatarView: UIImageView!
    @IBOutlet public weak var nameLabel: UILabel!
    @IBOutlet public weak var descriptionLabel: UILabel!
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func update() {
        super.update()
        selectionStyle = .none
        if let v = row.value {
            if let url = URL(string: v.avatar) {
//                avatarView.sd_setImage(with: url, placeholderImage: nil)
                avatarView.imagery.setImage(with: url, placeholder: nil)
            } else {
                avatarView.image = UIImage(named: v.avatar)
            }
        } else {
            avatarView.image = nil
        }
        nameLabel.text = row.value?.name
        descriptionLabel.text = row.value?.brief
    }
}

// The profile Row also has the cell: FormalProfileCell and its correspond value
public final class FormalProfileRow: FormalRow<FormalProfileCell>, FormalRowType {
    required public init(tag: String?) {
        
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = FormalCellProvider<FormalProfileCell>(nibName: "FormalProfileCell", bundle: nil)
    }
}
