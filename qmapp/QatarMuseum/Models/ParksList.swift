//
//  ParksList.swift
//  QatarMuseums
//
//  Created by Exalture on 09/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation
struct ParksList: ResponseObjectSerializable, ResponseCollectionSerializable {
    var title: String? = nil
    var description: String? = nil
    var sortId: String? = nil
    var image: String? = nil
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["Title"] as? String
            self.description = representation["Description"] as? String
            self.sortId = representation["sort_id"] as? String
            self.image = representation["image"] as? String
        }
    }
    init(title:String?, description:String?, sortId: String?, image: String?) {
        self.title = title
        self.description = description
        self.sortId = sortId
        self.image = image
    }
}

struct ParksLists: ResponseObjectSerializable {
    var parkList: [ParksList]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.parkList = ParksList.collection(response: response, representation: data as AnyObject)
        }
    }
}
struct NMoQParksList: ResponseObjectSerializable, ResponseCollectionSerializable {
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
            //self.nmoqParks = representation["nmoq_parks"] as? [String]
        }
    }
    init(title:String?, parkTitle:String?,mainDescription:String?, parkDescription: String?, hoursTitle: String?,hoursDesc:String?, nid:String?, longitude: String?, latitude: String?, locationTitle: String?) {
        self.title = title
        self.parkTitle = parkTitle
        self.mainDescription = mainDescription
        self.parkDescription = parkDescription
        self.hoursTitle = hoursTitle
        self.hoursDesc = hoursDesc
        self.nid = nid
        self.longitude = longitude
        self.latitude = latitude
        self.locationTitle = locationTitle
    }
}
struct NmoqParksLists: ResponseObjectSerializable {
    var nmoqParkList: [NMoQParksList]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.nmoqParkList = NMoQParksList.collection(response: response, representation: data as AnyObject)
        }
    }
}

struct NMoQPark: ResponseObjectSerializable, ResponseCollectionSerializable {
    var images: [String]? = []
    var nid: String? = nil
    var sortId: String? = nil
    var title: String? = nil

    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.images = representation["images"] as? [String]
            self.nid = representation["Nid"] as? String
            self.sortId = representation["sort_id"] as? String
            self.title = representation["title"] as? String
        }
    }
    
    init (title:String?, sortId: String?,nid: String?, images: [String]?) {
        self.title = title
        self.images = images
        self.sortId = sortId
        self.nid = nid
    }
}

struct NMoQParks: ResponseObjectSerializable {
    var nmoqParks: [NMoQPark]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.nmoqParks = NMoQPark.collection(response: response, representation: data as AnyObject)
        }
    }
}

