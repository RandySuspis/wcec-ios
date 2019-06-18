//
//  TagView.swift
//  TagListViewDemo
//
//  Created by Dongyuan Liu on 2015-05-09.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit

@IBDesignable
open class TagView: UIView {
    var label = UILabel()
    var button = UIButton()
    var tagId: Int = -1
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            label.layer.cornerRadius = cornerRadius
            label.layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            label.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable open var borderColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var textColor: UIColor = UIColor.white {
        didSet {
            reloadStyles()
        }
    }
    @IBInspectable open var selectedTextColor: UIColor = UIColor.white {
        didSet {
            reloadStyles()
        }
    }
    @IBInspectable open var titleLineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
        didSet {
        }
    }
    @IBInspectable open var paddingY: CGFloat = 2 {
        didSet {
//            titleEdgeInsets.top = paddingY
//            titleEdgeInsets.bottom = paddingY
        }
    }
    @IBInspectable open var paddingX: CGFloat = 5 {
        didSet {
        }
    }

    @IBInspectable open var tagBackgroundColor: UIColor = UIColor.gray {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var highlightedBackgroundColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var selectedBorderColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable open var selectedBackgroundColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    var textFont: UIFont = AppFont.fontWithType(.regular, size: 14) {
        didSet {
            label.font = textFont
        }
    }
    
    private func reloadStyles() {

        backgroundColor = tagBackgroundColor
        label.layer.borderColor = borderColor?.cgColor
        label.textColor = textColor
    }

    
    // MARK: remove button
    let removeButton = CloseButton()
    
    @IBInspectable open var enableRemoveButton: Bool = false {
        didSet {
            removeButton.isHidden = !enableRemoveButton
        }
    }
    
    @IBInspectable open var allowSelectLabel: Bool = false {
        didSet {
            if !enableRemoveButton {
                let tapPress = UITapGestureRecognizer(target: self, action: #selector(self.tapPress))
                label.addGestureRecognizer(tapPress)
            }
        }
    }
    
    @IBInspectable open var allowSelectLabelWithoutRemoveButton: Bool = false {
        didSet {
            if !enableRemoveButton {
                let tapPress = UITapGestureRecognizer(target: self, action: #selector(self.tapPress))
                label.addGestureRecognizer(tapPress)
            }
        }
    }
    
    @IBInspectable open var removeButtonIconSize: CGFloat = 10 {
        didSet {
            removeButton.iconSize = removeButtonIconSize
        }
    }
    
    @IBInspectable open var removeIconLineWidth: CGFloat = 3 {
        didSet {
            removeButton.lineWidth = removeIconLineWidth
        }
    }
    @IBInspectable open var removeIconLineColor: UIColor = UIColor.white.withAlphaComponent(0.54) {
        didSet {
            removeButton.lineColor = AppColor.colorTextField()
        }
    }
    
    /// Handles Tap (TouchUpInside)
    open var onTap: ((TagView) -> Void)?
    open var onLongPress: ((TagView) -> Void)?
    
    // MARK: - init
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    public init(title: String, tagId: Int) {
        super.init(frame: CGRect.zero)
        label.text = title
        self.tagId = tagId
        setupView()
    }
    
    private func setupView() {
        label.frame = CGRect.init(x: 0, y: 0, width: intrinsicContentSize.width, height: intrinsicContentSize.height)
        label.textColor = textColor
        label.font = textFont
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        addSubview(label)
        frame.size = intrinsicContentSize
        addSubview(removeButton)
        removeButton.frame.origin.x = label.frame.origin.x + label.frame.size.width
        removeButton.tagView = self
        removeButton.setImage(UIImage.init(named: "closeGrey"), for: .normal)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        self.addGestureRecognizer(longPress)
    }
    
    @objc func longPress() {
        onLongPress?(self)
    }
    
    @objc func tapPress() {
        onTap?(self)
        if allowSelectLabel {
            enableRemoveButton = true
        }

        frame.size = intrinsicContentSize
    }
    
    // MARK: - layout
    override open var intrinsicContentSize: CGSize {
        var size = CGSize(width: (label.text?.width(withConstraintedHeight: 32, font: textFont))!, height:32)
        
        size.height = 32 //textFont.pointSize + paddingY * 2
        size.width += paddingX * 2
        if size.width < size.height {
            size.width = size.height
        }
        
//        if enableRemoveButton {
//            size.width += removeButtonIconSize + paddingX
//        }
        
//        if size.width < 70 {
//            size.width = 80
//        }
        
        if size.width > UIScreen.main.bounds.width - 30 {
            size.width = UIScreen.main.bounds.width - 30
        }
        if enableRemoveButton {
            size.width += removeButtonIconSize + paddingX
            frame.size = CGSize(width: size.width, height: size.height)
        }
        return size
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if enableRemoveButton {
            removeButton.frame.size.width = 20//paddingX + removeButtonIconSize + paddingX
            removeButton.frame.origin.x = label.frame.origin.x + label.frame.size.width + 1
            removeButton.frame.size.height = 20
            removeButton.frame.origin.y = (self.frame.height - removeButton.frame.height)/2
        }
    }
}
