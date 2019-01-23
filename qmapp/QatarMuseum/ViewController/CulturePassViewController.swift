//
//  CulturePassViewController.swift
//  QatarMuseums
//
//  Created by Developer on 21/08/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import UIKit

class CulturePassViewController: UIViewController, HeaderViewProtocol, comingSoonPopUpProtocol,LoginPopUpProtocol,UITextFieldDelegate {
    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var secondIntroLabel: UILabel!
    @IBOutlet weak var benefitLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var notMemberLabel: UILabel!
    @IBOutlet weak var alreadyMemberLabel: UILabel!
    @IBOutlet weak var benefitsDiscountLabel: UILabel!
    
    var fromHome: Bool = false
    var fromProfile : Bool = false
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var loginPopUpView : LoginPopupPage = LoginPopupPage()
    let benefitList = ["15% Discount at QM Cafe's across all venues",
                       "10% Discount on items in all QM Gift Shops (without minimum purchase)",
                       "10% Discount at Idam Restaurant at lunch time",
                       "Receive our monthly newsletter to stay up to date on QM and partner offerings",
                       "Get premier access to members only talks &workkshops",
                       "Get exclusive invitation to QM open house access to our world class call center 8AM to 8PM daily"]
    var accessToken : String? = nil
    var loginArray : LoginData?
    var userInfoArray : UserInfoData?
    let networkReachability = NetworkReachabilityManager()
    var userEventList: [NMoQUserEventList]! = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if(fromProfile) {
             fromProfile = false
            popupView  = ComingSoonPopUp(frame: self.view.frame)
            popupView.comingSoonPopupDelegate = self
            popupView.loadLogoutMessage(message : NSLocalizedString("LOGOUT_SUCCESSFULLY", comment: "LOGOUT_SUCCESSFULLY Label in the Popup"))
            self.view.addSubview(popupView)
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        headerView.headerViewDelegate = self
        headerView.headerTitle.text = NSLocalizedString("CULTUREPASS_TITLE", comment: "CULTUREPASS_TITLE in the Culture Pass page").uppercased()
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
        
        introLabel.textAlignment = .left
        secondIntroLabel.textAlignment = .left
        benefitLabel.textAlignment = .center

        benefitLabel.font = UIFont.eventPopupTitleFont
        introLabel.font = UIFont.englishTitleFont
        secondIntroLabel.font = UIFont.englishTitleFont
        notMemberLabel.font = UIFont.englishTitleFont
        alreadyMemberLabel.font = UIFont.englishTitleFont
        
        benefitLabel.text = NSLocalizedString("BENEFIT_TITLE", comment: "BENEFIT_TITLE in the Culture Pass page")
        introLabel.text = NSLocalizedString("CULTURE_PASS_INTRO", comment: "CULTURE_PASS_INTRO in the Culture Pass page")
        secondIntroLabel.text = NSLocalizedString("CULTURE_PASS_SECONDDESC", comment: "CULTURE_PASS_SECONDDESC in the Culture Pass page")

        benefitsDiscountLabel.text = NSLocalizedString("CULTURE_DISCOUNT_LABEL", comment: "CULTURE_DISCOUNT_LABEL in the Culture Pass page")
        notMemberLabel.text = NSLocalizedString("CULTURE_NOT_A_MEMBER", comment: "CULTURE_NOT_A_MEMBER in the Culture Pass page")
        registerButton.setTitle(NSLocalizedString("CULTURE_BECOME_A_MEMBER", comment: "CULTURE_BECOME_A_MEMBER in the Culture Pass page"), for: .normal)
        alreadyMemberLabel.text = NSLocalizedString("CULTURE_BECOME_ALREADY_MEMBER", comment: "CULTURE_BECOME_ALREADY_MEMBER in the Culture Pass page")
        logInButton.setTitle(NSLocalizedString("CULTURE_LOG_IN", comment: "CULTURE_LOG_IN in the Culture Pass page"), for: .normal)
        benefitsDiscountLabel.font = UIFont.settingsUpdateLabelFont
        registerButton.titleLabel?.font = UIFont.discoverButtonFont
        logInButton.titleLabel?.font = UIFont.discoverButtonFont
    }
    
    func loadComingSoonPopup() {
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadPopup()
        self.view.addSubview(popupView)
    }
    
    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
    }
    
    func loadSuccessMessage() {
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadLogoutMessage(message : NSLocalizedString("FORGOT_PASSWORD_SENT_SUCCESSFULLY", comment: "FORGOT_PASSWORD_SENT_SUCCESSFULLY Label in the Popup"))
        self.view.addSubview(popupView)
    }
    
    @IBAction func didTapRegisterButton(_ sender: UIButton) {
        var registrationUrlString = String()
        
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            registrationUrlString = "http://www.qm.org.qa/en/user/register#user-register-form"
        } else {
            registrationUrlString = "http://www.qm.org.qa/ar/user/register#user-register-form"
        }
        
        
        
        if let registrationUrl = URL(string: registrationUrlString) {
            // show alert to choose app
            if UIApplication.shared.canOpenURL(registrationUrl as URL) {
                let webViewVc:WebViewController = self.storyboard?.instantiateViewController(withIdentifier: "webViewId") as! WebViewController
                webViewVc.webViewUrl = registrationUrl
                webViewVc.titleString = NSLocalizedString("CULTURE_BECOME_A_MEMBER", comment: "CULTURE_BECOME_A_MEMBER in the Registration page")
                //webViewVc.titleString = NSLocalizedString("WEBVIEW_TITLE", comment: "WEBVIEW_TITLE  in the Webview")
                self.present(webViewVc, animated: false, completion: nil)
            }
        }
        /* Commented Bcz Now loading webview
        let registrationView =  self.storyboard?.instantiateViewController(withIdentifier: "registerViewId") as! RegistrationViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(registrationView, animated: false, completion: nil)
        self.registerButton.transform = CGAffineTransform(scaleX: 1, y: 1)
 */
    }
    
    @IBAction func registerButtonTouchDown(_ sender: UIButton) {
        self.registerButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    
    @IBAction func didTapLogInButton(_ sender: UIButton) {
        //loadComingSoonPopup()
        loadLoginPopup()
        self.logInButton.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    @IBAction func logInButtonTouchDown(_ sender: UIButton) {
        self.logInButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    func loadLoginPopup() {
        loginPopUpView  = LoginPopupPage(frame: self.view.frame)
        loginPopUpView.loginPopupDelegate = self
        loginPopUpView.userNameText.delegate = self
        loginPopUpView.passwordText.delegate = self
        self.view.addSubview(loginPopUpView)
    }
    //MARK: Login Popup Delegate
    func popupCloseButtonPressed() {
        self.loginPopUpView.removeFromSuperview()
    }
    
    func loginButtonPressed() {
        loginPopUpView.userNameText.resignFirstResponder()
        loginPopUpView.passwordText.resignFirstResponder()
        self.loginPopUpView.loadingView.isHidden = false
        self.loginPopUpView.loadingView.showLoading()
        
        let titleString = NSLocalizedString("WEBVIEW_TITLE",comment: "Set the title for Alert")
        if  (networkReachability?.isReachable)! {
            if ((loginPopUpView.userNameText.text != "") && (loginPopUpView.passwordText.text != "")) {
                self.getCulturePassTokenFromServer(login: true)
            }  else {
                self.loginPopUpView.loadingView.stopLoading()
                self.loginPopUpView.loadingView.isHidden = true
                if ((loginPopUpView.userNameText.text == "") && (loginPopUpView.passwordText.text == "")) {
                    showAlertView(title: titleString, message: NSLocalizedString("USERNAME_REQUIRED",comment: "Set the message for user name required")+"\n"+NSLocalizedString("PASSWORD_REQUIRED",comment: "Set the message for password required"), viewController: self)
                    
                } else if ((loginPopUpView.userNameText.text == "") && (loginPopUpView.passwordText.text != "")) {
                    showAlertView(title: titleString, message: NSLocalizedString("USERNAME_REQUIRED",comment: "Set the message for user name required"), viewController: self)
                } else if ((loginPopUpView.userNameText.text != "") && (loginPopUpView.passwordText.text == "")) {
                    showAlertView(title: titleString, message: NSLocalizedString("PASSWORD_REQUIRED",comment: "Set the message for password required"), viewController: self)
                }
            }
        } else {
            self.loginPopUpView.loadingView.stopLoading()
            self.loginPopUpView.loadingView.isHidden = true
            self.view.hideAllToasts()
            let eventAddedMessage =  NSLocalizedString("CHECK_NETWORK", comment: "CHECK_NETWORK") 
            self.view.makeToast(eventAddedMessage)
        }
    }
    
    func loadProfilepage(loginInfo : LoginData?) {
        if (loginInfo != nil) {
            let userData = loginInfo?.user
            UserDefaults.standard.setValue(userData?.uid, forKey: "uid")
            UserDefaults.standard.setValue(userData?.mail, forKey: "mail")
            UserDefaults.standard.setValue(userData?.name, forKey: "displayName")
            UserDefaults.standard.setValue(userData?.picture, forKey: "profilePic")
            if(userData?.fieldDateOfBirth != nil) {
                if((userData?.fieldDateOfBirth?.count)! > 0) {
                    UserDefaults.standard.setValue(userData?.fieldDateOfBirth![0], forKey: "fieldDateOfBirth")
                }
            }
            let firstNameData = userData?.fieldFirstName["und"] as! NSArray
            if(firstNameData != nil && firstNameData.count > 0) {
                let name = firstNameData[0] as! NSDictionary
                if(name["value"] != nil) {
                    UserDefaults.standard.setValue(name["value"] as! String, forKey: "fieldFirstName")
                }
            }
            let lastNameData = userData?.fieldLastName["und"] as! NSArray
            if(lastNameData != nil && lastNameData.count > 0) {
                let name = lastNameData[0] as! NSDictionary
                if(name["value"] != nil) {
                    UserDefaults.standard.setValue(name["value"] as! String, forKey: "fieldLastName")
                }
            }
            let locationData = userData?.fieldLocation["und"] as! NSArray
            if(locationData.count > 0) {
                let iso = locationData[0] as! NSDictionary
                if(iso["iso2"] != nil) {
                    UserDefaults.standard.setValue(iso["iso2"] as! String, forKey: "country")
                }
                
            }
            
            let nationalityData = userData?.fieldNationality["und"] as! NSArray
            if(nationalityData.count > 0) {
                let nation = nationalityData[0] as! NSDictionary
                if(nation["iso2"] != nil) {
                    UserDefaults.standard.setValue(nation["iso2"] as! String , forKey: "nationality")
                }
                
            }
            let translationsData = userData?.translations["data"] as! NSDictionary
            if(translationsData != nil) {
                let arValues = translationsData["ar"] as! NSDictionary
                if(arValues["entity_id"] != nil) {
                    UserDefaults.standard.setValue(arValues["entity_id"] as! String , forKey: "loginEntityID")
                }
            }
            
        }
        self.loginPopUpView.removeFromSuperview()
        getEventListUserRegistrationFromServer()
        let profileView =  self.storyboard?.instantiateViewController(withIdentifier: "profileViewId") as! ProfileViewController
        profileView.loginInfo = loginArray
        profileView.fromCulturePass = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(profileView, animated: false, completion: nil)
    }
    func forgotButtonPressed() {
        self.loginPopUpView.loadingView.isHidden = false
        self.loginPopUpView.loadingView.showLoading()
        let titleString = NSLocalizedString("WEBVIEW_TITLE",comment: "Set the title for Alert")
        if (loginPopUpView.userNameText.text != "") {
            self.getCulturePassTokenFromServer(login: false)
        } else {
            self.loginPopUpView.loadingView.stopLoading()
            self.loginPopUpView.loadingView.isHidden = true
            showAlertView(title: titleString, message: NSLocalizedString("USERNAME_REQUIRED",comment: "Set the message for user name required"), viewController: self)
        }
    }
    //MARK:TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == loginPopUpView.userNameText) {
            loginPopUpView.passwordText.becomeFirstResponder()
        } else {
            loginPopUpView.userNameText.resignFirstResponder()
            loginPopUpView.passwordText.resignFirstResponder()
        }
        return true
    }
    //MARK: Header delegates
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
    //MARK: WebServiceCall
    func getCulturePassTokenFromServer(login: Bool? = false) {
        _ = Alamofire.request(QatarMuseumRouter.GetToken(["name": loginPopUpView.userNameText.text!,"pass":loginPopUpView.passwordText.text!])).responseObject { (response: DataResponse<TokenData>) -> Void in
            switch response.result {
            case .success(let data):
                self.accessToken = data.accessToken
//                UserDefaults.standard.set(data.accessToken, forKey: "accessToken")
                //self.loginPopUpView.loadingView.stopLoading()
               // self.loginPopUpView.loadingView.isHidden = true
                if(login == true) {
                    self.getCulturePassLoginFromServer()
                } else {
                    self.setNewPassword()
                }
                
            case .failure( _):
                self.loginPopUpView.loadingView.stopLoading()
                self.loginPopUpView.loadingView.isHidden = true
            }
        }
    }
    
    func getCulturePassLoginFromServer() {
        let titleString = NSLocalizedString("WEBVIEW_TITLE",comment: "Set the title for Alert")
        if(accessToken != nil) {
            _ = Alamofire.request(QatarMuseumRouter.Login(["name" : loginPopUpView.userNameText.text!,"pass": loginPopUpView.passwordText.text!])).responseObject { (response: DataResponse<LoginData>) -> Void in
                switch response.result {
                case .success(let data):
                    self.loginPopUpView.loadingView.stopLoading()
                    self.loginPopUpView.loadingView.isHidden = true
                    if(response.response?.statusCode == 200) {
                        self.loginArray = data
                        UserDefaults.standard.setValue(self.loginArray?.token, forKey: "accessToken")
                        if(self.loginArray != nil) {
                            if(self.loginArray?.user != nil) {
                                if(self.loginArray?.user?.uid != nil) {
                                    self.checkRSVPUserFromServer(userId: self.loginArray?.user?.uid )
                                }
                            }
                        }
                        //self.loadProfilepage(loginInfo: self.loginArray)
                    } else if(response.response?.statusCode == 401) {
                        showAlertView(title: titleString, message: NSLocalizedString("WRONG_USERNAME_OR_PWD",comment: "Set the message for wrong username or password"), viewController: self)
                    } else if(response.response?.statusCode == 406) {
                        showAlertView(title: titleString, message: NSLocalizedString("ALREADY_LOGGEDIN",comment: "Set the message for Already Logged in"), viewController: self)
                    }
                    
                case .failure( _):
                    self.loginPopUpView.loadingView.stopLoading()
                    self.loginPopUpView.loadingView.isHidden = true
                    
                }
            }

        }
    }
    
    func setNewPassword() {
        let titleString = NSLocalizedString("WEBVIEW_TITLE",comment: "Set the title for Alert")
        if(accessToken != nil) {
            _ = Alamofire.request(QatarMuseumRouter.NewPasswordRequest(["name" : loginPopUpView.userNameText.text!])).responseData { (response) -> Void in
                switch response.result {
                case .success( _):
                    self.loginPopUpView.loadingView.stopLoading()
                    self.loginPopUpView.loadingView.isHidden = true
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    if(response.response?.statusCode == 200) {
                        self.loadSuccessMessage()
                    } else if(response.response?.statusCode == 406) {
                        showAlertView(title: titleString, message: NSLocalizedString("INVALID_USERNAME",comment: "Set the message for invalid username or email id"), viewController: self)
                    }
                case .failure( _):
                    self.loginPopUpView.loadingView.stopLoading()
                    self.loginPopUpView.loadingView.isHidden = true
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                }
            }
            
        }
    }
    //RSVP Service call
    func checkRSVPUserFromServer(userId: String?) {
        _ = Alamofire.request(QatarMuseumRouter.GetUser(userId!)).responseObject { (response: DataResponse<UserInfoData>) -> Void in
            switch response.result {
            case .success(let data):
                self.loginPopUpView.loadingView.stopLoading()
                self.loginPopUpView.loadingView.isHidden = true
                if(response.response?.statusCode == 200) {
                    self.userInfoArray = data
                    
                    if(self.userInfoArray != nil) {
                        if(self.userInfoArray?.fieldRsvpAttendance != nil) {
                            let undData = self.userInfoArray?.fieldRsvpAttendance!["und"] as! NSArray
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
                    
                    self.loadProfilepage(loginInfo: self.loginArray)
                }
            case .failure( _):
                self.loginPopUpView.loadingView.stopLoading()
                self.loginPopUpView.loadingView.isHidden = true
                
            }
        }
    }
    //MARK : NMoQ EntityRegistratiion
    func getEventListUserRegistrationFromServer() {
        if((accessToken != nil) && (UserDefaults.standard.value(forKey: "uid") != nil)){
            let userId = UserDefaults.standard.value(forKey: "uid") as! String
            _ = Alamofire.request(QatarMuseumRouter.NMoQEventListUserRegistration(["user_id" : userId])).responseObject { (response: DataResponse<NMoQUserEventListValues>) -> Void in
                switch response.result {
                case .success(let data):
                    self.userEventList = data.eventList
                    self.saveOrUpdateEventReistratedCoredata()
                case .failure( _):
                    self.loginPopUpView.removeFromSuperview()
                    self.loginPopUpView.loadingView.stopLoading()
                    self.loginPopUpView.loadingView.isHidden = true
                    
                }
            }
            
        }
    }
    //MARK: EventRegistrationCoreData
    func saveOrUpdateEventReistratedCoredata() {
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
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            if (userEventList.count > 0) {
                for i in 0 ... userEventList.count-1 {
                    let userEventInfo: RegisteredEventListEntity = NSEntityDescription.insertNewObject(forEntityName: "RegisteredEventListEntity", into: managedContext) as! RegisteredEventListEntity
                    let userEventListDict = userEventList[i]
                    userEventInfo.eventId = userEventListDict.eventID
                    userEventInfo.regId = userEventListDict.regID
                    do{
                        try managedContext.save()
                    }
                    catch{
                        print(error)
                    }
                }
            }
        }
    }

}
