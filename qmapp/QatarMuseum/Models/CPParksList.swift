//
//  CPParksList.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 09/08/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct CPParksList: CPResponseObjectSerializable, CPResponseCollectionSerializable {
    var title: String? = nil
    var description: String? = nil
    var sortId: String? = nil
    var image: String? = nil
    var language: String?
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["Title"] as? String
            self.description = representation["Description"] as? String
            self.sortId = representation["sort_id"] as? String
            self.image = representation["image"] as? String
            self.language = representation["language"] as? String
        }
    }
    
    init(title:String?, description:String?, sortId: String?, image: String?, language: String?) {
        self.title = title
        self.description = description
        self.sortId = sortId
        self.image = image
        self.language = language
    }
}

struct ParksLists: CPResponseObjectSerializable {
    var parkList: [CPParksList]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.parkList = CPParksList.collection(response: response, representation: data as AnyObject)
        }
    }
}
struct NMoQParksList: CPResponseObjectSerializable, CPResponseCollectionSerializable {
    var title: String? = nil
    var parkTitle: String? = nil
    var mainDescription: String? = nil
    var parkDescription: String? = nil
    var hoursTitle: String? = nil
    var hoursDesc: String? = nil
    var nid: String? = nil
    var longitude: String? = nil
    var latitude: String? = nil
    var locationTitle: String? = nil
    var language: String?
    //var nmoqParks: [String]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["title"] as? String
            self.parkTitle = representation["park_title "] as? String
            self.mainDescription = representation["Main_description"] as? String
            self.parkDescription = representation["park_description"] as? String
            self.hoursTitle = representation["park_hours_title"] as? String
            self.hoursDesc = representation["parks_hours_description"] as? String
            
            self.nid = representation["nid"] as? String
            self.longitude = representation["longtitude_nmoq"] as? String
            self.latitude = representation["latitude_nmoq"] as? String
            self.locationTitle = representation["location_title"] as? String
            self.language = representation["language"] as? String
            //self.nmoqParks = representation["nmoq_parks"] as? [String]
        }
    }
    
    init(entity: NMoQParkListEntity) {
        self.title = entity.title
        self.parkTitle = entity.parkTitle
        self.mainDescription = entity.mainDescription
        self.parkDescription = entity.parkDescription
        self.hoursTitle = entity.hoursTitle
        self.hoursDesc = entity.hoursDesc
        self.nid = entity.nid
        self.longitude = entity.longitude
        self.latitude = entity.latitude
        self.locationTitle = entity.locationTitle
        self.language = entity.language
    }
}
struct NmoqParksLists: CPResponseObjectSerializable {
    var nmoqParkList: [NMoQParksList]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.nmoqParkList = NMoQParksList.collection(response: response, representation: data as AnyObject)
        }
    }
}

struct NMoQPark: CPResponseObjectSerializable, CPResponseCollectionSerializable {
    var images: [String]? = []
    var nid: String? = nil
    var sortId: String? = nil
    var title: String? = nil
    var language: String?

    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.images = representation["images"] as? [String]
            self.nid = representation["Nid"] as? String
            self.sortId = representation["sort_id"] as? String
            self.title = representation["title"] as? String
            self.language = representation["language"] as? String
        }
    }
    
    init (title:String?, sortId: String?,nid: String?, images: [String]?, language: String?) {
        self.title = title
        self.images = images
        self.sortId = sortId
        self.nid = nid
        self.language = language
    }
    
    init(entity: NMoQParksEntity) {
        
        var imagesArray : [String] = []
        if let imagesInfoArray = (entity.parkImgRelation?.allObjects) as? [ImageEntity] {
            for info in imagesInfoArray {
                if let image = info.image {
                    imagesArray.append(image)
                }
            }
        }
        
        self.title = entity.title
        self.images = imagesArray
        self.sortId = entity.sortId
        self.nid = entity.nid
        self.language = entity.language
    }
}

struct NMoQParks: CPResponseObjectSerializable {
    var nmoqParks: [NMoQPark]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.nmoqParks = NMoQPark.collection(response: response, representation: data as AnyObject)
        }
    }
}
