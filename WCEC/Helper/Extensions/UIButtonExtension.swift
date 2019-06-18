//
//  UIButtonExtension.swift
//  WCEC
//
//  Created by hnc on 5/8/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

extension UIButton {
    func enabled() {
        self.isEnabled = true
        self.alpha = 1
    }
    
    func disabled() {
        self.isEnabled = false
        self.alpha = 0.5
    }
    
    func underLineText(_ text: String, font: UIFont, color: UIColor) {
        let attributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : font,
            NSAttributedStringKey.foregroundColor : color,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: text,
                                                        attributes: attributes)
        self.setAttributedTitle(attributeString, for: .normal)
    }
}
