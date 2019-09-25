//
//  CPHomeViewController.swift
//  QatarMuseum
//
//  Created by Wakralab Software Labs on 06/06/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//


import UIKit
import Firebase
import KeychainSwift


enum CPHomePageName {
    case diningList
    case parksList
    case heritageList
    case exhibitionList
    case tourguideList
    case publicArtsList
    case panelAndTalksList
    case notificationsList
    case eventList
    case educationList
    case profilePage
    case museumLandingPage
    case bannerMuseumLandingPage
}

class CPHomeViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var buyYourTicketsLabel: UILabel!
    
    @IBOutlet weak var restaurantButton: UIButton!
    @IBOutlet weak var giftShopButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var culturePassButton: UIButton!
    
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var topbarView: CPTopBarView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var giftShopLabel: UILabel!
    @IBOutlet weak var culturePassLabel: UILabel!
    @IBOutlet weak var diningLabel: UILabel!
    
    
    var homeDataFullArray : NSArray!
    var effect:UIVisualEffect!
    var popupView : CPComingSoonPopUp = CPComingSoonPopUp()
    var sideView : CPSideMenuView = CPSideMenuView()
    var isSideMenuLoaded : Bool = false
    var homeList: [CPHome]! = []
    var homeEntity: HomeEntity?
    let networkReachability = NetworkReachabilityManager()
    var homeDBArray:[HomeEntity]?
    var apnDelegate : CPAPNProtocol?
    let imageView = UIImageView()
    var blurView = UIVisualEffectView()
    var imgButton = UIButton()
    var imgLabel = UITextView()
    var homeBannerList: [CPHomeBanner]! = []
    var loginPopUpView : CPLoginPopupPage = CPLoginPopupPage()
    var accessToken : String? = nil
    var loginArray : CPLoginData?
    var userInfoArray : UserInfoData?
    var userEventList: [CPNMoQUserEventList] = []
    var alreadyFetch : Bool? = false
    var selectedRow : Int? = 0
    var homePageNameString : CPHomePageName?
    let keychain = KeychainSwift()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ((CPLocalizationLanguage.currentAppleLanguage()) == "en") {
            buyYourTicketsLabel.font = UIFont.init(name: "DINNextLTPro-Bold", size: 17)!
        } else{
            buyYourTicketsLabel.font = UIFont.init(name: "DINNextLTArabic-Bold", size:18)!
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        registerNib()
        setUpUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedNotification(notification:)), name: NSNotification.Name("NotificationIdentifier"), object: nil)
        
        self.recordScreenView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
//        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
//            buyYourTicketsLabel.font = UIFont.init(name: "DINNextLTPro-Bold", size: 17)!
//        } else{
//            buyYourTicketsLabel.font = UIFont.init(name: "DINNextLTArabic-Bold", size:18)!
//        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setUpUI() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        topbarView.topbarDelegate = self
        topbarView.backButton.isHidden = true
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
        loadingView.isHidden = false
        loadingView.loadingViewDelegate = self
        loadingView.showLoading()
        moreLabel.text = NSLocalizedString("MORE",comment: "MORE in Home Page")
        culturePassLabel.text = NSLocalizedString("CULTUREPASS_TITLE",comment: "CULTUREPASS_TITLE in Home Page")
        giftShopLabel.text = NSLocalizedString("GIFT_SHOP",comment: "GIFT_SHOP in Home Page")
        diningLabel.text = NSLocalizedString("DINING_LABEL",comment: "DINING_LABEL in Home Page")
        
        moreLabel.font = UIFont.exhibitionDateLabelFont
        culturePassLabel.font = UIFont.exhibitionDateLabelFont
        giftShopLabel.font = UIFont.exhibitionDateLabelFont
        diningLabel.font = UIFont.exhibitionDateLabelFont
        /* Just Commented for New Release
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            if(UserDefaults.standard.value(forKey: "firstTimeLaunch") as? String == nil) {
                loadingView.isHidden = false
                loadingView.showLoading()
                if (networkReachability?.isReachable)! {
                    loadLoginPopup()
                    UserDefaults.standard.set("false", forKey: "firstTimeLaunch")
                } else {
                    showNoNetwork()
                }
            } else {
                if (networkReachability?.isReachable)! {
                    getHomeBanner()
                } else {
                    fetchHomeBannerInfoFromCoredata()
                }
            }
        }
        */
        NotificationCenter.default.addObserver(self, selector: #selector(CPHomeViewController.receiveHomePageNotificationEn(notification:)), name: NSNotification.Name(homepageNotificationEn), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CPHomeViewController.receiveHomePageNotificationAr(notification:)), name: NSNotification.Name(homepageNotificationAr), object: nil)
        self.fetchHomeInfoFromCoredata()
    }
    
    func setTopImageUI() {
       DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        homeTableView.contentInset = UIEdgeInsetsMake(120, 0, 0, 0)
        if(UIScreen.main.bounds.height == 812) {
            imageView.frame = CGRect(x: 0, y: 108, width: UIScreen.main.bounds.size.width, height: 120)
        } else {
            imageView.frame = CGRect(x: 0, y: 85, width: UIScreen.main.bounds.size.width, height: 120)
        }
        
        imageView.backgroundColor = UIColor.white
            if homeBannerList.count > 0 {

                if let imageUrl = homeBannerList[0].bannerLink {
                    if(imageUrl != "") {
                        imageView.kf.setImage(with: URL(string: imageUrl))
                    }else {
                        imageView.image = UIImage(named: "default_imageX2")
                    }
                }
                else {
                    imageView.image = UIImage(named: "default_imageX2")
                }
            }
            else {
                imageView.image = nil
            }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        if(homeBannerList[0].bannerTitle != nil) {
            imgLabel.text = homeBannerList[0].bannerTitle
        }
        imgLabel.textAlignment = .center
        imgLabel.scrollsToTop = false
        imgLabel.isEditable = false
        imgLabel.isScrollEnabled = false
        imgLabel.isSelectable = false
        imgLabel.backgroundColor = UIColor.clear
        imgLabel.font = UIFont.eventPopupTitleFont
        if(UIScreen.main.bounds.height == 812) {
            imgLabel.frame = CGRect(x: 0, y: 130, width: UIScreen.main.bounds.size.width, height: 90)
        } else {
            imgLabel.frame = CGRect(x: 0, y: 95, width: UIScreen.main.bounds.size.width, height: 90)
        }
        self.view.addSubview(imgLabel)
        imgButton.setTitle("", for: .normal)
        imgButton.setTitleColor(UIColor.blue, for: .normal)
        imgButton.frame = imageView.frame
        imgButton.addTarget(self, action: #selector(self.imgButtonPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(imgButton)
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = imageView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        imageView.addSubview(blurView)
        self.view.layoutIfNeeded()
        
        
    }
    
    @objc func imgButtonPressed(sender: UIButton!) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.performSegue(withIdentifier: "homeToMuseumLandingSegue", sender: self)
//        let museumsView =  self.storyboard?.instantiateViewController(withIdentifier: "museumViewId") as! MuseumsViewController
//        museumsView.fromHomeBanner = true
//        museumsView.museumTitleString = homeBannerList[0].bannerTitle
//        let transition = CATransition()
//        transition.duration = 0.25
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromRight
//        view.window!.layer.add(transition, forKey: kCATransition)
//        self.present(museumsView, animated: false, completion: nil)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 120 - (scrollView.contentOffset.y + 120)
        let height = min(max(y, 0), 120)
        if(UIScreen.main.bounds.height == 812) {
            imageView.frame = CGRect(x: 0, y: 108, width: UIScreen.main.bounds.size.width, height: height)
            imgButton.frame = imageView.frame
            imgLabel.frame = CGRect(x: 0, y: 130, width: UIScreen.main.bounds.size.width, height: height-10)
        }else {
            imageView.frame = CGRect(x: 0, y: 85, width: UIScreen.main.bounds.size.width, height: height)
            imgButton.frame = imageView.frame
            imgLabel.frame = CGRect(x: 0, y: 95, width: UIScreen.main.bounds.size.width, height: height-10)
        }

        if (imageView.frame.height >= 120 ){
            blurView.alpha  = 0.0
        } else if (imageView.frame.height >= 100 ){
            blurView.alpha  = 0.2
        } else if (imageView.frame.height >= 80 ){
            blurView.alpha  = 0.4
        } else if (imageView.frame.height >= 60 ){
            blurView.alpha  = 0.6
        } else if (imageView.frame.height >= 40 ){
            blurView.alpha  = 0.8
        } else if (imageView.frame.height >= 20 ){
            blurView.alpha  = 0.9
        }
    }
    @objc func receivedNotification(notification: CPNotification) {
        homePageNameString = CPHomePageName.notificationsList
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.performSegue(withIdentifier: "homeToNotificationSegue", sender: self)
//        let notificationsView =  self.storyboard?.instantiateViewController(withIdentifier: "notificationId") as! NotificationsViewController
//        notificationsView.fromHome = true
//        self.present(notificationsView, animated: false, completion: nil)
    }
    func registerNib() {
        self.homeTableView.register(UINib(nibName: "CommonListCellXib", bundle: nil), forCellReuseIdentifier: "commonListCellId")
        self.homeTableView.register(UINib(nibName: "NMoHeaderView", bundle: nil), forCellReuseIdentifier: "bannerCellId")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   
    func loadMuseumsPage(curretRow:Int? = 0) {
        let museumsView =  self.storyboard?.instantiateViewController(withIdentifier: "museumViewId") as! CPMuseumsViewController
        museumsView.museumId = homeList[curretRow!].id
        museumsView.museumTitleString = homeList[curretRow!].name
        museumsView.fromHomeBanner = false
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_item,
            AnalyticsParameterItemName: museumsView.museumTitleString ?? "",
            AnalyticsParameterContentType: "home_screen"
            ])
        
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(museumsView, animated: false, completion: nil)
        
    }
    
    func loadExhibitionPage() {
        let exhibitionView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CPCommonListViewController
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        exhibitionView.exhibitionsPageNameString = CPExhbitionPageName.homeExhibition
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_exhibition_item,
            AnalyticsParameterItemName: exhibitionView.exhibitionsPageNameString ?? "",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(exhibitionView, animated: false, completion: nil)
    }
    
    func loadComingSoonPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        popupView  = CPComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadPopup()
        self.view.addSubview(popupView)
    }
    
    func updateNotificationBadge() {
        topbarView.updateNotificationBadgeCount()
    }
    
    //MARK: Service call
    func getHomeList() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.HomeList(CPLocalizationLanguage.currentAppleLanguage()))
            .responseObject { [weak self] (response: DataResponse<HomeList>) -> Void in
            switch response.result {
            case .success(let data):
                if((self?.homeList.count == 0) || (self?.homeList.count == 1)) {
                    self?.homeList = data.homeList
                    /* Just Commented for New Release
                    let panelAndTalksName = NSLocalizedString("PANEL_AND_TALKS",comment: "PANEL_AND_TALKS in Home Page")
                    if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                        let panelAndTalks = "Panels And Talks".lowercased()
                        if self.homeList.index(where: {$0.name?.lowercased() != panelAndTalks}) != nil {
                            
                            self.homeList.insert(Home(id: "13976", name: panelAndTalksName.uppercased(), image: "panelAndTalks", tourguide_available: "false", sort_id: "10"), at: self.homeList.endIndex)
                        }
                    } else {
                        let panelAndTalks = "قطر تبدع: فعاليات افتتاح متحف قطر الوطني"
                        if self.homeList.index(where: {$0.name != panelAndTalks}) != nil {
                            self.homeList.insert(Home(id: "15631", name: panelAndTalksName, image: "panelAndTalks", tourguide_available: "false", sort_id: "10"), at: self.homeList.endIndex)
                        }
                    }
*/
                    if let nilItem = self?.homeList.first(where: {$0.sortId == "" || $0.sortId == nil}) {
                        print(nilItem)
                    } else {
                        self?.homeList = self?.homeList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                    if let count = self?.homeBannerList.count, count > 0 {
                        self?.homeList.insert(CPHome(id:self?.homeBannerList[0].fullContentID , name: self?.homeBannerList[0].bannerTitle,image: self?.homeBannerList[0].bannerLink,
                                                  tourguide_available: "false", sort_id: nil),
                                             at: 0)
                    }

                    if((self?.homeList.count == 0) || (self?.homeList.count == 1)) {
                        self?.loadingView.stopLoading()
                        self?.loadingView.noDataView.isHidden = false
                        self?.loadingView.isHidden = false
                        self?.loadingView.showNoDataView()
                    }
                    
                    self?.homeTableView.reloadData()
                }
//                if(self?.homeList.count > 0) {
                   // self.saveOrUpdateHomeCoredata(homeList: data.homeList)
//                }
            case .failure( _):
                if((self?.homeList.count == 0) || (self?.homeList.count == 1)) {
                    self?.loadingView.stopLoading()
                    self?.loadingView.noDataView.isHidden = false
                    self?.loadingView.isHidden = false
                    self?.loadingView.showNoDataView()
                }
            }
        }
    }
    func getHomeBanner() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.GetHomeBanner())
            .responseObject { [weak self] (response: DataResponse<HomeBannerList>) -> Void in
            switch response.result {
            case .success(let data):
                
                self?.homeBannerList = data.homeBannerList
                if let count = self?.homeBannerList.count,
                    (UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != nil) && (UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != "") &&
                    count > 0 {
                    if let count = self?.homeList.count, count > 0 {
                        self?.homeList.insert(CPHome(id:self?.homeBannerList[0].fullContentID , name: self?.homeBannerList[0].bannerTitle,image: self?.homeBannerList[0].bannerLink,
                                                  tourguide_available: "false", sort_id: nil),
                                             at: 0)
                    }
                    
                }
                if let count = self?.homeBannerList.count, count > 0 {
                    self?.saveOrUpdateHomeBannerCoredata()
                }
                self?.homeTableView.reloadData()
            case .failure( _):
            print("error")
            }
        }
    }
   
    @IBAction func buyTicketBtnAction(_ sender: Any) {
        var storyBoard = UIStoryboard()
        UserDefaults.standard.set(AppConstants.QMTLibConstants.QMTLTicketCounterContainerViewController, forKey: AppConstants.QMTLibConstants.initialViewControllerKey)
        let bundle = Bundle(identifier: AppConstants.QMTLibConstants.bundleId)
        storyBoard = UIStoryboard(name: AppConstants.QMTLibConstants.QMTStoryboardForEN_Id, bundle: bundle)
        let controller = storyBoard.instantiateViewController(withIdentifier:
            AppConstants.QMTLibConstants.QMTLTabViewController)
        //self.navigationController?.pushViewController(controller, animated: true)
        self.present(controller, animated: true, completion: nil)
    }
    //MARK: Bottombar Delegate
    @IBAction func didTapMoreButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.moreButton.transform = CGAffineTransform(scaleX: 1, y: 1)
         topbarMenuPressed()
    }
    
    @IBAction func moreButtonTouchDown(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.moreButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTaprestaurantButton(_ sender: UIButton) {
        self.restaurantButton.transform = CGAffineTransform(scaleX: 1, y: 1)
         homePageNameString = CPHomePageName.diningList
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.performSegue(withIdentifier: "homeToCommonListSegue", sender: self)
        self.culturePassButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        let diningView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CPCommonListViewController
         diningView.fromHome = true
         diningView.fromSideMenu = false
         diningView.exhibitionsPageNameString = CPExhbitionPageName.diningList
         let transition = CATransition()
         transition.duration = 0.25
         transition.type = kCATransitionPush
         transition.subtype = kCATransitionFromRight
         view.window!.layer.add(transition, forKey: kCATransition)
         Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "didTaprestaurantButton_from_Home_Menu",
            AnalyticsParameterContentType: "home_screen"
            ])
         self.present(diningView, animated: false, completion: nil)
    }
    
    @IBAction func restaurantButtonTouchDown(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.restaurantButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTapCulturePass(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        culturePassButtonPressed()
        self.culturePassButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func culturePassTouchDown(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.culturePassButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTapGiftShopButton(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        giftShopButtonPressed()
        self.giftShopButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func giftShopButtonTouchDown(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.giftShopButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func topbarMenuPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.topbarView.menuButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 18)
        var sideViewFrame = CGRect()
        if (UIScreen.main.bounds.height >= 812) {
            sideViewFrame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: self.view.bounds.height)
        } else {
            sideViewFrame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.bounds.height)
        }
        sideView  = CPSideMenuView(frame: sideViewFrame)
        self.view.addSubview(sideView)
        
        sideView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        sideView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.visualEffectView.isHidden = false
            self.visualEffectView.effect = self.effect
            self.sideView.alpha = 1
            self.sideView.transform = CGAffineTransform.identity
            self.sideView.topBarView.menuButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 20)
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "topbarMenuPressed_from_Home",
            AnalyticsParameterContentType: "home_screen"
            ])
        sideView.sideMenuDelegate = self
        
    }
    
    func topBarEventButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        homePageNameString = CPHomePageName.eventList
        self.performSegue(withIdentifier: "homeToEventSegue", sender: self)
    }
    
    func topBarProfileButtonPressed() {
        let profileView =  self.storyboard?.instantiateViewController(withIdentifier: "profileViewId") as! CPProfileViewController
        profileView.fromHome = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "topBarProfileButtonPressed_from_Home",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(profileView, animated: false, completion: nil)
        
    }
    
    func setProfileDetails(loginInfo : CPLoginData?) {
        if (loginInfo != nil) {
            let userData = loginInfo?.user
            self.keychain.set(userData?.uid ?? "", forKey: UserProfileInfo.user_id)
            self.keychain.set(userData?.mail ?? "", forKey: UserProfileInfo.user_email)
            self.keychain.set(userData?.name ?? "", forKey: UserProfileInfo.user_dispaly_name)
            self.keychain.set(userData?.picture ?? "", forKey: UserProfileInfo.user_photo)
            
            if(userData?.fieldDateOfBirth != nil) {
                if((userData?.fieldDateOfBirth?.count)! > 0) {
                    self.keychain.set(userData?.fieldDateOfBirth![0] ?? "", forKey: UserProfileInfo.user_dob)

                }
            }
            let firstNameData = userData?.fieldFirstName["und"] as? NSArray
            if(firstNameData != nil && (firstNameData?.count)! > 0) {
                let name = firstNameData![0] as! NSDictionary
                if(name["value"] != nil) {
                    self.keychain.set(name["value"] as! String , forKey: UserProfileInfo.user_firstname)

                }
            }
            let lastNameData = userData?.fieldLastName["und"] as? NSArray
            if(lastNameData != nil && (lastNameData?.count)! > 0) {
                let name = lastNameData?[0] as! NSDictionary
                if(name["value"] != nil) {
                    self.keychain.set(name["value"] as! String , forKey: UserProfileInfo.user_lastname)

                }
            }
            let locationData = userData?.fieldLocation["und"] as! NSArray
            if(locationData.count > 0) {
                let iso = locationData[0] as! NSDictionary
                if(iso["iso2"] != nil) {
                    self.keychain.set(iso["iso2"] as! String , forKey: UserProfileInfo.user_country)

                }
                
            }
            
            let nationalityData = userData?.fieldNationality["und"] as! NSArray
            if(nationalityData.count > 0) {
                let nation = nationalityData[0] as! NSDictionary
                if(nation["iso2"] != nil) {
                    self.keychain.set(nation["iso2"] as! String, forKey: UserProfileInfo.user_nationality)

                }
            }
            let translationsData = userData?.translations["data"] as? NSDictionary
            if(translationsData != nil) {
                let arValues = translationsData?["ar"] as! NSDictionary
                if(arValues["entity_id"] != nil) {
                    self.keychain.set(arValues["entity_id"] as! String, forKey: UserProfileInfo.user_loginentity_id)

                }
            }
            
            
            
        }
        self.loginPopUpView.removeFromSuperview()
        getEventListUserRegistrationFromServer()
    }
    func loadTourViewPage(nid: String?,subTitle:String?,isFromTour:Bool?) {
        homePageNameString = CPHomePageName.panelAndTalksList
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.performSegue(withIdentifier: "homeToCommonListSegue", sender: self)
    }
    @objc func receiveHomePageNotificationEn(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((CPLocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (homeList.count == 0)){
            DispatchQueue.main.async{
                self.fetchHomeInfoFromCoredata()
            }
        }
        
    }
    @objc func receiveHomePageNotificationAr(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((CPLocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (homeList.count == 0)){
            DispatchQueue.main.async{
                self.fetchHomeInfoFromCoredata()
            }
        }
    }
    func recordScreenView() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(HOME, screenClass: screenClass)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

//MARK:- Segue extension
extension CPHomeViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "homeToCommonListSegue") {
            let commonList = segue.destination as! CPCommonListViewController
            if((homePageNameString == CPHomePageName.exhibitionList) && ((homeList[selectedRow!].id == "12181") || (homeList[selectedRow!].id == "12186"))){
                commonList.exhibitionsPageNameString = CPExhbitionPageName.homeExhibition
            } else if((homePageNameString == CPHomePageName.panelAndTalksList) && (homeList[selectedRow!].id == "13976") || (homeList[selectedRow!].id == "15631")) {
                commonList.tourDetailId = homeList[selectedRow!].id
                commonList.headerTitle = NSLocalizedString("PANEL_AND_TALKS",comment: "PANEL_AND_TALKS in Home Page")
                commonList.isFromTour = false
                commonList.exhibitionsPageNameString = CPExhbitionPageName.nmoqTourSecondList
            }  else if(homePageNameString == CPHomePageName.tourguideList){
                commonList.fromSideMenu = true
                commonList.exhibitionsPageNameString = CPExhbitionPageName.tourGuideList
            } else if(homePageNameString == CPHomePageName.diningList){
                commonList.fromHome = true
                commonList.fromSideMenu = false
                commonList.exhibitionsPageNameString = CPExhbitionPageName.diningList
            }
            
        } else if (segue.identifier == "homeToListFadeSegue") {
            let commonList = segue.destination as! CPCommonListViewController
            if(homePageNameString == CPHomePageName.exhibitionList){
                commonList.fromSideMenu = true
                commonList.exhibitionsPageNameString = CPExhbitionPageName.homeExhibition
            } else if(homePageNameString == CPHomePageName.diningList){
                commonList.fromHome = true
                commonList.fromSideMenu = true
                commonList.exhibitionsPageNameString = CPExhbitionPageName.diningList
            } else if(homePageNameString == CPHomePageName.heritageList){
                commonList.fromSideMenu = true
                commonList.exhibitionsPageNameString = CPExhbitionPageName.heritageList
            } else if(homePageNameString == CPHomePageName.publicArtsList){
                commonList.fromSideMenu = true
                commonList.exhibitionsPageNameString = CPExhbitionPageName.publicArtsList
            }
        }else if (segue.identifier == "homeToMuseumLandingSegue") {
            let museumsView = segue.destination as! CPMuseumsViewController
            
            if(homePageNameString == CPHomePageName.museumLandingPage){
                museumsView.museumId = homeList[selectedRow!].id
                museumsView.museumTitleString = homeList[selectedRow!].name
                museumsView.fromHomeBanner = false
            } else if(homePageNameString == CPHomePageName.bannerMuseumLandingPage){
                museumsView.fromHomeBanner = true
                museumsView.museumTitleString = homeBannerList[0].bannerTitle
                museumsView.bannerId = homeBannerList[0].fullContentID
                museumsView.bannerImageArray = homeBannerList[0].image
            } else {
                museumsView.fromHomeBanner = true
                museumsView.museumTitleString = homeBannerList[0].bannerTitle
            }
            
        }else if (segue.identifier == "homeToCulturepass") {
            let culturePass = segue.destination as! CPCulturePassViewController
            culturePass.fromHome = true
        } else if (segue.identifier == "homeToCommonDetail") {
            let commonDetail = segue.destination as! CommonDetailViewController
            commonDetail.pageNameString = PageName.SideMenuPark
        } else if (segue.identifier == "homeToNotificationSegue") {
            let notificationView = segue.destination as! CPNotificationsViewController
            notificationView.fromHome = true
        } else if(homePageNameString == CPHomePageName.eventList){
            let eventView = segue.destination as! CPEventViewController
            if (segue.identifier == "homeToEventSegue") {
                eventView.fromHome = true
                eventView.isLoadEventPage = true
            } else if (segue.identifier == "homeToEventFadeSegue") {
                eventView.fromHome = true
                eventView.isLoadEventPage = true
                eventView.fromSideMenu = true
            }
            
        } else if (segue.identifier == "homeToEducationFadeSegue") {
            let educationView = segue.destination as! CPEducationViewController
            educationView.fromSideMenu = true
        }else if (segue.identifier == "homeToWebViewSegue") {
            let webViewVc = segue.destination as! CPWebViewController
            let aboutUrlString = "https://inq-online.com/"
            if let aboutUrl = URL(string: aboutUrlString) {
                // show alert to choose app
                if UIApplication.shared.canOpenURL(aboutUrl as URL) {
                    webViewVc.webViewUrl = aboutUrl
                    webViewVc.titleString = NSLocalizedString("WEBVIEW_TITLE", comment: "WEBVIEW_TITLE  in the Webview")
                }
            }
        } else if (homePageNameString == CPHomePageName.profilePage) {
            let profileView = segue.destination as! CPProfileViewController
            if (segue.identifier == "homeToProfileSegue") {
                profileView.fromHome = true
                //homeToProfileSegue
                //homeToProfileFadeSegue
            }
        }
    }
}

//MARK:- ReusableView methods and delgates
extension CPHomeViewController: CPTopBarProtocol,CPComingSoonPopUpProtocol,CPSideMenuProtocol, LoadingViewProtocol,CPLoginPopUpProtocol {
    //MARK: Topbar Delegate
    func backButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    }
    
    func eventButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        topBarEventButtonPressed()
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "eventButtonPressed_from_Home",
            AnalyticsParameterContentType: "home_screen"
            ])
    }
    
    func notificationbuttonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        
        self.performSegue(withIdentifier: "homeToNotificationSegue", sender: self)
        //        let notificationsView =  self.storyboard?.instantiateViewController(withIdentifier: "notificationId") as! NotificationsViewController
        //        notificationsView.fromHome = true
        //        let transition = CATransition()
        //        transition.duration = 0.3
        //        transition.type = kCATransitionPush
        //        transition.subtype = kCATransitionFromRight
        //        view.window!.layer.add(transition, forKey: kCATransition)
        //        self.present(notificationsView, animated: false, completion: nil)
        let notificationsView =  self.storyboard?.instantiateViewController(withIdentifier: "notificationId") as! CPNotificationsViewController
        notificationsView.fromHome = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "notificationbuttonPressed_from_Home",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(notificationsView, animated: false, completion: nil)
    }
    
    func profileButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        culturePassButtonPressed()
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "profileButtonPressed_from_Home",
            AnalyticsParameterContentType: "home_screen"
            ])
    }
    
    func menuButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        topbarMenuPressed()
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "menuButtonPressed_from_Home",
            AnalyticsParameterContentType: "home_screen"
            ])
    }
    
    //MARK: Poup Delegate
    func closeButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "closeButtonPressed_from_Home",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.popupView.removeFromSuperview()
    }
    
    //MARK: SideMenu Delegates
    //    func exhibitionButtonPressed() {
    //        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    //        homePageNameString = HomePageName.exhibitionList
    //        self.performSegue(withIdentifier: "homeToListFadeSegue", sender: self)
    //    }
    //
    //    func eventbuttonPressed() {
    //        homePageNameString = HomePageName.eventList
    //        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    //        self.performSegue(withIdentifier: "homeToEventFadeSegue", sender: self)
    //    }
    //
    //    func educationButtonPressed() {
    //        homePageNameString = HomePageName.educationList
    //        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    //        self.performSegue(withIdentifier: "homeToEducationFadeSegue", sender: self)
    //    }
    //
    //    func tourGuideButtonPressed() {
    //        homePageNameString = HomePageName.tourguideList
    //        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    //        self.performSegue(withIdentifier: "homeToCommonListSegue", sender: self)
    //    }
    //
    //    func heritageButtonPressed() {
    //        homePageNameString = HomePageName.heritageList
    //        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    //        self.performSegue(withIdentifier: "homeToListFadeSegue", sender: self)
    //    }
    //
    //    func publicArtsButtonPressed() {
    //        homePageNameString = HomePageName.publicArtsList
    //        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    //        self.performSegue(withIdentifier: "homeToListFadeSegue", sender: self)
    //    }
    //
    //    func parksButtonPressed() {
    //        homePageNameString = HomePageName.parksList
    //        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    //        self.performSegue(withIdentifier: "homeToCommonDetail", sender: self)
    //    }
    //
    //    func diningButtonPressed() {
    //        homePageNameString = HomePageName.diningList
    //        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
    //        self.performSegue(withIdentifier: "homeToListFadeSegue", sender: self)
    
    func exhibitionButtonPressed() {
        let exhibitionView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CPCommonListViewController
        exhibitionView.fromSideMenu = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        exhibitionView.exhibitionsPageNameString = CPExhbitionPageName.homeExhibition
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "exhibitionButtonPressed_from_Home_Menu",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(exhibitionView, animated: false, completion: nil)
    }
    
    func eventbuttonPressed() {
        let eventView =  self.storyboard?.instantiateViewController(withIdentifier: "eventPageID") as! CPEventViewController
        eventView.fromHome = true
        eventView.isLoadEventPage = true
        eventView.fromSideMenu = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "eventbuttonPressed_from_Home_Menu",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(eventView, animated: false, completion: nil)
    }
    
    func educationButtonPressed() {
        let educationView =  self.storyboard?.instantiateViewController(withIdentifier: "educationPageID") as! CPEducationViewController
        educationView.fromSideMenu = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "educationButtonPressed_from_Home_Menu",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(educationView, animated: false, completion: nil)
    }
    
    func tourGuideButtonPressed() {
        let tourGuideView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CPCommonListViewController
        tourGuideView.fromSideMenu = true
        tourGuideView.exhibitionsPageNameString = CPExhbitionPageName.tourGuideList
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "tourGuideButtonPressed_from_Home_Menu",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(tourGuideView, animated: false, completion: nil)
    }
    
    func heritageButtonPressed() {
        let heritageView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CPCommonListViewController
        heritageView.fromSideMenu = true
        heritageView.exhibitionsPageNameString = CPExhbitionPageName.heritageList
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "heritageButtonPressed_from_Home_Menu",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(heritageView, animated: false, completion: nil)
    }
    
    func publicArtsButtonPressed() {
        let publicArtsView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CPCommonListViewController
        publicArtsView.fromSideMenu = true
        publicArtsView.exhibitionsPageNameString = CPExhbitionPageName.publicArtsList
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "publicArtsButtonPressed_from_Home_Menu",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(publicArtsView, animated: false, completion: nil)
    }
    
    func parksButtonPressed() {
        let parksView =  self.storyboard?.instantiateViewController(withIdentifier: "heritageDetailViewId") as! CommonDetailViewController
        parksView.pageNameString = PageName.SideMenuPark
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "parksButtonPressed_from_Home_Menu",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(parksView, animated: false, completion: nil)
    }
    
    func diningButtonPressed() {
        let diningView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CPCommonListViewController
        diningView.fromHome = true
        diningView.fromSideMenu = true
        diningView.exhibitionsPageNameString = CPExhbitionPageName.diningList
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "diningButtonPressed_from_Home_Menu",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(diningView, animated: false, completion: nil)
    }
    
    
    
    func culturePassButtonPressed() {
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        
        // New Ticketing Functionalty Implementation
        var storyBoard = UIStoryboard()
        UserDefaults.standard.set(AppConstants.QMTLibConstants.QMTLUserProfileTableViewController, forKey: AppConstants.QMTLibConstants.initialViewControllerKey)
        let bundle = Bundle(identifier: AppConstants.QMTLibConstants.bundleId)
        storyBoard = UIStoryboard(name: AppConstants.QMTLibConstants.QMTStoryboardForEN_Id, bundle: bundle)
        let controller = storyBoard.instantiateViewController(withIdentifier: AppConstants.QMTLibConstants.QMTLTabViewController)
        //self.navigationController?.pushViewController(controller, animated: true)
        self.present(controller, animated: true, completion: nil)
        
        
        // Old Ticketing Mechanism Implementation
        //        if (UserDefaults.standard.value(forKey: "accessToken") as? String != nil) {
        //            self.performSegue(withIdentifier: "homeToProfileFadeSegue", sender: self)
        //        } else {
        //            self.performSegue(withIdentifier: "homeToCulturepass", sender: self)
        //        }
    }
    
    func giftShopButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.performSegue(withIdentifier: "homeToWebViewSegue", sender: self)
    }
    
    func settingsButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.performSegue(withIdentifier: "homeToSettingsSegue", sender: self)
        //        FIXME: Below code loads webview rather than the settings page
        //                let aboutUrlString = "https://inq-online.com/"
        //        if let aboutUrl = URL(string: aboutUrlString) {
        //            // show alert to choose app
        //            if UIApplication.shared.canOpenURL(aboutUrl as URL) {
        //                let webViewVc:WebViewController = self.storyboard?.instantiateViewController(withIdentifier: "webViewId") as! WebViewController
        //                webViewVc.webViewUrl = aboutUrl
        //                webViewVc.titleString = NSLocalizedString("WEBVIEW_TITLE", comment: "WEBVIEW_TITLE  in the Webview")
        //                self.present(webViewVc, animated: false, completion: nil)
        //            }
        //
        //            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
        //                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
        //                AnalyticsParameterItemName: "giftShopButtonPressed_from_Home_Menu",
        //                AnalyticsParameterContentType: aboutUrlString
        //                ])
        //        }
    }
    
    func menuEventPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        topBarEventButtonPressed()
    }
    
    func menuNotificationPressed() {
        let notificationsView =  self.storyboard?.instantiateViewController(withIdentifier: "notificationId") as! CPNotificationsViewController
        notificationsView.fromHome = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "menuNotificationPressed_from_Home_Menu",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.present(notificationsView, animated: false, completion: nil)
    }
    
    func menuProfilePressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        topBarProfileButtonPressed()
    }
    
    func menuClosePressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        UIView.animate(withDuration: 0.4, animations: {
            self.sideView.transform = CGAffineTransform.init(scaleX:1 , y: 1)
            self.sideView.alpha = 0
        }) { (success:Bool) in
            self.visualEffectView.effect = nil
            self.visualEffectView.isHidden = true
            self.sideView.removeFromSuperview()
        }
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_button_item,
            AnalyticsParameterItemName: "menuClosePressed_from_Home_Menu",
            AnalyticsParameterContentType: "home_screen"
            ])
        self.topbarView.menuButton.setImage(UIImage(named: "side_menu_iconX1"), for: .normal)
        self.topbarView.menuButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
        sideView.sideMenuDelegate = self
    }
    
    func showNodata() {
        var errorMessage: String
        errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                        comment: "Setting the content of the alert"))
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoDataView()
        self.loadingView.noDataLabel.text = errorMessage
    }
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            appDelegate?.getHomeList(lang: CPLocalizationLanguage.currentAppleLanguage())
            if(UserDefaults.standard.value(forKey: "firstTimeLaunch") as? String == nil) {
                loadLoginPopup()
                UserDefaults.standard.set("false", forKey: "firstTimeLaunch")
            }
        }
    }
    //MARK: Login Details
    func loadLoginPopup() {
        loginPopUpView  = CPLoginPopupPage(frame: self.view.frame)
        loginPopUpView.loginPopupDelegate = self
        loginPopUpView.userNameText.delegate = self
        loginPopUpView.passwordText.delegate = self
        self.view.addSubview(loginPopUpView)
    }
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
}

//MARK:- TextField Delegate
extension CPHomeViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == loginPopUpView.userNameText) {
            loginPopUpView.passwordText.becomeFirstResponder()
        } else {
            loginPopUpView.userNameText.resignFirstResponder()
            loginPopUpView.passwordText.resignFirstResponder()
        }
        return true
    }
}
