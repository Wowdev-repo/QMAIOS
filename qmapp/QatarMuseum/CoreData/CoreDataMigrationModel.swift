//
//  CoreDataMigrationModel.swift
//  QatarMuseums
//
//  Created by Developer on 27/03/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation
import CoreData

class CoreDataMigrationModel {
    
    let version: CoreDataVersion
    
    var modelBundle: Bundle {
        return Bundle.main
    }
    
    var modelDirectoryName: String {
        return "QatarMuseums.momd"
    }
    
    static var all: [CoreDataMigrationModel] {
        var migrationModels = [CoreDataMigrationModel]()
        
        for version in CoreDataVersion.all {
            migrationModels.append(CoreDataMigrationModel(version: version))
        }
        
        return migrationModels
    }
    
    static var current: CoreDataMigrationModel {
        return CoreDataMigrationModel(version: CoreDataVersion.latest)
    }
    
    /**
     Determines the next model version from the current model version.
     
     NB: the next version migration is not always the next actual version. With
     this solution we can skip "bad/corrupted" versions.
     */
    var successor: CoreDataMigrationModel? {
        switch self.version {
        case .version1:
            return CoreDataMigrationModel(version: .version2)
        case .version2:
            return CoreDataMigrationModel(version: .version3)
        case .version3:
            return nil
        }
    }
    
    // MARK: - Init
    
    init(version: CoreDataVersion) {
        self.version = version
    }
    
    // MARK: - Model
    
    func managedObjectModel() -> NSManagedObjectModel {
        let omoURL = modelBundle.url(forResource: version.name, withExtension: "omo", subdirectory: modelDirectoryName) // optimized model file
        let momURL = modelBundle.url(forResource: version.name, withExtension: "mom", subdirectory: modelDirectoryName)
        
        guard let url = omoURL ?? momURL else {
            fatalError("unable to find model in bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("unable to load model in bundle")
        }
        
        return model
    }
    
    // MARK: - Mapping
    
    func mappingModelToSuccessor() -> NSMappingModel? {
        guard let nextVersion = successor else {
            return nil
        }
        
        switch version {
        case .version1: //manual mapped versions
            guard let mapping = customMappingModel(to: nextVersion) else {
                return nil
            }
            
            return mapping
        default:
            return inferredMappingModel(to: nextVersion)
        }
    }
    
    func inferredMappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel {
        do {
            let sourceModel = managedObjectModel()
            let destinationModel = nextVersion.managedObjectModel()
            return try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
        } catch {
            fatalError("unable to generate inferred mapping model")
        }
    }
    
    func customMappingModel(to nextVersion: CoreDataMigrationModel) -> NSMappingModel? {
        let sourceModel = managedObjectModel()
        let destinationModel = nextVersion.managedObjectModel()
        guard let mapping = NSMappingModel(from: [modelBundle], forSourceModel: sourceModel, destinationModel: destinationModel) else {
            return nil
        }
        
        return mapping
    }
    
    // MARK: - MigrationSteps
    
    func migrationSteps(to version: CoreDataMigrationModel) -> [CoreDataMigrationStep] {
        guard self.version != version.version else {
            return []
        }
        
        guard let mapping = mappingModelToSuccessor(), let nextVersion = successor else {
            return []
        }
        
        let sourceModel = managedObjectModel()
        let destinationModel = nextVersion.managedObjectModel()
        
        let step = CoreDataMigrationStep(source: sourceModel, destination: destinationModel, mapping: mapping)
        let nextStep = nextVersion.migrationSteps(to: version)
        
        return [step] + nextStep
    }
    
    // MARK: - Metadata
    
    static func migrationModelCompatibleWithStoreMetadata(_ metadata: [String : Any]) -> CoreDataMigrationModel? {
        let compatibleMigrationModel = CoreDataMigrationModel.all.first {
            $0.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        
        return compatibleMigrationModel
    }
}

class CoreDataMigrationSourceModel: CoreDataMigrationModel {
    
    // MARK: - Init
    
    init?(storeURL: URL) {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL) else {
            return nil
        }
        
        let migrationVersionModel = CoreDataMigrationModel.all.first {
            $0.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        
        guard migrationVersionModel != nil else {
            return nil
        }
        
        super.init(version: (migrationVersionModel?.version)!)
    }
}

