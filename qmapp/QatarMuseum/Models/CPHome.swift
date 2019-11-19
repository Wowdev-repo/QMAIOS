//
//  Home.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 27/07/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation

struct CPHome: CPResponseObjectSerializable, CPResponseCollectionSerializable {
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
    
    init(entity: HomeEntity) {
        self.id = entity.id
        self.name = entity.name
        self.image = entity.image
        self.isTourguideAvailable = entity.tourguideavailable
        self.sortId = String(entity.sortid)
    }
}

struct HomeList: CPResponseObjectSerializable {
    var homeList: [CPHome]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.homeList = CPHome.collection(response: response, representation: data as AnyObject)
        }
    }
}