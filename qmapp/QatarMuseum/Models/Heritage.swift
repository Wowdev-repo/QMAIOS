//
//  HeritageDetail.swift
//  QatarMuseums
//
//  Created by Exalture on 03/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation
struct Heritage: ResponseObjectSerializable, ResponseCollectionSerializable {
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

    init(id:String?, name:String?, location:String?, latitude:String?, longitude:String?, image:String?, shortdescription:String?, longdescription:String?, images:[String]?, sortid:String?) {
        self.id = id
        self.name = name
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.image = image
        self.shortdescription = shortdescription
        self.longdescription = longdescription
        self.images = images
        self.sortid = sortid
    
    }
}

struct Heritages: ResponseObjectSerializable {
    var heritage: [Heritage]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.heritage = Heritage.collection(response: response, representation: data as AnyObject)
        }
    }
}

