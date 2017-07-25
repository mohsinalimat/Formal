//
//  ImageryResource.swift
//  Imagery
//
//  Created by Meniny on 15/4/6.
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

/// `ImageryResource` protocol defines how to download and cache a resource from network.
public protocol ImageryResource {
    /// The key used in cache.
    var cacheKey: String { get }
    
    /// The target image URL.
    var downloadURL: URL { get }
}

/**
 ImageResource is a simple combination of `downloadURL` and `cacheKey`.
 
 When passed to image view set methods, Imagery will try to download the target 
 image from the `downloadURL`, and then store it with the `cacheKey` as the key in cache.
 */
public struct ImageResource: ImageryResource {
    /// The key used in cache.
    public let cacheKey: String
    
    /// The target image URL.
    public let downloadURL: URL
    
    /**
     Create a resource.
     
     - parameter downloadURL: The target image URL.
     - parameter cacheKey:    The cache key. If `nil`, Imagery will use the `absoluteString` of `downloadURL` as the key.
     
     - returns: A resource.
     */
    public init(downloadURL: URL, cacheKey: String? = nil) {
        self.downloadURL = downloadURL
        self.cacheKey = cacheKey ?? downloadURL.absoluteString
    }
}

/**
 URL conforms to `ImageryResource` in Imagery.
 The `absoluteString` of this URL is used as `cacheKey`. And the URL itself will be used as `downloadURL`.
 If you need customize the url and/or cache key, use `ImageResource` instead.
 */
extension URL: ImageryResource {
    public var cacheKey: String { return absoluteString }
    public var downloadURL: URL { return self }
}

///**
// String conforms to `ImageryResource` in Imagery.
// The `MD5` of this String is used as `cacheKey`. And the String itself will be used as `downloadURL`.
// If you need customize the url and/or cache key, use `ImageResource` instead.
// */
//extension String: ImageryResource {
//    public var cacheKey: String { return StringProxy(proxy: self).md5 }
//    public var downloadURL: URL { return URL(string: self)! }
//}
