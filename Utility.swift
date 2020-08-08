//
//  Utility.swift
//  ImageProviderModule
//
//  Created by Amrita Kandrikar on 8/5/20.
//  Copyright © 2020 Amrita Kumar. All rights reserved.
//

import Foundation
import UIKit
let imgCache = NSCache<NSString, AnyObject>()

class Utility: NSObject {
    
    static func getImageFromString(_ urlStr: String) -> UIImage?  {
        if let cachedImg = imgCache.object(forKey: NSString(string: urlStr)) as? UIImage {
            return cachedImg
        }
        return nil
    }
    
    static func saveImage(_ image: UIImage, forKey: String) {
        
        if (imgCache.object(forKey: NSString(string: forKey)) as? UIImage) == nil {
            imgCache.setObject(image, forKey: forKey as NSString)
        }
    }
}
