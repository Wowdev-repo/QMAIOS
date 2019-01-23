//
//  LogoutData.swift
//  QatarMuseums
//
//  Created by Exalture on 24/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import Foundation
struct LogoutData: ResponseObjectSerializable {
    var uid: Int? = 0
    var hostName: String? = nil
    var roles: [String: Any] = [:]
    var cache: Int? = 0
    
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.uid = representation["uid"] as? Int
            self.hostName = representation["hostname"] as? String
            self.roles = (representation["roles"] as? [String: Any])!
            self.cache = representation["cache"] as? Int
            
        }
    }
}
