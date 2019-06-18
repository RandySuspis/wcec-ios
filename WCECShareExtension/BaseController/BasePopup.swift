//
//  BasePopup.swift
//  WCEC
//
//  Created by GEM on 6/5/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class BasePopup: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    init(_ name: String) {
        super.init(nibName: name, bundle: Bundle.main)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let overlay = UIVisualEffectView()
        overlay.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view.insertSubview(overlay, at: 0)
        overlay.effect = UIBlurEffect(style: .dark)
        view.backgroundColor = UIColor.clear
    }
}
