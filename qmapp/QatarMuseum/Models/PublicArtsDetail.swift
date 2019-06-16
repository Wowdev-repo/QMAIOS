//
//  PublicArtsDetail.swift
//  QatarMuseums
//
//  Created by Exalture on 05/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation
struct PublicArtsDetail: ResponseObjectSerializable, ResponseCollectionSerializable {
    var id: String? = nil
    var name: String? = nil
    var description: String? = nil
    var shortdescription: String? = nil
    var image: String? = nil
    var images: [String]? = []
    var longitude: String? = nil
    var latitude: String? = nil
    var language: String?
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.id = representation["ID"] as? String
            self.name = representation["name"] as? String
            self.description = representation["Description"] as? String
            self.shortdescription = representation["short_description"] as? String
            self.image = representation["Teaser_image"] as? String
            self.images = representation["images"] as? [String]
            self.longitude = representation["longtitude"] as? String
            self.latitude = representation["Latitude"] as? String
            self.language = representation["language"] as? String
        }
    }
    
    init(entity: PublicArtsEntity) {
        var imagesArray : [String] = []
        if let imagesInfoArray = (entity.publicImagesRelation?.allObjects) as? [ImageEntity] {
            for info in imagesInfoArray {
                if let image = info.image {
                    imagesArray.append(image)
                }
            }
        }
        
        self.id = entity.id
        self.name = entity.name
        self.description = entity.detaildescription
        self.shortdescription = entity.shortdescription
        self.image = entity.image
        self.images = imagesArray
        self.longitude = entity.longitude
        self.latitude = entity.latitude
        self.language = entity.language
    }
}

struct PublicArtsDetails: ResponseObjectSerializable {
    var publicArtsDetail: [PublicArtsDetail]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.publicArtsDetail = PublicArtsDetail.collection(response: response, representation: data as AnyObject)
        }
    }
}
