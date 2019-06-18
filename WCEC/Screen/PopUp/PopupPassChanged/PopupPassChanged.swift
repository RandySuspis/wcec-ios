//
//  PopupPassChanged.swift
//  WCEC
//
//  Created by GEM on 7/24/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol PopupPassChangedDelegate:NSObjectProtocol {
    func popupPassChangedDidTapOK()
}
class PopupPassChanged: BasePopup {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    weak var delegate: PopupPassChangedDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupLocalized() {
        titleLabel.text = "Password Changed".localized()
        okButton.setTitle("OK".localized(), for: .normal)
    }
    
    @IBAction func tapOK(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.popupPassChangedDidTapOK()
        }
    }
}
