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
        }
    }
    
    init (title:String?, fullContentID: String?, bannerTitle: String?, bannerLink: String?, image: [String]?,introductionText:String?, email: String?, contactNumber: String?, promotionalCode: String?,claimOffer: String?) {
        self.title = title
        self.fullContentID = fullContentID
        self.bannerTitle = bannerTitle
        self.bannerLink = bannerLink
        self.image = image
        //for Travel List
        self.introductionText = introductionText
        self.email = email
        self.contactNumber = contactNumber
        self.promotionalCode = promotionalCode
        self.claimOffer = claimOffer
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
