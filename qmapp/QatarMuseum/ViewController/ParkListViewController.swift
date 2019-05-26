//
//  ParkListViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 19/03/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Alamofire
import CoreData
import MapKit
import UIKit
import CocoaLumberjack

class ParkListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, HeaderViewProtocol,comingSoonPopUpProtocol,LoadingViewProtocol {
    
    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var parkTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var nmoqParkList: [NMoQParksList]! = []
    var nmoqParks: [NMoQPark]! = []
    let networkReachability = NetworkReachabilityManager()
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        registerCell()
        setUI()
    }
    func setUI() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        headerView.headerViewDelegate = self
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
        fetchNmoqParkListFromCoredata()
        fetchNmoqParkFromCoredata()
        NotificationCenter.default.addObserver(self, selector: #selector(ParkListViewController.receiveNmoqParkListNotificationEn(notification:)), name: NSNotification.Name(heritageListNotificationEn), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParkListViewController.receiveNmoqParkListNotificationAr(notification:)), name: NSNotification.Name(heritageListNotificationAr), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParkListViewController.receiveNmoqParkNotificationEn(notification:)), name: NSNotification.Name(nmoqParkNotificationEn), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParkListViewController.receiveNmoqParkNotificationAr(notification:)), name: NSNotification.Name(nmoqParkNotificationAr), object: nil)
//        if  (networkReachability?.isReachable)! {
//            DispatchQueue.global(qos: .background).async {
//                self.getNmoqParkListFromServer()
//                self.getNmoqListOfParksFromServer()
//            }
//        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func registerCell() {
        self.parkTableView.register(UINib(nibName: "ParkListView", bundle: nil), forCellReuseIdentifier: "parkListCellId")
        self.parkTableView.register(UINib(nibName: "NMoQListCell", bundle: nil), forCellReuseIdentifier: "nMoQListCellId")
        self.parkTableView.register(UINib(nibName: "NMoQPArkTopCell", bundle: nil), forCellReuseIdentifier: "parkTopCellId")
        parkTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (nmoqParkList.count > 0) {
            return 2 + nmoqParks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.loadingView.stopLoading()
        self.loadingView.isHidden = true
        if (indexPath.row == 0) {
            let cell = parkTableView.dequeueReusableCell(withIdentifier: "parkTopCellId", for: indexPath) as! NMoQParkTopTableViewCell
            cell.setTopCellDescription(topDescription: nmoqParkList[0].mainDescription)
            return cell
        } else if indexPath.row > nmoqParks.count {
            let parkListSecondCell = parkTableView.dequeueReusableCell(withIdentifier: "parkListCellId", for: indexPath) as! ParkListTableViewCell
            parkListSecondCell.selectionStyle = .none
            parkListSecondCell.setParkListValues(parkListData: nmoqParkList[0])
            parkListSecondCell.loadMapView = {
                () in
                self.loadLocationMap(mobileLatitude: self.nmoqParkList[0].latitude, mobileLongitude: self.nmoqParkList[0].longitude)
            }
            return parkListSecondCell
        } else {
            let parkListCell = tableView.dequeueReusableCell(withIdentifier: "nMoQListCellId", for: indexPath) as! NMoQListCell
            parkListCell.selectionStyle = .none
            if (nmoqParks.count > 0) {
                parkListCell.setParkListData(parkList: nmoqParks[indexPath.row - 1])
            }
            
            return parkListCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath.row != 0) && (indexPath.row <= nmoqParks.count)) {
            let heightValue = UIScreen.main.bounds.height/100
            return heightValue*27
        } else if(indexPath.row == 0) {
            if((nmoqParkList[0].mainDescription == nil) || (nmoqParkList[0].mainDescription?.trimmingCharacters(in: NSCharacterSet.whitespaces) == "")) {
                return 0
            }
        }
            return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (indexPath.row == 1) {
//            loadParkPlayGroundDetail(parkList: nmoqParks[indexPath.row - 1])
//        } else if ((indexPath.row != 0) && (indexPath.row <= nmoqParks.count)) {
//           loadParkHeritageGardenDetail(parkList: nmoqParks[indexPath.row - 1])
//        }
        if ((nmoqParks.count > 0) && (indexPath.row != 0) && (indexPath.row != 3)) {
            if((nmoqParks[indexPath.row - 1].nid == "15616") || (nmoqParks[indexPath.row - 1].nid == "15851")) {
                loadParkPlayGroundDetail(parkList: nmoqParks[indexPath.row - 1])
            } else {
                loadParkHeritageGardenDetail(parkList: nmoqParks[indexPath.row - 1])
            }
        }
    }
    
    func loadParkPlayGroundDetail(parkList: NMoQPark) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let collectionDetailView =  self.storyboard?.instantiateViewController(withIdentifier: "collectionDetailId") as! CollectionDetailViewController
       // collectionDetailView.collectionName = parkList.title?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        collectionDetailView.collectionPageNameString = CollectionPageName.PlayGroundPark
        collectionDetailView.nid = parkList.nid
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(collectionDetailView, animated: false, completion: nil)
    }
    
    func loadParkHeritageGardenDetail(parkList: NMoQPark) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let parksView =  self.storyboard?.instantiateViewController(withIdentifier: "parkViewId") as! ParksViewController
        parksView.parkPageNameString = ParkPageName.NMoQPark
        parksView.parkDetailId = parkList.nid
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(parksView, animated: false, completion: nil)
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
            
            let detailStoryboard: UIStoryboard = UIStoryboard(name: "DetailPageStoryboard", bundle: nil)
            
            let mapDetailView = detailStoryboard.instantiateViewController(withIdentifier: "mapViewId") as! MapViewController
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
    
    func getNmoqParkListFromServer() {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = Alamofire.request(QatarMuseumRouter.GetNmoqParkList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<NmoqParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.nmoqParkList.count == 0) {
                    self.nmoqParkList = data.nmoqParkList
                    if(self.nmoqParkList.count > 0) {
                        self.headerView.headerTitle.text = self.nmoqParkList[0].title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
                    }
                    self.parkTableView.reloadData()
                    if(self.nmoqParkList.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                }
                if(self.nmoqParkList.count > 0) {
                    self.saveOrUpdateNmoqParkListCoredata(nmoqParkList: data.nmoqParkList)
                }
            case .failure( _):
                if(self.nmoqParkList.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            }
        }
    }
    
    func getNmoqListOfParksFromServer() {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = Alamofire.request(QatarMuseumRouter.GetNmoqListParks(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<NMoQParks>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.nmoqParks.count == 0) {
                    self.nmoqParks = data.nmoqParks
                    self.parkTableView.reloadData()
                    if(self.nmoqParks.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                }
                if(self.nmoqParks.count > 0) {
                    self.saveOrUpdateNmoqParksCoredata(nmoqParkList: data.nmoqParks)
                }
                
            case .failure( _):
                if(self.nmoqParks.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            }
        }
    }
    
    //MARK: NMoqPark List Coredata Method
    func saveOrUpdateNmoqParkListCoredata(nmoqParkList:[NMoQParksList]?) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((nmoqParkList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.nmoqParkListCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.nmoqParkListCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext : managedContext)
                }
            }
        }
    }
    func nmoqParkListCoreDataInBackgroundThread(nmoqParkList:[NMoQParksList]?,managedContext: NSManagedObjectContext) {
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "NMoQParkListEntity", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParkListEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParkListEntity", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParkListEntity
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.parkTitle = nmoqParkListDict.parkTitle
                        nmoqParkListdbDict.mainDescription = nmoqParkListDict.mainDescription
                        nmoqParkListdbDict.parkDescription =  nmoqParkListDict.parkDescription
                        nmoqParkListdbDict.hoursTitle = nmoqParkListDict.hoursTitle
                        nmoqParkListdbDict.hoursDesc = nmoqParkListDict.hoursDesc
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.longitude = nmoqParkListDict.longitude
                        nmoqParkListdbDict.latitude = nmoqParkListDict.latitude
                        nmoqParkListdbDict.locationTitle =  nmoqParkListDict.locationTitle
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveNmoqParkListToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationEn), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQParksList?
                    nmoqParkListDict = nmoqParkList?[i]
                    self.saveNmoqParkListToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationEn), object: self)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "NMoQParkListEntityAr", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParkListEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParkListEntityAr", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParkListEntityAr
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.parkTitle = nmoqParkListDict.parkTitle
                        nmoqParkListdbDict.mainDescription = nmoqParkListDict.mainDescription
                        nmoqParkListdbDict.parkDescription =  nmoqParkListDict.parkDescription
                        nmoqParkListdbDict.hoursTitle = nmoqParkListDict.hoursTitle
                        nmoqParkListdbDict.hoursDesc = nmoqParkListDict.hoursDesc
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.longitude = nmoqParkListDict.longitude
                        nmoqParkListdbDict.latitude = nmoqParkListDict.latitude
                        nmoqParkListdbDict.locationTitle =  nmoqParkListDict.locationTitle
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveNmoqParkListToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationAr), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQParksList?
                    nmoqParkListDict = nmoqParkList![i]
                    self.saveNmoqParkListToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationAr), object: self)
            }
        }
    }
    func saveNmoqParkListToCoreData(nmoqParkListDict: NMoQParksList, managedObjContext: NSManagedObjectContext) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let nmoqParkListdbDict: NMoQParkListEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkListEntity", into: managedObjContext) as! NMoQParkListEntity
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.parkTitle = nmoqParkListDict.parkTitle
            nmoqParkListdbDict.mainDescription = nmoqParkListDict.mainDescription
            nmoqParkListdbDict.parkDescription =  nmoqParkListDict.parkDescription
            nmoqParkListdbDict.hoursTitle = nmoqParkListDict.hoursTitle
            nmoqParkListdbDict.hoursDesc = nmoqParkListDict.hoursDesc
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.longitude = nmoqParkListDict.longitude
            nmoqParkListdbDict.latitude = nmoqParkListDict.latitude
            nmoqParkListdbDict.locationTitle =  nmoqParkListDict.locationTitle
            
        } else {
            let nmoqParkListdbDict: NMoQParkListEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkListEntityAr", into: managedObjContext) as! NMoQParkListEntityAr
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.parkTitle = nmoqParkListDict.parkTitle
            nmoqParkListdbDict.mainDescription = nmoqParkListDict.mainDescription
            nmoqParkListdbDict.parkDescription =  nmoqParkListDict.parkDescription
            nmoqParkListdbDict.hoursTitle = nmoqParkListDict.hoursTitle
            nmoqParkListdbDict.hoursDesc = nmoqParkListDict.hoursDesc
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.longitude = nmoqParkListDict.longitude
            nmoqParkListdbDict.latitude = nmoqParkListDict.latitude
            nmoqParkListdbDict.locationTitle =  nmoqParkListDict.locationTitle
        }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: NMoq List of Parks Coredata Method
    func saveOrUpdateNmoqParksCoredata(nmoqParkList:[NMoQPark]?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((nmoqParkList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.nmoqParkCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.nmoqParkCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext : managedContext)
                }
            }
        }
    }
    
    func nmoqParkCoreDataInBackgroundThread(nmoqParkList:[NMoQPark]?,managedContext: NSManagedObjectContext) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "NMoQParksEntity", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParksEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParksEntity", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParksEntity
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId

                        if(nmoqParkListDict.images != nil){
                            if((nmoqParkListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                                    var parkListImage: NMoQParkImgEntity!
                                    let parkListImageArray: NMoQParkImgEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkImgEntity", into: managedContext) as! NMoQParkImgEntity
                                    parkListImageArray.images = nmoqParkListDict.images![i]
                                    
                                    parkListImage = parkListImageArray
                                    nmoqParkListdbDict.addToParkImgRelation(parkListImage)
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
                        self.saveNmoqParkToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationEn), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQPark?
                    nmoqParkListDict = nmoqParkList?[i]
                    self.saveNmoqParkToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationEn), object: self)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "NMoQParksEntityAr", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParksEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParksEntityAr", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParksEntityAr
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
                        if(nmoqParkListDict.images != nil){
                            if((nmoqParkListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                                    var parkListImage: NMoQParkImgEntityAr!
                                    let parkListImageArray: NMoQParkImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkImgEntityAr", into: managedContext) as! NMoQParkImgEntityAr
                                    parkListImageArray.images = nmoqParkListDict.images![i]
                                    
                                    parkListImage = parkListImageArray
                                    nmoqParkListdbDict.addToParkImgRelationAr(parkListImage)
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
                        self.saveNmoqParkToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationAr), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQPark?
                    nmoqParkListDict = nmoqParkList![i]
                    self.saveNmoqParkToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationAr), object: self)
            }
        }
    }
    
    func saveNmoqParkToCoreData(nmoqParkListDict: NMoQPark, managedObjContext: NSManagedObjectContext) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let nmoqParkListdbDict: NMoQParksEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParksEntity", into: managedObjContext) as! NMoQParksEntity
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
            
            if(nmoqParkListDict.images != nil){
                if((nmoqParkListDict.images?.count)! > 0) {
                    for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                        var parkListImage: NMoQParkImgEntity!
                        let parkListImageArray: NMoQParkImgEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkImgEntity", into: managedObjContext) as! NMoQParkImgEntity
                        parkListImageArray.images = nmoqParkListDict.images![i]

                        parkListImage = parkListImageArray
                        nmoqParkListdbDict.addToParkImgRelation(parkListImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        } else {
            let nmoqParkListdbDict: NMoQParksEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParksEntityAr", into: managedObjContext) as! NMoQParksEntityAr
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
            
            if(nmoqParkListDict.images != nil){
                if((nmoqParkListDict.images?.count)! > 0) {
                    for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                        var parkListImage: NMoQParkImgEntityAr!
                        let parkListImageArray: NMoQParkImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkImgEntityAr", into: managedObjContext) as! NMoQParkImgEntityAr
                        parkListImageArray.images = nmoqParkListDict.images![i]
                        
                        parkListImage = parkListImageArray
                        nmoqParkListdbDict.addToParkImgRelationAr(parkListImage)
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
    
    func fetchNmoqParkListFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var parkListArray = [NMoQParkListEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQParkListEntity")
                parkListArray = (try managedContext.fetch(fetchRequest) as? [NMoQParkListEntity])!
                if (parkListArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNmoqParkListFromServer()
                        }
                    }
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        self.nmoqParkList.insert(NMoQParksList(title: parkListDict.title, parkTitle: parkListDict.parkTitle, mainDescription: parkListDict.mainDescription, parkDescription: parkListDict.parkDescription, hoursTitle: parkListDict.hoursTitle, hoursDesc: parkListDict.hoursDesc, nid: parkListDict.nid, longitude: parkListDict.longitude, latitude: parkListDict.latitude, locationTitle: parkListDict.locationTitle), at: i)
                    }
                    if(nmoqParkList.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        self.headerView.headerTitle.text = self.nmoqParkList[0].title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
                    }
                    parkTableView.reloadData()
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getNmoqParkListFromServer()//coreDataMigratio  solution
                    }
                }
            } else {
                var parkListArray = [NMoQParkListEntityAr]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQParkListEntityAr")
                parkListArray = (try managedContext.fetch(fetchRequest) as? [NMoQParkListEntityAr])!
                if (parkListArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNmoqParkListFromServer()
                        }
                    }
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        self.nmoqParkList.insert(NMoQParksList(title: parkListDict.title,parkTitle: parkListDict.parkTitle, mainDescription: parkListDict.mainDescription, parkDescription: parkListDict.parkDescription, hoursTitle: parkListDict.hoursTitle, hoursDesc: parkListDict.hoursDesc, nid: parkListDict.nid, longitude: parkListDict.longitude, latitude: parkListDict.latitude, locationTitle: parkListDict.locationTitle), at: i)
                    }
                    if(nmoqParkList.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        self.headerView.headerTitle.text = self.nmoqParkList[0].title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
                    }
                    parkTableView.reloadData()
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                         self.getNmoqParkListFromServer()//coreDataMigratio  solution
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func fetchNmoqParkFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var parkListArray = [NMoQParksEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQParksEntity")
                parkListArray = (try managedContext.fetch(fetchRequest) as? [NMoQParksEntity])!
                    
                if (parkListArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNmoqListOfParksFromServer()
                        }
                    }
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (parkListDict.parkImgRelation?.allObjects) as! [NMoQParkImgEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.nmoqParks.insert(NMoQPark(title: parkListDict.title, sortId: parkListDict.sortId, nid: parkListDict.nid, images: imagesArray), at: i)
                    }
                    if(nmoqParks.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        if self.nmoqParks.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParks = self.nmoqParks.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                    }
                    DispatchQueue.main.async{
                        self.parkTableView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getNmoqListOfParksFromServer()//coreDataMigratio  solution
                    }
                }
            } else {
                var parkListArray = [NMoQParksEntityAr]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQParksEntityAr")
                parkListArray = (try managedContext.fetch(fetchRequest) as? [NMoQParksEntityAr])!
                if (parkListArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNmoqListOfParksFromServer()
                        }
                    }
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (parkListDict.parkImgRelationAr?.allObjects) as! [NMoQParkImgEntityAr]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.nmoqParks.insert(NMoQPark(title: parkListDict.title, sortId: parkListDict.sortId, nid: parkListDict.nid, images: imagesArray), at: i)
                    }
                    if(nmoqParks.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        if self.nmoqParks.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParks = self.nmoqParks.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                    }
                    DispatchQueue.main.async{
                        self.parkTableView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                       // self.loadingView.showNoDataView()
                        self.getNmoqListOfParksFromServer()//coreDataMigratio  solution
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
    func showNoNetwork() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    func showLocationErrorPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadMapKitLocationErrorPopup()
        self.view.addSubview(popupView)
    }
    func headerCloseButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.dismiss(animated: false, completion: nil)
    }
    func closeButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.popupView.removeFromSuperview()
    }
    func tryAgainButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if  (networkReachability?.isReachable)! {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            appDelegate?.getNmoqParkListFromServer(lang: LocalizationLanguage.currentAppleLanguage())
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
}
