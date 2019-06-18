//
//  UITableViewExtension.swift
//  WCEC
//
//  Created by GEM on 6/22/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

extension UITableView {
    func reloadDataWithoutScroll(){
        let contentOffset = self.contentOffset
        self.reloadData()
        self.layoutIfNeeded()
        self.setContentOffset(contentOffset, animated: false)
    }
    
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.numberOfRows(inSection:  (self.numberOfSections - 1)) - 1,section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func scrollToTop(animated: Bool) {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
}
