//
//  PopupClearChat.swift
//  WCEC
//
//  Created by GEM on 7/24/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol PopupClearChatDelegate: NSObjectProtocol {
    func popupClearChat()
}

class PopupClearChat: BasePopup {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    weak var delegate: PopupClearChatDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func setupLocalized() {
        titleLabel.text = "Clear Chat".localized()
        descLabel.text = "Clearing all chat history in this conversation".localized()
        cancelButton.setTitle("Cancel".localized(), for: .normal)
        confirmButton.setTitle("Confirm".localized(), for: .normal)
    }
    
    @IBAction func tapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapConfirm(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.popupClearChat()
        }
    }
}
