//
//  CoreDataMigrationStep.swift
//  QatarMuseums
//
//  Created by Developer on 27/03/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataMigrationStep {
    
    let source: NSManagedObjectModel
    let destination: NSManagedObjectModel
    let mapping: NSMappingModel
}

