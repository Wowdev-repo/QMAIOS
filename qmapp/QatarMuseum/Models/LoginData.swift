

import Foundation
struct LoginData: ResponseObjectSerializable {
    var sessid: String? = nil
    var sessionName: String? = nil
    var token: String? = nil
    var user: UserData?
    var result:  String? = nil
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
            if let representation = representation as? [String: Any] {
                self.sessid = representation["sessid"] as? String
                self.sessionName = representation["session_name"] as? String
                self.token = representation["token"] as? String
                self.result = representation["result"] as? String
            }
        if let data = representation["user"] {
            self.user = UserData.init(response: response, representation: data as AnyObject)
        }
    }
}

struct UserData: ResponseObjectSerializable {
    var uid: String? = nil
    var name: String? = nil
    var mail: String? = nil
    var theme: String? = nil
    var signature: String? = nil
    var signatureFormat: String? = nil
    var created: String? = nil
    var access: String? = nil
    var login: String? = nil
    var status: String? = nil
    var timezone: String? = nil
    var language: String? = nil
    var picture: String? = nil
    var initEmail: String? = nil
    var data: [String: Any] = [:]
    var roles: [String: Any] = [:]
    var fieldDateOfBirth: [String]? = []
    var fieldFirstName: [String: Any] = [:]
    var fieldLastName: [String: Any] = [:]
    var fieldLocation: [String: Any] = [:]
    var fieldNationality: [String: Any] = [:]
    var fieldRecieveNewsletter: [String: Any] = [:]
    var fieldTitle: [String: Any] = [:]
    var fieldMobileNumberPhone: [String: Any] = [:]
    var metatags: [String]? = []
    var translations: [String: Any] = [:]
    var drupagramAccounts: [String]? = []
    var twitterAccounts: [String]? = []
    var fieldRsvpAttendance :  [String]? = []
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.uid = representation["uid"] as? String
            self.name = representation["name"] as? String
            self.mail = representation["mail"] as? String
            self.theme = representation["theme"] as? String
            self.signature = representation["signature"] as? String
            self.signatureFormat = representation["signature_format"] as? String
            self.created = representation["created"] as? String
            self.access = representation["access"] as? String
            self.login = representation["login"] as? String
            self.status = representation["status"] as? String
            self.timezone = representation["timezone"] as? String
            self.language = representation["language"] as? String
            self.picture = representation["picture"] as? String
            self.initEmail = representation["init"] as? String       //
            self.data = (representation["data"] as? [String: Any])!
            self.roles = (representation["roles"] as? [String: Any])!
            self.fieldDateOfBirth = representation["field_date_of_birth"] as? [String]
            self.fieldFirstName = (representation["field_first_name"] as? [String: Any])!
            self.fieldLastName = (representation["field_last_name"] as? [String: Any])!
            self.fieldLocation = (representation["field_location"] as? [String: Any])!
            self.fieldNationality = (representation["field_nationality"] as? [String: Any])!
            self.fieldRecieveNewsletter = (representation["field_recieve_newsletter"] as? [String: Any])!
            self.fieldTitle = (representation["field_title"] as? [String: Any])!
            self.fieldMobileNumberPhone = (representation["field_mobile_number_phone"] as? [String: Any])!
            self.metatags = representation["metatags"] as? [String]
            self.translations = (representation["translations"] as? [String: Any])!
            self.drupagramAccounts = representation["drupagram_accounts"] as? [String]
            self.twitterAccounts = representation["twitter_accounts"] as? [String]
            self.fieldRsvpAttendance = representation["field_rsvp_attendance"] as? [String]
            
        }
    }
}

struct UserInfoData: ResponseObjectSerializable {
    var uid: String? = nil
    var roles: [String: Any]? = [:]
    var fieldRsvpAttendance : [String: Any]? = [:]
    
    public init?(response: HTTPURLResponse, representation: AnyObject) {
        if let representation = representation as? [String: Any] {
            self.uid = representation["uid"] as? String
            self.roles = (representation["roles"] as? [String: Any])
            self.fieldRsvpAttendance = (representation["field_rsvp_attendance"] as? [String: Any])
        }
    }
}

