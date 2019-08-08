//
//  NotificationsViewController.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 19/07/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//


import Crashlytics
import Firebase
import UIKit


class CPNotificationsViewController: UIViewController {
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var notificationsHeader: CPCommonHeaderView!
    @IBOutlet weak var loadingView: LoadingView!
    
    var fromHome : Bool = false
    var notificationArray: [CPNotification]! = []

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
            [CPNotification] {
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
        if ((CPLocalizationLanguage.currentAppleLanguage()) == "en") {
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
    
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(NOTIFICATIONS_LIST, screenClass: screenClass)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CPNotificationsViewController: CPHeaderViewProtocol {
    //MARK: header delegate
    func headerCloseButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        if (fromHome == true) {
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! CPHomeViewController
            
            let appDelegate = UIApplication.shared.delegate
            appDelegate?.window??.rootViewController = homeViewController
        }
        else {
            self.dismiss(animated: false, completion: nil)
        }
        
    }
}
