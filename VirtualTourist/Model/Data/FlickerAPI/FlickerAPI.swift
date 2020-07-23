//
//  FlickerAPI.swift
//  VirtualTourist
//
//  Created by Ali Ahmad on 16/07/2020.
//  Copyright © 2020 Ali Ahmed. All rights reserved.
//

import Foundation
import UIKit

class FlickerAPI {
    enum Endpoints {
        static let apiKeyParam = "api_key=e016cf93690e1a2f5d2b050b9aef10fb"
        static let base = "https://api.flickr.com/services/rest/"
        
        case getPhotos(String,String,String)
        
        var stringValue: String {
                switch self {
                case .getPhotos(let lat,let lon,let page):
                    return Endpoints.base + "?method=flickr.photos.search&\(Endpoints.apiKeyParam)&lat=\(lat)&lon=\(lon)&format=json&tags=\("")&accuracy=11&nojsoncallback=1&per_page=33&page=\(page)"
            }
        }
        
        var url: URL {
                return URL(string: stringValue)!
        }
        
        
    }
    
    
    
    class func downloadPhotos(imageURLs:[URL],completion:@escaping ([UIImage],Error?)->Void){
      var images = [UIImage]()
         
        for imageURL in imageURLs{
        let imageRequest = URLRequest(url:imageURL)
            
             let imageTask = URLSession.shared.dataTask(with: imageRequest) { (data, res, error) in
                 guard let data = data else{
                     return
                 }
                let image = UIImage(data: data)
                if image != nil {
                    images.append(image!)
                }
               

                if imageURL == imageURLs.last{
                    completion(images,nil)
                }
             }
            
             imageTask.resume()
       
        }
        
    }
    
    
    
    class func getPhotos(lat:String,lon:String,page:String,completion:@escaping ([UIImage],Error?)->Void){
        var imageURLs = [URL]()
        let request = URLRequest(url: Endpoints.getPhotos(lat, lon,page).url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else{
                //here we couldn't download the collection of raw images based on lat&lon
                completion([],error)
                return
            }
            let PhotosResponse = try! JSONDecoder().decode(GetPhotosResponse.self, from: data)
            print("APi number")
            print(PhotosResponse.photos.photo.count)
            for photo in PhotosResponse.photos.photo{
                let url = URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")!
                imageURLs.append(url)
                
            }
            downloadPhotos(imageURLs: imageURLs) { (imageArray, error) in
                guard error == nil else{
                    completion([],error)
                    return
                }
                DispatchQueue.main.async {
                completion(imageArray,nil)
                }
            }
            
            
        }
        task.resume()
        
    }
}

