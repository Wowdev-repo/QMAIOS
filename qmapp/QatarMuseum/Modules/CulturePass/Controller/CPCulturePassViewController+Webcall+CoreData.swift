//
//  CPCulturePassViewControllerCoreData.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation

extension CPCulturePassViewController {
    //MARK: WebServiceCall
    func getCulturePassTokenFromServer(login: Bool? = false) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetToken(["name": loginPopUpView.userNameText.text!,"pass":loginPopUpView.passwordText.text!]))
            .responseObject { [weak self] (response: DataResponse<CPTokenData>) -> Void in
            switch response.result {
            case .success(let data):
                self?.accessToken = data.accessToken
                //                UserDefaults.standard.set(data.accessToken, forKey: "accessToken")
                //self.loginPopUpView.loadingView.stopLoading()
                // self.loginPopUpView.loadingView.isHidden = true
                if(login == true) {
                    self?.getCulturePassLoginFromServer()
                } else {
                    self?.setNewPassword()
                }
                
            case .failure( _):
                self?.loginPopUpView.loadingView.stopLoading()
                self?.loginPopUpView.loadingView.isHidden = true
            }
        }
    }
    
    func getCulturePassLoginFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let titleString = NSLocalizedString("WEBVIEW_TITLE",comment: "Set the title for Alert")
        if(accessToken != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.Login(["name" : loginPopUpView.userNameText.text!,"pass": loginPopUpView.passwordText.text!]))
                .responseObject { [weak self] (response: DataResponse<CPLoginData>) -> Void in
                switch response.result {
                case .success(let data):
                    self?.loginPopUpView.loadingView.stopLoading()
                    self?.loginPopUpView.loadingView.isHidden = true
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
                        //self.loadProfilepage(loginInfo: self.loginArray)
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
    
    func setNewPassword() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let titleString = NSLocalizedString("WEBVIEW_TITLE",comment: "Set the title for Alert")
        if(accessToken != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.NewPasswordRequest(["name" : loginPopUpView.userNameText.text!])).responseData { [weak self] (response) -> Void in
                switch response.result {
                case .success( _):
                    self?.loginPopUpView.loadingView.stopLoading()
                    self?.loginPopUpView.loadingView.isHidden = true
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    if(response.response?.statusCode == 200) {
                        self?.loadSuccessMessage()
                    } else if(response.response?.statusCode == 406) {
                        if let controller = self {
                            showAlertView(title: titleString, message: NSLocalizedString("INVALID_USERNAME",comment: "Set the message for invalid username or email id"), viewController: controller)
                        }
                        
                    }
                case .failure( _):
                    self?.loginPopUpView.loadingView.stopLoading()
                    self?.loginPopUpView.loadingView.isHidden = true
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                }
            }
            
        }
    }
    //RSVP Service call
    func checkRSVPUserFromServer(userId: String?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetUser(userId!))
            .responseObject { [weak self] (response: DataResponse<UserInfoData>) -> Void in
            switch response.result {
            case .success(let data):
                self?.loginPopUpView.loadingView.stopLoading()
                self?.loginPopUpView.loadingView.isHidden = true
                if(response.response?.statusCode == 200) {
                    self?.userInfoArray = data
                    
                    if(self?.userInfoArray != nil) {
                        if(self?.userInfoArray?.fieldRsvpAttendance != nil) {
                            let undData = self?.userInfoArray?.fieldRsvpAttendance!["und"] as! NSArray
                            if(undData != nil) {
                                if(undData.count > 0) {
                                    let value = undData[0] as! NSDictionary
                                    if(value["value"] != nil) {
                                        UserDefaults.standard.setValue(value["value"], forKey: "acceptOrDecline")
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    self?.loadProfilepage(loginInfo: self?.loginArray)
                }
            case .failure( _):
                self?.loginPopUpView.loadingView.stopLoading()
                self?.loginPopUpView.loadingView.isHidden = true
                
            }
        }
    }
    //MARK : NMoQ EntityRegistratiion
    func getEventListUserRegistrationFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if((accessToken != nil) && (keychain.get(UserProfileInfo.user_id) != nil)){
            let userId = keychain.get(UserProfileInfo.user_id)!
            _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.NMoQEventListUserRegistration(["user_id" : userId]))
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
    
    //MARK: EventRegistrationCoreData
    func saveOrUpdateEventReistratedCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (userEventList.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.userEventCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.userEventCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    func userEventCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        CPDataManager.saveRegisteredEventListEntity(managedContext : managedContext,
                                                  list: self.userEventList)
    }
}
