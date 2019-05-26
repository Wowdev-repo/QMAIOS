//
//  Home.swift
//  QatarMuseums
//
//  Created by Developer on 27/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation

struct Home: ResponseObjectSerializable, ResponseCollectionSerializable {
    var id: String? = nil
    var name: String? = nil
    var image: String? = nil
    var isTourguideAvailable: String? = nil
    var sortId: String? = nil
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.id = representation["id"] as? String
            self.name = representation["name"] as? String
            self.image = representation["image"] as? String
            self.isTourguideAvailable = representation["tourguide_available"] as? String
            self.sortId = representation["SORt_ID"] as? String
        }
    }
    
    init (id:String?, name: String?, image: String?, tourguide_available: String?, sort_id: String?) {
        self.id = id
        self.name = name
        self.image = image
        self.isTourguideAvailable = tourguide_available
        self.sortId = sort_id
    }
}

struct HomeList: ResponseObjectSerializable {
    var homeList: [Home]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.homeList = Home.collection(response: response, representation: data as AnyObject)
        }
    }
}
