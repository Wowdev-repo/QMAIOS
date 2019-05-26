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

    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.images = representation["images"] as? [String]
            self.nid = representation["Nid"] as? String
            self.sortId = representation["sort_id"] as? String
            self.title = representation["title"] as? String
            self.parkDesc = representation["Description"] as? String
        }
    }
    
    init (title:String?, sortId: String?, nid: String?, images: [String]?, parkDesc: String?) {
        self.title = title
        self.sortId = sortId
        self.nid = nid
        self.images = images
        self.parkDesc = parkDesc
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

