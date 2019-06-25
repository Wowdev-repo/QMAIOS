//
//  CoreDataMigrationStep.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 27/03/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation


struct CoreDataMigrationStep {
    
    let source: NSManagedObjectModel
    let destination: NSManagedObjectModel
    let mapping: NSMappingModel
}

