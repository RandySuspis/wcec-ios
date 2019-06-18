//
//  PopupConnectedViewController.swift
//  WCEC
//
//  Created by GEM on 6/7/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol PopupConnectedViewControllerDelegate: NSObjectProtocol {
    func popupConnectedViewController(userId: String)
}

class PopupConnectedViewController: BasePopup {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var eliteImageView: UIImageView!
    
    weak var delegate: PopupConnectedViewControllerDelegate?
    var user: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let user = user else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        nameLabel.text = user.fullName
        descLabel.text = user.currentJobCompany
        if user.mutual_connections == 0 {
            statusLabel.text = ""
        } else {
            statusLabel.text = String(user.mutual_connections) +
                (user.mutual_connections == 1 ?
                    " mutual connection".localized() :
                    " mutual connections".localized())
        }
        eliteImageView.isHidden = !user.elite
        avatarImageView.kf.setImage(with: URL(string: user.avatar.thumb_file_url),
                                    placeholder: #imageLiteral(resourceName: "placeholder"),
                                    options: nil,
                                    progressBlock: nil,
                                    completionHandler: nil)
    }
    override func setupLocalized() {
        connectedLabel.text = "Connected".localized()
        okButton.setTitle("OK".localized(), for: .normal)
    }
    
    @IBAction func tapAvatar(_ sender: Any) {
        guard let user = user else {
            dismiss(animated: true, completion: nil)
            return
        }
        openPhotoViewer([user.avatar.thumb_file_url])
    }

    @IBAction func onOK(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.popupConnectedViewController(userId: String(self.user!.id))
        }
    }
    
}
