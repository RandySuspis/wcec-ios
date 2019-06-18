//
//  UIBarButtonItemExtension.swift
//  WCEC
//
//  Created by hnc on 5/8/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    static func customBarItem(image: String, target: AnyObject, btnAction: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: image)?.withRenderingMode(.alwaysOriginal), style: .plain, target: target, action: btnAction)
    }
    
    static func backBarItem(target: AnyObject, btnAction: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "arrowLeftWhite")?.withRenderingMode(.alwaysOriginal), style: .plain, target: target, action: btnAction)
    }
    
    static func closeBarItem(target: AnyObject, btnAction: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "closeWhite")?.withRenderingMode(.alwaysOriginal), style: .plain, target: target, action: btnAction)
    }
    
    class func nextBarButton(target: Any, selector: Selector) -> UIBarButtonItem {
        let barButton = UIBarButtonItem(title: "Next", style: .plain, target: target, action: selector)
        barButton.setTitleTextAttributes([NSAttributedStringKey.font:AppFont.fontWithType(.regular, size: 14)], for: .normal)
        return barButton
    }
    
    class func cancelBarButton(target: Any, selector: Selector) -> UIBarButtonItem {
        let barButton = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: target, action: selector)
        barButton.setTitleTextAttributes([NSAttributedStringKey.font:AppFont.fontWithType(.regular, size: 14)], for: .normal)
        return barButton
    }
    
    class func addBarButton(target: Any, selector: Selector) -> UIBarButtonItem {
        let barButton = UIBarButtonItem(title: "Add".localized(), style: .plain, target: target, action: selector)
        barButton.setTitleTextAttributes([NSAttributedStringKey.font:AppFont.fontWithType(.regular, size: 14)], for: .normal)
        return barButton
    }
    
    class func plusBarButton(target: Any, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "activeWhite")?.withRenderingMode(.alwaysOriginal), style: .plain, target: target, action: selector)
    }
    
    class func searchBarButton(target: Any, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: target, action: selector)
    }
    
    class func postBarButton(target: Any, selector: Selector) -> UIBarButtonItem {
        let barButton = UIBarButtonItem(title: "Post".localized(), style: .plain, target: target, action: selector)
        barButton.setTitleTextAttributes([NSAttributedStringKey.font:AppFont.fontWithType(.regular, size: 14)], for: .normal)
        return barButton
    }
    
    class func doneBarButton(target: Any, selector: Selector) -> UIBarButtonItem {
        let barButton = UIBarButtonItem(title: "Done".localized(), style: .plain, target: target, action: selector)
        barButton.setTitleTextAttributes([NSAttributedStringKey.font:AppFont.fontWithType(.regular, size: 14)], for: .normal)
        return barButton
    }
}
