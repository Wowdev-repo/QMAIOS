//
//  CommonListViewController.swift
//  QatarMuseum
//
//  Created by Wakralab Software Labs on 10/06/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//


import Crashlytics
import Firebase
import MapKit
import UIKit


enum ExhbitionPageName {
    case homeExhibition
    case museumExhibition
    case heritageList
    case publicArtsList
    case museumCollectionsList
    case diningList
    case nmoqTourSecondList
    case facilitiesSecondList
    case miaTourGuideList
    case tourGuideList
    case parkList
}
class CommonListViewController: UIViewController {
    @IBOutlet weak var commonListHeaderView: CommonHeaderView!
    @IBOutlet weak var commonListTableView: UITableView!
    @IBOutlet weak var commonListLoadingView: LoadingView!
    
    var exhibition: [Exhibition]! = []
    var heritageListArray: [Heritage]! = []
    var publicArtsListArray: [PublicArtsList]! = []
    var collection: [Collection] = []
    var diningListArray : [Dining]! = []
    var nmoqTourDetail: [NMoQTourDetail] = []
    var facilitiesDetail: [FacilitiesDetail]! = []
    var miaTourDataFullArray: [TourGuide] = []
    var museumsList: [Home]! = []
    var nmoqParkList: [NMoQParksList]! = []
    var nmoqParks: [NMoQPark]! = []
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var exhibitionsPageNameString : ExhbitionPageName?
    let networkReachability = NetworkReachabilityManager()
    var museumId : String? = nil
    var fromSideMenu : Bool = false
    var fromHome : Bool = false
    var isFromTour: Bool? =  false
    var tourTitle : String! = ""
    var tourDesc: String = ""
    var tourDetailId : String? = nil
    var headerTitle : String? = nil
    var dataInCoreData : Bool? = false
    var selectedRow : Int? = 0

    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        setUpExhibitionPageUi()
        registerNib()
        self.recordScreenView()
    }
    
    func setUpExhibitionPageUi() {
        commonListLoadingView.isHidden = false
        commonListLoadingView.showLoading()
        commonListLoadingView.loadingViewDelegate = self
        commonListHeaderView.headerViewDelegate = self
        if ((exhibitionsPageNameString == ExhbitionPageName.homeExhibition) || (exhibitionsPageNameString == ExhbitionPageName.museumExhibition)) {
            commonListHeaderView.headerTitle.text = NSLocalizedString("EXHIBITIONS_TITLE", comment: "EXHIBITIONS_TITLE Label in the Exhibitions page")
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveExhibitionListNotificationEn(notification:)), name: NSNotification.Name(exhibitionsListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveExhibitionListNotificationAr(notification:)), name: NSNotification.Name(exhibitionsListNotificationAr), object: nil)
            
            
            if  (networkReachability?.isReachable)! {
                if (exhibitionsPageNameString == ExhbitionPageName.homeExhibition) {
//                    DispatchQueue.global(qos: .background).async {
//                        self.getExhibitionDataFromServer()
//                    }
                    self.fetchExhibitionsListFromCoredata()
                } else
                    if (exhibitionsPageNameString == ExhbitionPageName.museumExhibition){
                    getMuseumExhibitionDataFromServer()
                }
            } else {
                if (exhibitionsPageNameString == ExhbitionPageName.homeExhibition) {
                    self.fetchExhibitionsListFromCoredata()
                } else if (exhibitionsPageNameString == ExhbitionPageName.museumExhibition){
                    self.fetchMuseumExhibitionsListFromCoredata()
                }
            }
            
        } else if (exhibitionsPageNameString == ExhbitionPageName.heritageList) {
            commonListHeaderView.headerTitle.text = NSLocalizedString("HERITAGE_SITES_TITLE", comment: "HERITAGE_SITES_TITLE  in the Heritage page")
            commonListHeaderView.headerTitle.font = UIFont.headerFont
            self.fetchHeritageListFromCoredata()
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveHeritageListNotificationEn(notification:)), name: NSNotification.Name(heritageListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveHeritageListNotificationAr(notification:)), name: NSNotification.Name(heritageListNotificationAr), object: nil)
//            if  (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getHeritageDataFromServer()
//                }
//            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.publicArtsList) {
            commonListHeaderView.headerTitle.text = NSLocalizedString("PUBLIC_ARTS_TITLE", comment: "PUBLIC_ARTS_TITLE Label in the PublicArts page")
//            if  (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getPublicArtsListDataFromServer()
//                }
//            }
            self.fetchPublicArtsListFromCoredata()
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receivePublicArtsListNotificationEn(notification:)), name: NSNotification.Name(publicArtsListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receivePublicArtsListNotificationAr(notification:)), name: NSNotification.Name(publicArtsListNotificationAr), object: nil)
        } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList) {
            commonListHeaderView.headerTitle.text = NSLocalizedString("COLLECTIONS_TITLE", comment: "COLLECTIONS_TITLE Label in the collections page").uppercased()
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveCollectionListNotificationEn(notification:)), name: NSNotification.Name(collectionsListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveCollectionListNotificationAr(notification:)), name: NSNotification.Name(collectionsListNotificationAr), object: nil)
            if((museumId == "63") || (museumId == "96")) {
//                if (networkReachability?.isReachable)! {
//                    DispatchQueue.global(qos: .background).async {
//                        self.getCollectionList()
//                    }
//                }
                self.fetchCollectionListFromCoredata()
            } else {
                if (networkReachability?.isReachable)! {
                    self.getCollectionList()
                } else {
                    self.fetchCollectionListFromCoredata()
                }
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.diningList) {
            commonListHeaderView.headerTitle.text = NSLocalizedString("DINING_TITLE", comment: "DINING_TITLE in the Dining page")
            if(fromHome) {
                self.fetchDiningListFromCoredata()
//                if  (networkReachability?.isReachable)! {
//                    DispatchQueue.global(qos: .background).async {
//                        self.getDiningListFromServer()
//                    }
//                }
            } else {
                self.fetchMuseumDiningListFromCoredata()
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getMuseumDiningListFromServer()
                    }
                }
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.nmoqTourSecondList) {
            tourDesc = NSLocalizedString("NMoQ_TOUR_DESC", comment: "NMoQ_TOUR_DESC in the NMoQ Tour page")
            commonListHeaderView.headerTitle.text = headerTitle?.uppercased()
            if (networkReachability?.isReachable)! {
                getNMoQTourDetail()
            } else {
                fetchTourDetailsFromCoredata()
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.facilitiesSecondList) {
            commonListHeaderView.headerTitle.text = headerTitle?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "&amp;", with: "&", options: .regularExpression, range: nil).uppercased()
            if (networkReachability?.isReachable)! {
                getFacilitiesDetail()
            } else {
                fetchFacilitiesDetailsFromCoredata()
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.miaTourGuideList) {
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveMiaTourNotification(notification:)), name: NSNotification.Name(miaTourNotification), object: nil)
            if let museumID = self.museumId {
                DispatchQueue.main.async {
                    self.fetchTourGuideListFromCoredata(museumID: museumID)
                }
            }
            
            commonListHeaderView.headerTitle.isHidden = true
        } else if (exhibitionsPageNameString == ExhbitionPageName.tourGuideList) {
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveHomePageNotificationEn(notification:)), name: NSNotification.Name(homepageNotificationEn), object: nil)
            if  (networkReachability?.isReachable)! {
                DispatchQueue.global(qos: .background).async {
                    self.getTourGuideMuseumsList()
                }
            }
            self.fetchMuseumsInfoFromCoredata()
        } else if (exhibitionsPageNameString == ExhbitionPageName.parkList) {
            fetchNmoqParkListFromCoredata()
            fetchNmoqParkFromCoredata()
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveNmoqParkListNotificationEn(notification:)), name: NSNotification.Name(heritageListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveNmoqParkListNotificationAr(notification:)), name: NSNotification.Name(heritageListNotificationAr), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveNmoqParkNotificationEn(notification:)), name: NSNotification.Name(nmoqParkNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveNmoqParkNotificationAr(notification:)), name: NSNotification.Name(nmoqParkNotificationAr), object: nil)
        }
        popupView.comingSoonPopupDelegate = self
        
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            commonListHeaderView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            commonListHeaderView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    func registerNib() {
        self.commonListTableView.register(UINib(nibName: "CommonListCellXib", bundle: nil), forCellReuseIdentifier: "commonListCellId")
        self.commonListTableView.register(UINib(nibName: "MiaTourHeaderView", bundle: nil), forCellReuseIdentifier: "miaHeaderId")
        self.commonListTableView.register(UINib(nibName: "ParkListView", bundle: nil), forCellReuseIdentifier: "parkListCellId")
        self.commonListTableView.register(UINib(nibName: "NMoQPArkTopCell", bundle: nil), forCellReuseIdentifier: "parkTopCellId")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func loadExhibitionCellPages(cellObj: CommonListCell, selectedIndex: Int) {
        
    }
    func loadPublicArtsDetail(idValue: String) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let publicDtlView = self.storyboard?.instantiateViewController(withIdentifier: "heritageDetailViewId") as! CommonDetailViewController
        publicDtlView.pageNameString = PageName.publicArtsDetail
        publicDtlView.publicArtsDetailId = idValue
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(publicDtlView, animated: false, completion: nil)
    }
    func loadCollectionDetail(currentRow: Int?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let collectionDetailView =  self.storyboard?.instantiateViewController(withIdentifier: "paneldetailViewId") as! PanelDiscussionDetailViewController
        collectionDetailView.pageNameString = NMoQPanelPage.CollectionDetail
        collectionDetailView.collectionName = collection[currentRow!].name?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(collectionDetailView, animated: false, completion: nil)
    }
    func addComingSoonPopup(isTourGuide: Bool = false) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        let viewFrame : CGRect = self.view.frame
        popupView.frame = viewFrame
        if isTourGuide {
            popupView.loadTourGuidePopup()
        }else {
            popupView.loadPopup()
        }
        self.view.addSubview(popupView)
    }
    func loadHeritageDetail(heritageListId: String) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let heritageDtlView = self.storyboard?.instantiateViewController(withIdentifier: "heritageDetailViewId") as! CommonDetailViewController
        heritageDtlView.pageNameString = PageName.heritageDetail
        heritageDtlView.heritageDetailId = heritageListId
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(heritageDtlView, animated: false, completion: nil)
    }
    func loadExhibitionDetailAnimation(exhibitionId: String) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let exhibitionDtlView = self.storyboard?.instantiateViewController(withIdentifier: "heritageDetailViewId") as! CommonDetailViewController
        exhibitionDtlView.pageNameString = PageName.exhibitionDetail
        exhibitionDtlView.fromHome = true
        exhibitionDtlView.exhibitionId = exhibitionId
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)

    }
    func loadDiningDetailAnimation(idValue: String) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let diningDetailView =  self.storyboard?.instantiateViewController(withIdentifier: "heritageDetailViewId") as! CommonDetailViewController
        diningDetailView.diningDetailId = idValue
        diningDetailView.pageNameString = PageName.DiningDetail
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(diningDetailView, animated: false, completion: nil)
        
    }
    func loadTourSecondDetailPage(selectedRow: Int?,fromTour:Bool?,pageName: ExhbitionPageName?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        let panelView =  self.storyboard?.instantiateViewController(withIdentifier: "paneldetailViewId") as! PanelDiscussionDetailViewController

        panelView.selectedRow = selectedRow

        if(pageName == ExhbitionPageName.nmoqTourSecondList) {
            panelView.nmoqTourDetail = nmoqTourDetail
            panelView.panelDetailId = tourDetailId

            if (fromTour)! {
                panelView.pageNameString = NMoQPanelPage.TourDetailPage
            } else {
                panelView.pageNameString = NMoQPanelPage.PanelDetailPage
            }
        } else if(pageName == ExhbitionPageName.facilitiesSecondList) {
            panelView.pageNameString = NMoQPanelPage.FacilitiesDetailPage
            panelView.panelDetailId = facilitiesDetail![selectedRow!].nid
            panelView.facilitiesDetail = facilitiesDetail
            panelView.fromCafeOrDining = true
        }
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(panelView, animated: false, completion: nil)
    }

    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        if ((exhibitionsPageNameString == ExhbitionPageName.homeExhibition) ||  (exhibitionsPageNameString == ExhbitionPageName.homeExhibition)) {
            Analytics.setScreenName(EXHIBITION_LIST, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.heritageList) {
            Analytics.setScreenName(HERITAGE_LIST, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.publicArtsList) {
             Analytics.setScreenName(PUBLIC_ARTS_LIST, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList) {
            Analytics.setScreenName(MUSEUM_COLLECTION, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.diningList) {
            Analytics.setScreenName(DINING_LIST, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.nmoqTourSecondList) {
            Analytics.setScreenName(NMOQ_TOUR_SECOND_LIST, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.miaTourGuideList) {
            Analytics.setScreenName(MIA_TOUR_GUIDE, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.tourGuideList) {
            Analytics.setScreenName(TOUR_GUIDE_VC, screenClass: screenClass)
        }
        
        
    }
    
    func loadLocationMap( mobileLatitude: String?, mobileLongitude: String? ) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (mobileLatitude != nil && mobileLatitude != "" && mobileLongitude != nil && mobileLongitude != "") {
            let latitudeString = (mobileLatitude)!
            let longitudeString = (mobileLongitude)!
            var latitude : Double?
            var longitude : Double?
            if let lat : Double = Double(latitudeString) {
                latitude = lat
            }
            if let long : Double = Double(longitudeString) {
                longitude = long
            }
            
            let destinationLocation = CLLocationCoordinate2D(latitude: latitude!,
                                                             longitude: longitude!)
            let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            let destination = MKMapItem(placemark: destinationPlacemark)
            let mapDetailView = self.storyboard?.instantiateViewController(withIdentifier: "mapViewId") as! MapViewController
            mapDetailView.latitudeString = mobileLatitude
            mapDetailView.longiudeString = mobileLongitude
            mapDetailView.destination = destination
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            self.present(mapDetailView, animated: false, completion: nil)
        }
        else {
            showLocationErrorPopup()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

//MARK:- Notification methods
extension CommonListViewController {
    @objc func receiveCollectionListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (collection.count == 0)){
            self.fetchCollectionListFromCoredata()
        }
    }
    @objc func receiveCollectionListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (collection.count == 0)){
            self.fetchCollectionListFromCoredata()
        }
    }
    @objc func receivePublicArtsListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (publicArtsListArray.count == 0)){
            self.fetchPublicArtsListFromCoredata()
        }
    }
    @objc func receivePublicArtsListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (publicArtsListArray.count == 0)){
            self.fetchPublicArtsListFromCoredata()
        }
    }
    @objc func receiveHomePageNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (museumsList.count == 0)){
            DispatchQueue.main.async{
                self.fetchMuseumsInfoFromCoredata()
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @objc func receiveHomePageNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (museumsList.count == 0)){
            DispatchQueue.main.async{
                self.fetchMuseumsInfoFromCoredata()
            }
        }
    }
    @objc func receiveNmoqParkListNotificationEn(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (nmoqParkList.count == 0)){
            self.fetchNmoqParkListFromCoredata()
        }
    }
    @objc func receiveNmoqParkListNotificationAr(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (nmoqParkList.count == 0)){
            self.fetchNmoqParkListFromCoredata()
        }
    }
    @objc func receiveNmoqParkNotificationEn(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (nmoqParks.count == 0)){
            self.fetchNmoqParkFromCoredata()
        }
    }
    @objc func receiveNmoqParkNotificationAr(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (nmoqParks.count == 0)){
            self.fetchNmoqParkFromCoredata()
        }
    }
    @objc func receiveExhibitionListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (exhibition.count == 0)){
            self.fetchExhibitionsListFromCoredata()
        }
    }
    @objc func receiveExhibitionListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (exhibition.count == 0)){
            self.fetchExhibitionsListFromCoredata()
        }
    }
    @objc func receiveMiaTourNotification(notification: NSNotification) {
        let data = notification.userInfo as? [String:String]
        if (data?.count)!>0 {
            if let museumID = self.museumId, museumID == data!["id"] {
                self.fetchTourGuideListFromCoredata(museumID: museumID)
            }
        }
    }
    @objc func receiveHeritageListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (heritageListArray.count == 0)){
            self.fetchHeritageListFromCoredata()
        }
    }
    @objc func receiveHeritageListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (heritageListArray.count == 0)){
            self.fetchHeritageListFromCoredata()
        }
    }
}

//MARK:- Segue controller
extension CommonListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "commonListToDetailSegue") {
            let commonDetail = segue.destination as! CommonDetailViewController
            if ((exhibitionsPageNameString == ExhbitionPageName.homeExhibition) || (exhibitionsPageNameString == ExhbitionPageName.museumExhibition)) {
                commonDetail.pageNameString = PageName.exhibitionDetail
                commonDetail.fromHome = true
                commonDetail.exhibitionId = exhibition[selectedRow!].id
            } else if (exhibitionsPageNameString == ExhbitionPageName.heritageList) {
                commonDetail.pageNameString = PageName.heritageDetail
                commonDetail.heritageDetailId = heritageListArray[selectedRow!].id
            }else if (exhibitionsPageNameString == ExhbitionPageName.publicArtsList) {
                commonDetail.pageNameString = PageName.publicArtsDetail
                commonDetail.publicArtsDetailId = publicArtsListArray[selectedRow!].id
            } else if (exhibitionsPageNameString == ExhbitionPageName.diningList) {
                commonDetail.diningDetailId = diningListArray[selectedRow!].id
                commonDetail.pageNameString = PageName.DiningDetail
            } else if (exhibitionsPageNameString == ExhbitionPageName.parkList) {
                commonDetail.pageNameString = PageName.NMoQPark
                commonDetail.parkDetailId = nmoqParks[selectedRow! - 1].nid
            }
        } else if (segue.identifier == "commonListToPanelDetailSegue") {
            let panelDetail = segue.destination as! PanelDiscussionDetailViewController
            if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList) {
                panelDetail.pageNameString = NMoQPanelPage.CollectionDetail
                panelDetail.collectionName = collection[selectedRow!].name?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
            } else if (exhibitionsPageNameString == ExhbitionPageName.nmoqTourSecondList) {
                panelDetail.selectedRow = selectedRow
                panelDetail.nmoqTourDetail = nmoqTourDetail
                panelDetail.panelDetailId = tourDetailId
                if (isFromTour)! {
                    panelDetail.pageNameString = NMoQPanelPage.TourDetailPage
                } else {
                    panelDetail.pageNameString = NMoQPanelPage.PanelDetailPage
                }
            } else if (exhibitionsPageNameString == ExhbitionPageName.facilitiesSecondList) {
                panelDetail.selectedRow = selectedRow
                panelDetail.pageNameString = NMoQPanelPage.FacilitiesDetailPage
                panelDetail.panelDetailId = facilitiesDetail![selectedRow!].nid
                panelDetail.facilitiesDetail = facilitiesDetail
                panelDetail.fromCafeOrDining = true
            } else if (exhibitionsPageNameString == ExhbitionPageName.parkList) {
                panelDetail.pageNameString = NMoQPanelPage.PlayGroundPark
                panelDetail.nid = nmoqParks[selectedRow! - 1].nid
            }
        } else if (segue.identifier == "commonListToMiaTourSegue") {
            let miaTouguideView = segue.destination as! MiaTourDetailViewController
            miaTouguideView.museumId = museumId ?? "0"
            if (miaTourDataFullArray != nil) {
                miaTouguideView.tourGuideDetail = miaTourDataFullArray[selectedRow! - 1]
            }
        } else if (segue.identifier == "commonListToFloormapSegue") {
            let floorMapView = segue.destination as! FloorMapViewController
            floorMapView.fromTourString = fromTour.exploreTour
        }
    }
}

extension CommonListViewController {
    func showLocationErrorPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadMapKitLocationErrorPopup()
        self.view.addSubview(popupView)
    }
}
