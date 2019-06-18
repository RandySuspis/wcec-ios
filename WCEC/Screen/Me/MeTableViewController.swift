//
//  MeTableViewController.swift
//  WCEC
//
//  Created by GEM on 6/28/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Localize_Swift

class MeTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDescLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var myProfileLabel: UILabel!
    @IBOutlet weak var qrCodeLabel: UILabel!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var faqLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var eliteImageView: UIImageView!
    @IBOutlet weak var notiView: UIView!
    
    var userService = UserService()
    fileprivate var listChannelId = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocalized()
        getListChannelID()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupLocalized),
                                               name: NSNotification.Name( LCLLanguageChangeNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupUI),
                                               name: .kRefreshMyProfile,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotificationRedDot), name: .kRefreshNotificationRedDot, object: nil)
        Constants.appDelegate.countNotificationBadge()
    }

    @objc func setupUI() {
        guard let currentUser = DataManager.getCurrentUserModel() else {
            return
        }
        eliteImageView.isHidden = !currentUser.elite
        userNameLabel.text = currentUser.fullName
        userDescLabel.text = currentUser.currentJobCompany
        userLocationLabel.text = currentUser.currentLocationOccupation
        notiView.layer.cornerRadius = notiView.frame.width/2
        avatarImageView.kf.setImage(with: URL(string: currentUser.avatar.file_url),
                                    placeholder: #imageLiteral(resourceName: "placeholder"),
                                    options: nil,
                                    progressBlock: nil,
                                    completionHandler: nil)
    }
    
    @objc func setupLocalized() {
        myProfileLabel.text = "My Profile".localized()
        qrCodeLabel.text = "My QR Code".localized()
        notificationsLabel.text = "Notifications".localized()
        settingsLabel.text = "Settings".localized()
        faqLabel.text = "FAQ".localized()
        logoutLabel.text = "Log Out".localized()
    }
    
    @objc func refreshNotificationRedDot(notification: Notification) {
        guard let count = notification.object as? Int else {
            return
        }
        notiView.isHidden = count == 0 ? true : false
    }
    
    func getListChannelID() {
        showHud()
        let chatService = ChatService()
        chatService.getListChannelId { (result) in
            self.hideHude()
            switch result {
            case .success(let responseChannel):
                self.listChannelId = responseChannel.data
                break
            case .failure( let error):
                #if DEBUG
                    DLog("ChannelIDs: \(error)")
                #endif
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            guard let currentUser = DataManager.getCurrentUserModel() else {
                return
            }
            let vc = ProfileDetailViewController()
            vc.userId = String(currentUser.id)
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2:
            let vc = MyQRCodeViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 3:
            let vc = NotificationsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 4:
            let vc = SettingsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 5:
            let vc = FAQViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 6:
            self.showHud()
            userService.doLogOut(complete: { (result) in
                switch result {
                case .success(_):
                    Constants.appDelegate.client.removePushNotificationsFromChannels(self.listChannelId,
                                                                                     withDevicePushToken: DataManager.deviceTokenData()) { (status) in
                                                                                        Constants.appDelegate.setupAuthentication()
                                                                                        Constants.appDelegate.tabbarController.selectedIndex = 2
                                                                                        self.hideHude()
                                                                                        if !status.isError {
                                                                                        }
                                                                                        else {
                                                                                        }
                    }
                case .failure(let error):
                    self.alertWithError(error)
                    break
                }
            })
            break
        default:
            break
        }
    }

    @IBAction func tapAvatar(_ sender: Any) {
        guard let currentUser = DataManager.getCurrentUserModel() else {
            return
        }
        let vc = PhotoViewerViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.listPhoto = [currentUser.avatar.file_url]
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
}
