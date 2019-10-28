//
//  FacilitiesDetail.swift
//  QatarMuseums
//
//  Created by Exalture on 18/03/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation
struct FacilitiesDetail: ResponseObjectSerializable, ResponseCollectionSerializable {
    var title: String? = nil
    var images: [String]? = []
    var subtitle: String? = nil
    var facilitiesDes: String? = nil
    var timing: String? = nil
    var titleTiming: String? = nil
    var nid: String? = nil
    var longtitude: String? = nil
    var category: String? = nil
    var latitude: String? = nil
    var locationTitle: String? = nil
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["Title"] as? String
            self.images = representation["images"] as? [String]
            self.subtitle = representation["Subtitle"] as? String
            self.facilitiesDes = representation["Description"] as? String
            self.timing = representation["timing"] as? String
            self.titleTiming = representation["title_timing"] as? String
            self.nid = representation["nid"] as? String
            self.longtitude = representation["longtitude"] as? String
            self.category = representation["category"] as? String
            self.latitude = representation["latitude "] as? String
            self.locationTitle = representation["location title"] as? String
        }
    }
    
    init (title:String?, images: [String]?,subtitle: String?, facilitiesDes: String? , timing: String?,titleTiming: String?, nid: String?, longtitude: String?,category:String?,  latitude: String?, locationTitle: String?) {
        self.title = title
        self.images = images
        self.subtitle = subtitle
        self.facilitiesDes = facilitiesDes
        self.timing = timing
        self.titleTiming = titleTiming
        self.nid = nid
        self.longtitude = longtitude
        self.category = category
        self.latitude = latitude
        self.locationTitle = locationTitle

    }
}

struct FacilitiesDetailData: ResponseObjectSerializable {
    var facilitiesDetail: [FacilitiesDetail]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.facilitiesDetail = FacilitiesDetail.collection(response: response, representation: data as AnyObject)
        }
    }
}

