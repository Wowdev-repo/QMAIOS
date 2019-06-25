//
//  ParksViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 22/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import Firebase
import UIKit
import CocoaLumberjack

enum ParkPageName {
    case SideMenuPark
    case NMoQPark
}
class ParksViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,comingSoonPopUpProtocol,LoadingViewProtocol {
    
    
    
    @IBOutlet weak var parksTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    let imageView = UIImageView()
    let closeButton = UIButton()
    var blurView = UIVisualEffectView()
    var parksListArray: [ParksList]! = []
    let networkReachability = NetworkReachabilityManager()
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var parkPageNameString : ParkPageName? = ParkPageName.SideMenuPark
    var parkDetailId: String? = nil
    var nmoqParkDetailArray: [NMoQParkDetail]! = []
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        setupUIContents()
        
        registerCell()
        self.recordScreenView()
    }
    func setupUIContents() {
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(ParksViewController.receiveParksNotificationEn(notification:)), name: NSNotification.Name(parksNotificationEn), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ParksViewController.receiveParksNotificationAr(notification:)), name: NSNotification.Name(parksNotificationAr), object: nil)
        if (parkPageNameString == ParkPageName.SideMenuPark) {
            self.fetchParksFromCoredata()
//            if  (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getParksDataFromServer()
//                }
//            }
        } else {
            if  (networkReachability?.isReachable)! {
                getNMoQParkDetailFromServer()
            } else {
                //self.fetchNMoQParkDetailFromCoredata()
                self.showNoNetwork()
                if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                    closeButton.frame = CGRect(x: 10, y: 30, width: 40, height: 40)
                }
                else {
                    closeButton.frame = CGRect(x: self.view.frame.width-50, y: 30, width: 40, height: 40)
                }
                closeButton.setImage(UIImage(named: "closeX1"), for: .normal)
                closeButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom:12, right: 12)
                
                closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                closeButton.addTarget(self, action: #selector(closeTouchDownAction), for: .touchDown)
                view.addSubview(closeButton)
            }
        }
    }
    
    func setTopbarImage(imageUrl:String?) {
        parksTableView.estimatedRowHeight = 50
        parksTableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0)
        
        imageView.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 300)
        imageView.image = UIImage(named: "default_imageX2")
            if ((imageUrl != nil) && (imageUrl != "")){
                imageView.kf.setImage(with: URL(string: imageUrl!))
            }
            else {
                imageView.image = UIImage(named: "default_imageX2")
            }
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = imageView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        imageView.addSubview(blurView)
        loadCloseButton()
    }
    func loadCloseButton() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            closeButton.frame = CGRect(x: 10, y: 30, width: 40, height: 40)
        }
        else {
            closeButton.frame = CGRect(x: self.view.frame.width-50, y: 30, width: 40, height: 40)
        }
        closeButton.setImage(UIImage(named: "closeX1"), for: .normal)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom:12, right: 12)
        
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTouchDownAction), for: .touchDown)
        view.addSubview(closeButton)
    }
    func registerCell() {
        self.parksTableView.register(UINib(nibName: "ParkTableCellXib", bundle: nil), forCellReuseIdentifier: "parkCellId")
        self.parksTableView.register(UINib(nibName: "CollectionDetailView", bundle: nil), forCellReuseIdentifier: "collectionCellId")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //MARK: TableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (parkPageNameString == ParkPageName.SideMenuPark) {
            return parksListArray.count
        } else {
            return nmoqParkDetailArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let parkCell = tableView.dequeueReusableCell(withIdentifier: "parkCellId", for: indexPath) as! ParkTableViewCell
        if (parkPageNameString == ParkPageName.SideMenuPark) {
            if (indexPath.row != 0) {
                parkCell.titleLineView.isHidden = true
                parkCell.imageViewHeight.constant = 200
                
            }
            else {
                parkCell.titleLineView.isHidden = false
                parkCell.imageViewHeight.constant = 0
            }
            parkCell.favouriteButtonAction = {
                ()in
                self.setFavouritesAction(cellObj: parkCell)
            }
            parkCell.shareButtonAction = {
                () in
            }
            parkCell.locationButtonTapAction = {
                () in
                self.loadLocationInMap(currentRow: indexPath.row)
            }
            parkCell.setParksCellValues(parksList: parksListArray[indexPath.row], currentRow: indexPath.row)
        } else {
            parkCell.titleLineView.isHidden = false
            parkCell.imageViewHeight.constant = 0
            parkCell.setNmoqParkDetailValues(parkDetails: nmoqParkDetailArray[indexPath.row])
        }
        
        parkCell.favouriteViewHeight.constant = 0
        parkCell.favouriteView.isHidden = true
        parkCell.shareView.isHidden = true
        parkCell.favouriteButton.isHidden = true
        parkCell.shareButton.isHidden = true
            loadingView.stopLoading()
            loadingView.isHidden = true
            return parkCell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func setFavouritesAction(cellObj :ParkTableViewCell) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (cellObj.favouriteButton.tag == 0) {
            cellObj.favouriteButton.tag = 1
            cellObj.favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
            
        }
        else {
            cellObj.favouriteButton.tag = 0
            cellObj.favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y + 300)
        let height = min(max(y, 60), 400)
        imageView.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: height)
        
        
        if (imageView.frame.height >= 300 ){
            blurView.alpha  = 0.0
            
        }
        else if (imageView.frame.height >= 250 ){
            blurView.alpha  = 0.2
            
        }
        else if (imageView.frame.height >= 200 ){
            blurView.alpha  = 0.4
            
        }
        else if (imageView.frame.height >= 150 ){
            blurView.alpha  = 0.6
            
        }
        else if (imageView.frame.height >= 100 ){
            blurView.alpha  = 0.8
            
        }
        else if (imageView.frame.height >= 50 ){
            blurView.alpha  = 0.9
            
        }
        
    }
    func loadLocationInMap(currentRow: Int) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        /*
        var latitudeString :String?
        var longitudeString : String?
        if ((parksListArray[currentRow].latitude != nil) && (parksListArray[currentRow].longitude != nil)) {
            latitudeString = parksListArray[currentRow].latitude
            longitudeString = parksListArray[currentRow].longitude
        }
        if latitudeString != nil && longitudeString != nil {
            let latitude = convertDMSToDDCoordinate(latLongString: latitudeString!)
            let longitude = convertDMSToDDCoordinate(latLongString: longitudeString!)
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string:"comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)")!)
                }
            } else {
                let locationUrl = URL(string: "https://maps.google.com/?q=@\(latitude),\(longitude)")!
                UIApplication.shared.openURL(locationUrl)
            }
        } else {
            showLocationErrorPopup()
        }*/
        showLocationErrorPopup()
    }
    func showLocationErrorPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadLocationErrorPopup()
        self.view.addSubview(popupView)
    }
    @objc func buttonAction(sender: UIButton!) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        sender.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
        
    }
    @objc func closeTouchDownAction(sender: UIButton!) {
        sender.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    //MARK: WebServiceCall
    func getParksDataFromServer()
    {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = Alamofire.request(QatarMuseumRouter.ParksList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<ParksLists>) -> Void in
            switch response.result {
            case .success(let data):
               
                
//                if(retryButtonPressed ?? false) {
//                    self.parksListArray = data.parkList
//
//                    self.parksTableView.reloadData()
//                    self.loadingView.stopLoading()
//                    self.loadingView.isHidden = true
                    if (self.parksListArray.count == 0) {
//                        self.loadingView.stopLoading()
//                        self.loadingView.noDataView.isHidden = false
//                        self.loadingView.isHidden = false
//                        self.loadingView.showNoDataView()
                        self.parksListArray = data.parkList
                        self.parksTableView.reloadData()
                        if(self.parksListArray.count == 0) {
                            self.loadCloseButton()
                            var errorMessage: String
                            errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                            comment: "Setting the content of the alert"))
                            self.loadingView.stopLoading()
                            self.loadingView.noDataView.isHidden = false
                            self.loadingView.isHidden = false
                            self.loadingView.showNoDataView()
                            self.loadingView.noDataLabel.text = errorMessage
                        }
                    }
                    if (self.parksListArray.count > 0)  {
                        self.saveOrUpdateParksCoredata(parksListArray: data.parkList)
                        if let imageUrl = self.parksListArray[0].image{
                            self.setTopbarImage(imageUrl: imageUrl)
                        } else {
                            self.imageView.image = UIImage(named: "default_imageX2")
                        }
                        
                    }
               // }
                
            case .failure( _):
                print("error")
                if(self.parksListArray.count == 0) {
                    self.loadCloseButton()
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                    self.loadingView.noDataLabel.text = errorMessage
                }
                
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateParksCoredata(parksListArray:[ParksList]? ) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (parksListArray!.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext, parksListArray: parksListArray)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext, parksListArray: parksListArray)
                }
            }
        }
    }
    
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext,parksListArray:[ParksList]?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "ParksEntity", idKey: nil, idValue: nil, managedContext: managedContext) as! [ParksEntity]
            if (fetchData.count > 0) {
                let isDeleted = self.deleteExistingEvent(managedContext: managedContext, entityName: "ParksEntity")
                if(isDeleted == true) {
                    for i in 0 ... parksListArray!.count-1 {
                        let parksDict : ParksList?
                        parksDict = parksListArray![i]
                        self.saveToCoreData(parksDict: parksDict!, managedObjContext: managedContext)
                        
                    }
                }
            }
            else {
                for i in 0 ... parksListArray!.count-1 {
                    let parksDict : ParksList?
                    parksDict = parksListArray![i]
                    self.saveToCoreData(parksDict: parksDict!, managedObjContext: managedContext)

                }
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "ParksEntityArabic", idKey: nil, idValue: nil, managedContext: managedContext) as! [ParksEntityArabic]
            if (fetchData.count > 0) {
                let isDeleted = self.deleteExistingEvent(managedContext: managedContext, entityName: "ParksEntityArabic")
                if(isDeleted == true) {
                    for i in 0 ... parksListArray!.count-1 {
                        let parksDict : ParksList?
                        parksDict = parksListArray![i]
                        self.saveToCoreData(parksDict: parksDict!, managedObjContext: managedContext)
                        
                    }
                }
            }
            else {
                for i in 0 ... parksListArray!.count-1 {
                    let parksDict : ParksList?
                    parksDict = parksListArray![i]
                    self.saveToCoreData(parksDict: parksDict!, managedObjContext: managedContext)

                }
            }
        }
    }
    
    func saveToCoreData(parksDict: ParksList, managedObjContext: NSManagedObjectContext) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let parksInfo: ParksEntity = NSEntityDescription.insertNewObject(forEntityName: "ParksEntity", into: managedObjContext) as! ParksEntity
            parksInfo.title = parksDict.title
            parksInfo.parksDescription = parksDict.description
            parksInfo.image = parksDict.image
            if(parksDict.sortId != nil) {
                parksInfo.sortId = parksDict.sortId
            }
        }
        else {
            let parksInfo: ParksEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "ParksEntityArabic", into: managedObjContext) as! ParksEntityArabic
            parksInfo.titleArabic = parksDict.title
            parksInfo.descriptionArabic = parksDict.description
            parksInfo.imageArabic = parksDict.image
            if(parksDict.sortId != nil) {
                parksInfo.sortIdArabic = parksDict.sortId
            }
        }
        do {
            try managedObjContext.save()


        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchParksFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var parksArray = [ParksEntity]()
                let parksFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ParksEntity")
                parksArray = (try managedContext.fetch(parksFetchRequest) as? [ParksEntity])!
                
                if (parksArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getParksDataFromServer()
                        }
                    }
                    for i in 0 ... parksArray.count-1 {
                        self.parksListArray.insert(ParksList(title: parksArray[i].title, description: parksArray[i].parksDescription, sortId: parksArray[i].sortId, image: parksArray[i].image), at: i)

                    }
                    if(parksListArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    if let imageUrl = parksListArray[0].image {
                        self.setTopbarImage(imageUrl: imageUrl)
                    } else {
                        imageView.image = UIImage(named: "default_imageX2")
                    }
                    
                    parksTableView.reloadData()
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                        self.loadCloseButton()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getParksDataFromServer()//coreDataMigratio  solution
                        self.loadCloseButton()
                    }
                }
            }
            else {
                var parksArray = [ParksEntityArabic]()
                let parksFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ParksEntityArabic")
                parksArray = (try managedContext.fetch(parksFetchRequest) as? [ParksEntityArabic])!
                if (parksArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getParksDataFromServer()
                        }
                    }
                    for i in 0 ... parksArray.count-1 {
                        self.parksListArray.insert(ParksList(title: parksArray[i].titleArabic, description: parksArray[i].descriptionArabic, sortId: parksArray[i].sortIdArabic, image: parksArray[i].imageArabic), at: i)
                    }
                    if(parksArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    if let imageUrl = parksListArray[0].image {
                        self.setTopbarImage(imageUrl: imageUrl)
                    }else {
                        imageView.image = UIImage(named: "default_imageX2")
                    }
                    parksTableView.reloadData()
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                        self.loadCloseButton()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getParksDataFromServer()//coreDataMigratio  solution
                        self.loadCloseButton()
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if(self.networkReachability?.isReachable == false) {
                self.showNoNetwork()
                self.loadCloseButton()
            }
        }
    }
    //MARK : NMoQPark
    func getNMoQParkDetailFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (parkDetailId != nil) {
            _ = Alamofire.request(QatarMuseumRouter.GetNMoQPlaygroundDetail(LocalizationLanguage.currentAppleLanguage(), ["nid": parkDetailId!])).responseObject { (response: DataResponse<NMoQParksDetail>) -> Void in
                switch response.result {
                case .success(let data):
                    self.nmoqParkDetailArray = data.nmoqParksDetail
                   // self.saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: data.nmoqParksDetail)
                    self.parksTableView.reloadData()
                    if(self.nmoqParkDetailArray.count > 0) {
                        if ( (self.nmoqParkDetailArray[0].images?.count)! > 0) {
                            if let imageUrl = self.nmoqParkDetailArray[0].images?[0] {
                                self.setTopbarImage(imageUrl: imageUrl)
                            } else {
                                self.imageView.image = UIImage(named: "default_imageX2")
                            }
                            
                        }
                    }
                    
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    if (self.nmoqParkDetailArray.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                    
                case .failure( _):
                    self.loadCloseButton()
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                    self.loadingView.noDataLabel.text = errorMessage
                }
            }
        }
        
    }
    //MARK: NMoq Playground Parks Detail Coredata Method
    func saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: [NMoQParkDetail]?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((nmoqParkList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.nmoqParkDetailCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.nmoqParkDetailCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext : managedContext)
                }
            }
        }
    }
    
    func nmoqParkDetailCoreDataInBackgroundThread(nmoqParkList: [NMoQParkDetail]?, managedContext: NSManagedObjectContext) {
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
            let fetchData = checkAddedToCoredata(entityName: "NMoQParkDetailEntity", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParkDetailEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParkDetailEntity", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParkDetailEntity
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
                        nmoqParkListdbDict.parkDesc =  nmoqParkListDict.parkDesc
                        
                        if(nmoqParkListDict.images != nil){
                            if((nmoqParkListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                                    var parkListImage: NMoQParkDetailImgEntity!
                                    let parkListImageArray: NMoQParkDetailImgEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailImgEntity", into: managedContext) as! NMoQParkDetailImgEntity
                                    parkListImageArray.images = nmoqParkListDict.images![i]
                                    
                                    parkListImage = parkListImageArray
                                    nmoqParkListdbDict.addToParkDetailImgRelation(parkListImage)
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
                        self.saveNMoQParkDetailToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationEn), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQParkDetail?
                    nmoqParkListDict = nmoqParkList?[i]
                    self.saveNMoQParkDetailToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationEn), object: self)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "NMoQParkDetailEntityAr", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParkDetailEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParkDetailEntityAr", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParkDetailEntityAr
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
                        nmoqParkListdbDict.parkDesc =  nmoqParkListDict.parkDesc
                        
                        if(nmoqParkListDict.images != nil){
                            if((nmoqParkListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                                    var parkListImage: NMoQParkDetailImgEntityAr!
                                    let parkListImageArray: NMoQParkDetailImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailImgEntityAr", into: managedContext) as! NMoQParkDetailImgEntityAr
                                    parkListImageArray.images = nmoqParkListDict.images![i]
                                    
                                    parkListImage = parkListImageArray
                                    nmoqParkListdbDict.addToParkDetailImgRelationAr(parkListImage)
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
                        self.saveNMoQParkDetailToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationAr), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQParkDetail?
                    nmoqParkListDict = nmoqParkList![i]
                    self.saveNMoQParkDetailToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationAr), object: self)
            }
        }
    }
    
    func saveNMoQParkDetailToCoreData(nmoqParkListDict: NMoQParkDetail, managedObjContext: NSManagedObjectContext) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let nmoqParkListdbDict: NMoQParkDetailEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailEntity", into: managedObjContext) as! NMoQParkDetailEntity
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
            nmoqParkListdbDict.parkDesc =  nmoqParkListDict.parkDesc
            
            if(nmoqParkListDict.images != nil){
                if((nmoqParkListDict.images?.count)! > 0) {
                    for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                        var parkListImage: NMoQParkDetailImgEntity!
                        let parkListImageArray: NMoQParkDetailImgEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailImgEntity", into: managedObjContext) as! NMoQParkDetailImgEntity
                        parkListImageArray.images = nmoqParkListDict.images![i]
                        
                        parkListImage = parkListImageArray
                        nmoqParkListdbDict.addToParkDetailImgRelation(parkListImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        } else {
            let nmoqParkListdbDict: NMoQParkDetailEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailEntityAr", into: managedObjContext) as! NMoQParkDetailEntityAr
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
            nmoqParkListdbDict.parkDesc =  nmoqParkListDict.parkDesc
            
            if(nmoqParkListDict.images != nil){
                if((nmoqParkListDict.images?.count)! > 0) {
                    for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                        var parkListImage: NMoQParkDetailImgEntityAr!
                        let parkListImageArray: NMoQParkDetailImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailImgEntityAr", into: managedObjContext) as! NMoQParkDetailImgEntityAr
                        parkListImageArray.images = nmoqParkListDict.images![i]
                        
                        parkListImage = parkListImageArray
                        nmoqParkListdbDict.addToParkDetailImgRelationAr(parkListImage)
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
    
    func fetchNMoQParkDetailFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var parkListArray = [NMoQParkDetailEntity]()
                parkListArray = checkAddedToCoredata(entityName: "NMoQParkDetailEntity", idKey: "nid", idValue: parkDetailId, managedContext: managedContext) as! [NMoQParkDetailEntity]
                if (parkListArray.count > 0) {
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (parkListDict.parkDetailImgRelation?.allObjects) as! [NMoQParkDetailImgEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.nmoqParkDetailArray.insert(NMoQParkDetail(title: parkListDict.title, sortId: parkListDict.sortId, nid: parkListDict.nid, images: imagesArray, parkDesc: parkListDict.parkDesc), at: i)
                    }
                    if(nmoqParkDetailArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        if self.nmoqParkDetailArray.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParkDetailArray = self.nmoqParkDetailArray.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                        if ( (self.nmoqParkDetailArray[0].images?.count)! > 0) {
                            if let imageUrl = self.nmoqParkDetailArray[0].images?[0] {
                                self.setTopbarImage(imageUrl: imageUrl)
                            } else {
                                self.imageView.image = UIImage(named: "default_imageX2")
                            }
                            
                        }
                    }
                    parksTableView.reloadData()
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            } else {
                var parkListArray = [NMoQParkDetailEntityAr]()
                parkListArray = checkAddedToCoredata(entityName: "NMoQParkDetailEntityAr", idKey: "nid", idValue: parkDetailId, managedContext: managedContext) as! [NMoQParkDetailEntityAr]
                if (parkListArray.count > 0) {
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (parkListDict.parkDetailImgRelationAr?.allObjects) as! [NMoQParkDetailImgEntityAr]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.nmoqParkDetailArray.insert(NMoQParkDetail(title: parkListDict.title, sortId: parkListDict.sortId, nid: parkListDict.nid, images: imagesArray, parkDesc: parkListDict.parkDesc), at: i)
                    }
                    if(nmoqParkDetailArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        if self.nmoqParkDetailArray.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParkDetailArray = self.nmoqParkDetailArray.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                    }
                    parksTableView.reloadData()
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if(self.networkReachability?.isReachable == false) {
                self.showNoNetwork()
                self.loadCloseButton()
            }
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
    func deleteExistingEvent(managedContext:NSManagedObjectContext,entityName : String?) ->Bool? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName!)
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
            return true
        }catch let error as NSError {
            return false
        }
        
    }
    func showNodata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        var errorMessage: String
        errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                        comment: "Setting the content of the alert"))
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoDataView()
        self.loadingView.noDataLabel.text = errorMessage
    }
     //MARK: Poup Delegate
    func closeButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.popupView.removeFromSuperview()
    }
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if  (networkReachability?.isReachable)! {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            appDelegate?.getParksDataFromServer(lang: LocalizationLanguage.currentAppleLanguage())
        }
    }
    func showNoNetwork() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    func recordScreenView() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(PARKS_VC, screenClass: screenClass)
    }
    @objc func receiveParksNotificationEn(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (parksListArray.count == 0)){
            self.fetchParksFromCoredata()
        } else if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (parksListArray.count == 0)){
            self.fetchParksFromCoredata()
        }
    }
    @objc func receiveParksNotificationAr(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (parksListArray.count == 0)){
            self.fetchParksFromCoredata()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

 

}
