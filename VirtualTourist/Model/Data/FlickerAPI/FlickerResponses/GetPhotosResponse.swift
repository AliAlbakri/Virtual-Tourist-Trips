//
//  GetImageResponse.swift
//  VirtualTourist
//
//  Created by Ali Ahmad on 16/07/2020.
//  Copyright © 2020 Ali Ahmed. All rights reserved.
//


import Foundation

// MARK: - Welcome
struct GetPhotosResponse: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Image]
}

// MARK: - Photo
struct Image: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}
