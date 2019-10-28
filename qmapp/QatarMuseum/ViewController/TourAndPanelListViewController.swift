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
    }
    func loadTravelDetailPage(selectedIndex: Int) {
        let detailStoryboard: UIStoryboard = UIStoryboard(name: "DetailPageStoryboard", bundle: nil)
        
        let museumAboutView = detailStoryboard.instantiateViewController(withIdentifier: "heritageDetailViewId2") as! MuseumAboutViewController
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
    }
    func headerCloseButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
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
        }
    }
    
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    //MARK: Service call
    func getNMoQTourList() {
        _ = Alamofire.request(QatarMuseumRouter.GetNMoQTourList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<NMoQTourList>) -> Void in
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
                    self.saveOrUpdateTourListCoredata(nmoqTourList: data.nmoqTourList, isTourGuide: true)
                }
                
            case .failure(let error):
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
    func saveOrUpdateTourListCoredata(nmoqTourList:[NMoQTour]?,isTourGuide:Bool) {
        if ((nmoqTourList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.tourListCoreDataInBackgroundThread(nmoqTourList: nmoqTourList, managedContext: managedContext, isTourGuide: isTourGuide)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.tourListCoreDataInBackgroundThread(nmoqTourList: nmoqTourList, managedContext : managedContext, isTourGuide: isTourGuide)
                }
            }
        }
    }
    
    func tourListCoreDataInBackgroundThread(nmoqTourList:[NMoQTour]?,managedContext: NSManagedObjectContext,isTourGuide:Bool) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "NMoQTourListEntity", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQTourListEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqTourList?.count)!-1 {
                    let tourListDict = nmoqTourList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQTourListEntity", idKey: "nid", idValue: tourListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let tourListdbDict = fetchResult[0] as! NMoQTourListEntity
                        tourListdbDict.title = tourListDict.title
                        tourListdbDict.dayDescription = tourListDict.dayDescription
                        tourListdbDict.subtitle =  tourListDict.subtitle
                        tourListdbDict.sortId = Int16(tourListDict.sortId!)!
                        tourListdbDict.nid =  tourListDict.nid
                        tourListdbDict.eventDate = tourListDict.eventDate
                        
                        //eventlist
                        tourListdbDict.dateString = tourListDict.date
                        tourListdbDict.descriptioForModerator = tourListDict.descriptioForModerator
                        tourListdbDict.mobileLatitude = tourListDict.mobileLatitude
                        tourListdbDict.moderatorName = tourListDict.moderatorName
                        tourListdbDict.longitude = tourListDict.longitude
                        tourListdbDict.contactEmail = tourListDict.contactEmail
                        tourListdbDict.contactPhone = tourListDict.contactPhone
                        tourListdbDict.isTourGuide = isTourGuide
                        
                        if(tourListDict.images != nil){
                            if((tourListDict.images?.count)! > 0) {
                                for i in 0 ... (tourListDict.images?.count)!-1 {
                                    var tourImage: NMoqTourImagesEntity!
                                    let tourImgaeArray: NMoqTourImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoqTourImagesEntity", into: managedContext) as! NMoqTourImagesEntity
                                    tourImgaeArray.image = tourListDict.images?[i]
                                    
                                    tourImage = tourImgaeArray
                                    tourListdbDict.addToTourImagesRelation(tourImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveTourListToCoreData(tourListDict: tourListDict, managedObjContext: managedContext, isTourGuide: isTourGuide)
                    }
                }
            } else {
                for i in 0 ... (nmoqTourList?.count)!-1 {
                    let tourListDict : NMoQTour?
                    tourListDict = nmoqTourList?[i]
                    self.saveTourListToCoreData(tourListDict: tourListDict!, managedObjContext: managedContext, isTourGuide: isTourGuide)
                }
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "NMoQTourListEntityAr", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQTourListEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqTourList?.count)!-1 {
                    let tourListDict = nmoqTourList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQTourListEntityAr", idKey: "nid", idValue: tourListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let tourListdbDict = fetchResult[0] as! NMoQTourListEntityAr
                        tourListdbDict.title = tourListDict.title
                        tourListdbDict.dayDescription = tourListDict.dayDescription
                        tourListdbDict.subtitle =  tourListDict.subtitle
                        tourListdbDict.sortId = Int16(tourListDict.sortId!)!
                        tourListdbDict.nid =  tourListDict.nid
                        tourListdbDict.eventDate = tourListDict.eventDate
                        
                        //eventlist
                        tourListdbDict.dateString = tourListDict.date
                        tourListdbDict.descriptioForModerator = tourListDict.descriptioForModerator
                        tourListdbDict.mobileLatitude = tourListDict.mobileLatitude
                        tourListdbDict.moderatorName = tourListDict.moderatorName
                        tourListdbDict.longitude = tourListDict.longitude
                        tourListdbDict.contactEmail = tourListDict.contactEmail
                        tourListdbDict.contactPhone = tourListDict.contactPhone
                        tourListdbDict.isTourGuide = isTourGuide
                        
                        if(tourListDict.images != nil){
                            if((tourListDict.images?.count)! > 0) {
                                for i in 0 ... (tourListDict.images?.count)!-1 {
                                    var tourImage: NMoqTourImagesEntityAr!
                                    let tourImgaeArray: NMoqTourImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoqTourImagesEntityAr", into: managedContext) as! NMoqTourImagesEntityAr
                                    tourImgaeArray.image = tourListDict.images?[i]
                                    
                                    tourImage = tourImgaeArray
                                    tourListdbDict.addToTourImagesRelationAr(tourImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveTourListToCoreData(tourListDict: tourListDict, managedObjContext: managedContext, isTourGuide: isTourGuide)
                    }
                }
            } else {
                for i in 0 ... (nmoqTourList?.count)!-1 {
                    let tourListDict : NMoQTour?
                    tourListDict = nmoqTourList?[i]
                    self.saveTourListToCoreData(tourListDict: tourListDict!, managedObjContext: managedContext, isTourGuide: isTourGuide)
                }
            }
        }
    }
    func saveTourListToCoreData(tourListDict: NMoQTour, managedObjContext: NSManagedObjectContext,isTourGuide:Bool) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let tourListInfo: NMoQTourListEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQTourListEntity", into: managedObjContext) as! NMoQTourListEntity
            tourListInfo.title = tourListDict.title
            tourListInfo.dayDescription = tourListDict.dayDescription
            tourListInfo.subtitle = tourListDict.subtitle
            tourListInfo.sortId = Int16(tourListDict.sortId!)!
            tourListInfo.nid = tourListDict.nid
            tourListInfo.eventDate = tourListDict.eventDate
            
            //specialEvent
            tourListInfo.dateString = tourListDict.date
            tourListInfo.descriptioForModerator = tourListDict.descriptioForModerator
            tourListInfo.mobileLatitude = tourListDict.mobileLatitude
            tourListInfo.moderatorName = tourListDict.moderatorName
            tourListInfo.longitude = tourListDict.longitude
            tourListInfo.contactEmail = tourListDict.contactEmail
            tourListInfo.contactPhone = tourListDict.contactPhone
            tourListInfo.isTourGuide = isTourGuide
            if(tourListDict.images != nil){
                if((tourListDict.images?.count)! > 0) {
                    for i in 0 ... (tourListDict.images?.count)!-1 {
                        var tourImage: NMoqTourImagesEntity!
                        let tourImgaeArray: NMoqTourImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoqTourImagesEntity", into: managedObjContext) as! NMoqTourImagesEntity
                        tourImgaeArray.image = tourListDict.images?[i]
                        
                        tourImage = tourImgaeArray
                        tourListInfo.addToTourImagesRelation(tourImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        } else {
            let tourListInfo: NMoQTourListEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQTourListEntityAr", into: managedObjContext) as! NMoQTourListEntityAr
            tourListInfo.title = tourListDict.title
            tourListInfo.dayDescription = tourListDict.dayDescription
            tourListInfo.subtitle = tourListDict.subtitle
            tourListInfo.sortId = Int16(tourListDict.sortId!)!
            tourListInfo.nid = tourListDict.nid
            tourListInfo.eventDate = tourListDict.eventDate
            
            //specialEvent
            tourListInfo.dateString = tourListDict.date
            tourListInfo.descriptioForModerator = tourListDict.descriptioForModerator
            tourListInfo.mobileLatitude = tourListDict.mobileLatitude
            tourListInfo.moderatorName = tourListDict.moderatorName
            tourListInfo.longitude = tourListDict.longitude
            tourListInfo.contactEmail = tourListDict.contactEmail
            tourListInfo.contactPhone = tourListDict.contactPhone
            tourListInfo.isTourGuide = isTourGuide
            if(tourListDict.images != nil){
                if((tourListDict.images?.count)! > 0) {
                    for i in 0 ... (tourListDict.images?.count)!-1 {
                        var tourImage: NMoqTourImagesEntityAr!
                        let tourImgaeArray: NMoqTourImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoqTourImagesEntityAr", into: managedObjContext) as! NMoqTourImagesEntityAr
                        tourImgaeArray.image = tourListDict.images?[i]
                        
                        tourImage = tourImgaeArray
                        tourListInfo.addToTourImagesRelationAr(tourImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
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
    func fetchTourInfoFromCoredata(isTourGuide:Bool) {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
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
                        let imagesInfoArray = (tourListDict.tourImagesRelation?.allObjects) as! [NMoqTourImagesEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].image!)
                            }
                        }
                        self.nmoqTourList.insert(NMoQTour(title: tourListArray[i].title, dayDescription: tourListArray[i].dayDescription, images: imagesArray, subtitle: tourListArray[i].subtitle, sortId: String(tourListArray[i].sortId), nid: tourListArray[i].nid, eventDate: tourListArray[i].eventDate, date: tourListArray[i].dateString, descriptioForModerator: tourListArray[i].descriptioForModerator, mobileLatitude: tourListArray[i].mobileLatitude, moderatorName: tourListArray[i].moderatorName, longitude: tourListArray[i].longitude, contactEmail: tourListArray[i].contactEmail, contactPhone: tourListArray[i].contactPhone), at: i)
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
            } else {
                var tourListArray = [NMoQTourListEntityAr]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQTourListEntityAr")
                fetchRequest.predicate = NSPredicate.init(format: "isTourGuide == \(isTourGuide)")
                tourListArray = (try managedContext.fetch(fetchRequest) as? [NMoQTourListEntityAr])!
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
                        let imagesInfoArray = (tourListDict.tourImagesRelationAr?.allObjects) as! [NMoqTourImagesEntityAr]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].image!)
                            }
                        }
                        self.nmoqTourList.insert(NMoQTour(title: tourListArray[i].title, dayDescription: tourListArray[i].dayDescription, images: imagesArray, subtitle: tourListArray[i].subtitle, sortId: String(tourListArray[i].sortId), nid: tourListArray[i].nid, eventDate: tourListArray[i].eventDate, date: tourListArray[i].dateString, descriptioForModerator: tourListArray[i].descriptioForModerator, mobileLatitude: tourListArray[i].mobileLatitude, moderatorName: tourListArray[i].moderatorName, longitude: tourListArray[i].longitude, contactEmail: tourListArray[i].contactEmail, contactPhone: tourListArray[i].contactPhone), at: i)
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
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //Activities API
    func getNMoQSpecialEventList() {
        _ = Alamofire.request(QatarMuseumRouter.GetNMoQSpecialEventList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<NMoQActivitiesListData>) -> Void in
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
                    self.saveOrUpdateActivityListCoredata(nmoqActivityList: data.nmoqActivitiesList)
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
    func saveOrUpdateActivityListCoredata(nmoqActivityList:[NMoQActivitiesList]?) {
        if ((nmoqActivityList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.activityListCoreDataInBackgroundThread(nmoqActivityList: nmoqActivityList, managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.activityListCoreDataInBackgroundThread(nmoqActivityList: nmoqActivityList, managedContext : managedContext)
                }
            }
        }
    }
    
    func activityListCoreDataInBackgroundThread(nmoqActivityList:[NMoQActivitiesList]?,managedContext: NSManagedObjectContext) {
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "NMoQActivitiesEntity", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQActivitiesEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqActivityList?.count)!-1 {
                    let nmoqActivityListDict = nmoqActivityList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQActivitiesEntity", idKey: "nid", idValue: nmoqActivityListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let activityListdbDict = fetchResult[0] as! NMoQActivitiesEntity
                        activityListdbDict.title = nmoqActivityListDict.title
                        activityListdbDict.dayDescription = nmoqActivityListDict.dayDescription
                        activityListdbDict.subtitle =  nmoqActivityListDict.subtitle
                        activityListdbDict.sortId = nmoqActivityListDict.sortId
                        activityListdbDict.nid =  nmoqActivityListDict.nid
                        activityListdbDict.eventDate = nmoqActivityListDict.eventDate
                        //eventlist
                        activityListdbDict.date = nmoqActivityListDict.date
                        activityListdbDict.descriptioForModerator = nmoqActivityListDict.descriptioForModerator
                        activityListdbDict.mobileLatitude = nmoqActivityListDict.mobileLatitude
                        activityListdbDict.moderatorName = nmoqActivityListDict.moderatorName
                        activityListdbDict.longitude = nmoqActivityListDict.longitude
                        activityListdbDict.contactEmail = nmoqActivityListDict.contactEmail
                        activityListdbDict.contactPhone = nmoqActivityListDict.contactPhone
                        
                        
                        if(nmoqActivityListDict.images != nil){
                            if((nmoqActivityListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqActivityListDict.images?.count)!-1 {
                                    var activityImage: NMoqActivityImgEntity!
                                    let activityImgaeArray: NMoqActivityImgEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoqActivityImgEntity", into: managedContext) as! NMoqActivityImgEntity
                                    activityImgaeArray.images = nmoqActivityListDict.images![i]
                                    
                                    activityImage = activityImgaeArray
                                    activityListdbDict.addToActivityImgRelation(activityImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveActivityListToCoreData(activityListDict: nmoqActivityListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqActivityListNotificationEn), object: self)
            } else {
                for i in 0 ... (nmoqActivityList?.count)!-1 {
                    let activitiesListDict : NMoQActivitiesList?
                    activitiesListDict = nmoqActivityList?[i]
                    self.saveActivityListToCoreData(activityListDict: activitiesListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqActivityListNotificationEn), object: self)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "NMoQActivitiesEntityAr", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQActivitiesEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqActivityList?.count)!-1 {
                    let nmoqActivityListDict = nmoqActivityList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQActivitiesEntityAr", idKey: "nid", idValue: nmoqActivityListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let activityListdbDict = fetchResult[0] as! NMoQActivitiesEntityAr
                        activityListdbDict.title = nmoqActivityListDict.title
                        activityListdbDict.dayDescription = nmoqActivityListDict.dayDescription
                        activityListdbDict.subtitle =  nmoqActivityListDict.subtitle
                        activityListdbDict.sortId = nmoqActivityListDict.sortId
                        activityListdbDict.nid =  nmoqActivityListDict.nid
                        activityListdbDict.eventDate = nmoqActivityListDict.eventDate
                        //eventlist
                        activityListdbDict.date = nmoqActivityListDict.date
                        activityListdbDict.descriptioForModerator = nmoqActivityListDict.descriptioForModerator
                        activityListdbDict.mobileLatitude = nmoqActivityListDict.mobileLatitude
                        activityListdbDict.moderatorName = nmoqActivityListDict.moderatorName
                        activityListdbDict.longitude = nmoqActivityListDict.longitude
                        activityListdbDict.contactEmail = nmoqActivityListDict.contactEmail
                        activityListdbDict.contactPhone = nmoqActivityListDict.contactPhone
                        
                        
                        if(nmoqActivityListDict.images != nil){
                            if((nmoqActivityListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqActivityListDict.images?.count)!-1 {
                                    var activityImage: NMoqActivityImgEntityAr!
                                    let activityImgaeArray: NMoqActivityImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoqActivityImgEntityAr", into: managedContext) as! NMoqActivityImgEntityAr
                                    activityImgaeArray.images = nmoqActivityListDict.images![i]
                                    
                                    activityImage = activityImgaeArray
                                    activityListdbDict.addToActivityImgRelationAr(activityImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveActivityListToCoreData(activityListDict: nmoqActivityListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqActivityListNotificationAr), object: self)
            } else {
                for i in 0 ... (nmoqActivityList?.count)!-1 {
                    let activityListDict : NMoQActivitiesList?
                    activityListDict = nmoqActivityList?[i]
                    self.saveActivityListToCoreData(activityListDict: activityListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqActivityListNotificationAr), object: self)
            }
        }
    }
    func saveActivityListToCoreData(activityListDict: NMoQActivitiesList, managedObjContext: NSManagedObjectContext) {
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let activityListdbDict: NMoQActivitiesEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQActivitiesEntity", into: managedObjContext) as! NMoQActivitiesEntity
            activityListdbDict.title = activityListDict.title
            activityListdbDict.dayDescription = activityListDict.dayDescription
            activityListdbDict.subtitle =  activityListDict.subtitle
            activityListdbDict.sortId = activityListDict.sortId
            activityListdbDict.nid =  activityListDict.nid
            activityListdbDict.eventDate = activityListDict.eventDate
            //eventlist
            activityListdbDict.date = activityListDict.date
            activityListdbDict.descriptioForModerator = activityListDict.descriptioForModerator
            activityListdbDict.mobileLatitude = activityListDict.mobileLatitude
            activityListdbDict.moderatorName = activityListDict.moderatorName
            activityListdbDict.longitude = activityListDict.longitude
            activityListdbDict.contactEmail = activityListDict.contactEmail
            activityListdbDict.contactPhone = activityListDict.contactPhone
            
            
            if(activityListDict.images != nil){
                if((activityListDict.images?.count)! > 0) {
                    for i in 0 ... (activityListDict.images?.count)!-1 {
                        var activityImage: NMoqActivityImgEntity!
                        let activityImgaeArray: NMoqActivityImgEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoqActivityImgEntity", into: managedObjContext) as! NMoqActivityImgEntity
                        activityImgaeArray.images = activityListDict.images![i]
                        
                        activityImage = activityImgaeArray
                        activityListdbDict.addToActivityImgRelation(activityImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        } else {
            let activityListdbDict: NMoQActivitiesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQActivitiesEntityAr", into: managedObjContext) as! NMoQActivitiesEntityAr
            activityListdbDict.title = activityListDict.title
            activityListdbDict.dayDescription = activityListDict.dayDescription
            activityListdbDict.subtitle =  activityListDict.subtitle
            activityListdbDict.sortId = activityListDict.sortId
            activityListdbDict.nid =  activityListDict.nid
            activityListdbDict.eventDate = activityListDict.eventDate
            activityListdbDict.date = activityListDict.date
            activityListdbDict.descriptioForModerator = activityListDict.descriptioForModerator
            activityListdbDict.mobileLatitude = activityListDict.mobileLatitude
            activityListdbDict.moderatorName = activityListDict.moderatorName
            activityListdbDict.longitude = activityListDict.longitude
            activityListdbDict.contactEmail = activityListDict.contactEmail
            activityListdbDict.contactPhone = activityListDict.contactPhone
            
            
            if(activityListDict.images != nil){
                if((activityListDict.images?.count)! > 0) {
                    for i in 0 ... (activityListDict.images?.count)!-1 {
                        var activityImage: NMoqActivityImgEntityAr!
                        let activityImgaeArray: NMoqActivityImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoqActivityImgEntityAr", into: managedObjContext) as! NMoqActivityImgEntityAr
                        activityImgaeArray.images = activityListDict.images![i]
                        
                        activityImage = activityImgaeArray
                        activityListdbDict.addToActivityImgRelationAr(activityImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
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
    func fetchActivityListFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
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
                        let imagesInfoArray = (activityListDict.activityImgRelation?.allObjects) as! [NMoqActivityImgEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.nmoqActivityList.insert(NMoQActivitiesList(title: activityListDict.title, dayDescription: activityListDict.dayDescription, images: imagesArray, subtitle: activityListDict.subtitle, sortId: activityListDict.sortId, nid: activityListDict.nid, eventDate: activityListDict.eventDate, date: activityListDict.date, descriptioForModerator: activityListDict.descriptioForModerator, mobileLatitude: activityListDict.mobileLatitude, moderatorName: activityListDict.moderatorName, longitude: activityListDict.longitude, contactEmail: activityListDict.contactEmail, contactPhone: activityListDict.contactPhone), at: i)
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
            } else {
                var activityListArray = [NMoQActivitiesEntityAr]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQActivitiesEntityAr")
                activityListArray = (try managedContext.fetch(fetchRequest) as? [NMoQActivitiesEntityAr])!
                if (activityListArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNMoQSpecialEventList()
                        }
                    }
                    for i in 0 ... activityListArray.count-1 {
                        let activityListDict = activityListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (activityListDict.activityImgRelationAr!.allObjects) as! [NMoqActivityImgEntityAr]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.nmoqActivityList.insert(NMoQActivitiesList(title: activityListDict.title, dayDescription: activityListDict.dayDescription, images: imagesArray, subtitle: activityListDict.subtitle, sortId: activityListDict.sortId, nid: activityListDict.nid, eventDate: activityListDict.eventDate, date: activityListDict.date, descriptioForModerator: activityListDict.descriptioForModerator, mobileLatitude: activityListDict.mobileLatitude, moderatorName: activityListDict.moderatorName, longitude: activityListDict.longitude, contactEmail: activityListDict.contactEmail, contactPhone: activityListDict.contactPhone), at: i)
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
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: Facilities API
    func getFacilitiesListFromServer()
    {
        _ = Alamofire.request(QatarMuseumRouter.FacilitiesList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<FacilitiesData>) -> Void in
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
                    self.saveOrUpdateFacilitiesListCoredata(facilitiesList: data.facilitiesList)
                }
            case .failure( _):
                if(self.facilitiesList.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: Facilities List Coredata Method
    func saveOrUpdateFacilitiesListCoredata(facilitiesList:[Facilities]?) {
        if ((facilitiesList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.facilitiesListCoreDataInBackgroundThread(facilitiesList: facilitiesList, managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.facilitiesListCoreDataInBackgroundThread(facilitiesList: facilitiesList, managedContext : managedContext)
                }
            }
        }
    }
    func facilitiesListCoreDataInBackgroundThread(facilitiesList:[Facilities]?,managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "FacilitiesEntity", idKey: "nid", idValue: nil, managedContext: managedContext) as! [FacilitiesEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (facilitiesList?.count)!-1 {
                    let facilitiesListDict = facilitiesList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "FacilitiesEntity", idKey: "nid", idValue: facilitiesListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let facilitiesListdbDict = fetchResult[0] as! FacilitiesEntity
                        facilitiesListdbDict.title = facilitiesListDict.title
                        facilitiesListdbDict.sortId = facilitiesListDict.sortId
                        facilitiesListdbDict.nid =  facilitiesListDict.nid
                        
                        if(facilitiesListDict.images != nil){
                            if((facilitiesListDict.images?.count)! > 0) {
                                for i in 0 ... (facilitiesListDict.images?.count)!-1 {
                                    var facilitiesImage: FacilitiesImgEntity!
                                    let facilitiesImgaeArray: FacilitiesImgEntity = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesImgEntity", into: managedContext) as! FacilitiesImgEntity
                                    facilitiesImgaeArray.images = facilitiesListDict.images![i]
                                    
                                    facilitiesImage = facilitiesImgaeArray
                                    facilitiesListdbDict.addToFacilitiesImgRelation(facilitiesImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveFacilitiesListToCoreData(facilitiesListDict: facilitiesListDict, managedObjContext: managedContext)
                    }
                }
            } else {
                for i in 0 ... (facilitiesList?.count)!-1 {
                    let facilitiesListDict : Facilities?
                    facilitiesListDict = facilitiesList?[i]
                    self.saveFacilitiesListToCoreData(facilitiesListDict: facilitiesListDict!, managedObjContext: managedContext)
                }
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "FacilitiesEntityAr", idKey: "nid", idValue: nil, managedContext: managedContext) as! [FacilitiesEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (facilitiesList?.count)!-1 {
                    let facilitiesListDict = facilitiesList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "FacilitiesEntityAr", idKey: "nid", idValue: facilitiesListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let facilitiesListdbDict = fetchResult[0] as! FacilitiesEntityAr
                        facilitiesListdbDict.title = facilitiesListDict.title
                        facilitiesListdbDict.sortId = facilitiesListDict.sortId
                        facilitiesListdbDict.nid =  facilitiesListDict.nid
                        
                        if(facilitiesListDict.images != nil){
                            if((facilitiesListDict.images?.count)! > 0) {
                                for i in 0 ... (facilitiesListDict.images?.count)!-1 {
                                    var facilitiesImage: FacilitiesImgEntityAr!
                                    let facilitiesImgaeArray: FacilitiesImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesImgEntityAr", into: managedContext) as! FacilitiesImgEntityAr
                                    facilitiesImgaeArray.images = facilitiesListDict.images?[i]
                                    
                                    facilitiesImage = facilitiesImgaeArray
                                    facilitiesListdbDict.addToFacilitiesImgRelationAr(facilitiesImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveFacilitiesListToCoreData(facilitiesListDict: facilitiesListDict, managedObjContext: managedContext)
                    }
                }
            } else {
                for i in 0 ... (facilitiesList?.count)!-1 {
                    let facilitiesListDict : Facilities?
                    facilitiesListDict = facilitiesList![i]
                    self.saveFacilitiesListToCoreData(facilitiesListDict: facilitiesListDict!, managedObjContext: managedContext)
                }
            }
        }
    }
    func saveFacilitiesListToCoreData(facilitiesListDict: Facilities, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let facilitiesListInfo: FacilitiesEntity = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesEntity", into: managedObjContext) as! FacilitiesEntity
            facilitiesListInfo.title = facilitiesListDict.title
            facilitiesListInfo.sortId = facilitiesListDict.sortId
            facilitiesListInfo.nid = facilitiesListDict.nid
            
            if(facilitiesListDict.images != nil){
                if((facilitiesListDict.images?.count)! > 0) {
                    for i in 0 ... (facilitiesListDict.images?.count)!-1 {
                        var facilitiesImage: FacilitiesImgEntity!
                        let facilitiesImgaeArray: FacilitiesImgEntity = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesImgEntity", into: managedObjContext) as! FacilitiesImgEntity
                        facilitiesImgaeArray.images = facilitiesListDict.images![i]
                        
                        facilitiesImage = facilitiesImgaeArray
                        facilitiesListInfo.addToFacilitiesImgRelation(facilitiesImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        } else {
            let facilitiesListInfo: FacilitiesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesEntityAr", into: managedObjContext) as! FacilitiesEntityAr
            facilitiesListInfo.title = facilitiesListDict.title
            facilitiesListInfo.sortId = facilitiesListDict.sortId
            facilitiesListInfo.nid =  facilitiesListDict.nid
            
            if(facilitiesListDict.images != nil){
                if((facilitiesListDict.images?.count)! > 0) {
                    for i in 0 ... (facilitiesListDict.images?.count)!-1 {
                        var facilitiesImage: FacilitiesImgEntityAr!
                        let facilitiesImgaeArray: FacilitiesImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesImgEntityAr", into: managedObjContext) as! FacilitiesImgEntityAr
                        facilitiesImgaeArray.images = facilitiesListDict.images?[i]
                        
                        facilitiesImage = facilitiesImgaeArray
                        facilitiesListInfo.addToFacilitiesImgRelationAr(facilitiesImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
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
    func fetchFacilitiesListFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
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
                        let imagesInfoArray = (facilitiesListDict.facilitiesImgRelation?.allObjects) as! [FacilitiesImgEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
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
            } else {
                var facilitiesListArray = [FacilitiesEntityAr]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "FacilitiesEntityAr")
                //fetchRequest.predicate = NSPredicate.init(format: "isTourGuide == \(isTourGuide)")
                facilitiesListArray = (try managedContext.fetch(fetchRequest) as? [FacilitiesEntityAr])!
                if (facilitiesListArray.count > 0) {
                    if (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getFacilitiesListFromServer()
                        }
                    }
                    for i in 0 ... facilitiesListArray.count-1 {
                        let facilitiesListDict = facilitiesListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (facilitiesListDict.facilitiesImgRelationAr?.allObjects) as! [FacilitiesImgEntityAr]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
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
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
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
        _ = Alamofire.request(QatarMuseumRouter.GetNMoQTravelList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<HomeBannerList>) -> Void in
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
                    self.saveOrUpdateTravelListCoredata(travelList: data.homeBannerList)
                }
            case .failure(let error):
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
    func saveOrUpdateTravelListCoredata(travelList:[HomeBanner]?) {
        if ((travelList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.travelListCoreDataInBackgroundThread(travelList: travelList, managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.travelListCoreDataInBackgroundThread(travelList: travelList, managedContext : managedContext)
                }
            }
        }
    }
    
    func travelListCoreDataInBackgroundThread(travelList:[HomeBanner]?,managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "NMoQTravelListEntity", idKey: "fullContentID", idValue: nil, managedContext: managedContext) as! [NMoQTravelListEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (travelList?.count)!-1 {
                    let travelListDict = travelList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQTravelListEntity", idKey: "fullContentID", idValue: travelListDict.fullContentID, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let travelListdbDict = fetchResult[0] as! NMoQTravelListEntity
                        travelListdbDict.title = travelListDict.title
                        travelListdbDict.fullContentID = travelListDict.fullContentID
                        travelListdbDict.bannerTitle =  travelListDict.bannerTitle
                        travelListdbDict.bannerLink = travelListDict.bannerLink
                        travelListdbDict.introductionText =  travelListDict.introductionText
                        travelListdbDict.email = travelListDict.email
                        
                        travelListdbDict.contactNumber = travelListDict.contactNumber
                        travelListdbDict.promotionalCode =  travelListDict.promotionalCode
                        travelListdbDict.claimOffer = travelListDict.claimOffer
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveTrevelListToCoreData(travelListDict: travelListDict, managedObjContext: managedContext)
                    }
                }
            } else {
                for i in 0 ... (travelList?.count)!-1 {
                    let travelListDict : HomeBanner?
                    travelListDict = travelList?[i]
                    self.saveTrevelListToCoreData(travelListDict: travelListDict!, managedObjContext: managedContext)
                }
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "NMoQTravelListEntityAr", idKey: "fullContentID", idValue: nil, managedContext: managedContext) as! [NMoQTravelListEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (travelList?.count)!-1 {
                    let travelListDict = travelList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQTravelListEntityAr", idKey: "fullContentID", idValue: travelListDict.fullContentID, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let travelListdbDict = fetchResult[0] as! NMoQTravelListEntityAr
                        travelListdbDict.title = travelListDict.title
                        travelListdbDict.fullContentID = travelListDict.fullContentID
                        travelListdbDict.bannerTitle =  travelListDict.bannerTitle
                        travelListdbDict.bannerLink = travelListDict.bannerLink
                        travelListdbDict.introductionText =  travelListDict.introductionText
                        travelListdbDict.email = travelListDict.email
                        
                        travelListdbDict.contactNumber = travelListDict.contactNumber
                        travelListdbDict.promotionalCode =  travelListDict.promotionalCode
                        travelListdbDict.claimOffer = travelListDict.claimOffer
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveTrevelListToCoreData(travelListDict: travelListDict, managedObjContext: managedContext)
                    }
                }
            } else {
                for i in 0 ... (travelList?.count)!-1 {
                    let travelListDict : HomeBanner?
                    travelListDict = travelList?[i]
                    self.saveTrevelListToCoreData(travelListDict: travelListDict!, managedObjContext: managedContext)
                }
            }
        }
    }
    func saveTrevelListToCoreData(travelListDict: HomeBanner, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let travelListdbDict: NMoQTravelListEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQTravelListEntity", into: managedObjContext) as! NMoQTravelListEntity
            travelListdbDict.title = travelListDict.title
            travelListdbDict.fullContentID = travelListDict.fullContentID
            travelListdbDict.bannerTitle =  travelListDict.bannerTitle
            travelListdbDict.bannerLink = travelListDict.bannerLink
            travelListdbDict.introductionText =  travelListDict.introductionText
            travelListdbDict.email = travelListDict.email
            travelListdbDict.contactNumber = travelListDict.contactNumber
            travelListdbDict.promotionalCode =  travelListDict.promotionalCode
            travelListdbDict.claimOffer = travelListDict.claimOffer
        } else {
            let travelListdbDict: NMoQTravelListEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQTravelListEntityAr", into: managedObjContext) as! NMoQTravelListEntityAr
            travelListdbDict.title = travelListDict.title
            travelListdbDict.fullContentID = travelListDict.fullContentID
            travelListdbDict.bannerTitle =  travelListDict.bannerTitle
            travelListdbDict.bannerLink = travelListDict.bannerLink
            travelListdbDict.introductionText =  travelListDict.introductionText
            travelListdbDict.email = travelListDict.email
            travelListdbDict.contactNumber = travelListDict.contactNumber
            travelListdbDict.promotionalCode =  travelListDict.promotionalCode
            travelListdbDict.claimOffer = travelListDict.claimOffer
        }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchTravelInfoFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
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
                        self.travelList.insert(HomeBanner(title: travelListArray[i].title, fullContentID: travelListArray[i].fullContentID, bannerTitle: travelListArray[i].bannerTitle, bannerLink: travelListArray[i].bannerLink, image: nil, introductionText: travelListArray[i].introductionText, email: travelListArray[i].email, contactNumber: travelListArray[i].contactNumber, promotionalCode: travelListArray[i].promotionalCode, claimOffer: travelListArray[i].claimOffer), at: i)
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
            } else {
                var travelListArray = [NMoQTravelListEntityAr]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQTravelListEntityAr")
                travelListArray = (try managedContext.fetch(fetchRequest) as? [NMoQTravelListEntityAr])!
                if (travelListArray.count > 0) {
                    if (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getTravelList()
                        }
                    }

                    for i in 0 ... travelListArray.count-1 {
                        self.travelList.insert(HomeBanner(title: travelListArray[i].title, fullContentID: travelListArray[i].fullContentID, bannerTitle: travelListArray[i].bannerTitle, bannerLink: travelListArray[i].bannerLink, image: nil, introductionText: travelListArray[i].introductionText, email: travelListArray[i].email, contactNumber: travelListArray[i].contactNumber, promotionalCode: travelListArray[i].promotionalCode, claimOffer: travelListArray[i].claimOffer), at: i)
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
    }
    @objc func receiveNmoqTravelListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (travelList.count == 0)) {
            self.fetchTravelInfoFromCoredata()
        }
    }
    @objc func receiveFacilitiesListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (facilitiesList.count == 0)) {
            self.fetchFacilitiesListFromCoredata()
        }
    }
    @objc func receiveFacilitiesListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (facilitiesList.count == 0)) {
            self.fetchFacilitiesListFromCoredata()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func receiveActivityListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (nmoqActivityList.count == 0)){
            self.fetchActivityListFromCoredata()
        }
    }
    @objc func receiveActivityListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (nmoqActivityList.count == 0)){
            self.fetchActivityListFromCoredata()
        }
    }
    
}

