//
//  CacheSerializer.swift
//  Imagery
//
//  Created by Meniny on 2015/09/02.
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

/// An `CacheSerializer` would be used to convert some data to an image object for 
/// retrieving from disk cache and vice versa for storing to disk cache.
public protocol CacheSerializer {
    
    /// Get the serialized data from a provided image
    /// and optional original data for caching to disk.
    ///
    ///
    /// - parameter image:    The image needed to be serialized.
    /// - parameter original: The original data which is just downloaded. 
    ///                       If the image is retrieved from cache instead of
    ///                       downloaded, it will be `nil`.
    ///
    /// - returns: A data which will be stored to cache, or `nil` when no valid
    ///            data could be serialized.
    func data(with image: ImageType, original: Data?) -> Data?
    
    /// Get an image deserialized from provided data.
    ///
    /// - parameter data:    The data from which an image should be deserialized.
    /// - parameter options: Options for deserialization.
    ///
    /// - returns: An image deserialized or `nil` when no valid image 
    ///            could be deserialized.
    func image(with data: Data, options: ImageryOptionsInfo?) -> ImageType?
}


/// `DefaultCacheSerializer` is a basic `CacheSerializer` used in default cache of
/// Imagery. It could serialize and deserialize PNG, JEPG and GIF images. For 
/// image other than these formats, a normalized `pngRepresentation` will be used.
public struct DefaultCacheSerializer: CacheSerializer {
    
    public static let `default` = DefaultCacheSerializer()
    private init() {}
    
    public func data(with image: ImageType, original: Data?) -> Data? {
        let imageFormat = original?.imagery.imageFormat ?? .unknown
        
        let data: Data?
        switch imageFormat {
        case .PNG: data = image.imagery.pngRepresentation()
        case .JPEG: data = image.imagery.jpegRepresentation(compressionQuality: 1.0)
        case .GIF: data = image.imagery.gifRepresentation()
        case .unknown: data = original ?? image.imagery.normalized.imagery.pngRepresentation()
        }
        
        return data
    }
    
    public func image(with data: Data, options: ImageryOptionsInfo?) -> ImageType? {
        let options = options ?? ImageryEmptyOptionsInfo
        return Imagery<ImageType>.image(
            data: data,
            scale: options.scaleFactor,
            preloadAllAnimationData: options.preloadAllAnimationData,
            onlyFirstFrame: options.onlyLoadFirstFrame)
    }
}
