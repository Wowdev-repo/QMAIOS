//
//  CPDataManager+Fetch.swift
//  QatarMuseums
//
//  Created by Subins P Jose on 15/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation


//Fetch functions
extension CPDataManager {
    
    static func fetchEvents(_ context: NSManagedObjectContext, for date: Date) -> [CPEducationEvent] {
        let dateID = CPUtils.uniqueDate(date)
        let educationArray = CPDataManager.checkAddedToCoredata(entityName: "EventEntity",
                                                              idKey: "dateId",
                                                              idValue: dateID,
                                                              managedContext: context)  as! [EventEntity]
        
        var educationEventArray = [CPEducationEvent]()
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
            
            educationEventArray.append(CPEducationEvent(itemId: educationInfo.itemId,
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
    
    static func fetchMuseumLandingImages(_ museumID: String) -> [CPMuseum] {
        var museumArray = [CPMuseum]()
        let managedContext = getContext()
        var aboutArray = [AboutEntity]()
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "AboutEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", museumID)
        do { aboutArray = try managedContext.fetch(fetchRequest) as! [AboutEntity] } catch _ {}
        if !aboutArray.isEmpty {
            let aboutDict = aboutArray[0]
            museumArray.append(CPMuseum(entity: aboutDict))
        }
        
        return museumArray
    }
}
