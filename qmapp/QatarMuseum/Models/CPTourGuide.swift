//
//  CPTourGuide.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 26/09/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct CPTourGuide: CPResponseObjectSerializable, CPResponseCollectionSerializable {
    var title: String? = nil
    var tourGuideDescription: String? = nil
    var multimediaFile: [String]? = []
    var museumsEntity: String? = nil
    var nid: String? = nil
    var language: String?
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["Title"] as? String
            self.tourGuideDescription = representation["Description"] as? String
            self.multimediaFile = representation["multimedia"] as? [String]
            self.museumsEntity = representation["Museums_entity"] as? String
            self.nid = representation["Nid"] as? String
            self.language = representation["language"] as? String
        }
    }
    
    init(entity: TourGuideEntity) {
        
        var imagesArray : [String] = []
        if let imagesInfoArray = (entity.tourGuideMultimediaRelation?.allObjects) as? [TourGuideMultimediaEntity] {
            for info in imagesInfoArray {
                if let image = info.multimediaFile {
                    imagesArray.append(image)
                }
            }
        }
        
        self.title = entity.title
        self.tourGuideDescription = entity.tourGuideDescription
        self.multimediaFile = imagesArray
        self.museumsEntity = entity.museumsEntity
        self.nid = entity.nid
        self.language = entity.language
    }
}

struct TourGuides: CPResponseObjectSerializable {
    var tourGuide: [CPTourGuide]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.tourGuide = CPTourGuide.collection(response: response, representation: data as AnyObject)
        }
    }
}