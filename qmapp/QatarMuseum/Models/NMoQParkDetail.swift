//
//  NMoQParkDetail.swift
//  QatarMuseums
//
//  Created by Developer on 22/03/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation

struct NMoQParkDetail: ResponseObjectSerializable, ResponseCollectionSerializable {
    var images: [String]? = []
    var nid: String? = nil
    var sortId: String? = nil
    var title: String? = nil
    var parkDesc: String? = nil
    var language: String?

    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.images = representation["images"] as? [String]
            self.nid = representation["Nid"] as? String
            self.sortId = representation["sort_id"] as? String
            self.title = representation["title"] as? String
            self.parkDesc = representation["Description"] as? String
            self.language = representation["language"] as? String
        }
    }
    
    init (title:String?, sortId: String?, nid: String?, images: [String]?, parkDesc: String?, language: String?) {
        self.title = title
        self.sortId = sortId
        self.nid = nid
        self.images = images
        self.parkDesc = parkDesc
        self.language = language
    }
    
    init(entity: NMoQParkDetailEntity) {
        var imagesArray : [String] = []
        if let imagesInfoArray = (entity.parkDetailImgRelation?.allObjects) as? [ImageEntity] {
            for info in imagesInfoArray {
                if let image = info.image {
                    imagesArray.append(image)
                }
            }
        }
        
        self.title = entity.title
        self.sortId = entity.sortId
        self.nid = entity.nid
        self.images = imagesArray
        self.parkDesc = entity.parkDesc
        self.language = entity.language
    }
}

struct NMoQParksDetail: ResponseObjectSerializable {
    var nmoqParksDetail: [NMoQParkDetail]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.nmoqParksDetail = NMoQParkDetail.collection(response: response, representation: data as AnyObject)
        }
    }
}

