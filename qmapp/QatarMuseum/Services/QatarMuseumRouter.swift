//
//  QatarMuseumRouter.swift
//  QatarMuseums
//
//  Created by Developer on 24/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import Foundation

enum QatarMuseumRouter: URLRequestConvertible {
    case ExhibitionList()
    case MuseumExhibitionList([String: Any])
    case HomeList(String)
    case HeritageList(String)
    case ExhibitionDetail([String: Any])
    case DiningList(String)
    case PublicArtsList(String)
    case ParksList()
    case GetDiningDetail([String: Any])
    case HeritageDetail([String: Any])
    case GetPublicArtsDetail([String: Any])
    case CollectionList([String: Any])
    case EducationEvent([String: Any])
    case LandingPageMuseums([String: Any])
    case MuseumDiningList([String: Any])
    case CollectionDetail([String: Any])
    case MuseumTourGuide(String,[String: Any])
    case CollectionByTourGuide(String,[String: Any])
    case GetToken([String: Any])
    case Login([String: Any])
    case Logout()
    case NewPasswordRequest([String: Any])
    case GetUser(String)
    case UpdateUser(String,[String: Any])
    case SendDeviceToken(String, [String: Any])
    case NumberSearchList([String: Any])
    case GetHomeBanner()
    case GetNMoQAboutEvent([String: Any])
    case GetNMoQTourList()
    case GetNMoQTravelList()
    case GetNMoQSpecialEventList()
    case GetNMoQSpecialEventDetail([String: Any])
    case GetNMoQTourDetail([String: Any])
    case NMoQEventListUserRegistration([String: Any])
    case NMoQEntityRegistration([String: Any])
    case SetUserRegistrationComplete(String,[String: Any])
    case SetUserUnRegistration(String,[String: Any])
    var method: Alamofire.HTTPMethod {
        switch self {
        case .ExhibitionList:
            return .get
        case .HomeList:
            return .get
        case .HeritageList:
            return .get
        case .ExhibitionDetail:
            return .get
        case .DiningList:
            return .get
        case .PublicArtsList:
            return .get
        case .ParksList:
            return .get
        case .GetDiningDetail:
            return .get
        case .HeritageDetail:
            return .get
        case .GetPublicArtsDetail:
            return .get
        case .CollectionList:
            return .get
        case .EducationEvent:
            return .get
        case .LandingPageMuseums:
            return .get
        case .MuseumDiningList:
            return .get
        case .MuseumExhibitionList:
            return .get
        case .CollectionDetail:
            return .get
        case .MuseumTourGuide:
            return .get
        case .CollectionByTourGuide:
            return .get
        case .GetToken:
            return .post
        case .Login:
            return .post
        case .Logout:
            return .post
        case .NewPasswordRequest:
            return .post
        case .GetUser:
            return .get
        case .UpdateUser:
            return .put
        case .SendDeviceToken:
            return .post
        case .NumberSearchList:
            return .get
        case .GetHomeBanner:
            return .get
        case .GetNMoQAboutEvent:
            return .get
        case .GetNMoQTourList:
            return .get
        case .GetNMoQTravelList:
            return .get
        case .GetNMoQSpecialEventList:
            return .get
        case .GetNMoQSpecialEventDetail:
            return .get
        case .GetNMoQTourDetail:
            return .get
        case .NMoQEventListUserRegistration:
            return .get
        case .NMoQEntityRegistration:
            return .post
        case .SetUserRegistrationComplete:
            return .put
        case .SetUserUnRegistration:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .ExhibitionList:
            return "Exhibition_List_Page.json"
        case .HomeList( _):
            return "/gethomeList.json"
        case .HeritageList( _):
            return "/Heritage_List_Page.json"
        case .ExhibitionDetail( _):
            return "/Exhibition_detail_Page.json"
        case .DiningList( _):
            return "/getDiningList.json"
        case .ParksList:
            return "/park_service_combined.json"
        case .PublicArtsList( _):
            return "/Public_Arts_List_Page.json"
        case .GetDiningDetail( _):
            return "/getDiningdetail.json"
        case .HeritageDetail( _):
            return "/heritage_detail_Page.json"
        case .GetPublicArtsDetail( _):
            return "/getpublicartdetail.json"
        case .CollectionList( _):
            return "/museum_collection_category.json"
        case .CollectionDetail( _):
            return "/collection_ws.json"
        case .EducationEvent( _):
            return "/new_ws_educations.json"
        case .LandingPageMuseums( _):
            return "/museum-detail.json"
        case .MuseumDiningList( _):
            return "/getDiningList.json"
        case .MuseumExhibitionList( _):
            return "Exhibition_List_Page.json"
        case .MuseumTourGuide( _, _):
            return "tour_guide_list_museums.json"
        case .CollectionByTourGuide( _, _):
            return "collection_by_tour_guide.json"
        case .GetToken( _):
            return "user/token.json"
        case .Login( _):
            return "user/login.json"
        case .Logout:
            return "user/logout.json"
        case .NewPasswordRequest( _):
            return "user/request_new_password.json"
        case .GetUser(let userId):
            return "/user/\(userId).json"
        case .UpdateUser(let userId,_):
            return "/user/\(userId).json"
        case .SendDeviceToken( _, _):
            return "push_notifications.json"
        case .NumberSearchList( _):
            return "/collection_by_tour_guide.json"
        case .GetHomeBanner:
            return "/nmoq_banner_banner.json"
        case .GetNMoQAboutEvent( _):
            return "/nmoq_about_page.json"
        case .GetNMoQTourList:
            return "/nmoq_list_day.json"
        case .GetNMoQTravelList:
            return "/nmoq_list_partner.json"
        case .GetNMoQSpecialEventList:
            return "/nmoq_special_event.json"
        case .GetNMoQSpecialEventDetail( _):
            return "/nmoq_special_event.json"
        case .GetNMoQTourDetail( _):
            return "/list_tour_per_day.json"
        case .NMoQEventListUserRegistration( _):
            return "/list_event_user_registration.json"
        case .NMoQEntityRegistration( _):
            return "/entity_registration.json"
        case .SetUserRegistrationComplete(let registrationId, _):
            return "/entity_registration/\(registrationId).json"
        case .SetUserUnRegistration(let registrationId, _):
            return "/entity_registration/\(registrationId).json"
        }
    }

    // MARK:- URLRequestConvertible
    public var request: URLRequest {
        let URL = NSURL(string: Config.baseURL + lang() + Config.mobileApiURL)!
        var mutableURLRequest = URLRequest(url: URL.appendingPathComponent(path)!)
        mutableURLRequest.httpMethod = method.rawValue
        if let accessToken = UserDefaults.standard.value(forKey: "accessToken")
            as? String {
            mutableURLRequest.setValue(accessToken,
                                       forHTTPHeaderField: "x-csrf-token")
        }

        switch self {
        case .ExhibitionList():
            return try! Alamofire.JSONEncoding.default.encode(mutableURLRequest)
        case .MuseumExhibitionList(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .HomeList(let apiLang):
            let apiURL = NSURL(string: Config.baseURL + apiLang + Config.mobileApiURL)!
            var apiMutableURLReq = URLRequest(url: apiURL.appendingPathComponent(path)!)
            apiMutableURLReq.httpMethod = method.rawValue
            return try! Alamofire.JSONEncoding.default.encode(apiMutableURLReq)
            //return try! Alamofire.JSONEncoding.default.encode(mutableURLRequest)
        case .HeritageList(let apiLang):
            let apiURL = NSURL(string: Config.baseURL + apiLang + Config.mobileApiURL)!
            var apiMutableURLReq = URLRequest(url: apiURL.appendingPathComponent(path)!)
            apiMutableURLReq.httpMethod = method.rawValue
            return try! Alamofire.JSONEncoding.default.encode(apiMutableURLReq)
        case .ExhibitionDetail(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .DiningList(let apiLang):
            let apiURL = NSURL(string: Config.baseURL + apiLang + Config.mobileApiURL)!
            var apiMutableURLReq = URLRequest(url: apiURL.appendingPathComponent(path)!)
            apiMutableURLReq.httpMethod = method.rawValue
            return try! Alamofire.JSONEncoding.default.encode(apiMutableURLReq)
            //return try! Alamofire.JSONEncoding.default.encode(mutableURLRequest)
        case .MuseumDiningList(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .PublicArtsList(let apiLang):
            let apiURL = NSURL(string: Config.baseURL + apiLang + Config.mobileApiURL)!
            var apiMutableURLReq = URLRequest(url: apiURL.appendingPathComponent(path)!)
            apiMutableURLReq.httpMethod = method.rawValue
            return try! Alamofire.JSONEncoding.default.encode(apiMutableURLReq)
            //return try! Alamofire.JSONEncoding.default.encode(mutableURLRequest)
        case .ParksList():
            return try! Alamofire.JSONEncoding.default.encode(mutableURLRequest)
        case .GetDiningDetail(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .HeritageDetail(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .GetPublicArtsDetail(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .LandingPageMuseums(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .CollectionList(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .CollectionDetail(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .EducationEvent(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .CollectionByTourGuide(let apiLang,let parameters):
            let apiURL = NSURL(string: Config.baseURL + apiLang + Config.mobileApiURL)!
            var apiMutableURLReq = URLRequest(url: apiURL.appendingPathComponent(path)!)
            apiMutableURLReq.httpMethod = method.rawValue
            return try! Alamofire.URLEncoding.default.encode(apiMutableURLReq, with: parameters)
        case .MuseumTourGuide(let apiLang,let parameters):
            let apiURL = NSURL(string: Config.baseURL + apiLang + Config.mobileApiURL)!
            var apiMutableURLReq = URLRequest(url: apiURL.appendingPathComponent(path)!)
            apiMutableURLReq.httpMethod = method.rawValue
            return try! Alamofire.URLEncoding.default.encode(apiMutableURLReq, with: parameters)
        case .GetToken(let parameters):
            let tokenURL = NSURL(string: Config.baseURL + lang() + Config.mobileApiURL)!
            var tokenMutableURLReq = URLRequest(url: tokenURL.appendingPathComponent(path)!)
            tokenMutableURLReq.httpMethod = method.rawValue
            tokenMutableURLReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return try! Alamofire.JSONEncoding.default.encode(tokenMutableURLReq, with: parameters)
        case .Login(let parameters):
            let loginURL = NSURL(string: Config.baseURL + lang() + Config.mobileApiURL)!
            var loginMutableURLReq = URLRequest(url: loginURL.appendingPathComponent(path)!)
            loginMutableURLReq.httpMethod = method.rawValue
            if let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String {
                loginMutableURLReq.setValue(accessToken, forHTTPHeaderField: "x-csrf-token")
            }
            loginMutableURLReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return try! Alamofire.JSONEncoding.default.encode(loginMutableURLReq, with: parameters)
        case .Logout():
            let logoutURL = NSURL(string: Config.baseURL + lang() + Config.mobileApiURL)!
            var logoutMutableURLReq = URLRequest(url: logoutURL.appendingPathComponent(path)!)
            logoutMutableURLReq.httpMethod = method.rawValue
            if let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String {
                logoutMutableURLReq.setValue(accessToken, forHTTPHeaderField: "x-csrf-token")
            }
            logoutMutableURLReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return try! Alamofire.JSONEncoding.default.encode(logoutMutableURLReq)
        case .NewPasswordRequest(let parameters):
            let newPasswordURL = NSURL(string: Config.baseURL + lang() + Config.mobileApiURL)!
            var passwordMutableURLReq = URLRequest(url: newPasswordURL.appendingPathComponent(path)!)
            passwordMutableURLReq.httpMethod = method.rawValue
            if let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String {
                passwordMutableURLReq.setValue(accessToken, forHTTPHeaderField: "x-csrf-token")
            }
            passwordMutableURLReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return try! Alamofire.JSONEncoding.default.encode(passwordMutableURLReq, with: parameters)
        case .GetUser( _):
            let newPasswordURL = NSURL(string: Config.baseURL + lang() + Config.mobileApiURL)!
            var passwordMutableURLReq = URLRequest(url: newPasswordURL.appendingPathComponent(path)!)
            passwordMutableURLReq.httpMethod = method.rawValue
            return try! Alamofire.JSONEncoding.default.encode(passwordMutableURLReq)
        case .UpdateUser(_,let parameters):
            let loginURL = NSURL(string: Config.baseURL + Config.engLang + Config.mobileApiURL)!
            var loginMutableURLReq = URLRequest(url: loginURL.appendingPathComponent(path)!)
            loginMutableURLReq.httpMethod = method.rawValue
            if let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String {
                loginMutableURLReq.setValue(accessToken, forHTTPHeaderField: "x-csrf-token")
            }
            loginMutableURLReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return try! Alamofire.JSONEncoding.default.encode(loginMutableURLReq, with: parameters)
        case .SendDeviceToken(let accessToken, let parameters):
            let deviceTokenURL = NSURL(string: Config.baseURL + lang() + Config.mobileApiURL)!
            var tokenMutableURLReq = URLRequest(url: deviceTokenURL.appendingPathComponent(path)!)
            tokenMutableURLReq.httpMethod = method.rawValue
            tokenMutableURLReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            tokenMutableURLReq.setValue(accessToken, forHTTPHeaderField: "x-csrf-token")
            return try! Alamofire.JSONEncoding.default.encode(tokenMutableURLReq, with: parameters)
        case .NumberSearchList( _):
            let searchURL = NSURL(string: Config.baseURL + lang() + Config.mobileApiURL)!
            var searchURLReq = URLRequest(url: searchURL.appendingPathComponent(path)!)
            searchURLReq.httpMethod = method.rawValue
            return try! Alamofire.JSONEncoding.default.encode(searchURLReq)
        case .GetHomeBanner():
            return try! Alamofire.JSONEncoding.default.encode(mutableURLRequest)
        case .GetNMoQAboutEvent(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .GetNMoQTourList():
            return try! Alamofire.JSONEncoding.default.encode(mutableURLRequest)
        case .GetNMoQTravelList():
            return try! Alamofire.JSONEncoding.default.encode(mutableURLRequest)
        case .GetNMoQSpecialEventList():
            return try! Alamofire.JSONEncoding.default.encode(mutableURLRequest)
        case .GetNMoQSpecialEventDetail(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .GetNMoQTourDetail(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
//            let nmqURL = NSURL(string: Config.baseURL + Config.engLang + Config.mobileApiURL)!
//            var nmqMutableURLReq = URLRequest(url: nmqURL.appendingPathComponent(path)!)
//            nmqMutableURLReq.httpMethod = method.rawValue
//           // return try! Alamofire.URLEncoding.default.encode(nmqMutableURLReq, with: parameters)
//            return try! Alamofire.JSONEncoding.default.encode(nmqMutableURLReq, with: parameters)
        case .NMoQEventListUserRegistration(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)
        case .NMoQEntityRegistration(let parameters):
            let regURL = NSURL(string: Config.baseURL + lang() + Config.mobileApiURL)!
            var regMutableURLReq = URLRequest(url: regURL.appendingPathComponent(path)!)
            regMutableURLReq.httpMethod = method.rawValue
            if let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String {
                regMutableURLReq.setValue(accessToken, forHTTPHeaderField: "x-csrf-token")
            }
            regMutableURLReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return try! Alamofire.JSONEncoding.default.encode(regMutableURLReq, with: parameters)
        case .SetUserRegistrationComplete( _,let parameters):
            let regURL = NSURL(string: Config.baseURL + Config.engLang + Config.mobileApiURL)!
            var regMutableURLReq = URLRequest(url: regURL.appendingPathComponent(path)!)
            regMutableURLReq.httpMethod = method.rawValue
            if let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String {
                regMutableURLReq.setValue(accessToken, forHTTPHeaderField: "x-csrf-token")
            }
            regMutableURLReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return try! Alamofire.JSONEncoding.default.encode(regMutableURLReq, with: parameters)
        case .SetUserUnRegistration( _,let parameters):
            let regURL = NSURL(string: Config.baseURL + Config.engLang + Config.mobileApiURL)!
            var regMutableURLReq = URLRequest(url: regURL.appendingPathComponent(path)!)
            regMutableURLReq.httpMethod = method.rawValue
            if let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String {
                regMutableURLReq.setValue(accessToken, forHTTPHeaderField: "x-csrf-token")
            }
            regMutableURLReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return try! Alamofire.JSONEncoding.default.encode(regMutableURLReq, with: parameters)
        }
        
        
    }
    
    public func asURLRequest() throws -> URLRequest {
        return request
    }
    
    public func lang() -> String {
        return LocalizationLanguage.currentAppleLanguage()
    }
    
    func stopAllRequests(){
        if #available(iOS 9.0, *) {
            Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
                tasks.forEach{ $0.cancel() }
            }
        } else {
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
                sessionDataTask.forEach { $0.cancel() }
                uploadData.forEach { $0.cancel() }
                downloadData.forEach { $0.cancel() }
            }
        }
    }
}
