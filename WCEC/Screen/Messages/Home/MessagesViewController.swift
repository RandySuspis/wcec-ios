//
//  MessagesViewController.swift
//  WCEC
//
//  Created by GEM on 5/11/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import PubNub
import SwiftyJSON

class MessagesViewController: BaseViewController {

    @IBOutlet weak var noConversationView: UIView!
    @IBOutlet weak var newConversationButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var refreshControl = UIRefreshControl()
    var currentPage = 1
    var openedChannelID = -1
    var viewModel = MessagesViewModel()
    var chatService = ChatService()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
        addNotificationCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Setup
    func setupUI() {
        addRefreshControl()
        addScrollToLoadMore()
        
        noConversationView.isHidden = true
        
        newConversationButton.layer.cornerRadius = 3.0
        newConversationButton.layer.masksToBounds = true
        
        tableView.register(UINib(nibName: MessageTableViewCell.nibName(), bundle: nil),
                           forCellReuseIdentifier: MessageTableViewCell.nibName())
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.plusBarButton(target: self, selector: #selector(onNewConversation))
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Messages".localized()
        descLabel.text = "Build up relationship with your connections!".localized()
        newConversationButton.setTitle("Start New Conversation".localized(), for: .normal)
    }
    
    // MARK: - Action
    func addNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshChannelModel(_:)),
                                               name: .kRefreshListMessage,
                                               object: nil)
    }
    
    @objc func refreshChannelModel(_ notification: NSNotification) {
        if (notification.object != nil) {
            let channel = notification.object as! ChannelModel
            for item in viewModel.rows {
                if item.channelModel?.id == channel.id {
                    
                }
            }
            
            for index in 0..<viewModel.rows.count {
                let item = viewModel.rows[index]
                if item.channelModel?.id == channel.id {
                    viewModel.rows.remove(at: index)
                    viewModel.addData(channel, index: index)
                    tableView.reloadRows(at:  [IndexPath.init(row: index, section: 0)], with: .automatic)
                    break
                }
            }
        } else {
            getData()
        }
        Constants.appDelegate.countNotificationBadge()
    }
    
    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(getData), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        tableView?.addSubview(refreshControl)
    }
    
    func addScrollToLoadMore() {
        weak var wself = self
        tableView?.addInfiniteScrolling(actionHandler: {
            wself?.getNextPage()
        })
        tableView?.showsInfiniteScrolling = false
    }
    
    @objc func getData() {
        self.showHud()
        currentPage = 1
        let pager = Pager(page: currentPage, per_page: Constants.kDefaultLimit)
        chatService.getListChannelMessage(pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.parseData(response.data)
                var channelIds = [String]()
                var isNew: Bool = false
                response.data.forEach({
                    channelIds.append("\($0.id.description)")
                    if $0.new {
                        isNew = true
                    }
                })
                if isNew {
                    Constants.appDelegate.tabbarController.addRedDotAtTabBarItem(atIndex: TabbarIndex.messageNav.rawValue)
                }
                if response.data.count < Constants.kDefaultLimit {
                    self.tableView.showsInfiniteScrolling = false
                } else {
                    self.tableView.showsInfiniteScrolling = true
                }
                
                if response.data.count == 0 {
                    self.noConversationView.isHidden = false
                } else {
                    self.noConversationView.isHidden = true
                }
                
                self.tableView.reloadData()
            case .failure( let error):
                self.alertWithError(error)
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.tableView?.infiniteScrollingView.stopAnimating()
            self.hideHude()
        }
        getChannelIds()
    }
    
    func getChannelIds() {
        Constants.appDelegate.client.addListener(self)
        chatService.getListChannelId { (result) in
            switch result {
            case .success(let response):
                Constants.appDelegate.client.unsubscribeFromAll()
                Constants.appDelegate.client.subscribeToChannels(response.data, withPresence: true)
            case .failure( let error):
                #if DEBUG
                    DLog("ChannelIDs: \(error)")
                #endif
            }
        }
    }
    
    func getNextPage() {
        self.showHud()
        let pager = Pager(page: currentPage + 1, per_page: Constants.kDefaultLimit)
        chatService.getListChannelMessage(pager: pager) { (result) in
            switch result {
            case .success(let response):
                self.viewModel.doUpdateData(response.data)
                if response.data.count < Constants.kDefaultLimit {
                    self.tableView.showsInfiniteScrolling = false
                } else {
                    self.tableView.showsInfiniteScrolling = true
                    self.currentPage += 1
                }
                var isNew: Bool = false
                response.data.forEach({
                    if $0.new {
                        isNew = true
                    }
                })
                if isNew {
                    Constants.appDelegate.tabbarController.addRedDotAtTabBarItem(atIndex: TabbarIndex.messageNav.rawValue)
                }
                
                self.tableView.reloadData()
            case .failure( let error):
                self.alertWithError(error)
            }
            self.tableView?.infiniteScrollingView.stopAnimating()
            self.hideHude()
        }
    }
    
    // MARK: - IBAction
    @IBAction func onNewConversation(_ sender: Any) {
        let vc = NewMessagesViewController()
        vc.delegate = self
        self.hidesBottomBarWhenPushed = true
        self.pushViewControllerWithPresentAnimation(vc)
        self.hidesBottomBarWhenPushed = false
    }
}

// MARK: - PNObjectEventListener
extension MessagesViewController: PNObjectEventListener {
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
        guard let msg = message.data.message else {
            return
        }
        
        let json = JSON(msg)
        let messageDTO = MessageDTO(json)
        let messageModel = MessageModel(messageDTO)
        guard viewModel.rows.count > 0 else { return }
        for index in 0...self.viewModel.rows.count - 1 {
            let messageRowModel = self.viewModel.rows[index]
            if messageRowModel.objectID == message.data.channel {
                if messageModel.removed.isEmpty {
                    if messageModel.images.isEmpty {
                        messageRowModel.desc = messageModel.message
                    } else {
                        messageRowModel.desc = "\(messageModel.images.count) " +
                            (messageModel.images.count > 1 ? "photos".localized() : "photo".localized())
                    }
                    
                } else {
                    messageRowModel.desc = "You left".localized()
                }
                
                if message.data.channel.elementsEqual(openedChannelID.description) {
                    //
                } else {
                    messageRowModel.isNew = true
                    Constants.appDelegate.tabbarController.addRedDotAtTabBarItem(atIndex: TabbarIndex.messageNav.rawValue)
                }
                
                messageRowModel.time = Date().timeAgoSinceNow
                self.viewModel.rows.remove(at: index)
                self.viewModel.rows.insert(messageRowModel, at: 0)
                break
            }
        }
        self.tableView.reloadData()
    }
//
//    // Handle subscription status change.
//    func client(_ client: PubNub, didReceive status: PNStatus) {
//
//        if status.operation == .subscribeOperation {
//
//            // Check whether received information about successful subscription or restore.
//            if status.category == .PNConnectedCategory || status.category == .PNReconnectedCategory {
//
//                let subscribeStatus: PNSubscribeStatus = status as! PNSubscribeStatus
//                if subscribeStatus.category == .PNConnectedCategory {
//
//                    // This is expected for a subscribe, this means there is no error or issue whatsoever.
//                }
//                else {
//
//                    /**
//                     This usually occurs if subscribe temporarily fails but reconnects. This means there was
//                     an error but there is no longer any issue.
//                     */
//                }
//            }
//            else if status.category == .PNUnexpectedDisconnectCategory {
//
//                /**
//                 This is usually an issue with the internet connection, this is an error, handle
//                 appropriately retry will be called automatically.
//                 */
//            }
//                // Looks like some kind of issues happened while client tried to subscribe or disconnected from
//                // network.
//            else {
//
//                let errorStatus: PNErrorStatus = status as! PNErrorStatus
//                if errorStatus.category == .PNAccessDeniedCategory {
//
//                    /**
//                     This means that PAM does allow this client to subscribe to this channel and channel group
//                     configuration. This is another explicit error.
//                     */
//                }
//                else {
//
//                    /**
//                     More errors can be directly specified by creating explicit cases for other error categories
//                     of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
//                     `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
//                     or `PNNetworkIssuesCategory`
//                     */
//                }
//            }
//        }
//    }
}

// MARK: - UITableViewDataSource
extension MessagesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = viewModel.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: rowModel.identifier,
                                                 for: indexPath) as! MessageTableViewCell
        cell.bindingWithModel(rowModel)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension MessagesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowModel = viewModel.rows[indexPath.row]
        if let id = rowModel.channelModel?.id {
            openedChannelID = id
        }
        let chatVC = ChatViewController()
        chatVC.channelModel = rowModel.channelModel
        chatVC.delegate = self
        chatVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let channelId = self.viewModel.rows[indexPath.row].objectID
        let delete = UITableViewRowAction(style: .normal, title: "Delete".localized()) { action, index in
            self.alertYesNoWithTitle("Confirm".localized(), message: "Do you really want to delete this conversation?".localized(), completion: { (success) in
                if success {
                    self.showHud()
                    self.chatService.deleteChannel(channelId: channelId,
                                                   complete: { (result) in
                                                    self.hideHude()
                                                    switch result {
                                                    case .success(_):
                                                        self.viewModel.rows.remove(at: indexPath.row)
                                                        self.tableView.reloadData()
                                                        self.unRegisterDeviceTokenWithPubnub([channelId])
                                                        break
                                                    case .failure(let error):
                                                        self.alertWithError(error)
                                                        break
                                                    }
                    })
                } else {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            })
        }
        delete.backgroundColor = UIColor.lightGray
        return [delete]
    }
}

// MARK: - NewMessagesViewControllerDelegate
extension MessagesViewController: NewMessagesViewControllerDelegate {
    
    func createNewGroupSuccess(_ viewController: BaseViewController, withChannelModel: ChannelModel) {
        viewController.dissmissPushViewControllerWithPresentAnimation()
        self.getData()
        let chatVC = ChatViewController()
        chatVC.channelModel = withChannelModel
        chatVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chatVC, animated: false)
    }
}

// MARK: - ChatViewControllerDelegate
extension MessagesViewController: ChatViewControllerDelegate {
    func onClosedChannel(controller: ChatViewController) {
        openedChannelID = -1
    }
}
