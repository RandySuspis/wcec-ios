//
//  ProfileDetailViewModel.swift
//  WCEC
//
//  Created by hnc on 5/15/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class ProfileDetailViewModel: NSObject {
    var sections = [SectionModel]()
    var profileRow: [PBaseRowModel]
    var basicInfoMutualRows: [ProfileDetailRowModel]
    var basicInfoInterestRows: [ProfileDetailRowModel]
    var basicInfoIndustriesRows: [ProfileDetailRowModel]
    var basicInfoOccupationRows: [ProfileOccupationRowModel]
    var postInfoRows: [ProfileDetailRowModel]
    var user: UserModel?
    var userInterests: [SubCategoryModel]
    var userIndustries: [SubCategoryModel]
    var mutunalConnection = [UserModel]()
    var posts = [NewfeedModel]() {
        didSet {
            updateFollowTab(1)
        }
    }
    
    override init() {
        sections = []
        profileRow = []
        basicInfoMutualRows = []
        basicInfoInterestRows = []
        basicInfoIndustriesRows = []
        basicInfoOccupationRows = []
        userInterests = []
        userIndustries = []
        postInfoRows = []
    }
    
    func parseProfile(_ data: UserModel) {
        user = data
        profileRow = [PBaseRowModel]()
        let row = ProfileDetailRowModel(data, identifier: ProfileTableViewCell.nibName())
        row.note = TabProfile.basicInfo.rawValue
        profileRow.append(row) //type meaning relation between user login and user detail (friend/non-friend/request)
        let section = SectionModel(rows: profileRow) //SectionModel(rows: profileRow, header: headerSuggestion)
        sections.append(section)
        
        parseBasicInfoInterest(data)
        parseBasicInfoIndustries(data)
        parseBasicInfoCurrentOccupation(data)
    }
    
    func parseBasicInfoMutualFriend(_ data: [UserModel]) {
        guard let currentUser = DataManager.getCurrentUserModel() else { return }
        guard let user = user else { return }
        guard currentUser.id != user.id else { return }
        mutunalConnection = data
        let headerSuggestion = HeaderModel(title: "\(user.mutual_connections) " +
            (user.mutual_connections > 1 ? "mutual connections".localized():"mutual connection".localized()),
                                           identifier: ProfileHeaderView.nibName())
        basicInfoMutualRows = [ProfileDetailRowModel]()
        for item in data {
            basicInfoMutualRows.append(ProfileDetailRowModel(item, identifier: ProfileMutualTableViewCell.nibName()))
            if basicInfoMutualRows.count == 2 { break }
        }
        let section = SectionModel(rows: basicInfoMutualRows, header: headerSuggestion)
        sections.insert(section, at: 1)
    }
    
    func parseBasicInfoInterest(_ data: UserModel) {
        if let userInterest = data.listInterestsModel {
            userInterest.forEach({
                if let currentUser = DataManager.getCurrentUserModel() {
                    for id in currentUser.interests.components(separatedBy: ",") {
                        if id == String($0.id) {
                            $0.isSelected = true
                        }
                    }
                }
            })
            self.userInterests = userInterest
        }
        let header = HeaderModel(title: "Interests".localized(), identifier: ProfileHeaderView.nibName())
        basicInfoInterestRows = [ProfileDetailRowModel]()
        basicInfoInterestRows.append(ProfileDetailRowModel("", identifier: ProfileInterestsTableViewCell.nibName()))
        let section = SectionModel(rows: basicInfoInterestRows, header: header)
        sections.append(section)
    }
    
    func parseBasicInfoIndustries(_ data: UserModel) {
        if let userIndustries = data.listIndustriesModel {
            userIndustries.forEach({
                if let currentUser = DataManager.getCurrentUserModel() {
                    for id in currentUser.industries.components(separatedBy: ",") {
                        if id == String($0.id) {
                            $0.isSelected = true
                        }
                    }
                }
            })
            self.userIndustries = userIndustries
        }
        let headerSuggestion = HeaderModel(title: "Industries".localized(), identifier: ProfileHeaderView.nibName())
        basicInfoIndustriesRows = [ProfileDetailRowModel]()
        basicInfoIndustriesRows.append(ProfileDetailRowModel("", identifier: ProfileInterestsTableViewCell.nibName()))
        let section = SectionModel(rows: basicInfoIndustriesRows, header: headerSuggestion)
        sections.append(section)
    }
    
    func parseBasicInfoCurrentOccupation(_ data: UserModel) {
        let headerSuggestion = HeaderModel(title: "Current Occupation".localized(), identifier: ProfileHeaderView.nibName())
        basicInfoOccupationRows = [ProfileOccupationRowModel]()
        data.occupations.forEach({
            basicInfoOccupationRows.append(ProfileOccupationRowModel($0, identifier: OccupationTableViewCell.nibName()))
        })
        let section = SectionModel(rows: basicInfoOccupationRows, header: headerSuggestion)
        sections.append(section)
    }
    
    func addNewPost(_ model: NewfeedModel) {
        var currentPost = self.posts
        currentPost.insert(model, at: 0)
        self.posts = currentPost
        var identifier: String = ""
        switch model.post_type {
        case .text:
            if model.images.count == 0 {
                identifier = NewFeedNoAssetTableViewCell.nibName()
            } else {
                identifier = NewFeedPhotoTableViewCell.nibName()
            }
            break
        case .video:
            identifier = NewFeedVideoTableViewCell.nibName()
            break
        case .link:
            identifier = NewFeedEmbedLinkTableViewCell.nibName()
            break
        }
        sections[0].rows.insert(NewFeedRowModel(model, identifier: identifier), at: 1)
    }
    
    func updatePost(_ data: [NewfeedModel]) {
        var currentPost = self.posts
        currentPost.append(contentsOf: data)
        self.posts = currentPost
        data.forEach({
            var identifier: String = ""
            switch $0.post_type {
            case .text:
                if $0.images.count == 0 {
                    identifier = NewFeedNoAssetTableViewCell.nibName()
                } else {
                    identifier = NewFeedPhotoTableViewCell.nibName()
                }
                break
            case .video:
                identifier = NewFeedVideoTableViewCell.nibName()
                break
            case .link:
                identifier = NewFeedEmbedLinkTableViewCell.nibName()
                break
            }
            sections[0].rows.append(NewFeedRowModel($0, identifier: identifier))
        })
    }
    
    func updateFollowTab(_ index: Int) {
        sections[0].rows[0].note = index == 0 ? TabProfile.basicInfo.rawValue : TabProfile.posts.rawValue
        if index == 0 && sections.count == 1 {
            guard let userData = self.user else { return }
            sections[0].rows.removeLast(sections[0].rows.count - 1)
            self.parseBasicInfoMutualFriend(mutunalConnection)
            self.parseBasicInfoInterest(userData)
            self.parseBasicInfoIndustries(userData)
            self.parseBasicInfoCurrentOccupation(userData)
        } else if index == 1 && sections.count > 1 {
            sections.removeLast(sections.count - 1)
            posts.forEach({
                var identifier: String = ""
                switch $0.post_type {
                case .text:
                    if $0.images.count == 0 {
                        identifier = NewFeedNoAssetTableViewCell.nibName()
                    } else {
                        identifier = NewFeedPhotoTableViewCell.nibName()
                    }
                    break
                case .video:
                    identifier = NewFeedVideoTableViewCell.nibName()
                    break
                case .link:
                    identifier = NewFeedEmbedLinkTableViewCell.nibName()
                    break
                }
                sections[0].rows.append(NewFeedRowModel($0, identifier: identifier))
            })
        }
    }
    
    func updateCollapseDesc(index: Int) {
        var row: NewFeedRowModel?
        if let rowModel = sections[0].rows[index] as? NewFeedRowModel {
            row = rowModel
        }
        
        if row != nil {
            row!.isDescCollapse = !row!.isDescCollapse
            sections[0].rows[index] = row!
        }
    }
    
    func updateLike(index: Int) {
        var newRowModel: NewFeedRowModel?
        if let rowModel = sections[0].rows[index] as? NewFeedRowModel {
            newRowModel = rowModel
            newRowModel!.isLiked = !newRowModel!.isLiked
            if !newRowModel!.isLiked && newRowModel!.likeCount > 0 {
                newRowModel!.likeCount -= 1
            } else {
                newRowModel!.likeCount += 1
            }
        }
        if let newRowModel = newRowModel {
            sections[0].rows[index] = newRowModel
        }
    }
    
    func updateShare(index: Int) {
        var newRowModel: NewFeedRowModel?
        if let rowModel = sections[0].rows[index] as? NewFeedRowModel {
            newRowModel = rowModel
            newRowModel?.shareCount += 1
        }
        if let newRowModel = newRowModel {
            sections[0].rows[index] = newRowModel
        }
    }
    
    func deletePost(_ index: Int) {
        self.posts.remove(at: index - 1)
        self.sections[0].rows.remove(at: index)
    }
}









