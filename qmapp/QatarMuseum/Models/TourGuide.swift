//
//  TourGuide.swift
//  QatarMuseums
//
//  Created by Developer on 26/09/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import Foundation
struct TourGuide: ResponseObjectSerializable, ResponseCollectionSerializable {
    var title: String? = nil
    var tourGuideDescription: String? = nil
    var multimediaFile: [String]? = []
    var museumsEntity: String? = nil
    var nid: String? = nil
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["Title"] as? String
            self.tourGuideDescription = representation["Description"] as? String
            self.multimediaFile = representation["multimedia"] as? [String]
            self.museumsEntity = representation["Museums_entity"] as? String
            self.nid = representation["Nid"] as? String
        }
    }
    
    init(title:String?, tourGuideDescription:String?, multimediaFile:[String]?, museumsEntity:String?,nid:String?) {
        self.title = title
        self.tourGuideDescription = tourGuideDescription
        self.multimediaFile = multimediaFile
        self.museumsEntity = museumsEntity
        self.nid = nid
    }
}

struct TourGuides: ResponseObjectSerializable {
    var tourGuide: [TourGuide]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.tourGuide = TourGuide.collection(response: response, representation: data as AnyObject)
        }
    }
}
