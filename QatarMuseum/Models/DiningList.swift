//
//  DiningList.swift
//  QatarMuseums
//
//  Created by Exalture on 02/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation
struct DiningList: ResponseObjectSerializable, ResponseCollectionSerializable {
    var id: String? = nil
    var name: String? = nil
    var location: String? = nil
    var description: String? = nil
    var image: String? = nil
    var openingtime: String? = nil
    var closetime: String? = nil
    var sortid: String? = nil
    
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.id = representation["ID"] as? String
            self.name = representation["name"] as? String
            self.location = representation["Location"] as? String
            self.description = representation["Description"] as? String
            self.image = representation["Image "] as? String
            self.openingtime = representation["opening time"] as? String
            self.closetime = representation["close time"] as? String
            self.sortid = representation["sort id"] as? String
            
        }
    }
}

struct DiningLists: ResponseObjectSerializable {
    var diningLists: [DiningList]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.diningLists = DiningList.collection(response: response, representation: data as AnyObject)
        }
    }
}

