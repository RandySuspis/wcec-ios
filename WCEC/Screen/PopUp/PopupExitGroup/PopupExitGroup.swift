//
//  PopupExitGroup.swift
//  WCEC
//
//  Created by GEM on 7/24/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol PopupExitGroupDelegate: NSObjectProtocol {
    func popupExitGroup()
}

class PopupExitGroup: BasePopup {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    weak var delegate: PopupExitGroupDelegate?
    var conversationName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupLocalized() {
        titleLabel.text = "Exit Group".localized() + "\n" + conversationName
        descLabel.text = "You will no longer be a part of this group. You will unable to view or send any chat.".localized()
        cancelButton.setTitle("Cancel".localized(), for: .normal)
        exitButton.setTitle("Exit Group".localized(), for: .normal)
    }
    
    @IBAction func tapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapExit(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.popupExitGroup()
        }
    }
}
