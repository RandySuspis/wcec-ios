//
//  PopupRemoveConnection.swift
//  WCEC
//
//  Created by GEM on 6/5/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class PopupRemoveConnection: BasePopup {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupLocalized() {
        
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onRemove(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
