//
//  ImageHelper.swift
//  PinterestTest
//
//  Created by Digital Dividend on 25/05/2019.
//  Copyright © 2019 Saad. All rights reserved.
//

import Foundation
import UIKit

enum ImageHelperTypes{
    case JSON
    case IMAGE
}

class ImageHelper{
    
    static let cache = NSCache<NSString, UIImage>()
    typealias completionBlock = (_ image: UIImage?) -> Void

    
    static func downloadImage( url: URL, completion: @escaping completionBlock){
        
        // Approx 15 Images can be cached.
        cache.countLimit = 15 * 1024 * 1024
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, imageUrl, error) in
            var downloadedImage : UIImage?
            if let data = data{
                downloadedImage = UIImage(data: data)
            }
            
            if downloadedImage != nil{
                cache.setObject(downloadedImage!, forKey: url.absoluteString as NSString)
            }
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
        }
        
        dataTask.resume()
    }
    
    static func getCacheImage(url: URL, completion: @escaping completionBlock){
        if let image = cache.object(forKey: url.absoluteString as NSString){
            completion(image)
        }else{
            downloadImage(url: url, completion: completion)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
