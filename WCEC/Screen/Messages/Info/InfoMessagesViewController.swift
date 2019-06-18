//
//  InfoMessagesViewController.swift
//  WCEC
//
//  Created by GEM on 6/27/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit

class InfoMessagesViewController: BaseViewController {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var tileTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearChatLabel: UILabel!
    @IBOutlet weak var exitGroupLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addParticipantContainer: UIView!
    @IBOutlet weak var editConversationContainer: UIView!
    
    fileprivate var refreshControl = UIRefreshControl()
    var viewModel = InfoMessagesViewModel()
    let chatService = ChatService()
    var currentPage: Int = 1
    var channelModel: ChannelModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Info".localized()
        clearChatLabel.text = "Clear Chat".localized()
        exitGroupLabel.text = "Exit Group".localized()
    }
    
    func setupUI() {
        titleTextView.isUserInteractionEnabled = false
        titleTextView.delegate = self
        tableView.register(UINib(nibName: ConnectionsTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: ConnectionsTableViewCell.nibName())
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @objc func getData() {
        self.showHud()
        chatService.getChannelDetail(channelId: "\(channelModel?.id.description ?? "")") { (result) in
            switch result {
            case .success(let response):
                self.channelModel = response.data
                self.setupData()
            case .failure( let error):
                self.alertWithError(error)
            }
            self.hideHude()
        }
    }
    
    func setupData() {
        titleTextView.text = channelModel?.name
        setTextViewHeight()
        guard let listMember = channelModel?.members else { return }
        
        participantsLabel.text = "\(listMember.count) " +
            (listMember.count > 1 ? "Participants".localized() : "Participant".localized())
        
        var isAdmin = false
        for user in listMember {
            if user.userChannelRoleType == .admin {
                if user.id == DataManager.getCurrentUserModel()?.id {
                    isAdmin = true
                    break
                }
            }
        }
        
        if (channelModel?.leftChannelDate.isEmpty)! {
            if isAdmin {
                self.viewModel.parseData(listMember, withType: .delete)
                self.addParticipantContainer.isHidden = false
                self.editConversationContainer.isHidden = false
            } else {
                self.viewModel.parseData(listMember, withType: .label)
                self.addParticipantContainer.isHidden = true
                self.editConversationContainer.isHidden = true
            }
            bottomView.isHidden = false
            bottomHeightConstraint.constant = 96
        } else {
            self.viewModel.parseData(listMember, withType: .label)
            bottomView.isHidden = true
            bottomHeightConstraint.constant = 0
            self.addParticipantContainer.isHidden = true
            self.editConversationContainer.isHidden = true
        }

        self.tableView.reloadData()
    }
    
    //MARK: Action
    @IBAction func onPressEdit(_ sender: Any) {
        if titleTextView.isUserInteractionEnabled {
            self.showHud()
            if titleTextView.text?.count == 0 {
                self.alertView("Alert".localized(), message: "Please input group name")
                return
            }
            
            self.titleTextView.isUserInteractionEnabled = false
            self.editImageView.image = UIImage.init(named: "edit")
            chatService.updateChannel(channelId: "\(channelModel?.id.description ?? "")", name: titleTextView.text!, complete: { (result) in
                self.hideHude()
                switch result {
                case .success(let response):
                    self.channelModel = response.data
                    NotificationCenter.default.post(name: .kRefreshListMessage,
                                                    object: response.data,
                                                    userInfo: nil)
                    self.setupData()
                case .failure( let error):
                    self.titleTextView.text = self.channelModel?.name
                    self.setTextViewHeight()
                    self.alertWithError(error)
                }
            })
        } else {
            titleTextView.isUserInteractionEnabled = true
            titleTextView.becomeFirstResponder()
            editImageView.image = UIImage.init(named: "check")
        }
    }
    
    @IBAction func onAdd(_ sender: Any) {
        guard let channelModel = channelModel else { return }
        let vc = NewMessagesViewController()
        vc.connectionAdded = channelModel.members
        vc.existChannelId = String(channelModel.id)
        vc.delegate = self
        self.hidesBottomBarWhenPushed = true
        self.pushViewControllerWithPresentAnimation(vc)
        self.hidesBottomBarWhenPushed = false
    }
    
    @IBAction func onSelectClearChat(_ sender: Any) {
        let popup = PopupClearChat.init(PopupClearChat.classString())
        popup.delegate = self
        self.present(popup, animated: true, completion: nil)
    }
    
    @IBAction func onSelectExitGroup(_ sender: Any) {
        let popup = PopupExitGroup.init(PopupExitGroup.classString())
        popup.delegate = self
        if let channelModel = channelModel {
            popup.conversationName = channelModel.name
        }
        self.present(popup, animated: true, completion: nil)
    }
}

extension InfoMessagesViewController: PopupExitGroupDelegate {
    
    func popupExitGroup() {
        self.showHud()
        self.chatService.leftChannel(channelId: "\(self.channelModel?.id.description ?? "")") { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                self.channelModel = response.data
                NotificationCenter.default.post(name: .kRefreshListMessage,
                                                object: nil,
                                                userInfo: nil)
                self.navigationController?.popViewController(animated: true)
                self.unRegisterDeviceTokenWithPubnub([String(response.data.id)])
            case .failure( let error):
                self.alertWithError(error)
            }
        }
    }
}

extension InfoMessagesViewController: PopupClearChatDelegate {
    
    func popupClearChat() {
        self.showHud()
        self.chatService.clearChatHistoryInChannel(channelId: "\(self.channelModel?.id.description ?? "")") { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                NotificationCenter.default.post(name: .kRefreshListMessage,
                                                object: nil,
                                                userInfo: nil)
                self.navigationController?.popViewController(animated: true)
            case .failure( let error):
                self.alertWithError(error)
            }
        }
    }
}

extension InfoMessagesViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        setTextViewHeight()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
        return numberOfChars < 255;
    }
    
    func setTextViewHeight() {
        let fixedWidth = titleTextView.frame.size.width
        titleTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = titleTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = titleTextView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        tileTextViewHeightConstraint.constant = newFrame.size.height
    }
}

extension InfoMessagesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows.count
    }
    
    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = viewModel.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                 for: indexPath) as! BaseTableViewCell
        cell.selectionStyle = .none
        cell.bindingWithModel(rowModel)
        if let cell = cell as? ConnectionsTableViewCell {
            cell.delegate = self
        }
        return cell
    }
    
}

extension InfoMessagesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowModel = viewModel.rows[indexPath.row]
        let profileDetailVC = ProfileDetailViewController()
        profileDetailVC.userId = rowModel.objectID
        self.navigationController?.pushViewController(profileDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = AppColor.colorPinkLow()
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
}

extension InfoMessagesViewController: NewMessagesViewControllerDelegate {
    
    func createNewGroupSuccess(_ viewController: BaseViewController, withChannelModel: ChannelModel) {
        viewController.dissmissPushViewControllerWithPresentAnimation()
        getData()
        NotificationCenter.default.post(name: .kRefreshListMessage,
                                        object: withChannelModel,
                                        userInfo: nil)
    }
}

extension InfoMessagesViewController: ConnectionsTableViewCellDelegate {

    func connectionsTableViewCellDidSelectAvatar(url: String) {
        openPhotoViewer([url])
    }
    
    func connectionsTableViewCell(_ cell: ConnectionsTableViewCell, didSelectActionButton sender: UIButton, type: RelationType) {
        alertButtonWithTitle("Confirm".localized(),
                            message: "Do you want to remove this user".localized(),
                            completion: {
                                guard let channelModel = self.channelModel else { return }
                                guard let indexPath = self.tableView.indexPath(for: cell) else { return }
                                self.showHud()
                                self.chatService.removeUserFromChannel(channelId: String(channelModel.id),
                                                                  removeUserId: self.viewModel.rows[indexPath.row].objectID) { (result) in
                                                                    self.hideHude()
                                                                    switch result {
                                                                    case .success(_):
                                                                        self.notifyRemovedUser(userId: self.viewModel.rows[indexPath.row].objectID)
                                                                        self.viewModel.rows.remove(at: indexPath.row)
                                                                        self.channelModel?.members.remove(at: indexPath.row)
                                                                        self.tableView.reloadData()
                                                                        
                                                                        break
                                                                    case .failure(let error):
                                                                        self.alertWithError(error)
                                                                        break
                                                                    }
                                }
        })
    }
    
    func notifyRemovedUser(userId: String) {
        let listGallery = [String]()
        let param = ["text": "", "user_id": "\(DataManager.getCurrentUserModel()?.id.description ?? "")", "images": listGallery, "avatar": DataManager.getCurrentUserModel()?.avatar.file_url ?? "", "full_name":DataManager.getCurrentUserModel()?.fullName ?? "", "created_date": "\(Date().currentTimeInMiliseconds())", "removed": userId] as [String: Any]
        Constants.appDelegate.client.publish(param, toChannel: "\(channelModel?.id.description ?? "")") { (status) in
            if !status.isError {
                // Message successfully published to specified channel.
            } else {
                self.alertWithTitle("Error".localized(), message: status.errorData.description)
            }
        }

    }
}






