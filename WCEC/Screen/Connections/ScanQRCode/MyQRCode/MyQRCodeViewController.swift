//
//  MyQRCodeViewController.swift
//  WCEC
//
//  Created by GEM on 5/18/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class MyQRCodeViewController: BaseViewController {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var imgQrCode: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ctTopImgQrCode: NSLayoutConstraint!
    @IBOutlet weak var ctBotImgQrCode: NSLayoutConstraint!
    @IBOutlet weak var eliteImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "My QR Code".localized()
    }
    
    func setupUI() {
        self.view.backgroundColor = AppColor.colorCellBgBlack()
        
        if Constants.isIphone5 {
            ctTopImgQrCode.constant = 60
            ctBotImgQrCode.constant = 50
            self.view.layoutIfNeeded()
        }
        if let user = DataManager.getCurrentUserModel() {
            lblName.text = user.fullName
            lblDesc.text = user.currentJobCompany
            eliteImageView.isHidden = !user.elite
            if user.avatar.thumb_file_url.count > 0 {
                imgAvatar.kf.setImage(with: URL(string: user.avatar.thumb_file_url),
                                      placeholder: #imageLiteral(resourceName: "default_avatar"),
                                      options: nil,
                                      progressBlock: nil,
                                      completionHandler: nil)
            } else if DataManager.getSavedImage(named: Constants.kSocialAvatar) != nil {
                self.imgAvatar.image = DataManager.getSavedImage(named: Constants.kSocialAvatar)!
            }
        }
            
        generatorQRCode()
    }

    func generatorQRCode() {
        imgQrCode.image = {
            if let user = DataManager.getCurrentUserModel() {
                let data = user.qr_code_id
                var qrCode = QRCode(data)
                qrCode?.errorCorrection = .High
                return qrCode?.image
            }
            return UIImage()
        }()
    }
    
    @IBAction func tapAvatar(_ sender: Any) {
        guard let user = DataManager.getCurrentUserModel() else {
            return
        }
        if user.avatar.thumb_file_url.count > 0 {
            openPhotoViewer([user.avatar.thumb_file_url])
        } else if DataManager.getSavedImage(named: Constants.kSocialAvatar) != nil {
            openPhotoViewer([DataManager.getSavedImage(named: Constants.kSocialAvatar)!])
        }
    }
}










