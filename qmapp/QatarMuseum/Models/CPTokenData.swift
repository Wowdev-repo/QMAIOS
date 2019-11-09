//
//  CPTokenData.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 23/10/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct CPTokenData: CPResponseObjectSerializable {
    var accessToken: String? = nil
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.accessToken = representation["token"] as? String
            
        }
    }
}

struct DeviceToken: CPResponseObjectSerializable {
    var success: Int? = nil
    var message: String? = nil

    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.success = representation["success"] as? Int
            self.message = representation["message"] as? String
        }
    }
}
