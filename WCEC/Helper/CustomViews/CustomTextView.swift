//
//  CustomTextView.swift
//  WCEC
//
//  Created by hnc on 5/9/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
@objc protocol CustomTextViewDelegate: NSObjectProtocol {
    @objc optional func customTextViewDidBeginEditting(_ textView: UITextView)
    @objc optional func customTextViewDidEndEditting(_ textView: UITextView)
}

class CustomTextView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    weak var delegate: CustomTextViewDelegate?
    
    var title: String? {
        didSet {
            titleLabel.text = title
            titleLabel.textColor = AppColor.colorTitleTextField()
        }
    }
    
    var text: String? {
        didSet {
            textView.text = text
            textView.textColor = AppColor.colorTitleTextField()
            textView.font = AppFont.fontWithType(.regular, size: 16)
        }
    }
    
    func setText(_ textString: String) {
        textView.text = textString
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
        Bundle.main.loadNibNamed("CustomTextView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        textView.setLeftPaddingPoints(5)
        textView.delegate = self
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = AppColor.colorBorderBlack().cgColor
    }
}

extension CustomTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = AppColor.colorBorderRustyOrange().cgColor
        delegate?.customTextViewDidBeginEditting?(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = AppColor.colorBorderBlack().cgColor
        delegate?.customTextViewDidEndEditting?(textView)
    }
}







