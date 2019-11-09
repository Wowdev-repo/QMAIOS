//
//  CPEducationEvent.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 19/08/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Foundation
struct CPEducationEvent: CPResponseObjectSerializable, CPResponseCollectionSerializable {
    var title: String? = nil
    var fieldRepeatDate: [String]? = []
    var ageGroup: [String]? = []
    var associatedTopics: [String]? = []
    var introductionText: String? = nil
    var museumDepartMent: String? = nil
    var programType: String? = nil
    var register: String? = nil
    var startDate: [String]? = []
    var endDate: [String]? = []
    var itemId: String? = nil
    var mainDescription: String? = nil
    
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            
            self.title = representation["title"] as? String
            self.fieldRepeatDate = representation["field_eduprog_repeat_field_date"] as? [String]
            self.ageGroup = representation["Age_group"] as? [String]
            self.associatedTopics = representation["Associated_topics"] as? [String]
            self.introductionText = representation["Introduction_Text"] as? String
            self.museumDepartMent = representation["Museum_Department"] as? String
            self.programType = representation["Programme_type"] as? String
            self.register = representation["Register"] as? String
            self.startDate = representation["start_Date"] as? [String]
            self.endDate = representation["End_Date"] as? [String]
            self.itemId = representation["item_id"] as? String
            self.mainDescription = representation["main_description"] as? String
            
        }
    }

    
    init (itemId:String?, introductionText: String?, register: String?, fieldRepeatDate: [String]?, title: String?,programType:String?,mainDescription: String?,ageGroup:[String]?,associatedTopics:[String]?,museumDepartMent:String?,startDate:[String]?,endDate:[String]?) {
//    init (itemId:String?, introductionText: String?, register: String?, fieldRepeatDate: [String]?, title: String?,programType:String?,mainDescription:[String]?) {
        self.itemId = itemId
        self.introductionText = introductionText
        self.register = register
        self.fieldRepeatDate = fieldRepeatDate
        self.title = title
        self.programType = programType
        self.mainDescription = mainDescription
        
        self.ageGroup = ageGroup
        self.associatedTopics = associatedTopics
        self.museumDepartMent = museumDepartMent
        self.startDate = startDate
        self.endDate = endDate
        
    }
    
    
    init(entity: EducationEventEntity) {
        self.itemId = entity.itemId
        self.introductionText = entity.introductionText
        self.register = entity.register
        self.title = entity.title
        self.programType = entity.pgmType
        self.mainDescription = entity.mainDesc
        self.museumDepartMent = entity.museumDepartMent
        
        var dateArray = [String]()
        if let educationInfoArray = (entity.fieldRepeatDates?.allObjects) as? [DateEntity] {
            for info in educationInfoArray {
                if let date = info.date {
                    dateArray.append(date)
                }
            }
        }
        
        var ageGrpArray = [String]()
        if let educationInfoArray = (entity.ageGroupRelation?.allObjects) as? [EdAgeGroupEntity] {
            for info in educationInfoArray {
                if let ageGroup = info.ageGroup {
                    ageGrpArray.append(ageGroup)
                }
            }
        }
        
        var topicsArray = [String]()
        if let educationInfoArray = (entity.fieldRepeatDates?.allObjects) as? [EdEventTopicsEntity] {
            for info in educationInfoArray {
                if let associatedTopic = info.associatedTopic {
                    topicsArray.append(associatedTopic)
                }
            }
        }
        
        var startDateArray = [String]()
        if let educationInfoArray = (entity.startDateRelation?.allObjects) as? [DateEntity] {
            for info in educationInfoArray {
                if let date = info.date {
                    startDateArray.append(date)
                }
            }
        }
        
        var endDateArray = [String]()
        if let educationInfoArray = (entity.endDateRelation?.allObjects) as? [DateEntity] {
            for info in educationInfoArray {
                if let date = info.date {
                    endDateArray.append(date)
                }
            }
        }
        
        self.fieldRepeatDate = dateArray
        self.ageGroup = ageGrpArray
        self.associatedTopics = topicsArray
        self.startDate = startDateArray
        self.endDate = endDateArray
    }
}

struct EducationEventList: CPResponseObjectSerializable {
    var educationEvent: [CPEducationEvent]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.educationEvent = CPEducationEvent.collection(response: response, representation: data as AnyObject)
        }
    }
}
