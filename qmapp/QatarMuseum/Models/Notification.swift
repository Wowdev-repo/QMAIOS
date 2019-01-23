//
//  Notification.swift
//  QatarMuseums
//
//  Created by Developer on 01/11/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import Foundation
class Notification:  NSObject, NSCoding {
    var title: String? = nil
    var sortId: String? = nil
    
    init(title:String?, sortId: String?) {
        self.title = title
        self.sortId = sortId
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        self.sortId = aDecoder.decodeObject(forKey: "sortId") as? String ?? ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(sortId, forKey: "sortId")
    }
}

struct Notifications: ResponseObjectSerializable {
    var notification: [Notification]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
//            self.notification = Notification.collection(response: response, representation: data as AnyObject)
        }
    }
}
