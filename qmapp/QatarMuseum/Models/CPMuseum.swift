//
//  CPMuseum.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 22/08/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct CPMuseum: CPResponseObjectSerializable, CPResponseCollectionSerializable {
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
    var multimediaVideo: [String]? = []
    var eventDate: String? = nil
    var downloadable: [String]? = []
    var language = "1"
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            
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
            self.multimediaVideo = representation["multimedia_video"] as? [String]
            self.eventDate = representation["event_Date"] as? String
            self.downloadable = representation["downloadable"] as? [String]
        }
    }
  
    init(name:String?, id: String? = nil,
         tourguideAvailable:String? = nil,
         contactNumber:String? = nil,
         contactEmail:String? = nil,
         mobileLongtitude:String? = nil,
         subtitle:String? = nil,
         openingTime:String? = nil,
         mobileDescription:[String]? = nil,
         multimediaFile:[String]? = nil,
         mobileLatitude:String? = nil,
         tourGuideAvailability:String? = nil,
         multimediaVideo:[String]? = nil,
         downloadable:[String]? = nil,
         eventDate:String? = nil) {
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
            self.multimediaVideo = multimediaVideo
            self.downloadable = downloadable
            self.eventDate = eventDate
    }
    
    init(entity: AboutEntity) {
        self.name = entity.name
        self.id = entity.id
        self.tourguideAvailable = entity.tourguideAvailable
        self.contactNumber = entity.contactNumber
        self.contactEmail = entity.contactEmail
        self.mobileLongtitude = entity.mobileLongtitude
        self.subtitle = entity.subtitle
        self.openingTime = entity.openingTime
        self.mobileLatitude = entity.mobileLatitude
        self.tourGuideAvailability = entity.tourGuideAvailability
        
//        self.multimediaVideo = entity.multimediaVideo
//        self.downloadable = entity.downloadable
//        self.eventDate = entity.eventDate
        
        
        if let aboutInfoArray = (entity.mobileDescRelation?.allObjects) as? [AboutDescriptionEntity] {
            var descriptionArray = [String]()
            for _ in aboutInfoArray {
                descriptionArray.append("")
            }
            for info in aboutInfoArray {
                descriptionArray.remove(at: Int(info.id))
                if let mobileDesc = info.mobileDesc {
                    descriptionArray.insert(mobileDesc, at: Int(info.id))
                }
            }
            self.mobileDescription = descriptionArray
        }
        
        if let mutimediaInfoArray = (entity.multimediaRelation?.allObjects) as? [AboutMultimediaFileEntity] {
            var multimediaArray = [String]()
            for info in mutimediaInfoArray {
                if let image = info.image {
                    multimediaArray.append(image)
                }
            }
            self.multimediaFile = multimediaArray
        }
        
        
        var downloadArray : [String] = []
        let downloadInfoArray = (entity.downloadLinkRelation?.allObjects) as! [AboutDownloadLinkEntity]
        if(downloadInfoArray.count > 0) {
            for i in 0 ... downloadInfoArray.count-1 {
                downloadArray.append(downloadInfoArray[i].downloadLink!)
            }
        }
        
    }
}

struct Museums: CPResponseObjectSerializable {
    var museum: [CPMuseum]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.museum = CPMuseum.collection(response: response, representation: data as AnyObject)
        }
    }
}
