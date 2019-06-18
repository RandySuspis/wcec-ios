//
//  SettingsViewController.swift
//  WCEC
//
//  Created by GEM on 6/28/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController {

    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var changePassWordLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var userService = UserService()
    var chatService = ChatService()
    var arrIdMsgChannel = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getChannelIds()
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") {
            versionLabel.text = "Version: \(version)"
        }
        guard let currentUser = DataManager.getCurrentUserModel() else { return }
        notificationSwitch.isOn = currentUser.push_notification
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Settings".localized()
        notificationLabel.text = "Enable Notifications".localized();
        languageLabel.text = "Language".localized();
        changePassWordLabel.text = "Change Password".localized();
    }
    
    func getChannelIds() {
        self.showHud()
        chatService.getListChannelId { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                self.arrIdMsgChannel = response.data
                break
            case .failure( let error):
                #if DEBUG
                    DLog("ChannelIDs: \(error)")
                #endif
            }
        }
    }
    
    @IBAction func onSwitchNotification(_ sender: Any) {
        guard let currentUser = DataManager.getCurrentUserModel() else { return }
        showHud()
        userService.doEnableNotification(userId: currentUser.id,
                                         enable: notificationSwitch.isOn ? 1 : 0) { (result) in
                                            switch result {
                                            case .success(let response):
                                                DataManager.saveUserModel(response.data)
                                                if response.data.push_notification {
                                                    self.registerDeviceTokenWithPubnub(self.arrIdMsgChannel)
                                                } else {
                                                    self.unRegisterDeviceTokenWithPubnub(self.arrIdMsgChannel)
                                                }
                                                break
                                            case .failure(let error):
                                                self.alertWithError(error)
                                                break
                                            }
                                            self.hideHude()
        }
    }
    
    @IBAction func tapLanguage(_ sender: Any) {
        let vc = LanguagesViewController()
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    @IBAction func tapChangePassword(_ sender: Any) {
        let vc = ChangePasswordViewController()
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
}





