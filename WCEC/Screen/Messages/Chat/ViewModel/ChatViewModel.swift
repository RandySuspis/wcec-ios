//
//  ChatViewModel.swift
//  WCEC
//
//  Created by hnc on 7/9/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation

class ChatViewModel {
    var rows = [ChatRowModel]()
//    var lastUserId = ""
//    var lastMessageDate: Date?
    var previousMessageModel: MessageModel?
    
    func parseData(_ data: [MessageModel]) {
        rows = [ChatRowModel]()
        previousMessageModel = nil
        for item in data {
            if item.removed.isEmpty {
                if self.previousMessageModel != nil {
                    // Day Changed
                    let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: (previousMessageModel?.createdDate)!)
                    let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: item.createdDate)
                    
                    if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                        // Show date seperator.
                        self.rows.append(ChatRowModel(item, identifier: DateSeperatorTableViewCell.nibName()))
                        addChatRowModel(item, true)
                    } else {
                        // Hide date seperator.
                        addChatRowModel(item, false)
                    }
                    previousMessageModel = item
                } else {
                    // Show date seperator.
                    self.rows.append(ChatRowModel(item, identifier: DateSeperatorTableViewCell.nibName()))
                    addChatRowModel(item, true)
                    previousMessageModel = item
                }
            }
        }
    }
    
    func doUpdateData(_ data: MessageModel) {
        if data.removed.isEmpty {
            if let item = rows.last {
                previousMessageModel = item.messageModel
            }
            if self.previousMessageModel != nil {
                // Day Changed
                let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: (previousMessageModel?.createdDate)!)
                let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: data.createdDate)
                
                if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                    // Show date seperator.
                    self.rows.append(ChatRowModel(data, identifier: DateSeperatorTableViewCell.nibName()))
                    addChatRowModel(data, true)
                } else {
                    // Hide date seperator.
                    addChatRowModel(data, false)
                }
            } else {
                // Show date seperator.
                self.rows.append(ChatRowModel(data, identifier: DateSeperatorTableViewCell.nibName()))
                addChatRowModel(data, true)
            }
        }
    }
    
    func addChatRowModel(_ item: MessageModel, _ isForceShowAvatar: Bool) {
        if item.removed.isEmpty {
            if item.userId == DataManager.getCurrentUserModel()?.id.description ?? "" {
                if item.images.count > 0 {
                    self.rows.append(ChatRowModel(item, identifier: SendImageMessageTableViewCell.nibName()))
                } else {
                    self.rows.append(ChatRowModel(item, identifier: SendMessageTableViewCell.nibName()))
                }
                
            } else {
                if item.images.count > 0 {
                    if isForceShowAvatar {
                        self.rows.append(ChatRowModel(item, identifier: AvatarReceiveImageTableViewCell.nibName()))
                    } else {
                        if item.userId == previousMessageModel?.userId {
                            self.rows.append(ChatRowModel(item, identifier: ReceiveImageMessageTableViewCell.nibName()))
                        } else {
                            self.rows.append(ChatRowModel(item, identifier: AvatarReceiveImageTableViewCell.nibName()))
                        }
                    }
                } else {
                    if isForceShowAvatar {
                        self.rows.append(ChatRowModel(item, identifier: AvatarReceiveMessageTableViewCell.nibName()))
                    } else {
                        if item.userId == previousMessageModel?.userId {
                            self.rows.append(ChatRowModel(item, identifier: ReceiveMessageTableViewCell.nibName()))
                        } else {
                            self.rows.append(ChatRowModel(item, identifier: AvatarReceiveMessageTableViewCell.nibName()))
                        }
                    }
                }
            }
            previousMessageModel = item
        }
    }
    
    //MARK: Load More
    func doLoadMoreWithData(_ data: MessageModel) {
        if data.removed.isEmpty {
            if let item = rows.first {
                previousMessageModel = item.messageModel
            }
            if self.previousMessageModel != nil {
                // Day Changed
                let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: (previousMessageModel?.createdDate)!)
                let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: data.createdDate)
                
                if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                    // Show date seperator.
                    
                    addLoadMoreRowModel(data)
                    self.rows.insert(ChatRowModel(data, identifier: DateSeperatorTableViewCell.nibName()), at: 0)
                } else {
                    // Hide date seperator.
                    if self.rows.count > 0 {
                        if self.rows.first?.identifier == DateSeperatorTableViewCell.nibName() {
                            self.rows.remove(at: 0)
                        }
                    }
                    addLoadMoreRowModel(data)
                    self.rows.insert(ChatRowModel(data, identifier: DateSeperatorTableViewCell.nibName()), at: 0)
                }
            } else {
                // Show date seperator.
                self.rows.insert(ChatRowModel(data, identifier: DateSeperatorTableViewCell.nibName()), at: 0)
                addLoadMoreRowModel(data)
            }
        }
    }
    
    func addLoadMoreRowModel(_ item: MessageModel) {
        if item.removed.isEmpty {
            if item.userId == DataManager.getCurrentUserModel()?.id.description ?? "" {
                if item.images.count > 0 {
                    self.rows.insert(ChatRowModel(item, identifier: SendImageMessageTableViewCell.nibName()), at: 0)
                } else {
                    self.rows.insert(ChatRowModel(item, identifier: SendMessageTableViewCell.nibName()), at: 0)
                }
            } else {
                if item.images.count > 0 {
                    if item.userId == previousMessageModel?.userId {
                        if self.rows.count > 0 {
                            if self.rows.first?.identifier == AvatarReceiveImageTableViewCell.nibName() {
                                self.rows.remove(at: 0)
                                self.rows.insert(ChatRowModel(previousMessageModel!, identifier: ReceiveImageMessageTableViewCell.nibName()), at: 0)
                                self.rows.insert(ChatRowModel(item, identifier: AvatarReceiveImageTableViewCell.nibName()), at: 0)
                            } else if self.rows.first?.identifier == AvatarReceiveMessageTableViewCell.nibName() {
                                self.rows.remove(at: 0)
                                self.rows.insert(ChatRowModel(previousMessageModel!, identifier: ReceiveMessageTableViewCell.nibName()), at: 0)
                                self.rows.insert(ChatRowModel(item, identifier: AvatarReceiveImageTableViewCell.nibName()), at: 0)
                            } else {
                                self.rows.insert(ChatRowModel(item, identifier: AvatarReceiveImageTableViewCell.nibName()), at: 0)
                            }
                        } else {
                            self.rows.insert(ChatRowModel(item, identifier: AvatarReceiveImageTableViewCell.nibName()), at: 0)
                        }
                    } else {
                        self.rows.insert(ChatRowModel(item, identifier: AvatarReceiveImageTableViewCell.nibName()), at: 0)
                    }
                } else {
                    if item.userId == previousMessageModel?.userId {
                        if self.rows.count > 0 {
                            if self.rows.first?.identifier == AvatarReceiveMessageTableViewCell.nibName() {
                                self.rows.remove(at: 0)
                                self.rows.insert(ChatRowModel(previousMessageModel!, identifier: ReceiveMessageTableViewCell.nibName()), at: 0)
                                self.rows.insert(ChatRowModel(item, identifier: AvatarReceiveMessageTableViewCell.nibName()), at: 0)
                            } else if self.rows.first?.identifier == AvatarReceiveImageTableViewCell.nibName() {
                                self.rows.remove(at: 0)
                                self.rows.insert(ChatRowModel(previousMessageModel!, identifier: ReceiveImageMessageTableViewCell.nibName()), at: 0)
                                self.rows.insert(ChatRowModel(item, identifier: AvatarReceiveMessageTableViewCell.nibName()), at: 0)
                            } else {
                                self.rows.insert(ChatRowModel(item, identifier: AvatarReceiveMessageTableViewCell.nibName()), at: 0)
                            }
                        } else {
                            self.rows.insert(ChatRowModel(item, identifier: AvatarReceiveMessageTableViewCell.nibName()), at: 0)
                        }
                    } else {
                        self.rows.insert(ChatRowModel(item, identifier: AvatarReceiveMessageTableViewCell.nibName()), at: 0)
                    }
                }
            }
            previousMessageModel = item
        }
    }
}
