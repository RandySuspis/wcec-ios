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





