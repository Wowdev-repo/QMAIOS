//
//  TourAndPanelListViewController.swift
//  QatarMuseums
//
//  Created by Developer on 28/11/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import Firebase
import UIKit
import CocoaLumberjack

enum NMoQPageName {
    case Tours
    case PanelDiscussion
    case TravelArrangementList
    case Facilities
}

class TourAndPanelListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,HeaderViewProtocol,LoadingViewProtocol {
    @IBOutlet weak var collectionTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var headerView: CommonHeaderView!
    
    var pageNameString : NMoQPageName?
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
        if (pageNameString == NMoQPageName.Tours) {
            headerView.headerTitle.text = NSLocalizedString("TOUR_TITLE", comment: "TOUR_TITLE in the NMoQ page")
            fetchTourInfoFromCoredata(isTourGuide: true)
//            if  (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getNMoQTourList()
//                }
//            }
            NotificationCenter.default.addObserver(self, selector: #selector(TourAndPanelListViewController.receiveNmoqTourListNotification(notification:)), name: NSNotification.Name(nmoqTourlistNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(TourAndPanelListViewController.receiveNmoqTourListNotification(notification:)), name: NSNotification.Name(nmoqTourlistNotificationAr), object: nil)
        } else if (pageNameString == NMoQPageName.PanelDiscussion) {
            headerView.headerTitle.text = NSLocalizedString("PANEL_DISCUSSION", comment: "PANEL_DISCUSSION in the NMoQ page").uppercased()
            fetchActivityListFromCoredata()
//            if  (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getNMoQSpecialEventList()
//                }
//            }
            NotificationCenter.default.addObserver(self, selector: #selector(TourAndPanelListViewController.receiveActivityListNotificationEn(notification:)), name: NSNotification.Name(nmoqActivityListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(TourAndPanelListViewController.receiveActivityListNotificationEn(notification:)), name: NSNotification.Name(nmoqActivityListNotificationAr), object: nil)
            
        } else if (pageNameString == NMoQPageName.TravelArrangementList) {
            headerView.headerTitle.text = NSLocalizedString("TRAVEL_ARRANGEMENTS", comment: "TRAVEL_ARRANGEMENTS Label in the Travel page page").uppercased()
            NotificationCenter.default.addObserver(self, selector: #selector(TourAndPanelListViewController.receiveNmoqTravelListNotificationEn(notification:)), name: NSNotification.Name(nmoqTravelListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(TourAndPanelListViewController.receiveNmoqTravelListNotificationAr(notification:)), name: NSNotification.Name(nmoqTravelListNotificationAr), object: nil)
            fetchTravelInfoFromCoredata()
//            if (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getTravelList()
//                }
//            }
        }  else if (pageNameString == NMoQPageName.Facilities) {
            headerView.headerTitle.text = NSLocalizedString("FACILITIES", comment: "FACILITIES Label in the Facilities page page").uppercased()
            NotificationCenter.default.addObserver(self, selector: #selector(TourAndPanelListViewController.receiveFacilitiesListNotificationEn(notification:)), name: NSNotification.Name(facilitiesListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(TourAndPanelListViewController.receiveFacilitiesListNotificationAr(notification:)), name: NSNotification.Name(facilitiesListNotificationAr), object: nil)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (pageNameString == NMoQPageName.Tours) {
            return nmoqTourList.count
        } else if (pageNameString == NMoQPageName.PanelDiscussion) {
            return nmoqActivityList.count
        } else if (pageNameString == NMoQPageName.TravelArrangementList) {
            return travelList.count
        } else if (pageNameString == NMoQPageName.Facilities){
            return facilitiesList.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
        if (pageNameString == NMoQPageName.Tours) {
            cell.setTourListDate(tourList: nmoqTourList[indexPath.row], isTour: true)
        } else if (pageNameString == NMoQPageName.PanelDiscussion){
            cell.setActivityListDate(activityList: nmoqActivityList[indexPath.row])
        } else if (pageNameString == NMoQPageName.TravelArrangementList){
            cell.setTravelListData(travelListData: travelList[indexPath.row])
        } else if (pageNameString == NMoQPageName.Facilities){
            cell.setFacilitiesListData(facilitiesListData: facilitiesList[indexPath.row])
        }
        
        loadingView.stopLoading()
        loadingView.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightValue = UIScreen.main.bounds.height/100
        return heightValue*27
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (pageNameString == NMoQPageName.Tours) {
            loadTourViewPage(selectedRow: indexPath.row, isFromTour: true, pageName: NMoQPageName.Tours)
        } else if (pageNameString == NMoQPageName.PanelDiscussion) {
            loadTourViewPage(selectedRow: indexPath.row, isFromTour: false, pageName: NMoQPageName.PanelDiscussion)
        } else if (pageNameString == NMoQPageName.TravelArrangementList) {
            loadTravelDetailPage(selectedIndex: indexPath.row)
        }
        else if (pageNameString == NMoQPageName.Facilities) {
            if((facilitiesList[indexPath.row].nid == "15256") || (facilitiesList[indexPath.row].nid == "15826")) {
                loadTourViewPage(selectedRow: indexPath.row, isFromTour: false, pageName: NMoQPageName.Facilities)
            } else {
                loadPanelDiscussionDetailPage(selectedRow: indexPath.row)
            }
            
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), pageNameString: \(String(describing: pageNameString))")
    }
    
    func loadTourViewPage(selectedRow: Int?,isFromTour:Bool?, pageName: NMoQPageName?) {
        let tourView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
        
        if pageName == NMoQPageName.Tours {
            tourView.isFromTour = true
            tourView.exhibitionsPageNameString = ExhbitionPageName.nmoqTourSecondList
            tourView.tourDetailId = nmoqTourList[selectedRow!].nid
            tourView.headerTitle = nmoqTourList[selectedRow!].subtitle
        } else if pageName == NMoQPageName.PanelDiscussion {
            tourView.isFromTour = false
            tourView.exhibitionsPageNameString = ExhbitionPageName.nmoqTourSecondList
            tourView.tourDetailId = nmoqActivityList[selectedRow!].nid
            tourView.headerTitle = nmoqActivityList[selectedRow!].subtitle
        } else if pageName == NMoQPageName.Facilities {
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
        let panelView =  self.storyboard?.instantiateViewController(withIdentifier: "paneldetailViewId") as! PanelDiscussionDetailViewController
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
        let museumAboutView = self.storyboard?.instantiateViewController(withIdentifier: "heritageDetailViewId2") as! MuseumAboutViewController
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
            if(pageNameString == NMoQPageName.Tours) {
                appDelegate?.getNMoQTourList(lang: LocalizationLanguage.currentAppleLanguage())
            } else if(pageNameString == NMoQPageName.PanelDiscussion) {
                appDelegate?.getNMoQSpecialEventList(lang: LocalizationLanguage.currentAppleLanguage())
            } else if(pageNameString == NMoQPageName.TravelArrangementList) {
                appDelegate?.getTravelList(lang: LocalizationLanguage.currentAppleLanguage())
            } else if(pageNameString == NMoQPageName.Facilities) {
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
    //MARK: Service call
    func getNMoQTourList() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")

        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQTourList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<NMoQTourList>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.nmoqTourList.count == 0) {
                    self.nmoqTourList = data.nmoqTourList
                    self.collectionTableView.reloadData()
                    if(self.nmoqTourList.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                }
                if(self.nmoqTourList.count > 0) {
                    if let nmoqTourList = data.nmoqTourList {
                        self.saveOrUpdateTourListCoredata(nmoqTourList: nmoqTourList,
                                                          isTourGuide: true)
                    }
                }
                
            case .failure( _):

                if(self.nmoqTourList.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            }
        }
    }
    
    //MARK: Tour List Coredata Method
    func saveOrUpdateTourListCoredata(nmoqTourList: [NMoQTour], isTourGuide:Bool) {
        if !nmoqTourList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateTourList(nmoqTourList: nmoqTourList,
                                                            managedContext: managedContext,
                                                            isTourGuide: isTourGuide)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateTourList(nmoqTourList: nmoqTourList,
                                                            managedContext : managedContext,
                                                            isTourGuide: isTourGuide)
                }
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func fetchTourInfoFromCoredata(isTourGuide:Bool) {
        let managedContext = getContext()
        do {
                var tourListArray = [NMoQTourListEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQTourListEntity")
                fetchRequest.predicate = NSPredicate.init(format: "isTourGuide == \(isTourGuide)")
                tourListArray = (try managedContext.fetch(fetchRequest) as? [NMoQTourListEntity])!
                if (tourListArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNMoQTourList()
                        }
                    }
                    tourListArray.sort(by: {$0.sortId < $1.sortId})
                    for i in 0 ... tourListArray.count-1 {
                        let tourListDict = tourListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (tourListDict.tourImagesRelation?.allObjects) as! [ImageEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].image!)
                            }
                        }
                        self.nmoqTourList.insert(NMoQTour(title: tourListArray[i].title, dayDescription: tourListArray[i].dayDescription, images: imagesArray, subtitle: tourListArray[i].subtitle, sortId: String(tourListArray[i].sortId), nid: tourListArray[i].nid, eventDate: tourListArray[i].eventDate, date: tourListArray[i].dateString, descriptioForModerator: tourListArray[i].descriptioForModerator, mobileLatitude: tourListArray[i].mobileLatitude, moderatorName: tourListArray[i].moderatorName, longitude: tourListArray[i].longitude, contactEmail: tourListArray[i].contactEmail, contactPhone: tourListArray[i].contactPhone,language: tourListArray[i].language), at: i)
                    }
                    if(nmoqTourList.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    DispatchQueue.main.async{
                        self.collectionTableView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getNMoQTourList() //coreDataMigratio  solution
                    }
                }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //Activities API
    func getNMoQSpecialEventList() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQSpecialEventList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<NMoQActivitiesListData>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.nmoqActivityList.count == 0) {
                    self.nmoqActivityList = data.nmoqActivitiesList
                    if self.nmoqActivityList.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                        self.nmoqActivityList = self.nmoqActivityList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                    self.collectionTableView.reloadData()
                    if(self.nmoqActivityList.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                }
                if(self.nmoqActivityList.count > 0) {
                    if let list = data.nmoqActivitiesList {
                        self.saveOrUpdateActivityListCoredata(nmoqActivityList: list)
                    }
                }
            case .failure( _):
                if(self.nmoqActivityList.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: ActivityList Coredata Method
    func saveOrUpdateActivityListCoredata(nmoqActivityList: [NMoQActivitiesList]) {
        if !nmoqActivityList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateActivityList(nmoqActivityList: nmoqActivityList,
                                                                managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateActivityList(nmoqActivityList: nmoqActivityList,
                                                                managedContext : managedContext)
                }
            }
        }
    }
    
    func fetchActivityListFromCoredata() {
        let managedContext = getContext()
        do {
                var activityListArray = [NMoQActivitiesEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQActivitiesEntity")
                activityListArray = (try managedContext.fetch(fetchRequest) as? [NMoQActivitiesEntity])!
                if (activityListArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNMoQSpecialEventList()
                        }
                    }
                    for i in 0 ... activityListArray.count-1 {
                        let activityListDict = activityListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (activityListDict.activityImgRelation?.allObjects) as! [ImageEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].image!)
                            }
                        }
                        self.nmoqActivityList.insert(NMoQActivitiesList(title: activityListDict.title, dayDescription: activityListDict.dayDescription, images: imagesArray, subtitle: activityListDict.subtitle, sortId: activityListDict.sortId, nid: activityListDict.nid, eventDate: activityListDict.eventDate, date: activityListDict.date, descriptioForModerator: activityListDict.descriptioForModerator, mobileLatitude: activityListDict.mobileLatitude, moderatorName: activityListDict.moderatorName, longitude: activityListDict.longitude, contactEmail: activityListDict.contactEmail, contactPhone: activityListDict.contactPhone, language: activityListDict.language), at: i)
                    }
                    if(nmoqActivityList.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        if self.nmoqActivityList.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqActivityList = self.nmoqActivityList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                    }
                    DispatchQueue.main.async{
                        self.collectionTableView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getNMoQSpecialEventList()//coreDataMigratio  solution
                    }
                }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: Facilities API
    func getFacilitiesListFromServer()
    {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.FacilitiesList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<FacilitiesData>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.facilitiesList.count == 0) {
                    self.facilitiesList = data.facilitiesList
                    if self.facilitiesList.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                        self.facilitiesList = self.facilitiesList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                    self.collectionTableView.reloadData()
                    if(self.facilitiesList.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                }
                if(self.facilitiesList.count > 0) {
                    if let facilitiesList = data.facilitiesList {
                        self.saveOrUpdateFacilitiesListCoredata(facilitiesList: facilitiesList)
                    }
                }
            case .failure( _):
                if(self.facilitiesList.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            }
            
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        }
    }
    //MARK: Facilities List Coredata Method
    func saveOrUpdateFacilitiesListCoredata(facilitiesList: [Facilities]) {
        if !facilitiesList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateFacilitiesEntity(facilitiesList: facilitiesList,
                                                       managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateFacilitiesEntity(facilitiesList: facilitiesList,
                                                       managedContext : managedContext)
                }
            }
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        }
    }
    
    
    
    func fetchFacilitiesListFromCoredata() {
        let managedContext = getContext()
        do {
                var facilitiesListArray = [FacilitiesEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "FacilitiesEntity")
                facilitiesListArray = (try managedContext.fetch(fetchRequest) as? [FacilitiesEntity])!
                if (facilitiesListArray.count > 0) {
                    if (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getFacilitiesListFromServer()
                        }
                    }
                    for i in 0 ... facilitiesListArray.count-1 {
                        let facilitiesListDict = facilitiesListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (facilitiesListDict.facilitiesImgRelation?.allObjects) as! [ImageEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].image!)
                            }
                        }
                        self.facilitiesList.insert(Facilities(title: facilitiesListDict.title, sortId: facilitiesListDict.sortId, nid: facilitiesListDict.nid, images: imagesArray), at: i)
                    }
                    if(facilitiesList.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        if self.facilitiesList.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.facilitiesList = self.facilitiesList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                    }
                    DispatchQueue.main.async{
                        self.collectionTableView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getFacilitiesListFromServer()//coreDataMigratio  solution
                    }
                }

        } catch let error as NSError {
            DDLogError("Could not fetch. \(error), \(error.userInfo)")
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        if(pageNameString == NMoQPageName.Tours) {
            Analytics.setScreenName(NMOQ_TOUR_LIST, screenClass: screenClass)
        } else if(pageNameString == NMoQPageName.PanelDiscussion){
            Analytics.setScreenName(NMOQ_ACTIVITY_LIST, screenClass: screenClass)
        } else if(pageNameString == NMoQPageName.TravelArrangementList){
            Analytics.setScreenName(TRAVEL_ARRANGEMENT_VC, screenClass: screenClass)
        }
        
    }
    //MARK: TravelList Methods
    //MARK: Service Call
    func getTravelList() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQTravelList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<HomeBannerList>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.travelList.count == 0) {
                    self.travelList = data.homeBannerList
                    self.collectionTableView.reloadData()
                    if(self.travelList.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                }
                if(self.nmoqActivityList.count > 0) {
                    if let homeBannerList = data.homeBannerList {
                        self.saveOrUpdateTravelListCoredata(travelList: homeBannerList)
                    }
                }
            case .failure( _):
                if(self.travelList.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            }
        }
    }
    
    //MARK: Travel List Coredata
    func saveOrUpdateTravelListCoredata(travelList: [HomeBanner]) {
        if !travelList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateTravelList(travelList: travelList,
                                                 managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateTravelList(travelList: travelList,
                                                 managedContext : managedContext)
                }
            }
        }
    }
    
    
    
    func fetchTravelInfoFromCoredata() {
        let managedContext = getContext()
        do {
//            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var travelListArray = [NMoQTravelListEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQTravelListEntity")
                travelListArray = (try managedContext.fetch(fetchRequest) as? [NMoQTravelListEntity])!
                if (travelListArray.count > 0) {
                    if (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getTravelList()
                        }
                    }
                    for i in 0 ... travelListArray.count-1 {
                        self.travelList.insert(HomeBanner(title: travelListArray[i].title, fullContentID: travelListArray[i].fullContentID, bannerTitle: travelListArray[i].bannerTitle, bannerLink: travelListArray[i].bannerLink, image: nil, introductionText: travelListArray[i].introductionText, email: travelListArray[i].email, contactNumber: travelListArray[i].contactNumber, promotionalCode: travelListArray[i].promotionalCode, claimOffer: travelListArray[i].claimOffer, language: travelListArray[i].language), at: i)
                    }
                    if(travelList.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        if(bannerId != nil) {
                            if let arrayOffset = self.travelList.index(where: {$0.fullContentID == bannerId}) {
                                self.travelList.remove(at: arrayOffset)
                            }
                        }
                    }
                    DispatchQueue.main.async{
                        self.collectionTableView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getTravelList()//coreDataMigratio  solution
                    }
                }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    @objc func receiveNmoqTourListNotification(notification: NSNotification) {
        if(nmoqTourList.count == 0) {
            let data = notification.userInfo as? [String:Bool]
            if ((data?.count)! > 0) {
                if((data!["isTour"])! && (pageNameString == NMoQPageName.Tours)) {
                    self.fetchTourInfoFromCoredata(isTourGuide: true)
                } else if(((data!["isTour"])! == false) && (pageNameString == NMoQPageName.PanelDiscussion)){
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

