//
//  ProfileViewController.swift
//  QatarMuseum
//
//  Created by Exalture on 10/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import Firebase
import Kingfisher
import UIKit
import KeychainSwift
import CocoaLumberjack

class ProfileViewController: UIViewController,HeaderViewProtocol,comingSoonPopUpProtocol {
    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var viewmyCulturePassButton: UIButton!
    @IBOutlet weak var viewMyFavoriteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var membershipNumText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var dateOfBirthText: UILabel!
    @IBOutlet weak var countryText: UILabel!
    @IBOutlet weak var nationalityText: UILabel!
    @IBOutlet weak var userNameText: UITextView!
    @IBOutlet weak var membershipNumKeyLabel: UILabel!
    @IBOutlet weak var emailKeyLabel: UILabel!
    @IBOutlet weak var dateOfBirthKeyLabel: UILabel!
    @IBOutlet weak var countryKeyLabel: UILabel!
    @IBOutlet weak var nationalityKeyLabel: UILabel!
    //VIP Inviation controls
    var membershipNum = Int()
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var fromHome : Bool = false
    var loginInfo : LoginData?
    var logoutToken : String? = nil
    var countryListsArray : NSArray!
    var fromCulturePass : Bool = false
    var userId: String? = nil
    var countryDictArabic : NSDictionary!
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            getCountryListsFromJson()
        } else {
           getCountryListsArabicFromJson()
        }
        setUpProfileUI()
        self.recordScreenView()
    }

    func setUpProfileUI() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        headerView.headerViewDelegate = self
        headerView.headerTitle.text = NSLocalizedString("PROFILE_TITLE", comment: "PROFILE_TITLE Label in the PROFILE page")
        headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        profileImageView.image = UIImage(named: "profile_pic_round")
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
            membershipNumKeyLabel.textAlignment = .right
            emailKeyLabel.textAlignment = .right
            dateOfBirthKeyLabel.textAlignment = .right
            countryKeyLabel.textAlignment = .right
            nationalityKeyLabel.textAlignment = .right
            membershipNumText.textAlignment = .left
            emailText.textAlignment = .left
            dateOfBirthText.textAlignment = .left
            countryText.textAlignment = .left
            nationalityText.textAlignment = .left
        }
        headerView.settingsButton.isHidden = false
        headerView.settingsButton.setImage(UIImage(named: "logoutX1"), for: .normal)
        userNameText.font = UIFont.collectionSubTitleFont
        membershipNumKeyLabel.font = UIFont.settingResetButtonFont
        emailKeyLabel.font = UIFont.settingResetButtonFont
        dateOfBirthKeyLabel.font = UIFont.settingResetButtonFont
        countryKeyLabel.font = UIFont.settingResetButtonFont
        nationalityKeyLabel.font = UIFont.settingResetButtonFont
        
        
        membershipNumText.font = UIFont.sideMenuLabelFont
        emailText.font = UIFont.sideMenuLabelFont
        dateOfBirthText.font = UIFont.sideMenuLabelFont
        countryText.font = UIFont.sideMenuLabelFont
        nationalityText.font = UIFont.sideMenuLabelFont
        nationalityText.font = UIFont.sideMenuLabelFont
        
        viewmyCulturePassButton.titleLabel?.font = UIFont.settingResetButtonFont
        viewMyFavoriteButton.titleLabel?.font = UIFont.settingResetButtonFont
        
        membershipNumKeyLabel.text =  NSLocalizedString("MEMBERSHIP_NUMBER", comment: "MEMBERSHIP_NUMBER in the Profile page")
        emailKeyLabel.text =  NSLocalizedString("EMAIL", comment: "EMAIL in the Profile page")
        dateOfBirthKeyLabel.text =  NSLocalizedString("DATE_OF_BIRTH", comment: "DATE_OF_BIRTH in the Profile page")
        countryKeyLabel.text =  NSLocalizedString("COUNTRY", comment: "COUNTRY in the Profile page")
        nationalityKeyLabel.text =  NSLocalizedString("NATIONALITY", comment: "NATIONALITY in the Profile page")
        viewmyCulturePassButton.setTitle(NSLocalizedString("VIEW_MY_CULTUREPASS_CARD", comment: "VIEW_MY_CULTUREPASS_CARD in the Profile page"), for: .normal)
        
        self.setProfileInfo()
        
    }
    func setProfileInfo() {
        if((keychain.get(UserProfileInfo.user_dispaly_name) != nil) && (keychain.get(UserProfileInfo.user_dispaly_name) != "")) {
            userNameText.text = (keychain.get(UserProfileInfo.user_dispaly_name))?.uppercased()
        }
        if((keychain.get(UserProfileInfo.user_photo) != nil) && (keychain.get(UserProfileInfo.user_photo) != "")) {
            if let imageUrl = (keychain.get(UserProfileInfo.user_photo)) {
                profileImageView.kf.setImage(with: URL(string: imageUrl))
            }
            if (profileImageView.image == nil){
                profileImageView.image = UIImage(named: "profile_pic_round")
            }
        }
        
        if((keychain.get(UserProfileInfo.user_id) != nil) && (keychain.get(UserProfileInfo.user_id) != "") && (keychain.get(UserProfileInfo.user_id) != nil) && (keychain.get(UserProfileInfo.user_id) != "")) {
            membershipNum = Int(keychain.get(UserProfileInfo.user_id)!)! + 006000
            
            membershipNumText.text = "00" + String(membershipNum)
            userId = keychain.get(UserProfileInfo.user_id)
        }
        if((keychain.get(UserProfileInfo.user_email) != nil) && (keychain.get(UserProfileInfo.user_email) != "") && (keychain.get(UserProfileInfo.user_email) != nil) && (keychain.get(UserProfileInfo.user_email) != "")) {
            emailText.text = keychain.get(UserProfileInfo.user_email)
        }
        if((keychain.get(UserProfileInfo.user_dob) != nil) && (keychain.get(UserProfileInfo.user_dob) != "") && (keychain.get(UserProfileInfo.user_dob) != nil) && (keychain.get(UserProfileInfo.user_dob) != "")) {
            dateOfBirthText.text = (keychain.get(UserProfileInfo.user_dob))
        }
        if((keychain.get(UserProfileInfo.user_country) != nil) && (keychain.get(UserProfileInfo.user_country) != "") && (keychain.get(UserProfileInfo.user_country) != nil) && (keychain.get(UserProfileInfo.user_country) != "")) {
            let countryKey = (keychain.get(UserProfileInfo.user_country))
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                if(countryListsArray != nil) {
                    for country in countryListsArray {
                        let countryDict = country as! NSDictionary
                        if(countryDict["alpha-2"] as? String == countryKey) {
                            countryText.text = countryDict["name"] as? String
                        }
                    }
                }
            } else {
                if(countryDictArabic != nil) {
                    if( countryDictArabic[countryKey!] != nil) {
                        countryText.text = countryDictArabic[countryKey!] as? String
                    }
                }
            }
        }
        if(keychain.get(UserProfileInfo.user_nationality) != nil) && (keychain.get(UserProfileInfo.user_nationality) != "") {
            let nationalityKey = (keychain.get(UserProfileInfo.user_nationality))
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            if(countryListsArray != nil) {
                for country in countryListsArray {
                    let countryDict = country as! NSDictionary
                    if(countryDict["alpha-2"] as? String == nationalityKey) {
                        nationalityText.text = countryDict["name"] as? String
                    }
                }
            }
            } else {
                if(countryDictArabic != nil) {
                    if( countryDictArabic[nationalityKey!] != nil) {
                        nationalityText.text = countryDictArabic[nationalityKey!] as? String
                    }
                }
            }
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) +
            "Function: \(#function)" +
            "Language: \(LocalizationLanguage.currentAppleLanguage())" +
            "User: \(String(describing: userNameText.text))" +
            "MembershipNumber: \(membershipNum)" +
            "User Id: \(String(describing: userId))" +
            "email: \(String(describing: emailText.text))" +
            "DOB: \(String(describing: dateOfBirthText.text))" +
            "Country: \(String(describing: countryText.text))" +
            "Nationality: \(String(describing: nationalityText))")
    }
    //MARK: Service call
    func getCountryListsFromJson(){
        let url = Bundle.main.url(forResource: "CountryList", withExtension: "json")
        let dataObject = NSData(contentsOf: url!)
        if let jsonObj = try? JSONSerialization.jsonObject(with: dataObject! as Data, options: .allowFragments) as? NSDictionary {
            countryListsArray = jsonObj!.value(forKey: "countryLists")
                as? NSArray
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    func getCountryListsArabicFromJson(){
        let url = Bundle.main.url(forResource: "CountryListArabic", withExtension: "json")
        let dataObject = NSData(contentsOf: url!)
        if let jsonObj = try? JSONSerialization.jsonObject(with: dataObject! as Data, options: .allowFragments) as? NSDictionary {
            countryDictArabic = jsonObj
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func loadComingSoonPopup() {
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadPopup()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.view.addSubview(popupView)
    }
    func closeButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.popupView.removeFromSuperview()
    }
    @IBAction func didTapViewMyFavoriteButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        loadComingSoonPopup()
        self.viewMyFavoriteButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        
    }
    @IBAction func viewMyFavoriteButtonTouchDown(_ sender: UIButton) {
         self.viewMyFavoriteButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    @IBAction func didTapViewMyCulturePassCard(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.viewmyCulturePassButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.performSegue(withIdentifier: "profileToCultureCardSegue", sender: self)
    }
    @IBAction func viewMyCulturePassButtonTouchDown(_ sender: UIButton) {
        self.viewmyCulturePassButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @IBAction func didTapProfileEditButton(_ sender: UIButton) {
        self.editButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        loadComingSoonPopup()
    }
    @IBAction func editButtonTouchDown(_ sender: UIButton) {
        self.editButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    //MARK: headerView Protocol
    func headerCloseButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
            let appDelegate = UIApplication.shared.delegate
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController
            appDelegate?.window??.rootViewController = homeViewController
    }
    
    //MARK: WebServiceCall
    /* logout when click on the logout button */
    func filterButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function) + Action: Logout")
        if(UserDefaults.standard.value(forKey: "accessToken") as? String != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.Logout()).responseObject { (response: DataResponse<LogoutData>) -> Void in
                switch response.result {
                case .success( _):
                    if(response.response?.statusCode == 200) {
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                        UserDefaults.standard.removeObject(forKey: "acceptOrDecline")

                        
                        self.keychain.set("", forKey: UserProfileInfo.user_id)
                        self.keychain.set("", forKey: UserProfileInfo.user_email)
                        self.keychain.set("", forKey: UserProfileInfo.user_dispaly_name)
                        self.keychain.set("", forKey: UserProfileInfo.user_dob)
                        self.keychain.set("", forKey: UserProfileInfo.user_country)
                        self.keychain.set("", forKey: UserProfileInfo.user_nationality)
                        self.keychain.set("", forKey: UserProfileInfo.user_photo)
                        
                        self.keychain.delete(UserProfileInfo.user_firstname)
                        self.keychain.delete(UserProfileInfo.user_lastname)// Remove single key

                        if((UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != nil) && (UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != "")) {
                            let managedContext = getContext()
                            self.deleteExistingEvent(managedContext: managedContext, entityName: "RegisteredEventListEntity")
                        }
                        
                        if let presenter = self.presentingViewController as? CulturePassViewController {
                            presenter.fromHome = true
                            presenter.fromProfile = true
                            self.dismiss(animated: false, completion: nil)
                        } else {
                            let culturePassView =  self.storyboard?.instantiateViewController(withIdentifier: "culturePassViewId") as! CulturePassViewController
                            culturePassView.fromHome = true
                            culturePassView.fromProfile = true
                            self.present(culturePassView, animated: false, completion: nil)
                        }
                        
                    } else {
                        showAlertView(title: NSLocalizedString("WEBVIEW_TITLE", comment: "WEBVIEW_TITLE in profile page"), message: NSLocalizedString("LOGOUT_ERROR", comment: "LOGOUT_ERROR in profile page"), viewController: self)
                    }
                case .failure( _):
                    self.view.hideAllToasts()
                    let logOutFailture =  NSLocalizedString("LOGOUT_ERROR", comment: "LOGOUT_ERROR")
                    self.view.makeToast(logOutFailture)
                    
                }
            }
        } else {
            showAlertView(title: NSLocalizedString("WEBVIEW_TITLE", comment: "WEBVIEW_TITLE in profile page"), message: NSLocalizedString("LOGOUT_ERROR", comment: "LOGOUT_ERROR in profile page"), viewController: self)
        }
    }
    func deleteExistingEvent(managedContext:NSManagedObjectContext,entityName : String?)  {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName!)
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
            
        }catch _ as NSError {
        }
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(PROFILE_VC, screenClass: screenClass)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "profileToCultureCardSegue") {
            let culturepassCard = segue.destination as! CulturePassCardViewController
//            if((UserDefaults.standard.value(forKey: "uid") as? String != nil) && (UserDefaults.standard.value(forKey: "uid") as? String != "") ) {
//                culturepassCard.membershipNumber = "00" + String(membershipNum)
//            }
//            if((UserDefaults.standard.value(forKey: "displayName") as? String != nil) && (UserDefaults.standard.value(forKey: "displayName") as? String != "")) {
//                culturepassCard.nameString = (UserDefaults.standard.value(forKey: "displayName") as? String)
//            }
            if((keychain.get(UserProfileInfo.user_id) != nil) && (keychain.get(UserProfileInfo.user_id) != "")) {
                culturepassCard.membershipNumber = "00" + String(membershipNum)
            }
            if((keychain.get(UserProfileInfo.user_dispaly_name) != nil) && (keychain.get(UserProfileInfo.user_dispaly_name) != "")) {
                culturepassCard.nameString = (keychain.get(UserProfileInfo.user_dispaly_name))
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
