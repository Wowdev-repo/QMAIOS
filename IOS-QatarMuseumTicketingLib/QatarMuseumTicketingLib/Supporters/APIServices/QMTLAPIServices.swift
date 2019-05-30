//
//  APIServices.swift
//  QMLibPreProduction
//
//  Created by Jeeva.S.K on 18/02/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import JGProgressHUD
import Toast_Swift

protocol APIServiceResponse: class {
    func responseWith(ResponseJSON json:JSON,StatusCode statusCode:Int,ServiceFor serviceFor:String)
}

protocol  APIServiceProtocolForConnectionError: class {
    func connectionError(ConnectionErrInfo errInfo:String?,StatusCode statusCode:Int)
}

class QMTLAPIServices: NSObject {
    
    var toastStyle = ToastStyle()
    
    var afManager : SessionManager!
    var view : UIView!
    let hud = JGProgressHUD(style: .extraLight)
    
    weak var delegateForAPIServiceResponse: APIServiceResponse?
    weak var delegateForConnectionError : APIServiceProtocolForConnectionError?
    
    //MARK:- API Call Initiator
    
    func doAPICall(APIPageName apiPageName : String,Parameters parameters : Parameters,PayLoadData playloadData : JSON,RequestFor requestFor: String) {
        
        showHud()
        
        setBaseURL()
        
        var apiBaseURL = ""
        
        
        switch requestFor {
        case QMTLConstants.ServiceFor.paymentGateWayURL,QMTLConstants.ServiceFor.PasswordReset,QMTLConstants.ServiceFor.TicketPurchase,QMTLConstants.ServiceFor.CPRegistration,QMTLConstants.ServiceFor.CPRenewal,QMTLConstants.ServiceFor.CPPurchaseMail:
            
            apiBaseURL = apiPageName
            break
            
        default:
            apiBaseURL = QMTLConstants.GantnerAPI.baseURLTest + apiPageName
        }
        
        let httpMethod : HTTPMethod = .post
        let baseURL = apiBaseURL.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let components = URLComponents(string: baseURL!)!
        
        var request = URLRequest(url:components.url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = httpMethod.rawValue
        
        print("doAPICall Req playloadData JSON = \((playloadData).rawString() ?? "")")
        
        let jsonObj = try? JSONSerialization.data(withJSONObject: playloadData.dictionaryObject!, options: [.prettyPrinted, .sortedKeys])
        
        let stringJson = String(data: jsonObj!, encoding: .utf8)
        print("doAPICall Req encoding JSON = \(String(describing: stringJson))")
        
        request.httpBody = jsonObj //try! playloadData.rawData()
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        afManager = Alamofire.SessionManager(configuration: configuration)
        
        print("doAPICall Service Call URL = \(String(describing: request.url))")
        
        self.afManager.request(request).responseJSON { response in
            
            if self.view != nil {
                self.hideHud()
            }
            
            print("Service Call Response.request = \(String(describing: response.request))")
            print("Service Call Response.response = \(String(describing: response.response))")
            
            
            if response.result.isSuccess {
                if let jsonObj = response.result.value {
                    let json = JSON(jsonObj)
                    self.delegateForAPIServiceResponse?.responseWith(ResponseJSON: json,StatusCode: (response.response?.statusCode)!,ServiceFor: requestFor)
                }
            }else{
                print("doAPICall Error detail = \(String(describing: response))")
                print("doAPICall Error Code = \(String(describing: response.response?.statusCode))")
                
                if response.response?.statusCode == nil && (response.result.error?.localizedDescription)! != "cancelled" {
                    
                    let errInfo = (response.result.error?.localizedDescription)!
                    
                    if errInfo == "The Internet connection appears to be offline." {
                        self.view.hideAllToasts()
                        self.showToast(message: errInfo)
                    }
                }
                
                var statusCode = 0
                
                if response.response?.statusCode == nil{
                    statusCode = 0
                }else{
                    statusCode = (response.response?.statusCode)!
                }
                self.delegateForConnectionError?.connectionError(ConnectionErrInfo: (response.result.error?.localizedDescription),StatusCode: statusCode)
            }
            
            }.session.finishTasksAndInvalidate()
        
    }
    
    func showHud(){
        toastStyle.messageColor = .white
        toastStyle.backgroundColor = .darkGray
        
        let window: UIWindow? = UIApplication.shared.windows[0]
        hud.show(in: window!)
        var hudRect = hud.hudView.frame
        hudRect.origin.y = (window!.frame.size.height/2) - 25
        hud.hudView.frame = hudRect
    }
    
    func hideHud(){
        self.hud.dismiss(afterDelay: 0)
    }
    
    func showToast(message : String){
        self.view.makeToast(getLocalizedStr(str: message) , duration: 2.0, position: .center, style: toastStyle)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.view.hideAllToasts()
        })
    }
    
    func setBaseURL() {
    }
    
    //MARK:- API Callers
    
    func getContextForAPI() -> [String : Any]{
        
        let langType = QMTLConstants.commonRequestKeys.languageType
        let shopID = QMTLConstants.AuthCreds.shopID
        let shopPWD = QMTLConstants.AuthCreds.shopPWD
        
        return [QMTLConstants.commonRequestKeys.language:langType,QMTLConstants.commonRequestKeys.shopId:shopID,QMTLConstants.commonRequestKeys.password:shopPWD] as [String : Any]
    }
    
    func getDivisionList(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.searchCriteria:searchCriteria,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.ListDivisions
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
    }
    
    func getExpositionList(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.searchCriteria:searchCriteria,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.findExposition
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)

    }
    
    func getArticleList(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        
        let paging:JSON = [
            QMTLConstants.FindSubscriptionsKeys.PageIndex:0,
            QMTLConstants.FindSubscriptionsKeys.PageSize:1000
        ]
        
        let searchCriteriaJSON:JSON = [
            QMTLConstants.FindSubscriptionsKeys.Paging:paging,
        ]
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.searchCriteria:searchCriteriaJSON,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.FindArticles
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func getExpositionPeriods(searchCriteria : [String:String],serviceFor : String, view : UIView){
        
        self.view = view
                
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.searchCriteria:searchCriteria,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.findExpositionPeriod
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func findSubscriptions(searchCriteria : [String:Any],serviceFor : String, view : UIView){
        
        self.view = view
        
        let includes:JSON = [
            QMTLConstants.FindSubscriptionsKeys.Inactive:true,
            QMTLConstants.FindSubscriptionsKeys.Invalid:true,
            QMTLConstants.FindSubscriptionsKeys.Logs:false,
            QMTLConstants.FindSubscriptionsKeys.PersonCards:false,
            QMTLConstants.FindSubscriptionsKeys.Image:false,
            QMTLConstants.FindSubscriptionsKeys.OnlyCurrentPersonCard:false,
            QMTLConstants.FindSubscriptionsKeys.InvalidityReasons:false,
            QMTLConstants.FindSubscriptionsKeys.LessonGroups:false,
            QMTLConstants.FindSubscriptionsKeys.PriceGroup:false
        ]
        
        let paging:JSON = [
            QMTLConstants.FindSubscriptionsKeys.PageIndex:0,
            QMTLConstants.FindSubscriptionsKeys.PageSize:100
            ]
        
        let searchCriteriaJSON:JSON = [
            QMTLConstants.FindSubscriptionsKeys.personId:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.FindSubscriptionsKeys.includes:includes,
            QMTLConstants.FindSubscriptionsKeys.Paging:paging,
            QMTLConstants.FindSubscriptionsKeys.ListForProlongation:false,
            QMTLConstants.FindSubscriptionsKeys.ListForReader:false,
            QMTLConstants.FindSubscriptionsKeys.IgnoreExclusionCalendar:false,
            QMTLConstants.FindSubscriptionsKeys.personId:QMTLSingleton.sharedInstance.userInfo.id
            ]
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.criteria:searchCriteriaJSON,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.findSubscriptions
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
    }
    
    func findSubscriptionArticles(searchCriteria : [String:Any],serviceFor : String, view : UIView){
        
        self.view = view
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.criteria:searchCriteria,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.findSubscriptionArticles
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func findArticleSalesOrders(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.searchCriteria:searchCriteria,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.findArticleSalesOrders
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func findOrganisedVisits(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        
        let includes:JSON = [
            QMTLConstants.FindOrganisedVisitsKeys.Cancelled:false,
            QMTLConstants.FindOrganisedVisitsKeys.PersonDetails:false,
            QMTLConstants.FindOrganisedVisitsKeys.periodReservations:true,
            QMTLConstants.FindOrganisedVisitsKeys.Articles:true,
            QMTLConstants.FindOrganisedVisitsKeys.ContactDetails:false
        ]
        
        let paging:JSON = [
            QMTLConstants.FindOrganisedVisitsKeys.PageIndex:0,
            QMTLConstants.FindOrganisedVisitsKeys.PageSize:100
        ]
        
        let searchCriteriaJSON:JSON = [
            QMTLConstants.FindOrganisedVisitsKeys.PersonId:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.FindOrganisedVisitsKeys.Includes:includes,
            QMTLConstants.FindOrganisedVisitsKeys.Paging:paging
        ]
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.searchCriteria:searchCriteriaJSON,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.FindOrganisedVisits
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func authenticateUser(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.credentials:searchCriteria,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.AuthenticateUser
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func findPerson(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.criteria:searchCriteria,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.FindPerson
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func getCountriesList(searchCriteria : [String:String],serviceFor : String, view : UIView){
        
        self.view = view
        
        let paging:JSON = [
            QMTLConstants.commonRequestKeys.PageIndex:0,
            QMTLConstants.commonRequestKeys.PageSize:400
        ]
        
        let searchCriteriaJSON:JSON = [
            QMTLConstants.commonRequestKeys.Paging:paging
        ]
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.searchCriteria:searchCriteriaJSON,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.ListCountries
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
    }
    func getListPersonTitles(searchCriteria : [String:String],serviceFor : String, view : UIView){
        
        self.view = view
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.criteria:searchCriteria,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.ListPersonTitles
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
    }
    
    func savePerson(searchCriteria : [String:Any],serviceFor : String, view : UIView, isToEditUser : Bool){
        
        self.view = view
        
        let address:JSON = [
            QMTLConstants.PersonKeys.country:(searchCriteria[QMTLConstants.PersonKeys.country] as! String)
        ]
        
        let name:JSON = [
            QMTLConstants.PersonKeys.first:(searchCriteria[QMTLConstants.PersonKeys.first] as! String),
            QMTLConstants.PersonKeys.last:(searchCriteria[QMTLConstants.PersonKeys.last] as! String)
        ]
        let settings:JSON = [
            QMTLConstants.PersonKeys.subscribeMailingList:(searchCriteria[QMTLConstants.PersonKeys.subscribeMailingList] as! Bool)
        ]
        
        let titleObj = searchCriteria[QMTLConstants.PersonKeys.Title] as! ListPersonTitles
        
        let title:JSON = [
            QMTLConstants.PersonKeys.id : titleObj.id,
            QMTLConstants.PersonKeys.shortName : titleObj.shortName,
            QMTLConstants.PersonKeys.Description : titleObj.desc
        ]
        
        var person:JSON = []
        var options:JSON = []
        
        if isToEditUser{
            let credentials:JSON = [
                QMTLConstants.PersonKeys.username:(searchCriteria[QMTLConstants.PersonKeys.username] as! String),
                QMTLConstants.PersonKeys.password:QMTLSingleton.sharedInstance.userInfo.password
            ]
            person = [
            QMTLConstants.PersonKeys.address:address,
            QMTLConstants.PersonKeys.credential:credentials,
            QMTLConstants.PersonKeys.name:name,
            QMTLConstants.PersonKeys.settings:settings,
            QMTLConstants.PersonKeys.email:(searchCriteria[QMTLConstants.PersonKeys.email] as! String),
            QMTLConstants.PersonKeys.Code:(searchCriteria[QMTLConstants.PersonKeys.Code] as! String),
            QMTLConstants.PersonKeys.phone:(searchCriteria[QMTLConstants.PersonKeys.phone] as! String),
            QMTLConstants.PersonKeys.language:"EN",
            QMTLConstants.PersonKeys.id:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.PersonKeys.Title:title,
            QMTLConstants.PersonKeys.Info1:(searchCriteria[QMTLConstants.PersonKeys.Info1] as! String),
            QMTLConstants.PersonKeys.Info2:(searchCriteria[QMTLConstants.PersonKeys.Info2] as! String),
            QMTLConstants.PersonKeys.Info3:(searchCriteria[QMTLConstants.PersonKeys.Info3] as! String),
            QMTLConstants.PersonKeys.Info4:(searchCriteria[QMTLConstants.PersonKeys.Info4] as! String)
            ]
            options = [
            QMTLConstants.PersonKeys.createZipcodes:false,
            QMTLConstants.PersonKeys.ignoreDuplicates:true,
            QMTLConstants.PersonKeys.ignoreCredentials:true,
            QMTLConstants.PersonKeys.skipAgeValidation:true
            ]
        }else{
            let credentials:JSON = [
                QMTLConstants.PersonKeys.username:(searchCriteria[QMTLConstants.PersonKeys.username] as! String),
                QMTLConstants.PersonKeys.password:(searchCriteria[QMTLConstants.PersonKeys.password] as! String)
            ]
            person = [
                QMTLConstants.PersonKeys.address:address,
                QMTLConstants.PersonKeys.credential:credentials,
                QMTLConstants.PersonKeys.name:name,
                QMTLConstants.PersonKeys.settings:settings,
                QMTLConstants.PersonKeys.email:(searchCriteria[QMTLConstants.PersonKeys.email] as! String),
                QMTLConstants.PersonKeys.Code:(searchCriteria[QMTLConstants.PersonKeys.Code] as! String),
                QMTLConstants.PersonKeys.phone:(searchCriteria[QMTLConstants.PersonKeys.phone] as! String),
                QMTLConstants.PersonKeys.language:"EN",
                QMTLConstants.PersonKeys.Title:title,
                QMTLConstants.PersonKeys.Info1:(searchCriteria[QMTLConstants.PersonKeys.Info1] as! String),
                QMTLConstants.PersonKeys.Info2:(searchCriteria[QMTLConstants.PersonKeys.Info2] as! String),
                QMTLConstants.PersonKeys.Info3:(searchCriteria[QMTLConstants.PersonKeys.Info3] as! String),
                QMTLConstants.PersonKeys.Info4:(searchCriteria[QMTLConstants.PersonKeys.Info4] as! String)
            ]
            options = [
            QMTLConstants.PersonKeys.createZipcodes:false,
            QMTLConstants.PersonKeys.ignoreDuplicates:true,
            QMTLConstants.PersonKeys.ignoreCredentials:false,
            QMTLConstants.PersonKeys.skipAgeValidation:false
            ]
        }
        
        let payLoadDict: JSON = [QMTLConstants.PersonKeys.person:person,QMTLConstants.PersonKeys.options:options,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.savePerson
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func getPaymentGateWayLink(serviceFor : String,isFromMemberShipRenewal : Bool, view : UIView) {
        
        self.view = view
        var modeStr = ""
        var idStr = ""
        var totalTicketAmount = 0
        var prices = [PriceItem]()
        if isFromMemberShipRenewal {
            modeStr = "CP"
            idStr = QMTLSingleton.sharedInstance.memberShipInfo.division.id
            prices = QMTLSingleton.sharedInstance.memberShipInfo.prices
        }else{
            modeStr = "T"
            idStr = QMTLSingleton.sharedInstance.ticketInfo.division.id
            prices = QMTLSingleton.sharedInstance.ticketInfo.prices
        }
        
        if prices.count > 0 {
            for price in prices {
                totalTicketAmount = totalTicketAmount + price.totalAmount
            }
        }
        
        let apiPageName = "\(QMTLConstants.QMAPI.paymentGatewayURL)?\(QMTLConstants.paymentGatewayKeys.pay)=\(totalTicketAmount)&\("mode")=\(modeStr)&\("mid")=\(idStr)"
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: [:], RequestFor: serviceFor)
    }
    
    
    //MARK: BaketItem Calls To buy tickets
    
    func lockBasketItems(searchCriteria : [String:String],serviceFor : String, view : UIView){
        
        self.view = view
        var entriesJsonArr = [JSON]()
        var basketItemJSONArr = [JSON]()
        let prices = QMTLSingleton.sharedInstance.ticketInfo.prices
        if prices.count > 0 {
            for price in prices {
                
                if price.ticketPicked == 0 {
                    continue
                }
                 
                let entryObj:JSON = [
                    QMTLConstants.BasketKey.type: "ReCreateX.WebShop.WebServices.Contracts.ExpositionPeriodReservationEntry,ReCreateX.WebShop.WebServices.Contracts",
                    QMTLConstants.BasketKey.participantCount: price.ticketPicked,
                    QMTLConstants.BasketKey.priceGroupId: price.id ]
                entriesJsonArr.append(entryObj)
            }
        }
        
        var basketItemJSON = JSON()
        
        if QMTLSingleton.sharedInstance.userInfo.isLoggedIn == false {
            
            basketItemJSON = [
            QMTLConstants.BasketKey.type:"ReCreateX.WebShop.WebServices.Contracts.ExpositionPeriodReservation,ReCreateX.WebShop.WebServices.Contracts ",
            QMTLConstants.BasketKey.entries:entriesJsonArr,
            QMTLConstants.BasketKey.expositionPeriodId:QMTLSingleton.sharedInstance.ticketInfo.expositionPeriod.id,
            QMTLConstants.BasketKey.expositionId:QMTLSingleton.sharedInstance.ticketInfo.expositions.id
            ]
            
        }else{
            
            basketItemJSON = [
                QMTLConstants.BasketKey.type:"ReCreateX.WebShop.WebServices.Contracts.ExpositionPeriodReservation,ReCreateX.WebShop.WebServices.Contracts ",
                QMTLConstants.BasketKey.entries:entriesJsonArr,
                QMTLConstants.BasketKey.expositionPeriodId:QMTLSingleton.sharedInstance.ticketInfo.expositionPeriod.id,
                QMTLConstants.BasketKey.expositionId:QMTLSingleton.sharedInstance.ticketInfo.expositions.id,
                QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id
            ]
        }
        
        
        basketItemJSONArr.append(basketItemJSON)
        
        let payLoadDict: JSON = [QMTLConstants.BasketKey.basketItems:basketItemJSONArr,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.lockBasketItems
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
    }
    
    func recalculateBasket(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        var customerId = QMTLConstants.PersonKeys.dummyIdForAnonymousUser
        if QMTLSingleton.sharedInstance.userInfo.isLoggedIn {
            customerId = QMTLSingleton.sharedInstance.userInfo.id
        }
        
        var itemsJsonArr = [JSON]()
        var entriesJsonArr = [JSON]()
        var paymentsJsonArr = [JSON]()
        
        let prices = QMTLSingleton.sharedInstance.ticketInfo.prices
        let lockBasket = QMTLSingleton.sharedInstance.ticketInfo.lockBasket
        
        var totalTicketsPicked = 0
        var totalTicketAmount = 0
        
        if prices.count > 0 {
            for price in prices {
                
                if price.ticketPicked == 0 {
                    continue
                }
                
                totalTicketsPicked = totalTicketsPicked + price.ticketPicked
                totalTicketAmount = totalTicketAmount + price.totalAmount
                
                let entryObj:JSON = [
                    QMTLConstants.BasketKey.type: "ReCreateX.WebShop.WebServices.Contracts.ExpositionPeriodReservationEntry,ReCreateX.WebShop.WebServices.Contracts",
                    QMTLConstants.BasketKey.participantCount: price.ticketPicked,
                    QMTLConstants.BasketKey.priceGroupId: price.id,
                    QMTLConstants.BasketKey.amount: price.amount]
                entriesJsonArr.append(entryObj)
            }
        }
        
        let lockTicket: JSON = [
            QMTLConstants.BasketKey.type: "ReCreateX.WebShop.WebServices.Contracts.ExpositionReservationLockTicket, ReCreateX.WebShop.WebServices.Contracts",
            QMTLConstants.BasketKey.expirationTime: lockBasket.expirationTime,
            QMTLConstants.BasketKey.id: lockBasket.id
        ]
        
        let itemObj: JSON = [
            QMTLConstants.BasketKey.type:"ReCreateX.WebShop.WebServices.Contracts.ExpositionPeriodReservation, ReCreateX.WebShop.WebServices.Contracts",
            QMTLConstants.BasketKey.entries:entriesJsonArr,
            QMTLConstants.BasketKey.lockTicket:lockTicket,
            QMTLConstants.BasketKey.divisionId:QMTLSingleton.sharedInstance.ticketInfo.division.id,
            QMTLConstants.BasketKey.expositionPeriodId:QMTLSingleton.sharedInstance.ticketInfo.expositionPeriod.id,
            QMTLConstants.BasketKey.expositionId:QMTLSingleton.sharedInstance.ticketInfo.expositions.id,
            QMTLConstants.BasketKey.customerID:customerId,
            QMTLConstants.BasketKey.quantity:1,
            QMTLConstants.BasketKey.unitPrice:totalTicketAmount,
            QMTLConstants.BasketKey.salesOrderNumber:false
        ]
        itemsJsonArr.append(itemObj)
        
        let paymentsObj:JSON = [
            QMTLConstants.BasketKey.Amount : totalTicketAmount,
            QMTLConstants.BasketKey.Currency: "QR",
            QMTLConstants.BasketKey.PaymentMethodId : QMTLConstants.BasketKey.PaymentMethodIdVal
        ]
        paymentsJsonArr.append(paymentsObj)
        
        let basketJSON: JSON = [
            QMTLConstants.BasketKey.customerID:customerId,
            QMTLConstants.BasketKey.items:itemsJsonArr,
            QMTLConstants.BasketKey.payments:paymentsJsonArr,
            QMTLConstants.BasketKey.price:totalTicketAmount
        ]
        
        
        let payLoadDict: JSON = [QMTLConstants.BasketKey.basket:basketJSON,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.ReCalculateBasket
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func validateBasket(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        
        var itemsJsonArr = [JSON]()
        var entriesJsonArr = [JSON]()
        var paymentsJsonArr = [JSON]()
        
        let prices = QMTLSingleton.sharedInstance.ticketInfo.prices
        let lockBasket = QMTLSingleton.sharedInstance.ticketInfo.lockBasket
        
        var totalTicketsPicked = 0
        var totalTicketAmount = 0
        
        if prices.count > 0 {
            for price in prices {
                
                if price.ticketPicked == 0 {
                    continue
                }
                
                totalTicketsPicked = totalTicketsPicked + price.ticketPicked
                totalTicketAmount = totalTicketAmount + price.totalAmount
                
                let entryObj:JSON = [
                    QMTLConstants.BasketKey.type: "ReCreateX.WebShop.WebServices.Contracts.ExpositionPeriodReservationEntry,ReCreateX.WebShop.WebServices.Contracts",
                    QMTLConstants.BasketKey.participantCount: price.ticketPicked,
                    QMTLConstants.BasketKey.priceGroupId: price.id,
                    QMTLConstants.BasketKey.amount: price.amount]
                entriesJsonArr.append(entryObj)
            }
        }
        
        let lockTicket: JSON = [
            QMTLConstants.BasketKey.type: "ReCreateX.WebShop.WebServices.Contracts.ExpositionReservationLockTicket, ReCreateX.WebShop.WebServices.Contracts",
            QMTLConstants.BasketKey.expirationTime: lockBasket.expirationTime,
            QMTLConstants.BasketKey.id: lockBasket.id
        ]
        
        let itemObj: JSON = [
            QMTLConstants.BasketKey.type:"ReCreateX.WebShop.WebServices.Contracts.ExpositionPeriodReservation, ReCreateX.WebShop.WebServices.Contracts",
            QMTLConstants.BasketKey.entries:entriesJsonArr,
            QMTLConstants.BasketKey.lockTicket:lockTicket,
            QMTLConstants.BasketKey.divisionId:QMTLSingleton.sharedInstance.ticketInfo.division.id,
            QMTLConstants.BasketKey.expositionPeriodId:QMTLSingleton.sharedInstance.ticketInfo.expositionPeriod.id,
            QMTLConstants.BasketKey.expositionId:QMTLSingleton.sharedInstance.ticketInfo.expositions.id,
            QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.BasketKey.quantity:1,
            QMTLConstants.BasketKey.unitPrice:totalTicketAmount,
            QMTLConstants.BasketKey.salesOrderNumber:false
        ]
        itemsJsonArr.append(itemObj)
        
        let paymentsObj:JSON = [
            QMTLConstants.BasketKey.Amount : totalTicketAmount,
            QMTLConstants.BasketKey.Currency: "QR",
            QMTLConstants.BasketKey.PaymentMethodId : QMTLConstants.BasketKey.PaymentMethodIdVal
        ]
        paymentsJsonArr.append(paymentsObj)
        
        let basketJSON: JSON = [
            QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.BasketKey.items:itemsJsonArr,
            QMTLConstants.BasketKey.payments:paymentsJsonArr,
            QMTLConstants.BasketKey.price:totalTicketAmount
        ]
        
        let payLoadDict: JSON = [QMTLConstants.BasketKey.basket:basketJSON,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.ValidateBasket
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func checkoutBasket(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        
        if !QMTLSingleton.sharedInstance.userInfo.isLoggedIn {
            QMTLSingleton.sharedInstance.userInfo.id = QMTLSingleton.sharedInstance.userInfo.anonymousUserId
        }
        
        var itemsJsonArr = [JSON]()
        var entriesJsonArr = [JSON]()
        var paymentsJsonArr = [JSON]()
        
        let prices = QMTLSingleton.sharedInstance.ticketInfo.prices
        let lockBasket = QMTLSingleton.sharedInstance.ticketInfo.lockBasket
        
        var totalTicketsPicked = 0
        var totalTicketAmount = 0
        
        
        if prices.count > 0 {
            for price in prices {
                
                if price.ticketPicked == 0 {
                    continue
                }
                
                totalTicketsPicked = totalTicketsPicked + price.ticketPicked
                totalTicketAmount = totalTicketAmount + price.totalAmount
                
                let entryObj:JSON = [
                    QMTLConstants.BasketKey.type: "ReCreateX.WebShop.WebServices.Contracts.ExpositionPeriodReservationEntry,ReCreateX.WebShop.WebServices.Contracts",
                    QMTLConstants.BasketKey.participantCount: price.ticketPicked,
                    QMTLConstants.BasketKey.priceGroupId: price.id,
                    QMTLConstants.BasketKey.amount: price.amount]
                entriesJsonArr.append(entryObj)
            }
        }
        
        let lockTicket: JSON = [
            QMTLConstants.BasketKey.type: "ReCreateX.WebShop.WebServices.Contracts.ExpositionReservationLockTicket, ReCreateX.WebShop.WebServices.Contracts",
            QMTLConstants.BasketKey.expirationTime: lockBasket.expirationTime,
            QMTLConstants.BasketKey.id: lockBasket.id
        ]
        
        let itemObj: JSON = [
            QMTLConstants.BasketKey.type:"ReCreateX.WebShop.WebServices.Contracts.ExpositionPeriodReservation, ReCreateX.WebShop.WebServices.Contracts",
            QMTLConstants.BasketKey.entries:entriesJsonArr,
            QMTLConstants.BasketKey.lockTicket:lockTicket,
            QMTLConstants.BasketKey.divisionId:QMTLSingleton.sharedInstance.ticketInfo.division.id,
            QMTLConstants.BasketKey.expositionPeriodId:QMTLSingleton.sharedInstance.ticketInfo.expositionPeriod.id,
            QMTLConstants.BasketKey.expositionId:QMTLSingleton.sharedInstance.ticketInfo.expositions.id,
            QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.BasketKey.quantity:1,
            QMTLConstants.BasketKey.unitPrice:totalTicketAmount,
            QMTLConstants.BasketKey.salesOrderNumber:false
        ]
        itemsJsonArr.append(itemObj)
        
        let paymentsObj:JSON = [
            QMTLConstants.BasketKey.Amount : totalTicketAmount,
            QMTLConstants.BasketKey.Currency: "QR",
            QMTLConstants.BasketKey.PaymentMethodId : QMTLConstants.BasketKey.PaymentMethodIdVal
        ]
        paymentsJsonArr.append(paymentsObj)
        
        var basketJSON = JSON()
        
        if !QMTLSingleton.sharedInstance.userInfo.isLoggedIn {
            let anonymousPerson: JSON = [
                QMTLConstants.AnonymousPersonKeys.Name: QMTLSingleton.sharedInstance.userInfo.name,
                QMTLConstants.AnonymousPersonKeys.Email: QMTLSingleton.sharedInstance.userInfo.email,
                QMTLConstants.AnonymousPersonKeys.Number: QMTLSingleton.sharedInstance.userInfo.phone,
                QMTLConstants.AnonymousPersonKeys.Country: QMTLSingleton.sharedInstance.userInfo.nationality
            ]
            
            basketJSON = [
                QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id,
                QMTLConstants.BasketKey.items:itemsJsonArr,
                QMTLConstants.BasketKey.payments:paymentsJsonArr,
                QMTLConstants.BasketKey.price:totalTicketAmount,
                QMTLConstants.AnonymousPersonKeys.AnonymousPerson:anonymousPerson
            ]
        }else{
            basketJSON = [
            QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.BasketKey.items:itemsJsonArr,
            QMTLConstants.BasketKey.payments:paymentsJsonArr,
            QMTLConstants.BasketKey.price:totalTicketAmount
            ]
        }
        
        
        let payLoadDict: JSON = [QMTLConstants.BasketKey.basket:basketJSON,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.CheckoutBasket
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func findPersonCards(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.criteria:searchCriteria,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.findPersonCards
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    //MARK: BaketItem Calls To buy membership
    
    func cancelMembershipSubscription(subscriptionIdStr : String,serviceFor : String, view : UIView){
        
        self.view = view
        
        let search = [QMTLConstants.FindSubscriptionsKeys.subscriptionId:subscriptionIdStr]
        
        let payLoadDict: JSON = [QMTLConstants.commonRequestKeys.criteria:search,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.cancelSubscription
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func recalculateBasketForMembership(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        var itemsJsonArr = [JSON]()

        let price = QMTLSingleton.sharedInstance.memberShipInfo.prices[0]
        let articleObj:JSON = [
            QMTLConstants.BasketKey.id: price.id]
        
        let itemObj: JSON = [
            QMTLConstants.BasketKey.type:"ReCreateX.WebShop.WebServices.Contracts.ArticleSale, ReCreateX.WebShop.WebServices.Contracts",
            QMTLConstants.BasketKey.article:articleObj,
            QMTLConstants.BasketKey.quantity:1,
            QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id
        ]
        
        itemsJsonArr.append(itemObj)
        let basketJSON: JSON = [
            QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.BasketKey.items:itemsJsonArr,
            QMTLConstants.BasketKey.price:price.totalAmount
        ]
        
        let payLoadDict: JSON = [QMTLConstants.BasketKey.basket:basketJSON,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.ReCalculateBasket
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func validateBasketForMembership(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        var itemsJsonArr = [JSON]()
        var paymentsJsonArr = [JSON]()
        
        let price = QMTLSingleton.sharedInstance.memberShipInfo.prices[0]
        let articleObj:JSON = [
            QMTLConstants.BasketKey.id: price.id]
        
        let itemObj: JSON = [
            QMTLConstants.BasketKey.type:"ReCreateX.WebShop.WebServices.Contracts.ArticleSale, ReCreateX.WebShop.WebServices.Contracts",
            QMTLConstants.BasketKey.article:articleObj,
            QMTLConstants.BasketKey.quantity:1,
            QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.BasketKey.unitPrice:price.totalAmount
        ]
        itemsJsonArr.append(itemObj)
        
        let paymentsObj:JSON = [
            QMTLConstants.BasketKey.Amount : price.totalAmount,
            QMTLConstants.BasketKey.Currency: "QR",
            QMTLConstants.BasketKey.PaymentMethodId : QMTLConstants.BasketKey.PaymentMethodIdVal
        ]
        paymentsJsonArr.append(paymentsObj)
        
        let basketJSON: JSON = [
            QMTLConstants.BasketKey.type:"ReCreateX.WebShop.WebServices.Contracts.Basket, ReCreateX.WebShop.WebServices.Contracts",
            QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.BasketKey.items:itemsJsonArr,
            QMTLConstants.BasketKey.payments:paymentsJsonArr,
            QMTLConstants.BasketKey.price:price.totalAmount
        ]
        
        let payLoadDict: JSON = [QMTLConstants.BasketKey.basket:basketJSON,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.ValidateBasket
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    func checkoutBasketForMembership(searchCriteria : [String:String],serviceFor : String, view : UIView) {
        
        self.view = view
        var itemsJsonArr = [JSON]()
        var paymentsJsonArr = [JSON]()
        
        let price = QMTLSingleton.sharedInstance.memberShipInfo.prices[0]
        let articleObj:JSON = [
            QMTLConstants.BasketKey.id: price.id]
        
        let itemObj: JSON = [
            QMTLConstants.BasketKey.type:"ReCreateX.WebShop.WebServices.Contracts.ArticleSale, ReCreateX.WebShop.WebServices.Contracts",
            QMTLConstants.BasketKey.article:articleObj,
            QMTLConstants.BasketKey.quantity:1,
            QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.BasketKey.unitPrice:price.totalAmount
        ]
        itemsJsonArr.append(itemObj)
        
        let paymentsObj:JSON = [
            QMTLConstants.BasketKey.Amount : price.totalAmount,
            QMTLConstants.BasketKey.Currency: "QR",
            QMTLConstants.BasketKey.PaymentMethodId : QMTLConstants.BasketKey.PaymentMethodIdVal
        ]
        paymentsJsonArr.append(paymentsObj)
        
        let basketJSON: JSON = [
            QMTLConstants.BasketKey.type:"ReCreateX.WebShop.WebServices.Contracts.Basket, ReCreateX.WebShop.WebServices.Contracts",
            QMTLConstants.BasketKey.customerID:QMTLSingleton.sharedInstance.userInfo.id,
            QMTLConstants.BasketKey.items:itemsJsonArr,
            QMTLConstants.BasketKey.payments:paymentsJsonArr,
            QMTLConstants.BasketKey.price:price.totalAmount
        ]
        
        let payLoadDict: JSON = [QMTLConstants.BasketKey.basket:basketJSON,QMTLConstants.commonRequestKeys.context:getContextForAPI()]
        
        let apiPageName = QMTLConstants.GantnerAPI.CheckoutBasket
        let parameters: Parameters  = [:]
        
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
        
    }
    
    // MARK:- Email Generator Mechanism
    
    // Forgot Password Email Link
    
    func forgotPasswordLink(emailStr : String, username : String, password : String, personID : String, serviceFor : String, view : UIView){
        
        let language = QMTLLocalizationLanguage.currentAppleLanguage()
        
        self.view = view
        let apiPageName = QMTLConstants.QMAPI.passwordResetURL
        let payLoadDict: JSON = ["ToEmail":emailStr,"Username":username,"Password":password,"Key":personID,"Language":language]
        let parameters: Parameters  = [:]
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
    }

    // Ticket Purchased Email
    
    func ticketPurchasedEmail(toEmail : String, shopid : String, username : String,  password : String, serviceFor : String, view : UIView){
        
        let language = QMTLLocalizationLanguage.currentAppleLanguage()

        self.view = view
        let apiPageName = QMTLConstants.QMAPI.ticketPurchaseURL
        let payLoadDict: JSON = ["ToEmail":toEmail,"shopid":shopid,"Museum":QMTLSingleton.sharedInstance.ticketInfo.division.name,"Username":username,"Password":password,"Language":language]
        let parameters: Parameters  = [:]
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
    }
    
    
    // CP Registration Email
    
    func cpRegistrationEmail(toEmail : String, username : String,  password : String, serviceFor : String, view : UIView){
        
        let language = QMTLLocalizationLanguage.currentAppleLanguage()
        
        self.view = view
        let apiPageName = QMTLConstants.QMAPI.cpRegistrationURL
        let payLoadDict: JSON = ["ToEmail":toEmail,"Username":username,"Password":password,"Language":language]
        let parameters: Parameters  = [:]
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
    }
    
    // CP Renewal Email
    
    func cpRenewalEmail(toEmail : String, username : String,  password : String, serviceFor : String, view : UIView){
        
        let language = QMTLLocalizationLanguage.currentAppleLanguage()

        
        self.view = view
        let apiPageName = QMTLConstants.QMAPI.cpRenewalURL
        let payLoadDict: JSON = ["ToEmail":toEmail,"Username":username,"Password":password,"Language":language]
        let parameters: Parameters  = [:]
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
    }
    
    // CP Purchase MailURL Email
    
    func cpPurchaseMail(toEmail : String, type : String, username : String,  password : String, serviceFor : String, view : UIView){
        
        let language = QMTLLocalizationLanguage.currentAppleLanguage()
        
        self.view = view
        let apiPageName = QMTLConstants.QMAPI.cpPurchaseMailURL
        let payLoadDict: JSON = ["ToEmail":toEmail,"Type":type,"Username":username,"Password":password,"Language":language]
        let parameters: Parameters  = [:]
        doAPICall(APIPageName: apiPageName, Parameters: parameters, PayLoadData: payLoadDict, RequestFor: serviceFor)
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    
    //MARK:- Get Random Screen
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
}
