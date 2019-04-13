//
//  HomeViewController.swift
//  QatarMuseum
//
//  Created by Exalture on 06/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import UIKit
import Firebase

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, TopBarProtocol,comingSoonPopUpProtocol,SideMenuProtocol,UIViewControllerTransitioningDelegate,LoadingViewProtocol,LoginPopUpProtocol,UITextFieldDelegate {
    

    @IBOutlet weak var restaurantButton: UIButton!
    @IBOutlet weak var giftShopButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var culturePassButton: UIButton!
    
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var topbarView: TopBarView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var giftShopLabel: UILabel!
    @IBOutlet weak var culturePassLabel: UILabel!
    @IBOutlet weak var diningLabel: UILabel!
    
    
    var homeDataFullArray : NSArray!
    var effect:UIVisualEffect!
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var sideView : SideMenuView = SideMenuView()
    var isSideMenuLoaded : Bool = false
    var homeList: [Home]! = []
    var homeEntity: HomeEntity?
    let networkReachability = NetworkReachabilityManager()
    var homeDBArray:[HomeEntity]?
    var apnDelegate : APNProtocol?
    let imageView = UIImageView()
    var blurView = UIVisualEffectView()
    var imgButton = UIButton()
    var imgLabel = UITextView()
    var homeBannerList: [HomeBanner]! = []
    var loginPopUpView : LoginPopupPage = LoginPopupPage()
    var accessToken : String? = nil
    var loginArray : LoginData?
    var userInfoArray : UserInfoData?
    var userEventList: [NMoQUserEventList]! = []
    var alreadyFetch : Bool? = false

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNib()
        setUpUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedNotification(notification:)), name: NSNotification.Name("NotificationIdentifier"), object: nil)
        self.recordScreenView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setUpUI() {
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
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.receiveHomePageNotificationEn(notification:)), name: NSNotification.Name(homepageNotificationEn), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.receiveHomePageNotificationAr(notification:)), name: NSNotification.Name(homepageNotificationAr), object: nil)
        self.fetchHomeInfoFromCoredata()
    }
    @objc func imgButtonPressed(sender: UIButton!) {
        let museumsView =  self.storyboard?.instantiateViewController(withIdentifier: "museumViewId") as! MuseumsViewController
        museumsView.fromHomeBanner = true
        museumsView.museumTitleString = homeBannerList[0].bannerTitle
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(museumsView, animated: false, completion: nil)
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
    @objc func receivedNotification(notification: Notification) {
        let notificationsView =  self.storyboard?.instantiateViewController(withIdentifier: "notificationId") as! NotificationsViewController
        notificationsView.fromHome = true
        self.present(notificationsView, animated: false, completion: nil)
    }
    func registerNib() {
        self.homeTableView.register(UINib(nibName: "CommonListCellXib", bundle: nil), forCellReuseIdentifier: "commonListCellId")
        self.homeTableView.register(UINib(nibName: "NMoHeaderView", bundle: nil), forCellReuseIdentifier: "bannerCellId")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadingView.stopLoading()
        loadingView.isHidden = true
        if((UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != nil) && (UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != "")  && (self.homeBannerList.count > 0)) {
            if(indexPath.row == 0) {
                let cell = homeTableView.dequeueReusableCell(withIdentifier: "bannerCellId", for: indexPath) as! NMoQHeaderCell
                cell.setBannerData(bannerData: homeBannerList[0])
                return cell
            } else {
                let cell = homeTableView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
                cell.setHomeCellData(home: homeList[indexPath.row])
                
                loadingView.stopLoading()
                loadingView.isHidden = true
                return cell
            }
        }else {
            let cell = homeTableView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
            cell.setHomeCellData(home: homeList[indexPath.row])
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let panelAndTalks = NSLocalizedString("PANEL_AND_TALKS",comment: "PANEL_AND_TALKS in Home Page")
        if((UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != nil) && (UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != "") && (self.homeBannerList.count > 0)) {
            if(indexPath.row == 0) {
                let museumsView =  self.storyboard?.instantiateViewController(withIdentifier: "museumViewId") as! MuseumsViewController
                museumsView.fromHomeBanner = true
                museumsView.museumTitleString = homeBannerList[0].bannerTitle
                museumsView.bannerId = homeBannerList[0].fullContentID
                museumsView.bannerImageArray = homeBannerList[0].image
                let transition = CATransition()
                transition.duration = 0.25
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                self.present(museumsView, animated: false, completion: nil)
            } else {
                if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                    if (homeList[indexPath.row].id == "12181") {
                        loadExhibitionPage()
                    } else if (homeList[indexPath.row].id == "13976") {
                        loadTourViewPage(nid: "13976", subTitle: panelAndTalks, isFromTour: false)
                    } else {
                        loadMuseumsPage(curretRow: indexPath.row)
                    }
                }
                else {
                    if (homeList[indexPath.row].id == "12186") {
                        loadExhibitionPage()
                    } else if (homeList[indexPath.row].id == "15631") {
                        loadTourViewPage(nid: "15631", subTitle: panelAndTalks, isFromTour: false)
                    }
                    else {
                        loadMuseumsPage(curretRow: indexPath.row)
                    }
                }
            }
        } else {
            if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                if (homeList[indexPath.row].id == "12181") {
                    loadExhibitionPage()
                } else if (homeList[indexPath.row].id == "13976") {
                    loadTourViewPage(nid: "13976", subTitle: panelAndTalks, isFromTour: false)
                }
                else {
                    loadMuseumsPage(curretRow: indexPath.row)
                }
            }
            else {
                if (homeList[indexPath.row].id == "12186") {
                    loadExhibitionPage()
                }
                else if (homeList[indexPath.row].id == "15631") {
                    loadTourViewPage(nid: "15631", subTitle: panelAndTalks, isFromTour: false)
                }
                else {
                    loadMuseumsPage(curretRow: indexPath.row)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightValue = UIScreen.main.bounds.height/100
        if((UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != nil) && (UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != "")  && (self.homeBannerList.count > 0)) {
            if(indexPath.row == 0) {
                return 120
            } else {
                return heightValue*27
            }
        }
        else {
            return heightValue*27
        }
    }
    func loadMuseumsPage(curretRow:Int? = 0) {
        let museumsView =  self.storyboard?.instantiateViewController(withIdentifier: "museumViewId") as! MuseumsViewController
        museumsView.museumId = homeList[curretRow!].id
        museumsView.museumTitleString = homeList[curretRow!].name
        museumsView.fromHomeBanner = false
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(museumsView, animated: false, completion: nil)
        
    }
    
    func loadExhibitionPage() {
        let exhibitionView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        exhibitionView.exhibitionsPageNameString = ExhbitionPageName.homeExhibition
        self.present(exhibitionView, animated: false, completion: nil)
    }
    
    func loadComingSoonPopup() {
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadPopup()
        self.view.addSubview(popupView)
    }
    
    func updateNotificationBadge() {
        topbarView.updateNotificationBadgeCount()
    }
    
    //MARK: Service call
    func getHomeList() {
        _ = Alamofire.request(QatarMuseumRouter.HomeList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<HomeList>) -> Void in
            switch response.result {
            case .success(let data):
                if((self.homeList.count == 0) || (self.homeList.count == 1)) {
                    self.homeList = data.homeList
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
                    if let nilItem = self.homeList.first(where: {$0.sortId == "" || $0.sortId == nil}) {
                        print("nil found")
                    } else {
                        self.homeList = self.homeList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                    if(self.homeBannerList.count > 0) {
                        self.homeList.insert(Home(id:self.homeBannerList[0].fullContentID , name: self.homeBannerList[0].bannerTitle,image: self.homeBannerList[0].bannerLink,
                                                  tourguide_available: "false", sort_id: nil),
                                             at: 0)
                    }

                    if((self.homeList.count == 0) || (self.homeList.count == 1)) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                    
                    self.homeTableView.reloadData()
                }
                if(self.homeList.count > 0) {
                   // self.saveOrUpdateHomeCoredata(homeList: data.homeList)
                }
            case .failure( _):
                if((self.homeList.count == 0) || (self.homeList.count == 1)) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            }
        }
    }
    func getHomeBanner() {
        _ = Alamofire.request(QatarMuseumRouter.GetHomeBanner()).responseObject { (response: DataResponse<HomeBannerList>) -> Void in
            switch response.result {
            case .success(let data):
                
                self.homeBannerList = data.homeBannerList
                if((UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != nil) && (UserDefaults.standard.value(forKey: "acceptOrDecline") as? String != "")  && (self.homeBannerList.count > 0)) {
                    if(self.homeList.count > 0) {
                        self.homeList.insert(Home(id:self.homeBannerList[0].fullContentID , name: self.homeBannerList[0].bannerTitle,image: self.homeBannerList[0].bannerLink,
                                                  tourguide_available: "false", sort_id: nil),
                                             at: 0)
                    }
                    
                }
                if(self.homeBannerList.count > 0) {
                    self.saveOrUpdateHomeBannerCoredata()
                }
                self.homeTableView.reloadData()
            case .failure( _):
            print("error")
            }
        }
    }
    //MARK: Topbar Delegate
    func backButtonPressed() {
    
    }
    
    func eventButtonPressed() {
        topBarEventButtonPressed()
    }
    
    func notificationbuttonPressed() {
        let notificationsView =  self.storyboard?.instantiateViewController(withIdentifier: "notificationId") as! NotificationsViewController
        notificationsView.fromHome = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(notificationsView, animated: false, completion: nil)
    }
    
    func profileButtonPressed() {
        culturePassButtonPressed()
    }
    
    func menuButtonPressed() {
        topbarMenuPressed()
    }
    
    //MARK: Poup Delegate
    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
    }
    
    //MARK: SideMenu Delegates
    func exhibitionButtonPressed() {
        let exhibitionView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
        exhibitionView.fromSideMenu = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
         exhibitionView.exhibitionsPageNameString = ExhbitionPageName.homeExhibition
        self.present(exhibitionView, animated: false, completion: nil)
    }
    
    func eventbuttonPressed() {
        let eventView =  self.storyboard?.instantiateViewController(withIdentifier: "eventPageID") as! EventViewController
        eventView.fromHome = true
        eventView.isLoadEventPage = true
        eventView.fromSideMenu = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(eventView, animated: false, completion: nil)
    }
    
    func educationButtonPressed() {
        let educationView =  self.storyboard?.instantiateViewController(withIdentifier: "educationPageID") as! EducationViewController
        educationView.fromSideMenu = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(educationView, animated: false, completion: nil)
    }
    
    func tourGuideButtonPressed() {
        let tourGuideView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
        tourGuideView.fromSideMenu = true
        tourGuideView.exhibitionsPageNameString = ExhbitionPageName.tourGuideList
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(tourGuideView, animated: false, completion: nil)
    }
    
    func heritageButtonPressed() {
        let heritageView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
        heritageView.fromSideMenu = true
        heritageView.exhibitionsPageNameString = ExhbitionPageName.heritageList
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(heritageView, animated: false, completion: nil)
    }
    
    func publicArtsButtonPressed() {
        let publicArtsView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
        publicArtsView.fromSideMenu = true
        publicArtsView.exhibitionsPageNameString = ExhbitionPageName.publicArtsList
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(publicArtsView, animated: false, completion: nil)
    }
    
    func parksButtonPressed() {
        let parksView =  self.storyboard?.instantiateViewController(withIdentifier: "heritageDetailViewId") as! HeritageDetailViewController
        parksView.pageNameString = PageName.SideMenuPark
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(parksView, animated: false, completion: nil)
    }
    
    func diningButtonPressed() {
        let diningView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
        diningView.fromHome = true
        diningView.fromSideMenu = true
        diningView.exhibitionsPageNameString = ExhbitionPageName.diningList
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(diningView, animated: false, completion: nil)
    }
    
    func culturePassButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        if (UserDefaults.standard.value(forKey: "accessToken") as? String != nil) {
            let profileView =  self.storyboard?.instantiateViewController(withIdentifier: "profileViewId") as! ProfileViewController
            self.present(profileView, animated: false, completion: nil)
        } else {
            let culturePassView =  self.storyboard?.instantiateViewController(withIdentifier: "culturePassViewId") as! CulturePassViewController
            culturePassView.fromHome = true
            self.present(culturePassView, animated: false, completion: nil)
        }
    }
    
    func giftShopButtonPressed() {
        let aboutUrlString = "https://inq-online.com/"
        if let aboutUrl = URL(string: aboutUrlString) {
            // show alert to choose app
            if UIApplication.shared.canOpenURL(aboutUrl as URL) {
                let webViewVc:WebViewController = self.storyboard?.instantiateViewController(withIdentifier: "webViewId") as! WebViewController
                webViewVc.webViewUrl = aboutUrl
                webViewVc.titleString = NSLocalizedString("WEBVIEW_TITLE", comment: "WEBVIEW_TITLE  in the Webview")
                self.present(webViewVc, animated: false, completion: nil)
            }
        }
    }
    
    func settingsButtonPressed() {
        let settingsView =  self.storyboard?.instantiateViewController(withIdentifier: "settingsId") as! SettingsViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(settingsView, animated: false, completion: nil)
    }
    
    func menuEventPressed() {
        topBarEventButtonPressed()
    }
    
    func menuNotificationPressed() {
        let notificationsView =  self.storyboard?.instantiateViewController(withIdentifier: "notificationId") as! NotificationsViewController
        notificationsView.fromHome = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(notificationsView, animated: false, completion: nil)
    }
    
    func menuProfilePressed() {
        topBarProfileButtonPressed()
    }
    
    func menuClosePressed() {
        UIView.animate(withDuration: 0.4, animations: {
            self.sideView.transform = CGAffineTransform.init(scaleX:1 , y: 1)
            self.sideView.alpha = 0
        }) { (success:Bool) in
            self.visualEffectView.effect = nil
            self.visualEffectView.isHidden = true
            self.sideView.removeFromSuperview()
        }
        self.topbarView.menuButton.setImage(UIImage(named: "side_menu_iconX1"), for: .normal)
        self.topbarView.menuButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 18, bottom: 14, right: 18)
        sideView.sideMenuDelegate = self
    }
    
    //MARK: Bottombar Delegate
    @IBAction func didTapMoreButton(_ sender: UIButton) {
        self.moreButton.transform = CGAffineTransform(scaleX: 1, y: 1)
         topbarMenuPressed()
    }
    
    @IBAction func moreButtonTouchDown(_ sender: UIButton) {
        self.moreButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTaprestaurantButton(_ sender: UIButton) {
        self.culturePassButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        let diningView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
         diningView.fromHome = true
         diningView.fromSideMenu = false
         diningView.exhibitionsPageNameString = ExhbitionPageName.diningList
         let transition = CATransition()
         transition.duration = 0.25
         transition.type = kCATransitionPush
         transition.subtype = kCATransitionFromRight
         view.window!.layer.add(transition, forKey: kCATransition)
         self.present(diningView, animated: false, completion: nil)
    }
    
    @IBAction func restaurantButtonTouchDown(_ sender: UIButton) {
        self.restaurantButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTapCulturePass(_ sender: UIButton) {
        culturePassButtonPressed()
        self.culturePassButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func culturePassTouchDown(_ sender: UIButton) {
        self.culturePassButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func didTapGiftShopButton(_ sender: UIButton) {
        giftShopButtonPressed()
        self.giftShopButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func giftShopButtonTouchDown(_ sender: UIButton) {
        self.giftShopButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func topbarMenuPressed() {
        self.topbarView.menuButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 18)
        var sideViewFrame = CGRect()
        if (UIScreen.main.bounds.height >= 812) {
            sideViewFrame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: self.view.bounds.height)
        } else {
            sideViewFrame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.bounds.height)
        }
        sideView  = SideMenuView(frame: sideViewFrame)
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
        sideView.sideMenuDelegate = self
        
    }
    
    func topBarEventButtonPressed() {
        let eventView =  self.storyboard?.instantiateViewController(withIdentifier: "eventPageID") as! EventViewController
        eventView.fromHome = true
        eventView.isLoadEventPage = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(eventView, animated: false, completion: nil)
    }
    
    func topBarProfileButtonPressed() {
        let profileView =  self.storyboard?.instantiateViewController(withIdentifier: "profileViewId") as! ProfileViewController
        profileView.fromHome = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(profileView, animated: false, completion: nil)
        
    }
    
    //MARK: Coredata Method
    func saveOrUpdateHomeCoredata(homeList: [Home]?) {
        if ((homeList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext, homeList: homeList)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext, homeList: homeList)
                }
            }
        }
    }
    
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext,homeList: [Home]?) {
        var fetchData = [HomeEntity]()
        var langVar : String? = nil
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
        fetchData = checkAddedToCoredata(entityName: "HomeEntity", idKey: "lang", idValue: langVar, managedContext: managedContext) as! [HomeEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (homeList?.count)!-1 {
                    let homeListDict = homeList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "HomeEntity", idKey: "id", idValue: homeList![i].id, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let homedbDict = fetchResult[0] as! HomeEntity
                        homedbDict.name = homeListDict.name
                        homedbDict.image = homeListDict.image
                        homedbDict.sortid =  (Int16(homeListDict.sortId!) ?? 0)
                        homedbDict.tourguideavailable = homeListDict.isTourguideAvailable
                        homedbDict.lang = langVar
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveToCoreData(homeListDict: homeListDict, managedObjContext: managedContext)
                    }
                }
            } else {
                for i in 0 ... (homeList?.count)!-1 {
                    let homeListDict : Home?
                    homeListDict = homeList?[i]
                    self.saveToCoreData(homeListDict: homeListDict!, managedObjContext: managedContext)
                }
            }
    }
    
    func saveToCoreData(homeListDict: Home, managedObjContext: NSManagedObjectContext) {
        var langVar : String? = nil
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
        let homeInfo: HomeEntity = NSEntityDescription.insertNewObject(forEntityName: "HomeEntity", into: managedObjContext) as! HomeEntity
        homeInfo.id = homeListDict.id
        homeInfo.name = homeListDict.name
        homeInfo.image = homeListDict.image
        homeInfo.tourguideavailable = homeListDict.isTourguideAvailable
        homeInfo.image = homeListDict.image
        homeInfo.sortid = (Int16(homeListDict.sortId!) ?? 0)
        homeInfo.lang = langVar
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    //MARK: Coredata Method
    
    func fetchHomeInfoFromCoredata() {
        if(alreadyFetch == false) {
        let managedContext = getContext()
       // let panelAndTalksName = NSLocalizedString("PANEL_AND_TALKS",comment: "PANEL_AND_TALKS in Home Page")
        do {
                var homeArray = [HomeEntity]()
                var langVar : String? = nil
                if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
                    langVar = "1"
                    
                } else {
                    langVar = "0"
                }
                homeArray = checkAddedToCoredata(entityName: "HomeEntity", idKey: "lang", idValue: langVar, managedContext: managedContext) as! [HomeEntity]
                var j:Int? = 0
            if (homeArray.count > 0) {
                if((self.networkReachability?.isReachable)!) {
                    DispatchQueue.global(qos: .background).async {
                        self.getHomeList()
                    }
                }
                //homeArray.sort(by: {$0.sortid < $1.sortid})
                for i in 0 ... homeArray.count-1 {
                    if homeList.first(where: {$0.id == homeArray[i].id}) != nil {
                        } else {
                            self.homeList.insert(Home(id:homeArray[i].id , name: homeArray[i].name,image: homeArray[i].image,
                                                      tourguide_available: homeArray[i].tourguideavailable, sort_id: String(homeArray[i].sortid)),
                                                 at: j!)
                            j = j!+1
                        }
                    
                }
                
                /* Just Commented for New Release
                let panelAndTalks = "QATAR CREATES: EVENTS FOR THE OPENING OF NMoQ".lowercased()
                if homeList.index(where: {$0.name?.lowercased() != panelAndTalks}) != nil {
                    self.homeList.insert(Home(id: "13976", name: panelAndTalksName.uppercased(), image: "panelAndTalks", tourguide_available: "false", sort_id: "10"), at: self.homeList.endIndex)
                }
 */
                if let nilItem = self.homeList.first(where: {$0.sortId == "" || $0.sortId == nil}) {
                    print("nil found")
                } else {
                    self.homeList = self.homeList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                }
                if(self.homeBannerList.count > 0) {
                    self.homeList.insert(Home(id:self.homeBannerList[0].fullContentID , name: self.homeBannerList[0].bannerTitle,image: self.homeBannerList[0].bannerLink,
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
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if (networkReachability?.isReachable == false) {
                self.showNoNetwork()
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
                        userEventInfo.title = userEventListDict.title
                        userEventInfo.eventId = userEventListDict.eventID
                        userEventInfo.regId = userEventListDict.regID
                        userEventInfo.seats = userEventListDict.seats
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
    //MARK: HomeBanner CoreData
    func saveOrUpdateHomeBannerCoredata() {
        if (homeBannerList.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.homeBannerCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.homeBannerCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    func homeBannerCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "HomeBannerEntity", idKey: "fullContentID", idValue: nil, managedContext: managedContext) as! [HomeBannerEntity]
            let homeListDict = homeBannerList[0]
            if (fetchData.count > 0) {
                
                let isDeleted = self.deleteExistingEvent(managedContext: managedContext, entityName: "HomeBannerEntity")
                if(isDeleted == true) {
                    self.saveHomeBannerToCoreData(homeListDict: homeListDict, managedObjContext: managedContext)
                }
                
                    } else {
                        //save
                        self.saveHomeBannerToCoreData(homeListDict: homeListDict, managedObjContext: managedContext)
                    }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "HomeBannerEntityAr", idKey: "fullContentID", idValue: nil, managedContext: managedContext) as! [HomeBannerEntityAr]
            let homeListDict = homeBannerList[0]
            if (fetchData.count > 0) {
                
                let isDeleted = self.deleteExistingEvent(managedContext: managedContext, entityName: "HomeBannerEntityAr")
                if(isDeleted == true) {
                    self.saveHomeBannerToCoreData(homeListDict: homeListDict, managedObjContext: managedContext)
                }
                
            } else {
                //save
                self.saveHomeBannerToCoreData(homeListDict: homeListDict, managedObjContext: managedContext)
            }
        }
    }
    func saveHomeBannerToCoreData(homeListDict: HomeBanner, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let homeInfo: HomeBannerEntity = NSEntityDescription.insertNewObject(forEntityName: "HomeBannerEntity", into: managedObjContext) as! HomeBannerEntity
            homeInfo.title = homeListDict.title
            homeInfo.fullContentID = homeListDict.fullContentID
            homeInfo.bannerTitle = homeListDict.bannerTitle
            homeInfo.bannerLink = homeListDict.bannerLink
            
            if(homeListDict.image != nil){
                if((homeListDict.image?.count)! > 0) {
                    for i in 0 ... (homeListDict.image?.count)!-1 {
                        var bannerImage: HomeBannerImageEntity
                        let bannerImgaeArray: HomeBannerImageEntity = NSEntityDescription.insertNewObject(forEntityName: "HomeBannerImageEntity", into: managedObjContext) as! HomeBannerImageEntity
                        bannerImgaeArray.image = homeListDict.image![i]
                        
                        bannerImage = bannerImgaeArray
                        homeInfo.addToBannerImageRelations(bannerImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
            do {
                try managedObjContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } else {
            let homeInfo: HomeBannerEntityAr = NSEntityDescription.insertNewObject(forEntityName: "HomeBannerEntityAr", into: managedObjContext) as! HomeBannerEntityAr
            homeInfo.title = homeListDict.title
            homeInfo.fullContentID = homeListDict.fullContentID
            homeInfo.bannerTitle = homeListDict.bannerTitle
            homeInfo.bannerLink = homeListDict.bannerLink
            
            if(homeListDict.image != nil){
                if((homeListDict.image?.count)! > 0) {
                    for i in 0 ... (homeListDict.image?.count)!-1 {
                        var bannerImage: HomeBannerImageEntityAr
                        let bannerImgaeArray: HomeBannerImageEntityAr = NSEntityDescription.insertNewObject(forEntityName: "HomeBannerImageEntityAr", into: managedObjContext) as! HomeBannerImageEntityAr
                        bannerImgaeArray.image = homeListDict.image![i]
                        
                        bannerImage = bannerImgaeArray
                        homeInfo.addToBannerImageRelationsAr(bannerImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
            do {
                try managedObjContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }

    }
    func fetchHomeBannerInfoFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var homeArray = [HomeBannerEntity]()
                let homeFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "HomeBannerEntity")
                homeArray = (try managedContext.fetch(homeFetchRequest) as? [HomeBannerEntity])!
                if (homeArray.count > 0) {
                    for i in 0 ... homeArray.count-1 {
                        let homeBannerDict = homeArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (homeBannerDict.bannerImageRelations?.allObjects) as! [HomeBannerImageEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].image!)
                            }
                        }
                        self.homeBannerList.insert(HomeBanner(title: homeArray[i].title, fullContentID: homeArray[i].fullContentID, bannerTitle: homeArray[i].bannerTitle, bannerLink: homeArray[i].bannerLink,image: imagesArray, introductionText: nil, email: nil, contactNumber: nil, promotionalCode: nil, claimOffer: nil), at: i)
                        
                    }
//                    if(self.homeList.count == 0){
//                        self.showNoNetwork()
//                    }
                    self.homeTableView.reloadData()
                } else{
                    //self.showNoNetwork()
                }
            } else {
                var homeArray = [HomeBannerEntityAr]()
                let homeFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "HomeBannerEntityAr")
                homeArray = (try managedContext.fetch(homeFetchRequest) as? [HomeBannerEntityAr])!
                if (homeArray.count > 0) {
                    for i in 0 ... homeArray.count-1 {
                        let homeBannerDict = homeArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (homeBannerDict.bannerImageRelationsAr?.allObjects) as! [HomeBannerImageEntityAr]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].image!)
                            }
                        }
                        self.homeBannerList.insert(HomeBanner(title: homeArray[i].title, fullContentID: homeArray[i].fullContentID, bannerTitle: homeArray[i].bannerTitle, bannerLink: homeArray[i].bannerLink,image: imagesArray, introductionText: nil, email: nil, contactNumber: nil, promotionalCode: nil, claimOffer: nil), at: i)
                        
                    }
                    if(self.homeList.count == 0){
                       // self.showNoNetwork()
                    }
                    self.homeTableView.reloadData()
                } else{
                    //self.showNoNetwork()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    func deleteExistingEvent(managedContext:NSManagedObjectContext,entityName : String?) ->Bool? {
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName!)
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
            return true
        }catch _ as NSError {
            //handle error here
            return false
        }
        
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
            appDelegate?.getHomeList(lang: LocalizationLanguage.currentAppleLanguage())
            if(UserDefaults.standard.value(forKey: "firstTimeLaunch") as? String == nil) {
                loadLoginPopup()
                UserDefaults.standard.set("false", forKey: "firstTimeLaunch")
            }
        }
    }
    //MARK: Login Details
    func loadLoginPopup() {
        loginPopUpView  = LoginPopupPage(frame: self.view.frame)
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
    //MARK: WebServiceCall
    func getCulturePassTokenFromServer(login: Bool? = false) {
        _ = Alamofire.request(QatarMuseumRouter.GetToken(["name": loginPopUpView.userNameText.text!,"pass":loginPopUpView.passwordText.text!])).responseObject { (response: DataResponse<TokenData>) -> Void in
            switch response.result {
            case .success(let data):
                self.accessToken = data.accessToken
                if(login == true) {
                    self.getCulturePassLoginFromServer()
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
                    UserDefaults.standard.setValue(self.loginPopUpView.passwordText.text, forKey: "userPassword")
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
                            let undData = self.userInfoArray?.fieldRsvpAttendance!["und"] as? NSArray
                            if(undData != nil) {
                                if((undData?.count)! > 0) {
                                    let value = undData?[0] as! NSDictionary
                                    if(value["value"] != nil) {
                                        UserDefaults.standard.setValue(value["value"], forKey: "acceptOrDecline")
                                        self.getHomeBanner()
                                    }
                                }
                                
                            }
                        }
                    }
                    self.setProfileDetails(loginInfo: self.loginArray)
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
            _ = Alamofire.request(QatarMuseumRouter.NMoQEventListUserRegistration(["uid" : userId])).responseObject { (response: DataResponse<NMoQUserEventListValues>) -> Void in
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
    
    func setProfileDetails(loginInfo : LoginData?) {
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
            let firstNameData = userData?.fieldFirstName["und"] as? NSArray
            if(firstNameData != nil && (firstNameData?.count)! > 0) {
                let name = firstNameData![0] as! NSDictionary
                if(name["value"] != nil) {
                    UserDefaults.standard.setValue(name["value"] as! String, forKey: "fieldFirstName")
                }
            }
            let lastNameData = userData?.fieldLastName["und"] as? NSArray
            if(lastNameData != nil && (lastNameData?.count)! > 0) {
                let name = lastNameData?[0] as! NSDictionary
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
            let translationsData = userData?.translations["data"] as? NSDictionary
            if(translationsData != nil) {
                let arValues = translationsData?["ar"] as! NSDictionary
                if(arValues["entity_id"] != nil) {
                    UserDefaults.standard.setValue(arValues["entity_id"] as! String , forKey: "loginEntityID")
                }
            }
            
            
            
        }
        self.loginPopUpView.removeFromSuperview()
        getEventListUserRegistrationFromServer()
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
    func loadTourViewPage(nid: String?,subTitle:String?,isFromTour:Bool?) {
        let tourView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
        tourView.tourDetailId = nid
        tourView.headerTitle = subTitle
        tourView.isFromTour = isFromTour
        tourView.exhibitionsPageNameString = ExhbitionPageName.nmoqTourSecondList
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(tourView, animated: false, completion: nil)
    }
    @objc func receiveHomePageNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (homeList.count == 0)){
            DispatchQueue.main.async{
                self.fetchHomeInfoFromCoredata()
            }
        }
        
    }
    @objc func receiveHomePageNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (homeList.count == 0)){
            DispatchQueue.main.async{
                self.fetchHomeInfoFromCoredata()
            }
        }
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(HOME, screenClass: screenClass)
    }

}
