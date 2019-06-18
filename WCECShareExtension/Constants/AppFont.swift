//
//  AppFont.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit

enum SourceSansProTextFontStyle: String {
    case bold
    case boldItalic
    case extraBold
    case extraBoldItalic
    case italic
    case light
    case lightItalic
    case regular
    case semiBold
    case semiBoldItalic
    
    func fontName() -> String {
        switch self {
        case .bold:
            return "OpenSans-Bold"
        case .boldItalic:
            return "OpenSans-BoldItalic"
        case .extraBold:
            return "OpenSans-ExtraBold"
        case .extraBoldItalic:
            return "OpenSans-ExtraBoldItalic"
        case .italic:
            return "OpenSans-Italic"
        case .light:
            return "OpenSans-Light"
        case .lightItalic:
            return "OpenSans-LightItalic"
        case .regular:
            return "OpenSans"
        case .semiBold:
            return "OpenSans-Semibold"
        case .semiBoldItalic:
            return "OpenSans-SemiboldItalic"
        }
    }
}

class AppFont: UIFont {
    class func fontWithType(_ type: SourceSansProTextFontStyle, size: CGFloat) -> UIFont {
        if let font = UIFont(name: type.fontName(), size: size) {
            return font
        } else {
            return UIFont.systemFont(ofSize: size)
        }
    }
}
