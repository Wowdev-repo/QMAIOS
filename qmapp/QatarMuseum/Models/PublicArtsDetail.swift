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
        }
    }
    
    init(id:String?,name:String?,description:String?,shortdescription:String?,image:String?,images:[String]?,longitude:String?,latitude:String? ) {
        self.id = id
        self.name = name
        self.description = description
        self.shortdescription = id
        self.image = image
        self.images = images
        self.longitude = longitude
        self.latitude = latitude
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
