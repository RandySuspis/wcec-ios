//
//  UITextViewExtension.swift
//  WCEC
//
//  Created by hnc on 5/9/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

extension UITextView {
    func setLeftPaddingPoints(_ amount:CGFloat){
        self.textContainerInset = UIEdgeInsetsMake(amount, amount, amount, amount)
    }
    
}
