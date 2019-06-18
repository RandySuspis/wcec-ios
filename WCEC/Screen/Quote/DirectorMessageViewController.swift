//
//  DirectorMessageViewController.swift
//  WCEC
//
//  Created by GEM on 6/5/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class DirectorMessageViewController: BaseViewController {

    @IBOutlet weak var imgNav: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var quote: QuoteModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func setupLocalized() {
        guard let data = quote else {
            return
        }
        lblTitle.text = data.jobtitle + "'s Message".localized()
    }
    
    func setupUI() {
        var updatedFrame = imgNav.bounds
        
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == 2436{
                updatedFrame.size.height += 44
            } else {
                updatedFrame.size.height += 20
            }
        }
        
        let gradient = CAGradientLayer()
        gradient.colors = [AppColor.colorFadedRed().cgColor, AppColor.colorlightBurgundy().cgColor, AppColor.colorpurpleBrown().cgColor]
        gradient.frame = updatedFrame
        
        imgNav.image = UIImage.imageWithLayer(layer: gradient)
        
        guard let data = quote else {
            return
        }
        avatarImageView.kf.setImage(with: URL(string: data.avatar.thumb_file_url),
                           placeholder: #imageLiteral(resourceName: "placeholder"), options: nil,
                           progressBlock: nil,
                           completionHandler: nil)
        lblTitle.text = data.jobtitle + "'s Message".localized()
        nameLabel.text = data.name
        jobLabel.text = data.jobtitle
        messageLabel.text = data.quote
        
    }

    @IBAction func tapAvatar(_ sender: Any) {
        guard let data = quote else {
            return
        }
        openPhotoViewer([data.avatar.thumb_file_url])
    }

    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
