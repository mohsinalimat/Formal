//
//  UIButton+Imagery.swift
//  Imagery
//
//  Created by Meniny on 15/4/13.
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

import UIKit

// MARK: - Set Images
/**
 *	Set image to use in button from web for a specified state.
 */
extension Imagery where Base: UIButton {
    /**
     Set an image to use for a specified state with a resource, a placeholder image, options, progress handler and
     completion handler.
     
     - parameter resource:          ImageryResource object contains information such as `cacheKey` and `downloadURL`.
     - parameter state:             The state that uses the specified image.
     - parameter placeholder:       A placeholder image when retrieving the image at URL.
     - parameter options:           A dictionary could control some behaviors. See `ImageryOptionsInfo` for more.
     - parameter progressBlock:     Called when the image downloading progress gets updated.
     - parameter completionHandler: Called when the image retrieved and set.
     
     - returns: A task represents the retrieving process.
     
     - note: Both the `progressBlock` and `completionHandler` will be invoked in main thread.
     The `CallbackDispatchQueue` specified in `optionsInfo` will not be used in callbacks of this method.
     
     If `resource` is `nil`, the `placeholder` image will be set and
     `completionHandler` will be called with both `error` and `image` being `nil`.
     */
    @discardableResult
    public func setImage(with resource: ImageryResource?,
                         for state: UIControlState,
                         placeholder: UIImage? = nil,
                         options: ImageryOptionsInfo? = nil,
                         progressBlock: ImageryDownloadProgressBlock? = nil,
                         completionHandler: ImageryCompletionHandler? = nil) -> ImageryRetrieveImageTask {
        guard let resource = resource else {
            base.setImage(placeholder, for: state)
            setWebURL(nil, for: state)
            completionHandler?(nil, nil, .none, nil)
            return .empty
        }
        
        let options = ImageryManager.shared.defaultOptions + (options ?? ImageryEmptyOptionsInfo)
        if !options.keepCurrentImageWhileLoading {
            base.setImage(placeholder, for: state)
        }
        
        setWebURL(resource.downloadURL, for: state)
        let task = ImageryManager.shared.retrieveImage(
            with: resource,
            options: options,
            progressBlock: { receivedSize, totalSize in
                guard resource.downloadURL == self.webURL(for: state) else {
                    return
                }
                if let progressBlock = progressBlock {
                    progressBlock(receivedSize, totalSize)
                }
            },
            completionHandler: {[weak base] image, error, cacheType, imageURL in
                DispatchQueue.main.safeAsync {
                    guard let strongBase = base, imageURL == self.webURL(for: state) else {
                        completionHandler?(image, error, cacheType, imageURL)
                        return
                    }
                    self.setImageTask(nil)
                    if image != nil {
                        strongBase.setImage(image, for: state)
                    }

                    completionHandler?(image, error, cacheType, imageURL)
                }
            })
        
        setImageTask(task)
        return task
    }
    
    /**
     Cancel the image download task bounded to the image view if it is running.
     Nothing will happen if the downloading has already finished.
     */
    public func cancelImageDownloadTask() {
        imageTask?.cancel()
    }
    
    /**
     Set the background image to use for a specified state with a resource,
     a placeholder image, options progress handler and completion handler.
     
     - parameter resource:          ImageryResource object contains information such as `cacheKey` and `downloadURL`.
     - parameter state:             The state that uses the specified image.
     - parameter placeholder:       A placeholder image when retrieving the image at URL.
     - parameter options:           A dictionary could control some behaviors. See `ImageryOptionsInfo` for more.
     - parameter progressBlock:     Called when the image downloading progress gets updated.
     - parameter completionHandler: Called when the image retrieved and set.
     
     - returns: A task represents the retrieving process.
     
     - note: Both the `progressBlock` and `completionHandler` will be invoked in main thread.
     The `CallbackDispatchQueue` specified in `optionsInfo` will not be used in callbacks of this method.
     
     If `resource` is `nil`, the `placeholder` image will be set and
     `completionHandler` will be called with both `error` and `image` being `nil`.
     */
    @discardableResult
    public func setBackgroundImage(with resource: ImageryResource?,
                                   for state: UIControlState,
                                   placeholder: UIImage?,
                                   options: ImageryOptionsInfo? = nil,
                                   progressBlock: ImageryDownloadProgressBlock? = nil,
                                   completionHandler: ImageryCompletionHandler? = nil) -> ImageryRetrieveImageTask
    {
        guard let resource = resource else {
            base.setBackgroundImage(placeholder, for: state)
            setBackgroundWebURL(nil, for: state)
            completionHandler?(nil, nil, .none, nil)
            return .empty
        }
        
        let options = ImageryManager.shared.defaultOptions + (options ?? ImageryEmptyOptionsInfo)
        if !options.keepCurrentImageWhileLoading {
            base.setBackgroundImage(placeholder, for: state)
        }
        
        setBackgroundWebURL(resource.downloadURL, for: state)
        let task = ImageryManager.shared.retrieveImage(
            with: resource,
            options: options,
            progressBlock: { receivedSize, totalSize in
                guard resource.downloadURL == self.backgroundWebURL(for: state) else {
                    return
                }
                if let progressBlock = progressBlock {
                    progressBlock(receivedSize, totalSize)
                }
            },
            completionHandler: { [weak base] image, error, cacheType, imageURL in
                DispatchQueue.main.safeAsync {
                    guard let strongBase = base, imageURL == self.backgroundWebURL(for: state) else {
                        completionHandler?(image, error, cacheType, imageURL)
                        return
                    }
                    self.setBackgroundImageTask(nil)
                    if image != nil {
                        strongBase.setBackgroundImage(image, for: state)
                    }
                    completionHandler?(image, error, cacheType, imageURL)
                }
            })
        
        setBackgroundImageTask(task)
        return task
    }
    
    /**
     Cancel the background image download task bounded to the image view if it is running.
     Nothing will happen if the downloading has already finished.
     */
    public func cancelBackgroundImageDownloadTask() {
        backgroundImageTask?.cancel()
    }

}

// MARK: - Associated Object
private var lastURLKey: Void?
private var imageTaskKey: Void?

extension Imagery where Base: UIButton {
    /**
     Get the image URL binded to this button for a specified state.
     
     - parameter state: The state that uses the specified image.
     
     - returns: Current URL for image.
     */
    public func webURL(for state: UIControlState) -> URL? {
        return webURLs[NSNumber(value:state.rawValue)] as? URL
    }
    
    fileprivate func setWebURL(_ url: URL?, for state: UIControlState) {
        webURLs[NSNumber(value:state.rawValue)] = url
    }
    
    fileprivate var webURLs: NSMutableDictionary {
        var dictionary = objc_getAssociatedObject(base, &lastURLKey) as? NSMutableDictionary
        if dictionary == nil {
            dictionary = NSMutableDictionary()
            setWebURLs(dictionary!)
        }
        return dictionary!
    }
    
    fileprivate func setWebURLs(_ URLs: NSMutableDictionary) {
        objc_setAssociatedObject(base, &lastURLKey, URLs, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    fileprivate var imageTask: ImageryRetrieveImageTask? {
        return objc_getAssociatedObject(base, &imageTaskKey) as? ImageryRetrieveImageTask
    }
    
    fileprivate func setImageTask(_ task: ImageryRetrieveImageTask?) {
        objc_setAssociatedObject(base, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}


private var lastBackgroundURLKey: Void?
private var backgroundImageTaskKey: Void?


extension Imagery where Base: UIButton {
    /**
     Get the background image URL binded to this button for a specified state.
     
     - parameter state: The state that uses the specified background image.
     
     - returns: Current URL for background image.
     */
    public func backgroundWebURL(for state: UIControlState) -> URL? {
        return backgroundWebURLs[NSNumber(value:state.rawValue)] as? URL
    }
    
    fileprivate func setBackgroundWebURL(_ url: URL?, for state: UIControlState) {
        backgroundWebURLs[NSNumber(value:state.rawValue)] = url
    }
    
    fileprivate var backgroundWebURLs: NSMutableDictionary {
        var dictionary = objc_getAssociatedObject(base, &lastBackgroundURLKey) as? NSMutableDictionary
        if dictionary == nil {
            dictionary = NSMutableDictionary()
            setBackgroundWebURLs(dictionary!)
        }
        return dictionary!
    }
    
    fileprivate func setBackgroundWebURLs(_ URLs: NSMutableDictionary) {
        objc_setAssociatedObject(base, &lastBackgroundURLKey, URLs, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    fileprivate var backgroundImageTask: ImageryRetrieveImageTask? {
        return objc_getAssociatedObject(base, &backgroundImageTaskKey) as? ImageryRetrieveImageTask
    }
    
    fileprivate func setBackgroundImageTask(_ task: ImageryRetrieveImageTask?) {
        objc_setAssociatedObject(base, &backgroundImageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - Deprecated. Only for back compatibility.
/**
*	Set image to use from web for a specified state. Deprecated. Use `imagery` namespacing instead.
*/
extension UIButton {
    /**
    Set an image to use for a specified state with a resource, a placeholder image, options, progress handler and 
     completion handler.
    
    - parameter resource:          ImageryResource object contains information such as `cacheKey` and `downloadURL`.
    - parameter state:             The state that uses the specified image.
    - parameter placeholder:       A placeholder image when retrieving the image at URL.
    - parameter options:           A dictionary could control some behaviors. See `ImageryOptionsInfo` for more.
    - parameter progressBlock:     Called when the image downloading progress gets updated.
    - parameter completionHandler: Called when the image retrieved and set.
    
    - returns: A task represents the retrieving process.
     
    - note: Both the `progressBlock` and `completionHandler` will be invoked in main thread.
     The `CallbackDispatchQueue` specified in `optionsInfo` will not be used in callbacks of this method.
    */
    @discardableResult
    @available(*, deprecated,
    message: "Extensions directly on UIButton are deprecated. Use `button.imagery.setImage` instead.",
    renamed: "imagery.setImage")
    public func imagery_setImage(with resource: ImageryResource?,
                                for state: UIControlState,
                              placeholder: UIImage? = nil,
                                  options: ImageryOptionsInfo? = nil,
                            progressBlock: ImageryDownloadProgressBlock? = nil,
                        completionHandler: ImageryCompletionHandler? = nil) -> ImageryRetrieveImageTask
    {
        return imagery.setImage(with: resource, for: state, placeholder: placeholder, options: options,
                              progressBlock: progressBlock, completionHandler: completionHandler)
    }
    
    /**
     Cancel the image download task bounded to the image view if it is running.
     Nothing will happen if the downloading has already finished.
     */
    @available(*, deprecated,
    message: "Extensions directly on UIButton are deprecated. Use `button.imagery.cancelImageDownloadTask` instead.",
    renamed: "imagery.cancelImageDownloadTask")
    public func imagery_cancelImageDownloadTask() { imagery.cancelImageDownloadTask() }
    
    /**
     Set the background image to use for a specified state with a resource,
     a placeholder image, options progress handler and completion handler.
     
     - parameter resource:          ImageryResource object contains information such as `cacheKey` and `downloadURL`.
     - parameter state:             The state that uses the specified image.
     - parameter placeholder:       A placeholder image when retrieving the image at URL.
     - parameter options:           A dictionary could control some behaviors. See `ImageryOptionsInfo` for more.
     - parameter progressBlock:     Called when the image downloading progress gets updated.
     - parameter completionHandler: Called when the image retrieved and set.
     
     - returns: A task represents the retrieving process.
     
     - note: Both the `progressBlock` and `completionHandler` will be invoked in main thread.
     The `CallbackDispatchQueue` specified in `optionsInfo` will not be used in callbacks of this method.
     */
    @discardableResult
    @available(*, deprecated,
    message: "Extensions directly on UIButton are deprecated. Use `button.imagery.setBackgroundImage` instead.",
    renamed: "imagery.setBackgroundImage")
    public func imagery_setBackgroundImage(with resource: ImageryResource?,
                                      for state: UIControlState,
                                      placeholder: UIImage? = nil,
                                      options: ImageryOptionsInfo? = nil,
                                      progressBlock: ImageryDownloadProgressBlock? = nil,
                                      completionHandler: ImageryCompletionHandler? = nil) -> ImageryRetrieveImageTask
    {
        return imagery.setBackgroundImage(with: resource, for: state, placeholder: placeholder, options: options,
                                     progressBlock: progressBlock, completionHandler: completionHandler)
    }
    
    /**
     Cancel the background image download task bounded to the image view if it is running.
     Nothing will happen if the downloading has already finished.
     */
    @available(*, deprecated,
    message: "Extensions directly on UIButton are deprecated. Use `button.imagery.cancelBackgroundImageDownloadTask` instead.",
    renamed: "imagery.cancelBackgroundImageDownloadTask")
    public func imagery_cancelBackgroundImageDownloadTask() { imagery.cancelBackgroundImageDownloadTask() }
    
    /**
     Get the image URL binded to this button for a specified state.
     
     - parameter state: The state that uses the specified image.
     
     - returns: Current URL for image.
     */
    @available(*, deprecated,
        message: "Extensions directly on UIButton are deprecated. Use `button.imagery.webURL` instead.",
        renamed: "imagery.webURL")
    public func imagery_webURL(for state: UIControlState) -> URL? { return imagery.webURL(for: state) }
    
    @available(*, deprecated, message: "Extensions directly on UIButton are deprecated.",renamed: "imagery.setWebURL")
    fileprivate func imagery_setWebURL(_ url: URL, for state: UIControlState) { imagery.setWebURL(url, for: state) }
    
    @available(*, deprecated, message: "Extensions directly on UIButton are deprecated.",renamed: "imagery.webURLs")
    fileprivate var imagery_webURLs: NSMutableDictionary { return imagery.webURLs }
    
    @available(*, deprecated, message: "Extensions directly on UIButton are deprecated.",renamed: "imagery.setWebURLs")
    fileprivate func imagery_setWebURLs(_ URLs: NSMutableDictionary) { imagery.setWebURLs(URLs) }
    
    @available(*, deprecated, message: "Extensions directly on UIButton are deprecated.",renamed: "imagery.imageTask")
    fileprivate var imagery_imageTask: ImageryRetrieveImageTask? { return imagery.imageTask }
    
    @available(*, deprecated, message: "Extensions directly on UIButton are deprecated.",renamed: "imagery.setImageTask")
    fileprivate func imagery_setImageTask(_ task: ImageryRetrieveImageTask?) { imagery.setImageTask(task) }
    
    /**
     Get the background image URL binded to this button for a specified state.
     
     - parameter state: The state that uses the specified background image.
     
     - returns: Current URL for background image.
     */
    @available(*, deprecated,
    message: "Extensions directly on UIButton are deprecated. Use `button.imagery.backgroundWebURL` instead.",
    renamed: "imagery.backgroundWebURL")
    public func imagery_backgroundWebURL(for state: UIControlState) -> URL? { return imagery.backgroundWebURL(for: state) }
    
    @available(*, deprecated,
    message: "Extensions directly on UIButton are deprecated.",renamed: "imagery.setBackgroundWebURL")
    fileprivate func imagery_setBackgroundWebURL(_ url: URL, for state: UIControlState) {
        imagery.setBackgroundWebURL(url, for: state)
    }
    
    @available(*, deprecated,
    message: "Extensions directly on UIButton are deprecated.",renamed: "imagery.backgroundWebURLs")
    fileprivate var imagery_backgroundWebURLs: NSMutableDictionary { return imagery.backgroundWebURLs }
    
    @available(*, deprecated,
    message: "Extensions directly on UIButton are deprecated.",renamed: "imagery.setBackgroundWebURLs")
    fileprivate func imagery_setBackgroundWebURLs(_ URLs: NSMutableDictionary) { imagery.setBackgroundWebURLs(URLs) }
    
    @available(*, deprecated,
    message: "Extensions directly on UIButton are deprecated.",renamed: "imagery.backgroundImageTask")
    fileprivate var imagery_backgroundImageTask: ImageryRetrieveImageTask? { return imagery.backgroundImageTask }
    
    @available(*, deprecated,
    message: "Extensions directly on UIButton are deprecated.",renamed: "imagery.setBackgroundImageTask")
    fileprivate func imagery_setBackgroundImageTask(_ task: ImageryRetrieveImageTask?) { return imagery.setBackgroundImageTask(task) }
    
}
