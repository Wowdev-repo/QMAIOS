//
//  MuseumsViewController.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 23/06/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//



import Crashlytics
import Firebase
import Kingfisher
import UIKit

class MuseumsViewController: UIViewController,KASlideShowDelegate {
    
    @IBOutlet weak var museumsTopbar: TopBarView!
    @IBOutlet weak var museumsSlideView: KASlideShow!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var museumsBottomCollectionView: UICollectionView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var museumTitle: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    
    var collectionViewImages : NSArray!
    var collectionViewNames : NSArray!
    var popUpView : ComingSoonPopUp = ComingSoonPopUp()
    var museumArray: [Museum] = []
    var museumId:String? = nil
    var museumTitleString:String? = nil
    var totalImgCount = Int()
    var sliderImgCount : Int? = 0
    var sliderImgArray = NSMutableArray()
    var apnDelegate : APNProtocol?
    var fromHomeBanner = false
    var bannerId: String? = nil
    var bannerImageArray : [String]? = []
    let networkReachability = NetworkReachabilityManager()
    var selectedItemName : String? = nil
    
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        setupUI()
        self.recordScreenView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupUI() {
        if (fromHomeBanner == false) {
            fetchMuseumLandingImagesFromCoredata()
        } else {
            self.setImageArray(imageArray: bannerImageArray)
        }
        museumsSlideView.imagesContentMode = .scaleAspectFill
        let aboutName = NSLocalizedString("ABOUT", comment: "ABOUT  in the Museum")
        let tourGuideName = ((museumId == "63") || (museumId == "96")) ?
            NSLocalizedString("TOURGUIDE_LABEL", comment: "TOURGUIDE_LABEL  in the MIA Museum page") :
            NSLocalizedString("AUDIOGUIDE_LABEL", comment: "AUDIOGUIDE_LABEL  in the NMoQ Museum page")
        let exhibitionsName = NSLocalizedString("EXHIBITIONS_LABEL", comment: "EXHIBITIONS_LABEL  in the Museum page")
        let collectionsName = NSLocalizedString("COLLECTIONS_TITLE", comment: "COLLECTIONS_TITLE  in the Museum page")
        //let experienceName = NSLocalizedString("EXPERIENCE_TITLE", comment: "EXPERIENCE_TITLE  in the Museum page")
        let parkName = NSLocalizedString("PARKS_LABEL", comment: "PARKS_LABEL  in the Museum page")
        let diningName = NSLocalizedString("DINING_LABEL", comment: "DINING_LABEL  in the Museum page")
       // let highlightTourName = NSLocalizedString("HIGHLIGHTS_TOUR", comment: "HIGHLIGHTS_TOUR  in the Museum page")
        let facilitiesName = NSLocalizedString("FACILITIES", comment: "FACILITIES  in the Museum page")
       // let eventsName = NSLocalizedString("EVENTS_LABEL", comment: "EVENTS_LABEL  in the Museum page")
        
        museumsTopbar.topbarDelegate = self
        museumsTopbar.menuButton.isHidden = true
        museumsTopbar.backButton.isHidden = false
        museumTitle.text = museumTitleString
        museumTitle.font = UIFont.museumTitleFont
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            museumsTopbar.backButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
            previousButton.isHidden = true
            nextButton.isHidden = false
        } else {
            museumsTopbar.backButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
            previousButton.isHidden = false
            nextButton.isHidden = true
            previousButton.setImage(UIImage(named: "nextImg"), for: .normal)
        }
        
        if fromHomeBanner {
            let aboutBanner = NSLocalizedString("ABOUT", comment: "ABOUT  in the Museum")
            let tourBanner = NSLocalizedString("TOURS", comment: "TOURS  in the Museum page")
            let travelBanner = NSLocalizedString("TRAVEL_ARRANGEMENTS", comment: "TRAVEL_ARRANGEMENTS  in the Museum page")
            let panelBanner = NSLocalizedString("PANEL_DISCUSSION", comment: "PANEL_DISCUSSION  in the Museum page")
            collectionViewImages = ["about-launchX1","tours-launchX1","travel-launchX1","discussion-launchX1"]
            collectionViewNames = [aboutBanner,tourBanner,travelBanner,panelBanner]
            previousButton.isHidden = true
            nextButton.isHidden = true
            museumsTopbar.eventButton.isHidden = true
            museumsTopbar.notificationButton.isHidden = true
            museumsTopbar.profileButton.isHidden = true
        } else {
            
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), Museum ID: \(String(describing: museumId))")
            
            if ((museumId != nil) && ((museumId == "63") || (museumId == "96"))) {
                collectionViewImages = ["MIA_AboutX1","Audio CircleX1","exhibition_blackX1","collectionsX1","park_blackX1","diningX1",]
                collectionViewNames = [aboutName,tourGuideName,exhibitionsName,collectionsName,parkName,diningName]
            }else if ((museumId == "61") || (museumId == "635")) {
                collectionViewImages = ["MIA_AboutX1","Audio CircleX1","exhibition_blackX1","collectionsX1","diningX1",]
                collectionViewNames = [aboutName,tourGuideName,exhibitionsName,collectionsName,diningName]
            }else if ((museumId == "66") || (museumId == "638")) {
                collectionViewImages = ["about-launchX1","facilitiesX1","exhibition_blackX1","Audio CircleX1","park_blackX1"]
                collectionViewNames = [aboutName,facilitiesName,exhibitionsName,tourGuideName,parkName]
                previousButton.isHidden = true
                nextButton.isHidden = true
            } else {
                collectionViewImages = ["MIA_AboutX1","exhibition_blackX1","collectionsX1","diningX1",]
                collectionViewNames = [aboutName,exhibitionsName,collectionsName,diningName]
                previousButton.isHidden = true
                nextButton.isHidden = true
            }
        }
    }
//    func setImageArray(imageArray: [String]?) {
//        if ((imageArray?.count)! >= 4) {
//            totalImgCount = 3
//        } else if ((imageArray?.count)! > 1){
//            totalImgCount = (imageArray?.count)!-1
//        } else {
//            totalImgCount = 0
//        }
//        if (totalImgCount > 0) {
//            for  i in 1 ... totalImgCount {
//                let imageUrlString = imageArray![i]
//                downloadImage(imageUrlString: imageUrlString)
//            }
//        }
//    }
    func setImageArray(imageArray: [String]?) {
        totalImgCount = imageArray?.count ?? 0
        if (totalImgCount > 0) {
            for  i in 0 ... totalImgCount-1 {
                let imageUrlString = imageArray![i]
                downloadImage(imageUrlString: imageUrlString)
            }
        }
    }
    func downloadImage(imageUrlString : String?)  {
        if (imageUrlString != nil) {
            let imageUrl = URL(string: imageUrlString!)
            
            KingfisherManager.shared.retrieveImage(with: imageUrl!, options: [], progressBlock: nil, completionHandler: {  (image, error, cacheType, imageUrl) in
                if let image = image {
                    self.sliderImgArray[self.sliderImgCount!] = image
                    self.sliderImgCount = self.sliderImgCount!+1
                    self.setSlideShow(imgArray: self.sliderImgArray)
                    self.museumsSlideView.start()
                } else {
                    if(self.sliderImgCount == 0) {
                        self.sliderImgArray[0] = UIImage(named: "sliderPlaceholder")!
                    } else {
                        self.sliderImgArray[self.sliderImgCount!-1] = UIImage(named: "sliderPlaceholder")!
                    }
                    self.sliderImgCount = self.sliderImgCount!+1
                    self.setSlideShow(imgArray: self.sliderImgArray)
                    self.museumsSlideView.start()
                }
            })
            
        }
    }
    func setSlideShow(imgArray: NSArray) {
        //KASlideshow
        museumsSlideView.delegate = self
        museumsSlideView.delay = 0.5
        museumsSlideView.transitionDuration = 1.2
        museumsSlideView.transitionType = KASlideShowTransitionType.fade
        museumsSlideView.imagesContentMode = .scaleAspectFill
        museumsSlideView.images = imgArray as? NSMutableArray
        museumsSlideView.add(KASlideShowGestureType.swipe)
        museumsSlideView.start()
        pageControl.numberOfPages = imgArray.count
        if museumsSlideView.images.count > 0 {
            let dot = pageControl.subviews[0]
            dot.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        }
        
        pageControl.currentPage = Int(museumsSlideView.currentIndex)
        pageControl.addTarget(self, action: #selector(MuseumsViewController.pageChanged), for: .valueChanged)
    }
    func updateNotificationBadge() {
        museumsTopbar.updateNotificationBadgeCount()
    }
    
    @IBAction func didTapPrevious(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let collectionBounds = self.museumsBottomCollectionView.bounds
            let contentOffset = CGFloat(floor(self.museumsBottomCollectionView.contentOffset.x - collectionBounds.size.width))
            self.moveCollectionToFrame(contentOffset: contentOffset)
            nextButton.isHidden = false
            previousButton.isHidden = true
        }
        else {
            self.museumsBottomCollectionView.isScrollEnabled = true
            let collectionBounds = self.museumsBottomCollectionView.bounds
            let contentOffset = CGFloat(floor(self.museumsBottomCollectionView.contentOffset.x + collectionBounds.size.width))
            self.moveCollectionToFrame(contentOffset: contentOffset)
            nextButton.isHidden = false
            previousButton.isHidden = true
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_previous,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    @IBAction func didTapNext(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            self.museumsBottomCollectionView.isScrollEnabled = true
            let collectionBounds = self.museumsBottomCollectionView.bounds
            let contentOffset = CGFloat(floor(self.museumsBottomCollectionView.contentOffset.x + collectionBounds.size.width))
            self.moveCollectionToFrame(contentOffset: contentOffset)
            nextButton.isHidden = true
            previousButton.isHidden = false
        }
        else {
            let collectionBounds = self.museumsBottomCollectionView.bounds
            let contentOffset = CGFloat(floor(self.museumsBottomCollectionView.contentOffset.x - collectionBounds.size.width))
            self.moveCollectionToFrame(contentOffset: contentOffset)
            nextButton.isHidden = true
            previousButton.isHidden = false
            previousButton.setImage(UIImage(named: "nextImg"), for: .normal)
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_next,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    func moveCollectionToFrame(contentOffset : CGFloat) {
        
        let frame: CGRect = CGRect(x : contentOffset ,y : self.museumsBottomCollectionView.contentOffset.y ,width : self.museumsBottomCollectionView.frame.width,height : self.museumsBottomCollectionView.frame.height)
        self.museumsBottomCollectionView.scrollRectToVisible(frame, animated: false)
    }
    
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(MUSEUM_VC, screenClass: screenClass)
    }
}

//KASlideShow methods
extension MuseumsViewController {
    //KASlideShow delegate
    func kaSlideShowDidShowNext(_ slideshow: KASlideShow) {
        let currentIndex = Int(museumsSlideView.currentIndex)
        pageControl.currentPage = Int(museumsSlideView.currentIndex)
        customizePageControlDot(currentIndex: currentIndex)
    }
    
    func kaSlideShowDidShowPrevious(_ slideshow: KASlideShow) {
        let currentIndex = Int(museumsSlideView.currentIndex)
        pageControl.currentPage = Int(museumsSlideView.currentIndex)
        customizePageControlDot(currentIndex: currentIndex)
    }
    
    func customizePageControlDot(currentIndex: Int) {
        for i in 0...pageControl.numberOfPages-1 {
            let dot = pageControl.subviews[i]
            if (i == currentIndex) {
                dot.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            } else {
                dot.transform = CGAffineTransform(scaleX: 1, y: 1)
                //  break
            }
        }
    }
    @objc func pageChanged() {
        
    }
}

//MARK:- ReusableViews methods
extension MuseumsViewController: TopBarProtocol,comingSoonPopUpProtocol {
    func loadComingSoonPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        popUpView  = ComingSoonPopUp(frame: self.view.frame)
        popUpView.comingSoonPopupDelegate = self
        popUpView.loadPopup()
        self.view.addSubview(popUpView)
    }
    //MARk: ComingSoonPopUp Delegates
    func closeButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.popUpView.removeFromSuperview()
    }
    //MARK: Header Deleagate
    func eventButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let eventView =  self.storyboard?.instantiateViewController(withIdentifier: "eventPageID") as! EventViewController
        eventView.fromHome = false
        eventView.isLoadEventPage = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_event,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
        self.present(eventView, animated: false, completion: nil)
    }
    
    func notificationbuttonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let notificationsView =  self.storyboard?.instantiateViewController(withIdentifier: "notificationId") as! NotificationsViewController
        notificationsView.fromHome = false
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_notifications,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
        self.present(notificationsView, animated: false, completion: nil)
    }
    
    func profileButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
            culturePassView.fromHome = false
            self.present(culturePassView, animated: false, completion: nil)
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_profile,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    func menuButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    //MARK: Topbar delegate
    func backButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        museumsSlideView.stop()
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.dismiss(animated: false, completion: nil)
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_header_back,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
        
        self.view.window!.layer.add(transition, forKey: kCATransition)
    }
}

//MARK:- Segue controller
extension MuseumsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tourBanner = NSLocalizedString("TOURS", comment: "TOURS  in the Museum page")
        let travelBanner = NSLocalizedString("TRAVEL_ARRANGEMENTS", comment: "TRAVEL_ARRANGEMENTS  in the Museum page")
        let panelBanner = NSLocalizedString("PANEL_DISCUSSION", comment: "PANEL_DISCUSSION  in the Museum page")
        if (segue.identifier == "museumsToAboutSegue") {
            let museumAboutView = segue.destination as! MuseumAboutViewController
            
            if fromHomeBanner {
                museumAboutView.pageNameString = PageName2.museumEvent
                museumAboutView.museumId = bannerId
            } else {
                museumAboutView.pageNameString = PageName2.museumAbout
                museumAboutView.museumId = museumId
            }
        } else if (segue.identifier == "museumsToTourAndPanelSegue") {
            let tourAndPanelView = segue.destination as! TourAndPanelListViewController
            if (selectedItemName == tourBanner) {
                tourAndPanelView.pageNameString = NMoQPageName.Tours
            } else if (selectedItemName == travelBanner) {
                tourAndPanelView.bannerId = bannerId
                tourAndPanelView.pageNameString = NMoQPageName.TravelArrangementList
            } else if (selectedItemName == panelBanner) {
                tourAndPanelView.pageNameString = NMoQPageName.PanelDiscussion
            } else if((selectedItemName == "Facilities") || (selectedItemName == "المرافق")) {
                tourAndPanelView.pageNameString = NMoQPageName.Facilities
            }
        } else if (segue.identifier == "museumsToCommonListSegue") {
            let commonList = segue.destination as! CommonListViewController
            if ((selectedItemName == "Audio Guide") || (selectedItemName == "الدليل الصوتي")){
                commonList.exhibitionsPageNameString = ExhbitionPageName.miaTourGuideList
                commonList.museumId = museumId!
            } else if ((selectedItemName == "Exhibitions") || (selectedItemName == "المعارض")){
                commonList.museumId = museumId
                commonList.exhibitionsPageNameString = ExhbitionPageName.museumExhibition
            } else if ((selectedItemName == "Collections") || (selectedItemName == "المجموعات")){
                commonList.museumId = museumId
                commonList.exhibitionsPageNameString = ExhbitionPageName.museumCollectionsList
            } else if ((selectedItemName == "Parks") || (selectedItemName == "الحدائق")){
                commonList.exhibitionsPageNameString = ExhbitionPageName.parkList
            }else if((selectedItemName == "Dining") || (selectedItemName == "الطعام")) {
                commonList.museumId = museumId
                commonList.fromHome = false
                commonList.fromSideMenu = false
                commonList.exhibitionsPageNameString = ExhbitionPageName.diningList
            }
        } else if (segue.identifier == "museumToCommonDetailSegue") {
            let commonDetail = segue.destination as! CommonDetailViewController
            commonDetail.pageNameString = PageName.SideMenuPark
        }
    }
}
