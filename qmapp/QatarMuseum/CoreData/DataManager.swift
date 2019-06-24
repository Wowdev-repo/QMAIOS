//
//  DataManager.swift
//  QatarMuseums
//
//  Created by Subins P Jose on 06/06/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import UIKit


class DataManager {
    
    /// Get stored objects from coredata
    ///
    /// - Parameters:
    ///   - entityName: Entity name as String
    ///   - idKey: Key as String to check match
    ///   - idValue: Value as String
    ///   - managedContext: NSManagedObjectContext
    /// - Returns: Matched NSManagedObjects
    static func checkAddedToCoredata(entityName: String?,
                                     idKey:String?,
                                     idValue: String?,
                                     managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults = [NSManagedObject]()
        if let key = idKey, let value = idValue , let entity = entityName {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
            fetchRequest.predicate = NSPredicate.init(format: "\(key) == \(value)")
            
            do {
                fetchResults = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
        }
        
        
        
        return fetchResults
    }
    
    
    /// Delete object from core date
    ///
    /// - Parameters:
    ///   - managedContext: NSManagedObjectContext
    ///   - date: Date
    ///   - entityName: Entity name as String
    /// - Returns: Status as Bool
    static func delete(managedContext: NSManagedObjectContext,
                       for date: Date,
                       entityName : String) -> Bool {
        if let uniqueDate = Utils.uniqueDate(date) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchRequest.predicate = NSPredicate.init(format: "\("dateId") == \(uniqueDate)")
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
            do {
                try managedContext.execute(deleteRequest)
                return true
            } catch _ as NSError {
            }
        }
        return false
        
    }
    
    static func getImageEntity(_ image: String, context: NSManagedObjectContext) -> ImageEntity {
        let imageEntity = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity",
                                                              into: context) as! ImageEntity
        imageEntity.image = image
        imageEntity.language = Utils.getLanguage()
        return imageEntity
    }
    
    /// Delete
    ///
    /// - Parameters:
    ///   - managedContext: NSManagedObjectContext
    ///   - entityName: Entity name as String
    /// - Returns: Bool, success/failure
    static func delete(managedContext: NSManagedObjectContext, entityName : String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
            return true
        } catch _ as NSError {
        }
        return false
    }
}

// MARK: - NSManagedObjectContext extension
extension NSManagedObjectContext {
    
    /// Save current context
    func saveContext() {
        do {
            try save()
        } catch {
            print(error)
        }
    }
}

//Store functions
extension DataManager {
    
    static func saveAboutDetails(managedContext: NSManagedObjectContext,
                                 aboutDetailtArray: [Museum]?,
                                 fromHomeBanner: Bool,
                                 language: String) {
        if let aboutDetailDict = aboutDetailtArray?.first {
            let fetchData = checkAddedToCoredata(entityName: "AboutEntity",
                                                 idKey: "id" ,
                                                 idValue: aboutDetailDict.id,
                                                 managedContext: managedContext) as! [AboutEntity]
            if !fetchData.isEmpty {
                if self.delete(managedContext: managedContext, entityName: "AboutEntity") {
                    _ = self.delete(managedContext: managedContext, entityName: "AboutDescriptionEntity")
                    _ = self.delete(managedContext: managedContext, entityName: "AboutMultimediaFileEntity")
                    _ = self.delete(managedContext: managedContext, entityName: "AboutDownloadLinkEntity")
                    self.saveToCoreData(aboutDetailDict: aboutDetailDict,
                                        managedObjContext: managedContext,
                                        fromHomeBanner: fromHomeBanner,
                                        language: language)
                }
            } else {
                self.saveToCoreData(aboutDetailDict: aboutDetailDict,
                                    managedObjContext: managedContext,
                                    fromHomeBanner: fromHomeBanner,
                                    language: language)
            }
        }
    }
    
    static func saveToCoreData(aboutDetailDict: Museum,
                               managedObjContext: NSManagedObjectContext,
                               fromHomeBanner: Bool,
                               language: String) {
        let aboutdbDict: AboutEntity = NSEntityDescription.insertNewObject(forEntityName: "AboutEntity",
                                                                           into: managedObjContext) as! AboutEntity
        
        aboutdbDict.name = aboutDetailDict.name
        aboutdbDict.id = aboutDetailDict.id
        aboutdbDict.tourguideAvailable = aboutDetailDict.tourguideAvailable
        aboutdbDict.contactNumber = aboutDetailDict.contactNumber
        aboutdbDict.contactEmail = aboutDetailDict.contactEmail
        aboutdbDict.mobileLongtitude = aboutDetailDict.mobileLongtitude
        aboutdbDict.subtitle = aboutDetailDict.subtitle
        aboutdbDict.language = language
        
        if !fromHomeBanner {
            aboutdbDict.openingTime = aboutDetailDict.openingTime
        } else {
            aboutdbDict.openingTime = aboutDetailDict.eventDate
        }
        
        aboutdbDict.mobileLatitude = aboutDetailDict.mobileLatitude
        aboutdbDict.tourGuideAvailability = aboutDetailDict.tourGuideAvailability
        
        if((aboutDetailDict.mobileDescription?.count)! > 0) {
            for i in 0 ... (aboutDetailDict.mobileDescription?.count)!-1 {
                var aboutDescEntity: AboutDescriptionEntity!
                let aboutDesc: AboutDescriptionEntity = NSEntityDescription.insertNewObject(forEntityName: "AboutDescriptionEntity", into: managedObjContext) as! AboutDescriptionEntity
                aboutDesc.mobileDesc = aboutDetailDict.mobileDescription![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                aboutDesc.id = Int16(i)
                aboutDescEntity = aboutDesc
                aboutDescEntity.language = Utils.getLanguage()
                aboutdbDict.addToMobileDescRelation(aboutDescEntity)
                managedObjContext.saveContext()
            }
        }
        
        //MultimediaFile
        if(aboutDetailDict.multimediaFile != nil){
            if((aboutDetailDict.multimediaFile?.count)! > 0) {
                for i in 0 ... (aboutDetailDict.multimediaFile?.count)!-1 {
                    var aboutImage: AboutMultimediaFileEntity!
                    let aboutImgaeArray: AboutMultimediaFileEntity = NSEntityDescription.insertNewObject(forEntityName: "AboutMultimediaFileEntity", into: managedObjContext) as! AboutMultimediaFileEntity
                    aboutImgaeArray.image = aboutDetailDict.multimediaFile![i]
                    aboutImgaeArray.language = Utils.getLanguage()
                    aboutImage = aboutImgaeArray
                    aboutdbDict.addToMultimediaRelation(aboutImage)
                    managedObjContext.saveContext()
                }
            }
        }
        
        //Download File
        if(aboutDetailDict.downloadable != nil){
            if((aboutDetailDict.downloadable?.count)! > 0) {
                for i in 0 ... (aboutDetailDict.downloadable?.count)!-1 {
                    var aboutImage: AboutDownloadLinkEntity
                    let aboutImgaeArray: AboutDownloadLinkEntity = NSEntityDescription.insertNewObject(forEntityName: "AboutDownloadLinkEntity", into: managedObjContext) as! AboutDownloadLinkEntity
                    aboutImgaeArray.downloadLink = aboutDetailDict.downloadable![i]
                    
                    aboutImage = aboutImgaeArray
                    aboutdbDict.addToDownloadLinkRelation(aboutImage)
                    managedObjContext.saveContext()
                }
            }
        }
        
        managedObjContext.saveContext()
    }
    
    /// Store education events
    ///
    /// - Parameters:
    ///   - events: EducationEvent list
    ///   - date: Date
    ///   - managedContext: NSManagedObjectContext
    static func storeEvents(events: [EducationEvent],
                            for date: Date,
                            managedContext: NSManagedObjectContext, language: String) {
        let dateID = Utils.uniqueDate(date)
        let fetchData = checkAddedToCoredata(entityName: "EventEntity",
                                             idKey: "dateId",
                                             idValue: dateID,
                                             managedContext: managedContext) as! [EventEntity]
        if !fetchData.isEmpty {
            for educationDict in events {
                let fetchResultData = checkAddedToCoredata(entityName: "EventEntity",
                                                           idKey: "itemId",
                                                           idValue: educationDict.itemId,
                                                           managedContext: managedContext) as! [EventEntity]
                if !fetchResultData.isEmpty {
                    let isDeleted = delete(managedContext: managedContext,
                                           for: date,
                                           entityName: "EventEntity")
                    if isDeleted {
                        self.saveEventToCoreData(educationEventDict: educationDict,
                                                 dateId: dateID,
                                                 managedObjContext: managedContext,
                                                 language: language)
                    }
                } else {
                    self.saveEventToCoreData(educationEventDict: educationDict,
                                             dateId: dateID,
                                             managedObjContext: managedContext,
                                             language: language)
                }
            }
            
        } else {
            for educationEvent in events {
                self.saveEventToCoreData(educationEventDict: educationEvent,
                                         dateId: dateID,
                                         managedObjContext: managedContext,
                                         language: language)
            }
        }
    }
    
    static func saveEventToCoreData(educationEventDict: EducationEvent,
                                    dateId: String?,
                                    managedObjContext: NSManagedObjectContext,
                                    language: String) {
        let edducationInfo: EventEntity = NSEntityDescription.insertNewObject(forEntityName: "EventEntity",
                                                                              into: managedObjContext) as! EventEntity
        edducationInfo.dateId = dateId
        edducationInfo.itemId = educationEventDict.itemId
        edducationInfo.introductionText = educationEventDict.introductionText
        edducationInfo.register = educationEventDict.register
        edducationInfo.title = educationEventDict.title
        edducationInfo.pgmType = educationEventDict.programType
        edducationInfo.museumDepartMent = educationEventDict.museumDepartMent
        edducationInfo.mainDesc = educationEventDict.mainDescription
        edducationInfo.language = language
        
        //Date
        if(educationEventDict.fieldRepeatDate != nil){
            if((educationEventDict.fieldRepeatDate?.count)! > 0) {
                for i in 0 ... (educationEventDict.fieldRepeatDate?.count)!-1 {
                    let eventDateEntity = NSEntityDescription.insertNewObject(forEntityName: "DateEntity",
                                                                              into: managedObjContext) as! DateEntity
                    eventDateEntity.date = educationEventDict.fieldRepeatDate![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;",
                                                                                                       with: "",
                                                                                                       options: .regularExpression,
                                                                                                       range: nil)
                    
                    eventDateEntity.language = Utils.getLanguage()
                    edducationInfo.addToFieldRepeatDates(eventDateEntity)
                    managedObjContext.saveContext()
                    
                }
            }
        }
        
        //AgeGroup
        if((educationEventDict.ageGroup?.count)! > 0) {
            for i in 0 ... (educationEventDict.ageGroup?.count)!-1 {
                var eventAgeEntity: EventAgeGroupEntity!
                let eventAge: EventAgeGroupEntity = NSEntityDescription.insertNewObject(forEntityName: "EventAgeGroupEntity",
                                                                                        into: managedObjContext) as! EventAgeGroupEntity
                eventAge.ageGroup = educationEventDict.ageGroup![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;",
                                                                                         with: "",
                                                                                         options: .regularExpression,
                                                                                         range: nil)
                
                eventAge.language = Utils.getLanguage()
                eventAgeEntity = eventAge
                edducationInfo.addToAgeGroupRelation(eventAgeEntity)
                managedObjContext.saveContext()
            }
        }
        //Associated_topics
        if((educationEventDict.associatedTopics?.count)! > 0) {
            for i in 0 ... (educationEventDict.associatedTopics?.count)!-1 {
                var eventSubEntity: EventTopicsEntity!
                let event: EventTopicsEntity = NSEntityDescription.insertNewObject(forEntityName: "EventTopicsEntity",
                                                                                   into: managedObjContext) as! EventTopicsEntity
                event.associatedTopic = educationEventDict.associatedTopics![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;",
                                                                                                     with: "",
                                                                                                     options: .regularExpression,
                                                                                                     range: nil)
                
                event.language = Utils.getLanguage()
                eventSubEntity = event
                edducationInfo.addToAssTopicRelation(eventSubEntity)
                managedObjContext.saveContext()
                
            }
        }
        
        //StartDate
        if let startDates = educationEventDict.startDate {
            for dateDict in startDates {
                let event = NSEntityDescription.insertNewObject(forEntityName: "DateEntity",
                                                                into: managedObjContext) as! DateEntity
                event.date = dateDict.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;",
                                                           with: "",
                                                           options: .regularExpression,
                                                           range: nil)
                event.language = Utils.getLanguage()
                edducationInfo.addToStartDateRelation(event)
                managedObjContext.saveContext()
            }
        }
        
        //EndDate
        if let startDates = educationEventDict.endDate {
            for dateDict in startDates {
                let event = NSEntityDescription.insertNewObject(forEntityName: "DateEntity",
                                                                into: managedObjContext) as! DateEntity
                event.date = dateDict.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;",
                                                           with: "",
                                                           options: .regularExpression,
                                                           range: nil)
                event.language = Utils.getLanguage()
                edducationInfo.addToEndDateRelation(event)
                managedObjContext.saveContext()
            }
        }
        
        managedObjContext.saveContext()
    }
    
    static func saveEducationEvents(_ events: [EducationEvent],
                                    date: Date,
                                    managedContext: NSManagedObjectContext) {
        let dateID = Utils.uniqueDate(date)
        let fetchData = DataManager.checkAddedToCoredata(entityName: "EducationEventEntity",
                                                         idKey: "dateId",
                                                         idValue: dateID,
                                                         managedContext: managedContext) as! [EducationEventEntity]
        if !fetchData.isEmpty {
            for educationDict in events {
                let fetchResultData = DataManager.checkAddedToCoredata(entityName: "EducationEventEntity",
                                                                       idKey: "itemId",
                                                                       idValue: educationDict.itemId,
                                                                       managedContext: managedContext) as! [EducationEventEntity]
                
                if !fetchResultData.isEmpty {
                    let isDeleted  = DataManager.delete(managedContext: managedContext,
                                                        for: date,
                                                        entityName: "EducationEventEntity")
                    if isDeleted {
                        self.saveToCoreData(educationEventDict: educationDict,
                                            dateId: dateID,
                                            managedObjContext: managedContext)
                    }
                } else {
                    self.saveToCoreData(educationEventDict: educationDict,
                                        dateId: dateID,
                                        managedObjContext: managedContext)
                }
            }
        } else {
            for educationEvent in events {
                self.saveToCoreData(educationEventDict: educationEvent,
                                    dateId: dateID,
                                    managedObjContext: managedContext)
            }
        }
    }
    
    static func saveToCoreData(educationEventDict: EducationEvent,
                               dateId: String?,
                               managedObjContext: NSManagedObjectContext) {
        let edducationInfo: EducationEventEntity = NSEntityDescription.insertNewObject(forEntityName: "EducationEventEntity",
                                                                                       into: managedObjContext) as! EducationEventEntity
        edducationInfo.dateId = dateId
        edducationInfo.itemId = educationEventDict.itemId
        edducationInfo.introductionText = educationEventDict.introductionText
        edducationInfo.register = educationEventDict.register
        edducationInfo.title = educationEventDict.title
        edducationInfo.pgmType = educationEventDict.programType
        edducationInfo.language = Utils.getLanguage()
        edducationInfo.mainDesc = educationEventDict.mainDescription
        
        if let dates  = educationEventDict.fieldRepeatDate {
            for date in dates {
                let eventDateEntity = NSEntityDescription.insertNewObject(forEntityName: "DateEntity",
                                                                          into: managedObjContext) as! DateEntity
                eventDateEntity.date = date.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;",
                                                                 with: "",
                                                                 options: .regularExpression,
                                                                 range: nil)
                
                eventDateEntity.language = Utils.getLanguage()
                edducationInfo.addToFieldRepeatDates(eventDateEntity)
                
               managedObjContext.saveContext()
                
            }
        }
        
        //AgeGroup
        if((educationEventDict.ageGroup?.count)! > 0) {
            for i in 0 ... (educationEventDict.ageGroup?.count)!-1 {
                var eventAgeEntity: EdAgeGroupEntity!
                let eventAge: EdAgeGroupEntity = NSEntityDescription.insertNewObject(forEntityName: "EdAgeGroupEntity", into: managedObjContext) as! EdAgeGroupEntity
                eventAge.ageGroup = educationEventDict.ageGroup![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                eventAge.language = Utils.getLanguage()
                eventAgeEntity = eventAge
                edducationInfo.addToAgeGroupRelation(eventAgeEntity)
                managedObjContext.saveContext()
                
            }
        }
        
        //Associated_topics
        if((educationEventDict.associatedTopics?.count)! > 0) {
            for i in 0 ... (educationEventDict.associatedTopics?.count)!-1 {
                var eventSubEntity: EdEventTopicsEntity!
                let event: EdEventTopicsEntity = NSEntityDescription.insertNewObject(forEntityName: "EdEventTopicsEntity", into: managedObjContext) as! EdEventTopicsEntity
                event.associatedTopic = educationEventDict.associatedTopics![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                
                event.language = Utils.getLanguage()
                eventSubEntity = event
                edducationInfo.addToAssTopicRelation(eventSubEntity)
                managedObjContext.saveContext()
                
            }
        }
        
        //StartDate
        if((educationEventDict.startDate?.count)! > 0) {
            for i in 0 ... (educationEventDict.startDate?.count)!-1 {
                var eventSubEntity: DateEntity!
                let event = NSEntityDescription.insertNewObject(forEntityName: "DateEntity", into: managedObjContext) as! DateEntity
                event.date = educationEventDict.startDate![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                
                event.language = Utils.getLanguage()
                eventSubEntity = event
                edducationInfo.addToStartDateRelation(eventSubEntity)
               managedObjContext.saveContext()
                
            }
        }
        
        //endDate
        if((educationEventDict.endDate?.count)! > 0) {
            for i in 0 ... (educationEventDict.endDate?.count)!-1 {
                var eventSubEntity: DateEntity!
                let event = NSEntityDescription.insertNewObject(forEntityName: "DateEntity", into: managedObjContext) as! DateEntity
                event.date = educationEventDict.endDate![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                
                event.language = Utils.getLanguage()
                eventSubEntity = event
                edducationInfo.addToEndDateRelation(eventSubEntity)
                managedObjContext.saveContext()
                
            }
        }
        
        managedObjContext.saveContext()
    }
    
    static func updateFacilitiesDetails(managedContext: NSManagedObjectContext,
                                        category: String?,
                                        facilities: [FacilitiesDetail]) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "FacilitiesDetailEntity",
                                                         idKey: "category",
                                                         idValue: category,
                                                         managedContext: managedContext) as! [FacilitiesDetailEntity]
        
        if !fetchData.isEmpty {
            for facilitiesDetailDict in facilities {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "FacilitiesDetailEntity",
                                                                   idKey: "nid",
                                                                   idValue: facilitiesDetailDict.nid,
                                                                   managedContext: managedContext) as! [FacilitiesDetailEntity]
                if fetchResult.isEmpty {
                    DataManager.saveFacilitiesDetails(facilitiesDetailDict: facilitiesDetailDict,
                                                      managedContext: managedContext,
                                                      entity: nil)
                } else {
                    DataManager.saveFacilitiesDetails(facilitiesDetailDict: facilitiesDetailDict,
                                                      managedContext: managedContext,
                                                      entity: fetchResult.first)
                }
            }
        } else {
            for facilitiesDetailDict in facilities {
                DataManager.saveFacilitiesDetails(facilitiesDetailDict: facilitiesDetailDict,
                                                  managedContext: managedContext,
                                                  entity: nil)
            }
        }
    }
    
    static func updateNmoqTourDetails(managedContext: NSManagedObjectContext,
                                    eventID: String?,
                                    events: [NMoQTourDetail]) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "NmoqTourDetailEntity",
                                             idKey: "nmoqEvent",
                                             idValue: eventID,
                                             managedContext: managedContext) as! [NmoqTourDetailEntity]
        if !fetchData.isEmpty {
            for tourDetailDict in events {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "NmoqTourDetailEntity",
                                                       idKey: "nid",
                                                       idValue: tourDetailDict.nid,
                                                       managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let tourDetaildbDict = fetchResult[0] as! NmoqTourDetailEntity
                    DataManager.saveTourDetails(tourDetailDict: tourDetailDict,
                                                managedObjContext: managedContext,
                                                entity: tourDetaildbDict)
                }
                else {
                    //save
                    DataManager.saveTourDetails(tourDetailDict: tourDetailDict,
                                                managedObjContext: managedContext,
                                                entity: nil)
                }
            }
        }
        else {
            for tourDetailDict in events {
                DataManager.saveTourDetails(tourDetailDict: tourDetailDict,
                                            managedObjContext: managedContext,
                                            entity: nil)
            }
        }
    }
    
    static func updateTourGuide(managedContext: NSManagedObjectContext,
                         miaTourDataFullArray: [TourGuide],
                         museumID: String?, language: String) {
        let fetchData = checkAddedToCoredata(entityName: "TourGuideEntity",
                                             idKey: "museumsEntity",
                                             idValue: museumID,
                                             managedContext: managedContext) as! [TourGuideEntity]
        if !fetchData.isEmpty {
            for tourGuideListDict in miaTourDataFullArray {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "TourGuideEntity",
                                                                   idKey: "nid",
                                                                   idValue: tourGuideListDict.nid,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let tourguidedbDict = fetchResult[0] as! TourGuideEntity
                    DataManager.saveTourGuide(tourguideListDict: tourGuideListDict,
                                              managedObjContext: managedContext,
                                              entity: tourguidedbDict,
                                              language: language)
                }
                else {
                    //save
                    DataManager.saveTourGuide(tourguideListDict: tourGuideListDict,
                                              managedObjContext: managedContext,
                                              entity: nil,
                                              language: language)
                    
                }
            }
        }
        else {
            for tourGuideListDict in miaTourDataFullArray {
                DataManager.saveTourGuide(tourguideListDict: tourGuideListDict,
                                          managedObjContext: managedContext,
                                          entity: nil,
                                          language: language)
                
            }
        }
    }
    
    /// Save facilities details to core data
    ///
    /// - Parameters:
    ///   - facilitiesDetailDict: Facilities details as FacilitiesDetail
    ///   - managedContext: NSManagedObjectContext
    ///   - entity: FacilitiesDetailEntity, nil will create new entity
    static func saveFacilitiesDetails(facilitiesDetailDict: FacilitiesDetail,
                                      managedContext: NSManagedObjectContext,
                                      entity: FacilitiesDetailEntity?) {
        var facilitiesDetaildbDict = entity
        if entity == nil {
            facilitiesDetaildbDict = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesDetailEntity",
                                                                         into: managedContext) as? FacilitiesDetailEntity
        }
        facilitiesDetaildbDict?.title = facilitiesDetailDict.title
        facilitiesDetaildbDict?.subtitle = facilitiesDetailDict.subtitle
        facilitiesDetaildbDict?.facilitiesDes =  facilitiesDetailDict.facilitiesDes
        facilitiesDetaildbDict?.timing =  facilitiesDetailDict.timing
        facilitiesDetaildbDict?.titleTiming = facilitiesDetailDict.titleTiming
        facilitiesDetaildbDict?.nid = facilitiesDetailDict.nid
        facilitiesDetaildbDict?.longtitude =  facilitiesDetailDict.longtitude
        facilitiesDetaildbDict?.category =  facilitiesDetailDict.category
        facilitiesDetaildbDict?.latitude = facilitiesDetailDict.latitude
        facilitiesDetaildbDict?.locationTitle = facilitiesDetailDict.locationTitle
        facilitiesDetaildbDict?.language = Utils.getLanguage()
        
        if let images = facilitiesDetailDict.images {
            for image in images {
                facilitiesDetaildbDict?.addToFacilitiesDetailRelation(DataManager.getImageEntity(image, context: managedContext))
                managedContext.saveContext()
            }
        }
        
        managedContext.saveContext()
    }
    
    /// Save tour details to core data
    ///
    /// - Parameters:
    ///   - tourDetailDict: tour details as NMoQTourDetail
    ///   - managedObjContext: NSManagedObjectContext
    ///   - entity: NmoqTourDetailEntity, nil will create new entity
    static func saveTourDetails(tourDetailDict: NMoQTourDetail,
                                managedObjContext: NSManagedObjectContext,
                                entity: NmoqTourDetailEntity?) {
        
        var tourDetaildbDict = entity
        if entity == nil {
            tourDetaildbDict = NSEntityDescription.insertNewObject(forEntityName: "NmoqTourDetailEntity",
                                                                   into: managedObjContext) as? NmoqTourDetailEntity
        }
        
        tourDetaildbDict?.title = tourDetailDict.title
        tourDetaildbDict?.date = tourDetailDict.date
        tourDetaildbDict?.nmoqEvent =  tourDetailDict.nmoqEvent
        tourDetaildbDict?.register =  tourDetailDict.register
        tourDetaildbDict?.contactEmail = tourDetailDict.contactEmail
        tourDetaildbDict?.contactPhone = tourDetailDict.contactPhone
        tourDetaildbDict?.mobileLatitude =  tourDetailDict.mobileLatitude
        tourDetaildbDict?.longitude =  tourDetailDict.longitude
        tourDetaildbDict?.sort_id = tourDetailDict.sortId
        tourDetaildbDict?.body = tourDetailDict.body
        tourDetaildbDict?.registered =  tourDetailDict.registered
        tourDetaildbDict?.nid =  tourDetailDict.nid
        tourDetaildbDict?.seatsRemaining =  tourDetailDict.seatsRemaining
        tourDetaildbDict?.language = Utils.getLanguage()
        
        if let imageBanner = tourDetailDict.imageBanner {
            for image in imageBanner {
                tourDetaildbDict?.addToNmoqTourDetailImgBannerRelation(DataManager.getImageEntity(image, context: managedObjContext))
                managedObjContext.saveContext()
            }
        }
        
        managedObjContext.saveContext()
    }
    
    /// Save tour guide to core data
    ///
    /// - Parameters:
    ///   - tourguideListDict: tour guide details as TourGuide
    ///   - managedObjContext: NSManagedObjectContext
    ///   - entity: TourGuideEntity, nil will create new entity and save to core data
    static func saveTourGuide(tourguideListDict: TourGuide,
                       managedObjContext: NSManagedObjectContext,
                       entity: TourGuideEntity?, language: String) {
        var tourGuideInfo = entity
        if entity == nil {
            tourGuideInfo = NSEntityDescription.insertNewObject(forEntityName: "TourGuideEntity",
                                                                into: managedObjContext) as? TourGuideEntity
        }
        tourGuideInfo?.title = tourguideListDict.title
        tourGuideInfo?.tourGuideDescription = tourguideListDict.tourGuideDescription
        tourGuideInfo?.museumsEntity = tourguideListDict.museumsEntity
        tourGuideInfo?.nid = tourguideListDict.nid
        tourGuideInfo?.language = language
        
        if let multimediaFiles = tourguideListDict.multimediaFile {
            for file in multimediaFiles {
                var multimediaEntity: TourGuideMultimediaEntity!
                let multimediaArray: TourGuideMultimediaEntity = NSEntityDescription.insertNewObject(forEntityName: "TourGuideMultimediaEntity", into: managedObjContext) as! TourGuideMultimediaEntity
                multimediaArray.multimediaFile = file
                multimediaArray.language = language
                multimediaEntity = multimediaArray
                tourGuideInfo?.addToTourGuideMultimediaRelation(multimediaEntity)
                managedObjContext.saveContext()
                
            }
        }
        managedObjContext.saveContext()
    }
    
    static func updateDinings(managedContext: NSManagedObjectContext,
                              diningListArray : [Dining]?,
                              language: String) {
        var fetchData = [DiningEntity]()
        fetchData = DataManager.checkAddedToCoredata(entityName: "DiningEntity",
                                                     idKey: "lang",
                                                     idValue: Utils.getLanguageCode(language),
                                                     managedContext: managedContext) as! [DiningEntity]
        if let diningList = diningListArray, !fetchData.isEmpty {
            for diningListDict in diningList {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "DiningEntity",
                                                                   idKey: "id",
                                                                   idValue: diningListDict.id,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let diningdbDict = fetchResult[0] as! DiningEntity
                    DataManager.saveToDiningCoreData(diningListDict: diningListDict,
                                                     managedObjContext: managedContext,
                                                     entity: diningdbDict,
                                                     language: Utils.getLanguageCode(language))
                } else {
                    //save
                    DataManager.saveToDiningCoreData(diningListDict: diningListDict,
                                                     managedObjContext: managedContext,
                                                     entity: nil,
                                                     language: Utils.getLanguageCode(language))
                }
            }
        } else if let diningList = diningListArray {
            for diningListDict in diningList {
                DataManager.saveToDiningCoreData(diningListDict: diningListDict,
                                                 managedObjContext: managedContext,
                                                 entity: nil,
                                                 language: Utils.getLanguageCode(language))
            }
        }
    }
    
    /// Save dining entity to coredata
    ///
    /// - Parameters:
    ///   - diningListDict: Dining
    ///   - managedObjContext: NSManagedObjectContext
    ///   - entity: DiningEntity, nil will create new entity
    static func saveToDiningCoreData(diningListDict: Dining,
                              managedObjContext: NSManagedObjectContext,
                              entity: DiningEntity?,
                              language: String) {
        var diningInfo: DiningEntity?
        if entity == nil {
            diningInfo = NSEntityDescription.insertNewObject(forEntityName: "DiningEntity",
                                                             into: managedObjContext) as? DiningEntity
        }
        diningInfo?.id = diningListDict.id
        diningInfo?.name = diningListDict.name
        
        diningInfo?.image = diningListDict.image
        if let sortID = diningListDict.sortid {
            diningInfo?.sortid = sortID
        }
        diningInfo?.museumId = diningListDict.museumId
        diningInfo?.lang = language //Utils.getLanguageCode(language)
        
        if let description = diningListDict.description {
            diningInfo?.diningdescription = description
        }
        
        if let closetime = diningListDict.closetime {
            diningInfo?.closetime = closetime
        }
        
        if let openingtime = diningListDict.openingtime {
            diningInfo?.openingtime =  openingtime
        }
        
        if let location = diningListDict.location {
            diningInfo?.location =  location
        }
        
        if let images = diningListDict.images {
            for image in images {
                diningInfo?.addToImagesRelation(DataManager.getImageEntity(image, context: managedObjContext))
                managedObjContext.saveContext()
            }
        }
        
        managedObjContext.saveContext()
    }
    
    static func updatePublicArts(managedContext: NSManagedObjectContext,
                                 publicArtsListArray:[PublicArtsList]?,
                                 language: String) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "PublicArtsEntity",
                                                         idKey: "id",
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [PublicArtsEntity]
        if let publicArts = publicArtsListArray, !fetchData.isEmpty {
            for publicArtsListDict in publicArts {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "PublicArtsEntity",
                                                                   idKey: "id",
                                                                   idValue: publicArtsListDict.id,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let publicArtsdbDict = fetchResult[0] as! PublicArtsEntity
                    DataManager.saveToPublicArtsCoreData(publicArtsListDict: publicArtsListDict,
                                                         managedObjContext: managedContext,
                                                         entity: publicArtsdbDict, language: language)
                } else {
                    //save
                    DataManager.saveToPublicArtsCoreData(publicArtsListDict: publicArtsListDict,
                                                         managedObjContext: managedContext,
                                                         entity: nil, language: language)
                }
            }
        } else {
            if let publicArts = publicArtsListArray {
                for publicArtsListDict in publicArts {
                    DataManager.saveToPublicArtsCoreData(publicArtsListDict: publicArtsListDict,
                                                         managedObjContext: managedContext,
                                                         entity: nil, language: language)
                }
            }
        }
    }
    
    static func saveToPublicArtsCoreData(publicArtsListDict: PublicArtsList,
                                         managedObjContext: NSManagedObjectContext,
                                         entity: PublicArtsEntity?,
                                         language: String) {
        var publicArtsInfo = entity
        if entity == nil {
            publicArtsInfo = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsEntity",
                                                                 into: managedObjContext) as? PublicArtsEntity
        }
        publicArtsInfo?.name = publicArtsListDict.name
        publicArtsInfo?.image = publicArtsListDict.image
        publicArtsInfo?.latitude =  publicArtsListDict.latitude
        publicArtsInfo?.longitude = publicArtsListDict.longitude
        publicArtsInfo?.sortcoefficient = publicArtsListDict.sortcoefficient
        publicArtsInfo?.language = language
        
        managedObjContext.saveContext()
    }
    
    static func updatePublicArtsDetailsEntity(managedContext: NSManagedObjectContext,
                                 publicArtsListArray:[PublicArtsDetail]?) {
        if let publicArts = publicArtsListArray {
            for publicArtsListDict in publicArts {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "PublicArtsEntity",
                                                                   idKey: "id",
                                                                   idValue: publicArtsListDict.id,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let publicArtsdbDict = fetchResult[0] as! PublicArtsEntity
                    DataManager.savePublicArtsDetailsEntity(publicArtsListDict: publicArtsListDict,
                                                         managedObjContext: managedContext,
                                                         entity: publicArtsdbDict)
                } else {
                    //save
                    DataManager.savePublicArtsDetailsEntity(publicArtsListDict: publicArtsListDict,
                                                         managedObjContext: managedContext,
                                                         entity: nil)
                }
            }
        }
    }
    
    
    static func savePublicArtsDetailsEntity(publicArtsListDict: PublicArtsDetail,
                                         managedObjContext: NSManagedObjectContext,
                                         entity: PublicArtsEntity?) {
        var publicArtsInfo = entity
        if entity == nil {
            publicArtsInfo = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsEntity",
                                                                 into: managedObjContext) as? PublicArtsEntity
        }
        publicArtsInfo?.name = publicArtsListDict.name
        publicArtsInfo?.image = publicArtsListDict.image
        publicArtsInfo?.latitude =  publicArtsListDict.latitude
        publicArtsInfo?.longitude = publicArtsListDict.longitude
        publicArtsInfo?.language = Utils.getLanguage()
        publicArtsInfo?.detaildescription = publicArtsListDict.description
        publicArtsInfo?.shortdescription = publicArtsListDict.shortdescription
        
        if let images = publicArtsListDict.images {
            for image in images {
                publicArtsInfo?.addToPublicImagesRelation(DataManager.getImageEntity(image, context: managedObjContext))
                managedObjContext.saveContext()
            }
        }
        
        managedObjContext.saveContext()
    }
    
    static func updateParks(managedContext: NSManagedObjectContext,
                            parksListArray: [ParksList],
                            language: String) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "ParksEntity",
                                                         idKey: nil,
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [ParksEntity]
        if !fetchData.isEmpty {
            if DataManager.delete(managedContext: managedContext,
                                  entityName: "ParksEntity") {
                for parksDict in parksListArray {
                    DataManager.saveParks(parksDict: parksDict,
                                          managedObjContext: managedContext,
                                          language: language)
                }
            }
        } else  {
            for parksDict in parksListArray {
                DataManager.saveParks(parksDict: parksDict,
                                      managedObjContext: managedContext,
                                      language: language)
            }
        }
    }
    
    /// Save Parks to core data
    ///
    /// - Parameters:
    ///   - parksDict: ParksList
    ///   - managedObjContext: NSManagedObjectContext
    static func saveParks(parksDict: ParksList,
                          managedObjContext: NSManagedObjectContext,
                          language: String) {
        let parksInfo = NSEntityDescription.insertNewObject(forEntityName: "ParksEntity",
                                                            into: managedObjContext) as! ParksEntity
        parksInfo.title = parksDict.title
        parksInfo.parksDescription = parksDict.description
        parksInfo.image = parksDict.image
        parksInfo.language = language
        
        if let sortId = parksDict.sortId {
            parksInfo.sortId = sortId
        }
        managedObjContext.saveContext()
    }
    
    static func updateNotifications(managedContext: NSManagedObjectContext,
                                    notifications: [Notification]) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "NotificationsEntity",
                                                         idKey: "sortId",
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [NotificationsEntity]
        if !fetchData.isEmpty {
            for notificationDict in notifications {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "NotificationsEntity",
                                                                   idKey: "sortId",
                                                                   idValue: nil,
                                                                   managedContext: managedContext) as! [NotificationsEntity]
                if(fetchResult.count > 0) {
                    if DataManager.delete(managedContext: managedContext,
                                          entityName: "NotificationsEntity") {
                        DataManager.saveNotificatons(notificationsDict: notificationDict,
                                              managedObjContext: managedContext)
                    }
                } else {
                    DataManager.saveNotificatons(notificationsDict: notificationDict,
                                          managedObjContext: managedContext)
                }
            }
        } else {
            for notificationDict in notifications {
                DataManager.saveNotificatons(notificationsDict: notificationDict,
                                      managedObjContext: managedContext)
            }
        }
    }
    
    static func saveNotificatons(notificationsDict: Notification,
                          managedObjContext: NSManagedObjectContext) {
        let notificationInfo: NotificationsEntity = NSEntityDescription.insertNewObject(forEntityName: "NotificationsEntity", into: managedObjContext) as! NotificationsEntity
        notificationInfo.title = notificationsDict.title
        notificationInfo.language = Utils.getLanguage()
        
        if let sortID = notificationsDict.sortId {
            notificationInfo.sortId = sortID
        }
        managedObjContext.saveContext()
    }
    
    static func updateTravelList(travelList: [HomeBanner],
                                 managedContext: NSManagedObjectContext,
                                 language: String) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "NMoQTravelListEntity",
                                                         idKey: "fullContentID",
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [NMoQTravelListEntity]
        if (fetchData.count > 0) {
            for travelListDict in travelList {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "NMoQTravelListEntity",
                                                                   idKey: "fullContentID",
                                                                   idValue: travelListDict.fullContentID,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let travelListdbDict = fetchResult[0] as! NMoQTravelListEntity
                    DataManager.saveTravelList(travelListDict: travelListDict,
                                        managedObjContext: managedContext,
                                        entity: travelListdbDict,
                                        language: language)
                } else {
                    //save
                    DataManager.saveTravelList(travelListDict: travelListDict,
                                        managedObjContext: managedContext,
                                        entity: nil,
                                        language: language)
                }
            }
        } else {
            for travelListDict in travelList {
                DataManager.saveTravelList(travelListDict: travelListDict,
                                    managedObjContext: managedContext,
                                    entity: nil,
                                    language: language)
            }
        }
    }
    
    static func saveTravelList(travelListDict: HomeBanner,
                        managedObjContext: NSManagedObjectContext,
                        entity: NMoQTravelListEntity?,
                        language: String) {
        
        var travelListdbDict = entity
        
        if entity == nil {
            travelListdbDict = NSEntityDescription.insertNewObject(forEntityName: "NMoQTravelListEntity",
                                                                   into: managedObjContext) as? NMoQTravelListEntity
        }
        travelListdbDict?.title = travelListDict.title
        travelListdbDict?.fullContentID = travelListDict.fullContentID
        travelListdbDict?.bannerTitle =  travelListDict.bannerTitle
        travelListdbDict?.bannerLink = travelListDict.bannerLink
        travelListdbDict?.introductionText =  travelListDict.introductionText
        travelListdbDict?.email = travelListDict.email
        travelListdbDict?.contactNumber = travelListDict.contactNumber
        travelListdbDict?.promotionalCode =  travelListDict.promotionalCode
        travelListdbDict?.claimOffer = travelListDict.claimOffer
        travelListdbDict?.language = language
        
        managedObjContext.saveContext()
    }
    
    static func updateTourList(nmoqTourList:[NMoQTour],
                        managedContext: NSManagedObjectContext,
                        isTourGuide:Bool,
                        language: String) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "NMoQTourListEntity",
                                                         idKey: "nid",
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [NMoQTourListEntity]
        if (fetchData.count > 0) {
            for tourListDict in nmoqTourList {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "NMoQTourListEntity",
                                                                   idKey: "nid",
                                                                   idValue: tourListDict.nid,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let tourListdbDict = fetchResult[0] as! NMoQTourListEntity
                    DataManager.saveTourList(tourListDict: tourListDict,
                                      managedObjContext: managedContext,
                                      isTourGuide: isTourGuide,
                                      entity: tourListdbDict,
                                      language: language)
                } else {
                    //save
                    DataManager.saveTourList(tourListDict: tourListDict,
                                      managedObjContext: managedContext,
                                      isTourGuide: isTourGuide,
                                      entity: nil,
                                      language: language)
                }
            }
        } else {
            for tourListDict in nmoqTourList {
                DataManager.saveTourList(tourListDict: tourListDict,
                                  managedObjContext: managedContext,
                                  isTourGuide: isTourGuide,
                                  entity: nil,
                                  language: language)
            }
        }
    }
    
    static func saveTourList(tourListDict: NMoQTour,
                      managedObjContext: NSManagedObjectContext,
                      isTourGuide: Bool,
                      entity: NMoQTourListEntity?,
                      language: String) {
        var tourListInfo = entity
        if entity == nil {
            tourListInfo = NSEntityDescription.insertNewObject(forEntityName: "NMoQTourListEntity",
                                                               into: managedObjContext) as? NMoQTourListEntity
        }
        
        tourListInfo?.title = tourListDict.title
        tourListInfo?.dayDescription = tourListDict.dayDescription
        tourListInfo?.subtitle = tourListDict.subtitle
        tourListInfo?.sortId = Int16(tourListDict.sortId!)!
        tourListInfo?.nid = tourListDict.nid
        tourListInfo?.eventDate = tourListDict.eventDate
        
        //specialEvent
        tourListInfo?.dateString = tourListDict.date
        tourListInfo?.descriptioForModerator = tourListDict.descriptioForModerator
        tourListInfo?.mobileLatitude = tourListDict.mobileLatitude
        tourListInfo?.moderatorName = tourListDict.moderatorName
        tourListInfo?.longitude = tourListDict.longitude
        tourListInfo?.contactEmail = tourListDict.contactEmail
        tourListInfo?.contactPhone = tourListDict.contactPhone
        tourListInfo?.isTourGuide = isTourGuide
        tourListInfo?.language = language
        
        if(tourListDict.images != nil){
            if let images = tourListDict.images {
                for image in images {
                    tourListInfo?.addToTourImagesRelation(DataManager.getImageEntity(image, context: managedObjContext))
                    managedObjContext.saveContext()
                }
            }
        }
        managedObjContext.saveContext()
    }
    
    static func updateNmoqPark(nmoqParkList: [NMoQPark], managedContext: NSManagedObjectContext, language: String) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "NMoQParksEntity",
                                                         idKey: "nid",
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [NMoQParksEntity]
        if (fetchData.count > 0) {
            for nmoqParkListDict in nmoqParkList {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "NMoQParksEntity",
                                                                   idKey: "nid",
                                                                   idValue: nmoqParkListDict.nid,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let nmoqParkListdbDict = fetchResult[0] as! NMoQParksEntity
                    DataManager.saveNmoqParks(nmoqParkListDict: nmoqParkListDict,
                                       managedObjContext: managedContext,
                                       entity: nmoqParkListdbDict, language: language)
                } else {
                    //save
                    DataManager.saveNmoqParks(nmoqParkListDict: nmoqParkListDict,
                                       managedObjContext: managedContext,
                                       entity: nil, language: language)
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationEn), object: self)
        } else {
            for nmoqParkListDict in nmoqParkList {
                DataManager.saveNmoqParks(nmoqParkListDict: nmoqParkListDict,
                                   managedObjContext: managedContext,
                                   entity: nil, language: language)
            }
            NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationEn), object: self)
        }
    }
    
    static func saveNmoqParks(nmoqParkListDict: NMoQPark,
                       managedObjContext: NSManagedObjectContext,
                       entity: NMoQParksEntity?, language: String) {
        
        var nmoqParkListdbDict = entity
        if entity == nil {
            nmoqParkListdbDict = NSEntityDescription.insertNewObject(forEntityName: "NMoQParksEntity",
                                                                     into: managedObjContext) as? NMoQParksEntity
        }
        
        nmoqParkListdbDict?.title = nmoqParkListDict.title
        nmoqParkListdbDict?.nid =  nmoqParkListDict.nid
        nmoqParkListdbDict?.sortId =  nmoqParkListDict.sortId
        nmoqParkListdbDict?.language = language
        
        if(nmoqParkListDict.images != nil){
            if let images = nmoqParkListDict.images {
                for image in images {
                    nmoqParkListdbDict?.addToParkImgRelation(DataManager.getImageEntity(image, context: managedObjContext))
                    managedObjContext.saveContext()
                }
            }
        }
        managedObjContext.saveContext()
    }
    
    static func updateNmoqParkList(nmoqParkList: [NMoQParksList],
                                   managedContext: NSManagedObjectContext,
                                   language: String) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "NMoQParkListEntity",
                                                         idKey: "nid",
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [NMoQParkListEntity]
        if (fetchData.count > 0) {
            for nmoqParkListDict in nmoqParkList {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "NMoQParkListEntity",
                                                                   idKey: "nid",
                                                                   idValue: nmoqParkListDict.nid,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let nmoqParkListdbDict = fetchResult[0] as! NMoQParkListEntity
                    DataManager.saveNmoqParkList(nmoqParkListDict: nmoqParkListDict,
                                          managedObjContext: managedContext,
                                          entity: nmoqParkListdbDict,
                                          language: language)
                } else {
                    //save
                    DataManager.saveNmoqParkList(nmoqParkListDict: nmoqParkListDict,
                                          managedObjContext: managedContext,
                                          entity: nil,
                                          language: language)
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationEn), object: self)
        } else {
            for nmoqParkListDict in nmoqParkList {
                DataManager.saveNmoqParkList(nmoqParkListDict: nmoqParkListDict,
                                      managedObjContext: managedContext,
                                      entity: nil,
                                      language: language)
            }
            NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationEn), object: self)
        }
    }
    
    static func saveNmoqParkList(nmoqParkListDict: NMoQParksList,
                          managedObjContext: NSManagedObjectContext,
                          entity: NMoQParkListEntity?,
                          language: String) {
        var nmoqParkListdbDict = entity
        if entity == nil {
            nmoqParkListdbDict = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkListEntity",
                                                                     into: managedObjContext) as? NMoQParkListEntity
        }
        nmoqParkListdbDict?.title = nmoqParkListDict.title
        nmoqParkListdbDict?.parkTitle = nmoqParkListDict.parkTitle
        nmoqParkListdbDict?.mainDescription = nmoqParkListDict.mainDescription
        nmoqParkListdbDict?.parkDescription =  nmoqParkListDict.parkDescription
        nmoqParkListdbDict?.hoursTitle = nmoqParkListDict.hoursTitle
        nmoqParkListdbDict?.hoursDesc = nmoqParkListDict.hoursDesc
        nmoqParkListdbDict?.nid =  nmoqParkListDict.nid
        nmoqParkListdbDict?.longitude = nmoqParkListDict.longitude
        nmoqParkListdbDict?.latitude = nmoqParkListDict.latitude
        nmoqParkListdbDict?.locationTitle =  nmoqParkListDict.locationTitle
        nmoqParkListdbDict?.language = language
        
        managedObjContext.saveContext()
    }
    
    static func updateNmoqParkDetail(nmoqParkList: [NMoQParkDetail],
                              managedContext: NSManagedObjectContext) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "NMoQParkDetailEntity",
                                                         idKey: "nid",
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [NMoQParkDetailEntity]
        if (fetchData.count > 0) {
            for nmoqParkListDict in nmoqParkList {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "NMoQParkDetailEntity",
                                                                   idKey: "nid",
                                                                   idValue: nmoqParkListDict.nid,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let nmoqParkListdbDict = fetchResult[0] as! NMoQParkDetailEntity
                    DataManager.saveNMoQParkDetail(nmoqParkListDict: nmoqParkListDict,
                                            managedObjContext: managedContext,
                                            entity: nmoqParkListdbDict)
                } else {
                    //save
                    DataManager.saveNMoQParkDetail(nmoqParkListDict: nmoqParkListDict,
                                            managedObjContext: managedContext,
                                            entity: nil)
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationEn), object: self)
        } else {
            for nmoqParkListDict in nmoqParkList {
                DataManager.saveNMoQParkDetail(nmoqParkListDict: nmoqParkListDict,
                                        managedObjContext: managedContext,
                                        entity: nil)
            }
            NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationEn), object: self)
        }
    }
    
    static func saveNMoQParkDetail(nmoqParkListDict: NMoQParkDetail,
                            managedObjContext: NSManagedObjectContext, entity: NMoQParkDetailEntity?) {
        var nmoqParkListdbDict = entity
        if entity == nil {
            nmoqParkListdbDict = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailEntity",
                                                                     into: managedObjContext) as? NMoQParkDetailEntity
        }
        nmoqParkListdbDict?.title = nmoqParkListDict.title
        nmoqParkListdbDict?.nid =  nmoqParkListDict.nid
        nmoqParkListdbDict?.sortId =  nmoqParkListDict.sortId
        nmoqParkListdbDict?.parkDesc =  nmoqParkListDict.parkDesc
        nmoqParkListdbDict?.language = Utils.getLanguage()
        
        if let images = nmoqParkListDict.images{
            for image in images {
                nmoqParkListdbDict?.addToParkDetailImgRelation(DataManager.getImageEntity(image, context: managedObjContext))
                managedObjContext.saveContext()
            }
        }
        managedObjContext.saveContext()
    }
    
    static func updateActivityList(nmoqActivityList: [NMoQActivitiesList],
                                   managedContext: NSManagedObjectContext, language: String) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "NMoQActivitiesEntity",
                                                         idKey: "nid",
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [NMoQActivitiesEntity]
        if (fetchData.count > 0) {
            for nmoqActivityListDict in nmoqActivityList {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "NMoQActivitiesEntity",
                                                                   idKey: "nid",
                                                                   idValue: nmoqActivityListDict.nid,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let activityListdbDict = fetchResult[0] as! NMoQActivitiesEntity
                    DataManager.saveActivityList(activityListDict: nmoqActivityListDict,
                                          managedObjContext: managedContext,
                                          entity: activityListdbDict,
                                          language: language)
                } else {
                    //save
                    DataManager.saveActivityList(activityListDict: nmoqActivityListDict,
                                                 managedObjContext: managedContext,
                                                 entity: nil,
                                                 language: language)
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(nmoqActivityListNotificationEn), object: self)
        } else {
            for activitiesListDict in nmoqActivityList {
                DataManager.saveActivityList(activityListDict: activitiesListDict,
                                      managedObjContext: managedContext,
                                      entity: nil,
                                      language: language)
            }
            NotificationCenter.default.post(name: NSNotification.Name(nmoqActivityListNotificationEn), object: self)
        }
    }
    
    static func saveActivityList(activityListDict: NMoQActivitiesList,
                          managedObjContext: NSManagedObjectContext,
                          entity: NMoQActivitiesEntity?,
                          language: String) {
        var activityListdbDict = entity
        if entity == nil {
            activityListdbDict = NSEntityDescription.insertNewObject(forEntityName: "NMoQActivitiesEntity",
                                                                     into: managedObjContext) as? NMoQActivitiesEntity
        }
        activityListdbDict?.title = activityListDict.title
        activityListdbDict?.dayDescription = activityListDict.dayDescription
        activityListdbDict?.subtitle =  activityListDict.subtitle
        activityListdbDict?.sortId = activityListDict.sortId
        activityListdbDict?.nid =  activityListDict.nid
        activityListdbDict?.eventDate = activityListDict.eventDate
        //eventlist
        activityListdbDict?.date = activityListDict.date
        activityListdbDict?.descriptioForModerator = activityListDict.descriptioForModerator
        activityListdbDict?.mobileLatitude = activityListDict.mobileLatitude
        activityListdbDict?.moderatorName = activityListDict.moderatorName
        activityListdbDict?.longitude = activityListDict.longitude
        activityListdbDict?.contactEmail = activityListDict.contactEmail
        activityListdbDict?.contactPhone = activityListDict.contactPhone
        activityListdbDict?.language = language
        
        if let images = activityListDict.images {
            for image in images {
                activityListdbDict?.addToActivityImgRelation(DataManager.getImageEntity(image,
                                                                                        context: managedObjContext))
                managedObjContext.saveContext()
            }
        }
        managedObjContext.saveContext()
    }
    
    static func updateHomeEntity(managedContext: NSManagedObjectContext,
                                 homeList: [Home],
                                 language: String) {
        var fetchData = [HomeEntity]()
        
        fetchData = DataManager.checkAddedToCoredata(entityName: "HomeEntity",
                                                     idKey: "lang",
                                                     idValue: language,
                                                     managedContext: managedContext) as! [HomeEntity]
        if (fetchData.count > 0) {
            for homeListDict in homeList {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "HomeEntity",
                                                                   idKey: "id",
                                                                   idValue: homeListDict.id,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let homedbDict = fetchResult[0] as! HomeEntity
                    DataManager.saveHomeEntity(homeListDict: homeListDict,
                                        managedObjContext: managedContext,
                                        entity: homedbDict,
                                        language: language)
                } else {
                    //save
                    DataManager.saveHomeEntity(homeListDict: homeListDict,
                                        managedObjContext: managedContext,
                                        entity: nil,
                                        language: language)
                }
            }
        } else {
            for homeListDict in homeList {
                DataManager.saveHomeEntity(homeListDict: homeListDict,
                                    managedObjContext: managedContext,
                                    entity: nil,
                                    language: language)
            }
        }
    }
    
    static func saveHomeEntity(homeListDict: Home,
                        managedObjContext: NSManagedObjectContext,
                        entity: HomeEntity?,
                        language: String) {
        var homeInfo = entity
        if entity == nil {
            homeInfo = NSEntityDescription.insertNewObject(forEntityName: "HomeEntity",
                                                           into: managedObjContext) as? HomeEntity
        }
        homeInfo?.id = homeListDict.id
        homeInfo?.name = homeListDict.name
        homeInfo?.image = homeListDict.image
        homeInfo?.tourguideavailable = homeListDict.isTourguideAvailable
        homeInfo?.sortid = (Int16(homeListDict.sortId!) ?? 0)
        homeInfo?.lang = language
        managedObjContext.saveContext()
    }
    
    static func updateHomeBanner(managedContext: NSManagedObjectContext,
                                 list: [HomeBanner]) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "HomeBannerEntity",
                                                         idKey: "fullContentID",
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [HomeBannerEntity]
        let homeListDict = list[0]
        if !fetchData.isEmpty {
            if DataManager.delete(managedContext: managedContext,
                                  entityName: "HomeBannerEntity") {
                DataManager.saveHomeBannerT(homeListDict: homeListDict,
                                     managedObjContext: managedContext,
                                     entity: nil)
            }
            
        } else {
            //save
            DataManager.saveHomeBannerT(homeListDict: homeListDict,
                                 managedObjContext: managedContext,
                                 entity: nil)
        }
    }
    
    static func saveHomeBannerT(homeListDict: HomeBanner,
                         managedObjContext: NSManagedObjectContext,
                         entity: HomeBannerEntity?) {
        
        var homeInfo = entity
        if entity == nil {
            homeInfo = NSEntityDescription.insertNewObject(forEntityName: "HomeBannerEntity",
                                                           into: managedObjContext) as? HomeBannerEntity
        }
        homeInfo?.title = homeListDict.title
        homeInfo?.fullContentID = homeListDict.fullContentID
        homeInfo?.bannerTitle = homeListDict.bannerTitle
        homeInfo?.bannerLink = homeListDict.bannerLink
        homeInfo?.language = Utils.getLanguage()
        
        if let images = homeListDict.image{
            for image in images {
                homeInfo?.addToBannerImageRelations(DataManager.getImageEntity(image, context: managedObjContext))
                managedObjContext.saveContext()
            }
        }
        managedObjContext.saveContext()
    }
    
    static func updateHeritage(managedContext: NSManagedObjectContext,
                               heritageListArray: [Heritage],
                               language: String) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "HeritageEntity",
                                                         idKey: "lang",
                                                         idValue: language,
                                                         managedContext: managedContext) as! [HeritageEntity]
        
        if (fetchData.count > 0) {
            for heritageListDict in heritageListArray {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "HeritageEntity",
                                                                   idKey: "listid",
                                                                   idValue: heritageListDict.id,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let heritagedbDict = fetchResult[0] as! HeritageEntity
                    DataManager.saveTHeritage(heritageListDict: heritageListDict,
                                              managedObjContext: managedContext,
                                              entity: heritagedbDict, language: language)
                } else {
                    //save
                    DataManager.saveTHeritage(heritageListDict: heritageListDict,
                                              managedObjContext: managedContext,
                                              entity: nil, language: language)
                    
                }
            }
        } else {
            for heritageListDict in heritageListArray {
                DataManager.saveTHeritage(heritageListDict: heritageListDict,
                                          managedObjContext: managedContext,
                                          entity: nil, language: language)
            }
        }
    }
    
    static func saveTHeritage(heritageListDict: Heritage,
                       managedObjContext: NSManagedObjectContext,
                       entity: HeritageEntity?, language: String) {
        
        var heritageInfo = entity
        if entity == nil {
            heritageInfo = NSEntityDescription.insertNewObject(forEntityName: "HeritageEntity",
                                                               into: managedObjContext) as? HeritageEntity
        }
        heritageInfo?.listid = heritageListDict.id
        heritageInfo?.listname = heritageListDict.name
        heritageInfo?.listimage = heritageListDict.image
        heritageInfo?.lang = language
        if let sortID = heritageListDict.sortid {
            heritageInfo?.listsortid = sortID
        }
        managedObjContext.saveContext()
    }
    
    static func updateFloorMap(managedContext: NSManagedObjectContext,
                               floorMapArray: [TourGuideFloorMap],
                               tourGuideID: String?) {
        if !floorMapArray.isEmpty {
            let fetchData = DataManager.checkAddedToCoredata(entityName: "FloorMapTourGuideEntity",
                                                             idKey: "tourGuideId",
                                                             idValue: tourGuideID,
                                                             managedContext: managedContext)
            
            if (fetchData.count > 0) {
                for tourGuideDeatilDict in floorMapArray {
                    let fetchResult = DataManager.checkAddedToCoredata(entityName: "FloorMapTourGuideEntity",
                                                                       idKey: "nid",
                                                                       idValue: tourGuideDeatilDict.nid,
                                                                       managedContext: managedContext) as! [FloorMapTourGuideEntity]
                    
                    if !fetchResult.isEmpty {
                        //update
                        let tourguidedbDict = fetchResult[0]
                        DataManager.saveFloorMapTourGuide(tourGuideDetailDict: tourGuideDeatilDict,
                                                   managedObjContext: managedContext,
                                                   entity: tourguidedbDict)
                    } else {
                        DataManager.saveFloorMapTourGuide(tourGuideDetailDict: tourGuideDeatilDict,
                                                   managedObjContext: managedContext,
                                                   entity: nil)
                    }
                }//for
            }//if
            else {
                for tourGuideDetailDict in floorMapArray {
                    DataManager.saveFloorMapTourGuide(tourGuideDetailDict: tourGuideDetailDict,
                                               managedObjContext: managedContext,
                                               entity: nil)
                }
                
            }
        }
    }
    
    static func saveFloorMapTourGuide(tourGuideDetailDict: TourGuideFloorMap,
                               managedObjContext: NSManagedObjectContext,
                               entity: FloorMapTourGuideEntity?) {
        var tourguidedbDict = entity
        if entity == nil {
            tourguidedbDict = NSEntityDescription.insertNewObject(forEntityName: "FloorMapTourGuideEntity",
                                                                  into: managedObjContext) as? FloorMapTourGuideEntity
        }
        tourguidedbDict?.title = tourGuideDetailDict.title
        tourguidedbDict?.accessionNumber = tourGuideDetailDict.accessionNumber
        tourguidedbDict?.nid =  tourGuideDetailDict.nid
        tourguidedbDict?.curatorialDescription = tourGuideDetailDict.curatorialDescription
        tourguidedbDict?.diam = tourGuideDetailDict.diam
        
        tourguidedbDict?.dimensions = tourGuideDetailDict.dimensions
        tourguidedbDict?.mainTitle = tourGuideDetailDict.mainTitle
        tourguidedbDict?.objectEngSummary =  tourGuideDetailDict.objectENGSummary
        tourguidedbDict?.objectHistory = tourGuideDetailDict.objectHistory
        tourguidedbDict?.production = tourGuideDetailDict.production
        
        tourguidedbDict?.productionDates = tourGuideDetailDict.productionDates
        tourguidedbDict?.image = tourGuideDetailDict.image
        tourguidedbDict?.tourGuideId =  tourGuideDetailDict.tourGuideId
        tourguidedbDict?.artifactNumber = tourGuideDetailDict.artifactNumber
        tourguidedbDict?.artifactPosition = tourGuideDetailDict.artifactPosition
        
        tourguidedbDict?.audioDescriptif = tourGuideDetailDict.audioDescriptif
        tourguidedbDict?.audioFile = tourGuideDetailDict.audioFile
        tourguidedbDict?.floorLevel =  tourGuideDetailDict.floorLevel
        tourguidedbDict?.galleyNumber = tourGuideDetailDict.galleyNumber
        tourguidedbDict?.artistOrCreatorOrAuthor = tourGuideDetailDict.artistOrCreatorOrAuthor
        tourguidedbDict?.periodOrStyle = tourGuideDetailDict.periodOrStyle
        tourguidedbDict?.techniqueAndMaterials = tourGuideDetailDict.techniqueAndMaterials
        tourguidedbDict?.thumbImage = tourGuideDetailDict.thumbImage
        tourguidedbDict?.language = Utils.getLanguage()
        
        
        if let images = tourGuideDetailDict.images {
            for image in images {
                tourguidedbDict?.addToImagesRelation(DataManager.getImageEntity(image, context: managedObjContext))
                managedObjContext.saveContext()
            }
        }
        
        managedObjContext.saveContext()
    }
    
    static func updateExhibitionsEntity(managedContext: NSManagedObjectContext,
                                 exhibition: [Exhibition],
                                 isHomeExhibition : String?,
                                 language: String) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "ExhibitionsEntity",
                                                         idKey: "lang",
                                                         idValue: language,
                                                         managedContext: managedContext) as! [ExhibitionsEntity]
        if (fetchData.count > 0) {
            for exhibitionsListDict in exhibition {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "ExhibitionsEntity",
                                                                   idKey: "id",
                                                                   idValue: exhibitionsListDict.id,
                                                                   managedContext: managedContext) as! [ExhibitionsEntity]
                //update
                if !fetchResult.isEmpty {
                    let exhibitionsdbDict = fetchResult[0]
                    DataManager.saveExhibitionsEntity(exhibitionDict: exhibitionsListDict,
                                               managedObjContext: managedContext,
                                               isHomeExhibition :isHomeExhibition,
                                               entity: exhibitionsdbDict,
                                               language: language)
                } else {
                    //save
                    DataManager.saveExhibitionsEntity(exhibitionDict: exhibitionsListDict,
                                               managedObjContext: managedContext,
                                               isHomeExhibition :isHomeExhibition,
                                               entity: nil,
                                               language: language)
                }
            }//for
        } else {
            for exhibitionListDict in exhibition {
                DataManager.saveExhibitionsEntity(exhibitionDict: exhibitionListDict,
                                           managedObjContext: managedContext,
                                           isHomeExhibition :isHomeExhibition,
                                           entity:  nil,
                                           language: language)
            }
        }
    }
    
    static func saveExhibitionsEntity(exhibitionDict: Exhibition,
                               managedObjContext: NSManagedObjectContext,
                               isHomeExhibition : String?,
                               entity: ExhibitionsEntity?, language: String) {
        
        var exhibitionInfo = entity
        if entity == nil {
            exhibitionInfo = NSEntityDescription.insertNewObject(forEntityName: "ExhibitionsEntity",
                                                                 into: managedObjContext) as? ExhibitionsEntity
        }
        
        exhibitionInfo?.id = exhibitionDict.id
        exhibitionInfo?.name = exhibitionDict.name
        exhibitionInfo?.image = exhibitionDict.image
        exhibitionInfo?.startDate =  exhibitionDict.startDate
        exhibitionInfo?.endDate = exhibitionDict.endDate
        exhibitionInfo?.location =  exhibitionDict.location
        exhibitionInfo?.museumId =  exhibitionDict.museumId
        exhibitionInfo?.status =  exhibitionDict.status
        exhibitionInfo?.isHomeExhibition =  isHomeExhibition
        exhibitionInfo?.lang = language
        
        exhibitionInfo?.detailName = exhibitionDict.name
        exhibitionInfo?.detailImage = exhibitionDict.detailImage
        exhibitionInfo?.detailStartDate = exhibitionDict.startDate
        exhibitionInfo?.detailEndDate = exhibitionDict.endDate
        exhibitionInfo?.detailShortDesc =  exhibitionDict.shortDescription
        exhibitionInfo?.detailLongDesc =  exhibitionDict.longDescription
        exhibitionInfo?.detailLocation = exhibitionDict.location
        exhibitionInfo?.detailLatitude =  exhibitionDict.latitude
        exhibitionInfo?.detailLongitude = exhibitionDict.longitude
        exhibitionInfo?.status = exhibitionDict.status
        
        managedObjContext.saveContext()
    }
    
    static func updateCollectionDetailsEntity(managedContext: NSManagedObjectContext,
                                              collectionDetailArray: [CollectionDetail],
                                              collectionName: String?) {
//
//        if let fetchData = DataManager.checkAddedToCoredata(entityName: "CollectionDetailsEntity",
//                                                            idKey: "categoryCollection",
//                                                            idValue: collectionName,
//                                                            managedContext: managedContext) as? [CollectionDetailsEntity],
//            !fetchData.isEmpty {
            for collectionDetailDict in collectionDetailArray {
                if let fetchData = DataManager.checkAddedToCoredata(entityName: "CollectionDetailsEntity",
                                                                    idKey: "nid",
                                                                    idValue: collectionDetailDict.nid,
                                                                    managedContext: managedContext) as? [CollectionDetailsEntity],
                    !fetchData.isEmpty {
                    let collectiondbDict = fetchData[0]
                    DataManager.saveCollectionDetailsEntity(collectionDetailDict: collectionDetailDict,
                                                     managedObjContext: managedContext,
                                                     entity: collectiondbDict)
                    
                } else {
                    DataManager.saveCollectionDetailsEntity(collectionDetailDict: collectionDetailDict,
                                                     managedObjContext: managedContext,
                                                     entity: nil)
                }
            }
            
//        } else {
//            for collectionDetailDict in collectionDetailArray {
//                DataManager.saveCollectionDetailsEntity(collectionDetailDict: collectionDetailDict,
//                                                 managedObjContext: managedContext,
//                                                 entity: nil)
//            }
//        }
    }
    
    static func saveCollectionDetailsEntity(collectionDetailDict: CollectionDetail,
                                     managedObjContext: NSManagedObjectContext,
                                     entity: CollectionDetailsEntity?) {
        var collectiondbDict = entity
        if entity == nil {
            collectiondbDict = NSEntityDescription.insertNewObject(forEntityName: "CollectionDetailsEntity",
                                                                   into: managedObjContext) as? CollectionDetailsEntity
        }
        collectiondbDict?.title = collectionDetailDict.title
        collectiondbDict?.body = collectionDetailDict.body
        collectiondbDict?.nid = collectionDetailDict.nid
        collectiondbDict?.categoryCollection =  collectionDetailDict.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;",
                                                                                                              with: "",
                                                                                                              options: .regularExpression,
                                                                                                              range: nil)
        collectiondbDict?.image = collectionDetailDict.image
        collectiondbDict?.language = Utils.getLanguage()
        
        managedObjContext.saveContext()
    }
    
    static func updateCollectionsEntity(managedContext: NSManagedObjectContext,
                                        collection: [Collection], language: String) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "CollectionsEntity",
                                                         idKey: "lang",
                                                         idValue: language,
                                                         managedContext: managedContext) as! [CollectionsEntity]
        if !fetchData.isEmpty {
            if DataManager.delete(managedContext: managedContext, entityName: "CollectionsEntity") {
                for collectionListDict in collection {
                    DataManager.saveCollectionsEntity(collectionListDict: collectionListDict,
                                                      managedObjContext: managedContext, language: language)
                }
            }
        } else {
            for collectionListDict in collection {
                DataManager.saveCollectionsEntity(collectionListDict: collectionListDict,
                                                  managedObjContext: managedContext, language: language)
            }
        }
    }
    
    static func saveCollectionsEntity(collectionListDict: Collection,
                                      managedObjContext: NSManagedObjectContext, language: String) {
        let collectionInfo: CollectionsEntity = NSEntityDescription.insertNewObject(forEntityName: "CollectionsEntity",
                                                                                    into: managedObjContext) as! CollectionsEntity
        collectionInfo.listName = collectionListDict.name?.replacingOccurrences(of: "<[^>]+>|&nbsp;",
                                                                                with: "",
                                                                                options: .regularExpression,
                                                                                range: nil)
        collectionInfo.listImage = collectionListDict.image
        collectionInfo.museumId = collectionListDict.museumId
        collectionInfo.lang = language
        managedObjContext.saveContext()
    }
    
    static func updateFacilitiesEntity(facilitiesList: [Facilities],
                                       managedContext: NSManagedObjectContext,
                                       language: String) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "FacilitiesEntity",
                                                         idKey: "nid",
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [FacilitiesEntity]
        if (fetchData.count > 0) {
            for facilitiesListDict in facilitiesList {
                let fetchResult = DataManager.checkAddedToCoredata(entityName: "FacilitiesEntity",
                                                                   idKey: "nid",
                                                                   idValue: facilitiesListDict.nid,
                                                                   managedContext: managedContext)
                //update
                if !fetchResult.isEmpty {
                    let facilitiesListdbDict = fetchResult[0] as! FacilitiesEntity
                    DataManager.saveFacilitiesEntity(facilitiesListDict: facilitiesListDict,
                                              managedObjContext: managedContext,
                                              entity: facilitiesListdbDict,
                                              language: language)
                } else {
                    //save
                    DataManager.saveFacilitiesEntity(facilitiesListDict: facilitiesListDict,
                                              managedObjContext: managedContext,
                                              entity: nil,
                                              language: language)
                }
            }
        } else {
            for facilitiesListDict in facilitiesList {
                DataManager.saveFacilitiesEntity(facilitiesListDict: facilitiesListDict,
                                          managedObjContext: managedContext,
                                          entity: nil,
                                          language: language)
            }
        }
    }
    
    static func saveFacilitiesEntity(facilitiesListDict: Facilities,
                              managedObjContext: NSManagedObjectContext,
                              entity: FacilitiesEntity?,
                              language: String) {
        var facilitiesListInfo = entity
        if entity == nil {
            facilitiesListInfo = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesEntity",
                                                                     into: managedObjContext) as? FacilitiesEntity
        }
        facilitiesListInfo?.title = facilitiesListDict.title
        facilitiesListInfo?.sortId = facilitiesListDict.sortId
        facilitiesListInfo?.nid = facilitiesListDict.nid
        facilitiesListInfo?.language = language
        
        if let images = facilitiesListDict.images {
            for image in images {
                facilitiesListInfo?.addToFacilitiesImgRelation(DataManager.getImageEntity(image, context: managedObjContext))
                managedObjContext.saveContext()
            }
        }
        
        managedObjContext.saveContext()
    }
    
    static func saveRegisteredEventListEntity(managedContext: NSManagedObjectContext,
                                              list: [NMoQUserEventList]) {
        for eventList in list {
            let userEventInfo: RegisteredEventListEntity = NSEntityDescription.insertNewObject(forEntityName: "RegisteredEventListEntity",
                                                                                               into: managedContext) as! RegisteredEventListEntity
            let userEventListDict = eventList
            userEventInfo.title = userEventListDict.title
            userEventInfo.eventId = userEventListDict.eventID
            userEventInfo.regId = userEventListDict.regID
            userEventInfo.seats = userEventListDict.seats
            managedContext.saveContext()
        }
    }
}

