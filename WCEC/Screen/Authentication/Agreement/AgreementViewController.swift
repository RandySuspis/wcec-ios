//
//  AgreementViewController.swift
//  WCEC
//
//  Created by hnc on 5/9/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
protocol AgreementViewControllerDelegate: class {
    func onUserAgreeTerm(_ viewController: AgreementViewController, withAccountType type: AccountType)
    func onCloseAgrement(_ viewController: AgreementViewController)
}

class AgreementViewController: BaseViewController {
    @IBOutlet weak var agreeButton: UIButton!
    weak var delegate: AgreementViewControllerDelegate?
    var type: AccountType = .unknow
    
    let service = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem.closeBarItem(target: self, btnAction: #selector(onBack(_:)))
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Agreement".localized()
        agreeButton.setTitle("I Agree, Continue".localized(), for: .normal)
    }

    @IBAction func onSelectAgree(_ sender: Any) {
        self.showHud()
        service.upRootFirstTimeLogin { (result) in
            self.hideHude()
            switch result {
            case .failure(let error):
                self.alertWithError(error)
                break
            case .success(_):
                self.dismiss(animated: true, completion: {
                    if let user = DataManager.getCurrentUserModel() {
                        user.firstTimeLogin = false
                        DataManager.saveUserModel(user)
                    }
                    self.delegate?.onUserAgreeTerm(self, withAccountType: self.type)
                })
                break
            }
        }
    }
    
    @objc func onBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {
            self.delegate?.onCloseAgrement(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
