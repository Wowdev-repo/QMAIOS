//
//  CPCollectionDetail.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 19/09/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct CPCollectionDetail: CPResponseObjectSerializable, CPResponseCollectionSerializable {
    
    var title : String? = nil
    var image: String? = nil
    var body : String? = nil
    var nid : String? = nil
    var categoryCollection : String? = nil
    
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
           
            self.title = representation["Title"] as? String
            self.image = representation["image"] as? String
            self.body = representation["Body"] as? String
            self.nid = representation["nid"] as? String
            self.categoryCollection = representation["Category_collection"] as? String
            
        }
    }
    
    init(entity: CollectionDetailsEntity) {
        self.title = entity.title
        self.image = entity.image
        self.body = entity.body
        self.nid = entity.nid
        self.categoryCollection = entity.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;",
                                                                                  with: "",
                                                                                  options: .regularExpression)
    }
}

struct CollectionDetails: CPResponseObjectSerializable {
    var collectionDetails: [CPCollectionDetail]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.collectionDetails = CPCollectionDetail.collection(response: response, representation: data as AnyObject)
        }
    }
}
