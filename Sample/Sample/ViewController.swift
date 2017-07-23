//
//  ViewController.swift
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
import Formal

class ViewController: FormalViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.showsVerticalScrollIndicator = false
        
        let options = ["Option1", "Option2", "Option3"]
        
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
            <<< FormalURLRow() { row in
                row.title = "URL"
                row.placeholder = "Enther URL here"
            }
            <<< FormalTextAreaRow() { row in
                row.placeholder = "TextArea"
            }
            <<< FormalDecimalRow() { row in
                row.title = "Decimal"
                row.placeholder = "Enter decimal here"
            }
            <<< FormalSwitchRow() { row in
                row.title = "Switch"
                row.tag = "Switch"
            }
            <<< FormalButtonRow() { row in
                row.title = "Button"
            }
            <<< FormalLabelRow() { row in
                row.title = "Label"
            }
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
            <<< FormalTextFloatingFieldRow() { row in
                row.placeholder = "Enter text here"
                row.value = "Floating Text Field"
            }
            <<< FormalURLFloatingFieldRow() { row in
                row.placeholder = "Enter URL here"
                row.value = URL(string: "https://meniny.cn/")
            }
            <<< FormalStepperRow() { row in
                row.title = "Stepper"
                row.value = 2
            }
            <<< FormalLocationRow() { row in
                row.title = "Location"
            }
            <<< FormalGenericPasswordRow() { row in
                let password = "[ABCdef123]"
                row.placeholder = "Generic Password \(password)"
                row.value = password
            }
            <<< FormalSliderRow() { row in
                row.title = "Slider"
        }
        
        formal +++ FormalSection("Options", { (section) in
            section.tag = "OptionsSection"
            section.hidden = FormalCondition.closure(tags: ["HidingSwitch"], closure: { (f) -> Bool in
                if let r = f.rowBy(tag: "HidingSwitch") as? FormalSwitchRow {
                    return r.value ?? false
                }
                return false
            })
        })
            <<< FormalListCheckRow<String>() { row in
                row.title = "List Check"
            }
            <<< FormalSegmentedRow<String>() { row in
                row.title = "Segmented"
                row.options = options
            }
            <<< FormalPushSelectorRow<String>() { row in
                row.title = "Push"
                row.options = options
            }
            <<< FormalPopoverSelectorRow<String>() { row in
                row.title = "Popover"
                row.options = options
            }
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
            <<< FormalActionSheetRow<String>() { row in
                row.title = "ActionSheet"
                row.options = options
            }
            <<< FormalAlertRow<String>() { row in
                row.title = "Alert"
                row.options = options
            }
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
        
        formal +++ FormalSection("Hiding")
            <<< FormalSwitchRow("HidingSwitch") { row in
                row.title = "Hide Options Section"
                row.value = false
                }.onChange({ (row) in
                    
                })
        
        formal +++ FormalSection(header: "Acknowledgement", footer: "https://github.com/Meniny/Formal")
            <<< FormalLabelRow() {
                $0.title = "Home"
                $0.value = "https://github.com/Formal"
        }
            
        
    }
}

