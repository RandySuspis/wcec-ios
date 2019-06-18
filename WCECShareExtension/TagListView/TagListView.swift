//
//  TagListView.swift
//  TagListViewDemo
//
//  Created by Dongyuan Liu on 2015-05-09.
//  Copyright (c) 2015 Ela. All rights reserved.
//

import UIKit

@objc public protocol TagListViewDelegate {
    @objc optional func tagPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
    @objc optional func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
}

@IBDesignable
open class TagListView: UIScrollView {
    @IBInspectable open dynamic var scrollVertical: Bool = false {
        didSet {
            rearrangeViews()
        }
    }
    
    @IBInspectable open dynamic var textColor: UIColor = UIColor.white {
        didSet {
            for tagView in tagViews {
                tagView.textColor = textColor
            }
        }
    }
    
    @IBInspectable open dynamic var selectedTextColor: UIColor = UIColor.white {
        didSet {
            for tagView in tagViews {
                tagView.selectedTextColor = selectedTextColor
            }
        }
    }
    
    @IBInspectable open dynamic var tagLineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
        didSet {
            for tagView in tagViews {
                tagView.titleLineBreakMode = tagLineBreakMode
            }
        }
    }
    
    @IBInspectable open dynamic var tagBackgroundColor: UIColor = UIColor.gray {
        didSet {
            for tagView in tagViews {
                tagView.tagBackgroundColor = tagBackgroundColor
            }
        }
    }
    
    @IBInspectable open dynamic var tagHighlightedBackgroundColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
            }
        }
    }
    
    @IBInspectable open dynamic var tagSelectedBackgroundColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.selectedBackgroundColor = tagSelectedBackgroundColor
            }
        }
    }
    
    @IBInspectable open dynamic var cornerRadius: CGFloat = 0 {
        didSet {
            for tagView in tagViews {
                tagView.cornerRadius = cornerRadius
            }
        }
    }
    @IBInspectable open dynamic var borderWidth: CGFloat = 0 {
        didSet {
            for tagView in tagViews {
                tagView.borderWidth = borderWidth
            }
        }
    }
    
    @IBInspectable open dynamic var borderColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.borderColor = borderColor
            }
        }
    }
    
    @IBInspectable open dynamic var selectedBorderColor: UIColor? {
        didSet {
            for tagView in tagViews {
                tagView.selectedBorderColor = selectedBorderColor
            }
        }
    }
    
    @IBInspectable open dynamic var paddingY: CGFloat = 2 {
        didSet {
            for tagView in tagViews {
                tagView.paddingY = paddingY
            }
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var paddingX: CGFloat = 5 {
        didSet {
            for tagView in tagViews {
                tagView.paddingX = paddingX
            }
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var marginY: CGFloat = 2 {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var marginX: CGFloat = 5 {
        didSet {
            rearrangeViews()
        }
    }
    
    @objc public enum Alignment: Int {
        case left
        case center
        case right
    }
    @IBInspectable open var alignment: Alignment = .left {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var shadowColor: UIColor = UIColor.white {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var shadowRadius: CGFloat = 0 {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var shadowOffset: CGSize = CGSize.zero {
        didSet {
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var shadowOpacity: Float = 0 {
        didSet {
            rearrangeViews()
        }
    }
    
    @IBInspectable open dynamic var enableRemoveButton: Bool = false {
        didSet {
            for tagView in tagViews {
                tagView.enableRemoveButton = enableRemoveButton
            }
            rearrangeViews()
        }
    }
    
    @IBInspectable open dynamic var allowSelectLabel: Bool = false {
        didSet {
            for tagView in tagViews {
                tagView.allowSelectLabel = allowSelectLabel
            }
            rearrangeViews()
        }
    }
    
    @IBInspectable open var allowSelectLabelWithoutRemoveButton: Bool = false {
        didSet {
            for tagView in tagViews {
                tagView.allowSelectLabelWithoutRemoveButton = allowSelectLabelWithoutRemoveButton
            }
            rearrangeViews()
        }
    }
    
    @IBInspectable open dynamic var removeButtonIconSize: CGFloat = 12 {
        didSet {
            for tagView in tagViews {
                tagView.removeButtonIconSize = removeButtonIconSize
            }
            rearrangeViews()
        }
    }
    @IBInspectable open dynamic var removeIconLineWidth: CGFloat = 1 {
        didSet {
            for tagView in tagViews {
                tagView.removeIconLineWidth = removeIconLineWidth
            }
            rearrangeViews()
        }
    }
    
    @IBInspectable open dynamic var removeIconLineColor: UIColor = UIColor.white.withAlphaComponent(0.54) {
        didSet {
            for tagView in tagViews {
                tagView.removeIconLineColor = removeIconLineColor
            }
            rearrangeViews()
        }
    }
    
    @objc open dynamic var textFont: UIFont = AppFont.fontWithType(.regular, size: 14) {
        didSet {
            for tagView in tagViews {
                tagView.textFont = textFont
            }
            rearrangeViews()
        }
    }
    
    @IBOutlet open weak var delegateTag: TagListViewDelegate?
    
    open private(set) var tagViews: [TagView] = []
    private(set) var tagBackgroundViews: [UIView] = []
    private(set) var rowViews: [UIView] = []
    private(set) var tagViewHeight: CGFloat = 0
    private(set) var tagViewWidth: CGFloat = 0
    private(set) var rows = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Interface Builder
    
    open override func prepareForInterfaceBuilder() {
        //        addTag("Welcome")
        //        addTag("to")
        //        addTag("TagListView").isSelected = true
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        rearrangeViews()
    }
    
    private func rearrangeViews() {
        if scrollVertical {
            let views = tagViews as [UIView] + tagBackgroundViews + rowViews
            for view in views {
                view.removeFromSuperview()
            }
            rowViews.removeAll(keepingCapacity: true)
            
            var currentRow = 0
            var currentRowView: UIView!
            var currentRowTagCount = 0
            var currentRowWidth: CGFloat = 0
            for (index, tagView) in tagViews.enumerated() {
                tagView.frame.size = tagView.intrinsicContentSize
                tagViewHeight = tagView.frame.height
                
                if currentRowTagCount == 0 || currentRowWidth + tagView.frame.width > frame.width {
                    currentRow += 1
                    currentRowWidth = 0
                    currentRowTagCount = 0
                    currentRowView = UIView()
                    currentRowView.frame.origin.y = CGFloat(currentRow - 1) * (tagViewHeight + marginY)
                    
                    rowViews.append(currentRowView)
                    addSubview(currentRowView)
                    
                    tagView.frame.size.width = min(tagView.frame.size.width, frame.width)
                }
                
                let tagBackgroundView = tagBackgroundViews[index]
                tagBackgroundView.frame.origin = CGPoint(x: currentRowWidth, y: 0)
                tagBackgroundView.frame.size = tagView.bounds.size
                tagBackgroundView.layer.shadowColor = shadowColor.cgColor
                tagBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: tagBackgroundView.bounds, cornerRadius: cornerRadius).cgPath
                tagBackgroundView.layer.shadowOffset = shadowOffset
                tagBackgroundView.layer.shadowOpacity = shadowOpacity
                tagBackgroundView.layer.shadowRadius = shadowRadius
                tagBackgroundView.addSubview(tagView)
                currentRowView.addSubview(tagBackgroundView)
                
                currentRowTagCount += 1
                currentRowWidth += tagView.frame.width + marginX
                
                switch alignment {
                case .left:
                    currentRowView.frame.origin.x = 0
                case .center:
                    currentRowView.frame.origin.x = (frame.width - (currentRowWidth - marginX)) / 2
                case .right:
                    currentRowView.frame.origin.x = frame.width - (currentRowWidth - marginX)
                }
                currentRowView.frame.size.width = currentRowWidth
                currentRowView.frame.size.height = max(tagViewHeight, currentRowView.frame.height)
            }
            rows = currentRow
            
            invalidateIntrinsicContentSize()
        } else {
            let views = tagViews as [UIView] + tagBackgroundViews + rowViews
            for view in views {
                view.removeFromSuperview()
                tagViewWidth = 0
            }
            rowViews.removeAll(keepingCapacity: true)
            
            var currentRow = 0
            var currentRowView: UIView!
            var currentRowTagCount = 0
            var currentRowWidth: CGFloat = 0
            for (index, tagView) in tagViews.enumerated() {
                tagView.frame.size = tagView.intrinsicContentSize
                tagViewHeight = tagView.frame.height
                
                currentRow += 1
                currentRowWidth = 0
                currentRowTagCount = 0
                currentRowView = UIView()
                currentRowView.frame.origin.y = 0 //CGFloat(currentRow - 1) * (tagViewHeight + marginY)
                if index == 0 {
                    currentRowView.frame.origin.x = 0
                } else {
                    currentRowView.frame.origin.x = tagViewWidth + marginX
                }
                
                rowViews.append(currentRowView)
                addSubview(currentRowView)
                
                tagView.frame.size.height = min(tagView.frame.size.height, frame.height)
                
                let tagBackgroundView = tagBackgroundViews[index]
                tagBackgroundView.frame.origin = CGPoint(x: 0, y: 0)
                tagBackgroundView.frame.size = tagView.bounds.size
                tagBackgroundView.layer.shadowColor = shadowColor.cgColor
                tagBackgroundView.layer.shadowPath = UIBezierPath(roundedRect: tagBackgroundView.bounds, cornerRadius: cornerRadius).cgPath
                tagBackgroundView.layer.shadowOffset = shadowOffset
                tagBackgroundView.layer.shadowOpacity = shadowOpacity
                tagBackgroundView.layer.shadowRadius = shadowRadius
                tagBackgroundView.addSubview(tagView)
                currentRowView.addSubview(tagBackgroundView)
                
                currentRowTagCount += 1
                currentRowWidth += tagView.frame.width + marginX
                tagViewWidth += tagView.frame.width + marginX
                
                currentRowView.frame.size.width = max(tagViewWidth, currentRowView.frame.width)
                currentRowView.frame.size.height = max(tagViewHeight, currentRowView.frame.height)
            }
            rows = currentRow
            invalidateIntrinsicContentSize()
        }
        
    }
    
    // MARK: - Manage tags
    override open var intrinsicContentSize: CGSize {
        if scrollVertical {
            var height = CGFloat(rows) * (tagViewHeight + marginY)
            if rows > 0 {
                height -= marginY
            }
            self.contentSize = CGSize.init(width: frame.width, height: height)
            //        self.scrollRectToVisible(CGRect.init(origin: CGPoint.init(x: 0, y: self.contentSize.height - 40), size: self.contentSize), animated: false)
            if height > 100 {
                height = 100
            }
            return CGSize(width: frame.width, height: height)
        } else {
            let width = tagViewWidth + marginX
            
            self.contentSize = CGSize.init(width: width, height: frame.height)
            
            return CGSize(width: width, height: frame.height)
        }
        
    }
    
    private func createNewTagView(_ title: String, _ tagId: Int) -> TagView {
        let tagView = TagView(title: title, tagId: tagId)
        tagView.textColor = textColor
        tagView.selectedTextColor = selectedTextColor
        tagView.tagBackgroundColor = tagBackgroundColor
        tagView.highlightedBackgroundColor = tagHighlightedBackgroundColor
        tagView.selectedBackgroundColor = tagSelectedBackgroundColor
        tagView.titleLineBreakMode = tagLineBreakMode
        tagView.cornerRadius = cornerRadius
        tagView.borderWidth = borderWidth
        tagView.borderColor = borderColor
        tagView.selectedBorderColor = selectedBorderColor
        tagView.paddingX = paddingX
        tagView.paddingY = paddingY
        tagView.textFont = textFont
        tagView.removeIconLineWidth = removeIconLineWidth
        tagView.removeButtonIconSize = removeButtonIconSize
        tagView.enableRemoveButton = enableRemoveButton
        tagView.allowSelectLabel = allowSelectLabel
        tagView.removeIconLineColor = removeIconLineColor
        tagView.removeButton.addTarget(self, action: #selector(removeButtonPressed(_:)), for: .touchUpInside)
        
        // On long press, deselect all tags except this one
//        tagView.onLongPress = { [unowned self] this in
//                        for tag in self.tagViews {
//                            tag.isSelected = (tag == this)
//                        }
//        }
        
        tagView.onTap = {[unowned self] this in
            tagView.label.layer.borderColor = AppColor.colorBorderRustyOrange().cgColor
            if self.allowSelectLabelWithoutRemoveButton {
                self.delegateTag?.tagPressed?(tagView.label.text ?? "", tagView: tagView, sender: self)
            }
            self.rearrangeViews()
        }
        
        return tagView
    }
    
    @discardableResult
    open func addTag(_ title: String, _ tagId: Int) -> TagView {
        return addTagView(createNewTagView(title, tagId))
    }
    
    //    @discardableResult
    //    open func addTags(_ titles: [String]) -> [TagView] {
    //        var tagViews: [TagView] = []
    //        for title in titles {
    //            tagViews.append(createNewTagView(title))
    //        }
    //        return addTagViews(tagViews)
    //    }
    
    //    @discardableResult
    //    open func addTagViews(_ tagViews: [TagView]) -> [TagView] {
    //        for tagView in tagViews {
    //            self.tagViews.append(tagView)
    //            tagBackgroundViews.append(UIView(frame: tagView.bounds))
    //        }
    //        rearrangeViews()
    //        return tagViews
    //    }
    
    //    @discardableResult
    //    open func insertTag(_ title: String, at index: Int) -> TagView {
    //        return insertTagView(createNewTagView(title), at: index)
    //    }
    
    @discardableResult
    open func addTagView(_ tagView: TagView) -> TagView {
        tagViews.append(tagView)
        tagBackgroundViews.append(UIView(frame: tagView.bounds))
        rearrangeViews()
        //        if self.contentSize.height > self.bounds.size.height {
        //            let bottomOffset = CGPoint.init(x: 0, y: self.contentSize.height - self.bounds.size.height + 38)
        //            self.setContentOffset(bottomOffset, animated: false)
        //        }
        if self.contentSize.width > self.bounds.size.width {
            let bottomOffset = CGPoint.init(x: self.contentSize.width - self.bounds.size.width, y: 0)
            self.setContentOffset(bottomOffset, animated: false)
        }
        
        return tagView
    }
    
    @discardableResult
    open func insertTagView(_ tagView: TagView, at index: Int) -> TagView {
        tagViews.insert(tagView, at: index)
        tagBackgroundViews.insert(UIView(frame: tagView.bounds), at: index)
        rearrangeViews()
        
        return tagView
    }
    
    open func setTitle(_ title: String, at index: Int) {
        tagViews[index].label.text = title
    }
    
    open func removeTag(_ title: String) {
        // loop the array in reversed order to remove items during loop
        for index in stride(from: (tagViews.count - 1), through: 0, by: -1) {
            let tagView = tagViews[index]
            if tagView.label.text == title {
                removeTagView(tagView)
            }
        }
    }
    
    open func removeTagView(_ tagView: TagView) {
        tagView.removeFromSuperview()
        if let index = tagViews.index(of: tagView) {
            tagViews.remove(at: index)
            tagBackgroundViews.remove(at: index)
        }
        
        rearrangeViews()
    }
    
    open func removeTagViewById(_ tagID: Int) {
        for index in stride(from: (tagViews.count - 1), through: 0, by: -1) {
            let tagView = tagViews[index]
            if tagView.tagId == tagID {
                removeTagView(tagView)
            }
        }
    }
    
    open func removeAllTags() {
        let views = tagViews as [UIView] + tagBackgroundViews
        for view in views {
            view.removeFromSuperview()
        }
        tagViews = []
        tagBackgroundViews = []
        rearrangeViews()
    }
    
    //    open func selectedTags() -> [TagView] {
    //        return tagViews.filter() { $0.isSelected == true }
    //    }
    
    // MARK: - Events
    
    @objc func tagPressed(_ sender: UITapGestureRecognizer, view: TagView) {
        
    }
    
    @objc func removeButtonPressed(_ closeButton: CloseButton!) {
        if let tagView = closeButton.tagView {
            if tagView.enableRemoveButton == true && tagView.label.gestureRecognizers != nil{
                tagView.label.layer.borderColor = AppColor.colorWarmGrey().cgColor
                tagView.enableRemoveButton = false
                tagView.frame.size = tagView.intrinsicContentSize
                self.rearrangeViews()
            }
            delegateTag?.tagRemoveButtonPressed?(tagView.label.text ?? "", tagView: tagView, sender: self)
        }
    }
}

