//
//  Exhibition.swift
//  QatarMuseums
//
//  Created by Developer on 24/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation

struct Exhibition: ResponseObjectSerializable, ResponseCollectionSerializable {
    var name: String? = nil
    var id: String? = nil
    var image: String? = nil
    var startDate: String? = nil
    var endDate: String? = nil
    var location: String? = nil
    var museumId : String? = nil
    var displayDate : String? = nil

    var detailImage: String? = nil
    var latitude: String? = nil
    var longitude: String? = nil
    var shortDescription: String? = nil
    var longDescription: String? = nil
    var isFavourite : Bool = false
    var status : String? = nil
    var mail : String? = nil
    var phone : String? = nil

    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.id = representation["ID"] as? String
            self.name = representation["name"] as? String
            self.image = representation["latest_image"] as? String
            self.detailImage = representation["LATEST_IMAGE"] as? String
            self.location = representation["Location"] as? String
            self.latitude  = representation["Latitude"] as? String
            self.longitude  = representation["Longitude"] as? String
            self.startDate  = representation["start_Date"] as? String
            self.endDate  = representation["end_Date"] as? String
            self.shortDescription  = representation["Short_description"] as? String
            self.longDescription  = representation["Long_description"] as? String
            self.museumId  = representation["museum_id"] as? String
            self.status  = representation["Status"] as? String
            self.displayDate  = representation["Display_date"] as? String
            self.phone = representation["contact_number"] as? String
            self.mail = representation["contact_email"] as? String
        }
    }
    
    init(entity: ExhibitionsEntity) {
        self.id = entity.id
        self.name = entity.name
        self.image = entity.image
        self.detailImage = entity.detailImage
        self.startDate = entity.startDate
        self.endDate = entity.endDate
        self.location = entity.location
        self.museumId = entity.museumId
        self.status = entity.status
        self.displayDate = entity.dispalyDate
        self.latitude = entity.detailLatitude
        self.longitude = entity.detailLongitude
        self.displayDate = entity.dispalyDate
        self.mail = entity.mail
        self.phone = entity.phone
    }
}

struct Exhibitions: ResponseObjectSerializable {
    var exhibitions: [Exhibition]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.exhibitions = Exhibition.collection(response: response, representation: data as AnyObject)
        }
    }
}

