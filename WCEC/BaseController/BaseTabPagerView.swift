//
//  BaseTabPagerView.swift
//  WCEC
//
//  Created by hnc on 5/7/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

protocol BaseTabPagerViewDelegate: NSObjectProtocol {
    func baseTabPagerView(_ baseTabPagerView: BaseTabPagerView, didSelectAt index: Int)
}

class BaseTabPagerView: UIView {
    var _selectBarView = UIView()
    let selectColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.87)
    let unselectColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
    var tabButtons = [UIButton]()
    var isButtonEqual = false
    weak var delegate: BaseTabPagerViewDelegate?
    let indicatorHeight:CGFloat = 2
    let selectIndicatorColor = AppColor.colorOrange()
    private var lockMove = true
    var currentSelected = 0 {
        willSet {
            if tabButtons.count != 0 {
                let old = tabButtons[currentSelected]
                old.setTitleColor(unselectColor, for: .normal)
            }
        }
        didSet {
            if tabButtons.count != 0 {
                let new = tabButtons[currentSelected]
                new.setTitleColor(selectColor, for: .normal)
                if !lockMove {
                    moveBarTo(currentSelected)
                }
            }
        }
    }
    weak var controller: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    // MARK: - Private Helper Methods
    // Performs the initial setup.
    private func initView() {
        let view = viewFromNibForClass()
        view.frame = bounds
        
        // Auto-layout stuff.
        view.autoresizingMask = [
            UIViewAutoresizing.flexibleWidth,
            UIViewAutoresizing.flexibleHeight
        ]
        
        // Show the view.
        addSubview(view)
        
        setupView()
    }
    
    // Loads a XIB file into a view and returns this view.
    private func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        /* Usage for swift < 3.x
         let bundle = NSBundle(forClass: self.dynamicType)
         let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
         let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
         */
        return view
    }
    
    func setupView() {
        lockMove = true
        currentSelected = 0
        lockMove = false
        tabButtons = tabButtonList()
        if tabButtons.count > 1 {
            let frame = tabButtons[0].frame
            _selectBarView.frame = CGRect(x: frame.origin.x,
                                          y: frame.origin.y + frame.height-indicatorHeight,
                                          width: isButtonEqual ?  (Constants.screenWidth / CGFloat(tabButtons.count)) : frame.size.width,
                                          height: indicatorHeight)
            _selectBarView.backgroundColor = selectIndicatorColor
            self.addSubview(_selectBarView)
            
            
            for index in 1...tabButtons.count-1 {
                tabButtons[index].setTitleColor(unselectColor, for: .normal)
            }
        }
        
    }
    
    func tabButtonList() -> [UIButton] {
        fatalError("")
    }
    
    
    private func moveBarTo(_ page: Int) {
        let sender = tabButtons[page]
        let frame = sender.frame
        UIView.animate(withDuration: 0.3, animations: {
            self._selectBarView.frame = CGRect(x: frame.origin.x, y: frame.origin.y + frame.height - self.indicatorHeight,
                                               width: frame.width, height: self.indicatorHeight)
        })
    }
    
    func moveTo(Page page: Int) {
        currentSelected = page
        delegate?.baseTabPagerView(self, didSelectAt: page)
    }
    
    func onButtonClick(_ sender: UIButton) {
        let index = tabButtons.index(of: sender) ?? 0
        currentSelected = index
        delegate?.baseTabPagerView(self, didSelectAt: index)
    }
}
