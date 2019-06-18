//
//  AppDelegate.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import UserNotifications
import AudioToolbox
import Localize_Swift
import FBSDKLoginKit
import TwitterKit
import LineSDK
import PubNub
import Fabric
import Crashlytics

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, PNObjectEventListener, UITabBarControllerDelegate {

    var window: UIWindow?
    private var launchFromNotification = false
    var tabbarController = RootTabBarController()
    var client : PubNub!
    let userService = UserService()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])

        registerForRemoteNotifications()
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            // Do what you want to happen when a remote notification is tapped.
            launchFromNotification = true
        }
        
        // Twitter
        TWTRTwitter.sharedInstance().start(withConsumerKey:"uAPEPvN3K89BX4g9ei8RvvG0R", consumerSecret:"kVyPw7LJsndqXBMMKfylbLIPCZW0PyQnGUN0EM9bvt4LtrkOzF")
        
        // Wechat
       // WXApi.registerApp("wx235325325")
        
        if DataManager.getUserToken().isEmpty {
            setupAuthentication()
        } else {
            if (DataManager.getCurrentUserModel()?.firstTimeLogin)! {
                userService.doLogOut { (result) in
                    switch result {
                    case .success(_):
                        break
                    case .failure(_):
                        break
                    }
                    self.setupAuthentication()
                }
            } else {
                if DataManager.checkIsGuestUser() {
                    self.setupRootViewController()
                } else {
                    if let user = DataManager.getCurrentUserModel() {
                        switch user.verifiedStatus {
                        case .unverify:
                            setupAuthentication()
                            break
                        case .otpVerified:
                            setupAuthentication()
                            break
                        case .setPasswordCompleted:
                            setupIntro()
                            break
                        case .profileCompleted:
                            setupRootViewController()
                            break
                        }
                    } else {
                        setupAuthentication()
                    }
                }
            }
        }
        return true
    }
    
    //MARK: - INITIAL PUBNUB
    func configPubNub() {
        if DataManager.getCurrentUserModel()?.pubNubAuthKey == "" {
            return
        }
        
        let pubNub_publish_key = Bundle.main.object(forInfoDictionaryKey: "PUBNUB_PUBLISH_KEY") as! String
        let pubNub_subscribe_key = Bundle.main.object(forInfoDictionaryKey: "PUBNUB_SUBSCRIBE_KEY") as! String
        
        let config = PNConfiguration(publishKey: pubNub_publish_key, subscribeKey: pubNub_subscribe_key)
        config.authKey = DataManager.getCurrentUserModel()?.pubNubAuthKey
        self.client = PubNub.clientWithConfiguration(config)
    }
    
    //MARK: - SCREEN TRANSITION
    func setupAuthentication() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        DataManager.clearLoginSession()
        let authenticationVC = SignInViewController()
        let nav = BaseNavigationController(rootViewController: authenticationVC)
        authenticationVC.navigationController?.setNavigationBarHidden(true, animated: false)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
    
    func setupIntro() {
        let setupIntroVC = SetupIntroViewController()
        let nav = BaseNavigationController(rootViewController: setupIntroVC)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
    
    func setupVerifyOTP() {
        let vc = SetMobileViewController()
        let nav = BaseNavigationController(rootViewController: vc)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
    
    func setupPassword() {
        let vc = SetPasswordViewController()
        let nav = BaseNavigationController(rootViewController: vc)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
    
    func setupBeAMemberForm() {
        if DataManager.getCurrentUserModel()?.status == .guest {
            DataManager.clearLoginSession()
        }
        
        let setupIntroVC = RegistrationViewController()
        let nav = BaseNavigationController(rootViewController: setupIntroVC)
        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()
    }
    
    func setupRootViewController() {
        countNotificationBadge()
        configPubNub()
        let baseVC = BaseViewController()
        baseVC.reloadCurrentUser()
        tabbarController.selectedIndex = 2
        self.window?.rootViewController = tabbarController
        self.window?.makeKeyAndVisible()
    }
    
    func restartRootView() {
        let baseVC = BaseViewController()
        baseVC.reloadCurrentUser()
        tabbarController = RootTabBarController()
        tabbarController.selectedIndex = 2
        self.window?.rootViewController = tabbarController
        self.window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        AppEvents.activateApp()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        guard let _ = DataManager.getCurrentUserModel() else { return }
        guard let topVc = UIApplication.topViewController() as? ChatViewController else { return }
        print("channelID did enter background: " + topVc.channelId)
        Util.registerPubNubNotification(channelIds: [topVc.channelId], deviceTokenData: DataManager.deviceTokenData())
        
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        guard let _ = DataManager.getCurrentUserModel() else { return }
        countNotificationBadge()
        
        guard let topVc = UIApplication.topViewController() as? ChatViewController else { return }
        print("channelID did enter foreground: " + topVc.channelId)
        Util.removePubNubNotification(channelIds: [topVc.channelId], deviceTokenData: DataManager.deviceTokenData())
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - REGISTER NOTIFICATION
    
    func registerForRemoteNotifications() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (_, _) in
                // Enable or disable features based on authorization.
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        } else {
            // Fallback on earlier versions
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: - REGISTER DEVICE TOKEN NOTIFICATION
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X",    $1)})
        // kDeviceToken=tokenString
        DataManager.save(object: tokenString, forKey: Constants.kDeviceTokenKey)
        
        // kDeviceTokenData=tokenData
        DataManager.save(object: deviceToken, forKey: Constants.kDeviceTokenData)
        DLog("deviceToken: \(tokenString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DLog("Failed to get device token error \(error.localizedDescription)")
    }
    
    // MARK: - SHOW REMOTE NOTIFICATION
    
    func showRemoteNotificationDetails(_ userInfo: [AnyHashable : Any]) {
        guard !DataManager.getUserToken().isEmpty else {
            return
        }
        
        let model = RemoteNotificationModel(userInfo)
        
        switch model.notificationType {
        case .connection:
            guard let topVc = UIApplication.topViewController() as? ProfileDetailViewController else {
                let vc = ProfileDetailViewController()
                vc.userId = String(model.id)
                deeplinkPushViewContrller(vc)
                return
            }
            if topVc.userId == String(model.id) {
                NotificationCenter.default.post(name: .kRefreshMyProfile,
                                                object: nil,
                                                userInfo: nil)
            } else {
                let vc = ProfileDetailViewController()
                vc.userId = String(model.id)
                deeplinkPushViewContrller(vc)
            }
            break
        case .post:
            guard let topVc = UIApplication.topViewController() as? NewfeedDetailViewController else {
                let vc = NewfeedDetailViewController()
                vc.newfeedId = String(model.id)
                vc.hidesBottomBarWhenPushed = true
                deeplinkPushViewContrller(vc)
                return
            }
            if topVc.newfeedId == String(model.id) {
                NotificationCenter.default.post(name: .kRefreshNewfeedDetail,
                                                object: nil,
                                                userInfo: nil)
            } else {
                
                let vc = NewfeedDetailViewController()
                vc.newfeedId = String(model.id)
                vc.hidesBottomBarWhenPushed = true
                deeplinkPushViewContrller(vc)
            }
            break
        case .message, .newMessage:
            guard let topVc = UIApplication.topViewController() as? ChatViewController else {
                let vc = ChatViewController()
                vc.channelId = String(model.id)
                vc.hidesBottomBarWhenPushed = true
                deeplinkPushViewContrller(vc)
                return
            }
            if topVc.channelId != "" {
                topVc.channelId = String(model.id)
                topVc.getChannelDetail()
            } else {
                let vc = ChatViewController()
                vc.channelId = String(model.id)
                vc.hidesBottomBarWhenPushed = true
                deeplinkPushViewContrller(vc)
            }
            
            break
        }
    }
    
    func application(_ application: UIApplication,
                     didRegister notificationSettings: UIUserNotificationSettings) {
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
    }
    
    // MARK: - RECEIVE NOTIFICATION
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        AudioServicesPlaySystemSound(1007);
        countNotificationBadge()
        if application.applicationState == .inactive {
            showRemoteNotificationDetails(data)
        } else if application.applicationState == .background {
            showRemoteNotificationDetails(data)
        } else {
//            showRemoteNotificationDetails(data)
        }
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AudioServicesPlaySystemSound(1007);
        countNotificationBadge()
        if application.applicationState == .inactive {
            showRemoteNotificationDetails(userInfo)
        } else if application.applicationState == .background {
            showRemoteNotificationDetails(userInfo)
        } else {
//            showRemoteNotificationDetails(userInfo)
        }
    }
    
    // MARK: - DEEPLINK
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.absoluteString.contains("twitter") {
            return TWTRTwitter.sharedInstance().application(application, open: url, options: annotation as! [AnyHashable : Any])
        } else if url.absoluteString.contains("line") {
            return LineSDKLogin.sharedInstance().handleOpen(url)
        } else if url.absoluteString.contains("setupPassword") {
            var urlPath = url.path
            let setPassVC = SetPasswordViewController()
            if urlPath.count > 0 {
                setPassVC.activationCode = urlPath.removeFirstCharacter
            }
            //            let nav = BaseNavigationController(rootViewController: setPassVC)
            self.window?.rootViewController = setPassVC
            self.window?.makeKeyAndVisible()
        } else if url.absoluteString.contains("resetPassword") {
            var urlPath = url.path
            let vc = ResetPasswordViewController()
            if urlPath.count > 0 {
                vc.activationCode = urlPath.removeFirstCharacter
            }
            let nav = BaseNavigationController(rootViewController: vc)
            self.window?.rootViewController = nav
            self.window?.makeKeyAndVisible()
        } else if url.absoluteString.contains("posts") &&
            url.absoluteString.contains("wcec"){
            guard let postId = Int(url.absoluteString.components(separatedBy: "/").last!) else {
                return false
            }
            let newfeedVc = NewfeedDetailViewController()
            newfeedVc.newfeedId = String(postId)
            if let vc = UIApplication.topViewController() as? NewfeedDetailViewController {
                if vc.newfeedId != String(postId) {
                    newfeedVc.hidesBottomBarWhenPushed = true
                    deeplinkPushViewContrller(newfeedVc)
                }
            } else {
                newfeedVc.hidesBottomBarWhenPushed = true
                deeplinkPushViewContrller(newfeedVc)
            }
        } else if url.absoluteString.contains("profile") &&
            url.absoluteString.contains("wcec"){
            guard let userId = Int(url.absoluteString.components(separatedBy: "/").last!) else {
                return false
            }
            let profileVc = ProfileDetailViewController()
            profileVc.userId = String(userId)
            if let vc = UIApplication.topViewController() as? ProfileDetailViewController {
                if vc.userId != String(userId) {
                    deeplinkPushViewContrller(profileVc)
                }
            } else {
                deeplinkPushViewContrller(profileVc)
            }
        }
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.absoluteString.contains("twitter") {
            return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        } else if url.absoluteString.contains("line") {
            return LineSDKLogin.sharedInstance().handleOpen(url)
        } else if url.absoluteString.contains("setupPassword") {
            var urlPath = url.path
            let setPassVC = SetPasswordViewController()
            if urlPath.count > 0 {
                setPassVC.activationCode = urlPath.removeFirstCharacter
            }
            self.window?.rootViewController = setPassVC
            self.window?.makeKeyAndVisible()
        } else if url.absoluteString.contains("resetPassword") {
            var urlPath = url.path
            let vc = ResetPasswordViewController()
            if urlPath.count > 0 {
                vc.activationCode = urlPath.removeFirstCharacter
            }
            let nav = BaseNavigationController(rootViewController: vc)
            self.window?.rootViewController = nav
            self.window?.makeKeyAndVisible()
        } else if url.absoluteString.contains("posts") && url.absoluteString.contains("wcec"){
            guard let postId = Int(url.absoluteString.components(separatedBy: "/").last!) else {
                return false
            }
            let newfeedVc = NewfeedDetailViewController()
            newfeedVc.newfeedId = String(postId)
            if let vc = UIApplication.topViewController() as? NewfeedDetailViewController {
                if vc.newfeedId != String(postId) {
                    newfeedVc.hidesBottomBarWhenPushed = true
                    deeplinkPushViewContrller(newfeedVc)
                }
            } else {
                newfeedVc.hidesBottomBarWhenPushed = true
                deeplinkPushViewContrller(newfeedVc)
            }
        } else if url.absoluteString.contains("profile") &&
            url.absoluteString.contains("wcec"){
            guard let userId = Int(url.absoluteString.components(separatedBy: "/").last!) else {
                return false
            }
            let profileVc = ProfileDetailViewController()
            profileVc.userId = String(userId)
            if let vc = UIApplication.topViewController() as? ProfileDetailViewController {
                if vc.userId != String(userId) {
                    deeplinkPushViewContrller(profileVc)
                }
            } else {
                deeplinkPushViewContrller(profileVc)
            }
        } else if url.absoluteString.contains("user-became-member") &&  url.absoluteString.contains("wcec") {
            deeplinkPushViewContrller(PopupAccountApprovedViewController())
        }
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func deeplinkPushViewContrller(_ vc: UIViewController) {
        guard !DataManager.getUserToken().isEmpty else {
            if vc.isKind(of: PopupAccountApprovedViewController.self) {
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overCurrentContext
                Constants.appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
            }
            return
        }
        if vc.isKind(of: PopupAccountApprovedViewController.self) {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            Constants.appDelegate.window?.rootViewController?.present(vc, animated: true, completion: nil)
        } else {
            if let _ = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
                self.window?.rootViewController?.dismiss(animated: true, completion: {
                    UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                })
            } else {
                UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func countNotificationBadge() {
        let userService = UserService()
        userService.getTotalNotificationNew { (result) in
            switch result {
            case .success(let response):
                UIApplication.shared.applicationIconBadgeNumber = response.data.countNotification + response.data.countMsgNotification
                if response.data.countMsgNotification > 0 {
                    self.tabbarController.addRedDotAtTabBarItem(atIndex: TabbarIndex.messageNav.rawValue)
                } else {
                    self.tabbarController.removeRedDotAtTabBarItem(atIndex: TabbarIndex.messageNav.rawValue)
                }
                if response.data.countNotification > 0 {
                    self.tabbarController.addRedDotAtTabBarItem(atIndex: TabbarIndex.meNav.rawValue)
                } else {
                    self.tabbarController.removeRedDotAtTabBarItem(atIndex: TabbarIndex.meNav.rawValue)
                }
                NotificationCenter.default.post(name: .kRefreshNotificationRedDot,
                                                object: response.data.countNotification,
                                                userInfo: nil)
                break
            case .failure(_):
                break
            }
        }
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    var applicationStateString: String {
        if UIApplication.shared.applicationState == .active {
            return "active"
        } else if UIApplication.shared.applicationState == .background {
            return "background"
        }else {
            return "inactive"
        }
    }
    
    // MARK: - RECEIVE NOTIFICATION
    
    // ios10 +
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        AudioServicesPlaySystemSound(1007);
        countNotificationBadge()
        let userInfo = response.notification.request.content.userInfo
        showRemoteNotificationDetails(userInfo)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard !DataManager.getUserToken().isEmpty else {
            return
        }
        let userInfo = notification.request.content.userInfo
        let model = RemoteNotificationModel(userInfo)
        if let topVc = UIApplication.topViewController() {
            if topVc.isKind(of: ChatViewController.self) {
                let chatVC = topVc as! ChatViewController
                if chatVC.channelId == String(model.id) {
                    completionHandler([.badge])
                    return
                }
            }
        }
        if UIApplication.shared.applicationState == .active {
            
            countNotificationBadge()
            
            switch model.notificationType {
            case .connection:
                //do nothing
                break
            case .post:
                //do nothing
                break
            case .message:
                //need refresh list chat
                let nav = tabbarController.viewControllers![3] as! BaseNavigationController
                for vc in nav.viewControllers {
                    if vc.isKind(of: MessagesViewController.self) {
                        let msgVC = vc as! MessagesViewController
                        msgVC.getData()
                    }
                }
                tabbarController.addRedDotAtTabBarItem(atIndex: TabbarIndex.messageNav.rawValue)
                break
            case .newMessage:
                tabbarController.addRedDotAtTabBarItem(atIndex: TabbarIndex.messageNav.rawValue)
                break
            }
        }
        completionHandler([.alert, .badge, .sound])
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
    }
}

extension AppDelegate {
    
    func clearNotification() {
        guard #available(iOS 10.0, *) else {
            return
        }
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
    }
    
    func showAlert(msg: String) {
        var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
        topWindow?.rootViewController = UIViewController()
        topWindow?.windowLevel = UIWindowLevelAlert + 1
        let alert = UIAlertController(title: "APNS", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "confirm"), style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            // continue your work
            
            // important to hide the window after work completed.
            // this also keeps a reference to the window until the action is invoked.
            topWindow?.isHidden = true // if you want to hide the topwindow then use this
            topWindow = nil // if you want to hide the topwindow then use this
        }))
        topWindow?.makeKeyAndVisible()
        topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
