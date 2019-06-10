//
//  GoogleDirections.swift
//  QatarMuseums
//
//  Created by Wakralab on 13/12/18.
//  Copyright © 2018 Qatar museums. All rights reserved.
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
