//
//  AppMacro.swift
//  WCEC
//
//  Created by hnc on 5/4/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import Foundation
import UIKit
import Photos

func DLog(_ message: Any,
          function: String = #function,
          file: NSString = #file,
          line: Int = #line) {
    
    #if DEBUG
        // debug only code
        print("\(file.lastPathComponent) - \(function)[\(line)]: \(message)")
    #else
        // release only code
    #endif
}

func isIphoneApp() -> Bool {
    
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
        return true
    case .pad:
        return false
        
    default:
        return false
    }
}

func ALog(_ message: String?,
          function: String = #function,
          file: NSString = #file,
          line: Int = #line) {
    
    #if DEBUG
        // debug only code
        print("\n\(file.lastPathComponent) - \(function)[\(line)]: show alert with "
            + "\nMessage: \(message)"
            + "\n--------------------------------------------")
        
        let alertView = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let dismissAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default)
        
        alertView.addAction(dismissAction)
        
        presentAlertVC(alertView)
    #else
        // release only code
    #endif
}

func GemAlertShow(title: String?,
                  message: String?,
                  cancelHandle:((() -> Swift.Void)?),
                  doneHandle:((() -> Swift.Void)?),
                  function: String = #function,
                  file: NSString = #file,
                  line: Int = #line) {
    
    // debug only code
    print("\n\(file.lastPathComponent) - \(function)[\(line)]: show alert with "
        + "\nTitle: \(title)"
        + "\nMessage: \(message)"
        + "\n--------------------------------------------")
    
    let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (_) in
        
        if((cancelHandle) != nil) {
            cancelHandle!()
        }
    }
    
    let dismissAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (_) in
        
        if(doneHandle != nil) {
            doneHandle!()
        }
    }
    
    alertView.addAction(cancelAction)
    alertView.addAction(dismissAction)
    
    presentAlertVC(alertView)
}

//open class func animate(withDuration duration: TimeInterval, animations: @escaping () -> Swift.Void, completion: ((Bool) -> Swift.Void)? = nil)
func showAlert(title: String?, message: String?, completeHanle : ((() -> Swift.Void)?)) {
    var stringMessage = ""
    if let msg = message {
        if msg.characters.count > 0 {
            stringMessage = msg
        } else {
            stringMessage = "Error connecting to the system. Please check your network connection and try again."
        }
    } else {
        stringMessage = "Error connecting to the system. Please check your network connection and try again."
    }
    
    let alertView = UIAlertController(title: title, message: stringMessage, preferredStyle: UIAlertControllerStyle.alert)
    let cancelAction = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.cancel)
    alertView.addAction(cancelAction)
    
    presentAlertVC(alertView)
}

func showAlertAndWithAction(title: String?, message: String?, completeHanle : ((() -> Swift.Void)?)) {
    
    let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let cancelAction = UIAlertAction(title: "OK".localized(), style: .cancel) { (_) in
        completeHanle!()
    }
    
    alertView.addAction(cancelAction)
    
    presentAlertVC(alertView)
}

func showAlertRetry(title: String?, message: String?, completeHanle : ((() -> Swift.Void)?)) {
    var stringMessage = ""
    if let msg = message {
        stringMessage = msg
    } else {
        stringMessage = "Error connecting to the system. Please check your network connection and try again."
    }
    let alertView = UIAlertController(title: title, message: stringMessage, preferredStyle: UIAlertControllerStyle.alert)
    let cancelAction = UIAlertAction(title: "Đóng", style: .cancel) { (_) in
        completeHanle!()
    }
    
    alertView.addAction(cancelAction)
    
    presentAlertVC(alertView)
}

func presentAlertVC(_ alertVC: UIAlertController) {
    let viewController = UIApplication.topViewController()
    DispatchQueue.main.async {
        viewController!.present(alertVC, animated: true, completion: nil)
    }
}

func validateMaxCharacter(_ fieldName: String, textCount: Int, numberMax: Int) -> String? {
    if textCount > numberMax {
        return "The ".localized() +
            fieldName.localized().lowercased() +
            " may not be greater than " +
            String(numberMax)  +
            " characters".localized()
    }
    return nil
}

func convertImageFromAsset(asset: PHAsset) -> UIImage {
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    var image = UIImage()
    option.isSynchronous = true
    manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
        image = result!
    })
    return image
}

func getImage(asset: PHAsset, completionBlock:@escaping (UIImage,Bool)-> Void ) {
    let options = PHImageRequestOptions()
    options.isSynchronous = false
    options.resizeMode = .exact
    options.deliveryMode = .opportunistic
    options.isNetworkAccessAllowed = true
    var thumbnail = UIImage()
    
    let imageManager = PHCachingImageManager()
    imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: options) { image, info in
        let complete = (info?["PHImageResultIsDegradedKey"] as? Bool) == false
        if let image = image {
            thumbnail = image
            completionBlock(image,complete)
        }
    }
}

func getThumbnailFrom(path: URL) -> UIImage? {
    do {
        let asset = AVURLAsset(url: path , options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
        let thumbnail = UIImage(cgImage: cgImage)
        
        return thumbnail
    } catch let error {
        print("*** Error generating thumbnail: \(error.localizedDescription) from \(path)")
        return nil
    }
    
}

public func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
    let length = Int64(range.upperBound - range.lowerBound + 1)
    let value = Int64(arc4random()) % length + Int64(range.lowerBound)
    return T(value)
}





