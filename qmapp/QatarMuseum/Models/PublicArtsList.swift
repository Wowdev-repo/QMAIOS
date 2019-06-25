//
//  PublicArtsList.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 04/08/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct PublicArtsList: ResponseObjectSerializable, ResponseCollectionSerializable {
    var id: String? = nil
    var name: String? = nil
    var latitude: String? = nil
    var longitude: String? = nil
    var image: String? = nil
    var areaofwork:NSArray? = nil
    var sortcoefficient: String? = nil
    var isFavourite : Bool = false
    var language: String?
    
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.id = representation["ID"] as? String
            self.name = representation["name"] as? String
            self.latitude = representation["Latitude"] as? String
            self.longitude = representation["Longitude"] as? String
            self.image = representation["LATEST_IMAGE"] as? String
            self.areaofwork = representation["Area of Work"] as? NSArray
            self.sortcoefficient = representation["sort coefficient"] as? String
            self.language = representation["language"] as? String
            
        }
    }
    
    init(entity: PublicArtsEntity) {
        self.id = entity.id
        self.name = entity.name
        self.image = entity.image
        self.longitude = entity.longitude
        self.latitude = entity.latitude
        self.language = entity.language
    }
}

struct PublicArtsLists: ResponseObjectSerializable {
    var publicArtsList: [PublicArtsList]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.publicArtsList = PublicArtsList.collection(response: response, representation: data as AnyObject)
        }
    }
}
