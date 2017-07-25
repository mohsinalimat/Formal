
<p align="center">
  <img src="https://i.loli.net/2017/07/25/597765d9704f0.png" alt="Imagery">
  <br/><a href="https://cocoapods.org/pods/Imagery">
  <img alt="Version" src="https://img.shields.io/badge/version-1.1.0-brightgreen.svg">
  <img alt="Author" src="https://img.shields.io/badge/author-Meniny-blue.svg">
  <img alt="Build Passing" src="https://img.shields.io/badge/build-passing-brightgreen.svg">
  <img alt="Swift" src="https://img.shields.io/badge/swift-3.0%2B-orange.svg">
  <br/>
  <img alt="Platforms" src="https://img.shields.io/badge/platform-iOS-lightgrey.svg">
  <img alt="MIT" src="https://img.shields.io/badge/license-MIT-blue.svg">
  <br/>
  <img alt="Cocoapods" src="https://img.shields.io/badge/cocoapods-compatible-brightgreen.svg">
  <img alt="Carthage" src="https://img.shields.io/badge/carthage-working%20on-red.svg">
  <img alt="SPM" src="https://img.shields.io/badge/swift%20package%20manager-working%20on-red.svg">
  </a>
</p>

## What's this?

`Imagery` is a lightweight library for downloading and cacheing image from the web.

## Requirements

* iOS 8.0+
* macOS 10.10+
* tvOS 9.0+
* watchOS 2.0+
* Xcode 8 with Swift 3

## Installation

#### CocoaPods

```ruby
use_frameworks!
pod 'Imagery'
```

## Contribution

You are welcome to fork and submit pull requests.

## License

`Imagery` is open-sourced software, licensed under the `MIT` license.

## Samples

#### Basic Usage

> Use iOS for example

```swift
import Foundation
import UIKit
import Imagery

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        button.tintColor = .clear

        if let url = URL(string: "https://i.loli.net/2017/07/25/597765d9704f0.png") {

            let placeholder = UIImage(named: "placeholder")
            // let placeholder = #imageLiteral(resourceName: "placeholder")

            button.imagery.setBackgroundImage(with: url, for: .normal, placeholder: nil)
            //button.imagery.setImage(with: url, for: .normal)

            imageView.imagery.setImage(with: url,
                                       placeholder: placeholder,
                                       options: nil,
                                       progressBlock: nil,
                                       completionHandler: nil)
            //imageView.imagery.setImage(with: url, placeholder: placeholder)
        }
    }
}
```

#### Clean Caches

```swift
// MARK: Class Methods
ImageryCache.clearMemoryCache()
ImageryCache.clearDiskCache()
ImageryCache.cleanExpiredDiskCache()
ImageryCache.clearDiskCache {
    // code
}
ImageryCache.cleanExpiredDiskCache {
    // code
}

// MARK: Instance Methods
ImageryCache.default.clearMemoryCache()
ImageryCache.default.clearDiskCache()
ImageryCache.default.cleanExpiredDiskCache()
ImageryCache.default.clearDiskCache {
    // code
}
ImageryCache.default.cleanExpiredDiskCache {
    // code
}
```
