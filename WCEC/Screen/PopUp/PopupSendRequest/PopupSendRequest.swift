//
//  PopupSendRequest.swift
//  WCEC
//
//  Created by GEM on 5/14/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Kingfisher
import IQKeyboardManagerSwift

protocol PopupSendRequestDelegate: NSObjectProtocol {
    func popupSendRequest(_ controller: PopupSendRequest, didClose sender: UIButton, success: Bool)
}

class PopupSendRequest: BasePopup {
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblJob: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTitleTextView: UILabel!
    @IBOutlet weak var textViewMsg: UITextView!
    @IBOutlet weak var btnSendRequest: UIButton!
    @IBOutlet weak var lblSendSuccess: UILabel!
    @IBOutlet weak var imgSendSuccess: UIImageView!
    @IBOutlet weak var lblUnderMsg: UILabel!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var eliteImageView: UIImageView!
    @IBOutlet weak var bottomConstaint: NSLayoutConstraint!

    var isSuccess: Bool = false
    var connectionRowModel: PBaseRowModel?
    let connectionService = ConnectionsService()
    
    weak var delegate: PopupSendRequestDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
        getDefaultRequestMessage()
//        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.enableAutoToolbar = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardNotification),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardNotification),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        setupLocalized()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
//        IQKeyboardManager.shared.enable = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        if touch.view != viewPopup {
//            dismiss(animated: true, completion: nil)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        textViewMsg.layer.borderWidth = 1.0
        textViewMsg.layer.borderColor = AppColor.colorOrange().cgColor
        textViewMsg.layer.cornerRadius = 4.0
        textViewMsg.layer.masksToBounds = true
        textViewMsg.delegate = self
        textViewMsg.autocorrectionType = .no
        lblSendSuccess.isHidden = true
        imgSendSuccess.isHidden = true
    }

    @objc func handleKeyboardNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            bottomConstaint.constant = isKeyboardShowing ? (keyboardFrame?.height)! + 10 : 150
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }

    func getDefaultRequestMessage() {
        self.showHud()
        connectionService.defaultRequestMessage { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                self.textViewMsg.text = response.data.localized();
                break
            case .failure(_):
                //do nothing
                self.textViewMsg.text = "Hi, add me to your connection?".localized()
                break
            }
        }
    }
    
    func setupData() {
        lblName.text = connectionRowModel?.title
        lblJob.text = connectionRowModel?.desc
        lblDesc.text = connectionRowModel?.note
        
        if let model = connectionRowModel as? ConnectionsRowModel {
            eliteImageView.isHidden = !model.elite
        } else if let model = connectionRowModel as? ProfileDetailRowModel {
            eliteImageView.isHidden = !model.userModel!.elite
        }
        
        imgAvatar.kf.setImage(with: URL(string: (connectionRowModel?.image)!),
                              placeholder: #imageLiteral(resourceName: "placeholder"), options: nil,
                              progressBlock: nil,
                              completionHandler: nil)
        lblTitleTextView.text = "Send a message to".localized() + " " + (connectionRowModel?.title)!
    }
    
    override func setupLocalized() {
        btnSendRequest.titleLabel?.text = "Send Request".localized()
//        textViewMsg.text = "Hi, add me to your connection?".localized()
    }
    
    @IBAction func btnClose_Action(_ sender: Any) {
        delegate?.popupSendRequest(self, didClose: sender as! UIButton, success: isSuccess)
    }

    @IBAction func tapAvatar(_ sender: Any) {
        openPhotoViewer([connectionRowModel?.image])
    }
    
    @IBAction func btnSendRequest_Action(_ sender: Any) {
        if let msg = validateMaxCharacter("Message".localized(),
                                textCount: textViewMsg.text!.count,
                                numberMax: 180) {
            self.alertView("Alert".localized(), message: msg)
            return
        }
        
        self.showHud()
        connectionService.sendConnection(senderID: (DataManager.getCurrentUserModel()?.id)!,
                                         receiverID: (connectionRowModel?.objectID)!,
                                         message: textViewMsg.text) { (result) in
            self.hideHude()
            switch result {
            case .success( _):
                self.lblSendSuccess.isHidden = false
                self.imgSendSuccess.isHidden = false
                self.lblTitleTextView.isHidden = true
                self.textViewMsg.isHidden = true
                self.lblUnderMsg.isHidden = true
                self.btnSendRequest.backgroundColor = AppColor.colorGray176()
                self.btnSendRequest.isEnabled = false
                self.isSuccess = true
                NotificationCenter.default.post(name: .kRefreshConnections,
                                                object: nil,
                                                userInfo: nil)
                break
            case .failure( let error):
                self.alertWithError(error)
                break
            }
        }
    }
}

extension PopupSendRequest: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
        return numberOfChars <= 180;
    }
}
