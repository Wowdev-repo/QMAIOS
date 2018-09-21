//
//  Museum.swift
//  QatarMuseums
//
//  Created by Exalture on 22/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation
struct Museum: ResponseObjectSerializable, ResponseCollectionSerializable {
//    var mid: String? = nil
//    var filter: String? = nil
//    var title: String? = nil
//    var image1: String? = nil
//    var image2: String? = nil
//    var image3: String? = nil
    
    
    var name: String? = nil
    var id: String? = nil
    var tourguideAvailable: String? = nil
    var contactNumber: String? = nil
    var contactEmail: String? = nil
    var mobileLongtitude: String? = nil
    var subtitle: String? = nil
    var openingTime: String? = nil
    var mobileDescription: [String]? = []
    var multimediaFile: [String]? = []
    var mobileLatitude: String? = nil
    var tourGuideAvailability: String? = nil
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
//            self.mid = representation["mid"] as? String
//            self.filter = representation["filter"] as? String
//            self.title = representation["title"] as? String
//            self.image1 = representation["image1"] as? String
//            self.image2 = representation["image2"] as? String
//            self.image3 = representation["image3"] as? String
            
            
            self.name = representation["name"] as? String
            self.id = representation["id"] as? String
            self.tourguideAvailable = representation["tourguide_available"] as? String
            self.contactNumber = representation["contact_number"] as? String
            self.contactEmail = representation["contact_email"] as? String
            self.mobileLongtitude = representation["mobile_longtitude"] as? String
            
            self.subtitle = representation["Subtitle"] as? String
            self.openingTime = representation["opening_time"] as? String
            self.mobileDescription = representation["Mobile_descriptif"] as? [String]
            self.multimediaFile = representation["Multimedia_file"] as? [String]
            self.mobileLatitude = representation["mobile_latitude"] as? String
            self.tourGuideAvailability = representation["tour_guide_availability"] as? String
            
            
        }
    }
  //  init(mid:String?, filter: String?,title:String?,icon:String?,image1:String?,image2:String?,image3:String?) {
//        self.mid = mid
//        self.filter = filter
//        self.title = title
//        self.image1 = image1
//        self.image2 = image2
//        self.image3 = image3
  //  }
    
    init(name:String?, id: String?,tourguideAvailable:String?,contactNumber:String?,contactEmail:String?,mobileLongtitude:String?,subtitle:String?,openingTime:String?,mobileDescription:[String]?,multimediaFile:[String]?,mobileLatitude:String?,tourGuideAvailability:String?) {
            self.name = name
            self.id = id
            self.tourguideAvailable = tourguideAvailable
            self.contactNumber = contactNumber
            self.contactEmail = contactEmail
            self.mobileLongtitude = mobileLongtitude
            self.subtitle = subtitle
            self.openingTime = openingTime
            self.mobileDescription = mobileDescription
            self.multimediaFile = multimediaFile
            self.mobileLatitude = mobileLatitude
            self.tourGuideAvailability = tourGuideAvailability
        
    }
}

struct Museums: ResponseObjectSerializable {
    var museum: [Museum]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.museum = Museum.collection(response: response, representation: data as AnyObject)
        }
    }
}
