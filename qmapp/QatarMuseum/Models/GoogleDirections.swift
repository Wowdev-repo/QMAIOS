//
//  GoogleDirections.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 13/12/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct GoogleDirections: ResponseObjectSerializable {
    
    
    var routes: [String]? = []
    
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            
            self.routes = (representation["routes"] as? [String])
            
            
        }
        
    }
}
