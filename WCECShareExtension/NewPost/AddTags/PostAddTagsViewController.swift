//
//  PostAddTagsViewController.swift
//  WCEC
//
//  Created by hnc on 6/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class PostAddTagsViewController: BaseViewController {
    @IBOutlet weak var selectedTagsTitleLabel: UILabel!
    @IBOutlet weak var notHaveSelectedTagsLabel: UILabel!
    @IBOutlet weak var selectedTagsView: TagListView!
    @IBOutlet weak var searchTagsLabel: UILabel!
    @IBOutlet weak var suggestedTagsTitleLabel: UILabel!
    @IBOutlet weak var suggestedTagsView: TagListView!
    
    var selectedTags = [SubCategoryModel]()
    let newsfeedService = NewsfeedService()
    var suggetedTags = [SubCategoryModel]()
    let newPostViewModel = NewPostViewModel.shareInstance
    var listGallery = [String]()
    
    let mediaService = MediaService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        selectedTags = newPostViewModel.selectedTags
        for item in selectedTags {
            selectedTagsView.addTag(item.name, item.id)
        }
        reloadView()
        getSuggestedTags()
    }
    
    func setupUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.postBarButton(target: self, selector: #selector(onSelectPost))
        selectedTagsView.delegateTag = self
        suggestedTagsView.delegateTag = self
    }
    
    @objc func onSelectPost() {
        if selectedTags.count == 0 {
            self.alertWithTitle("Alert".localized(), message: "Add at least one tag to help others see your post".localized())
            return
        }
        self.listGallery = [String]()
        var selectedIndustries = [String]()
        var selectedInterests = [String]()
        for tag in selectedTags {
            if tag.type == .interests {
                selectedInterests.append("\(tag.id)")
            } else if tag.type == .industries {
                selectedIndustries.append("\(tag.id)")
            }
        }
        self.showHud()
        if self.newPostViewModel.mediaType == .video && self.newPostViewModel.listGallery?.count != 0{
            self.mediaService.uploadVideo(videoData: self.newPostViewModel.videoData, { (result) in
                switch result {
                case .failure(let error):
                    self.hideHude()
                    if let errorDiction = error._userInfo as? NSDictionary {
                        self.alertWithTitle(errorDiction["title"] as? String, message: errorDiction["message"] as? String)
                    }
                case .success(let response):
                    self.createPost(content: self.newPostViewModel.content, industries: selectedIndustries, interests: selectedInterests, photos: [], videoId: "\(response.data.avatarId)", visibility: self.newPostViewModel.visibility)
                }
            })
        } else if self.newPostViewModel.mediaType == .image  && self.newPostViewModel.listGallery?.count != 0 {
            self.mediaService.uploadMultipleImage(images: self.newPostViewModel.listGallery as! [UIImage], { (result) in
                switch result {
                case .success( let response):
                    var listGalleryId = [String]()
                    for item in response.data {
                       listGalleryId.append("\(item.avatarId)")
                    }
                    self.createPost(content: self.newPostViewModel.content, industries: selectedIndustries, interests: selectedInterests, photos: listGalleryId, videoId: "", visibility: self.newPostViewModel.visibility)
                case .failure( let error):
                    self.hideHude()
                    self.alertWithError(error)
                }
            })
        } else {
            createPost(content: self.newPostViewModel.content, industries: selectedIndustries, interests: selectedInterests, photos: [], videoId: "", visibility: self.newPostViewModel.visibility)
        }
    }
    
    func createPost(content: String, industries:[String], interests:[String], photos:[String], videoId: String, visibility: Bool) {
        self.newsfeedService.createNewPost(content: content, listIndustryTag: industries, listInterestTag: interests, listPhoto: photos, videoId: videoId, visibility: visibility, complete: { (result) in
            self.hideHude()
            switch result {
            case .success( _):
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            case .failure( let error):
                self.alertWithError(error)
            }
        })
    }
    
    @IBAction func onSelectSearchTags(_ sender: Any) {
        let searchTagsVC = SearchTagsViewController()
        searchTagsVC.delegate = self
        searchTagsVC.searchCategoriesSelected = selectedTags
        self.navigationController?.pushViewController(searchTagsVC, animated: true)
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Add Tags".localized()
        selectedTagsTitleLabel.text = "Selected Tags".localized()
        suggestedTagsTitleLabel.text = "Suggested Tags".localized()
        searchTagsLabel.text = "Search tags...".localized()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PostAddTagsViewController {
    func getSuggestedTags() {
        self.showHud()
        newsfeedService.getSuggestedTags { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                self.suggetedTags = response.data
                for tag in self.suggetedTags {
                    self.suggestedTagsView.addTag(tag.name, tag.id)
                }
                self.reloadView()
            case .failure( let error):
                self.alertWithError(error)
            }
        }
    }
}

extension PostAddTagsViewController: SearchTagsDelegate {
    func didDoneChooseTags(viewController: SearchTagsViewController, tagsSelected: [SubCategoryModel]) {
        viewController.navigationController?.popViewController(animated: true)
        selectedTags = tagsSelected
        for item in tagsSelected {
            var isExist: Bool = false
            for tag in selectedTagsView.tagViews {
                if tag.label.text == item.name {
                    isExist = true
                    break
                }
            }
            if !isExist {
                selectedTagsView.addTag(item.name, item.id)
            }
        }
        reloadView()
    }
}

extension PostAddTagsViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
        for tag in suggestedTagsView.tagViews {
            if tag.tagId == tagView.tagId || tag.label.text == tagView.label.text {
                tag.label.layer.borderColor = AppColor.colorWarmGrey().cgColor
                break
            }
        }
        reloadView()
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        for tag in selectedTagsView.tagViews {
            if tag.tagId == tagView.tagId && tag.label.text == tagView.label.text {
                return
            }
        }
        
        selectedTagsView.addTag(title, tagView.tagId)
        for suggestTag in self.suggetedTags {
            if suggestTag.id == tagView.tagId && suggestTag.name == title {
                self.selectedTags.append(suggestTag)
            }
        }
        reloadView()
    }
    
    func reloadView() {
        if selectedTagsView.tagViews.count == 0 {
            notHaveSelectedTagsLabel.isHidden = false
        } else {
            notHaveSelectedTagsLabel.isHidden = true
        }
        
        for selectedTag in selectedTagsView.tagViews {
            for suggestedTag in suggestedTagsView.tagViews {
                if suggestedTag.tagId == selectedTag.tagId && suggestedTag.label.text == selectedTag.label.text {
                    suggestedTag.label.layer.borderColor = AppColor.colorBorderRustyOrange().cgColor
                    break
                }
            }
        }
    }
}
