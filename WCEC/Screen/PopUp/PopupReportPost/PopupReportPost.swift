//
//  PopupReportPost.swift
//  WCEC
//
//  Created by GEM on 6/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class PopupReportPost: BasePopup {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var reasonTextView: CustomTextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    var connectionService = ConnectionsService()
    var postId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        IQKeyboardManager.shared.enable = false
    }
    
    override func setupLocalized() {
        titleLabel.text = "Report".localized()
        descLabel.text = "Please help us understand what is inappropriate to this post".localized()
        cancelButton.setTitle("Cancel".localized(), for: .normal)
        reportButton.setTitle("Report Post".localized(), for: .normal)
        reasonTextView.title = "Report Messages".localized()
        reasonTextView.text = "Write down reason for report".localized()
    }
    
    override func setupUI() {
        super.setupUI()
        reasonTextView.delegate = self
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onReport(_ sender: Any) {
        guard let postId = postId else {
            return
        }
        
        guard reasonTextView.textView.text != "Write down reason for report".localized() &&
        reasonTextView.textView.text != "" else {
            self.alertView("Alert".localized(), message: "Please input report messages".localized())
            return
        }
        
        if let msg = validateMaxCharacter("Report Messages".localized(),
                                   textCount: reasonTextView.textView.text.count,
                                   numberMax: 255) {
            self.alertView("Alert".localized(), message: msg)
            return
        }
        
        self.showHud()
        connectionService.reportPost(postId: postId,
                                     message: reasonTextView.textView.text) { (result) in
                                        self.hideHude()
                                        switch result {
                                        case .success(_):
                                            let alertView = UIAlertController(title: "Success".localized(), message: "Your report has been sent successfully".localized(), preferredStyle: UIAlertControllerStyle.alert)
                                            let cancelAction = UIAlertAction(title: "OK".localized(), style: .cancel) { (_) in
                                                self.dismiss(animated: true, completion: nil)
                                            }
                                            
                                            alertView.addAction(cancelAction)
                                            self.present(alertView, animated: true, completion: nil)
                                            break
                                        case .failure(let error):
                                            self.alertWithError(error)
                                            break
                                        }
        }
    }
}

extension PopupReportPost: CustomTextViewDelegate {
    func customTextViewDidBeginEditting(_ textView: UITextView) {
        if textView.text == "Write down reason for report".localized() {
            textView.text = ""
        }
    }
    
    func customTextViewDidEndEditting(_ textView: UITextView) {
        if textView.text == "".localized() {
            textView.text = "Write down reason for report".localized()
        }
    }
}







