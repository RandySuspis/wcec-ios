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
        let okAction = UIAlertAction(title:"OK".localized(), style: .cancel, handler: nil)
        alertController.addAction(okAction)
        presentAlertVC(alertController)
    }
    
    func alertWithTitle(_ title: String?, message: String?, completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized(), style: .default, handler: { (action) in
            completion()
        })
        alertController.addAction(okAction)
        presentAlertVC(alertController)
    }
    
    func alertConfirmWithTitle(_ title: String?, message: String?,completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized(), style: .default, handler: { (action) in
            completion()
        })
        let cancelAction = UIAlertAction(title: "OK".localized(), style: .destructive, handler: nil)
        alertController.addAction(okAction)
        
        presentAlertVC(alertController)
    }
    
    func alertButtonWithTitle(_ title: String?, message: String?,completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .destructive, handler: { (action) in
            completion()
        })
        let cancelAction = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
       presentAlertVC(alertController)
    }
    
    func alertYesNoWithTitle(_ title: String?, message: String?,completion: @escaping (Bool) -> ()) {
        let alertController = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes".localized(), style: .destructive, handler: { (action) in
            completion(true)
        })
        let cancelAction = UIAlertAction(title: "No".localized(), style: .cancel, handler: { (action) in
            completion(false)
        })
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        presentAlertVC(alertController)
    }
    
    func alertConfirmCancelWithTitle(_ title: String?, message: String?,completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized(), style: .default, handler: { (action) in
            completion()
        })
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        presentAlertVC(alertController)
    }
    
    func alertView(_ title: String?, message: String?) {
        let alertView = UIAlertView(title: title,
                                    message: message,
                                    delegate: nil,
                                    cancelButtonTitle: "OK".localized())
        alertView.show()
    }
    
    func showHud() {
        MBProgressHUD.hide(for: view, animated: true)
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    func hideHude() {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func call(_ phoneNumber: String) {
        let url = URL(string:"tel://\(phoneNumber)")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.openURL(url!)
        } else {
            toast("This Device Not Support Call")
        }
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
    
    func showAlertGoToPhotoSetting() {
        let alertController = UIAlertController(title: "Start Sending Photos".localized(),
                                                message: "In iPhone settings, tap WCEC and turn on Photos".localized(), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Open Settings".localized(),
                                     style: .destructive,
                                     handler: { (action) in
                                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                                            return
                                        }
                                        
                                        if UIApplication.shared.canOpenURL(settingsUrl) {
                                            if #available(iOS 10.0, *) {
                                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                                })
                                            } else {
                                            }
                                        }
        })
        let cancelAction = UIAlertAction(title: "Cancel".localized(),
                                         style: .cancel,
                                         handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        presentAlertVC(alertController)
    }
}
