//
//  LanguagesViewController.swift
//  WCEC
//
//  Created by GEM on 6/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Localize_Swift

class LanguagesViewController: BaseViewController {

    @IBOutlet weak var englishIconImageView: UIImageView!
    @IBOutlet weak var chineseIconImageView: UIImageView!
    @IBOutlet weak var confirmButton: UIButton!
    
    let availableLanguages = Localize.availableLanguages()
    var userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Language".localized()
        confirmButton.setTitle("Confirm".localized(), for: .normal)
    }

    func setupUI() {
        englishIconImageView.isHidden = true
        if Localize.currentLanguage() == "en" {
            englishIconImageView.isHidden = false
            chineseIconImageView.isHidden = true
        } else {
            englishIconImageView.isHidden = true
            chineseIconImageView.isHidden = false
        }
        for lang in availableLanguages {
            print(lang)
        }
    }
    
    @IBAction func tapEnglish(_ sender: Any) {
        englishIconImageView.isHidden = false
        chineseIconImageView.isHidden = true
    }
    
    @IBAction func tapChinese(_ sender: Any) {
        englishIconImageView.isHidden = true
        chineseIconImageView.isHidden = false
    }
    
    @IBAction func tapConfirm(_ sender: Any) {
        guard let currentUser = DataManager.getCurrentUserModel() else { return }
        showHud()
        userService.doUpdateLanguage(userId: currentUser.id,
                                     language: englishIconImageView.isHidden
                                        ? LanguageType.chinese.rawValue : LanguageType.english.rawValue) { (result) in
                                            self.hideHude()
                                            switch result {
                                            case .success(_):
                                                if !self.englishIconImageView.isHidden {
                                                    Localize.setCurrentLanguage("en")
                                                } else {
                                                    Localize.setCurrentLanguage("zh-Hans")
                                                }
                                                Constants.appDelegate.restartRootView()
                                                self.navigationController?.popViewController(animated: true)
                                                break
                                            case .failure(let error):
                                                self.alertWithError(error)
                                                break
                                            }
        }
    }
}
