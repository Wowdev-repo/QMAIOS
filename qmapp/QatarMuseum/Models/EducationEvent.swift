//
//  EducationEvent.swift
//  QatarMuseums
//
//  Created by Exalture on 19/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation
struct EducationEvent: ResponseObjectSerializable, ResponseCollectionSerializable {
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
}

struct EducationEventList: ResponseObjectSerializable {
    var educationEvent: [EducationEvent]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let data = representation as? [[String: Any]] {
            self.educationEvent = EducationEvent.collection(response: response, representation: data as AnyObject)
        }
    }
}
