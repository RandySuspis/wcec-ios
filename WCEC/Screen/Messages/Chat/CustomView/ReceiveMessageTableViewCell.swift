//
//  ReceiveMessageTableViewCell.swift
//  WCEC
//
//  Created by hnc on 6/28/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ReceiveMessageTableViewCell: BaseTableViewCell {
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.messageBackground.layer.cornerRadius = 8
        self.messageBackground.clipsToBounds = true
        self.message.text = ""
    }
    
    override func bindingWithModel(_ model: PBaseRowModel) {
        super.bindingWithModel(model)
        if let rowModel = model as? ChatRowModel {
            self.message.text = rowModel.message
        }
    }
}
