//
//  Imagery.swift
//  Imagery
//
//  Created by Meniny on 15/6/14.
//
//  Copyright (c) 2015 Meniny 
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import ImageIO

#if os(macOS)
    import AppKit
    public typealias ImageType = NSImage
    public typealias ColorType = NSColor
    public typealias ImageViewType = NSImageView
    typealias ButtonType = NSButton
#else
    import UIKit
    public typealias ImageType = UIImage
    public typealias ColorType = UIColor
    #if !os(watchOS)
    public typealias ImageViewType = UIImageView
    typealias ButtonType = UIButton
    #endif
#endif

public final class Imagery<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

/**
 A type that has Imagery extensions.
 */
public protocol ImageryCompatible {
    associatedtype CompatibleType
    var imagery: CompatibleType { get }
}

public extension ImageryCompatible {
    public var imagery: Imagery<Self> {
        get { return Imagery(self) }
    }
}

extension ImageType: ImageryCompatible { }
#if !os(watchOS)
extension ImageViewType: ImageryCompatible { }
extension ButtonType: ImageryCompatible { }
#endif
