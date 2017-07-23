//
//  FormalPasswordStrengthView.swift
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

open class DefaultPasswordStrengthView: FormalPasswordStrengthView {

    public typealias StrengthView = (view: UIView, p: CGFloat, color: UIColor)
    open var strengthViews: [StrengthView]!
    open var validator: FormalPasswordValidator!

    open var progressView: UIView!
    open var progress: CGFloat = 0

    open var borderColor = UIColor.lightGray.withAlphaComponent(0.2)
    open var borderWidth = CGFloat(1)
    open var cornerRadius = CGFloat(3)
    open var animationTime = TimeInterval(0.3)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override open func setPasswordValidator(_ validator: FormalPasswordValidator) {
        self.validator = validator
        let colorsForStrenghts = validator.colorsForStrengths().sorted { $0.0 < $1.0 }
        strengthViews = colorsForStrenghts.enumerated().map { index, element in
            let view = UIView()
            view.layer.borderColor = borderColor.cgColor
            view.layer.borderWidth = borderWidth
            view.backgroundColor = backgroundColorForStrenghColor(element.1)
            let r = index < colorsForStrenghts.count - 1 ? colorsForStrenghts[index+1].0 : validator.maxStrength
            return (view: view, p: CGFloat(r / validator.maxStrength), color: element.1)
        }
        strengthViews.reversed().forEach { addSubview($0.view) }
        bringSubview(toFront: progressView)
    }

    open func backgroundColorForStrenghColor(_ color: UIColor) -> UIColor {
        var h = CGFloat(0), s = CGFloat(0), b = CGFloat(0), alpha = CGFloat(0)
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &alpha)
        return UIColor(hue: h, saturation: 0.06, brightness: 1, alpha: alpha)
    }

    open func setup() {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        progressView = UIView()
        progressView.layer.borderColor = borderColor.cgColor
        progressView.layer.borderWidth = borderWidth
        addSubview(progressView)
        progress = 0
    }

    override open func updateStrength(password: String, animated: Bool = true) {
        let strength = validator.strengthForPassword(password)
        progress = CGFloat(strength / validator.maxStrength)
        updateView(animated: animated)
    }

    open func colorForProgress() -> UIColor {
        for strengthView in strengthViews {
            if progress <= strengthView.p {
                return strengthView.color
            }
        }
        return strengthViews.last?.color ?? .clear
    }

    open func updateView(animated: Bool) {
        setNeedsLayout()
        if animated {
            UIView.animate(withDuration: animationTime, animations: { [weak self] in
                self?.layoutIfNeeded()
            }, completion: { [weak self] _ in
                UIView.animate(withDuration: self?.animationTime ?? 0.3, animations: { [weak self] in
                    self?.progressView?.backgroundColor = self?.colorForProgress()
                }) 
            })
        } else {
            layoutIfNeeded()
            self.progressView?.backgroundColor = self.colorForProgress()
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        var size = frame.size
        size.width = size.width * progress
        progressView.frame = CGRect(origin: CGPoint.zero, size: size)

        strengthViews.forEach { view, p, _ in
            var size = frame.size
            size.width = size.width * p
            view.frame = CGRect(origin: CGPoint.zero, size: size)
        }
    }

}
