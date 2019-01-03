//
//  AppDelegate.swift
//  QatarMuseum
//
//  Created by Exalture on 06/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import CoreData
import Firebase
import GoogleMaps
import GooglePlaces
import UIKit
import UserNotifications
import Alamofire
var tokenValue : String? = nil

var languageKey = 1

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var shouldRotate = false
    let networkReachability = NetworkReachabilityManager()
    var tourGuideId : String? = ""
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       // GMSServices.provideAPIKey("AIzaSyBXEzUfmsi5BidKqR1eY999pj0APP2N0k0")
        GMSServices.provideAPIKey("AIzaSyAbuv0Gx0vwyZdr90LFKeUFmMesorNZHKQ") // QM key
         GMSPlacesClient.provideAPIKey("AIzaSyAbuv0Gx0vwyZdr90LFKeUFmMesorNZHKQ")
        self.apiCalls()
        
           
        
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
            self.getHeritageDataFromServer()
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                self.getFloorMapDataFromServer(tourGuideId: "12471") // for explore and highlight tour English
                self.getFloorMapDataFromServer(tourGuideId: "12216") // for science tour English
            } else {
                self.getFloorMapDataFromServer(tourGuideId: "12916") //for explore and highlight tour Arabic
                self.getFloorMapDataFromServer(tourGuideId: "12226") // for science tour Arabic
            }
            
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
            notificationArray.insert(Notification(title: info.title, sortId: info.title), at: 0)
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: notificationArray)
            UserDefaults.standard.set(notificationData, forKey: "pushNotificationList")
        } else {
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: [Notification(title: info.title, sortId: info.title)])
            UserDefaults.standard.set(notificationData, forKey: "pushNotificationList")
        }
        
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
            notificationArray.insert(Notification(title: info.title, sortId: info.title), at: 0)
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: notificationArray)
            UserDefaults.standard.set(notificationData, forKey: "pushNotificationList")
        } else {
            let notificationData = NSKeyedArchiver.archivedData(withRootObject: [Notification(title: info.title, sortId: info.title)])
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
        _ = Alamofire.request(QatarMuseumRouter.GetToken(["name":"","pass":""])).responseObject { (response: DataResponse<TokenData>) -> Void in
            switch response.result {
            case .success(let data):
                _ = Alamofire.request(QatarMuseumRouter.SendDeviceToken(data.accessToken!, ["token": deviceToken, "type":"ios"])).responseObject { (response: DataResponse<DeviceToken>) -> Void in
                    switch response.result {
                    case .success( _):
                        print("This token is successfully sent to server")
                    case .failure( _):
                        print("Fail to update device token")
                    }
                }
            case .failure( _):
                print("Failed to generate token ")
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
    
    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "QatarMuseums")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    // iOS 9 and below
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "coreDataTestForPreOS", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    // MARK: - Core Data Saving support
    
    
    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }else{
            // iOS 9.0 and below - however you were previously handling it
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
            
        }
    }
    //MARK: HeritageList WebServiceCall
    func getHeritageDataFromServer() {
        let queue = DispatchQueue(label: "", qos: .background, attributes: .concurrent)
        _ = Alamofire.request(QatarMuseumRouter.HeritageList()).responseObject(queue: queue) { (response: DataResponse<Heritages>) -> Void in
            switch response.result {
            case .success(let data):
                DispatchQueue.main.async{
                    self.saveOrUpdateHeritageCoredata(heritageListArray: data.heritage)
                }
            case .failure(let error):
               // self.getHeritageDataFromServer()
               print(error)
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateHeritageCoredata(heritageListArray: [Heritage]?) {
        if ((heritageListArray?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = self.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext, heritageListArray: heritageListArray)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext, heritageListArray: heritageListArray)
                }
            }
        }
    }
    
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext,heritageListArray: [Heritage]?) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "HeritageEntity", idKey: "listid", idValue: nil, managedContext: managedContext) as! [HeritageEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict = heritageListArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "HeritageEntity", idKey: "listid", idValue: heritageListArray![i].id, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let heritagedbDict = fetchResult[0] as! HeritageEntity
                        heritagedbDict.listname = heritageListDict.name
                        heritagedbDict.listimage = heritageListDict.image
                        heritagedbDict.listsortid =  heritageListDict.sortid
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveToCoreData(heritageListDict: heritageListDict, managedObjContext: managedContext)
                        
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(heritageListNotification), object: self)
                
            } else {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict : Heritage?
                    heritageListDict = heritageListArray?[i]
                    self.saveToCoreData(heritageListDict: heritageListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(heritageListNotification), object: self)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "HeritageEntityArabic", idKey: "listid", idValue: nil, managedContext: managedContext) as! [HeritageEntityArabic]
            if (fetchData.count > 0) {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict = heritageListArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "HeritageEntityArabic", idKey: "listid", idValue: heritageListArray![i].id, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let heritagedbDict = fetchResult[0] as! HeritageEntityArabic
                        heritagedbDict.listnamearabic = heritageListDict.name
                        heritagedbDict.listimagearabic = heritageListDict.image
                        heritagedbDict.listsortidarabic =  heritageListDict.sortid
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    }
                    else {
                        //save
                        self.saveToCoreData(heritageListDict: heritageListDict, managedObjContext: managedContext)
                        
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(heritageListNotification), object: self)
            }
            else {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict : Heritage?
                    heritageListDict = heritageListArray?[i]
                    self.saveToCoreData(heritageListDict: heritageListDict!, managedObjContext: managedContext)
                    
                }
                NotificationCenter.default.post(name: NSNotification.Name(heritageListNotification), object: self)
            }
        }
    }
    
    func saveToCoreData(heritageListDict: Heritage, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let heritageInfo: HeritageEntity = NSEntityDescription.insertNewObject(forEntityName: "HeritageEntity", into: managedObjContext) as! HeritageEntity
            heritageInfo.listid = heritageListDict.id
            heritageInfo.listname = heritageListDict.name
            
            heritageInfo.listimage = heritageListDict.image
            if(heritageListDict.sortid != nil) {
                heritageInfo.listsortid = heritageListDict.sortid
            }
        } else {
            let heritageInfo: HeritageEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "HeritageEntityArabic", into: managedObjContext) as! HeritageEntityArabic
            heritageInfo.listid = heritageListDict.id
            heritageInfo.listnamearabic = heritageListDict.name
            
            heritageInfo.listimagearabic = heritageListDict.image
            if(heritageListDict.sortid != nil) {
                heritageInfo.listsortidarabic = heritageListDict.sortid
            }
        }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    //MARK: FloorMap WebServiceCall
    func getFloorMapDataFromServer(tourGuideId: String?) {
        let queue = DispatchQueue(label: "", qos: .background, attributes: .concurrent)
        _ = Alamofire.request(QatarMuseumRouter.CollectionByTourGuide(["tour_guide_id": tourGuideId!])).responseObject(queue: queue) { (response: DataResponse<TourGuideFloorMaps>) -> Void in
            switch response.result {
            case .success(let data):
                //DispatchQueue.main.async{
                    self.saveOrUpdateFloormapCoredata(floorMapArray: data.tourGuideFloorMap)
                //}
            case .failure(let error):
                print("error")
                
            }
        }
    }
    //MARK: FloorMap Coredata Method
    func saveOrUpdateFloormapCoredata(floorMapArray: [TourGuideFloorMap]?) {
        if ((floorMapArray?.count)! > 0) {
            if #available(iOS 10.0, *) {
                let container = self.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.floormapCoreDataInBackgroundThread(managedContext: managedContext, floorMapArray: floorMapArray)
                }
            } else {
                let managedContext = self.managedObjectContext
                managedContext.perform {
                    self.floormapCoreDataInBackgroundThread(managedContext : managedContext, floorMapArray: floorMapArray)
                }
            }
        }
    }
    func floormapCoreDataInBackgroundThread(managedContext: NSManagedObjectContext,floorMapArray: [TourGuideFloorMap]?) {
        if ((floorMapArray?.count)! > 0) {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                let fetchData = checkAddedToCoredata(entityName: "FloorMapTourGuideEntity", idKey: "tourGuideId", idValue: tourGuideId , managedContext: managedContext ) as! [FloorMapTourGuideEntity]
                
                if (fetchData.count > 0) {
                    for i in 0 ... (floorMapArray?.count)!-1 {
                        let managedContext = getContext()
                        let tourGuideDeatilDict = floorMapArray![i]
                        let fetchResult = checkAddedToCoredata(entityName: "FloorMapTourGuideEntity", idKey: "nid", idValue: floorMapArray![i].nid, managedContext: managedContext) as! [FloorMapTourGuideEntity]
                        
                        if(fetchResult.count != 0) {
                            
                            //update
                            let tourguidedbDict = fetchResult[0]
                            tourguidedbDict.title = tourGuideDeatilDict.title
                            tourguidedbDict.accessionNumber = tourGuideDeatilDict.accessionNumber
                            tourguidedbDict.nid =  tourGuideDeatilDict.nid
                            tourguidedbDict.curatorialDescription = tourGuideDeatilDict.curatorialDescription
                            tourguidedbDict.diam = tourGuideDeatilDict.diam
                            
                            tourguidedbDict.dimensions = tourGuideDeatilDict.dimensions
                            tourguidedbDict.mainTitle = tourGuideDeatilDict.mainTitle
                            tourguidedbDict.objectEngSummary =  tourGuideDeatilDict.objectENGSummary
                            tourguidedbDict.objectHistory = tourGuideDeatilDict.objectHistory
                            tourguidedbDict.production = tourGuideDeatilDict.production
                            
                            tourguidedbDict.productionDates = tourGuideDeatilDict.productionDates
                            tourguidedbDict.image = tourGuideDeatilDict.image
                            tourguidedbDict.tourGuideId =  tourGuideDeatilDict.tourGuideId
                            tourguidedbDict.artifactNumber = tourGuideDeatilDict.artifactNumber
                            tourguidedbDict.artifactPosition = tourGuideDeatilDict.artifactPosition
                            
                            tourguidedbDict.audioDescriptif = tourGuideDeatilDict.audioDescriptif
                            tourguidedbDict.audioFile = tourGuideDeatilDict.audioFile
                            tourguidedbDict.floorLevel =  tourGuideDeatilDict.floorLevel
                            tourguidedbDict.galleyNumber = tourGuideDeatilDict.galleyNumber
                            tourguidedbDict.artistOrCreatorOrAuthor = tourGuideDeatilDict.artistOrCreatorOrAuthor
                            tourguidedbDict.periodOrStyle = tourGuideDeatilDict.periodOrStyle
                            tourguidedbDict.techniqueAndMaterials = tourGuideDeatilDict.techniqueAndMaterials
                            if let imageUrl = tourGuideDeatilDict.thumbImage{
                                if(imageUrl != "") {
                                    if let data = try? Data(contentsOf: URL(string: imageUrl)!) {
                                        let image: UIImage = UIImage(data: data)!
                                        tourguidedbDict.artifactImg = UIImagePNGRepresentation(image)
                                    }
                                }
                            }
                            
                            
                            if(tourGuideDeatilDict.images != nil) {
                                if((tourGuideDeatilDict.images?.count)! > 0) {
                                    for i in 0 ... (tourGuideDeatilDict.images?.count)!-1 {
                                        var tourGuideImgEntity: FloorMapImagesEntity!
                                        let tourGuideImg: FloorMapImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "FloorMapImagesEntity", into: managedContext) as! FloorMapImagesEntity
                                        tourGuideImg.image = tourGuideDeatilDict.images?[i]
                                        
                                        tourGuideImgEntity = tourGuideImg
                                        tourguidedbDict.addToImagesRelation(tourGuideImgEntity)
                                        do {
                                            try managedContext.save()
                                            
                                        } catch let error as NSError {
                                            print("Could not save. \(error), \(error.userInfo)")
                                        }
                                        
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                do{
                                    try managedContext.save()
                                }
                                catch{
                                    print(error)
                                }
                            })
                        }else {
                            self.saveToCoreData(tourGuideDetailDict: tourGuideDeatilDict, managedObjContext: managedContext)
                        }
                    }//for
                    NotificationCenter.default.post(name: NSNotification.Name(floormapNotification), object: self)
                }//if
                else {
                    for i in 0 ... (floorMapArray?.count)!-1 {
                        let managedContext = getContext()
                        let tourGuideDetailDict : TourGuideFloorMap?
                        tourGuideDetailDict = floorMapArray?[i]
                        self.saveToCoreData(tourGuideDetailDict: tourGuideDetailDict!, managedObjContext: managedContext)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(floormapNotification), object: self)
                }
            }
            else {
                let fetchData = checkAddedToCoredata(entityName: "FloorMapTourGuideEntityAr", idKey:"tourGuideId" , idValue: tourGuideId, managedContext: managedContext) as! [FloorMapTourGuideEntityAr]
                if (fetchData.count > 0) {
                    for i in 0 ... (floorMapArray?.count)!-1 {
                        let managedContext = getContext()
                        let tourGuideDeatilDict = floorMapArray![i]
                        let fetchResult = checkAddedToCoredata(entityName: "FloorMapTourGuideEntityAr", idKey: "nid", idValue: floorMapArray![i].nid, managedContext: managedContext) as! [FloorMapTourGuideEntityAr]
                        //update
                        if(fetchResult.count != 0) {
                            let tourguidedbDict = fetchResult[0]
                            tourguidedbDict.title = tourGuideDeatilDict.title
                            tourguidedbDict.accessionNumber = tourGuideDeatilDict.accessionNumber
                            tourguidedbDict.nid =  tourGuideDeatilDict.nid
                            tourguidedbDict.curatorialDescription = tourGuideDeatilDict.curatorialDescription
                            tourguidedbDict.diam = tourGuideDeatilDict.diam
                            
                            tourguidedbDict.dimensions = tourGuideDeatilDict.dimensions
                            tourguidedbDict.mainTitle = tourGuideDeatilDict.mainTitle
                            tourguidedbDict.objectEngSummary =  tourGuideDeatilDict.objectENGSummary
                            tourguidedbDict.objectHistory = tourGuideDeatilDict.objectHistory
                            tourguidedbDict.production = tourGuideDeatilDict.production
                            
                            tourguidedbDict.productionDates = tourGuideDeatilDict.productionDates
                            tourguidedbDict.image = tourGuideDeatilDict.image
                            tourguidedbDict.tourGuideId =  tourGuideDeatilDict.tourGuideId
                            tourguidedbDict.artifactNumber = tourGuideDeatilDict.artifactNumber
                            tourguidedbDict.artifactPosition = tourGuideDeatilDict.artifactPosition
                            
                            tourguidedbDict.audioDescriptif = tourGuideDeatilDict.audioDescriptif
                            tourguidedbDict.audioFile = tourGuideDeatilDict.audioFile
                            tourguidedbDict.floorLevel =  tourGuideDeatilDict.floorLevel
                            tourguidedbDict.galleyNumber = tourGuideDeatilDict.galleyNumber
                            tourguidedbDict.artistOrCreatorOrAuthor = tourGuideDeatilDict.artistOrCreatorOrAuthor
                            tourguidedbDict.periodOrStyle = tourGuideDeatilDict.periodOrStyle
                            tourguidedbDict.techniqueAndMaterials = tourGuideDeatilDict.techniqueAndMaterials
                            if let imageUrl = tourGuideDeatilDict.thumbImage{
                                if(imageUrl != "") {
                                    if let data = try? Data(contentsOf: URL(string: imageUrl)!) {
                                        let image: UIImage = UIImage(data: data)!
                                        tourguidedbDict.artifactImg = UIImagePNGRepresentation(image)
                                    }
                                }
                                
                            }
                            if(tourGuideDeatilDict.images != nil) {
                                if((tourGuideDeatilDict.images?.count)! > 0) {
                                    for i in 0 ... (tourGuideDeatilDict.images?.count)!-1 {
                                        var tourGuideImgEntity: FloorMapImagesEntityAr!
                                        let tourGuideImg: FloorMapImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FloorMapImagesEntityAr", into: managedContext) as! FloorMapImagesEntityAr
                                        tourGuideImg.image = tourGuideDeatilDict.images?[i]
                                        
                                        tourGuideImgEntity = tourGuideImg
                                        tourguidedbDict.addToImagesRelation(tourGuideImgEntity)
                                        do {
                                            try managedContext.save()
                                            
                                        } catch let error as NSError {
                                            print("Could not save. \(error), \(error.userInfo)")
                                        }
                                        
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: {
                                do{
                                    try managedContext.save()
                                }
                                catch{
                                    print(error)
                                }
                            })
                        } else {
                            self.saveToCoreData(tourGuideDetailDict: tourGuideDeatilDict, managedObjContext: managedContext)
                        }
                    }//for
                    NotificationCenter.default.post(name: NSNotification.Name(floormapNotification), object: self)
                } //if
                else {
                    for i in 0 ... (floorMapArray?.count)!-1 {
                        let managedContext = getContext()
                        let tourGuideDetailDict : TourGuideFloorMap?
                        tourGuideDetailDict = floorMapArray?[i]
                        self.saveToCoreData(tourGuideDetailDict: tourGuideDetailDict!, managedObjContext: managedContext)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(floormapNotification), object: self)
                }
            }
        }
    }
    func saveToCoreData(tourGuideDetailDict: TourGuideFloorMap, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let tourguidedbDict: FloorMapTourGuideEntity = NSEntityDescription.insertNewObject(forEntityName: "FloorMapTourGuideEntity", into: managedObjContext) as! FloorMapTourGuideEntity
            tourguidedbDict.title = tourGuideDetailDict.title
            tourguidedbDict.accessionNumber = tourGuideDetailDict.accessionNumber
            tourguidedbDict.nid =  tourGuideDetailDict.nid
            tourguidedbDict.curatorialDescription = tourGuideDetailDict.curatorialDescription
            tourguidedbDict.diam = tourGuideDetailDict.diam
            
            tourguidedbDict.dimensions = tourGuideDetailDict.dimensions
            tourguidedbDict.mainTitle = tourGuideDetailDict.mainTitle
            tourguidedbDict.objectEngSummary =  tourGuideDetailDict.objectENGSummary
            tourguidedbDict.objectHistory = tourGuideDetailDict.objectHistory
            tourguidedbDict.production = tourGuideDetailDict.production
            
            tourguidedbDict.productionDates = tourGuideDetailDict.productionDates
            tourguidedbDict.image = tourGuideDetailDict.image
            tourguidedbDict.tourGuideId =  tourGuideDetailDict.tourGuideId
            tourguidedbDict.artifactNumber = tourGuideDetailDict.artifactNumber
            tourguidedbDict.artifactPosition = tourGuideDetailDict.artifactPosition
            
            tourguidedbDict.audioDescriptif = tourGuideDetailDict.audioDescriptif
            tourguidedbDict.audioFile = tourGuideDetailDict.audioFile
            tourguidedbDict.floorLevel =  tourGuideDetailDict.floorLevel
            tourguidedbDict.galleyNumber = tourGuideDetailDict.galleyNumber
            tourguidedbDict.artistOrCreatorOrAuthor = tourGuideDetailDict.artistOrCreatorOrAuthor
            tourguidedbDict.periodOrStyle = tourGuideDetailDict.periodOrStyle
            tourguidedbDict.techniqueAndMaterials = tourGuideDetailDict.techniqueAndMaterials
            if let imageUrl = tourGuideDetailDict.thumbImage{
                if(imageUrl != "") {
                    if let data = try? Data(contentsOf: URL(string: imageUrl)!) {
                        let image: UIImage = UIImage(data: data)!
                        tourguidedbDict.artifactImg = UIImagePNGRepresentation(image)
                    }
                }
            }
            if(tourGuideDetailDict.images != nil) {
                if((tourGuideDetailDict.images?.count)! > 0) {
                    for i in 0 ... (tourGuideDetailDict.images?.count)!-1 {
                        var tourGuideImgEntity: FloorMapImagesEntity!
                        let tourGuideImg: FloorMapImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "FloorMapImagesEntity", into: managedObjContext) as! FloorMapImagesEntity
                        tourGuideImg.image = tourGuideDetailDict.images?[i]
                        
                        tourGuideImgEntity = tourGuideImg
                        tourguidedbDict.addToImagesRelation(tourGuideImgEntity)
                        do {
                            try managedObjContext.save()
                            
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                    }
                }
            }
            
        }
        else {
            let tourguidedbDict: FloorMapTourGuideEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FloorMapTourGuideEntityAr", into: managedObjContext) as! FloorMapTourGuideEntityAr
            tourguidedbDict.title = tourGuideDetailDict.title
            tourguidedbDict.accessionNumber = tourGuideDetailDict.accessionNumber
            tourguidedbDict.nid =  tourGuideDetailDict.nid
            tourguidedbDict.curatorialDescription = tourGuideDetailDict.curatorialDescription
            tourguidedbDict.diam = tourGuideDetailDict.diam
            
            tourguidedbDict.dimensions = tourGuideDetailDict.dimensions
            tourguidedbDict.mainTitle = tourGuideDetailDict.mainTitle
            tourguidedbDict.objectEngSummary =  tourGuideDetailDict.objectENGSummary
            tourguidedbDict.objectHistory = tourGuideDetailDict.objectHistory
            tourguidedbDict.production = tourGuideDetailDict.production
            
            tourguidedbDict.productionDates = tourGuideDetailDict.productionDates
            tourguidedbDict.image = tourGuideDetailDict.image
            tourguidedbDict.tourGuideId =  tourGuideDetailDict.tourGuideId
            tourguidedbDict.artifactNumber = tourGuideDetailDict.artifactNumber
            tourguidedbDict.artifactPosition = tourGuideDetailDict.artifactPosition
            
            tourguidedbDict.audioDescriptif = tourGuideDetailDict.audioDescriptif
            tourguidedbDict.audioFile = tourGuideDetailDict.audioFile
            tourguidedbDict.floorLevel =  tourGuideDetailDict.floorLevel
            tourguidedbDict.galleyNumber = tourGuideDetailDict.galleyNumber
            tourguidedbDict.artistOrCreatorOrAuthor = tourGuideDetailDict.artistOrCreatorOrAuthor
            tourguidedbDict.periodOrStyle = tourGuideDetailDict.periodOrStyle
            tourguidedbDict.techniqueAndMaterials = tourGuideDetailDict.techniqueAndMaterials
            if let imageUrl = tourGuideDetailDict.thumbImage{
                if(imageUrl != "") {
                    if let data = try? Data(contentsOf: URL(string: imageUrl)!) {
                        let image: UIImage = UIImage(data: data)!
                        tourguidedbDict.artifactImg = UIImagePNGRepresentation(image)
                    }
                }
            }
            if(tourGuideDetailDict.images != nil) {
                if((tourGuideDetailDict.images?.count)! > 0) {
                    for i in 0 ... (tourGuideDetailDict.images?.count)!-1 {
                        var tourGuideImgEntity: FloorMapImagesEntityAr!
                        let tourGuideImg: FloorMapImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FloorMapImagesEntityAr", into: managedObjContext) as! FloorMapImagesEntityAr
                        tourGuideImg.image = tourGuideDetailDict.images?[i]
                        
                        tourGuideImgEntity = tourGuideImg
                        tourguidedbDict.addToImagesRelation(tourGuideImgEntity)
                        do {
                            try managedObjContext.save()
                            
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                    }
                }
            }
        }
        DispatchQueue.main.async(execute: {
        do {
                try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        })
    }
    func checkAddedToCoredata(entityName: String?, idKey:String?, idValue: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults : [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
        if (idValue != nil) {
            fetchRequest.predicate = NSPredicate(format: "\(idKey!) == %@", idValue!)
        }
        fetchResults = try! managedContext.fetch(fetchRequest)
        return fetchResults
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

