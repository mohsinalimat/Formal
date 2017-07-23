//
//  ImageCheckRow.swift
//  Pods
//
//  Created by Meniny on 2017-07-23.
//
//

import Foundation
import UIKit

public final class FormalImageCheckRow: FormalRow<FormalImageCheckCell>, SelectableRowType, FormalRowType {
    
    public var selectableValue: Bool?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public class FormalImageCheckCell: FormalCell<Bool>, FormalCellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Image for selected state
    lazy public var trueImage: UIImage = {
        return UIImage.formalResource(named: "selectedCircle")!
    }()
    
    /// Image for unselected state
    lazy public var falseImage: UIImage = {
        return UIImage.formalResource(named: "unselectedCircle")!
    }()
    
    public override func update() {
        super.update()
        if row.value != nil {
            checkImageView?.image = row.value! ? trueImage : falseImage
        } else {
            checkImageView?.image = falseImage
        }
        checkImageView?.sizeToFit()
    }
    
    /// Image view to render images. If `accessoryType` is set to `checkmark`
    /// will create a new `UIImageView` and set it as `accessoryView`.
    /// Otherwise returns `self.imageView`.
    open var checkImageView: UIImageView? {
        guard accessoryType == .checkmark else {
            return self.imageView
        }
        
        guard let accessoryView = accessoryView else {
            let imageView = UIImageView()
            self.accessoryView = imageView
            return imageView
        }
        
        return accessoryView as? UIImageView
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .none
    }
    
    public override func didSelect() {
        if row.value != nil {
            row.value = !row.value!
        } else {
            row.value = true
        }
        row.reload()
        row.select()
        row.deselect()
    }
    
}
