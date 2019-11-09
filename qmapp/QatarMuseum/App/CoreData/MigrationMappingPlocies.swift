//
//  MigrationMappingPlocies.swift
//  QatarMuseums
//
//  Created by Exalture on 16/07/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation

class ImageMigrationPolicyFrom3To4: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        if let modelVersion = mapping.userInfo?["modelVersion"] as? String, modelVersion == "4" {
        
            var lang = "0"
            var langKey = "lang"
            var sourceRelationName = ""
            var destinationRelationName = ""
            
            switch sInstance.entity.name {
            case "FacilitiesEntity":
                sourceRelationName = "facilitiesImgRelation"
                destinationRelationName = "facilitiesImgRelation"
                lang = "1"
                
            case "FacilitiesDetailEntity":
                sourceRelationName = "facilitiesDetailRelation"
                destinationRelationName = "facilitiesDetailRelation"
                lang = "1"
                
            case "FacilitiesEntityAr":
                sourceRelationName = "facilitiesImgRelationAr"
                destinationRelationName = "facilitiesImgRelation"
                
            case "FacilitiesDetailEntityAr":
                sourceRelationName = "facilitiesDetailRelationAr"
                destinationRelationName = "facilitiesDetailRelation"
                
            case "DiningEntity", "FloorMapTourGuideEntity", "HeritageEntity":
                sourceRelationName = "imagesRelation"
                destinationRelationName = "imagesRelation"
                lang = "1"
                
            case "DiningEntityAr", "FloorMapTourGuideEntityAr":
                sourceRelationName = "imagesRelation"
                destinationRelationName = "imagesRelation"
                
            case "HomeBannerEntity":
                sourceRelationName = "bannerImageRelations"
                destinationRelationName = "bannerImageRelations"
                lang = "1"
                
            case "HomeBannerEntityAr":
                sourceRelationName = "bannerImageRelationsAr"
                destinationRelationName = "bannerImageRelations"
             
            case "NMoQActivitiesEntity":
                sourceRelationName = "activityImgRelation"
                destinationRelationName = "activityImgRelation"
                lang = "1"
                
            case "NMoQActivitiesEntityAr":
                sourceRelationName = "activityImgRelationAr"
                destinationRelationName = "activityImgRelation"
            
            case "NMoQParkDetailEntity":
                sourceRelationName = "parkDetailImgRelation"
                destinationRelationName = "parkDetailImgRelation"
                lang = "1"
                
            case "NMoQParkDetailEntityAr":
                sourceRelationName = "parkDetailImgRelationAr"
                destinationRelationName = "parkDetailImgRelation"
             
            case "NMoQParksEntity":
                sourceRelationName = "parkImgRelation"
                destinationRelationName = "parkImgRelation"
                lang = "1"
                
            case "NMoQParksEntityAr":
                sourceRelationName = "parkImgRelationAr"
                destinationRelationName = "parkImgRelation"
                
            case "NmoqTourDetailEntity":
                sourceRelationName = "nmoqTourDetailImgBannerRelation"
                destinationRelationName = "nmoqTourDetailImgBannerRelation"
                lang = "1"
                
            case "NmoqTourDetailEntityAr":
                sourceRelationName = "nmoqTourDetailImgBannerRelationAr"
                destinationRelationName = "nmoqTourDetailImgBannerRelation"
                
            case "NMoQTourListEntity":
                sourceRelationName = "tourImagesRelation"
                destinationRelationName = "tourImagesRelation"
                lang = "1"
                
            case "NMoQTourListEntityAr":
                sourceRelationName = "parkImgRelationAr"
                destinationRelationName = "tourImagesRelation"
                
            case "PublicArtsEntity":
                sourceRelationName = "publicImagesRelation"
                destinationRelationName = "publicImagesRelation"
                lang = "1"
                langKey = "language"
                
            case "PublicArtsEntityAr":
                sourceRelationName = "publicImagesRelation"
                destinationRelationName = "publicImagesRelation"
                langKey = "language"
                
            default:
                break
            }
            
            let sourceKeys = sInstance.entity.attributesByName.keys
            let sourceValues = sInstance.dictionaryWithValues(forKeys: sourceKeys.map { $0 })
            let destination = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!, into: manager.destinationContext)
            
            // migrate all the keys that are in the new destination instance & in the old source instace
//            let destinationKeys = destination.entity.attributesByName.keys
//            for key in destinationKeys {
//                if let value = sourceValues[key] {
//                    destination.setValue(value, forKey: key)
//                }
//            }
            destination.setValue(lang, forKey: langKey)
            
            // now check if the old source Country entity is present and convert it to the new Country class
            if let sourceFacilitiesImage = sInstance.value(forKey: sourceRelationName) as? NSManagedObject {
                if let image = sourceFacilitiesImage.value(forKey: "image") as? String {
                    let destinationImage = ImageEntity()
                    destinationImage.image = image
                    destinationImage.language = lang
                    
                    destination.setValue(destinationImage, forKey: destinationRelationName)
                }
            }
            
            manager.associate(sourceInstance: sInstance, withDestinationInstance: destination, for: mapping)
            
        } else {
            try super.createDestinationInstances(forSource: sInstance,
                                                 in: mapping,
                                                 manager: manager)
        }
    }
}

class DateMigrationPolicyFrom3To4: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        
        if let modelVersion = mapping.userInfo?["modelVersion"] as? String, modelVersion == "4" {
            
            var lang = "0"
            let langKey = "lang"
            let sourceRelationNames = ["endDateRelation","fieldRepeatDates","startDateRelation"]
            let destinationRelationNames = ["endDateRelation","fieldRepeatDates","startDateRelation"]
            let sourceRelationDateAttributeKeys = ["endDate","fieldRepeatDate","startDate"]
            
            switch sInstance.entity.name {
            case "EducationEventEntity":
                lang = "1"
                
            case "EducationEventEntityAr":
                break
                
            case "EventEntity":
                lang = "1"
                
            case "EventEntityArabic":
                break
            
            default:
                break
            }
            
            let sourceKeys = sInstance.entity.attributesByName.keys
            let sourceValues = sInstance.dictionaryWithValues(forKeys: sourceKeys.map { $0 })
            let destination = NSEntityDescription.insertNewObject(forEntityName: mapping.destinationEntityName!, into: manager.destinationContext)
            
            // migrate all the keys that are in the new destination instance & in the old source instace
//                        let destinationKeys = destination.entity.attributesByName.keys
//                        for key in destinationKeys {
//                            if let value = sourceValues[key] {
//                                destination.setValue(value, forKey: key)
//                            }
//                        }
            destination.setValue(lang, forKey: langKey)
            
            for i in 0...sourceRelationNames.count {
                // now check if the old source Country entity is present and convert it to the new Country class
                if let sourceFacilitiesImage = sInstance.value(forKey: sourceRelationNames[i]) as? NSManagedObject {
                    if let date = sourceFacilitiesImage.value(forKey: sourceRelationDateAttributeKeys[i]) as? String {
                        let destinationDate = DateEntity()
                        destinationDate.date = date
                        destinationDate.language = lang
                        
                        destination.setValue(destinationDate, forKey: destinationRelationNames[i])
                    }
                }
            }
            
            manager.associate(sourceInstance: sInstance, withDestinationInstance: destination, for: mapping)
            
        } else {
            try super.createDestinationInstances(forSource: sInstance,
                                                 in: mapping,
                                                 manager: manager)
        }
        
    }
}

