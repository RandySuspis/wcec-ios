//
//  BaseViewController.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Localize_Swift
import AVKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(backAction))
        self.hideKeyboardWhenTappedAround()
        setupLocalized()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.backBarItem(target: self, btnAction: #selector(backAction))
        self.navigationController?.navigationBar.setGradientBackground(colors: [AppColor.colorFadedRed().cgColor, AppColor.colorlightBurgundy().cgColor, AppColor.colorpurpleBrown().cgColor])
        self.view.backgroundColor = AppColor.colorFadedWhiteBg()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIApplication.shared.statusBarStyle = .default
        setupLocalized()
        NotificationCenter.default.addObserver(self, selector: #selector(setupLocalized), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupView() {
    }
    
    @objc func setupLocalized() {
        //need override
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissAction() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    class func initWithDefautlNib() -> Self {
        
        let bundle = Bundle.main
        let fileManege = FileManager.default
        let nibName = String(describing: self)
        if let pathXib = bundle.path(forResource: nibName, ofType: "nib") {
            
            if fileManege.fileExists(atPath: pathXib) {
                
                return initWithNibTemplate()
            }
        }
        
        if let pathStoryboard = bundle.path(forResource: nibName, ofType: "storyboard") {
            
            if fileManege.fileExists(atPath: pathStoryboard) {
                
                return initWithDefautlStoryboard()
            }
        }
        
        return initWithNibTemplate()
    }
    
    private class func initWithDefautlStoryboard() -> Self {
        let className = String(describing: self)
        let storyboardId = className
        return instantiateFromStoryboardHelper(storyboardName: className, storyboardId: storyboardId)
    }
    
    private class func instantiateFromStoryboardHelper<T>(storyboardName: String,
                                                          storyboardId: String) -> T {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: storyboardId) as! T
        return controller
    }
    
    func shareWithLink(_ link: String) {
        if let url = URL(string: link) {
            let controller = UIActivityViewController(activityItems: [url],
                                                      applicationActivities: nil)
            if let wPPC = controller.popoverPresentationController {
                wPPC.sourceView = self.view
            }
            self.present(controller, animated: true, completion: nil)
        } else {
            alertDefault()
        }
    }
    
    func setupBorderAndShadow(layer: CALayer, radius: CGFloat = 5){
        layer.cornerRadius = radius
        layer.masksToBounds = false
        layer.shadowColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 0
    }
    
//    func playVideo(_ link: String) {
//        guard let videoUrl = URL(string: link) else { return }
//        let player = AVPlayer(url: videoUrl)
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        self.modalTransitionStyle = .crossDissolve
//        playerViewController.modalPresentationStyle = .overCurrentContext
//        Constants.appDelegate.tabbarController.present(playerViewController, animated: true) {
//            playerViewController.player?.play()
//        }
//    }
}
