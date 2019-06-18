//
//  UITabbarControllerExtension.swift
//  WCEC
//
//  Created by Đinh Ngọc Vũ on 9/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

extension UITabBarController {
    func addRedDotAtTabBarItem(atIndex index: Int) {
        let radius: CGFloat = 4
        let color : UIColor = UIColor.red
        let xOffset: CGFloat = 16
        let yOffset: CGFloat = 0
        let tag = index + 999
        
        let dotDiameter = radius * 2
        
        let dot = UIView(frame: CGRect(x: xOffset, y: yOffset, width: dotDiameter, height: dotDiameter))
        dot.tag = tag
        dot.backgroundColor = color
        dot.layer.cornerRadius = radius
        removeRedDotAtTabBarItem(atIndex: index)
        tabBar.subviews[index + 1].subviews.first?.insertSubview(dot, at: 1)
    }
    
    func removeRedDotAtTabBarItem(atIndex index: Int) {
        let tag = index + 999
        if (index + 1) >= tabBar.subviews.count {
            return
        }
        
        if tabBar.subviews[index + 1].subviews.count == 0 {
            return
        }
        
        if let subviews = tabBar.subviews[index + 1].subviews.first?.subviews {
            for subview in subviews where subview.tag == tag {
                subview.removeFromSuperview()
            }
        }
    }
}
