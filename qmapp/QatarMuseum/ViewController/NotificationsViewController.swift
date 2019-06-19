//
//  NotificationsViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 19/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import CoreData
import Crashlytics
import Firebase
import UIKit
import CocoaLumberjack

class NotificationsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,HeaderViewProtocol {
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var notificationsHeader: CommonHeaderView!
    @IBOutlet weak var loadingView: LoadingView!
    
    var fromHome : Bool = false
    var notificationArray: [Notification]! = []

    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        setUI()
        updateNotificationTableView()
        self.recordScreenView()
    }
    
    func updateNotificationTableView(){
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (notificationArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateNotifications(managedContext: managedContext,
                                                    notifications: self.notificationArray)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateNotifications(managedContext : managedContext,
                                                    notifications: self.notificationArray)
                }
            }
        }
    }
    
    func fetchNotificationsFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let managedContext = getContext()
        do {
                var listArray = [NotificationsEntity]()
                let notificationsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationsEntity")
                listArray = (try managedContext.fetch(notificationsFetchRequest) as? [NotificationsEntity])!
                
                if (listArray.count > 0) {
                    for entity in listArray {
                        self.notificationArray.append(Notification(title: entity.title,
                                                                   sortId: entity.sortId,
                                                                   language: entity.language))
                        
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
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: header delegate
    func headerCloseButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(NOTIFICATIONS_LIST, screenClass: screenClass)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
