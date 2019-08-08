//
//  CPFacilitiesDetail.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 18/03/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
struct CPFacilitiesDetail: CPResponseObjectSerializable, CPResponseCollectionSerializable {
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
    var language: String?
    
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
            self.language = representation["language"] as? String
        }
    }
    
//    init (title:String?,
//          images: [String]?,
//          subtitle: String?,
//          facilitiesDes: String?,
//          timing: String?,
//          titleTiming: String?,
//          nid: String?,
//          longtitude: String?,
//          category:String?,
//          latitude: String?,
//          locationTitle: String?,
//          language: String?) {
//        self.title = title
//        self.images = images
//        self.subtitle = subtitle
//        self.facilitiesDes = facilitiesDes
//        self.timing = timing
//        self.titleTiming = titleTiming
//        self.nid = nid
//        self.longtitude = longtitude
//        self.category = category
//        self.latitude = latitude
//        self.locationTitle = locationTitle
//        self.language = language
//    }
    
//    Init using FacilitiesDetailEntity
    init(entity: FacilitiesDetailEntity) {
        
        var imagesArray : [String] = []
        let imagesInfoArray = (entity.facilitiesDetailRelation!.allObjects) as! [ImageEntity]
        for imagesInfo in imagesInfoArray {
            imagesArray.append(imagesInfo.image!)
        }
        
        self.title = entity.title
        self.images = imagesArray
        self.subtitle = entity.subtitle
        self.facilitiesDes = entity.facilitiesDes
        self.timing = entity.timing
        self.titleTiming = entity.titleTiming
        self.nid = entity.nid
        self.longtitude = entity.longtitude
        self.category = entity.category
        self.latitude = entity.latitude
        self.locationTitle = entity.locationTitle
        self.language = entity.language
    }
}

struct FacilitiesDetailData: CPResponseObjectSerializable {
    var facilitiesDetail: [CPFacilitiesDetail]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.facilitiesDetail = CPFacilitiesDetail.collection(response: response,
                                                                representation: data as AnyObject)
        }
    }
}

