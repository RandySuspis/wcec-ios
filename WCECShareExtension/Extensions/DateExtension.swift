//
//  DateExtension.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    static func currentTimeInMiliseconds(_ date: Date) -> Int {
        let since1970 = date.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    static func dateFromMiliseconds(miliSecond: Double) -> Date {
        return Date(timeIntervalSince1970: (miliSecond / 1000.0))
    }
    
    static func dateFromSeconds(seconds: Double) -> Date {
        return Date(timeIntervalSince1970: seconds)
    }
    
    static func stringFromDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy  HH:mm"
        return formatter.string(from: date)
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
}
