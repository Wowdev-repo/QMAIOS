//
//  CoreDataMigrationModel.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 27/03/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation



class CPCoreDataMigrationModel {
    
    let version: CPCoreDataVersion
    
    var modelBundle: Bundle {
        return Bundle.main
    }
    
    var modelDirectoryName: String {
        return "QatarMuseums.momd"
    }
    
    static var all: [CPCoreDataMigrationModel] {
        var migrationModels = [CPCoreDataMigrationModel]()
        
        for version in CPCoreDataVersion.all {
            migrationModels.append(CPCoreDataMigrationModel(version: version))
        }
        
        return migrationModels
    }
    
    static var current: CPCoreDataMigrationModel {
        return CPCoreDataMigrationModel(version: CPCoreDataVersion.latest)
    }
    
    /**
     Determines the next model version from the current model version.
     
     NB: the next version migration is not always the next actual version. With
     this solution we can skip "bad/corrupted" versions.
     */
    var successor: CPCoreDataMigrationModel? {
        switch self.version {
        case .version1:
            return CPCoreDataMigrationModel(version: .version2)
        case .version2:
            return CPCoreDataMigrationModel(version: .version3)
        case .version3:
            return CPCoreDataMigrationModel(version: .version4)
        case .version4:
            return nil
        }
    }
    
    // MARK: - Init
    
    init(version: CPCoreDataVersion) {
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), urls: \(url), , model: \(model)")
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
    
    func inferredMappingModel(to nextVersion: CPCoreDataMigrationModel) -> NSMappingModel {
        do {
            let sourceModel = managedObjectModel()
            let destinationModel = nextVersion.managedObjectModel()
            return try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
        } catch {
            fatalError("unable to generate inferred mapping model")
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func customMappingModel(to nextVersion: CPCoreDataMigrationModel) -> NSMappingModel? {
        let sourceModel = managedObjectModel()
        let destinationModel = nextVersion.managedObjectModel()
        guard let mapping = NSMappingModel(from: [modelBundle], forSourceModel: sourceModel, destinationModel: destinationModel) else {
            return nil
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        return mapping
    }
    
    // MARK: - MigrationSteps
    
    func migrationSteps(to version: CPCoreDataMigrationModel) -> [CPCoreDataMigrationStep] {
        guard self.version != version.version else {
            return []
        }
        
        guard let mapping = mappingModelToSuccessor(), let nextVersion = successor else {
            return []
        }
        
        let sourceModel = managedObjectModel()
        let destinationModel = nextVersion.managedObjectModel()
        
        let step = CPCoreDataMigrationStep(source: sourceModel, destination: destinationModel, mapping: mapping)
        let nextStep = nextVersion.migrationSteps(to: version)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        return [step] + nextStep
    }
    
    // MARK: - Metadata
    
    static func migrationModelCompatibleWithStoreMetadata(_ metadata: [String : Any]) -> CPCoreDataMigrationModel? {
        let compatibleMigrationModel = CPCoreDataMigrationModel.all.first {
            $0.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
//        DDLogInfo(NSStringFromClass(type(of: self) as! AnyClass) + "Function: \(#function)")
        return compatibleMigrationModel
    }
}

class CoreDataMigrationSourceModel: CPCoreDataMigrationModel {
    
    // MARK: - Init
    
    init?(storeURL: URL) {
        DDLogInfo("File: \(#file)" + "Function: \(#function)")
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL) else {
            return nil
        }
        
        let migrationVersionModel = CPCoreDataMigrationModel.all.first {
            $0.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        
        guard migrationVersionModel != nil else {
            return nil
        }
        
        super.init(version: (migrationVersionModel?.version)!)
    }
}

