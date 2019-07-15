//
//  CoreDataVersion.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 27/03/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation

enum CoreDataVersion: Int {
    case version1 = 1
    case version2
    case version3
    case version4
    
    // MARK: - Accessors
    
    var name: String {
        if rawValue == 1 {
            return "QatarMuseums"
        } else {
            return "QatarMuseums_V\(rawValue)"
        }
    }
    
    static var all: [CoreDataVersion] {
        var versions = [CoreDataVersion]()
        
        for rawVersionValue in 1...1000 { // A bit of a hack here to avoid manual mapping
            if let version = CoreDataVersion(rawValue: rawVersionValue) {
                versions.append(version)
                continue
            }
            
            break
        }
        
        return versions.reversed()
    }
    
    static var latest: CoreDataVersion {
        return all.first!
    }
}

