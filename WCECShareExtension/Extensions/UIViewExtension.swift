//
//  UIViewExtension.swift
//  WCEC
//
//  Created by hnc on 6/6/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setGradientColor(colors: [CGColor]) {
        
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
        
        self.layer.contents = image.cgImage
    }
}
