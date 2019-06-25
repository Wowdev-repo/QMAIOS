//
//  NMoQTourDetail.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 05/12/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct NMoQTourDetail: ResponseObjectSerializable, ResponseCollectionSerializable {
    var title: String? = nil
    var imageBanner: [String]? = []
    var date: String? = nil
    var nmoqEvent: String? = nil
    var register: String? = nil
    var contactEmail: String? = nil
    var contactPhone: String? = nil
    var mobileLatitude: String? = nil
    var longitude: String? = nil
    var sortId: String? = nil
    var body: String? = nil
    var registered: String? = nil
    var nid: String? = nil
    var seatsRemaining: String? = nil
    var language: String?
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["Title"] as? String
            self.imageBanner = representation["image_banner"] as? [String]
            self.date = representation["Date"] as? String
            self.nmoqEvent = representation["NMoq_event"] as? String
            self.register = representation["Register"] as? String
            self.contactEmail = representation["contact_email"] as? String
            self.contactPhone = representation["contact_phone"] as? String
            self.mobileLatitude = representation["latitude"] as? String
            self.longitude = representation["longtitude"] as? String
            self.sortId = representation["sort_id"] as? String
            self.body = representation["Body"] as? String
            self.registered = representation["registered"] as? String
            self.nid = representation["node_id"] as? String
            self.seatsRemaining = representation["Seats_remaining"] as? String
            self.language = representation["language"] as? String
        }
    }
    
    init(entity: NmoqTourDetailEntity) {
        
        var imagesArray : [String] = []
        if let imagesInfoArray = (entity.nmoqTourDetailImgBannerRelation?.allObjects) as? [ImageEntity] {
            for info in imagesInfoArray {
                if let image = info.image {
                    imagesArray.append(image)
                }
            }
        }
        
        self.title = entity.title
        self.imageBanner = imagesArray
        self.date = entity.date
        self.nmoqEvent = entity.nmoqEvent
        self.register = entity.register
        self.contactEmail = entity.contactEmail
        self.contactPhone = entity.contactPhone
        self.mobileLatitude = entity.mobileLatitude
        self.longitude = entity.longitude
        self.sortId = entity.sort_id
        self.body = entity.body
        self.registered = entity.registered
        self.nid = entity.nid
        self.seatsRemaining = entity.seatsRemaining
        self.language = entity.language
        
    }
}

struct NMoQTourDetailList: ResponseObjectSerializable {
    var nmoqTourDetailList: [NMoQTourDetail]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.nmoqTourDetailList = NMoQTourDetail.collection(response: response, representation: data as AnyObject)
        }
    }
}
