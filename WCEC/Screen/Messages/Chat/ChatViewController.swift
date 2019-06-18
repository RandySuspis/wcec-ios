//
//  ChatViewController.swift
//  WCEC
//
//  Created by hnc on 6/28/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import PubNub
import SwiftyJSON
import Photos
import PhotosUI
import Kingfisher

protocol ChatViewControllerDelegate: class {
    func onClosedChannel(controller: ChatViewController)
}

class ChatViewController: UIViewController {
    @IBOutlet var inputBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var inputTextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var declineJoinView: UIView!
    @IBOutlet weak var notHaveContentLabel: UILabel!
    @IBOutlet weak var chatGroupNameLabel: UILabel!
    @IBOutlet weak var chatMembersLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var noLongerParticipant: UIView!
    @IBOutlet weak var noLongerLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    var isSendPubnubFail: Bool = false
    
    let imagePicker = UIImagePickerController()
    var currentUser: UserModel?
    var canSendLocation = true
    var channelModel: ChannelModel?
    var channelId: String = ""
    let chatService = ChatService()
    let mediaService = MediaService()
    var lastUserId: String = ""
    var viewModel = ChatViewModel()
    
    var stopMeasuringVelocity: Bool = false
    var isScrollingFast: Bool = false
    var lastOffset: CGPoint = CGPoint(x: 0, y: 0)
    var lastOffsetCapture: TimeInterval = 0
    var initialLoading: Bool = true
    var scrollLock: Bool = false
    var lastMessageHeight: CGFloat = 0
    var startTimeStamp: NSNumber = 0
    var endTimeStamp: NSNumber = 0
    
    let userService = UserService()
    
    var listDeviceTokens = [String]()
    weak var delegate: ChatViewControllerDelegate?
    
    //MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoading = true
        self.lastMessageHeight = 0
        self.scrollLock = false
        self.stopMeasuringVelocity = false
        
        setupView()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.hideKeyboard(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.layoutIfNeeded()
        getChannelDetail()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        guard let channel = channelModel else { return }
        guard noLongerParticipant.isHidden else { return }
        guard declineJoinView.isHidden else { return }
        self.registerDeviceTokenWithPubnub(String(channel.id))
        inputTextView.textContainer.maximumNumberOfLines = 3
        delegate?.onClosedChannel(controller: self)
    }
    
    func setupView() {
        noLongerLabel.text = "You can't send messages to this group because you're no longer a participant".localized()
        notHaveContentLabel.text = "Say something!".localized()
        
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UINib(nibName: SendMessageTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: SendMessageTableViewCell.nibName())
        tableView.register(UINib(nibName: SendImageMessageTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: SendImageMessageTableViewCell.nibName())
        tableView.register(UINib(nibName: ReceiveMessageTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: ReceiveMessageTableViewCell.nibName())
        tableView.register(UINib(nibName: AvatarReceiveMessageTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: AvatarReceiveMessageTableViewCell.nibName())
        tableView.register(UINib(nibName: ReceiveImageMessageTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: ReceiveImageMessageTableViewCell.nibName())
        tableView.register(UINib(nibName: AvatarReceiveImageTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: AvatarReceiveImageTableViewCell.nibName())
        tableView.register(UINib(nibName: DateSeperatorTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: DateSeperatorTableViewCell.nibName())
        tableView.rowHeight = UITableViewAutomaticDimension
        
        inputTextView.setLeftPaddingPoints(5)
    }
    
    func getChannelDetail() {
        self.showHud()
        
        if channelId == "" && channelModel != nil {
            channelId = "\(channelModel?.id.description ?? "")"
        }
        
        self.unRegisterDeviceTokenWithPubnub(channelId)
        
        chatService.getChannelDetail(channelId: channelId) { (result) in
            switch result {
            case .success(let response):
                self.channelModel = response.data
                self.channelId = "\(self.channelModel?.id.description ?? "")"
                self.setupData()
                
                NotificationCenter.default.post(name: .kRefreshListMessage,
                                                object: response.data,
                                                userInfo: nil)
            case .failure( let error):
                self.alertWithError(error)
            }
            self.hideHude()
        }
        getListDeviceToken()
    }
    
    func getListDeviceToken() {
        userService.getListDeviceToken { (result) in
            switch result {
            case .success(let response):
//                for token in response.data {
//                    self.listDeviceTokens.append(token.data(using: .utf8)!)
//                }
                self.listDeviceTokens = response.data
            case .failure(_):
                break
            }
        }
    }
    
    func getListMessage() {
        self.showHud()
        
        let leftChannelDate = Date.convertUTCToLocal(date: (channelModel?.leftChannelDate)!,
                                               fromFormat: "yyyy-MM-dd HH:mm:ss",
                                               toFormat: "yyyy-MM-dd HH:mm:ss")
        let clearHistoryDate = Date.convertUTCToLocal(date: (channelModel?.lastTimeClearHistory)!,
                                             fromFormat: "yyyy-MM-dd HH:mm:ss",
                                             toFormat: "yyyy-MM-dd HH:mm:ss")
        var leftChannelNum: Any?
        var clearHistoryNum: Any?
        if (leftChannelDate != nil) {
            leftChannelNum = leftChannelDate?.currentTimeInMiliseconds()
        }
        
        if (clearHistoryDate != nil) {
            clearHistoryNum = clearHistoryDate?.currentTimeInMiliseconds()
        }
        
        Constants.appDelegate.client.historyForChannel("\(channelModel?.id.description ?? "")", start: leftChannelNum as? NSNumber, end: clearHistoryNum as? NSNumber, limit: UInt(defaultChatLimit), withCompletion: { (result, error) in
            self.hideHude()
            self.initialLoading = false
            if error == nil {
                /**
                 Handle downloaded history using:
                 result.data.start - oldest message time stamp in response
                 result.data.end - newest message time stamp in response
                 result.data.messages - list of messages
                 */
                self.startTimeStamp = (result?.data.start)!
                self.endTimeStamp = (result?.data.end)!
                var items = [MessageModel]()
                for message in (result?.data.messages)! {
                    let json = JSON(message)
                    let messageDTO = MessageDTO(json)
                    let messageModel = MessageModel(messageDTO)
                    items.append(messageModel)
                }
                
                self.viewModel.parseData(items)
                self.tableView.reloadData()
                if self.viewModel.rows.count > 0 {
                    self.tableView.scrollToBottom()
                    self.notHaveContentLabel.isHidden = true
                } else {
                    self.notHaveContentLabel.isHidden = false
                }
            } else {
                self.alertView("Error".localized(), message: error?.description)
            }
        })
    }
    
    func loadMore() {
        let clearHistoryDate = Date.convertUTCToLocal(date: (channelModel?.lastTimeClearHistory)!,
                                                      fromFormat: "yyyy-MM-dd HH:mm:ss",
                                                      toFormat: "yyyy-MM-dd HH:mm:ss")
        var clearHistoryNum: Any?
        if (clearHistoryDate != nil) {
            clearHistoryNum = clearHistoryDate?.currentTimeInMiliseconds()
        }
        if clearHistoryNum != nil {
            let clearNum = 1000.0 * (clearHistoryNum as! NSNumber).doubleValue
            if startTimeStamp.compare(NSNumber(value: clearNum)) == .orderedAscending {
                return
            }
        }
        
        self.showHud()
        Constants.appDelegate.client.historyForChannel("\(channelModel?.id.description ?? "")", start: startTimeStamp, end: clearHistoryNum as? NSNumber, limit: UInt(defaultChatLimit), withCompletion: { (result, error) in
            self.hideHude()
            self.initialLoading = false
            if error == nil {
                if let list = result?.data.messages {
                    if self.startTimeStamp.compare((result?.data.start)!) != .orderedSame{
                        self.startTimeStamp = (result?.data.start)!
                    } else {
                        self.initialLoading = true
                        return
                    }
                    
                    self.endTimeStamp = (result?.data.end)!
                    var items = [MessageModel]()
                    for index in (0..<list.count).reversed() {
                        let message = list[index]
                        let json = JSON(message)
                        let messageDTO = MessageDTO(json)
                        let messageModel = MessageModel(messageDTO)
                        items.append(messageModel)
                        self.viewModel.doLoadMoreWithData(messageModel)
                        self.tableView.reloadData()
                    }
                    if list.count == 0 {
                        self.initialLoading = true
                    } else {
                        self.initialLoading = false
                    }
                }
            } else {
                self.alertView("Error".localized(), message: error?.description)
            }
        })
    }
    
    func subscribeChannel() {
        if (channelModel?.leftChannelDate.isEmpty)! {
            Constants.appDelegate.client.subscribeToChannels(["\(channelModel?.id.description ?? "")"], withPresence: true)
            Constants.appDelegate.client.addListener(self)
        }
    }
    
    func setupData() {
        chatGroupNameLabel.text = channelModel?.name
        var members: String = ""
        guard let listMember = channelModel?.members else { return }
        for index in 0..<listMember.count {
            let member = listMember[index]
            if member.id != DataManager.getCurrentUserModel()?.id {
                members.append(member.fullName + ", ")
            }
        }
        if members.count > 2 {
            members.removeLast()
            members.removeLast()
        }
        
        chatMembersLabel.text = members
        
        declineJoinView.isHidden = true
        inputBarView.isHidden = false
        
        if !(channelModel?.leftChannelDate.isEmpty)! {
            noLongerParticipant.isHidden = false
        } else {
            noLongerParticipant.isHidden = true
            for user in listMember {
                if user.id == DataManager.getCurrentUserModel()?.id {
                    if user.userChannelRoleType == .invitation {
                        declineJoinView.isHidden = false
                        inputBarView.isHidden = true
                        break
                    }
                }
            }
        }
        
        if declineJoinView.isHidden {
            subscribeChannel()
            self.getListMessage()
        }
    }
    
    //MARK: Action
    @IBAction func onSelectBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSelectInfo(_ sender: Any) {
        let infoVC = InfoMessagesViewController()
        infoVC.channelModel = self.channelModel
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    @IBAction func onSelectSendMsg(_ sender: Any) {
        if (inputTextView.text?.isEmpty)! {
            return
        }
        let listGallery = [String]()
        let random = randomNumber(inRange: 0...999999)
        let param = ["text": inputTextView.text!, "user_id": "\(DataManager.getCurrentUserModel()?.id.description ?? "")", "images": listGallery, "avatar": DataManager.getCurrentUserModel()?.avatar.file_url ?? "", "full_name":DataManager.getCurrentUserModel()?.fullName ?? "", "created_date": "\(Date().currentTimeInMiliseconds())", "identifier":random.description] as [String: Any]
        self.sendChat(param: param)
    }
    
    @IBAction func onSelectSendOtherOption(_ sender: Any) {
        view.endEditing(true)
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                let galleryVC = GalleryViewController()
                galleryVC.delegate = self
                galleryVC.isOnlyImage = true
                let navi = BaseNavigationController.init(rootViewController: galleryVC)
                navi.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(navi, animated: true, completion: nil)
                break
            default:
                self.showAlertGoToPhotoSetting()
                break
            }
        }
    }
    
    @IBAction func onSelectDecline(_ sender: Any) {
        alertButtonWithTitle("Confirm".localized(),
                             message: "Do you really want to decline this conversation".localized()) {
                                self.showHud()
                                self.chatService.declineChannel(channelId: "\(self.channelModel?.id.description ?? "")") { (result) in
                                    switch result {
                                    case .success( _):
                                        NotificationCenter.default.post(name: .kRefreshListMessage,
                                                                        object: nil,
                                                                        userInfo: nil)
                                        self.navigationController?.popViewController(animated: true)
                                    case .failure( let error):
                                        self.alertWithError(error)
                                    }
                                    self.hideHude()
                                }
        }
    }
    
    @IBAction func onSelectJoin(_ sender: Any) {
        self.showHud()
        chatService.joinChannel(channelId: "\(channelModel?.id.description ?? "")") { (result) in
            switch result {
            case .success(let response):
                self.channelModel = response.data
                self.setupData()
                NotificationCenter.default.post(name: .kRefreshListMessage,
                                                object: response.data,
                                                userInfo: nil)
            case .failure( let error):
                self.alertWithError(error)
            }
            self.hideHude()
        }
    }
    
    //MARK: NotificationCenter handlers
    @objc func hideKeyboard(notification: Notification) {
        DispatchQueue.main.async {
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    @objc func showKeyboard(notification: Notification) {
        if let keyboardInfo = notification.userInfo {
            let keyboardFrameBegin = keyboardInfo[UIKeyboardFrameEndUserInfoKey]
            let keyboardFrameBeginRect = (keyboardFrameBegin as! NSValue).cgRectValue
            DispatchQueue.main.async {
                self.bottomConstraint.constant = keyboardFrameBeginRect.size.height
                if self.viewModel.rows.count > 0 {
                    self.tableView.scrollToBottom()
                }
                
                self.view.layoutIfNeeded()
            }
        }
    }
}

//MARK: PubNub Event Listener
extension ChatViewController: PNObjectEventListener {
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        // Handle new message stored in message.data.message
        if message.data.channel != message.data.subscription {
            
            // Message has been received on channel group stored in message.data.subscription.
        } else {
            
            // Message has been received on channel stored in message.data.channel.
        }
        
        #if DEBUG
            DLog("Received message: \(message.data.message ?? "") on channel \(message.data.channel) " +
                "at \(message.data.timetoken)")
        #endif
        guard let chat = message.data.message else {
            return
        }
        let json = JSON(chat)
        let messageDTO = MessageDTO(json)
        let messageModel = MessageModel(messageDTO)
        
        if message.data.channel == channelModel?.id.description {
            if messageModel.removed.isEmpty {
                var isSameMessage = false
                for item in self.viewModel.rows {
                    let model = item.messageModel
                    if model.createdDate == messageModel.createdDate && model.identifier == model.identifier {
                        isSameMessage = true
                    }
                }
                if !isSameMessage {
                    self.viewModel.doUpdateData(messageModel)
                    self.tableView.reloadData()
                }
                
                if self.viewModel.rows.count > 0 {
                    self.tableView.scrollToBottom()
                    self.notHaveContentLabel.isHidden = true
                } else {
                    self.notHaveContentLabel.isHidden = false
                }
            } else {
                if messageModel.removed == "\(DataManager.getCurrentUserModel()?.id.description ?? "")" {
                    self.inputTextView.text = ""
                    self.view.endEditing(true)
                    self.noLongerParticipant.isHidden = false
                    Constants.appDelegate.client.unsubscribeFromChannels(["\(channelModel?.id.description ?? "")"], withPresence: true)
                    Constants.appDelegate.client.removeListener(self)
                }
            }
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = viewModel.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                 for: indexPath) as! BaseTableViewCell
        cell.selectionStyle = .none
        cell.bindingWithModel(rowModel)
        if let cell = cell as? AvatarReceiveMessageTableViewCell {
            cell.delegate = self
        }
        return cell
    }
}

extension ChatViewController: AvatarReceiveMessageTableViewCellDelegate {

    func avatarReceiveMessageTableViewCellDidSelectAvatar(url: String) {
        let vc = PhotoViewerViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.listPhoto = [url]
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(vc, animated: true, completion: nil)
        }
    }
}

extension ChatViewController: UITableViewDelegate {
    // MARK: UITableViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopMeasuringVelocity = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.stopMeasuringVelocity = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            if self.stopMeasuringVelocity == false {
                let currentOffset = scrollView.contentOffset
                let currentTime = NSDate.timeIntervalSinceReferenceDate
                
                let timeDiff = currentTime - self.lastOffsetCapture
                if timeDiff > 0.1 {
                    let distance = currentOffset.y - self.lastOffset.y
                    let scrollSpeedNotAbs = distance * 10 / 1000
                    let scrollSpeed = fabs(scrollSpeedNotAbs)
                    if scrollSpeed > 0.5 {
                        self.isScrollingFast = true
                    }
                    else {
                        self.isScrollingFast = false
                    }
                    
                    self.lastOffset = currentOffset
                    self.lastOffsetCapture = currentTime
                }
                
                if self.isScrollingFast {
//                    self.view.endEditing(true)
                }
            }
            
            if scrollView.contentOffset.y + scrollView.frame.size.height + self.lastMessageHeight < scrollView.contentSize.height {
                self.scrollLock = true
            }
            else {
                self.scrollLock = false
            }
            
            if scrollView.contentOffset.y == 0 {
                if self.viewModel.rows.count > 0 && self.initialLoading == false {
                    //load more here
                    self.loadMore()
                }
            }
        }
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let minTextViewHeight: CGFloat = 39
        let maxTextViewHeight: CGFloat = 60
        var height = ceil(textView.contentSize.height) // ceil to avoid decimal
        
        if (height < minTextViewHeight + 5) { // min cap, + 5 to avoid tiny height difference at min height
            height = minTextViewHeight
        }
        if (height > maxTextViewHeight) { // max cap
            height = maxTextViewHeight
        }
        
        if height != inputTextViewHeightConstraint.constant { // set when height changed
            inputTextViewHeightConstraint.constant = height // change the value of NSLayoutConstraint
            textView.setContentOffset(CGPoint.init(x: 0, y: height), animated: true)
        }
        
        if textView.text == "" {
            textView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        }
    }
    
}

extension ChatViewController: GalleryViewControllerDelegate {
    func didSelectGallery(controller: GalleryViewController, withTLPHAssets: [TLPHAsset], mediaType: PHAssetMediaType) {
        controller.dismiss(animated: true, completion: nil)
        var images = [UIImage]()
        for asset in withTLPHAssets {
            if let phAsset = asset.phAsset {
                images.append(convertImageFromAsset(asset: phAsset))
            }
            if asset == withTLPHAssets.last {
                self.showHud()
                self.mediaService.uploadMultipleImage(images: images, { (result) in
                    switch result {
                    case .success( let response):
                        var listGallery = [String]()
                        var listIdGallery = [Int]()
                        response.data.forEach({
                            listGallery.append("\($0.file_url)")
                            listIdGallery.append($0.avatarId)
                        })
                        let random = randomNumber(inRange: 0...999999)
                        let param = ["text": "", "user_id": "\(DataManager.getCurrentUserModel()?.id.description ?? "")", "images": listGallery, "avatar": DataManager.getCurrentUserModel()?.avatar.file_url ?? "", "full_name":DataManager.getCurrentUserModel()?.fullName ?? "", "created_date": "\(Date().currentTimeInMiliseconds())", "identifier":random.description] as [String : Any]
                        self.sendChat(param: param, listIdGallery: listIdGallery)
                    case .failure( let error):
                        self.alertWithError(error)
                    }
                    self.hideHude()
                })
            }
        }
    }
}

extension ChatViewController {
    
    func sendChat(param: [String: Any], listIdGallery: [Int] = []) {
        guard let currentUser = DataManager.getCurrentUserModel() else { return }
        let payloads: [String: Any] = ["pn_apns": ["aps" : ["alert" : "\(currentUser.fullName)" + " has sent you a message".localized()],
                                                   "custom": [ "a" : [
                                                    "id": channelModel?.id.description ?? "",
                                                    "user_id": DataManager.getCurrentUserModel()?.id.description ?? "",
                                                    "type": NotificationType.newMessage.rawValue
                                                    ]], "pn_exceptions": listDeviceTokens],
                                       "pn_gcm": ["data": [ "a" : [
                                                    "id": channelModel?.id.description ?? "",
                                                    "user_id": DataManager.getCurrentUserModel()?.id.description ?? "",
                                                    "type": NotificationType.newMessage.rawValue,
                                                    "title": "\(currentUser.fullName)" + " has sent you a message".localized()
                                                    ]], "pn_exceptions": listDeviceTokens]]
        sendButton.isEnabled = false
        Constants.appDelegate.client.publish(param, toChannel: "\(channelModel?.id.description ?? "")",
                             mobilePushPayload: payloads, withCompletion: { (status) in
                                self.sendButton.isEnabled = true
                                
                                if !status.isError {
                                    // Message successfully published to specified channel.
                                    self.chatService.sendMessageToChannel(channelId: "\(self.channelModel?.id.description ?? "")",
                                        message: self.inputTextView.text!,
                                        images: listIdGallery, pubnubTime: status.data.timetoken, complete: { (result) in
                                        
                                    })
                                    self.inputTextView.text = ""
                                    self.isSendPubnubFail = false
                                } else {
                                    let errorMessage = status.errorData.description
                                    if errorMessage.contains("Forbidden") {
                                        if self.isSendPubnubFail {
                                            self.alertWithTitle("Error".localized(), message: status.errorData.description)
                                        } else {
                                            self.grandAccess(param: param, listIdGallery: listIdGallery)
                                        }
                                    } else {
                                        self.alertWithTitle("Error".localized(), message: status.errorData.description)
                                    }
                                }
            })
    }
    
    func grandAccess(param: [String: Any], listIdGallery: [Int] = []) {
        self.isSendPubnubFail = true
        self.chatService.grandAccessManage(channelId: "\(channelModel?.id.description ?? "")", complete: { (result) in
            self.sendChat(param: param, listIdGallery: listIdGallery)
        })
    }
    
    //MARK: - Register Device Token with Pubnub
    
    func registerDeviceTokenWithPubnub(_ id: String) {
        guard let currentUser = DataManager.getCurrentUserModel() else { return }
        guard currentUser.push_notification else { return }
        
        Util.registerPubNubNotification(channelIds: [id], deviceTokenData: DataManager.deviceTokenData())
    }
    
    func unRegisterDeviceTokenWithPubnub(_ id: String) {
        Util.removePubNubNotification(channelIds: [id], deviceTokenData: DataManager.deviceTokenData())
    }
}
