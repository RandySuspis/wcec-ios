//
//  QuoteViewController.swift
//  WCEC
//
//  Created by GEM on 6/5/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SwiftyJSON

class QuoteViewController: BaseViewController {
    @IBOutlet weak var viewDirectorOne: UIView!
    @IBOutlet weak var viewDirectorTwo: UIView!
    @IBOutlet weak var viewDirectorThree: UIView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var avatarOneImageView: UIImageView!
    @IBOutlet weak var nameOneLabel: UILabel!
    @IBOutlet weak var descOneLabel: UILabel!
    @IBOutlet weak var avatarTwoImageView: UIImageView!
    @IBOutlet weak var nameTwoLabel: UILabel!
    @IBOutlet weak var descTwoLabel: UILabel!
    @IBOutlet weak var avatarThreeImageView: UIImageView!
    @IBOutlet weak var nameThreeLabel: UILabel!
    @IBOutlet weak var descThreeLabel: UILabel!
    
    let userService = UserService()
    var quotes = [QuoteModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
    }
    
    override func setupLocalized() {
        skipButton.setTitle("Skip Intro".localized(), for: .normal)
        descLabel.text = "See messages from the Directors".localized()
    }
    
    func getData() {
        self.showHud()
        userService.getListQuotes { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                if let response = response.data as? JSON {
                    let array = response["quotes"].arrayValue
                    var models = [QuoteModel]()
                    for item in array {
                        let dto = QuoteDTO(item)
                        let model = QuoteModel(dto)
                        models.append(model)
                    }
                    self.showData(models)
                    self.welcomeLabel.text = response["welcome_message"].stringValue
                }
                break
            case .failure(let error):
                self.alertWithError(error)
                break
            }
        }
    }
    
    func showData(_ data: [QuoteModel]) {
        quotes = data
        guard data.count > 0 else {
            viewDirectorOne.backgroundColor = UIColor.clear
            viewDirectorTwo.backgroundColor = UIColor.clear
            viewDirectorThree.backgroundColor = UIColor.clear
            return
        }
        avatarOneImageView.kf.setImage(with: URL(string: data[0].avatar.thumb_file_url),
                                       placeholder: #imageLiteral(resourceName: "placeholder"),
                                       options: nil,
                                       progressBlock: nil,
                                       completionHandler: nil)
        nameOneLabel.text = data[0].name
        descOneLabel.text = data[0].jobtitle
        guard data.count > 1 else {
            viewDirectorTwo.backgroundColor = UIColor.clear
            viewDirectorThree.backgroundColor = UIColor.clear
            return
        }
        avatarTwoImageView.kf.setImage(with: URL(string: data[1].avatar.thumb_file_url),
                                       placeholder: #imageLiteral(resourceName: "placeholder"),
                                       options: nil,
                                       progressBlock: nil,
                                       completionHandler: nil)
        nameTwoLabel.text = data[1].name
        descTwoLabel.text = data[1].jobtitle
        guard data.count > 2 else {
            viewDirectorThree.backgroundColor = UIColor.clear
            return
        }
        avatarThreeImageView.kf.setImage(with: URL(string: data[2].avatar.thumb_file_url),
                                       placeholder: #imageLiteral(resourceName: "placeholder"),
                                       options: nil,
                                       progressBlock: nil,
                                       completionHandler: nil)
        nameThreeLabel.text = data[2].name
        descThreeLabel.text = data[2].jobtitle
        
    }
    
    func setupUI() {
        setupBorderAndShadow(layer: viewDirectorOne.layer)
        setupBorderAndShadow(layer: viewDirectorTwo.layer)
        setupBorderAndShadow(layer: viewDirectorThree.layer)
        skipButton.layer.cornerRadius = 3.0
        skipButton.layer.masksToBounds = true
        skipButton.layer.borderWidth = 1.0
        skipButton.layer.borderColor = AppColor.colorOrange().cgColor
    }
    
    @IBAction func onPressDirector(_ sender: UIButton) {
        guard self.quotes.count - 1 >= sender.tag else { return }
        let vc = DirectorMessageViewController()
        vc.quote = quotes[sender.tag]
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onSkip(_ sender: Any) {
        Constants.appDelegate.setupIntro()
    }
}
