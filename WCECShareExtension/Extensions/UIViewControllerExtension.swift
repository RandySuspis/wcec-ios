//
//  UIViewControllerExtension.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import Toast

extension UIViewController {
    class func initWithNibTemplate<T>() -> T {
        var nibName = String(describing: self)
        if Constants.isIpad {
            if let pathXib = Bundle.main.path(forResource: "\(nibName)_\(Constants.iPad)", ofType: "nib") {
                if FileManager.default.fileExists(atPath: pathXib) {
                    nibName = "\(nibName)_\(Constants.iPad)"
                }
            }
        }
        let viewcontroller = self.init(nibName: nibName, bundle: Bundle.main)
        return viewcontroller as! T
    }
    
    func alertWithError(_ error: Error) {
        guard let errorDiction = error._userInfo as? NSDictionary else {
            alertDefault()
            return
        }

        guard errorDiction["message"] != nil &&
              errorDiction["message"] as! String != "" else {
            alertDefault()
            return
        }
        
        alertWithTitle("Alert".localized(), message: error._userInfo!["message"] as? String)
    }
    
    func alertDefault() {
        alertWithTitle("Alert".localized(), message: "Something went wrong, please try again later".localized())
    }
    
    func alertWithTitle(_ title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title:"OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertWithTitle(_ title: String?, message: String?, completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completion()
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertConfirmWithTitle(_ title: String?, message: String?,completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completion()
        })
        let cancelAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func alertButtonWithTitle(_ title: String?, message: String?,completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            completion()
        })
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func alertConfirmCancelWithTitle(_ title: String?, message: String?,completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completion()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showHud() {
        MBProgressHUD.hide(for: view, animated: true)
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    func hideHude() {
        MBProgressHUD.hide(for: view, animated: true)
    }

    
    func toast(_ message: String) {
        if !message.isEmpty {
            view.makeToast(message,
                           duration: TimeInterval(Constants.kToastDuration),
                           position: CSToastPositionTop)
        }
    }
    
    func toastBottom(_ message: String) {
        if !message.isEmpty {
            view.makeToast(message,
                           duration: TimeInterval(Constants.kToastDuration),
                           position: CSToastPositionBottom)
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer =
            UITapGestureRecognizer(target: self,
                                   action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
