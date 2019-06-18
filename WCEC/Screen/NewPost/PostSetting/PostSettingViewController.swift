//
//  PostSettingViewController.swift
//  WCEC
//
//  Created by hnc on 6/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class PostSettingViewController: BaseViewController {
    @IBOutlet weak var privateLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        switchButton.isOn = !NewPostViewModel.shareInstance.visibility
        if switchButton.isOn {
            statusLabel.text = "Only visible to your connection".localized()
        } else {
            statusLabel.text = "Visible to everyone".localized()
        }
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Post Setting".localized()
        privateLabel.text = "Private".localized()
        if switchButton.isOn {
            statusLabel.text = "Only visible to your connection".localized()
        } else {
            statusLabel.text = "Visible to everyone".localized()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onChangedPrivateOrUnPrivateButton(_ sender: Any) {
        if switchButton.isOn {
            statusLabel.text = "Only visible to your connection".localized()
            NewPostViewModel.shareInstance.visibility = false
        } else {
            statusLabel.text = "Visible to everyone".localized()
            NewPostViewModel.shareInstance.visibility = true
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
