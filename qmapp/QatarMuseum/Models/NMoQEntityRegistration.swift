//
//  NMoQEntityRegistration.swift
//  QatarMuseums
//
//  Created by Exalture on 07/12/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import Foundation
struct NMoQEntityRegistration: ResponseObjectSerializable {
    var registrationId: String? = nil
    var type: String? = nil
    var entityId: String? = nil
    var entityType: String? = nil
    var anonMail: String? = nil
    var userUid:  String? = nil
    
    var count: String? = nil
    var authorUid: String? = nil
    var state: String? = nil
    var created: String? = nil
    var updated:  String? = nil
    
    var fieldConfirmAttendance: [String: Any] = [:]
    var fieldNumberOfAttendees: [String: Any] = [:]
    var fieldFirstName: [String: Any] = [:]
    var fieldNmoqLastName: [String: Any] = [:]
    var fieldMembershipNumber: [String: Any] = [:]
    var fieldQmaEduEegDate: [String: Any] = [:]
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.registrationId = representation["registration_id"] as? String
            self.type = representation["type"] as? String
            self.entityId = representation["entity_id"] as? String
            self.entityType = representation["entity_type"] as? String
            self.anonMail = representation["anon_mail"] as? String
            self.userUid = representation["user_uid"] as? String
            self.count = representation["count"] as? String
            self.authorUid = representation["author_uid"] as? String
            self.state = representation["state"] as? String
            self.created = representation["created"] as? String
            self.updated = representation["updated"] as? String
            self.fieldConfirmAttendance = (representation["field_confirm_attendance"] as? [String: Any])!
            
            self.fieldNumberOfAttendees = (representation["field_number_of_attendees"] as? [String: Any])!
            self.fieldFirstName = (representation["field_first_name_"] as? [String: Any])!
            self.fieldNmoqLastName = (representation["field_nmoq_last_name"] as? [String: Any])!
            self.fieldMembershipNumber = (representation["field_membership_number"] as? [String: Any])!
            self.fieldQmaEduEegDate = (representation["field_qma_edu_reg_date"] as? [String: Any])!
        }
       
    }
}



