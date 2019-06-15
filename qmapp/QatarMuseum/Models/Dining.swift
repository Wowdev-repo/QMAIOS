//
//  DiningList.swift
//  QatarMuseums
//
//  Created by Exalture on 02/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation
struct Dining: ResponseObjectSerializable, ResponseCollectionSerializable {
    var name: String? = nil
    var id: String? = nil
    var location: String? = nil
    var image: String? = nil
    var openingtime: String? = nil
    var closetime: String? = nil
    var description: String? = nil
    var sortid: String? = nil
    var museumId: String? = nil
    //for detail
    var latitude: String? = nil
    var longitude: String? = nil
    var images: [String]? = []

    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.id = representation["ID"] as? String
            self.name = representation["name"] as? String
            self.location = representation["Location"] as? String
            self.latitude = representation["Latitude"] as? String
            self.longitude = representation["Longitude"] as? String
            self.description = representation["Description"] as? String
            self.image = representation["image"] as? String
            self.openingtime = representation["opening_time"] as? String
            self.closetime = representation["close_time"] as? String
            self.sortid = representation["sort_id"] as? String
            self.museumId = representation["museums"] as? String
            self.images = representation["images"] as? [String]
        }
    }
    
    init(entity: DiningEntity) {
        
        var imagesArray : [String] = []
        let diningImagesArray = (entity.imagesRelation?.allObjects) as! [ImageEntity]
        
        for images in diningImagesArray {
            if let image = images.image {
                imagesArray.append(image)
            }
        }
        
        self.id = entity.id
        self.name = entity.name
        self.location = entity.location
        self.description = entity.description
        self.image = entity.image
        self.openingtime = entity.openingtime
        self.closetime = entity.closetime
        self.sortid = entity.sortid
        self.museumId = entity.museumId
        self.images = imagesArray
    }
}

struct Dinings: ResponseObjectSerializable {
    var dinings: [Dining]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.dinings = Dining.collection(response: response, representation: data as AnyObject)
        }
    }
}

