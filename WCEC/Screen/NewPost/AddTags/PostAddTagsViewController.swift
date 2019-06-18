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
    
    // MARK: - IBOutlet
    @IBOutlet weak var selectedTagsTitleLabel: UILabel!
    @IBOutlet weak var notHaveSelectedTagsLabel: UILabel!
    @IBOutlet weak var selectedTagsView: TagListView!
    @IBOutlet weak var searchTagsLabel: UILabel!
    @IBOutlet weak var suggestedTagsTitleLabel: UILabel!
    @IBOutlet weak var suggestedTagsView: TagListView!
    
    // MARK: - Variable
    var selectedTags = [SubCategoryModel]()
    let newsfeedService = NewsfeedService()
    var suggestedTags = [SubCategoryModel]()
    let newPostViewModel = NewPostViewModel.shareInstance
    var listGallery = [String]()
    let mediaService = MediaService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        selectedTags = newPostViewModel.selectedTags
        for item in selectedTags {
            selectedTagsView.addTag(item.name, item.id, item.type)
        }
        reloadView()
        getSuggestedTags()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        newPostViewModel.selectedTags = selectedTags
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup
    override func setupLocalized() {
        self.navigationItem.title = "Add Tags".localized()
        selectedTagsTitleLabel.text = "Selected Tags".localized()
        suggestedTagsTitleLabel.text = "Suggested Tags".localized()
        searchTagsLabel.text = "Search tags...".localized()
        notHaveSelectedTagsLabel.text = "Add at least one tag to help others see your post".localized()
    }
    
    func setupUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.postBarButton(target: self, selector: #selector(onSelectPost))
        selectedTagsView.delegateTag = self
        suggestedTagsView.delegateTag = self
    }
    
    // MARK: - Action
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
                    if self.newPostViewModel.model != nil {
                        self.editPost(content: self.newPostViewModel.content, industries: selectedIndustries, interests: selectedInterests, photos: [], videoId: "\(response.data.avatarId)", visibility: self.newPostViewModel.visibility)
                    } else {
                        self.createPost(content: self.newPostViewModel.content, industries: selectedIndustries, interests: selectedInterests, photos: [], videoId: "\(response.data.avatarId)", visibility: self.newPostViewModel.visibility)
                    }
                }
            })
        } else if self.newPostViewModel.mediaType == .image  && self.newPostViewModel.listGallery?.count != 0 {
            self.showHud()
            self.mediaService.uploadMultipleImage(images: self.newPostViewModel.listGallery as! [UIImage], { (result) in
                switch result {
                case .success( let response):
                    var listGalleryId = [String]()
                    for item in response.data {
                       listGalleryId.append("\(item.avatarId)")
                    }
                    if self.newPostViewModel.model != nil {
                        for file in self.newPostViewModel.currentMedia {
                            listGalleryId.append("\(file.avatarId)")
                        }
                        self.editPost(content: self.newPostViewModel.content, industries: selectedIndustries, interests: selectedInterests, photos: listGalleryId, videoId: "", visibility: self.newPostViewModel.visibility)
                    } else {
                        self.createPost(content: self.newPostViewModel.content, industries: selectedIndustries, interests: selectedInterests, photos: listGalleryId, videoId: "", visibility: self.newPostViewModel.visibility)
                    }
                case .failure( let error):
                    self.hideHude()
                    self.alertWithError(error)
                }
            })
        } else {
            if self.newPostViewModel.model != nil {
                var listGalleryId = [String]()
                for file in self.newPostViewModel.currentMedia {
                    listGalleryId.append("\(file.avatarId)")
                }
                editPost(content: self.newPostViewModel.content, industries: selectedIndustries, interests: selectedInterests, photos: listGalleryId, videoId: "", visibility: self.newPostViewModel.visibility)
            } else {
                createPost(content: self.newPostViewModel.content, industries: selectedIndustries, interests: selectedInterests, photos: [], videoId: "", visibility: self.newPostViewModel.visibility)
            }
        }
    }
    
    func createPost(content: String, industries:[String], interests:[String], photos:[String], videoId: String, visibility: Bool) {
        self.newsfeedService.createNewPost(content: content, listIndustryTag: industries, listInterestTag: interests, listPhoto: photos, videoId: videoId, visibility: visibility, complete: { (result) in
            self.hideHude()
            switch result {
            case .success( _):
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .kRefreshListNewfeed,
                                                object: nil,
                                                userInfo: nil)
            case .failure( let error):
                self.alertWithError(error)
            }
        })
    }
    
    func editPost(content: String, industries:[String], interests:[String], photos:[String], videoId: String, visibility: Bool) {
        self.newsfeedService.editPost(postId: "\(newPostViewModel.model?.id.description ?? "")", content: content, listIndustryTag: industries, listInterestTag: interests, listPhoto: photos, videoId: videoId, visibility: visibility) { (result) in
            switch result {
            case .success( _):
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .kRefreshListNewfeed,
                                                object: nil,
                                                userInfo: nil)
            case .failure( let error):
                self.alertWithError(error)
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func onSelectSearchTags(_ sender: Any) {
        let searchTagsVC = SearchTagsViewController()
        searchTagsVC.delegate = self
        searchTagsVC.searchCategoriesSelected = selectedTags
        self.navigationController?.pushViewController(searchTagsVC, animated: true)
    }
}

// MARK: - Extension
extension PostAddTagsViewController {
    func getSuggestedTags() {
        self.showHud()
        newsfeedService.getSuggestedTags { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                self.suggestedTags = response.data
                for tag in self.suggestedTags {
                    self.suggestedTagsView.addTag(tag.name, tag.id, tag.type)
                }
                self.reloadView()
            case .failure( let error):
                self.alertWithError(error)
            }
        }
    }
}

// MARK: - SearchTagsDelegate
extension PostAddTagsViewController: SearchTagsDelegate {
    func didDoneChooseTags(viewController: SearchTagsViewController, tagsSelected: [SubCategoryModel]) {
        viewController.navigationController?.popViewController(animated: true)
        selectedTags = tagsSelected
        selectedTagsView.removeAllTags()
        for item in tagsSelected {
            var isExist: Bool = false
            for tag in selectedTagsView.tagViews {
                if tag.label.text == item.name && tag.tagId == item.id && tag.tagType == item.type {
                    isExist = true
                    break
                }
            }
            if !isExist {
                selectedTagsView.addTag(item.name, item.id, item.type)
            }
        }
        reloadView()
    }
}

// MARK: - TagListViewDelegate
extension PostAddTagsViewController: TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
        for tag in suggestedTagsView.tagViews {
            if tag.tagId == tagView.tagId && tag.label.text == tagView.label.text && tag.tagType == tagView.tagType {
                tag.label.layer.borderColor = AppColor.colorWarmGrey().cgColor
                break
            }
        }
        
        for i in 0..<selectedTags.count {
            let tag = selectedTags[i]
            if tag.id == tagView.tagId && tag.name == tagView.label.text && tag.type == tagView.tagType {
                selectedTags.remove(at: i)
                break
            }
        }
        
        reloadView()
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        for tag in selectedTagsView.tagViews {
            if tag.tagId == tagView.tagId && tag.label.text == tagView.label.text && tag.tagType == tagView.tagType {
                return
            }
        }
        
        selectedTagsView.addTag(title, tagView.tagId, tagView.tagType)
        for suggestTag in self.suggestedTags {
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
        for tag in suggestedTagsView.tagViews {
            tag.label.layer.borderColor = AppColor.colorWarmGrey().cgColor
        }
        for selectedTag in selectedTagsView.tagViews {
            for suggestedTag in suggestedTagsView.tagViews {
                if suggestedTag.tagId == selectedTag.tagId && suggestedTag.label.text == selectedTag.label.text && suggestedTag.tagType == selectedTag.tagType {
                    suggestedTag.label.layer.borderColor = AppColor.colorBorderRustyOrange().cgColor
                    break
                }
            }
        }
    }
}
