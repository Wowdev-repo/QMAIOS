//
//  CPNMoQActivitiesList.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 20/03/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
struct CPNMoQActivitiesList: CPResponseObjectSerializable, CPResponseCollectionSerializable {
    var title: String? = nil
    var dayDescription: String? = nil
    var images: [String]? = []
    var subtitle: String? = nil
    var sortId: String? = nil
    var nid: String? = nil
    var eventDate: String? = nil
    var date: String? = nil
    var descriptioForModerator: String? = nil
    var mobileLatitude: String? = nil
    var moderatorName: String? = nil
    var longitude: String? = nil
    var contactEmail: String? = nil
    var contactPhone: String? = nil
    var language: String?
    
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["Day"] as? String
            self.dayDescription = representation["descriptif_day"] as? String
            self.images = representation["Images"] as? [String]
            self.subtitle = representation["subtitle"] as? String
            self.sortId = representation["sort_id"] as? String
            self.nid = representation["nid"] as? String
            self.eventDate = representation["NMoq_event_Date"] as? String
            //For Special Events
            self.date = representation["Date"] as? String
            self.descriptioForModerator = representation["description_for_moderator"] as? String
            self.mobileLatitude = representation["latitude"] as? String
            self.moderatorName = representation["moderator_name"] as? String
            self.longitude = representation["longitude"] as? String
            self.contactEmail = representation["contact_email"] as? String
            self.contactPhone = representation["contact_phone"] as? String
            self.language = representation["language"] as? String
        }
    }
    
    init (title:String?, dayDescription: String?, images: [String]?, subtitle: String?,sortId:String?, nid: String?, eventDate: String?, date: String?, descriptioForModerator: String?, mobileLatitude: String?,moderatorName:String?, longitude: String?, contactEmail: String?, contactPhone: String?, language: String?) {
        self.title = title
        self.dayDescription = dayDescription
        self.images = images
        self.subtitle = subtitle
        self.sortId = sortId
        self.nid = nid
        self.eventDate = eventDate
        self.date = date
        self.descriptioForModerator = descriptioForModerator
        self.mobileLatitude = mobileLatitude
        self.moderatorName = moderatorName
        self.longitude = longitude
        self.contactEmail = contactEmail
        self.contactPhone = contactPhone
        self.language = language
    }
    
        
    init(entity: NMoQActivitiesEntity) {
        
        var imagesArray : [String] = []
        if let imagesInfoArray = (entity.activityImgRelation?.allObjects) as? [ImageEntity] {
            for info in imagesInfoArray {
                if let image = info.image {
                    imagesArray.append(image)
                }
            }
        }
        self.title = entity.title
        self.dayDescription = entity.dayDescription
        self.images = imagesArray
        self.subtitle = entity.subtitle
        self.sortId = entity.sortId
        self.nid = entity.nid
        self.eventDate = entity.eventDate
        self.date = entity.date
        self.descriptioForModerator = entity.descriptioForModerator
        self.mobileLatitude = entity.mobileLatitude
        self.moderatorName = entity.moderatorName
        self.longitude = entity.longitude
        self.contactEmail = entity.contactEmail
        self.contactPhone = entity.contactPhone
        self.language = entity.language
    }
}

struct NMoQActivitiesListData: CPResponseObjectSerializable {
    var nmoqActivitiesList: [CPNMoQActivitiesList]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.nmoqActivitiesList = CPNMoQActivitiesList.collection(response: response, representation: data as AnyObject)
        }
    }
}