
<p align="center">
  <img src="https://i.loli.net/2017/07/22/5973681f7d8d8.png" alt="Formal">
  <br/><a href="https://cocoapods.org/pods/Formal">
  <img alt="Version" src="https://img.shields.io/badge/version-2.1.1-brightgreen.svg">
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

`Formal` is a `UITableView` form builder.

![Formal](https://i.loli.net/2017/07/23/5974704c2e30f.png)

## Requirements

* iOS 8.0+
* Xcode 8 with Swift 3

## Installation

#### CocoaPods

```ruby
pod 'Formal'
```

## Dependencies

* ~~[SDWebImage](https://github.com/rs/SDWebImage)~~
* [Imagery](https://github.com/Meniny/Imagery)

## Contribution

You are welcome to fork and submit pull requests.

## License

`Formal` is open-sourced software, licensed under the `MIT` license.

## Usage

### Prepare

`Formal` allows you to simply add sections and rows by **extending** `FormalViewController`.

```swift
class ViewController: FormalViewController {
    // ...
}
```

You could create a form by just setting up the `Formal` property by yourself **without extending** from `FormalViewController`.

```swift
class ViewController: UIViewController: FormalDelegate {
    var formal: Formal = Formal()

    override func viewDidLoad() {
        super.viewDidLoad()
        formal.delegate = self
    }

    func sectionsHaveBeenAdded(_ sections: [FormalSection], at: IndexSet) {

    }
    func sectionsHaveBeenRemoved(_ sections: [FormalSection], at: IndexSet) {

    }
    func sectionsHaveBeenReplaced(oldSections: [FormalSection], newSections: [FormalSection], at: IndexSet) {

    }
    func rowsHaveBeenAdded(_ rows: [FormalBaseRow], at: [IndexPath]) {

    }
    func rowsHaveBeenRemoved(_ rows: [FormalBaseRow], at: [IndexPath]) {

    }
    func rowsHaveBeenReplaced(oldRows: [FormalBaseRow], newRows: [FormalBaseRow], at: [IndexPath]) {

    }
    func valueHasBeenChanged(for: FormalBaseRow, oldValue: Any?, newValue: Any?) {

    }
}
```

### Add a Section

```swift
formal +++ FormalSection("Base")
formal +++ FormalSection(header: "Acknowledgement", footer: "https://github.com/Meniny/Formal")
formal +++ FormalSection(header: "Setup", footer: "Footer", { section in
    // ...
})
```

### Add a Row

```swift
formal +++ FormalSection("Base")
    <<< FormalTextRow() {
        $0.textType = .account
        $0.title = "Account"
        $0.placeholder = "Enter account here"
        $0.value = "Meniny"
}
```

### Remove all

```swift
formal.removeAll()
```

### Change Animations

```swift
formal.animationSettings.rowInsertAnimation = .fade
```

#### Text Field Rows

```swift
public enum FormalTextType {
    case normal
    case phone
    case account
    case password
    case name
    case email
    case twitter
    case zipCode
}
```

```swift
formal +++ FormalSection("Base")
    <<< FormalTextRow() {
        $0.textType = .account
        $0.title = "Account"
        $0.placeholder = "Enter account here"
        $0.value = "Meniny"
    }
    <<< FormalTextRow() { row in
        row.textType = .password
        row.title = "Password"
        row.placeholder = "Enter password here"
    }
    <<< FormalTextRow(.email, tag: "Email", { (row) in
        row.title = "Email"
        row.placeholder = "Enter Email here"
    })
    <<< FormalTextRow(.twitter, tag: "Twitter", { (row) in
        row.title = "Twitter"
        row.placeholder = "Twitter Text here"
})
```

#### URL Row

```swift
formal +++ FormalSection("Base")
    <<< FormalURLRow() { row in
        row.title = "URL"
        row.placeholder = "Enther URL here"
}
```

#### Text Area Row

```swift
formal +++ FormalSection("Base")
    <<< FormalTextAreaRow() { row in
        row.placeholder = "TextArea"
}
```

#### Formatted Numbers Row

```swift
formal +++ FormalSection("Base")
    <<< FormalDecimalRow() { row in
        row.title = "Decimal"
        row.placeholder = "Enter decimal here"
}
```

#### Switch Row

```swift
formal +++ FormalSection("Base")
    <<< FormalSwitchRow() { row in
        row.title = "Switch"
        row.tag = "Switch"
}
```

#### Button Row

```swift
formal +++ FormalSection("Base")
    <<< FormalButtonRow() { row in
        row.title = "Button"
}
```

#### Label Row

```swift
formal +++ FormalSection("Base")
    <<< FormalLabelRow() { row in
        row.title = "Label"
}
```

#### Check Rows

```swift
formal +++ FormalSection("Base")
    <<< FormalCheckRow() { row in
        row.title = "Check"
        row.value = true
        }.onChange({ (row) in
            print("\(row.value!)")
        })
    <<< FormalImageCheckRow() { row in
        row.title = "Image Check"
        row.value = true
}
```

#### Floating Text Field/URL/Formatted Numbers Rows

```swift
formal +++ FormalSection("Base")
    <<< FormalTextFloatingFieldRow() { row in
        row.placeholder = "Enter text here"
        row.value = "Floating Text Field"
    }
    <<< FormalURLFloatingFieldRow() { row in
        row.placeholder = "Enter URL here"
        row.value = URL(string: "https://meniny.cn/")
}
```

#### Stepper Row

```swift
formal +++ FormalSection("Base")
    <<< FormalStepperRow() { row in
        row.title = "Stepper"
        row.value = 2
    }
```

#### Location Row

```swift
formal +++ FormalSection("Base")
    <<< FormalLocationRow() { row in
        row.title = "Location"
    }
```

#### Generic Password Row

```swift
formal +++ FormalSection("Base")
    <<< FormalGenericPasswordRow() { row in
        let password = "[ABCdef123]"
        row.placeholder = "Generic Password \(password)"
        row.value = password
    }
```

#### Slider Row

```swift
formal +++ FormalSection("Base")
    <<< FormalSliderRow() { row in
        row.title = "Slider"
}
```

#### Segmented Row

```swift
formal +++ FormalSection("Options")
    <<< FormalSegmentedRow<String>() { row in
        row.title = "Segmented"
        row.options = options
}
```

#### Push Selector Row

```swift
formal +++ FormalSection("Options")
    <<< FormalPushSelectorRow<String>() { row in
        row.title = "Push"
        row.options = options
}
```

#### Popover Selector Row

```swift
formal +++ FormalSection("Options")
    <<< FormalPopoverSelectorRow<String>() { row in
        row.title = "Popover"
        row.options = options
}
```

#### Inline Picker Row

```swift
formal +++ FormalSection("Options")
    <<< FormalPickerInlineRow<String>() { row in
        row.title = "Picker Inline"
        row.options = options
    }
    <<< FormalDateInlineRow() { row in
        row.title = "Date Inline"
    }
    <<< FormalPickerRow<String>() { row in
        var opts = [String]()
        for i in 0...5 {
            opts.append("Picker \(i)")
        }
        row.options = opts
}
```

#### Action Sheet Row

```swift
formal +++ FormalSection("Options")
    <<< FormalActionSheetRow<String>() { row in
        row.title = "ActionSheet"
        row.options = options
}
```

#### Alert Row

```swift
formal +++ FormalSection("Options")
    <<< FormalAlertRow<String>() { row in
        row.title = "Alert"
        row.options = options
}
```

#### Input Picker Row

```swift
formal +++ FormalSection("Options")
    <<< FormalPickerInputRow<String>("Picker Input Row") { row in
        row.title = "PickerInput"
        row.options = []
        for i in 1...10 {
            row.options.append("PickerInput \(i)")
        }
        row.value = row.options.first
    }
    <<< FormalPhotoPickerRow() { row in
        row.title = "Image"
}
```

### Hiding Sections and Rows

Use `FormalCondition` to hide/show sections and rows.

```swift
formal +++ FormalSection("Testing", { (section) in
    section.tag = "TestingSection"
    section.hidden = FormalCondition.closure(tags: ["HidingSwitch"], closure: { (f) -> Bool in
        if let r = f.rowBy(tag: "HidingSwitch") as? FormalSwitchRow {
            return r.value ?? false
        }
        return false
    })
})
    <<< FormalLabelRow() {
        $0.title = "Home"
        $0.value = "https://github.com/Formal"
}
```

```swift
formal +++ FormalSection("Hiding")
    <<< FormalSwitchRow("HidingSwitch") { row in
        row.title = "Hide Testings Section"
        row.value = false
}
```

> See the sample project for more detail.
