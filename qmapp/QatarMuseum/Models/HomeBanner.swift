//
//  HomeBanner.swift
//  QatarMuseums
//
//  Created by Exalture on 27/11/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import Foundation
struct HomeBanner: ResponseObjectSerializable, ResponseCollectionSerializable {
    var title: String? = nil
    var fullContentID: String? = nil
    var bannerTitle: String? = nil
    var bannerLink: String? = nil
    var image: [String]? = []
    //for Travel List
    var introductionText: String? = nil
    var email: String? = nil
    var contactNumber: String? = nil
    var promotionalCode: String? = nil
    var claimOffer: String? = nil
    var language: String?

    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["Title"] as? String
            self.fullContentID = representation["full_content_ID"] as? String
            self.bannerTitle = representation["Banner_title"] as? String
            self.bannerLink = representation["banner_link"] as? String
            self.image = representation["Image"] as? [String]
            //for Travel List
            self.introductionText = representation["Introduction_Text"] as? String
            self.email = representation["email"] as? String
            self.contactNumber = representation["contact_number"] as? String
            self.promotionalCode = representation["Promotional_code"] as? String
            self.claimOffer = representation["claim_offer"] as? String
            self.language = representation["language"] as? String
        }
    }
    
    init(entity: HomeBannerEntity) {
        
        var imagesArray : [String] = []
        if let imagesInfoArray = (entity.bannerImageRelations?.allObjects) as? [ImageEntity] {
            for info in imagesInfoArray {
                if let image = info.image {
                    imagesArray.append(image)
                }
            }
        }
        
        self.title = entity.title
        self.fullContentID = entity.fullContentID
        self.bannerTitle = entity.bannerTitle
        self.bannerLink = entity.bannerLink
        self.image = imagesArray
        //for Travel List
        self.introductionText = entity.introductionText
        self.email = entity.email
        self.contactNumber = entity.contactNumber
        self.promotionalCode = entity.promotionalCode
        self.claimOffer = entity.claimOffer
        self.language = entity.language
    }
    
    init(travelEntity: NMoQTravelListEntity) {
        self.title = travelEntity.title
        self.fullContentID = travelEntity.fullContentID
        self.bannerTitle = travelEntity.bannerTitle
        self.bannerLink = travelEntity.bannerLink
        //for Travel List
        self.introductionText = travelEntity.introductionText
        self.email = travelEntity.email
        self.contactNumber = travelEntity.contactNumber
        self.promotionalCode = travelEntity.promotionalCode
        self.claimOffer = travelEntity.claimOffer
        self.language = travelEntity.language
    }
}

struct HomeBannerList: ResponseObjectSerializable {
    var homeBannerList: [HomeBanner]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.homeBannerList = HomeBanner.collection(response: response, representation: data as AnyObject)
        }
    }
}
