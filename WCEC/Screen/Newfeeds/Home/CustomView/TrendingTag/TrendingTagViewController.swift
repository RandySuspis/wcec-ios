//
//  TrendingTagViewController.swift
//  WCEC
//
//  Created by GEM on 3/26/19.
//  Copyright © 2019 hnc. All rights reserved.
//

import UIKit

protocol TrendingTagViewControllerDelegate: NSObjectProtocol {
    func trendingTagViewController(trendingTagsSelected : [SubCategoryModel])
}
class TrendingTagViewController: BaseViewController {

    @IBOutlet weak var trendingTagView: TagListView!
    weak var delegate: TrendingTagViewControllerDelegate?
    var trendingTags = [SubCategoryModel]()
    var trendingTagsSelected = [SubCategoryModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func setupLocalized() {
        self.navigationItem.title = "Trending now".localized()
    }

    override func setupView() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.doneBarButton(target: self, selector: #selector(onDone))

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp(_:)))
        swipeGesture.direction = .up
        view.addGestureRecognizer(swipeGesture)

        trendingTagView.delegateTag = self

        for tag in self.trendingTags {
            self.trendingTagView.addTag(tag.name, tag.id, tag.type)
        }

        for selectedTag in self.trendingTagsSelected {
            for trendingTag in trendingTagView.tagViews {
                if trendingTag.tagId == selectedTag.id &&
                    trendingTag.label.text == selectedTag.name &&
                    trendingTag.tagType == selectedTag.type {
                    trendingTag.label.layer.borderColor = AppColor.colorBorderRustyOrange().cgColor
                    trendingTag.enableRemoveButton = true
                    break
                }
            }
        }
    }

    @objc func onDone() {
        dismiss()
    }

    @IBAction func swipeUp(_ gesture: UIPanGestureRecognizer) {
        dismiss()
    }

    func dismiss() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false) {
            var trendingTagsSelected = [SubCategoryModel]()
            self.trendingTagView.tagViews.forEach({
                if $0.enableRemoveButton {
                    let tagId = $0.tagId
                    let tagName = $0.label.text
                    self.trendingTags.forEach({
                        if $0.id == tagId && $0.name == tagName {
                            trendingTagsSelected.append($0)
                        }
                    })
                }
            })
            self.delegate?.trendingTagViewController(trendingTagsSelected: trendingTagsSelected)
        }
    }
}

extension TrendingTagViewController: TagListViewDelegate {

    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.label.backgroundColor = UIColor.clear
    }

    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        guard !tagView.enableRemoveButton else {
            return
        }
    }
}
