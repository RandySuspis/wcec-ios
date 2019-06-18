//
//  StringExtension.swift
//  WCEC
//
//  Created by hnc on 4/26/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func isValidEmailAddress() -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    func utf8DecodedString()-> String {
        let data = self.data(using: .utf8)
        if let message = String(data: data!, encoding: .nonLossyASCII){
            return message
        }
        return ""
    }
    
    func utf8EncodedString()-> String {
        let messageData = self.data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8)
        return text!
    }
    
    func isValidPhoneNumber() -> Bool {
        
        if self.isAllDigits() == true {
            let phoneRegex = "^((\\+?)|(00))[0-9]{0,255}$"//"[235689][0-9]{6}([0-9]{3})?"
            let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return  predicate.evaluate(with: self)
        }else {
            return false
        }
    }
    
    private func isAllDigits()->Bool {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = self.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  self == filtered
    }
    
    func trim() -> String {
        let trimmedString = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmedString
    }
    
    func isOnlyNumber() -> Bool {
        let charracterSet = CharacterSet.decimalDigits.inverted
        
        if self.rangeOfCharacter(from: charracterSet) != nil {
            return false
        }
        return true
    }
    
    func isEmailFormat() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isStrongPassword() -> Bool {
        let lengthresult = self.characters.count >= 6
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: self)
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluate(with: self)
        
        let specialCharacterReg  = "(?=^.{8,255}$)((?=.*\\d)(?=.*[A-Z])(?=.*[a-z])|(?=.*\\d)(?=.*[^A-Za-z0-9])(?=.*[a-z])|(?=.*[^A-Za-z0-9])(?=.*[A-Z])(?=.*[a-z])|(?=.*\\d)(?=.*[A-Z])(?=.*[^A-Za-z0-9]))^.*"
        let texttest2 = NSPredicate(format:"SELF MATCHES %@", specialCharacterReg)
        let allresult = texttest2.evaluate(with: self)
        
        return lengthresult && capitalresult && numberresult && allresult
    }
    
    func isPasswordValid() -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z])[A-Za-z\\d\\W]{6,12}$")
        return passwordTest.evaluate(with: self)
    }
    
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
    
    static func isPasswordComplexity(string: String) -> Bool {
        let capitalLetterRegEx  = ".*[a-zA-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: string)
        
        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = texttest1.evaluate(with: string)
        
        return numberresult && capitalresult
    }
    
    public func isValidPassword() -> Bool {
        var rulePassed = 0
        if (isContainLowerCase()) {
            rulePassed += 1
        }
        if (isContainUpperCase()) {
            rulePassed += 1
        }
        if (isContainNumber()) {
            rulePassed += 1
        }
        if (isContainSpecialCharacter()) {
            rulePassed += 1
        }
        return rulePassed >= 3 && self.count >= 8
    }
    
    public func isContainLowerCase() -> Bool {
        let PASSWORD_PATTERN = ".*[a-z].*"
        return NSPredicate(format: "SELF MATCHES %@", PASSWORD_PATTERN).evaluate(with: self)
    }
    
    public func isContainUpperCase() -> Bool {
        let PASSWORD_PATTERN = ".*[A-Z].*"
        return NSPredicate(format: "SELF MATCHES %@", PASSWORD_PATTERN).evaluate(with: self)
    }
    
    public func isContainNumber() -> Bool {
        let PASSWORD_PATTERN = ".*[0-9].*"
        return NSPredicate(format: "SELF MATCHES %@", PASSWORD_PATTERN).evaluate(with: self)
    }
    
    public func isContainSpecialCharacter() -> Bool {
        let PASSWORD_PATTERN = ".*[@#\\$%^&+=].*"
        return NSPredicate(format: "SELF MATCHES %@", PASSWORD_PATTERN).evaluate(with: self)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension String {
    
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    var removeFirstCharacter : String {
        mutating get {
            self.remove(at: self.startIndex)
            return self
        }
    }
}
