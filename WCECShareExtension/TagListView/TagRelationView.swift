//
//  TagRelationView.swift
//  WCEC
//
//  Created by hnc on 6/12/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

@IBDesignable
open class TagRelationView: UIView {
    var label = UILabel()
    var button = UIButton()
    var tagId: Int = -1
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
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
        self.layer.borderColor = borderColor?.cgColor
        label.textColor = textColor
    }
    
    
    // MARK: remove button
    let mutualIcon = UIImageView()
    
    @IBInspectable open var enableMutualIcon: Bool = false {
        didSet {
            mutualIcon.isHidden = !enableMutualIcon
        }
    }
    
    @IBInspectable open var mutualIconSize: CGFloat = 10 {
        didSet {
            
        }
    }
    
    /// Handles Tap (TouchUpInside)
    open var onTap: ((TagRelationView) -> Void)?
    open var onLongPress: ((TagRelationView) -> Void)?
    
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
        addSubview(mutualIcon)
        mutualIcon.frame.origin.x = 0
        mutualIcon.image = #imageLiteral(resourceName: "mutual")
    }
    
    // MARK: - layout
    override open var intrinsicContentSize: CGSize {
        var size = CGSize(width: (label.text?.width(withConstraintedHeight: 32, font: textFont))!, height:32)
        
        size.height = 32 //textFont.pointSize + paddingY * 2
        size.width += paddingX * 2
        if size.width < size.height {
            size.width = size.height
        }
     
        self.layer.borderColor = borderColor?.cgColor
        if enableMutualIcon {
            size.width += mutualIconSize + 2*paddingX
            frame.size = CGSize(width: size.width, height: size.height)
            self.layer.borderColor = selectedBorderColor?.cgColor
        }
        return size
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if enableMutualIcon {
            mutualIcon.frame.size.width = 20//paddingX + removeButtonIconSize + paddingX
            mutualIcon.frame.origin.x = paddingX
            mutualIcon.frame.size.height = 20
            mutualIcon.frame.origin.y = (self.frame.height - mutualIcon.frame.height)/2
            label.frame.origin.x = mutualIconSize + 2*paddingX
        }
    }
}
