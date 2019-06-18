//
//  DateExtension.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit
import DateToolsSwift

extension Date {
    func currentTimeInMiliseconds() -> NSNumber {
        let since1970 = self.timeIntervalSince1970
        return NSNumber(value: since1970 * 1000)
        
    }
    
    static func dateFromMiliseconds(miliSecond: Double) -> Date {
        return Date(timeIntervalSince1970: (miliSecond / 1000.0))
    }
    
    static func dateFromSeconds(seconds: Double) -> Date {
        return Date(timeIntervalSince1970: seconds)
    }
    
    func stringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: self)
    }
    
    static func stringFromDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    static func dateFromString(_ string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
    
    static func convertDateString(_ string: String, fromFormat: String, toFormat: String) -> String {
        var formatter = DateFormatter()
        formatter.dateFormat = fromFormat
        if let date = formatter.date(from: string) {
            formatter.dateFormat = toFormat
            let string = Date.stringFromDate(date: date, format: toFormat)
            return string
        }
        return ""
    }
    
    static func convertUTCToLocal(date:String, fromFormat: String, toFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = toFormat
        
        return dt
    }

    //MARK: - Date time ago
    public var wcecTimeAgoSinceNow: String {
        return self.wcecTimeAgo(since:Date())
    }
    
    public func wcecTimeAgo(since date:Date, numericDates: Bool = false, numericTimes: Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.second,.minute,.hour,.day,.month,.year])
//        let earliest = self.earlierDate(date)
//        let latest = (earliest == self) ? date : self //Should be triple equals, but not extended to Date at this time
        
        
        let components = calendar.dateComponents(unitFlags, from: self, to: date)
//        let yesterday = date.subtract(1.days)
//        let isYesterday = yesterday.day == self.day
        
        //Not Yet Implemented/Optional
        //The following strings are present in the translation files but lack logic as of 2014.04.05
        //@"Today", @"This week", @"This month", @"This year"
        //and @"This morning", @"This afternoon"
        
        if (components.year! >= 2) {
            return "\(components.year!) " + "years ago".localized()
        } else if (components.year! >= 1) {
            
            if (numericDates) {
                return "1 " + "year ago".localized()
            }
            
            return "Last year".localized()
        } else if (components.month! >= 2) {
            return "\(components.month!) " + "months ago".localized()
        } else if (components.month! >= 1) {
            
            if (numericDates) {
                return "1 " + "month ago".localized()
            }
            
            return "Last month".localized()
        } else if (components.day! >= 2) {
            return "\(components.day!) " + "days ago".localized()
        } else if (components.day! >= 1) {
            if (numericDates) {
                return "1 " + "day ago".localized()
            }
            
            return "Yesterday".localized()
        } else if (components.hour! >= 2) {
            return "\(components.hour!) " + "hours ago".localized()
        } else if (components.hour! >= 1) {
            
            if (numericTimes) {
                return "1 " + "hour ago".localized()
            }
            
            return "An hour ago".localized()
        } else if (components.minute! >= 2) {
            return "\(components.minute!) " + "minutes ago".localized()
        } else if (components.minute! >= 1) {
            
            if (numericTimes) {
                return "1 " + "minute ago".localized()
            }
            
            return "A minute ago".localized()
        } else if (components.second! >= 2) {
            return "\(components.second!) " + "seconds ago".localized()
        } else {
            
            if (numericTimes) {
                return "1 " + "second ago".localized()
            }
            
            return "Just now".localized()
        }
    }
}
