//
//  CustomDateView.swift
//  WCEC
//
//  Created by GEM on 5/21/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol CustomDateViewDelegate: NSObjectProtocol {
    func didSelectView(title: String)
}

class CustomDateView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgDate: UIImageView!
    @IBOutlet weak var viewDate: UIView!
    
    weak var delegate: CustomDateViewDelegate?
    
    var title: String? {
        didSet {
            lblTitle.text = title
        }
    }
    
    var date: String? {
        didSet {
            lblDate.text = date
        }
    }
    
    var isHightLight: Bool = false {
        didSet {
            if isHightLight {
                viewDate.layer.borderColor = AppColor.colorBorderRustyOrange().cgColor
            } else {
                viewDate.layer.borderColor = AppColor.colorBorderBlack().cgColor
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        Bundle.main.loadNibNamed("CustomDateView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        viewDate.layer.borderWidth = 0.5
        viewDate.layer.borderColor = AppColor.colorBorderBlack().cgColor
        viewDate.layer.cornerRadius = 3.0
        viewDate.layer.masksToBounds = true
        
    }
    
    @IBAction func onPressView(_ sender: Any) {
        if let title = self.title {
            delegate?.didSelectView(title: title)
        }
    }
    
}
