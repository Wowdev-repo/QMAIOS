//
//  NMoQTourDetail.swift
//  QatarMuseums
//
//  Created by Exalture on 05/12/18.
//  Copyright © 2018 Wakralab. All rights reserved.
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
    var sort_id: String? = nil
    var body: String? = nil
    var registered: String? = nil
    var nid: String? = nil
    
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
            self.sort_id = representation["sort_id"] as? String
            self.body = representation["Body"] as? String
            self.registered = representation["registered"] as? String
            self.nid = representation["nid"] as? String

        }
    }
    
    //    init (title:String?, fullContentID: String?, bannerTitle: String?, bannerLink: String?) {
    //        self.title = title
    //        self.fullContentID = fullContentID
    //        self.bannerTitle = bannerTitle
    //        self.bannerLink = bannerLink
    //    }
}

struct NMoQTourDetailList: ResponseObjectSerializable {
    var nmoqTourDetailList: [NMoQTourDetail]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.nmoqTourDetailList = NMoQTourDetail.collection(response: response, representation: data as AnyObject)
        }
    }
}
