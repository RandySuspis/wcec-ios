//
//  UINavigationBarExtension.swift
//  WCEC
//
//  Created by hnc on 5/7/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func setGradientBackground(colors: [CGColor]) {
        
        var updatedFrame = bounds
        
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == 2436{
                updatedFrame.size.height += 44
            } else {
                updatedFrame.size.height += 20
            }
        }
        
        let gradient = CAGradientLayer()
        gradient.colors = colors
        gradient.frame = updatedFrame
        
        let image = UIImage.imageWithLayer(layer: gradient)
        
        setBackgroundImage(image, for: UIBarMetrics.default)
    }
}
