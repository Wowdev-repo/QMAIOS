//
//  CPNMoQUserEventList.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 07/12/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct CPNMoQUserEventList: CPResponseObjectSerializable, CPResponseCollectionSerializable {
    var title: String? = nil
    var eventID: String? = nil
    var regID: String? = nil
    var seats: String? = nil
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.title = representation["Title"] as? String
            self.eventID = representation["event_ID"] as? String
            self.regID = representation["reg_id"] as? String
            self.seats = representation["Seats"] as? String
            
        }
    }
    
    init (title:String?, eventID: String?, regID: String?, seats: String?) {
        self.title = title
        self.eventID = eventID
        self.regID = regID
        self.seats = seats
    }
}

struct NMoQUserEventListValues: CPResponseObjectSerializable {
    var eventList: [CPNMoQUserEventList]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.eventList = CPNMoQUserEventList.collection(response: response, representation: data as AnyObject)
        }
    }
}
