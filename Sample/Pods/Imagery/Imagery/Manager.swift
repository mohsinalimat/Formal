//
//  ImageryManager.swift
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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public typealias ImageryDownloadProgressBlock = ((_ receivedSize: Int64, _ totalSize: Int64) -> ())
public typealias ImageryCompletionHandler = ((_ image: ImageType?, _ error: NSError?, _ cacheType: ImageryCacheType, _ imageURL: URL?) -> ())

/// ImageryRetrieveImageTask represents a task of image retrieving process.
/// It contains an async task of getting image from disk and from network.
public class ImageryRetrieveImageTask {
    
    public static let empty = ImageryRetrieveImageTask()
    
    // If task is canceled before the download task started (which means the `downloadTask` is nil),
    // the download task should not begin.
    var cancelledBeforeDownloadStarting: Bool = false
    
    /// The network retrieve task in this image task.
    public var downloadTask: RetrieveImageDownloadTask?
    
    /**
    Cancel current task. If this task is already done, do nothing.
    */
    public func cancel() {
        if let downloadTask = downloadTask {
            downloadTask.cancel()
        } else {
            cancelledBeforeDownloadStarting = true
        }
    }
}

/// Error domain of Imagery
public let ImageryErrorDomain = "cn.meniny.Imagery.Error"

/// Main manager class of Imagery. It connects Imagery downloader and cache.
/// You can use this class to retrieve an image via a specified URL from web or cache.
public class ImageryManager {
    
    /// Shared manager used by the extensions across Imagery.
    public static let shared = ImageryManager()
    
    /// Cache used by this manager
    public var cache: ImageryCache
    
    /// Downloader used by this manager
    public var downloader: ImageDownloader
    
    /// Default options used by the manager. This option will be used in 
    /// Imagery manager related methods, including all image view and 
    /// button extension methods. You can also passing the options per image by 
    /// sending an `options` parameter to Imagery's APIs, the per image option 
    /// will overwrite the default ones if exist.
    ///
    /// - Note: This option will not be applied to independent using of `ImageDownloader` or `ImageryCache`.
    public var defaultOptions = ImageryEmptyOptionsInfo
    
    var currentDefaultOptions: ImageryOptionsInfo {
        return [.downloader(downloader), .targetCache(cache)] + defaultOptions
    }
    
    convenience init() {
        self.init(downloader: .default, cache: .default)
    }
    
    init(downloader: ImageDownloader, cache: ImageryCache) {
        self.downloader = downloader
        self.cache = cache
    }
    
    /**
    Get an image with resource.
    If ImageryOptions.None is used as `options`, Imagery will seek the image in memory and disk first.
    If not found, it will download the image at `resource.downloadURL` and cache it with `resource.cacheKey`.
    These default behaviors could be adjusted by passing different options. See `ImageryOptions` for more.
    
    - parameter resource:          ImageryResource object contains information such as `cacheKey` and `downloadURL`.
    - parameter options:           A dictionary could control some behaviors. See `ImageryOptionsInfo` for more.
    - parameter progressBlock:     Called every time downloaded data changed. This could be used as a progress UI.
    - parameter completionHandler: Called when the whole retrieving process finished.
    
    - returns: A `ImageryRetrieveImageTask` task object. You can use this object to cancel the task.
    */
    @discardableResult
    public func retrieveImage(with resource: ImageryResource,
        options: ImageryOptionsInfo?,
        progressBlock: ImageryDownloadProgressBlock?,
        completionHandler: ImageryCompletionHandler?) -> ImageryRetrieveImageTask
    {
        let task = ImageryRetrieveImageTask()
        let options = currentDefaultOptions + (options ?? ImageryEmptyOptionsInfo)
        if options.forceRefresh {
            _ = downloadAndCacheImage(
                with: resource.downloadURL,
                forKey: resource.cacheKey,
                retrieveImageTask: task,
                progressBlock: progressBlock,
                completionHandler: completionHandler,
                options: options)
        } else {
            tryToRetrieveImageFromCache(
                forKey: resource.cacheKey,
                with: resource.downloadURL,
                retrieveImageTask: task,
                progressBlock: progressBlock,
                completionHandler: completionHandler,
                options: options)
        }
        
        return task
    }

    @discardableResult
    func downloadAndCacheImage(with url: URL,
                             forKey key: String,
                      retrieveImageTask: ImageryRetrieveImageTask,
                          progressBlock: ImageryDownloadProgressBlock?,
                      completionHandler: ImageryCompletionHandler?,
                                options: ImageryOptionsInfo) -> RetrieveImageDownloadTask?
    {
        let downloader = options.downloader
        return downloader.downloadImage(with: url, retrieveImageTask: retrieveImageTask, options: options,
            progressBlock: { receivedSize, totalSize in
                progressBlock?(receivedSize, totalSize)
            },
            completionHandler: { image, error, imageURL, originalData in

                let targetCache = options.targetCache
                if let error = error, error.code == ImageryError.notModified.rawValue {
                    // Not modified. Try to find the image from cache.
                    // (The image should be in cache. It should be guaranteed by the framework users.)
                    targetCache.retrieveImage(forKey: key, options: options, completionHandler: { (cacheImage, cacheType) -> () in
                        completionHandler?(cacheImage, nil, cacheType, url)
                    })
                    return
                }
                
                if let image = image, let originalData = originalData {
                    targetCache.store(image,
                                      original: originalData,
                                      forKey: key,
                                      processorIdentifier:options.processor.identifier,
                                      cacheSerializer: options.cacheSerializer,
                                      toDisk: !options.cacheMemoryOnly,
                                      completionHandler: nil)
                    if options.cacheOriginalImage {
                        let defaultProcessor = DefaultImageProcessor.default
                        if let originaliImage = defaultProcessor.process(item: .data(originalData), options: options) {
                            targetCache.store(originaliImage,
                                              original: originalData,
                                              forKey: key,
                                              processorIdentifier: defaultProcessor.identifier,
                                              cacheSerializer: options.cacheSerializer,
                                              toDisk: !options.cacheMemoryOnly,
                                              completionHandler: nil)
                        }
                        
                    }
                }

                completionHandler?(image, error, .none, url)

            })
    }
    
    func tryToRetrieveImageFromCache(forKey key: String,
                                       with url: URL,
                              retrieveImageTask: ImageryRetrieveImageTask,
                                  progressBlock: ImageryDownloadProgressBlock?,
                              completionHandler: ImageryCompletionHandler?,
                                        options: ImageryOptionsInfo)
    {
        
        
        let diskTaskImageryCompletionHandler: ImageryCompletionHandler = { (image, error, cacheType, imageURL) -> () in
            completionHandler?(image, error, cacheType, imageURL)
        }
        
        func handleNoCache() {
            if options.onlyFromCache {
                let error = NSError(domain: ImageryErrorDomain, code: ImageryError.notCached.rawValue, userInfo: nil)
                diskTaskImageryCompletionHandler(nil, error, .none, url)
                return
            }
            self.downloadAndCacheImage(
                with: url,
                forKey: key,
                retrieveImageTask: retrieveImageTask,
                progressBlock: progressBlock,
                completionHandler: diskTaskImageryCompletionHandler,
                options: options)
            
        }
        
        let targetCache = options.targetCache
        // First, try to get the exactly image from cache
        targetCache.retrieveImage(forKey: key, options: options) { image, cacheType in
            // If found, we could finish now.
            if image != nil {
                diskTaskImageryCompletionHandler(image, nil, cacheType, url)
                return
            }
            
            // If not found, and we are using a default processor, download it!
            let processor = options.processor
            guard processor != DefaultImageProcessor.default else {
                handleNoCache()
                return
            }
            
            // If processor is not the default one, we have a chance to check whether
            // the original image is already in cache.
            let optionsWithoutProcessor = options.removeAllMatchesIgnoringAssociatedValue(.processor(processor))
            targetCache.retrieveImage(forKey: key, options: optionsWithoutProcessor) { image, cacheType in
                // If we found the original image, there is no need to download it again.
                // We could just apply processor to it now.
                guard let image = image else {
                    handleNoCache()
                    return
                }
                
                guard let processedImage = processor.process(item: .image(image), options: options) else {
                    diskTaskImageryCompletionHandler(nil, nil, .none, url)
                    return
                }
                targetCache.store(processedImage,
                                  original: nil,
                                  forKey: key,
                                  processorIdentifier:options.processor.identifier,
                                  cacheSerializer: options.cacheSerializer,
                                  toDisk: !options.cacheMemoryOnly,
                                  completionHandler: nil)
                diskTaskImageryCompletionHandler(processedImage, nil, .none, url)
            }
        }
    }
}
