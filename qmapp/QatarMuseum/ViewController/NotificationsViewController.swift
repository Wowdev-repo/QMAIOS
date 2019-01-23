//
//  NotificationsViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 19/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Crashlytics
import UIKit
import CoreData

class NotificationsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,HeaderViewProtocol {
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var notificationsHeader: CommonHeaderView!
    @IBOutlet weak var loadingView: LoadingView!
    
    var fromHome : Bool = false
    var notificationArray: [Notification]! = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        updateNotificationTableView()
    }
    
    func updateNotificationTableView(){
        UserDefaults.standard.removeObject(forKey: "notificationBadgeCount")
        let notificationData = UserDefaults.standard.object(forKey: "pushNotificationList") as? NSData
        if let notificationData = notificationData, let notifications = NSKeyedUnarchiver.unarchiveObject(with: notificationData as Data) as?
            [Notification] {
            self.fetchNotificationsFromCoredata()
            notificationArray = []
            for notification in notifications {
               // notificationArray.insert(notification, at: 0)
                notificationArray.append(notification)
            }
            notificationsTableView.reloadData()
            saveOrUpdateNotificationsCoredata()
            //UserDefaults.standard.removeObject(forKey: "pushNotificationList")
        } else {
            self.fetchNotificationsFromCoredata()
        }
    }

    func setUI() {
        loadingView.isHidden = false
        loadingView.showLoading()
        
//        self.loadingView.noDataView.isHidden = false
//        self.loadingView.showNoDataView()
        //self.loadingView.noDataLabel.text = errorMessage
        
        notificationsHeader.headerTitle.text = NSLocalizedString("NOTIFICATIONS_TITLE", comment: "NOTIFICATIONS_TITLE in the Notification page")
        notificationsHeader.headerViewDelegate = self
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            notificationsHeader.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            notificationsHeader.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
    }
    
    func emptyNotificationData() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showYetNoNotificationDataView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightValue = UIScreen.main.bounds.height/100
        return heightValue*12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCellId", for: indexPath) as! NotificationsTableViewCell
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            cell.detailArrowButton.setImage(UIImage(named: "nextImg"), for: .normal)
        } else {
            cell.detailArrowButton.setImage(UIImage(named: "previousImg"), for: .normal)
        }
        if (indexPath.row % 2 == 0) {
            cell.innerView.backgroundColor = UIColor.notificationCellAsh
        } else {
            cell.innerView.backgroundColor = UIColor.white
        }
        
        cell.notificationLabel.text = notificationArray[indexPath.row].title
        cell.notificationDetailSelection = {
            () in
            self.loadNotificationDetail(cellObj: cell)
        }
        loadingView.stopLoading()
        loadingView.isHidden = true
        return cell
    }
    
    func loadNotificationDetail(cellObj: NotificationsTableViewCell) {
       
    }
    
    //    //MARK: Coredata Method
    func saveOrUpdateNotificationsCoredata() {
        if (notificationArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let fetchData = checkAddedToCoredata(entityName: "NotificationsEntity", idKey: "sortId", idValue: nil, managedContext: managedContext) as! [NotificationsEntity]
            if (fetchData.count > 0) {
                for i in 0 ... notificationArray.count-1 {
                    let notificationDict = notificationArray[i]
                    let fetchResult = checkAddedToCoredata(entityName: "NotificationsEntity", idKey: "sortId", idValue: nil, managedContext: managedContext) as! [NotificationsEntity]
                    if(fetchResult.count > 0) {
                        let isDeleted = self.deleteExistingNotification(managedContext: managedContext, entityName: "NotificationsEntity")
                        if(isDeleted == true) {
                            self.saveToCoreData(notificationsDict: notificationDict, managedObjContext: managedContext)
                        }
                    } else {
                        self.saveToCoreData(notificationsDict: notificationDict, managedObjContext: managedContext)
                    }
                }
            } else {
                for i in 0 ... notificationArray.count-1 {
                    let notificationDict : Notification?
                    notificationDict = notificationArray[i]
                    self.saveToCoreData(notificationsDict: notificationDict!, managedObjContext: managedContext)
                }
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "NotificationsEntityArabic", idKey: "sortId", idValue: nil, managedContext: managedContext) as! [NotificationsEntityArabic]
            if (fetchData.count > 0) {
                for i in 0 ... notificationArray.count-1 {
                    let notificationDict = notificationArray[i]
                    let fetchResult = checkAddedToCoredata(entityName: "NotificationsEntityArabic", idKey: "sortId", idValue: nil, managedContext: managedContext) as! [NotificationsEntityArabic]
                    if(fetchResult.count > 0) {
                        let isDeleted = self.deleteExistingNotification(managedContext: managedContext, entityName: "NotificationsEntityArabic")
                        if(isDeleted == true) {
                            self.saveToCoreData(notificationsDict: notificationDict, managedObjContext: managedContext)
                        }
                    } else {
                        self.saveToCoreData(notificationsDict: notificationDict, managedObjContext: managedContext)
                    }
                }
            } else {
                for i in 0 ... notificationArray.count-1 {
                    let notificationsDict : Notification?
                    notificationsDict = notificationArray[i]
                    self.saveToCoreData(notificationsDict: notificationsDict!, managedObjContext: managedContext)
                }
            }
        }
    }
    
    func saveToCoreData(notificationsDict: Notification, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let notificationInfo: NotificationsEntity = NSEntityDescription.insertNewObject(forEntityName: "NotificationsEntity", into: managedObjContext) as! NotificationsEntity
            notificationInfo.title = notificationsDict.title
            if(notificationsDict.sortId != nil) {
                notificationInfo.sortId = notificationsDict.sortId
            }
        } else {
            let notificationInfo: NotificationsEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "NotificationsEntityArabic", into: managedObjContext) as! NotificationsEntityArabic
            notificationInfo.titleArabic = notificationsDict.title
            if(notificationsDict.sortId != nil) {
                notificationInfo.sortIdArabic = notificationsDict.sortId
            }
        }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteExistingNotification(managedContext:NSManagedObjectContext,entityName : String?) ->Bool? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName!)
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
            return true
        }catch let error as NSError {
            //handle error here
            return false
        }
        
    }
    
    func fetchNotificationsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                var listArray = [NotificationsEntity]()
                let notificationsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationsEntity")
                listArray = (try managedContext.fetch(notificationsFetchRequest) as? [NotificationsEntity])!
                
                if (listArray.count > 0) {
                    for i in 0 ... listArray.count-1 {
                        self.notificationArray.insert(Notification(title: listArray[i].title, sortId: listArray[i].sortId), at: i)
                        
                    }
                    if(notificationArray.count == 0){
                        self.emptyNotificationData()
                    } else {
                        self.loadingView.stopLoading()
                        self.loadingView.isHidden = true
                    }
                    notificationsTableView.reloadData()
                }
                else{
                    self.emptyNotificationData()
                }
            }
            else {
                var listArray = [NotificationsEntityArabic]()
                let notificationsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationsEntityArabic")
                listArray = (try managedContext.fetch(notificationsFetchRequest) as? [NotificationsEntityArabic])!
                if (listArray.count > 0) {
                    for i in 0 ... listArray.count-1 {
                        self.notificationArray.insert(Notification(title: listArray[i].titleArabic, sortId: listArray[i].sortIdArabic), at: i)
                    }
                    if(listArray.count == 0){
                        self.emptyNotificationData()
                    } else {
                        self.loadingView.stopLoading()
                        self.loadingView.isHidden = true
                    }
                    notificationsTableView.reloadData()
                }
                else{
                    self.emptyNotificationData()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func checkAddedToCoredata(entityName: String?,idKey:String?, idValue: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults : [NSManagedObject] = []
        let notificationFetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
        if (idValue != nil) {
            notificationFetchRequest.predicate = NSPredicate.init(format: "\(idKey!) == \(idValue!)")
        }
        fetchResults = try! managedContext.fetch(notificationFetchRequest)
        return fetchResults
    }
    
    //MARK: header delegate
    func headerCloseButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        if (fromHome == true) {
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController
            
            let appDelegate = UIApplication.shared.delegate
            appDelegate?.window??.rootViewController = homeViewController
        }
        else {
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
