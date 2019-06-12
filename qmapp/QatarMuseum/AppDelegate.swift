//
//  AppDelegate.swift
//  QatarMuseum
//
//  Created by Exalture on 06/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//
import Alamofire
import CoreData
import Firebase
import GoogleMaps
import GooglePlaces
import Kingfisher
import UIKit
import UserNotifications
import CocoaLumberjack
var tokenValue : String? = nil

var languageKey = 1

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var shouldRotate = false
    let networkReachability = NetworkReachabilityManager()
    var tourGuideId : String? = ""
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupQMLogger()
//        DDLogVerbose("Did select settings action")
        DDLogInfo("AppDelegate initiated ..")
//        DDLogError("Hope no Failed to create AppDelegate ..")
//        DDLogWarn("Failed to load post details with error: \(error.localizedDescription)")
        
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        
       // GMSServices.provideAPIKey("AIzaSyBXEzUfmsi5BidKqR1eY999pj0APP2N0k0")
        GMSServices.provideAPIKey("AIzaSyAbuv0Gx0vwyZdr90LFKeUFmMesorNZHKQ") // QM key
        GMSPlacesClient.provideAPIKey("AIzaSyAbuv0Gx0vwyZdr90LFKeUFmMesorNZHKQ")
        CoreDataManager.shared.setup {
            self.apiCalls()
        }
        
        
        AppLocalizer.DoTheMagic()
        FirebaseApp.configure()
        
        registerForPushNotifications()
        
        // Register with APNs
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
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
            let notificationsView = storyboard.instantiateViewController(withIdentifier: "notificationId") as! NotificationsViewController
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
            self.getDiningListFromServer(lang: ENG_LANGUAGE)
            self.getDiningListFromServer(lang: AR_LANGUAGE)
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
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
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
        CoreDataManager.shared.saveContext()
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
            [Notification] {
            var notificationArray = notifications
            notificationArray.insert(Notification(title: info.title, sortId: info.title, language: Utils.getLanguage()), at: 0)
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: notificationArray)
            UserDefaults.standard.set(notificationData, forKey: "pushNotificationList")
        } else {
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: [Notification(title: info.title, sortId: info.title, language: Utils.getLanguage())])
            UserDefaults.standard.set(notificationData, forKey: "pushNotificationList")
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\("test")",
            AnalyticsParameterItemName: "Musheer",
            AnalyticsParameterContentType: "cont"
            ])
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let notificationsView = storyboard.instantiateViewController(withIdentifier: "notificationId") as! NotificationsViewController
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
            [Notification] {
            var notificationArray = notifications
            notificationArray.insert(Notification(title: info.title, sortId: info.title, language: Utils.getLanguage()), at: 0)
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: notificationArray)
            UserDefaults.standard.set(notificationData, forKey: "pushNotificationList")
        } else {
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: [Notification(title: info.title, sortId: info.title, language: Utils.getLanguage())])
            UserDefaults.standard.set(notificationData, forKey: "pushNotificationList")
        }
        if let topController = UIApplication.topViewController() {
            print(topController)
            if topController is HomeViewController {
                (topController as! HomeViewController).updateNotificationBadge()
            } else if topController is MuseumsViewController {
                (topController as! MuseumsViewController).updateNotificationBadge()
            } else if topController is NotificationsViewController {
                (topController as! NotificationsViewController).updateNotificationTableView()
            }
        }
        //        completionHandler([.alert, .badge, .sound])
    }
    
    //MARK: WebServiceCall
    func sendDeviceTokenToServer(deviceToken: String) {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetToken(["name":"","pass":""])).responseObject { (response: DataResponse<TokenData>) -> Void in
            switch response.result {
            case .success(let data):
                _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.SendDeviceToken(data.accessToken!, ["token": deviceToken, "type":"ios"])).responseObject { (response: DataResponse<DeviceToken>) -> Void in
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
        let container = CoreDataManager.shared.persistentContainer
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = CoreDataManager.shared.managedObjectContext
        return managedObjectContext
    }()
    
    
    //MARK: HeritageList WebServiceCall
    func getHeritageDataFromServer(lang: String?) {
        let queue = DispatchQueue(label: "HeritageThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.HeritageList(lang!)).responseObject(queue: queue) { (response: DataResponse<Heritages>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.heritage != nil) {
                    if((data.heritage?.count)! > 0) {
                        DispatchQueue.main.async{
                            self.saveOrUpdateHeritageCoredata(heritageListArray: data.heritage, lang: lang)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateHeritageCoredata(heritageListArray: [Heritage]?,lang: String?) {
        if ((heritageListArray?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext, heritageListArray: heritageListArray, lang: lang)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext, heritageListArray: heritageListArray, lang: lang)
                }
            }
        }
    }
    
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext,heritageListArray: [Heritage]?,lang: String?) {
        var fetchData = [HeritageEntity]()
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            fetchData = DataManager.checkAddedToCoredata(entityName: "HeritageEntity",
                                                         idKey: "lang",
                                                         idValue: "1",
                                                         managedContext: managedContext) as! [HeritageEntity]
        } else {
            fetchData = DataManager.checkAddedToCoredata(entityName: "HeritageEntity",
                                                         idKey: "lang",
                                                         idValue: "0",
                                                         managedContext: managedContext) as! [HeritageEntity]
        }
            if (fetchData.count > 0) {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict = heritageListArray![i]
                    let fetchResult = DataManager.checkAddedToCoredata(entityName: "HeritageEntity",
                                                                       idKey: "listid",
                                                                       idValue: heritageListArray![i].id,
                                                                       managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let heritagedbDict = fetchResult[0] as! HeritageEntity
                        heritagedbDict.listname = heritageListDict.name
                        heritagedbDict.listimage = heritageListDict.image
                        heritagedbDict.listsortid =  heritageListDict.sortid
                        if (lang == ENG_LANGUAGE) {
                            heritagedbDict.lang =  "1"
                        } else {
                            heritagedbDict.lang =  "0"
                        }
                        
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveHeritageListToCoreData(heritageListDict: heritageListDict, managedObjContext: managedContext, lang: lang)
                        
                    }
                }
                if(lang == ENG_LANGUAGE) {
                    NotificationCenter.default.post(name: NSNotification.Name(heritageListNotificationEn), object: self)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(heritageListNotificationAr), object: self)
                }
                
            } else {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict : Heritage?
                    heritageListDict = heritageListArray?[i]
                    self.saveHeritageListToCoreData(heritageListDict: heritageListDict!, managedObjContext: managedContext, lang: lang)
                }
                if(lang == ENG_LANGUAGE) {
                    NotificationCenter.default.post(name: NSNotification.Name(heritageListNotificationEn), object: self)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(heritageListNotificationAr), object: self)
                }
        }
    }
    
    func saveHeritageListToCoreData(heritageListDict: Heritage, managedObjContext: NSManagedObjectContext,lang: String?) {
            let heritageInfo: HeritageEntity = NSEntityDescription.insertNewObject(forEntityName: "HeritageEntity", into: managedObjContext) as! HeritageEntity
            heritageInfo.listid = heritageListDict.id
            heritageInfo.listname = heritageListDict.name
            
            heritageInfo.listimage = heritageListDict.image
        if (lang == ENG_LANGUAGE) {
            heritageInfo.lang =  "1"
        } else {
            heritageInfo.lang =  "0"
        }
            if(heritageListDict.sortid != nil) {
                heritageInfo.listsortid = heritageListDict.sortid
            }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    //MARK: Exhibitions Service call
    func getExhibitionDataFromServer(lang: String?) {
        let queue = DispatchQueue(label: "ExhibitionThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.ExhibitionList(lang!)).responseObject(queue: queue) { (response: DataResponse<Exhibitions>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.exhibitions != nil) {
                    if((data.exhibitions?.count)! > 0) {
                        self.saveOrUpdateExhibitionsCoredata(exhibition: data.exhibitions, lang: lang)
                    }
                }
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Exhibitions Coredata Method
    func saveOrUpdateExhibitionsCoredata(exhibition: [Exhibition]?,lang: String?) {
        if ((exhibition?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.exhibitionCoreDataInBackgroundThread(managedContext: managedContext, exhibition: exhibition, lang: lang)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    self.exhibitionCoreDataInBackgroundThread(managedContext : managedContext, exhibition: exhibition, lang: lang)
                }
            }
        }
    }
    
    func exhibitionCoreDataInBackgroundThread(managedContext: NSManagedObjectContext,exhibition: [Exhibition]?,lang: String?) {
        var fetchData = [ExhibitionsEntity]()
        var langVar : String? = nil
        if (lang == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
             fetchData = DataManager.checkAddedToCoredata(entityName: "ExhibitionsEntity",
                                                          idKey: "lang",
                                                          idValue: langVar,
                                                          managedContext: managedContext) as! [ExhibitionsEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (exhibition?.count)!-1 {
                    let exhibitionsListDict = exhibition![i]
                    let fetchResult = DataManager.checkAddedToCoredata(entityName: "ExhibitionsEntity",
                                                                       idKey: "id",
                                                                       idValue: exhibition![i].id,
                                                                       managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let exhibitionsdbDict = fetchResult[0] as! ExhibitionsEntity
                        exhibitionsdbDict.name = exhibitionsListDict.name
                        exhibitionsdbDict.image = exhibitionsListDict.image
                        exhibitionsdbDict.startDate =  exhibitionsListDict.startDate
                        exhibitionsdbDict.endDate = exhibitionsListDict.endDate
                        exhibitionsdbDict.location =  exhibitionsListDict.location
                        exhibitionsdbDict.museumId = exhibitionsListDict.museumId
                        exhibitionsdbDict.status = exhibitionsListDict.status
                        exhibitionsdbDict.isHomeExhibition = "1"
                        exhibitionsdbDict.lang = langVar
                        do {
                            try managedContext.save()
                        }
                        catch {
                            print(error)
                        }
                    } else {
                        //save
                        self.saveExhibitionListToCoreData(exhibitionDict: exhibitionsListDict, managedObjContext: managedContext, lang: lang)
                    }
                }//for
                NotificationCenter.default.post(name: NSNotification.Name(exhibitionsListNotificationEn), object: self)
            } else {
                for i in 0 ... (exhibition?.count)!-1 {
                    let exhibitionListDict : Exhibition?
                    exhibitionListDict = exhibition?[i]
                    self.saveExhibitionListToCoreData(exhibitionDict: exhibitionListDict!, managedObjContext: managedContext, lang: lang)
                }
                NotificationCenter.default.post(name: NSNotification.Name(exhibitionsListNotificationEn), object: self)
            }
    }
    
    func saveExhibitionListToCoreData(exhibitionDict: Exhibition, managedObjContext: NSManagedObjectContext,lang: String?) {
        var langVar : String? = nil
        if (lang == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
            let exhibitionInfo: ExhibitionsEntity = NSEntityDescription.insertNewObject(forEntityName: "ExhibitionsEntity", into: managedObjContext) as! ExhibitionsEntity
            
            exhibitionInfo.id = exhibitionDict.id
            exhibitionInfo.name = exhibitionDict.name
            exhibitionInfo.image = exhibitionDict.image
            exhibitionInfo.startDate =  exhibitionDict.startDate
            exhibitionInfo.endDate = exhibitionDict.endDate
            exhibitionInfo.location =  exhibitionDict.location
            exhibitionInfo.museumId =  exhibitionDict.museumId
            exhibitionInfo.status =  exhibitionDict.status
            exhibitionInfo.isHomeExhibition = "1"
            exhibitionInfo.lang = langVar
        do {
            try managedObjContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    //MARK: Home Service call
    func getHomeList(lang: String?) {
        let queue = DispatchQueue(label: "HomeThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.HomeList(lang!)).responseObject(queue:queue) { (response: DataResponse<HomeList>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.homeList != nil) {
                    if((data.homeList?.count)! > 0) {
                        DispatchQueue.main.async{
                            self.saveOrUpdateHomeCoredata(homeList: data.homeList, lang: lang)
                        }
                    }
                }
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Home Coredata Method
    func saveOrUpdateHomeCoredata(homeList: [Home]?,lang: String?) {
        if ((homeList?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.homeCoreDataInBackgroundThread(managedContext: managedContext, homeList: homeList, lang: lang)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    self.homeCoreDataInBackgroundThread(managedContext : managedContext, homeList: homeList, lang: lang)
                }
            }
        }
    }
    
    func homeCoreDataInBackgroundThread(managedContext: NSManagedObjectContext, homeList: [Home]?,lang: String?) {
        var fetchData = [HomeEntity]()
        var langVar : String? = nil
        if (lang == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
        fetchData = DataManager.checkAddedToCoredata(entityName: "HomeEntity",
                                                     idKey: "lang",
                                                     idValue: langVar,
                                                     managedContext: managedContext) as! [HomeEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (homeList?.count)!-1 {
                    let homeListDict = homeList![i]
                    let fetchResult = DataManager.checkAddedToCoredata(entityName: "HomeEntity",
                                                                       idKey: "id",
                                                                       idValue: homeList![i].id,
                                                                       managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let homedbDict = fetchResult[0] as! HomeEntity
                        homedbDict.name = homeListDict.name
                        homedbDict.image = homeListDict.image
                        homedbDict.sortid =  (Int16(homeListDict.sortId!) ?? 0)
                        homedbDict.tourguideavailable = homeListDict.isTourguideAvailable
                        homedbDict.lang = langVar
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveHomeDataToCoreData(homeListDict: homeListDict, managedObjContext: managedContext, lang: lang)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(homepageNotificationEn), object: self)
            } else {
                for i in 0 ... (homeList?.count)!-1 {
                    let homeListDict : Home?
                    homeListDict = homeList?[i]
                    self.saveHomeDataToCoreData(homeListDict: homeListDict!, managedObjContext: managedContext, lang: lang)
                }
                NotificationCenter.default.post(name: NSNotification.Name(homepageNotificationEn), object: self)
            }
    }
    
    func saveHomeDataToCoreData(homeListDict: Home, managedObjContext: NSManagedObjectContext,lang: String?) {
        var langVar : String? = nil
        if (lang == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
            let homeInfo: HomeEntity = NSEntityDescription.insertNewObject(forEntityName: "HomeEntity", into: managedObjContext) as! HomeEntity
            homeInfo.id = homeListDict.id
            homeInfo.name = homeListDict.name
            homeInfo.image = homeListDict.image
            homeInfo.tourguideavailable = homeListDict.isTourguideAvailable
            homeInfo.image = homeListDict.image
            homeInfo.sortid = (Int16(homeListDict.sortId!) ?? 0)
            homeInfo.lang = langVar
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    //MARK: MIA TourGuide WebServiceCall
    func getMiaTourGuideDataFromServer(museumId:String?,lang:String?) {
        let queue = DispatchQueue(label: "MiaTourThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.MuseumTourGuide(lang!,["museum_id": museumId!])).responseObject(queue:queue) { (response: DataResponse<TourGuides>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.tourGuide != nil) {
                    if((data.tourGuide?.count)! > 0) {
                        DispatchQueue.main.async{
                            self.saveOrUpdateTourGuideCoredata(miaTourDataFullArray: data.tourGuide, museumId: museumId, lang: lang)
                        }
                    }
                }
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateTourGuideCoredata(miaTourDataFullArray:[TourGuide]?,museumId: String?,lang:String?) {
        if ((miaTourDataFullArray?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    if let array = miaTourDataFullArray {
                        DataManager.updateTourGuide(managedContext: managedContext,
                                                    miaTourDataFullArray: array,
                                                    museumID: museumId)
                    }
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    if let array = miaTourDataFullArray {
                        DataManager.updateTourGuide(managedContext: managedContext,
                                                    miaTourDataFullArray: array,
                                                    museumID: museumId)
                    }
                }
            }
        }
    }
    
    
    //MARK: NMoQ ABoutEvent Webservice
    func getNmoQAboutDetailsFromServer(museumId:String?,lang: String?) {
        let queue = DispatchQueue(label: "NmoQAboutThread", qos: .background, attributes: .concurrent)
        if(museumId != nil) {
            
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQAboutEvent(lang!,["nid": museumId!])).responseObject(queue: queue) { (response: DataResponse<Museums>) -> Void in
                switch response.result {
                case .success(let data):
                    if(data.museum != nil) {
                        if((data.museum?.count)! > 0) {
                            DispatchQueue.main.async{
                                self.saveOrUpdateAboutCoredata(aboutDetailtArray: data.museum, lang: lang)
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
    func saveOrUpdateAboutCoredata(aboutDetailtArray:[Museum]?, lang: String?) {
        if ((aboutDetailtArray?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() { managedContext in
                    DataManager.saveAboutDetails(managedContext: managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: false)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    DataManager.saveAboutDetails(managedContext: managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: false)
                }
            }
        }
    }
    
   
    //MARK: NMoQ Tour ListService call
    func getNMoQTourList(lang: String?) {
        let queue = DispatchQueue(label: "NMoQTourListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQTourList(lang!)).responseObject(queue:queue) { (response: DataResponse<NMoQTourList>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.nmoqTourList != nil) {
                    if let nmoqTourList = data.nmoqTourList {
                        DispatchQueue.main.async{
                            self.saveOrUpdateTourListCoredata(nmoqTourList: nmoqTourList,
                                                              isTourGuide: true)
                        }
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    
    //MARK: Tour List Coredata Method
    func saveOrUpdateTourListCoredata(nmoqTourList: [NMoQTour], isTourGuide:Bool) {
        if !nmoqTourList.isEmpty {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateTourList(nmoqTourList: nmoqTourList,
                                               managedContext: managedContext,
                                               isTourGuide: isTourGuide)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    DataManager.updateTourList(nmoqTourList: nmoqTourList,
                                               managedContext: managedContext,
                                               isTourGuide: isTourGuide)
                }
            }
        }
    }
    
    
    //MARK: NMoQ TravelList Service Call
    func getTravelList(lang: String?) {
        let queue = DispatchQueue(label: "NMoQTravelListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQTravelList(lang!)).responseObject(queue:queue) { (response: DataResponse<HomeBannerList>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.homeBannerList != nil) {
                    if let homeBannerList = data.homeBannerList {
                        self.saveOrUpdateTravelListCoredata(travelList: homeBannerList)
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Travel List Coredata
    func saveOrUpdateTravelListCoredata(travelList: [HomeBanner]) {
        if travelList.count > 0 {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateTravelList(travelList: travelList,
                                                 managedContext : managedContext)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    DataManager.updateTravelList(travelList: travelList,
                                                 managedContext : managedContext)
                }
            }
        }
    }
    
    //MARK: NMoQSpecialEvent Lst APi
    func getNMoQSpecialEventList(lang:String?) {
        let queue = DispatchQueue(label: "NMoQSpecialEventListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQSpecialEventList(lang!)).responseObject(queue:queue) { (response: DataResponse<NMoQActivitiesListData>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.nmoqActivitiesList != nil) {
                    if((data.nmoqActivitiesList?.count)! > 0) {
                        self.saveOrUpdateActivityListCoredata(nmoqActivityList: data.nmoqActivitiesList, lang:lang )
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: ActivityList Coredata Method
    func saveOrUpdateActivityListCoredata(nmoqActivityList:[NMoQActivitiesList]?,lang: String?) {
        if ((nmoqActivityList?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.activityListCoreDataInBackgroundThread(nmoqActivityList: nmoqActivityList, managedContext: managedContext, lang: lang)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    self.activityListCoreDataInBackgroundThread(nmoqActivityList: nmoqActivityList, managedContext : managedContext, lang: lang)
                }
            }
        }
    }
    
    func activityListCoreDataInBackgroundThread(nmoqActivityList:[NMoQActivitiesList]?,
                                                managedContext: NSManagedObjectContext,
                                                lang: String?) {
            let fetchData = DataManager.checkAddedToCoredata(entityName: "NMoQActivitiesEntity",
                                                 idKey: "nid",
                                                 idValue: nil,
                                                 managedContext: managedContext) as! [NMoQActivitiesEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqActivityList?.count)!-1 {
                    let nmoqActivityListDict = nmoqActivityList![i]
                    let fetchResult = DataManager.checkAddedToCoredata(entityName: "NMoQActivitiesEntity", idKey: "nid", idValue: nmoqActivityListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let activityListdbDict = fetchResult[0] as! NMoQActivitiesEntity
                        activityListdbDict.title = nmoqActivityListDict.title
                        activityListdbDict.dayDescription = nmoqActivityListDict.dayDescription
                        activityListdbDict.subtitle =  nmoqActivityListDict.subtitle
                        activityListdbDict.sortId = nmoqActivityListDict.sortId
                        activityListdbDict.nid =  nmoqActivityListDict.nid
                        activityListdbDict.eventDate = nmoqActivityListDict.eventDate
                        //eventlist
                        activityListdbDict.date = nmoqActivityListDict.date
                        activityListdbDict.descriptioForModerator = nmoqActivityListDict.descriptioForModerator
                        activityListdbDict.mobileLatitude = nmoqActivityListDict.mobileLatitude
                        activityListdbDict.moderatorName = nmoqActivityListDict.moderatorName
                        activityListdbDict.longitude = nmoqActivityListDict.longitude
                        activityListdbDict.contactEmail = nmoqActivityListDict.contactEmail
                        activityListdbDict.contactPhone = nmoqActivityListDict.contactPhone
                        activityListdbDict.language = Utils.getLanguage()
                        
                        
                        if(nmoqActivityListDict.images != nil){
                            if((nmoqActivityListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqActivityListDict.images?.count)!-1 {
                                    var activityImage: ImageEntity!
                                    let activityImgaeArray = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: managedContext) as! ImageEntity
                                    activityImgaeArray.image = nmoqActivityListDict.images![i]
                                    activityImgaeArray.language = Utils.getLanguage()
                                    activityImage = activityImgaeArray
                                    activityListdbDict.addToActivityImgRelation(activityImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveActivityListToCoreData(activityListDict: nmoqActivityListDict, managedObjContext: managedContext, lang: lang)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqActivityListNotificationEn), object: self)
            } else {
                for i in 0 ... (nmoqActivityList?.count)!-1 {
                    let activitiesListDict : NMoQActivitiesList?
                    activitiesListDict = nmoqActivityList?[i]
                    self.saveActivityListToCoreData(activityListDict: activitiesListDict!, managedObjContext: managedContext, lang: lang)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqActivityListNotificationEn), object: self)
            }
    }
    
    func saveActivityListToCoreData(activityListDict: NMoQActivitiesList, managedObjContext: NSManagedObjectContext,lang:String?) {
            let activityListdbDict: NMoQActivitiesEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQActivitiesEntity", into: managedObjContext) as! NMoQActivitiesEntity
            activityListdbDict.title = activityListDict.title
            activityListdbDict.dayDescription = activityListDict.dayDescription
            activityListdbDict.subtitle =  activityListDict.subtitle
            activityListdbDict.sortId = activityListDict.sortId
            activityListdbDict.nid =  activityListDict.nid
            activityListdbDict.eventDate = activityListDict.eventDate
            //eventlist
            activityListdbDict.date = activityListDict.date
            activityListdbDict.descriptioForModerator = activityListDict.descriptioForModerator
            activityListdbDict.mobileLatitude = activityListDict.mobileLatitude
            activityListdbDict.moderatorName = activityListDict.moderatorName
            activityListdbDict.longitude = activityListDict.longitude
            activityListdbDict.contactEmail = activityListDict.contactEmail
            activityListdbDict.contactPhone = activityListDict.contactPhone
        activityListdbDict.language = Utils.getLanguage()
            
            
            if(activityListDict.images != nil){
                if((activityListDict.images?.count)! > 0) {
                    for i in 0 ... (activityListDict.images?.count)!-1 {
                        var activityImage: ImageEntity!
                        let activityImgaeArray = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: managedObjContext) as! ImageEntity
                        activityImgaeArray.image = activityListDict.images![i]
                        activityImgaeArray.language = Utils.getLanguage()
                        activityImage = activityImgaeArray
                        activityListdbDict.addToActivityImgRelation(activityImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    //MARK: DiningList WebServiceCall
    func getDiningListFromServer(lang: String?)
    {
        let queue = DispatchQueue(label: "DiningListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.DiningList(lang!)).responseObject(queue: queue) { (response: DataResponse<Dinings>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.dinings != nil) {
                    if((data.dinings?.count)! > 0) {
                        self.saveOrUpdateDiningCoredata(diningListArray: data.dinings, lang: lang)
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Dining Coredata Method
    func saveOrUpdateDiningCoredata(diningListArray : [Dining]?,lang: String?) {
        if ((diningListArray?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateDinings(managedContext: managedContext,
                                              diningListArray: diningListArray!)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    DataManager.updateDinings(managedContext: managedContext,
                                              diningListArray: diningListArray!)
                }
            }
        }
    }
    
    //MARK: PublicArtsList WebServiceCall
    func getPublicArtsListDataFromServer(lang: String?) {
        let queue = DispatchQueue(label: "PublicArtsListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.PublicArtsList(lang!)).responseObject(queue: queue) { (response: DataResponse<PublicArtsLists>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.publicArtsList != nil) {
                    if((data.publicArtsList?.count)! > 0) {
                        self.saveOrUpdatePublicArtsCoredata(publicArtsListArray: data.publicArtsList, lang: lang)
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: PublicArtsList Coredata Method
    func saveOrUpdatePublicArtsCoredata(publicArtsListArray:[PublicArtsList]?,lang: String?) {
        if ((publicArtsListArray?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updatePublicArts(managedContext : managedContext,
                                                 publicArtsListArray: publicArtsListArray)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    DataManager.updatePublicArts(managedContext : managedContext,
                                                 publicArtsListArray: publicArtsListArray)
                }
            }
        }
    }
    
    
    //MARK: Webservice call
    func getCollectionList(museumId:String?,lang: String?) {
        let queue = DispatchQueue(label: "CollectionListThread", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.CollectionList(lang!,["museum_id": museumId ?? 0])).responseObject(queue: queue) { (response: DataResponse<Collections>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.collections != nil) {
                    if((data.collections?.count)! > 0) {
                        self.saveOrUpdateCollectionCoredata(collection: data.collections, museumId: museumId, lang: lang)
                    }
                }
                
                
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateCollectionCoredata(collection: [Collection]?,museumId:String?,lang: String?) {
        if ((collection?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.collectionsListCoreDataInBackgroundThread(managedContext: managedContext, collection: collection!, museumId: museumId, lang: lang)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    self.collectionsListCoreDataInBackgroundThread(managedContext : managedContext, collection: collection!, museumId: museumId, lang: lang)
                }
            }
        }
    }
    
    func collectionsListCoreDataInBackgroundThread(managedContext: NSManagedObjectContext,collection: [Collection]?,museumId:String?,lang: String?) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "CollectionsEntity", idKey: "museumId", idValue: nil, managedContext: managedContext) as! [CollectionsEntity]
            if (fetchData.count > 0) {
                let isDeleted = DataManager.delete(managedContext: managedContext,
                                                                entityName: "CollectionsEntity")
                if(isDeleted == true) {
                    for i in 0 ... (collection?.count)!-1 {
                        let collectionListDict : Collection?
                        collectionListDict = collection?[i]
                        self.saveCollectionListToCoreData(collectionListDict: collectionListDict!, managedObjContext: managedContext, lang: lang)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(collectionsListNotificationEn), object: self)
            }
            else {
                for i in 0 ... (collection?.count)!-1 {
                    let collectionListDict : Collection?
                    collectionListDict = collection?[i]
                    self.saveCollectionListToCoreData(collectionListDict: collectionListDict!, managedObjContext: managedContext, lang: lang)
                }
                NotificationCenter.default.post(name: NSNotification.Name(collectionsListNotificationEn), object: self)
            }
    }
    
    func saveCollectionListToCoreData(collectionListDict: Collection, managedObjContext: NSManagedObjectContext,lang: String?) {
        var langVar : String? = nil
        if (lang == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
            let collectionInfo: CollectionsEntity = NSEntityDescription.insertNewObject(forEntityName: "CollectionsEntity", into: managedObjContext) as! CollectionsEntity
            collectionInfo.listName = collectionListDict.name?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
            collectionInfo.listImage = collectionListDict.image
            collectionInfo.museumId = collectionListDict.museumId
            collectionInfo.lang = langVar
       
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getParksDataFromServer(lang:String?) {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.ParksList(lang ?? ENG_LANGUAGE)).responseObject { (response: DataResponse<ParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                if let parkList = data.parkList {
                    self.saveOrUpdateParksCoredata(parksListArray: parkList)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: Coredata Method
    func saveOrUpdateParksCoredata(parksListArray:[ParksList]) {
        if parksListArray.count > 0 {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateParks(managedContext : managedContext,
                                            parksListArray: parksListArray)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateParks(managedContext : managedContext,
                                            parksListArray: parksListArray)
                }
            }
        }
    }
    
    func getFacilitiesListFromServer(lang:String?)
    {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.FacilitiesList(lang ?? ENG_LANGUAGE)).responseObject { (response: DataResponse<FacilitiesData>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.facilitiesList != nil) {
                    if((data.facilitiesList?.count)! > 0) {
                        self.saveOrUpdateFacilitiesListCoredata(facilitiesList: data.facilitiesList, lang: lang)
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Facilities List Coredata Method
    func saveOrUpdateFacilitiesListCoredata(facilitiesList:[Facilities]?,lang:String?) {
        if ((facilitiesList?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.facilitiesListCoreDataInBackgroundThread(facilitiesList: facilitiesList, managedContext: managedContext, lang: lang)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.facilitiesListCoreDataInBackgroundThread(facilitiesList: facilitiesList, managedContext : managedContext, lang: lang)
                }
            }
        }
    }
    func facilitiesListCoreDataInBackgroundThread(facilitiesList:[Facilities]?,
                                                  managedContext: NSManagedObjectContext,lang:String?) {
//        if (lang == ENG_LANGUAGE) {
            let fetchData = DataManager.checkAddedToCoredata(entityName: "FacilitiesEntity",
                                                 idKey: "nid",
                                                 idValue: nil,
                                                 managedContext: managedContext) as! [FacilitiesEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (facilitiesList?.count)!-1 {
                    let facilitiesListDict = facilitiesList![i]
                    let fetchResult = DataManager.checkAddedToCoredata(entityName: "FacilitiesEntity",
                                                           idKey: "nid",
                                                           idValue: facilitiesListDict.nid,
                                                           managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let facilitiesListdbDict = fetchResult[0] as! FacilitiesEntity
                        facilitiesListdbDict.title = facilitiesListDict.title
                        facilitiesListdbDict.sortId = facilitiesListDict.sortId
                        facilitiesListdbDict.nid =  facilitiesListDict.nid
                        facilitiesListdbDict.language = Utils.getLanguage()
                        
                        if(facilitiesListDict.images != nil){
                            if((facilitiesListDict.images?.count)! > 0) {
                                for i in 0 ... (facilitiesListDict.images?.count)!-1 {
                                    var facilitiesImage: ImageEntity!
                                    let facilitiesImgaeArray = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: managedContext) as! ImageEntity
                                    facilitiesImgaeArray.image = facilitiesListDict.images![i]
                                    
                                    facilitiesImage = facilitiesImgaeArray
                                    facilitiesListdbDict.addToFacilitiesImgRelation(facilitiesImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveFacilitiesListToCoreData(facilitiesListDict: facilitiesListDict,
                                                          managedObjContext: managedContext,
                                                          lang: lang)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationEn),
                                                object: self)
            } else {
                for i in 0 ... (facilitiesList?.count)!-1 {
                    let facilitiesListDict : Facilities?
                    facilitiesListDict = facilitiesList?[i]
                    self.saveFacilitiesListToCoreData(facilitiesListDict: facilitiesListDict!,
                                                      managedObjContext: managedContext,
                                                      lang: lang)
                }
                NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationEn), object: self)
            }

    }
    func saveFacilitiesListToCoreData(facilitiesListDict: Facilities,
                                      managedObjContext: NSManagedObjectContext,lang:String?) {
//        if (lang == ENG_LANGUAGE) {
            let facilitiesListInfo: FacilitiesEntity = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesEntity", into: managedObjContext) as! FacilitiesEntity
            facilitiesListInfo.title = facilitiesListDict.title
            facilitiesListInfo.sortId = facilitiesListDict.sortId
            facilitiesListInfo.nid = facilitiesListDict.nid
        facilitiesListInfo.language = Utils.getLanguage()
        
            if(facilitiesListDict.images != nil){
                if((facilitiesListDict.images?.count)! > 0) {
                    for i in 0 ... (facilitiesListDict.images?.count)!-1 {
                        var facilitiesImage: ImageEntity!
                        let facilitiesImgaeArray = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: managedObjContext) as! ImageEntity
                        facilitiesImgaeArray.image = facilitiesListDict.images![i]
                        
                        facilitiesImage = facilitiesImgaeArray
                        facilitiesListInfo.addToFacilitiesImgRelation(facilitiesImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }

        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getNmoqParkListFromServer(lang:String?) {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNmoqParkList(lang ?? ENG_LANGUAGE)).responseObject { (response: DataResponse<NmoqParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.nmoqParkList != nil) {
                    if((data.nmoqParkList?.count)! > 0) {
                        self.saveOrUpdateNmoqParkListCoredata(nmoqParkList: data.nmoqParkList, lang: lang)
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    
    //MARK: NmoqPark List Coredata Method
    func saveOrUpdateNmoqParkListCoredata(nmoqParkList:[NMoQParksList]?,lang:String?) {
        if ((nmoqParkList?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.nmoqParkListCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext: managedContext, lang: lang)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.nmoqParkListCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext : managedContext, lang: lang)
                }
            }
        }
    }
    
    func nmoqParkListCoreDataInBackgroundThread(nmoqParkList:[NMoQParksList]?,
                                                managedContext: NSManagedObjectContext,
                                                lang:String?) {
            let fetchData = DataManager.checkAddedToCoredata(entityName: "NMoQParkListEntity",
                                                 idKey: "nid",
                                                 idValue: nil,
                                                 managedContext: managedContext) as! [NMoQParkListEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = DataManager.checkAddedToCoredata(entityName: "NMoQParkListEntity",
                                                           idKey: "nid",
                                                           idValue: nmoqParkListDict.nid,
                                                           managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParkListEntity
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.parkTitle = nmoqParkListDict.parkTitle
                        nmoqParkListdbDict.mainDescription = nmoqParkListDict.mainDescription
                        nmoqParkListdbDict.parkDescription =  nmoqParkListDict.parkDescription
                        nmoqParkListdbDict.hoursTitle = nmoqParkListDict.hoursTitle
                        nmoqParkListdbDict.hoursDesc = nmoqParkListDict.hoursDesc
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.longitude = nmoqParkListDict.longitude
                        nmoqParkListdbDict.latitude = nmoqParkListDict.latitude
                        nmoqParkListdbDict.locationTitle =  nmoqParkListDict.locationTitle
                        nmoqParkListdbDict.language = Utils.getLanguage()
                        
                        
                        //                        if(facilitiesListDict.images != nil){
                        //                            if((facilitiesListDict.images?.count)! > 0) {
                        //                                for i in 0 ... (facilitiesListDict.images?.count)!-1 {
                        //                                    var facilitiesImage: FacilitiesImgEntity!
                        //                                    let facilitiesImgaeArray: FacilitiesImgEntity = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesImgEntity", into: managedContext) as! FacilitiesImgEntity
                        //                                    facilitiesImgaeArray.images = facilitiesListDict.images![i]
                        //
                        //                                    facilitiesImage = facilitiesImgaeArray
                        //                                    facilitiesListdbDict.addToFacilitiesImgRelation(facilitiesImage)
                        //                                    do {
                        //                                        try managedContext.save()
                        //                                    } catch let error as NSError {
                        //                                        print("Could not save. \(error), \(error.userInfo)")
                        //                                    }
                        //                                }
                        //                            }
                        //                        }
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveNmoqParkListToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext, lang: lang)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkListNotificationEn), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQParksList?
                    nmoqParkListDict = nmoqParkList?[i]
                    self.saveNmoqParkListToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext, lang: lang)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkListNotificationEn), object: self)
            }
    }
    
    func saveNmoqParkListToCoreData(nmoqParkListDict: NMoQParksList, managedObjContext: NSManagedObjectContext,lang:String?) {
            let nmoqParkListdbDict: NMoQParkListEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkListEntity", into: managedObjContext) as! NMoQParkListEntity
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.parkTitle = nmoqParkListDict.parkTitle
            nmoqParkListdbDict.mainDescription = nmoqParkListDict.mainDescription
            nmoqParkListdbDict.parkDescription =  nmoqParkListDict.parkDescription
            nmoqParkListdbDict.hoursTitle = nmoqParkListDict.hoursTitle
            nmoqParkListdbDict.hoursDesc = nmoqParkListDict.hoursDesc
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.longitude = nmoqParkListDict.longitude
            nmoqParkListdbDict.latitude = nmoqParkListDict.latitude
            nmoqParkListdbDict.locationTitle =  nmoqParkListDict.locationTitle
            nmoqParkListdbDict.language = Utils.getLanguage()
            
            
            //            if(facilitiesListDict.images != nil){
            //                if((facilitiesListDict.images?.count)! > 0) {
            //                    for i in 0 ... (facilitiesListDict.images?.count)!-1 {
            //                        var facilitiesImage: FacilitiesImgEntity!
            //                        let facilitiesImgaeArray: FacilitiesImgEntity = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesImgEntity", into: managedObjContext) as! FacilitiesImgEntity
            //                        facilitiesImgaeArray.images = facilitiesListDict.images![i]
            //
            //                        facilitiesImage = facilitiesImgaeArray
            //                        facilitiesListInfo.addToFacilitiesImgRelation(facilitiesImage)
            //                        do {
            //                            try managedObjContext.save()
            //                        } catch let error as NSError {
            //                            print("Could not save. \(error), \(error.userInfo)")
            //                        }
            //                    }
            //                }
            //            }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getNmoqListOfParksFromServer(lang:String?) {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNmoqListParks(lang ?? ENG_LANGUAGE)).responseObject { (response: DataResponse<NMoQParks>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.nmoqParks != nil) {
                    if((data.nmoqParks?.count)! > 0) {
                        self.saveOrUpdateNmoqParksCoredata(nmoqParkList: data.nmoqParks, lang: lang)
                    }
                }
                
            case .failure( _):
                print("error")
            }
        }
    }
    
    //MARK: NMoq List of Parks Coredata Method
    func saveOrUpdateNmoqParksCoredata(nmoqParkList:[NMoQPark]?, lang:String?) {
        if ((nmoqParkList?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = CoreDataManager.shared.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.nmoqParkCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext: managedContext, lang: lang)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.nmoqParkCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext : managedContext, lang: lang)
                }
            }
        }
    }
    
    func nmoqParkCoreDataInBackgroundThread(nmoqParkList: [NMoQPark]?, managedContext: NSManagedObjectContext, lang:String?) {
            let fetchData = DataManager.checkAddedToCoredata(entityName: "NMoQParksEntity",
                                                             idKey: "nid",
                                                             idValue: nil,
                                                             managedContext: managedContext) as! [NMoQParksEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = DataManager.checkAddedToCoredata(entityName: "NMoQParksEntity",
                                                                       idKey: "nid",
                                                                       idValue: nmoqParkListDict.nid,
                                                                       managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParksEntity
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
                        nmoqParkListdbDict.language = Utils.getLanguage()
                        
                        if(nmoqParkListDict.images != nil){
                            if((nmoqParkListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                                    var parkListImage: ImageEntity!
                                    let parkListImageArray = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: managedContext) as! ImageEntity
                                    parkListImageArray.image = nmoqParkListDict.images![i]
                                    parkListImageArray.language = Utils.getLanguage()
                                    parkListImage = parkListImageArray
                                    nmoqParkListdbDict.addToParkImgRelation(parkListImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveNmoqParkToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext, lang: lang)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationEn), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQPark?
                    nmoqParkListDict = nmoqParkList?[i]
                    self.saveNmoqParkToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext, lang: lang)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationEn), object: self)
            }
    }
    
    func saveNmoqParkToCoreData(nmoqParkListDict: NMoQPark, managedObjContext: NSManagedObjectContext, lang:String?) {
            let nmoqParkListdbDict: NMoQParksEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParksEntity", into: managedObjContext) as! NMoQParksEntity
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
        nmoqParkListdbDict.language = Utils.getLanguage()
            
            if(nmoqParkListDict.images != nil){
                if((nmoqParkListDict.images?.count)! > 0) {
                    for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                        var parkListImage: ImageEntity!
                        let parkListImageArray = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: managedObjContext) as! ImageEntity
                        parkListImageArray.image = nmoqParkListDict.images![i]
                        parkListImageArray.language = Utils.getLanguage()
                        parkListImage = parkListImageArray
                        nmoqParkListdbDict.addToParkImgRelation(parkListImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
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

