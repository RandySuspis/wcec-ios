
//
//  PopupCencelRequest.swift
//  WCEC
//
//  Created by GEM on 8/10/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol PopupCencelRequestDelegate: NSObjectProtocol {
    func popupCencelRequestDidTapYes(requestId: Int)
}

class PopupCencelRequest: BasePopup {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    weak var delegate: PopupCencelRequestDelegate?
    var userName = ""
    var requestId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupLocalized() {
        titleLabel.text = "Cancel Request".localized()
        descLabel.text = String(format: "Are you sure you want to cancel your request to ".localized(), userName)
        yesButton.setTitle("Yes".localized(), for: .normal)
        noButton.setTitle("No".localized(), for: .normal)
    }
    
    @IBAction func tapYes(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.delegate?.popupCencelRequestDidTapYes(requestId: self.requestId)
        })
    }
    
    @IBAction func tapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapNo(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
