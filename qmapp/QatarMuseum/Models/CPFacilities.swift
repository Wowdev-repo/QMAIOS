//
//  CPFacilities.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 18/03/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
struct CPFacilities: CPResponseObjectSerializable, CPResponseCollectionSerializable {
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

struct FacilitiesData: CPResponseObjectSerializable {
    var facilitiesList: [CPFacilities]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.facilitiesList = CPFacilities.collection(response: response, representation: data as AnyObject)
        }
    }
}
