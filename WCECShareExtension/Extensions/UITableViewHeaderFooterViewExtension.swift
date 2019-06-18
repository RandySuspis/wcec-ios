//
//  UITableViewHeaderFooterViewExtension.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//


import Foundation
import UIKit

extension UITableViewHeaderFooterView {
    class func dequeueReuseHeaderWithClass(in tableView: UITableView,
                                           reuseIdentifier text: String) -> Self {
        return dequeueReuseHeaderWithClassTemplate(in: tableView,
                                                   reuseIdentifier: text)
    }
    
    private class func dequeueReuseHeaderWithClassTemplate<T>(in tableView: UITableView,
                                                              reuseIdentifier text: String) -> T {
        var cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: text)
        if cell == nil {
            cell = self.init(reuseIdentifier: text)
        }
        return cell as! T
    }
    
    class func dequeueReuseHeaderWithNib(in tableView: UITableView,
                                         reuseIdentifier text: String,
                                         nibName nibNameOrNil: String? = nil) -> Self {
        return dequeueReuseHeaderWithNibTemplate(in: tableView,
                                                 reuseIdentifier: text,
                                                 nibName: nibNameOrNil)
    }
    
    private class func dequeueReuseHeaderWithNibTemplate<T>(in tableView: UITableView,
                                                            reuseIdentifier text: String,
                                                            nibName nibNameOrNil: String?) -> T {
        var cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: text)
        if cell == nil {
            var cellNibName: String! = nibNameOrNil
            if cellNibName == nil {
                cellNibName = nibName()
            }
            let nib = UINib(nibName: cellNibName, bundle: nil)
            tableView.register(nib, forHeaderFooterViewReuseIdentifier: text)
            cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: text)
        }
        return cell as! T
    }
    
    class func nibName() -> String {
        var nibName = String(describing: self)
        if Constants.isIpad {
            if let pathXib = Bundle.main.path(forResource: "\(nibName)_\(Constants.iPad)", ofType: "nib") {
                if FileManager.default.fileExists(atPath: pathXib) {
                    nibName = "\(nibName)_\(Constants.iPad)"
                }
            }
        }
        return nibName
    }
}

