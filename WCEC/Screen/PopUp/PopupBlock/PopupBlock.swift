//
//  PopupBlock.swift
//  WCEC
//
//  Created by GEM on 6/5/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol PopupBlockDelegate: NSObjectProtocol {
    func popupBlockSuccess()
}

class PopupBlock: BasePopup {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    
    weak var delegate: PopupBlockDelegate?
    var user: UserModel?
    var connectionService = ConnectionsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupLocalized() {
        guard let user = user else {
            dismiss(animated: true, completion: nil)
            return
        }
        lblTitle.text = "Block".localized()
        lblDesc.text =  String(format: "You will no longer be connected to ".localized(), user.fullName)
        btnCancel.setTitle("Cancel".localized(), for: .normal)
        btnReport.setTitle("Confirm".localized(), for: .normal)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onReport(_ sender: Any) {
        guard let currentUser = DataManager.getCurrentUserModel() else {
            dismiss(animated: true, completion: nil)
            return
        }
        self.showHud()
        connectionService.doBlockUser(blockUserId: String(self.user!.id),
                                      currentUserId: String(currentUser.id)) { (result) in
                                        self.hideHude()
                                        switch result {
                                        case .success( _):
                                            self.dismiss(animated: true, completion: {
                                                self.delegate?.popupBlockSuccess()
                                            })
                                            NotificationCenter.default.post(name: .kRefreshConnections,
                                                                            object: nil,
                                                                            userInfo: nil)
                                            break
                                        case .failure(let error):
                                            self.alertWithError(error)
                                            break
                                        }
        }
    }
}
