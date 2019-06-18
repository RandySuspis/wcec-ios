//
//  PopupSuccessForgotPWViewController.swift
//  WCEC
//
//  Created by GEM on 5/29/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class PopupSuccessForgotPWViewController: BasePopup {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        super.setupUI()
    }

    override func setupLocalized() {
        lblTitle.text = "Link Sent".localized()
        lblDesc.text = "A link to reset your password has been sent to your e-mail.".localized()
        btnOk.setTitle("OK".localized(), for: .normal)
    }
    
    @IBAction func onOk(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
