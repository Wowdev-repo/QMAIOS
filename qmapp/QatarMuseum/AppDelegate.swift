//
//  AppDelegate.swift
//  QatarMuseum
//
//  Created by Wakralab Software Labs on 06/06/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

//
import Firebase
import FirebaseMessaging
import GoogleMaps
import GooglePlaces
import Kingfisher
import UIKit
import UserNotifications
@_exported import CoreData 
@_exported import Alamofire
@_exported import CocoaLumberjack

var tokenValue : String? = nil
var languageKey = 1

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var window: UIWindow?
    var shouldRotate = false
    let networkReachability = NetworkReachabilityManager()
    var tourGuideId : String? = ""
    
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        fetch database location
        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
        
        setupQMLogger()
//        DDLogVerbose("Did select settings action")
        DDLogInfo("AppDelegate initiated ..")
//        DDLogError("Hope no Failed to create AppDelegate ..")
//        DDLogWarn("Failed to load post details with error: \(error.localizedDescription)")
        
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        
       // GMSServices.provideAPIKey("AIzaSyBXEzUfmsi5BidKqR1eY999pj0APP2N0k0")
        GMSServices.provideAPIKey("AIzaSyAbuv0Gx0vwyZdr90LFKeUFmMesorNZHKQ") // QM key
        GMSPlacesClient.provideAPIKey("AIzaSyAbuv0Gx0vwyZdr90LFKeUFmMesorNZHKQ")
        CPCoreDataManager.shared.setup {
            self.apiCalls()
        }
        
        // Register with APNs
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        CPAppLocalizer.performMethodSwizzle()
        FirebaseApp.configure()
        
        fetchCurrentNotificationToken()
        registerForPushNotifications()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        //Launched from push notification
        let remoteNotif = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: Any]
        if remoteNotif != nil {
            //            let aps = remoteNotif!["aps"] as? [String:AnyObject]
            //            NSLog("\n Custom: \(String(describing: aps))")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let notificationsView = storyboard.instantiateViewController(withIdentifier: "notificationId") as! CPNotificationsViewController
            notificationsView.fromHome = true
            self.window?.rootViewController = notificationsView
            self.window?.makeKeyAndVisible()
        }
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    
    
    func apiCalls() {
        if  (networkReachability?.isReachable)! {
            self.getHomeList(lang: ENG_LANGUAGE)
            self.getHomeList(lang: AR_LANGUAGE)
            self.getExhibitionDataFromServer(lang: ENG_LANGUAGE)
            self.getExhibitionDataFromServer(lang: AR_LANGUAGE)
            self.getHeritageDataFromServer(lang: ENG_LANGUAGE)
            self.getHeritageDataFromServer(lang: AR_LANGUAGE)
            self.getMiaTourGuideDataFromServer(museumId: "63", lang: ENG_LANGUAGE)
            self.getMiaTourGuideDataFromServer(museumId: "96", lang: AR_LANGUAGE)
            self.getNmoQAboutDetailsFromServer(museumId: "13376", lang: ENG_LANGUAGE)
            self.getNmoQAboutDetailsFromServer(museumId: "13376", lang: AR_LANGUAGE) // Arabic id is needed
            self.getNMoQTourList(lang: ENG_LANGUAGE)
            self.getNMoQTourList(lang: AR_LANGUAGE)
            self.getTravelList(lang: ENG_LANGUAGE)
            self.getTravelList(lang: AR_LANGUAGE)
            self.getNMoQSpecialEventList(lang: ENG_LANGUAGE)
            self.getNMoQSpecialEventList(lang: AR_LANGUAGE)
            self.getDiningListFromServer(language: ENG_LANGUAGE)
            self.getDiningListFromServer(language: AR_LANGUAGE)
            self.getPublicArtsListDataFromServer(lang: ENG_LANGUAGE)
            self.getPublicArtsListDataFromServer(lang: AR_LANGUAGE)
            self.getCollectionList(museumId: "63", lang: ENG_LANGUAGE)
            self.getCollectionList(museumId: "96", lang: AR_LANGUAGE)
            self.getParksDataFromServer(lang: ENG_LANGUAGE)
            self.getParksDataFromServer(lang: AR_LANGUAGE)
            self.getFacilitiesListFromServer(lang: ENG_LANGUAGE)
            self.getFacilitiesListFromServer(lang: AR_LANGUAGE)
            self.getNmoqParkListFromServer(lang: ENG_LANGUAGE)
            self.getNmoqParkListFromServer(lang: AR_LANGUAGE)
            self.getNmoqListOfParksFromServer(lang: ENG_LANGUAGE)
            self.getNmoqListOfParksFromServer(lang: AR_LANGUAGE)
            
             DDLogInfo("API calls initiated .." + NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        }
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self ///as? UNUserNotificationCenterDelegate
//        } else {
//            // Fallback on earlier versions
//        }
//        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                print("Permission granted: \(granted)")
                // 1. Check if permission granted
                guard granted else { return }
                // 2. Attempt registration for remote notifications on the main thread
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func fetchCurrentNotificationToken() {
        
        Messaging.messaging().delegate = self
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
    }
    
    //    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    //        // 1. Convert device token to string
    //        let tokenParts = deviceToken.map { data -> String in
    //            return String(format: "%02.2hhx", data)
    //        }
    //        let token = tokenParts.joined()
    //        // 2. Print device token to use for PNs payloads
    //        print("Device Token: \(token)")
    //    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        CPCoreDataManager.shared.saveContext()
    }
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return shouldRotate ? .allButUpsideDown : .portrait
    }
    
    //MARK: Push notification receive delegates
    //    func application(_ application: UIApplication,
    //                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    //                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    //        application.applicationIconBadgeNumber = 0
    //        print("Recived: \(userInfo)")
    //        if (application.applicationState == .active) {
    //            if let topController = UIApplication.topViewController() {
    //                print(topController)
    //            }
    //            // Do something you want when the app is active
    //
    //        } else {
    //
    //            // Do something else when your app is in the background
    //
    //
    //        }
    //        completionHandler(.newData)
    //
    //    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token) ")
        tokenValue = token
        self.sendDeviceTokenToServer(deviceToken: token)
    }
    
    //    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
    //        error: Error) {
    //        // Try again later.
    //    }
    
    // This method will be called when we click push notifications in background
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        let info = self.extractUserInfo(userInfo: userInfo)
        print(info.title)
        
        let notificationData = UserDefaults.standard.object(forKey: "pushNotificationList") as? NSData
        if let notificationData = notificationData, let notifications = NSKeyedUnarchiver.unarchiveObject(with: notificationData as Data) as?
            [CPNotification] {
            var notificationArray = notifications
            notificationArray.insert(CPNotification(title: info.title, sortId: info.title, language: CPUtils.getLanguage()), at: 0)
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: notificationArray)
            UserDefaults.standard.set(notificationData, forKey: "pushNotificationList")
        } else {
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: [CPNotification(title: info.title, sortId: info.title, language: CPUtils.getLanguage())])
            UserDefaults.standard.set(notificationData, forKey: "pushNotificationList")
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "Initiate",
            AnalyticsParameterItemName: "App Initiate",
            AnalyticsParameterContentType: "User open app"
            ])
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let notificationsView = storyboard.instantiateViewController(withIdentifier: "notificationId") as! CPNotificationsViewController
        notificationsView.fromHome = true
        self.window?.rootViewController = notificationsView
        self.window?.makeKeyAndVisible()
        //            NotificationCenter.default.post(name: NSNotification.Name("NotificationIdentifier"), object: nil)
    }
    
    // This method will be called when app received push notifications in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Print full message.
        print(userInfo)
        let info = self.extractUserInfo(userInfo: userInfo)
        print(info.title)
        
        if let badgeCount = UserDefaults.standard.value(forKey: "notificationBadgeCount") as?
            Int {
            UserDefaults.standard.setValue(badgeCount + 1, forKey: "notificationBadgeCount")
        } else {
            UserDefaults.standard.setValue(1, forKey: "notificationBadgeCount")
        }
        
        let notificationData = UserDefaults.standard.object(forKey: "pushNotificationList") as? NSData
        if let notificationData = notificationData, let notifications = NSKeyedUnarchiver.unarchiveObject(with: notificationData as Data) as?
            [CPNotification] {
            var notificationArray = notifications
            notificationArray.insert(CPNotification(title: info.title, sortId: info.title, language: CPUtils.getLanguage()), at: 0)
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: notificationArray)
            UserDefaults.standard.set(notificationData, forKey: "pushNotificationList")
        } else {
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: [CPNotification(title: info.title, sortId: info.title, language: CPUtils.getLanguage())])
            UserDefaults.standard.set(notificationData, forKey: "pushNotificationList")
        }
        if let topController = UIApplication.topViewController() {
            print(topController)
            if topController is CPHomeViewController {
                (topController as! CPHomeViewController).updateNotificationBadge()
            } else if topController is CPMuseumsViewController {
                (topController as! CPMuseumsViewController).updateNotificationBadge()
            } else if topController is CPNotificationsViewController {
                (topController as! CPNotificationsViewController).updateNotificationTableView()
            }
        }
        //        completionHandler([.alert, .badge, .sound])
    }
    
    //MARK: WebServiceCall
    func sendDeviceTokenToServer(deviceToken: String) {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetToken(["name":"","pass":""])).responseObject { (response: DataResponse<CPTokenData>) -> Void in
            switch response.result {
            case .success(let data):
                _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.SendDeviceToken(data.accessToken!, ["token": deviceToken, "type":"ios"])).responseObject { (response: DataResponse<DeviceToken>) -> Void in
                    switch response.result {
                    case .success( _):
                        DDLogInfo("This token is successfully sent to server")
                    case .failure( _):
                        DDLogInfo("Fail to update device token")
                    }
                }
            case .failure( _):
                DDLogInfo("Failed to generate token ")
            }
        }
    }
    
    func extractUserInfo(userInfo: [AnyHashable : Any]) -> (title: String, body: String) {
        var info = (title: "", body: "")
        guard let aps = userInfo["aps"] as? [String: Any] else { return info }
        //        guard let alert = aps["alert"] as? [String: Any] else { return info }
        let title = aps["alert"] as? String ?? ""
        let body = "" //alert["body"] as? String ?? ""
        info = (title: title, body: body)
        return info
    }
    
   
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = CPCoreDataManager.shared.persistentContainer
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = CPCoreDataManager.shared.managedObjectContext
        return managedObjectContext
    }()
    
    
    //MARK: HeritageList WebServiceCall
    func getHeritageDataFromServer(lang: String) {
        let queue = DispatchQueue(label: "HeritageThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.HeritageList(lang))
            .responseObject(queue: queue) { [weak self] (response: DataResponse<Heritages>) -> Void in
            switch response.result {
            case .success(let data):
                if let heritage = data.heritage{
                        DispatchQueue.main.async{
                            self?.saveOrUpdateHeritageCoredata(heritageListArray: heritage,
                                                              language: lang)
                        }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateHeritageCoredata(heritageListArray: [CPHeritage],
                                      language: String) {
        if !heritageListArray.isEmpty {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateHeritage(managedContext : managedContext,
                                               heritageListArray: heritageListArray,
                                               language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateHeritage(managedContext : managedContext,
                                               heritageListArray: heritageListArray,
                                               language: CPUtils.getLanguageCode(language))
                }
            }
        }
    }

    //MARK: Exhibitions Service call
    func getExhibitionDataFromServer(lang: String) {
        let queue = DispatchQueue(label: "ExhibitionThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.ExhibitionList(lang))
            .responseObject(queue: queue) { [weak self] (response: DataResponse<Exhibitions>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.exhibitions != nil) {
                    if let exhibitions = data.exhibitions {
                        self?.saveOrUpdateExhibitionsCoredata(exhibition: exhibitions,
                                                             language: lang)
                    }
                }
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Exhibitions Coredata Method
    func saveOrUpdateExhibitionsCoredata(exhibition: [CPExhibition], language: String) {
        if !exhibition.isEmpty {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateExhibitionsEntity(managedContext: managedContext,
                                                        exhibition: exhibition,
                                                        isHomeExhibition: "0",
                                                        language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateExhibitionsEntity(managedContext: managedContext,
                                                        exhibition: exhibition,
                                                        isHomeExhibition: "0",
                                                        language: CPUtils.getLanguageCode(language))
                    
                }
            }
        }
    }
    
    
    //MARK: Home Service call
    func getHomeList(lang: String) {
        let queue = DispatchQueue(label: "HomeThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.HomeList(lang)).responseObject(queue:queue) { [weak self] (response: DataResponse<HomeList>) -> Void in
            switch response.result {
            case .success(let data):
                if let homeList = data.homeList {
                        DispatchQueue.main.async{
                            self?.saveOrUpdateHomeCoredata(homeList: homeList,
                                                          language: lang)
                    }
                }
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Home Coredata Method
    func saveOrUpdateHomeCoredata(homeList: [CPHome],
                                  language: String ) {
        if !homeList.isEmpty {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateHomeEntity(managedContext: managedContext,
                                                 homeList: homeList,
                                                 language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateHomeEntity(managedContext: managedContext,
                                                 homeList: homeList,
                                                 language: CPUtils.getLanguageCode(language))
                }
            }
        }
    }
    
    
    //MARK: MIA TourGuide WebServiceCall
    func getMiaTourGuideDataFromServer(museumId:String?,
                                       lang:String) {
        let queue = DispatchQueue(label: "MiaTourThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.MuseumTourGuide(lang,["museum_id": museumId!])).responseObject(queue:queue) { [weak self] (response: DataResponse<TourGuides>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.tourGuide != nil) {
                    if((data.tourGuide?.count)! > 0) {
                        DispatchQueue.main.async{
                            self?.saveOrUpdateTourGuideCoredata(miaTourDataFullArray: data.tourGuide,
                                                               museumId: museumId,
                                                               lang: lang)
                        }
                    }
                }
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateTourGuideCoredata(miaTourDataFullArray:[CPTourGuide]?,
                                       museumId: String?,
                                       lang:String) {
        if ((miaTourDataFullArray?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    if let array = miaTourDataFullArray {
                        CPDataManager.updateTourGuide(managedContext: managedContext,
                                                    miaTourDataFullArray: array,
                                                    museumID: museumId,
                                                    language: CPUtils.getLanguageCode(lang))
                    }
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    if let array = miaTourDataFullArray {
                        CPDataManager.updateTourGuide(managedContext: managedContext,
                                                    miaTourDataFullArray: array,
                                                    museumID: museumId,
                                                    language: CPUtils.getLanguageCode(lang))
                    }
                }
            }
        }
    }
    
    
    //MARK: NMoQ ABoutEvent Webservice
    func getNmoQAboutDetailsFromServer(museumId:String?,lang: String) {
        let queue = DispatchQueue(label: "NmoQAboutThread", qos: .background, attributes: .concurrent)
        if(museumId != nil) {
            
            _ = CPSessionManager.sharedInstance.apiManager()?
                .request(CPQatarMuseumRouter.GetNMoQAboutEvent(lang,
                                                             ["nid": museumId!]))
                .responseObject(queue: queue) { [weak self] (response: DataResponse<Museums>) -> Void in
                    switch response.result {
                    case .success(let data):
                        if(data.museum != nil) {
                            if((data.museum?.count)! > 0) {
                                DispatchQueue.main.async{
                                    self?.saveOrUpdateAboutCoredata(aboutDetailtArray: data.museum,
                                                                   lang: lang)
                                }
                            }
                        }
                        
                    case .failure( _):
                        print("error")
                    }
            }
        }
    }
    //MARK: About CoreData
    func saveOrUpdateAboutCoredata(aboutDetailtArray:[CPMuseum]?,
                                   lang: String) {
        if ((aboutDetailtArray?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() { managedContext in
                    CPDataManager.saveAboutDetails(managedContext: managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: false,
                                                 language: CPUtils.getLanguageCode(lang))
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    CPDataManager.saveAboutDetails(managedContext: managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: false,
                                                 language: CPUtils.getLanguageCode(lang))
                }
            }
        }
    }
    
   
    //MARK: NMoQ Tour ListService call
    func getNMoQTourList(lang: String) {
        let queue = DispatchQueue(label: "NMoQTourListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.GetNMoQTourList(lang))
            .responseObject(queue:queue) { [weak self] (response: DataResponse<NMoQTourList>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.nmoqTourList != nil) {
                    if let nmoqTourList = data.nmoqTourList {
                        DispatchQueue.main.async{
                            self?.saveOrUpdateTourListCoredata(nmoqTourList: nmoqTourList,
                                                              isTourGuide: true, language: lang)
                        }
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    
    //MARK: Tour List Coredata Method
    func saveOrUpdateTourListCoredata(nmoqTourList: [CPNMoQTour], isTourGuide: Bool, language: String) {
        if !nmoqTourList.isEmpty {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateTourList(nmoqTourList: nmoqTourList,
                                               managedContext: managedContext,
                                               isTourGuide: isTourGuide,
                                               language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateTourList(nmoqTourList: nmoqTourList,
                                               managedContext: managedContext,
                                               isTourGuide: isTourGuide,
                                               language: CPUtils.getLanguageCode(language))
                }
            }
        }
    }
    
    
    //MARK: NMoQ TravelList Service Call
    func getTravelList(lang: String) {
        let queue = DispatchQueue(label: "NMoQTravelListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.GetNMoQTravelList(lang))
            .responseObject(queue:queue) { [weak self] (response: DataResponse<HomeBannerList>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.homeBannerList != nil) {
                    if let homeBannerList = data.homeBannerList {
                        self?.saveOrUpdateTravelListCoredata(travelList: homeBannerList,
                                                            language: lang)
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Travel List Coredata
    func saveOrUpdateTravelListCoredata(travelList: [CPHomeBanner],
                                        language: String) {
        if travelList.count > 0 {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateTravelList(travelList: travelList,
                                                 managedContext : managedContext,
                                                 language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateTravelList(travelList: travelList,
                                                 managedContext : managedContext,
                                                 language: CPUtils.getLanguageCode(language))
                }
            }
        }
    }
    
    //MARK: NMoQSpecialEvent Lst APi
    func getNMoQSpecialEventList(lang: String) {
        let queue = DispatchQueue(label: "NMoQSpecialEventListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.GetNMoQSpecialEventList(lang))
            .responseObject(queue:queue) { [weak self] (response: DataResponse<NMoQActivitiesListData>) -> Void in
            switch response.result {
            case .success(let data):
                if let nmoqActivitiesList = data.nmoqActivitiesList {
                    self?.saveOrUpdateActivityListCoredata(nmoqActivityList: nmoqActivitiesList,
                                                          language: lang)
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: ActivityList Coredata Method
    func saveOrUpdateActivityListCoredata(nmoqActivityList: [CPNMoQActivitiesList], language: String) {
        if !nmoqActivityList.isEmpty {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateActivityList(nmoqActivityList: nmoqActivityList,
                                                   managedContext : managedContext,
                                                   language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateActivityList(nmoqActivityList: nmoqActivityList,
                                                   managedContext : managedContext,
                                                   language: CPUtils.getLanguageCode(language))
                }
            }
        }
    }
    
    //MARK: DiningList WebServiceCall
    func getDiningListFromServer(language: String) {
        let queue = DispatchQueue(label: "DiningListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.DiningList(language)).responseObject(queue: queue) { [weak self] (response: DataResponse<Dinings>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.dinings != nil) {
                    if((data.dinings?.count)! > 0) {
                        self?.saveOrUpdateDiningCoredata(diningListArray: data.dinings, lang: language)
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Dining Coredata Method
    func saveOrUpdateDiningCoredata(diningListArray : [CPDining]?, lang: String) {
        if ((diningListArray?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateDinings(managedContext: managedContext,
                                              diningListArray: diningListArray!,
                                              language: lang)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateDinings(managedContext: managedContext,
                                              diningListArray: diningListArray!,
                                              language: lang)
                }
            }
        }
    }
    
    //MARK: PublicArtsList WebServiceCall
    func getPublicArtsListDataFromServer(lang: String) {
        let queue = DispatchQueue(label: "PublicArtsListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.PublicArtsList(lang))
            .responseObject(queue: queue) { [weak self] (response: DataResponse<PublicArtsLists>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.publicArtsList != nil) {
                    if((data.publicArtsList?.count)! > 0) {
                        self?.saveOrUpdatePublicArtsCoredata(publicArtsListArray: data.publicArtsList,
                                                            lang: lang)
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: PublicArtsList Coredata Method
    func saveOrUpdatePublicArtsCoredata(publicArtsListArray: [CPPublicArtsList]?,
                                        lang: String) {
        if ((publicArtsListArray?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updatePublicArts(managedContext : managedContext,
                                                 publicArtsListArray: publicArtsListArray,
                                                 language: CPUtils.getLanguageCode(lang))
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    CPDataManager.updatePublicArts(managedContext : managedContext,
                                                 publicArtsListArray: publicArtsListArray,
                                                 language: CPUtils.getLanguageCode(lang))
                }
            }
        }
    }
    
    
    //MARK: Webservice call
    func getCollectionList(museumId:String?, lang: String) {
        let queue = DispatchQueue(label: "CollectionListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.CollectionList(lang, ["museum_id": museumId ?? 0])).responseObject(queue: queue) { [weak self] (response: DataResponse<Collections>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.collections != nil) {
                    if let collections = data.collections {
                        self?.saveOrUpdateCollectionCoredata(collection: collections,
                                                            museumId: museumId, language: lang)
                    }
                }
                
                
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateCollectionCoredata(collection: [CPCollection],
                                        museumId:String?, language: String) {
        if !collection.isEmpty {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.collectionsListCoreDataInBackgroundThread(managedContext : managedContext,
                                                                   collection: collection,
                                                                   museumId: museumId, code: language)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    self.collectionsListCoreDataInBackgroundThread(managedContext : managedContext,
                                                                   collection: collection,
                                                                   museumId: museumId, code: language)
                }
            }
        }
    }
    
    func collectionsListCoreDataInBackgroundThread(managedContext: NSManagedObjectContext,
                                                   collection: [CPCollection],
                                                   museumId:String?, code: String) {
        let fetchData = CPDataManager.checkAddedToCoredata(entityName: "CollectionsEntity",
                                                         idKey: "museumId",
                                                         idValue: nil,
                                                         managedContext: managedContext) as! [CollectionsEntity]
            if (fetchData.count > 0) {
                let isDeleted = CPDataManager.delete(managedContext: managedContext,
                                                                entityName: "CollectionsEntity")
                if(isDeleted == true) {
                    for collectionListDict in collection {
                        CPDataManager.saveCollectionsEntity(collectionListDict: collectionListDict,
                                                          managedObjContext: managedContext,
                                                          language: CPUtils.getLanguageCode(code))
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(collectionsListNotificationEn), object: self)
            }
            else {
                for collectionListDict in collection {
                    CPDataManager.saveCollectionsEntity(collectionListDict: collectionListDict,
                                                      managedObjContext: managedContext,
                                                      language: CPUtils.getLanguageCode(code))
                }
                NotificationCenter.default.post(name: NSNotification.Name(collectionsListNotificationEn), object: self)
            }
    }
    
    func getParksDataFromServer(lang: String) {
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.ParksList(lang))
            .responseObject { [weak self] (response: DataResponse<ParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                if let parkList = data.parkList {
                    self?.saveOrUpdateParksCoredata(parksListArray: parkList,
                                                   language: lang)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: Coredata Method
    func saveOrUpdateParksCoredata(parksListArray:[CPParksList], language: String) {
        if parksListArray.count > 0 {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateParks(managedContext : managedContext,
                                            parksListArray: parksListArray,
                                            language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateParks(managedContext : managedContext,
                                            parksListArray: parksListArray,
                                            language: CPUtils.getLanguageCode(language))
                }
            }
        }
    }
    
    func getFacilitiesListFromServer(lang: String) {
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.FacilitiesList(lang))
            .responseObject { [weak self] (response: DataResponse<FacilitiesData>) -> Void in
            switch response.result {
            case .success(let data):
                    if let facilitiesList = data.facilitiesList {
                        self?.saveOrUpdateFacilitiesListCoredata(facilitiesList: facilitiesList,
                                                                language: lang)
                    }
                
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Facilities List Coredata Method
    func saveOrUpdateFacilitiesListCoredata(facilitiesList: [CPFacilities],
                                            language: String) {
        if !facilitiesList.isEmpty {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateFacilitiesEntity(facilitiesList: facilitiesList,
                                                       managedContext : managedContext,
                                                       language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateFacilitiesEntity(facilitiesList: facilitiesList,
                                                       managedContext : managedContext,
                                                       language: CPUtils.getLanguageCode(language))
                }
            }
        }
    }
    
    
    func getNmoqParkListFromServer(lang: String) {
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.GetNmoqParkList(lang))
            .responseObject { [weak self] (response: DataResponse<NmoqParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.nmoqParkList != nil) {
                    if let nmoqParkList = data.nmoqParkList {
                        self?.saveOrUpdateNmoqParkListCoredata(nmoqParkList: nmoqParkList,
                                                              language: lang)
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    
    //MARK: NmoqPark List Coredata Method
    func saveOrUpdateNmoqParkListCoredata(nmoqParkList: [NMoQParksList],
                                          language: String) {
        if !nmoqParkList.isEmpty {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateNmoqParkList(nmoqParkList: nmoqParkList,
                                                   managedContext : managedContext,
                                                   language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateNmoqParkList(nmoqParkList: nmoqParkList,
                                                   managedContext : managedContext,
                                                   language: CPUtils.getLanguageCode(language))
                }
            }
        }
    }
    
    func getNmoqListOfParksFromServer(lang: String) {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetNmoqListParks(lang)).responseObject { [weak self] (response: DataResponse<NMoQParks>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.nmoqParks != nil) {
                    if let nmoqParks = data.nmoqParks {
                        self?.saveOrUpdateNmoqParksCoredata(nmoqParkList: nmoqParks, language: lang)
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    
    //MARK: NMoq List of Parks Coredata Method
    func saveOrUpdateNmoqParksCoredata(nmoqParkList:[NMoQPark], language: String) {
        if !nmoqParkList.isEmpty {
            if #available(iOS 10.0, *) {
                let container = CPCoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateNmoqPark(nmoqParkList: nmoqParkList,
                                               managedContext : managedContext, language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateNmoqPark(nmoqParkList: nmoqParkList,
                                               managedContext : managedContext, language: CPUtils.getLanguageCode(language))
                }
            }
        }
    }
    
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

