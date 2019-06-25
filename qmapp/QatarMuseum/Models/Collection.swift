//
//  Collection.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 17/08/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation

struct Collection: ResponseObjectSerializable, ResponseCollectionSerializable {
    var name: String? = nil
    var image: String? = nil
    //var category: String? = nil
   // var collectionDescription: String? = nil
    var museumId: String? = nil
    //For Detail Page
//    var title : String? = nil
//    var body : String? = nil
//    var nid : String? = nil
//    var categoryCollection : String? = nil
   
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.name = representation["Name"] as? String
            self.image = representation["image"] as? String
            self.museumId = representation["Museums_reference"] as? String
             //For Detail Page
//            self.title = representation["Title"] as? String
//            self.body = representation["Body"] as? String
//            self.nid = representation["nid"] as? String
//            self.categoryCollection = representation["Category collection"] as? String
            
        }
    }
    init(name:String?,image:String?,museumId:String?) {
        self.name = name
        self.image = image
        self.museumId = museumId
        //For Detail Page
//        self.title = title
//        self.body = body
//
//        self.nid = nid
//        self.categoryCollection = categoryCollection
        
    }
    
    init(entity: CollectionsEntity) {
        self.name = entity.listName?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;",
                                                          with: "",
                                                          options: .regularExpression,
                                                          range: nil)
        self.image = entity.listImage
        self.museumId = entity.museumId
    }
}

struct Collections: ResponseObjectSerializable {
    var collections: [Collection]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.collections = Collection.collection(response: response, representation: data as AnyObject)
        }
    }
}
