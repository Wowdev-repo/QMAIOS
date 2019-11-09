//
//  CPNotification.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 01/11/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
class CPNotification:  NSObject, NSCoding {
    var title: String? = nil
    var sortId: String? = nil
    var language: String?
    
    init(title:String?, sortId: String?, language: String?) {
        self.title = title
        self.sortId = sortId
        self.language = language
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        self.sortId = aDecoder.decodeObject(forKey: "sortId") as? String ?? ""
        self.language = aDecoder.decodeObject(forKey: "language") as? String ?? ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(sortId, forKey: "sortId")
        aCoder.encode(language, forKey: "language")
    }
}

struct Notifications: CPResponseObjectSerializable {
    var notification: [CPNotification]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
//            self.notification = Notification.collection(response: response, representation: data as AnyObject)
        }
    }
}
