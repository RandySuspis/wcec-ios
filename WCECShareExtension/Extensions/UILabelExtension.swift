//
//  UILabelExtension.swift
//  WCEC
//
//  Created by GEM on 6/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    var numberOfVisibleLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let lines = Int(textSize.height/charSize)
        return lines
    }
    
    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedStringKey.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedStringKey : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: (self.text! as NSString).length - index - 1)).location
                }
            } while index != NSNotFound && index < (self.text! as NSString).length && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedStringKey : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return (self.text! as NSString).length
    }
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        
        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: NSString = self.text! as NSString
        let trimmedString: String? = mutableString.replacingCharacters(in: NSRange(location: lengthForVisibleString, length: (mutableString.length - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        var trimmedForReadMore: String = ""
        if (trimmedString! as NSString).length <= lengthForVisibleString {
            trimmedForReadMore = trimmedString! + trailingText
        } else {
            trimmedForReadMore = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: (((trimmedString! as NSString).length ) - readMoreLength), length: readMoreLength), with: "") + trailingText
        }
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedStringKey.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedStringKey.font: moreTextFont, NSAttributedStringKey.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }
}












