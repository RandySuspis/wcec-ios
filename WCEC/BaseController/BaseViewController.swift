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
import Photos
import PhotosUI

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"),
//                                                                style: .plain,
//                                                                target: self,
//                                                                action: #selector(backAction))
        self.hideKeyboardWhenTappedAround()
        setupLocalized()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.backBarItem(target: self, btnAction: #selector(backAction))
        self.navigationController?.navigationBar.setGradientBackground(colors: [AppColor.colorFadedRed().cgColor, AppColor.colorlightBurgundy().cgColor, AppColor.colorpurpleBrown().cgColor])
        self.view.backgroundColor = AppColor.colorFadedWhiteBg()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        setupLocalized()
        NotificationCenter.default.addObserver(self, selector: #selector(setupLocalized), name: NSNotification.Name( LCLLanguageChangeNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
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
        
        if let pathStoryboard = bundle.path(forResource: nibName, ofType: "storyboardc") {
            
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
    
    func shareNewfeed(_ link: String, postID: String) {
        if let url = URL(string: link) {
            let controller = UIActivityViewController(activityItems: [url],
                                                      applicationActivities: nil)
            if let wPPC = controller.popoverPresentationController {
                wPPC.sourceView = self.view
            }
            controller.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed {
                    let newfeedService = NewsfeedService()
                    newfeedService.sharePostVia(postId: postID,
                                                     complete: { (_) in
                    })
                }
            }
            self.present(controller, animated: true, completion: nil)
        } else {
            alertDefault()
        }
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
    
    func reloadCurrentUser() {
        guard let currentUser = DataManager.getCurrentUserModel() else { return }
        if !DataManager.checkIsGuestUser() {
            let userService = UserService()
            let chatService = ChatService()
            userService.doGetUserInfo(userId: String(currentUser.id)) { (result) in
                switch result {
                case .success(let response):
                    DataManager.saveUserModel(response.data)
                    if response.data.current_locale == .english {
                        Localize.setCurrentLanguage("en")
                    } else {
                        Localize.setCurrentLanguage("zh-Hans")
                    }
                    chatService.getListChannelId { (result) in
                        self.hideHude()
                        switch result {
                        case .success(let responseChannel):
                            if response.data.push_notification {
                                self.registerDeviceTokenWithPubnub(responseChannel.data)
                            } else {
                                self.unRegisterDeviceTokenWithPubnub(responseChannel.data)
                            }
                            break
                        case .failure( let error):
                            #if DEBUG
                                DLog("ChannelIDs: \(error)")
                            #endif
                        }
                    }
                    break
                case .failure(_):
                    break
                }
            }
        }
    }
    
    func playVideo(_ link: String, _ isPresentFromTabBar: Bool) {
        guard let videoUrl = URL(string: link) else { return }
        let player = AVPlayer(url: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.modalTransitionStyle = .crossDissolve
        playerViewController.modalPresentationStyle = .overCurrentContext
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(playerViewController, animated: true, completion: {
                playerViewController.player?.play()
            })
        }
    }
    
    func playVideo(_ asset: PHAsset) {
        guard (asset.mediaType == PHAssetMediaType.video)
            else {
                print("Not a valid video media type")
                return
        }
        
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { (asset, audioMix, args) in
            let asset = asset as! AVURLAsset
            
            DispatchQueue.main.async {
                let player = AVPlayer(url: asset.url)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.modalTransitionStyle = .crossDissolve
                playerViewController.modalPresentationStyle = .overCurrentContext
                self.present(playerViewController, animated: true, completion: {
                    playerViewController.player?.play()
                })
            }
        }
    }

    func openPhotoViewer(_ listImage: [Any]) {
        let vc = PhotoViewerViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.listPhoto = listImage
        self.presentVC(vc: vc)
    }
    
    func pushViewControllerWithPresentAnimation(_ vc: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func dissmissPushViewControllerWithPresentAnimation() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromBottom
        navigationController?.view.layer.add(transition, forKey:kCATransition)
        let _ = navigationController?.popViewController(animated: false)
    }
    
    func presentVC(vc: UIViewController) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    func createNewMessage(_ invitedIds: [String]) {
        let chatService = ChatService()
        self.showHud()
        chatService.createChatChannel(name: "New Conversation".localized(), invitations: invitedIds) { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                let chatVC = ChatViewController()
                chatVC.channelModel = response.data
                chatVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(chatVC, animated: true)
                break
            case .failure( let error):
                self.alertWithError(error)
                break
            }
        }
    }
    
    func registerDeviceTokenWithPubnub(_ arrId: [String]) {
        Util.registerPubNubNotification(channelIds: arrId, deviceTokenData: DataManager.deviceTokenData())
    }
    
    func unRegisterDeviceTokenWithPubnub(_ arrId: [String]) {
        Util.removePubNubNotification(channelIds: arrId, deviceTokenData: DataManager.deviceTokenData())
    }
    
    func isModal() -> Bool {
        if self.presentingViewController != nil {
            return true
        } else if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        } else if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
}
