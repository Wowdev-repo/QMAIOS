//
//  DataManager.swift
//  QatarMuseums
//
//  Created by Subins P Jose on 06/06/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import UIKit
import CoreData

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
        var fetchResults : [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
        if let key = idKey, let value = idValue {
            fetchRequest.predicate = NSPredicate.init(format: "\(key) == \(value)")
        }
        fetchResults = try! managedContext.fetch(fetchRequest)
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
}

//Fetch functions
extension DataManager {
    
    static func fetchEvents(_ context: NSManagedObjectContext,for date: Date) -> [EducationEvent] {
        let dateID = Utils.uniqueDate(date)
        let educationArray = DataManager.checkAddedToCoredata(entityName: "EventEntity",
                                                              idKey: "dateId",
                                                              idValue: dateID,
                                                              managedContext: context)  as! [EventEntity]
        
        var educationEventArray = [EducationEvent]()
        for educationInfo in educationArray {
            var dateArray : [String] = []
            let educationInfoArray = (educationInfo.fieldRepeatDates?.allObjects) as! [DateEntity]
            for i in 0 ... educationInfoArray.count-1 {
                dateArray.append(educationInfoArray[i].date!)
            }
            var ageGrpArray : [String] = []
            let ageInfoArray = (educationInfo.ageGroupRelation?.allObjects) as! [EventAgeGroupEntity]
            for i in 0 ... ageInfoArray.count-1 {
                ageGrpArray.append(ageInfoArray[i].ageGroup!)
            }
            var topicsArray : [String] = []
            let topicsInfoArray = (educationInfo.assTopicRelation?.allObjects) as! [EventTopicsEntity]
            for i in 0 ... topicsInfoArray.count-1 {
                topicsArray.append(topicsInfoArray[i].associatedTopic!)
            }
            var startDateArray : [String] = []
            let startDateInfoArray = (educationInfo.startDateRelation?.allObjects) as! [DateEntity]
            for i in 0 ... startDateInfoArray.count-1 {
                startDateArray.append(startDateInfoArray[i].date!)
            }
            var endDateArray : [String] = []
            let endDateInfoArray = (educationInfo.endDateRelation?.allObjects) as! [DateEntity]
            for i in 0 ... endDateInfoArray.count-1 {
                endDateArray.append(endDateInfoArray[i].date!)
            }
            
            educationEventArray.append(EducationEvent(itemId: educationInfo.itemId,
                                                      introductionText: educationInfo.introductionText,
                                                      register: educationInfo.register,
                                                      fieldRepeatDate: dateArray,
                                                      title: educationInfo.title,
                                                      programType: educationInfo.pgmType,
                                                      mainDescription: educationInfo.mainDesc,
                                                      ageGroup: ageGrpArray,
                                                      associatedTopics: topicsArray,
                                                      museumDepartMent: educationInfo.museumDepartMent,
                                                      startDate: startDateArray,
                                                      endDate: endDateArray))
        }
        
        return educationEventArray
    }
    
    
}

//Store functions
extension DataManager {
    
    /// Store education events
    ///
    /// - Parameters:
    ///   - events: EducationEvent list
    ///   - date: Date
    ///   - managedContext: NSManagedObjectContext
    static func storeEducationEvents(events: [EducationEvent],
                              for date: Date,
                              managedContext: NSManagedObjectContext) {
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
                                                 managedObjContext: managedContext)
                    }
                } else {
                    self.saveEventToCoreData(educationEventDict: educationDict,
                                             dateId: dateID,
                                             managedObjContext: managedContext)
                }
            }
                
        } else {
            for educationEvent in events {
                self.saveEventToCoreData(educationEventDict: educationEvent,
                                         dateId: dateID,
                                         managedObjContext: managedContext)
            }
        }
    }
    
    static func saveEventToCoreData(educationEventDict: EducationEvent,
                             dateId: String?,
                             managedObjContext: NSManagedObjectContext) {
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
        edducationInfo.language = Utils.getLanguage()
        
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
                    do {
                        try managedObjContext.save()
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
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
                do {
                    try managedObjContext.save()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
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
                do {
                    try managedObjContext.save()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
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
                do {
                    try managedObjContext.save()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
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
                do {
                    try managedObjContext.save()
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
        
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

