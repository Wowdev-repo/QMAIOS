//
//  QMTLConstants.swift
//  QMLibPreProduction
//
//  Created by Jeeva.S.K on 19/02/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import Foundation

struct QMTLConstants {
    
    //MARK:-
    struct lib {
        static let bundleId = "com.iprotecs.QatarMuseumTicketingLib"
    }
    
    //MARK:-
    struct AuthCreds {
        
        
        // Production
        //----- Mobile -----
        static let shopID = "3F6A737B-552C-4B4D-9971-ABB69F45DAFA"
        static let shopPWD = "rqhaCmQGYHB3Th7M"
        
        // Staging
        //----- Mobile -----
        //static let shopID = "60bbd4af-c2f9-4cf1-ae73-3e3a0739f28c"
        //static let shopPWD = "wHF43QkCLaKebPUG"
    }
    
    //MARK:-
    struct Language {
        static let ENG_LANGUAGE = "en"
        static let AR_LANGUAGE = "ar"
    }
    
    //MARK:-
    struct viewController {
        static let QMTLTicketCounterContainerViewController = "QMTLTicketCounterContainerViewController"
        static let UserProfileTableViewController = "UserProfileTableViewController"
        static let initialViewControllerKey = "initialViewControllerKey"
    }
    
    //MARK:-
    struct GantnerAPI {
        //Production
        //static let baseURL = "https://tickets.qm.org.qa"
        //staging
        static let baseURL = "https://testtickets.qm.org.qa"
        static let baseURLTest = "\(GantnerAPI.baseURL)/Json/"
        static let baseImgURLTest = "\(GantnerAPI.baseURL)/WebShopImageService.svc/"
        
        static let PDFGenETicketByOrganisedVisit = "\(GantnerAPI.baseURL)/WebShopDocumentService.svc/ETicketByOrganisedVisit/"
        static let PDFGenETickets = "\(GantnerAPI.baseURL)/WebShopDocumentService.svc/ETickets/"
        
        static let ListDivisions = "General/ListDivisions"
        static let AuthenticateUser = "General/AuthenticateUser"
        static let FindArticles = "Articles/FindArticles/"
        
        static let ReCalculateBasket = "General/ReCalculateBasket"
        static let ValidateBasket = "General/ValidateBasket"
        static let CheckoutBasket = "General/CheckoutBasket"
        static let FindPerson = "General/FindPerson"
        static let findExposition = "Expositions/FindExpositions"
        static let findExpositionPeriod = "Expositions/ListExpositionPeriods"
        static let findArticleSalesOrders = "Articles/FindArticleSalesOrders"
        static let findSubscriptionArticles = "Subscriptions/FindSubscriptionArticles"
        static let findSubscriptions = "Subscriptions/FindSubscriptions"
        static let cancelSubscription = "Subscriptions/CancelSubscription"
        static let lockBasketItems = "General/LockBasketItems"
        static let savePerson = "General/SavePerson"
        static let findPersonCards = "General/FindPersonCards"
        static let FindOrganisedVisits = "Expositions/FindOrganisedVisits"
        static let ListCountries = "General/ListCountries"
        static let ListPersonTitles = "General/ListPersonTitles"
    }
    
    //MARK:-
    struct QMAPI {
        
        // Payment Staging URL
        static let paymentGatewayURL = "http://qatarmuseumslchjkord6f.devcloud.acquia-sites.com/apipayment"
        
        // Payment Prod URL
        //static let paymentGatewayURL = "https://visit.qm.org.qa/apipayment"
        
        
        
        // Email Staging
        static let emailBaseUrl = "https://testmailtickets.qm.org.qa/api"
        static let userName = "admin"
        static let password = "admin"
        
        // Email Production
//        static let emailBaseUrl = "https://mailtickets.qm.org.qa/api"
//        static let userName = "admin"
//        static let password = "EPQMA!_2019"
        
        static let passwordResetURL = "\(QMAPI.emailBaseUrl)/PasswordReset"
        static let ticketPurchaseURL = "\(QMAPI.emailBaseUrl)/TicketPurchase"
        static let cpRegistrationURL = "\(QMAPI.emailBaseUrl)/CPRegistration"
        static let cpRenewalURL = "\(QMAPI.emailBaseUrl)/CPRenewal"
        static let cpPurchaseMailURL = "\(QMAPI.emailBaseUrl)/CPPurchaseMail"
        
    }
    
    //MARK:-
    struct ServiceFor {
        static let listDivisions = "ListDivisions"
        static let findArticles = "FindArticles"
        static let authenticateUser = "AuthenticateUser"
        static let reCalculateBasket = "ReCalculateBasket"
        static let validateBasket = "ValidateBasket"
        static let checkoutBasket = "CheckoutBasket"
        static let reCalculateBasketForMembership = "ReCalculateBasketForMembership"
        static let validateBasketForMembership = "ValidateBasketForMembership"
        static let checkoutBasketForMembership = "CheckoutBasketForMembership"
        static let findPerson = "FindPerson"
        static let savePerson = "SavePerson"
        static let findExposition = "FindExpositions"
        static let findExpositionPeriod = "ListExpositionPeriods"
        static let findArticleSalesOrders = "FindArticleSalesOrders"
        static let findSubscriptionArticles = "FindSubscriptionArticles"
        static let lockBasketItems = "LockBasketItems"
        static let paymentGateWayURL = "PaymentGateWayURL"
        static let findPersonCards = "FindPersonCards"
        static let findOrganisedVisits = "FindOrganisedVisits"
        static let findSubscriptions = "FindSubscriptions"
        static let ListCountries = "ListCountries"
        static let ListPersonTitles = "ListPersonTitles"
        static let PasswordReset = "PasswordReset"
        static let TicketPurchase = "TicketPurchase"
        static let CPRegistration = "CPRegistration"
        static let CPRenewal = "CPRenewal"
        static let CPPurchaseMail = "CPPurchaseMail"
        static let CancelSubscription = "CancelSubscription"
        
    }
    
    //FONTS:-
    struct App {
//        "AppRegularFont" = "DINNextLTPro-Regular";
//        "AppBoldFont" = "DINNextLTPro-Bold";
    static let regularFontEn = "DINNextLTPro-Regular"
    static let boldFontEn = "DINNextLTPro-Bold";
        
    static let regularFontAr = "DINNextLTArabic-Regular"
    static let boldFontAr = "DINNextLTArabic-Bold"
        
    static let regularFont = NSLocalizedString("AppRegularFont", comment: "")
    static let boldFont = NSLocalizedString("AppBoldFont", comment: "")
    }
    
    //MARK:-
    struct commonRequestKeys {
        static let language = "Language"
        static let searchCriteria = "SearchCriteria"
        static let criteria = "Criteria"
        static let credentials = "Credentials"
        static let context = "Context"
        static let includes = "Includes"
        
        static let Paging = "Paging"
        static let PageIndex = "PageIndex"
        static let PageSize = "PageSize"
        
        static let languageType = "EN"
        
        static let shopId = "ShopId"
        static let password = "Password"
    }
    
    //MARK:-
    struct ListDivisionKeys {
        static let divisions = "divisions"
        static let name = "name"
        static let id = "id"
        static let address = "address"
        static let box = "box"
    }
    
    //MARK:-
    struct ExpositionsKeys {
        static let expositions = "expositions"
        static let name = "name"
        static let id = "id"
        static let divisionId = "divisionId"
        static let prices = "prices"
        static let amount = "amount"
        static let group = "group"
        static let code = "code"
        static let startDate = "startDate"
        static let endDate = "endDate"
    }
    
    //MARK:-
    struct FindArticleKeys {
        static let articles = "articles"
        static let id = "id"
        static let name = "name"
        static let description = "description"
    }
    
    //MARK:-
    struct UserValues{
        static let password = "Password"
        static let username = "Username"
        static let isLoggedIn = "isLoggedIn"
        
        static let result = "result"
        static let hasSucceeded = "hasSucceeded"
        static let personId = "personId"
        static let person = "person"
        static let name = "name"
        static let first = "first"
        static let last = "last"
        static let email = "email"
        static let phone = "phone"
    }
    
    //MARK:-
    struct ExpostionPeriodsKeys {
        static let expositionPeriods = "expositionPeriods"
        static let expositionId = "expositionId"
        static let finalSubscriptionDate = "finalSubscriptionDate"
        static let from = "from"
        static let id = "id"
        static let occupancy = "occupancy"
        static let current = "current"
        static let maximum = "maximum"
        static let remaining = "remaining"
        static let controlType = "controlType"
        static let maxVisitorsPerGroup = "maxVisitorsPerGroup"
        static let until = "until"
        static let finalSubscriptionDateBo = "finalSubscriptionDateBo"
    }
    
    //MARK:-
    struct FindSubscriptionsKeys {
        static let subscriptionId = "SubscriptionId"
        static let id = "id"
        static let name = "name"
        static let includes = "includes"
        static let Inactive = "Inactive"
        static let Invalid = "Invalid"
        static let Logs = "Logs"
        static let PersonCards = "PersonCards"
        static let Image = "Image"
        static let OnlyCurrentPersonCard = "OnlyCurrentPersonCard"
        static let InvalidityReasons = "InvalidityReasons"
        static let LessonGroups = "LessonGroups"
        static let PriceGroup = "PriceGroup"
        static let Paging = "Paging"
        static let PageIndex = "PageIndex"
        static let PageSize = "PageSize"
        static let ListForProlongation = "ListForProlongation"
        static let ListForReader = "ListForReader"
        static let IgnoreExclusionCalendar = "IgnoreExclusionCalendar"
        static let personId = "personId"
        static let subscriptions = "subscriptions"
        static let article = "article"
        static let startDateTime = "startDateTime"
        static let endDateTime = "endDateTime"
        static let creationDate = "creationDate"
    }
    
    //MARK:-
    struct FindSubscriptionArticlesKeys {
        static let includes = "includes"
        static let prices = "prices"
        static let imageurl = "imageUrl"
        
        static let subscriptionArticles = "subscriptionArticles"
        static let name = "name"
        static let price = "price"
        static let id = "id"
        
        static let shortDescription = "shortDescription"
        
        //static let familyId = "8e54f0f2-2725-e911-a2d5-005056b0685a"
        static let familyId = "ec753a17-182d-e911-a2d3-005056b0c847"
        static let familyIdProd = "ec753a17-182d-e911-a2d3-005056b0c847"
        
        //static let basicId = "5b85a1bd-ca22-e911-a2d5-005056b0685a"
        static let basicId = "3f5c5626-172d-e911-a2d3-005056b0c847"
        static let basicIdProd = "3f5c5626-172d-e911-a2d3-005056b0c847"
        
        //static let plusId = "2af79b61-cb22-e911-a2d5-005056b0685a"
        static let plusId = "085c70d2-172d-e911-a2d3-005056b0c847"
        static let plusIdProd = "085c70d2-172d-e911-a2d3-005056b0c847"
        
        static let staffBasic = "434BDFC7-123B-E911-A2D3-005056B03FC3"
        
        static let staffPlus = "FA67A0D9-123B-E911-A2D3-005056B03FC3"
        static let promoPlus = "EA409CB9-7E3D-E911-A2D3-005056B03FC3"
        
        static let staffFamily = "B8931DE8-123B-E911-A2D3-005056B03FC3"
        static let promoFamily = "DBC5CFE9-7E3D-E911-A2D3-005056B03FC3"
        static let limEdition = "B2E05807-A356-E911-A2D3-005056B03FC3"
        
        static let periodDuration = "periodDuration"
        static let months = "months"
        
    }
    
    //MARK:-
    struct BasketKey {
        static let id = "Id"
        static let type = "$type"
        static let quantity = "Quantity"
        static let article = "Article"
        static let items = "Items"
        static let basket = "Basket"
        static let customerID = "customerID"
        static let unitPrice = "unitPrice"
        static let Amount = "Amount"
        static let Currency = "Currency"
        static let PaymentMethodId = "PaymentMethodId"
        static let PaymentMethodIdVal = "f6c39b6f-9254-e611-ae9c-8cdcd4cc8afb"
        static let payments = "payments"
        static let price = "price"
        static let result = "result"
        static let basketValidationResult = "basketValidationResult"
        static let isValid = "isValid"
        static let message = "message"
        static let resultState = "resultState"
        static let directDebitProcessing = "directDebitProcessing"
        static let salesItems = "salesItems"
        static let articleId = "articleId"
        static let barcodes = "barcodes"
        static let isMembership = "isMembership"
        static let name = "name"
        static let salesHeaderID = "salesHeaderID"
        static let date = "date"
        static let amount = "amount"
        static let salesNumber = "salesNumber"
        static let salesOrderNumber = "salesOrderNumber"
        static let salesSeriesId = "salesSeriesId"
        static let orderId = "orderId"
        static let basketItems = "BasketItems"
        static let entries = "Entries"
        static let participantCount = "ParticipantCount"
        static let priceGroupId = "PriceGroupId"
        static let expositionPeriodId = "ExpositionPeriodId"
        static let expositionId = "ExpositionId"
        static let lockBasketResult = "lockBasketResult"
        static let divisionId = "divisionId"
        static let lockTicket = "lockTicket"
        static let externalBarcodeIds = "externalBarcodeIds"
        static let expirationTime = "expirationTime"
        static let isLocked = "isLocked"
        static let saleDetails = "saleDetails"
        static let validationResult = "validationResult"
    }
    
    //MARK:-
    struct FindOrganisedVisitsKeys{
        static let PersonId = "PersonId"
        static let Includes = "Includes"
        static let Cancelled = "Cancelled"
        static let PersonDetails = "PersonDetails"
        static let PeriodReservations = "PeriodReservations"
        static let Articles = "Articles"
        static let ContactDetails = "ContactDetails"
        static let organisedVisits = "organisedVisits"
        static let id = "id"
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let periodReservations = "periodReservations"
        static let articleName = "articleName"
        static let quantity = "quantity"
        static let divisionIdOnExposition = "divisionIdOnExposition"
        static let Paging = "Paging"
        static let PageIndex = "PageIndex"
        static let PageSize = "PageSize"
    }
    
    //MARK:-
    struct PersonKeys {
        static let id = "id"
        static let dummyIdForAnonymousUser = "00000000-0000-0000-0000-000000000000"
        static let person = "Person"
        static let result = "result"
        static let address = "address"
        static let country = "country"
        static let number = "number"
        static let street = "street"
        static let town = "town"
        static let zipCode = "zipCode"
        static let birthDate = "birthDate"
        static let cellPhone = "cellPhone"
        static let credential = "credential"
        static let username = "username"
        static let password = "Password"
        static let email = "email"
        static let name = "name"
        static let Code = "Code"
        static let first = "first"
        static let last = "last"
        static let phone = "phone"
        static let gender = "Gender"
        static let language = "Language"
        static let settings = "Settings"
        static let subscribeMailingList = "SubscribeMailingList"
        
        static let options = "Options"
        static let createZipcodes = "CreateZipcodes"
        static let ignoreCredentials = "IgnoreCredentials"
        static let ignoreDuplicates = "IgnoreDuplicates"
        static let skipAgeValidation = "SkipAgeValidation"
        
        static let validationResults = "validationResults"
        static let isValid = "isValid"
        static let message = "message"
        
        static let group = "group"
        static let shortName = "shortName"
        
        static let Title = "Title"
        static let ShortName = "ShortName"
        static let Description = "Description"
        
        static let Info1 = "Info1"
        static let Info2 = "Info2"
        static let Info3 = "Info3"
        static let Info4 = "Info4"
        
    }
    
    //MARK:-
    struct AnonymousPersonKeys {
        static let AnonymousPerson = "AnonymousPerson"
        static let Name = "Name"
        static let FirstName = "FirstName"
        static let Street1 = "Street1"
        static let Street2 = "Street2"
        static let Number = "Number"
        static let Box = "Box"
        static let Home = "Home"
        static let Country = "Country"
        static let Email = "Email"
        static let Newsletter = "Newsletter"
        static let ZipCode = "ZipCode"
    }
    
    //MARK:-
    struct ListCountries {
        static let Paging = "Paging"
        static let PageIndex = "PageIndex"
        static let PageSize = "PageSize"
        static let result = "result"
        static let id = "id"
        static let code = "code"
        static let name = "name"
    }
    
    //MARK:-
    struct ListPersonTitlesKeys {
        static let titleResult = "titleResult"
        static let id = "id"
        static let shortName = "shortName"
        static let description = "description"
    }
    
    //MARK:-
    struct FindArticleSalesOrdersKeys {
        static let articleSalesOrders = "articleSalesOrders"
        static let articleId = "articleId"
        static let id = "id"
        static let description = "description"
        static let articleName = "articleName"
        static let date = "date"
        static let articleDescription = "articleDescription"
        static let personId = "personId"
        static let number = "number"
        static let sequenceNumber = "sequenceNumber"
        static let quantity = "quantity"
        static let unitPrice = "unitPrice"
        static let totalPrice = "totalPrice"
    }
    
    struct FindPersonCardsKeys {
        
        static let cardString = "CardString"
        static let personCards = "personCards"
        static let description = "description"
        static let card = "card"
        static let number = "number"
        static let cardNumber = "cardNumber"
    }
    
    //MARK:- Payment Gateway URL req Keys
    struct paymentGatewayKeys {
        static let pay = "pay"
        static let paymenturl = "paymenturl"
    }
    
    //MARK:-
    struct CPValidationKeys {
        static let CP_Family = "CP Family"
        static let Culture_Pass_Family_Card_Holder = "Culture Pass Family Card Holder"
        static let Culture_Pass_Family = "Culture Pass Family"
        
        static let CP_Family_Additional = "CP Family Additional"
        static let CP_Additional_Family = "CP Additional Family"
        
        static let QMA_STAFF_CP_Basic = "QMA STAFF CP Basic"
        
        static let QMA_STAFF_CP_Plus = "QMA STAFF CP Plus"
        static let CP_Plus_PROMO = "CP Plus PROMO"
        
        static let QMA_STAFF_CP_Family = "QMA STAFF CP Family"
        static let  CP_Family_PROMO = "CP Family PROMO"
        static let  NMoQ_Limited_Edition1 = "NMoQ Limited Edition"

        
        static let QM_STAFF_CP_FAMILY = "QM STAFF CP FAMILY"
        static let CP_PROMO_FAMILY = "CP PROMO FAMILY"
        
        static let CP_Member_Basic = "CP Member Basic"
        static let CP_Basic = "CP Basic"
        static let Culture_Pass_Basic_Card_Holder = "Culture Pass Basic Card Holder"
        static let Culture_Pass_Basic = "Culture Pass Basic"
        static let QM_STAFF_CP_BASIC = "QM STAFF CP BASIC"
        
        static let CP_Plus = "CP Plus"
        static let QM_STAFF_CP_PLUS = "QM STAFF CP PLUS"
        static let CP_PROMO_PLUS = "CP PROMO PLUS"
        static let  NMOQ_LIMITED_EDITION_PLUS = "NMOQ LIMITED EDITION PLUS"
        static let  VIP_LIMITED_EDITION_PLUS = "VIP LIMITED EDITION PLUS"
        
       
        static let Culture_Pass_Plus_Card_Holder = "Culture Pass Plus Card Holder"
        static let Culture_Pass_Plus = "Culture Pass Plus"
        
        static let guestErrMsg = "You are not authorized to select CP Membership tickets, please log in or register to become a member."
        static let basicOrPlusErrMsg = "You are not authorized member, please upgrade your membership."
        static let familyErrMsg = "You are not authorized user."
    }
    
    
    //MARK:-
    struct CellId {
        static let ticketCounterTableViewCell = "ticketCounterTableViewCell"
        static let expositionCellId = "expositionCellId"
        static let timePickerCellId = "timePickerCellId"
        static let divisionListCollectionViewCell = "DivisionListCollectionViewCell"
        static let eventListTableViewCell = "EventListTableViewCell"
        static let subViewListCollectionViewCell = "subViewListCollectionViewCell"
        static let cartTableViewCell = "CartTableViewCell"
        static let CulturePassTableViewCellID = "CulturePassTableViewCellID"
        static let checkoutBasketTblCell = "CheckoutBasketTblCell"
        static let userInfoTableViewCell = "userInfoTableViewCell"
        static let myVisitsTableViewControllerCell = "MyVisitsTableViewControllerCell"
        static let ticketPickerTableViewCellID = "TicketPickerTableViewCellID"
        static let BenefitsTableViewCellID = "BenefitsTableViewCellID"
    }
    
    //MARK:-
    struct StoryboardControllerID {
        static let calendarViewController = "QMTLCalendarViewController"
        static let ticketCounterTableViewController = "QMTLTicketCounterTableViewController"
        static let timePickerViewController = "QMTLTimePickerViewController"
        static let guestUserViewController = "QMTLGuestUserViewController"
        static let signInUserViewController = "QMTLSignInUserViewController"
        static let cartTableViewController = "QMTLCartTableTableViewController"
        static let ticketSuccessfullTableViewController = "QMTLTicketSuccessfullTableViewController"
    }
    
    //MARK:-
    struct Segue {
        static let ticketCounterViewControllerSegue = "TicketCounterViewControllerSegue"
        static let ticketCounterTableViewSegue = "ticketCounterTableViewSegue"
        static let segueQMTLGuestUserViewController = "SegueQMTLGuestUserViewController"
        static let segueQMTLSignInUserViewController = "SegueQMTLSignInUserViewController"
        static let segueCulturePassTableViewController = "SegueCulturePassTableViewController"
        static let segueCulturePassList = "culturePassListSegue"
        static let signupFromCardSegue = "signupFromCardSegue"
        static let segueQMTLSignInUserViewControllerFromProfile = "SegueQMTLSignInUserViewControllerFromProfile"
        static let segueQMTLTicketSuccessfullViewController = "SegueQMTLTicketSuccessfullViewController"
        static let segueUserInfoTableViewController = "SegueUserInfoTableViewController"
        static let segueMyVisitsTableViewController = "SegueMyVisitsTableViewController"
        static let segueQMTLCartTableTableViewController = "SegueQMTLCartTableTableViewController"
        static let segueMembershipPurchasedViewController = "SegueMembershipPurchasedViewController"
        static let segueMyVisitsTableViewControllerFromPaymentSuccess = "SegueMyVisitsTableViewControllerFromPaymentSuccess"
        static let seguePaymentGatewayViewControllerFromTicketCounter = "SeguePaymentGatewayViewControllerFromTicketCounter"
        static let seguePrintTicketViewController = "SeguePrintTicketViewController"
        static let segueSignUpTableViewController = "SegueSignUpTableViewController"
        static let segueReadBenefitsViewController = "SegueReadBenefitsViewController"
    }
    
    //MARK:-
    struct NibName {
        static let expositionListCollectionViewCell = "ExpositionListCollectionViewCell"
        static let divisionListCollectionViewCell = "DivisionListCollectionViewCell"
        static let culturePassTableViewCell = "CulturePassTableViewCell"
        static let ticketPickerTableViewCell = "TicketPickerTableViewCell"
        static let benefitsTableViewCell = "BenefitsTableViewCell"
    }
    
    //MARK:-
    struct ErrorMessage {
        static let periodsNotAvail = "Period not available in this date"
    }
    
}
