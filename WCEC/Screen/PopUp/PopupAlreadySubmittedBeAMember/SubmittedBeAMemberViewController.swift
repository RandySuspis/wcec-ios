//
//  SubmittedBeAMemberViewController.swift
//  WCEC
//
//  Created by hnc on 8/22/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class SubmittedBeAMemberViewController: BaseViewController {
    @IBOutlet weak var backMainButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var reEnterFormButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupLocalized() {
        
    }
    
    @IBAction func onSelectLogin(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Constants.appDelegate.setupAuthentication()
    }
    
    @IBAction func onSelectBackToMainPage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Constants.appDelegate.setupRootViewController()
    }
    
    @IBAction func onSelectReEnterForm(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        Constants.appDelegate.setupBeAMemberForm()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
