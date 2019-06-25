//
//  NotificationsViewController+CoreData.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation

extension NotificationsViewController {
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
}
