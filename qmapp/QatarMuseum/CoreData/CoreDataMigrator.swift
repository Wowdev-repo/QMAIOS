//
//  CoreDataMigrator.swift
//  QatarMuseums
//
//  Created by Developer on 27/03/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation
import CoreData

class CoreDataMigrator {
    
    // MARK: - Check
    
    func requiresMigration(at storeURL: URL, currentMigrationModel: CoreDataMigrationModel = CoreDataMigrationModel.current) -> Bool {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL) else {
            return false
        }
        
        return !currentMigrationModel.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
    }
    
    // MARK: - Migration
    
    func migrateStore(at storeURL: URL) {
        migrateStore(from: storeURL, to: storeURL, targetVersion: CoreDataMigrationModel.current)
    }
    
    func migrateStore(from sourceURL: URL, to targetURL: URL, targetVersion: CoreDataMigrationModel) {
        guard let sourceMigrationModel = CoreDataMigrationSourceModel(storeURL: sourceURL as URL) else {
            fatalError("unknown store version at URL \(sourceURL)")
        }
        forceWALCheckpointingForStore(at: sourceURL)
        
        var currentURL = sourceURL
        let migrationSteps = sourceMigrationModel.migrationSteps(to: targetVersion)
        
        for step in migrationSteps {
            let manager = NSMigrationManager(sourceModel: step.source, destinationModel: step.destination)
            let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString)
            
            do {
                try manager.migrateStore(from: currentURL, sourceType: NSSQLiteStoreType, options: nil, with: step.mapping, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
            } catch let error {
                fatalError("failed attempting to migrate from \(step.source) to \(step.destination), error: \(error)")
            }
            
            if currentURL != sourceURL {
                //Destroy intermediate step's store
                NSPersistentStoreCoordinator.destroyStore(at: currentURL)
            }
            
            currentURL = destinationURL
        }
        
        NSPersistentStoreCoordinator.replaceStore(at: targetURL, withStoreAt: currentURL)
        
        if (currentURL != sourceURL) {
            NSPersistentStoreCoordinator.destroyStore(at: currentURL)
        }
    }
    
    // MARK: - WAL
    
    func forceWALCheckpointingForStore(at storeURL: URL) {
        guard let metadata = NSPersistentStoreCoordinator.metadata(at: storeURL), let migrationModel = CoreDataMigrationModel.migrationModelCompatibleWithStoreMetadata(metadata)  else {
            return
        }
        
        do {
            let model = migrationModel.managedObjectModel()
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            
            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            let store = persistentStoreCoordinator.addPersistentStore(at: storeURL, options: options)
            try persistentStoreCoordinator.remove(store)
        } catch let error {
            fatalError("failed to force WAL checkpointing, error: \(error)")
        }
    }
}

extension NSPersistentStoreCoordinator {
    
    // MARK: - Destroy
    
    static func destroyStore(at storeURL: URL) {
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
        } catch let error {
            fatalError("failed to destroy persistent store at \(storeURL), error: \(error)")
        }
    }
    
    // MARK: - Replace
    
    static func replaceStore(at targetURL: URL, withStoreAt sourceURL: URL) {
        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
            try persistentStoreCoordinator.replacePersistentStore(at: targetURL, destinationOptions: nil, withPersistentStoreFrom: sourceURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
        } catch let error {
            fatalError("failed to replace persistent store at \(targetURL) with \(sourceURL), error: \(error)")
        }
    }
    
    // MARK: - Meta
    
    static func metadata(at storeURL: URL) -> [String : Any]?  {
        return try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
    }
    
    // MARK: - Add
    
    func addPersistentStore(at storeURL: URL, options: [AnyHashable : Any]) -> NSPersistentStore {
        do {
            return try addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch let error {
            fatalError("failed to add persistent store to coordinator, error: \(error)")
        }
        
    }
}

