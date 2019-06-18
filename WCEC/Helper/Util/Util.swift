//
//  Util.swift
//  WCEC
//
//  Created by hnc on 9/20/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import Foundation

class Util: NSObject {
    class func registerPubNubNotification(channelIds:[String], deviceTokenData: Data) {
        Constants.appDelegate.client.addPushNotificationsOnChannels(channelIds,
                                                                    withDevicePushToken: deviceTokenData) { (status) in
                                                                        if !status.isError {
                                                                        }
                                                                        else {
                                                                        }
        }
    }

    class func removePubNubNotification(channelIds:[String], deviceTokenData: Data) {
        Constants.appDelegate.client.removePushNotificationsFromChannels(channelIds,
                                                                         withDevicePushToken: deviceTokenData) { (status) in
                                                                            if !status.isError {
                                                                            }
                                                                            else {
                                                                            }
        }
    }
}
