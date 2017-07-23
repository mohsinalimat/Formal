//
//  PasswordValidatorEngine.swift
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

public struct FormalPasswordRule {
    let hint: String
    let test: (String) -> Bool
}

open class FormalDefaultPasswordValidator: FormalPasswordValidator {

    open let maxStrength = 4.0

    let rules: [FormalPasswordRule] = [
        FormalPasswordRule(hint: "Please enter a lowercase letter") { $0.satisfiesRegexp("[a-z]") },
        FormalPasswordRule(hint: "Please enter a number") { $0.satisfiesRegexp("[0-9]") },
        FormalPasswordRule(hint: "Please enter an uppercase letter") { $0.satisfiesRegexp("[A-Z]") },
        FormalPasswordRule(hint: "At least 6 characters") { $0.characters.count > 5 }
    ]

    open func strengthForPassword(_ password: String) -> Double {
        return rules.reduce(0) { $0 + ($1.test(password) ? 1 : 0) }
    }

    open func hintForPassword(_ password: String) -> String? {
        return rules.reduce([]) { $0 + ($1.test(password) ? []: [$1.hint]) }.first
    }

    open func isPasswordValid(_ password: String) -> Bool {
        return rules.reduce(true) { $0 && $1.test(password) }
    }

    open func colorsForStrengths() -> [Double: UIColor] {
        return [
            0: UIColor(red: 244 / 255, green: 67 / 255, blue: 54 / 255, alpha: 1),
            1: UIColor(red: 255 / 255, green: 193 / 255, blue: 7 / 255, alpha: 1),
            2: UIColor(red: 3 / 255, green: 169 / 255, blue: 244 / 255, alpha: 1),
            3: UIColor(red: 139 / 255, green: 195 / 255, blue: 74 / 255, alpha: 1)
        ]
    }

}

internal extension String {

    func satisfiesRegexp(_ regexp: String) -> Bool {
        return range(of: regexp, options: .regularExpression) != nil
    }

}
