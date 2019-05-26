//
//  PublicArtsList.swift
//  QatarMuseums
//
//  Created by Exalture on 04/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
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
    
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.id = representation["ID"] as? String
            self.name = representation["name"] as? String
            self.latitude = representation["Latitude"] as? String
            self.longitude = representation["Longitude"] as? String
            self.image = representation["LATEST_IMAGE"] as? String
            self.areaofwork = representation["Area of Work"] as? NSArray
            self.sortcoefficient = representation["sort coefficient"] as? String
            
        }
    }
    init(id: String?, name: String?, latitude:String?, longitude:String?,image:String?,sortcoefficient:String?) {
        self.id = id
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.image = image
        self.sortcoefficient = sortcoefficient
        
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
