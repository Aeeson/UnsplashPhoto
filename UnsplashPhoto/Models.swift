//
//  Models.swift
//  UnsplashPhoto
//
//  Created by Сергей on 28.01.2021.
//

import UIKit

struct CollectionSearch: Codable {
    let totalPages: Int
    let results: [Collection]

    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
        case results
    }
}

struct Collection: Codable {
    let title: String
    let totalPhotos: Int
    let links: CollectionLinks
    let coverPhoto: Photo

    enum CodingKeys: String, CodingKey {
        case title
        case totalPhotos = "total_photos"
        case links
        case coverPhoto = "cover_photo"
    }
}

struct CollectionLinks: Codable {
    let photos: String

    enum CodingKeys: String, CodingKey {
        case photos
    }
}

struct SearchResult: Codable {
    let total, totalPages: Int
    let results: [Photo]

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

struct Photo:Codable {
    let urls: Urls
    let width, height: Int
    let altDescription: String?
    let links: Links
    let likes: Int
    let user: User
    
    public func fetchPhoto (_ urlInString:String) -> UIImage {
        let url = URL(string: urlInString)
        let imageData = try? Data(contentsOf: url!)
        let image = UIImage(data: imageData!)
        return image!
    }
    
    enum CodingKeys: String, CodingKey {
            case urls, width, height, links, likes, user
            case altDescription = "alt_description"
        }
}

struct User: Codable {
    let username: String
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case username
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small, medium, large: String
}

struct Urls: Codable {
    let raw, full, regular, small, thumb: String
}

struct Links: Codable {
    let api: String
    
    enum CodingKeys: String, CodingKey {
            case api = "self"
        }
}





