//
//  Facilities.swift
//  QatarMuseums
//
//  Created by Exalture on 18/03/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation
struct Facilities: ResponseObjectSerializable, ResponseCollectionSerializable {
    var title: String? = nil
    var sortId: String? = nil
    var nid: String? = nil
    var images: [String]? = []
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["Title"] as? String
            self.sortId = representation["sort_id"] as? String
            self.nid = representation["nid"] as? String
            self.images = representation["images "] as? [String]
            
        }
    }
    
    init (title:String?, sortId: String?,nid: String?, images: [String]?) {
        self.title = title
        self.images = images
        self.sortId = sortId
        self.nid = nid
    }
}

struct FacilitiesData: ResponseObjectSerializable {
    var facilitiesList: [Facilities]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.facilitiesList = Facilities.collection(response: response, representation: data as AnyObject)
        }
    }
}

