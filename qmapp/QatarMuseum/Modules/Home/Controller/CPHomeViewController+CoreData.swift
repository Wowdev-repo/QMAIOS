//
//  CPHomeViewController+CoreData.swift
//  QatarMuseums
//
//  Created by Exalture on 11/07/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

/**
  HomeViewController CoreData and Web service methods in HomeViewController extensions
 */

import UIKit
import Firebase
import KeychainSwift

extension CPHomeViewController {
    func saveOrUpdateHomeCoredata(homeList: [CPHome]) {
        if !homeList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateHomeEntity(managedContext: managedContext, homeList: homeList, language: CPUtils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateHomeEntity(managedContext: managedContext, homeList: homeList, language: CPUtils.getLanguage())
                }
            }
        }
    }
    
    //MARK: Coredata Method
    func fetchHomeInfoFromCoredata() {
        if(alreadyFetch == false) {
            let managedContext = getContext()
            // let panelAndTalksName = NSLocalizedString("PANEL_AND_TALKS",comment: "PANEL_AND_TALKS in Home Page")
            do {
                let homeArray = CPDataManager.checkAddedToCoredata(entityName: "HomeEntity",
                                                                 idKey: "lang",
                                                                 idValue: CPUtils.getLanguage(),
                                                                 managedContext: managedContext) as! [HomeEntity]
                if (homeArray.count > 0) {
                    if((self.networkReachability?.isReachable)!) {
                        DispatchQueue.global(qos: .background).async {
                            self.getHomeList()
                        }
                    }
                    //homeArray.sort(by: {$0.sortid < $1.sortid})
                    for entity in homeArray {
                        if homeList.first(where: {$0.id == entity.id}) != nil {
                        } else {
                            self.homeList.append(CPHome(entity: entity))
                        }
                        
                    }
                    
                    /* Just Commented for New Release
                     let panelAndTalks = "QATAR CREATES: EVENTS FOR THE OPENING OF NMoQ".lowercased()
                     if homeList.index(where: {$0.name?.lowercased() != panelAndTalks}) != nil {
                     self.homeList.insert(Home(id: "13976", name: panelAndTalksName.uppercased(), image: "panelAndTalks", tourguide_available: "false", sort_id: "10"), at: self.homeList.endIndex)
                     }
                     */
                    if let nilItem = self.homeList.first(where: {$0.sortId == "" || $0.sortId == nil}) {
                        print(nilItem)
                    } else {
                        self.homeList = self.homeList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                    if(self.homeBannerList.count > 0) {
                        self.homeList.insert(CPHome(id:self.homeBannerList[0].fullContentID , name: self.homeBannerList[0].bannerTitle,image: self.homeBannerList[0].bannerLink,
                                                  tourguide_available: "false", sort_id: nil),
                                             at: 0)
                    }
                    if(self.homeList.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    self.homeTableView.reloadData()
                    self.alreadyFetch = true
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getHomeList()
                    }
                }
            }
            //        catch let error as NSError {
            //            print("Could not fetch. \(error), \(error.userInfo)")
            //            if (networkReachability?.isReachable == false) {
            //                self.showNoNetwork()
            //            }
            //        }
        }
    }
    //MARK: EventRegistrationCoreData
    func saveOrUpdateEventReistratedCoredata() {
        if (userEventList.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.saveRegisteredEventListEntity(managedContext: managedContext,
                                                              list: self.userEventList)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.saveRegisteredEventListEntity(managedContext : managedContext,
                                                              list: self.userEventList)
                }
            }
        }
    }
    
    
    //MARK: HomeBanner CoreData
    func saveOrUpdateHomeBannerCoredata() {
        if (homeBannerList.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateHomeBanner(managedContext: managedContext, list: self.homeBannerList!)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateHomeBanner(managedContext : managedContext, list: self.homeBannerList!)
                }
            }
        }
    }
    
    
    func fetchHomeBannerInfoFromCoredata() {
        let managedContext = getContext()
        do {
            var homeArray = [HomeBannerEntity]()
            let homeFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "HomeBannerEntity")
            homeArray = (try managedContext.fetch(homeFetchRequest) as? [HomeBannerEntity])!
            if (homeArray.count > 0) {
                for homeBannerDict in homeArray {
                    self.homeBannerList.append(CPHomeBanner(entity: homeBannerDict))
                }
                self.homeTableView.reloadData()
            } else{
                //self.showNoNetwork()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

//MARK:- WebServiceCall
extension CPHomeViewController {
    func getCulturePassTokenFromServer(login: Bool? = false) {
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.GetToken(["name": loginPopUpView.userNameText.text!,"pass":loginPopUpView.passwordText.text!]))
            .responseObject { [weak self] (response: DataResponse<CPTokenData>) -> Void in
                switch response.result {
                case .success(let data):
                    self?.accessToken = data.accessToken
                    if(login == true) {
                        self?.getCulturePassLoginFromServer()
                    }
                    
                case .failure( _):
                    self?.loginPopUpView.loadingView.stopLoading()
                    self?.loginPopUpView.loadingView.isHidden = true
                }
        }
    }
    func getCulturePassLoginFromServer() {
        let titleString = NSLocalizedString("WEBVIEW_TITLE",comment: "Set the title for Alert")
        if(accessToken != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?
                .request(CPQatarMuseumRouter.Login(["name" : loginPopUpView.userNameText.text!,"pass": loginPopUpView.passwordText.text!]))
                .responseObject { [weak self](response: DataResponse<CPLoginData>) -> Void in
                    switch response.result {
                    case .success(let data):
                        self?.loginPopUpView.loadingView.stopLoading()
                        self?.loginPopUpView.loadingView.isHidden = true
                        self?.keychain.set(self?.loginPopUpView.passwordText.text ?? "", forKey: UserProfileInfo.user_password)
                        
                        if(response.response?.statusCode == 200) {
                            self?.loginArray = data
                            UserDefaults.standard.setValue(self?.loginArray?.token, forKey: "accessToken")
                            if(self?.loginArray != nil) {
                                if(self?.loginArray?.user != nil) {
                                    if(self?.loginArray?.user?.uid != nil) {
                                        self?.checkRSVPUserFromServer(userId: self?.loginArray?.user?.uid )
                                    }
                                }
                            }
                        } else if(response.response?.statusCode == 401) {
                            if let controller = self {
                                showAlertView(title: titleString, message: NSLocalizedString("WRONG_USERNAME_OR_PWD",comment: "Set the message for wrong username or password"), viewController: controller)
                            }
                            
                        } else if(response.response?.statusCode == 406) {
                            if let controller = self {
                                showAlertView(title: titleString, message: NSLocalizedString("ALREADY_LOGGEDIN",comment: "Set the message for Already Logged in"), viewController: controller)
                            }
                            
                        }
                        
                    case .failure( _):
                        self?.loginPopUpView.loadingView.stopLoading()
                        self?.loginPopUpView.loadingView.isHidden = true
                        
                    }
            }
            
        }
    }
    //RSVP Service call
    func checkRSVPUserFromServer(userId: String?) {
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.GetUser(userId!))
            .responseObject { [weak self] (response: DataResponse<UserInfoData>) -> Void in
                switch response.result {
                case .success(let data):
                    self?.loginPopUpView.loadingView.stopLoading()
                    self?.loginPopUpView.loadingView.isHidden = true
                    if(response.response?.statusCode == 200) {
                        self?.userInfoArray = data
                        
                        if(self?.userInfoArray != nil) {
                            if(self?.userInfoArray?.fieldRsvpAttendance != nil) {
                                let undData = self?.userInfoArray?.fieldRsvpAttendance!["und"] as? NSArray
                                if(undData != nil) {
                                    if((undData?.count)! > 0) {
                                        let value = undData?[0] as! NSDictionary
                                        if(value["value"] != nil) {
                                            UserDefaults.standard.setValue(value["value"], forKey: "acceptOrDecline")
                                            self?.getHomeBanner()
                                        }
                                    }
                                    
                                }
                            }
                        }
                        self?.setProfileDetails(loginInfo: self?.loginArray)
                    }
                case .failure( _):
                    self?.loginPopUpView.loadingView.stopLoading()
                    self?.loginPopUpView.loadingView.isHidden = true
                    
                }
        }
    }
    //MARK : NMoQ EntityRegistratiion
    func getEventListUserRegistrationFromServer() {
        if((accessToken != nil) && ((keychain.get(UserProfileInfo.user_id) != nil) && (keychain.get(UserProfileInfo.user_id) != nil))){
            let userId = keychain.get(UserProfileInfo.user_id) ?? ""
            _ = CPSessionManager.sharedInstance.apiManager()?
                .request(CPQatarMuseumRouter.NMoQEventListUserRegistration(["uid" : userId]))
                .responseObject { [weak self] (response: DataResponse<NMoQUserEventListValues>) -> Void in
                    switch response.result {
                    case .success(let data):
                        self?.userEventList = data.eventList ?? []
                        self?.saveOrUpdateEventReistratedCoredata()
                    case .failure( _):
                        self?.loginPopUpView.removeFromSuperview()
                        self?.loginPopUpView.loadingView.stopLoading()
                        self?.loginPopUpView.loadingView.isHidden = true
                    }
            }
        }
    }
}
