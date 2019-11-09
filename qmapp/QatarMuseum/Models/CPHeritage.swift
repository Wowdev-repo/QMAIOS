//
//  CPHeritageDetail.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 03/08/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct CPHeritage: CPResponseObjectSerializable, CPResponseCollectionSerializable {
    var id: String? = nil
    var name: String? = nil
    var location: String? = nil
    var latitude: String? = nil
    var longitude: String? = nil
    var image: String? = nil
    var shortdescription: String? = nil
    var longdescription: String? = nil
    var images: [String]? = []

    //HeritageListList
    var sortid: String? = nil
    var isFavourite : Bool = false
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.id = representation["ID"] as? String
            self.name = representation["name"] as? String
            self.location = representation["Location"] as? String
            self.latitude = representation["Latitude"] as? String
            self.longitude = representation["Longitude"] as? String
            self.image = representation["LATEST_IMAGE"] as? String
            self.shortdescription = representation["short_description"] as? String
            self.longdescription = representation["long_description"] as? String
            self.images = representation["images"] as? [String]
            //HeritageListList
            self.sortid = representation["SORT_ID"] as? String
        }
    }

    init(entity: HeritageEntity) {
        var imagesArray : [String] = []
        if let heritageImagesArray = (entity.imagesRelation?.allObjects) as? [ImageEntity] {
            for info in heritageImagesArray {
                if let image = info.image {
                    imagesArray.append(image)
                }
            }
        }
        
        self.id = entity.listid
        self.name = entity.listname
        self.location = entity.detaillocation
        self.latitude = entity.detaillatitude
        self.longitude = entity.detaillongitude
        self.image = entity.listimage
        self.shortdescription = entity.detailshortdescription
        self.longdescription = entity.detaillongdescription
        self.images = imagesArray
        self.sortid = entity.listsortid
    
    }
}

struct Heritages: CPResponseObjectSerializable {
    var heritage: [CPHeritage]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.heritage = CPHeritage.collection(response: response, representation: data as AnyObject)
        }
    }
}

