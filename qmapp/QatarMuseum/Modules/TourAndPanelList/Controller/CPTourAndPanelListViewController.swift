//
//  TourAndPanelListViewController.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 28/11/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//



import Crashlytics
import Firebase
import UIKit


enum CPNMoQPageName {
    case Tours
    case PanelDiscussion
    case TravelArrangementList
    case Facilities
}

class CPTourAndPanelListViewController: UIViewController {
    @IBOutlet weak var collectionTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var headerView: CommonHeaderView!
    
    var pageNameString : CPNMoQPageName?
    let networkReachability = NetworkReachabilityManager()
    var imageArray: [String] = []
    var titleArray: [String] = []
    var nmoqTourList: [NMoQTour]! = []
    var nmoqActivityList: [NMoQActivitiesList]! = []
    var travelList: [HomeBanner]! = []
    var facilitiesList: [Facilities]! = []
    var sortIdTest = String()
    var bannerId: String? = ""
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        registerCell()
        setupUI()
        collectionTableView.delegate = self
        collectionTableView.dataSource = self
        self.recordScreenView()
    }
    
    func setupUI() {
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        headerView.headerViewDelegate = self
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
        if (pageNameString == CPNMoQPageName.Tours) {
            headerView.headerTitle.text = NSLocalizedString("TOUR_TITLE", comment: "TOUR_TITLE in the NMoQ page")
            fetchTourInfoFromCoredata(isTourGuide: true)
//            if  (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getNMoQTourList()
//                }
//            }
            NotificationCenter.default.addObserver(self, selector: #selector(CPTourAndPanelListViewController.receiveNmoqTourListNotification(notification:)), name: NSNotification.Name(nmoqTourlistNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CPTourAndPanelListViewController.receiveNmoqTourListNotification(notification:)), name: NSNotification.Name(nmoqTourlistNotificationAr), object: nil)
        } else if (pageNameString == CPNMoQPageName.PanelDiscussion) {
            headerView.headerTitle.text = NSLocalizedString("PANEL_DISCUSSION", comment: "PANEL_DISCUSSION in the NMoQ page").uppercased()
            fetchActivityListFromCoredata()
//            if  (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getNMoQSpecialEventList()
//                }
//            }
            NotificationCenter.default.addObserver(self, selector: #selector(CPTourAndPanelListViewController.receiveActivityListNotificationEn(notification:)), name: NSNotification.Name(nmoqActivityListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CPTourAndPanelListViewController.receiveActivityListNotificationEn(notification:)), name: NSNotification.Name(nmoqActivityListNotificationAr), object: nil)
            
        } else if (pageNameString == CPNMoQPageName.TravelArrangementList) {
            headerView.headerTitle.text = NSLocalizedString("TRAVEL_ARRANGEMENTS", comment: "TRAVEL_ARRANGEMENTS Label in the Travel page page").uppercased()
            NotificationCenter.default.addObserver(self, selector: #selector(CPTourAndPanelListViewController.receiveNmoqTravelListNotificationEn(notification:)), name: NSNotification.Name(nmoqTravelListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CPTourAndPanelListViewController.receiveNmoqTravelListNotificationAr(notification:)), name: NSNotification.Name(nmoqTravelListNotificationAr), object: nil)
            fetchTravelInfoFromCoredata()
//            if (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getTravelList()
//                }
//            }
        }  else if (pageNameString == CPNMoQPageName.Facilities) {
            headerView.headerTitle.text = NSLocalizedString("FACILITIES",
                                                            comment: "FACILITIES Label in the Facilities page page").uppercased()
            NotificationCenter.default.addObserver(self, selector: #selector(CPTourAndPanelListViewController.receiveFacilitiesListNotificationEn(notification:)), name: NSNotification.Name(facilitiesListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CPTourAndPanelListViewController.receiveFacilitiesListNotificationAr(notification:)), name: NSNotification.Name(facilitiesListNotificationAr), object: nil)
            fetchFacilitiesListFromCoredata()
//            if (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getFacilitiesListFromServer()
//                }
//            }
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), pageNameString: \(String(describing: pageNameString))")
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func registerCell() {
       // self.collectionTableView.register(UINib(nibName: "NMoQListCell", bundle: nil), forCellReuseIdentifier: "nMoQListCellId")
         self.collectionTableView.register(UINib(nibName: "CommonListCellXib", bundle: nil), forCellReuseIdentifier: "commonListCellId")
    }
    
    func loadTourViewPage(selectedRow: Int?,isFromTour:Bool?, pageName: CPNMoQPageName?) {
        let tourView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
        
        if pageName == CPNMoQPageName.Tours {
            tourView.isFromTour = true
            tourView.exhibitionsPageNameString = ExhbitionPageName.nmoqTourSecondList
            tourView.tourDetailId = nmoqTourList[selectedRow!].nid
            tourView.headerTitle = nmoqTourList[selectedRow!].subtitle
        } else if pageName == CPNMoQPageName.PanelDiscussion {
            tourView.isFromTour = false
            tourView.exhibitionsPageNameString = ExhbitionPageName.nmoqTourSecondList
            tourView.tourDetailId = nmoqActivityList[selectedRow!].nid
            tourView.headerTitle = nmoqActivityList[selectedRow!].subtitle
        } else if pageName == CPNMoQPageName.Facilities {
            tourView.isFromTour = false
            tourView.exhibitionsPageNameString = ExhbitionPageName.facilitiesSecondList
            tourView.tourDetailId = facilitiesList[selectedRow!].nid
            tourView.headerTitle = facilitiesList[selectedRow!].title
        }
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(tourView, animated: false, completion: nil)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), pageNameString: \(String(describing: pageName))")
    }
    func loadPanelDiscussionDetailPage(selectedRow: Int?) {
        let panelView =  self.storyboard?.instantiateViewController(withIdentifier: "paneldetailViewId") as! CPPanelDiscussionDetailViewController
        panelView.pageNameString = NMoQPanelPage.FacilitiesDetailPage
        panelView.panelDetailId = facilitiesList[selectedRow!].nid
        panelView.selectedRow = selectedRow
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(panelView, animated: false, completion: nil)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), pageNameString: \(String(describing: panelView.pageNameString))")
    }
    func loadTravelDetailPage(selectedIndex: Int) {
        let museumAboutView = self.storyboard?.instantiateViewController(withIdentifier: "heritageDetailViewId2") as! CPMuseumAboutViewController
        museumAboutView.pageNameString = PageName2.museumTravel
        museumAboutView.travelImage = travelList[selectedIndex].bannerLink
        museumAboutView.travelTitle = travelList[selectedIndex].title
        museumAboutView.travelDetail = travelList[selectedIndex]
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(museumAboutView, animated: false, completion: nil)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), pageNameString: \(String(describing: museumAboutView.pageNameString))")
    }
    
}

//MARK:- Reusable View Methods
extension CPTourAndPanelListViewController: HeaderViewProtocol,LoadingViewProtocol {
    //    MARK: HeaderView delegate
    func headerCloseButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_header_close,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
        self.dismiss(animated: false, completion: nil)
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if(pageNameString == CPNMoQPageName.Tours) {
                appDelegate?.getNMoQTourList(lang: LocalizationLanguage.currentAppleLanguage())
            } else if(pageNameString == CPNMoQPageName.PanelDiscussion) {
                appDelegate?.getNMoQSpecialEventList(lang: LocalizationLanguage.currentAppleLanguage())
            } else if(pageNameString == CPNMoQPageName.TravelArrangementList) {
                appDelegate?.getTravelList(lang: LocalizationLanguage.currentAppleLanguage())
            } else if(pageNameString == CPNMoQPageName.Facilities) {
                appDelegate?.getFacilitiesListFromServer(lang: LocalizationLanguage.currentAppleLanguage())
            }
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_tryagain,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
}

//MARK:- Notification methods
extension CPTourAndPanelListViewController {
    @objc func receiveNmoqTourListNotification(notification: NSNotification) {
        if(nmoqTourList.count == 0) {
            let data = notification.userInfo as? [String:Bool]
            if ((data?.count)! > 0) {
                if((data!["isTour"])! && (pageNameString == CPNMoQPageName.Tours)) {
                    self.fetchTourInfoFromCoredata(isTourGuide: true)
                } else if(((data!["isTour"])! == false) && (pageNameString == CPNMoQPageName.PanelDiscussion)){
                    self.fetchTourInfoFromCoredata(isTourGuide: false)
                }
            }
        }
        
    }
    
    @objc func receiveNmoqTravelListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (travelList.count == 0)) {
            self.fetchTravelInfoFromCoredata()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @objc func receiveNmoqTravelListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (travelList.count == 0)) {
            self.fetchTravelInfoFromCoredata()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @objc func receiveFacilitiesListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (facilitiesList.count == 0)) {
            self.fetchFacilitiesListFromCoredata()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @objc func receiveFacilitiesListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (facilitiesList.count == 0)) {
            self.fetchFacilitiesListFromCoredata()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func receiveActivityListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (nmoqActivityList.count == 0)){
            self.fetchActivityListFromCoredata()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @objc func receiveActivityListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (nmoqActivityList.count == 0)){
            self.fetchActivityListFromCoredata()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
}
