//
//  ImageProvider.swift
//  ImageProviderModule
//
//  Created by Amrita Kandrikar on 8/5/20.
//  Copyright © 2020 Amrita Kumar. All rights reserved.
//

import Foundation
import UIKit

class ImageProvider {
    typealias imageCompletion = (UIImage?) -> ()
    
    static let shared = ImageProvider()
    private var pendingResponses = [String: [imageCompletion]]()
    
    let servicecallQueue = DispatchQueue.init(label: "com.imageservice.concurrent", attributes: .concurrent)
    let imageCacheQueue = DispatchQueue.init(label: "com.imagecache.concurrent", attributes: .concurrent)
    
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    
    func providerImage(forPath imagePath: String, completion: @escaping imageCompletion) {
        
        // Check for a cached image.
        
        imageCacheQueue.sync {
            if let img = Utility.getImageFromString(imagePath) {
                DispatchQueue.main.async() {
                    completion(img)
                    return
                }
            }
        }
        
        // In case there are more than one requestor for the image, we append their completion block.
        
        servicecallQueue.async(flags: .barrier) {
            if self.pendingResponses[imagePath] != nil {
                self.pendingResponses[imagePath]?.append(completion)
                return
            }
            else {
                self.pendingResponses[imagePath] = [completion]
            }
            self.loadImage(fromURL: imagePath)
        }
    }
    // Fetch the image.
    func loadImage(fromURL urlStr: String) {

        guard let url = URL(string: urlStr) else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            // Check for the data and try to create the image.
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    self?.responseFromServer(key: urlStr, image: image)
                    return
                }
            }
            self?.callBacks(urlStr, image: nil)
        }
    }
    
    func responseFromServer(key: String, image: UIImage) {

            // Cache the image.
            imageCacheQueue.async(flags: .barrier) {
                Utility.saveImage(image, forKey: key)
            }
                self.callBacks(key, image: image)
    }
    
    func callBacks(_ key: String, image: UIImage?) {
        
        // Iterate over each requestor for the image and pass it back.
        
        servicecallQueue.sync() {
            guard let responseArray = self.pendingResponses[key] else {
                return
            }
            for callBack in responseArray {
                DispatchQueue.main.async() {
                    callBack(image)
                }
            }
        }
        
        // Update requesters list.
        servicecallQueue.async(flags: .barrier) {
            self.pendingResponses.removeValue(forKey: key)
        }
        
    }
}
