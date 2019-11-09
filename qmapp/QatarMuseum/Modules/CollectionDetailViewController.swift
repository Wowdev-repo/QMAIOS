//
//  CollectionDetailViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 31/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import Firebase
import UIKit
import CocoaLumberjack

enum CollectionPageName {
    case PlayGroundPark
    case CollectionDetail
}
class CollectionDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,HeaderViewProtocol,LoadingViewProtocol {
    @IBOutlet weak var collectionTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var headerView: CommonHeaderView!
    
    var collectionDetailArray: [CollectionDetail]! = []
    var nmoqParkDetailArray: [NMoQParkDetail]! = []
    var collectionName: String? = nil
    var nid: String? = nil
    let networkReachability = NetworkReachabilityManager()
    var collectionPageNameString : CollectionPageName? = CollectionPageName.CollectionDetail
    
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        registerCell()
        setUI()
        self.recordScreenView()
        collectionTableView.rowHeight = UITableViewAutomaticDimension
        collectionTableView.estimatedRowHeight = 261
    }
    func setUI() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(CollectionDetailViewController.receiveNmoqParkDetailNotificationEn(notification:)), name: NSNotification.Name(nmoqParkDetailNotificationEn), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CollectionDetailViewController.receiveNmoqParkDetailNotificationAr(notification:)), name: NSNotification.Name(nmoqParkDetailNotificationAr), object: nil)
        if (collectionPageNameString == CollectionPageName.CollectionDetail) {
            if  (networkReachability?.isReachable)! {
                getCollectioDetailsFromServer()
            } else {
                self.fetchCollectionDetailsFromCoredata()
            }
        } else if (collectionPageNameString == CollectionPageName.PlayGroundPark) {
            if  (networkReachability?.isReachable)! {
                getNMoQParkDetailFromServer()
            } else {
               // self.fetchNMoQParkDetailFromCoredata()
                self.showNoNetwork()
            }
        }
        headerView.headerViewDelegate = self
        headerView.headerBackButton.setImage(UIImage(named: "closeX1"), for: .normal)
        headerView.headerBackButton.contentEdgeInsets = UIEdgeInsets(top: 13, left: 18, bottom:13, right: 18)
       
    }
    func registerCell() {
        self.collectionTableView.register(UINib(nibName: "CollectionDetailView", bundle: nil), forCellReuseIdentifier: "collectionCellId")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (collectionPageNameString == CollectionPageName.CollectionDetail) {
            return collectionDetailArray.count
        } else {
            return nmoqParkDetailArray.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let collectionCell = tableView.dequeueReusableCell(withIdentifier: "collectionCellId", for: indexPath) as! CollectionDetailCell
        if (collectionPageNameString == CollectionPageName.CollectionDetail) {
            collectionCell.favouriteHeight.constant = 0
            collectionCell.favouriteView.isHidden = true
            collectionCell.shareView.isHidden = true
            collectionCell.favouriteButton.isHidden = true
            collectionCell.shareButton.isHidden = true
            collectionCell.favouriteButtonAction = {
                () in
                
            }
            collectionCell.shareButtonAction = {
                () in
                
            }
            collectionCell.setCollectionCellValues(collectionValues: collectionDetailArray[indexPath.row], currentRow: indexPath.row)
        } else {
            collectionCell.setParkPlayGroundValues(parkPlaygroundDetails: nmoqParkDetailArray[indexPath.row])
        }

        loadingView.stopLoading()
        loadingView.isHidden = true
        return collectionCell
    }
    func headerCloseButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK: WebServiceCall
    func getCollectioDetailsFromServer() {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = Alamofire.request(QatarMuseumRouter.CollectionDetail(["category": collectionName!])).responseObject { (response: DataResponse<CollectionDetails>) -> Void in
            switch response.result {
            case .success(let data):
                self.collectionDetailArray = data.collectionDetails
                self.saveOrUpdateCollectionDetailCoredata()
                self.collectionTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.collectionDetailArray.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            case .failure(let error):
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
    
    func getNMoQParkDetailFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (nid != nil) {
            _ = Alamofire.request(QatarMuseumRouter.GetNMoQPlaygroundDetail(LocalizationLanguage.currentAppleLanguage(), ["nid": nid!])).responseObject { (response: DataResponse<NMoQParksDetail>) -> Void in
                switch response.result {
                case .success(let data):
                    self.nmoqParkDetailArray = data.nmoqParksDetail
                    if (self.nmoqParkDetailArray.count > 0) {
                        if self.nmoqParkDetailArray.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParkDetailArray = self.nmoqParkDetailArray.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                    }
                    //self.saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: data.nmoqParksDetail)
                    self.collectionTableView.reloadData()
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    if (self.nmoqParkDetailArray.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                    
                case .failure( _):
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
    
    //MARK: CollectionDetail Coredata Method
    func saveOrUpdateCollectionDetailCoredata() {
        if (collectionDetailArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext)
                }
            }
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        }
    }
    
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "CollectionDetailsEntity", idKey: "categoryCollection" , idValue: collectionName, managedContext: managedContext) as! [CollectionDetailsEntity]
            
            if (fetchData.count > 0) {
                for i in 0 ... collectionDetailArray.count-1 {
                    let collectionDetailDict = collectionDetailArray[i]
                    let fetchResult = checkAddedToCoredata(entityName: "CollectionDetailsEntity", idKey: "nid", idValue: collectionDetailArray[i].nid, managedContext: managedContext) as! [CollectionDetailsEntity]
                    
                    if(fetchResult.count != 0) {
                        
                        //update
                        let collectiondbDict = fetchResult[0]
                        collectiondbDict.title = collectionDetailDict.title
                        collectiondbDict.body = collectionDetailDict.body
                        collectiondbDict.categoryCollection =  collectionDetailDict.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                        collectiondbDict.nid = collectionDetailDict.nid
                        collectiondbDict.image = collectionDetailDict.image
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    }else {
                        self.saveToCoreData(collectionDetailDict: collectionDetailDict, managedObjContext: managedContext)
                    }
                }//for
            }//if
            else {
                for i in 0 ... collectionDetailArray.count-1 {
                    let collectionDetailDict : CollectionDetail?
                    collectionDetailDict = collectionDetailArray[i]
                    self.saveToCoreData(collectionDetailDict: collectionDetailDict!, managedObjContext: managedContext)
                }

            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "CollectionDetailsEntityAr", idKey:"categoryCollection" , idValue: collectionName, managedContext: managedContext) as! [CollectionDetailsEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... collectionDetailArray.count-1 {
                    let collectionDetailDict = collectionDetailArray[i]
                    let fetchResult = checkAddedToCoredata(entityName: "CollectionDetailsEntityAr", idKey: "nid", idValue: collectionDetailArray[i].nid, managedContext: managedContext) as! [CollectionDetailsEntityAr]
                    //update
                    if(fetchResult.count != 0) {
                        let collectiondbDict = fetchResult[0]
                        collectiondbDict.titleAr = collectionDetailDict.title
                        collectiondbDict.bodyAr = collectionDetailDict.body
                        collectiondbDict.categoryCollection =  collectionDetailDict.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                        collectiondbDict.imageAr = collectionDetailDict.image
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        self.saveToCoreData(collectionDetailDict: collectionDetailDict, managedObjContext: managedContext)
                    }
                }//for
            } //if
            else {
                for i in 0 ... collectionDetailArray.count-1 {
                    let collectionDetailDict : CollectionDetail?
                    collectionDetailDict = collectionDetailArray[i]
                    self.saveToCoreData(collectionDetailDict: collectionDetailDict!, managedObjContext: managedContext)
                }
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func saveToCoreData(collectionDetailDict: CollectionDetail, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let collectiondbDict: CollectionDetailsEntity = NSEntityDescription.insertNewObject(forEntityName: "CollectionDetailsEntity", into: managedObjContext) as! CollectionDetailsEntity
            collectiondbDict.title = collectionDetailDict.title
            collectiondbDict.body = collectionDetailDict.body
            collectiondbDict.nid = collectionDetailDict.nid
            collectiondbDict.categoryCollection =  collectionDetailDict.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
            collectiondbDict.image = collectionDetailDict.image
        
        }
        else {
            let collectiondbDict: CollectionDetailsEntityAr = NSEntityDescription.insertNewObject(forEntityName: "CollectionDetailsEntityAr", into: managedObjContext) as! CollectionDetailsEntityAr
            collectiondbDict.titleAr = collectionDetailDict.title
            collectiondbDict.bodyAr = collectionDetailDict.body
            collectiondbDict.nid = collectionDetailDict.nid
            collectiondbDict.categoryCollection =  collectionDetailDict.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
            collectiondbDict.imageAr = collectionDetailDict.image
        }
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            DDLogError("Could not save. \(error), \(error.userInfo)")
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func fetchCollectionDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var collectionArray = [CollectionDetailsEntity]()
                collectionArray = checkAddedToCoredata(entityName: "CollectionDetailsEntity", idKey: "categoryCollection", idValue: collectionName, managedContext: managedContext) as! [CollectionDetailsEntity]
                    if (collectionArray.count > 0) {
                        for i in 0 ... collectionArray.count-1 {
                            let collectionDict = collectionArray[i]
                            if((collectionDict.title == nil) && (collectionDict.body == nil)) {
                                self.showNodata()
                                
                            } else {
                                self.collectionDetailArray.insert(CollectionDetail(title: collectionDict.title, image: collectionDict.image, body: collectionDict.body, nid: collectionDict.nid, categoryCollection: collectionDict.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)), at: 0)
                                }
                           
                        }
                        if(collectionDetailArray.count == 0){
                            if(self.networkReachability?.isReachable == false) {
                                self.showNoNetwork()
                            } else {
                                self.loadingView.showNoDataView()
                            }
                        }
                        collectionTableView.reloadData()
                    } else{
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
            } else {
                var collectionArray = [CollectionDetailsEntityAr]()
                collectionArray = checkAddedToCoredata(entityName: "CollectionDetailsEntityAr", idKey: "categoryCollection", idValue: collectionName, managedContext: managedContext) as! [CollectionDetailsEntityAr]
                if(collectionArray.count > 0) {
                    for i in 0 ... collectionArray.count-1 {
                        let collectionDict = collectionArray[i]
                        if((collectionDict.titleAr == nil) && (collectionDict.bodyAr == nil)) {
                            if(self.networkReachability?.isReachable == false) {
                                self.showNoNetwork()
                            } else {
                                self.loadingView.showNoDataView()
                            }
                        } else {
                           self.collectionDetailArray.insert(CollectionDetail(title: collectionDict.titleAr, image: collectionDict.imageAr, body: collectionDict.bodyAr, nid: collectionDict.nid, categoryCollection: collectionDict.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)), at: 0)
                        
                        }
                    }
                    if(collectionDetailArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    collectionTableView.reloadData()
                } else {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
        } catch let error as NSError {
            DDLogError("Could not fetch. \(error), \(error.userInfo)")
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    //MARK: NMoq Playground Parks Detail Coredata Method
    func saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: [NMoQParkDetail]?) {
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
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func nmoqParkDetailCoreDataInBackgroundThread(nmoqParkList: [NMoQParkDetail]?, managedContext: NSManagedObjectContext) {
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
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
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func saveNMoQParkDetailToCoreData(nmoqParkListDict: NMoQParkDetail, managedObjContext: NSManagedObjectContext) {
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
            DDLogError("Could not save. \(error), \(error.userInfo)")
        }
        
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func fetchNMoQParkDetailFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var parkListArray = [NMoQParkDetailEntity]()
                parkListArray = checkAddedToCoredata(entityName: "NMoQParkDetailEntity", idKey: "nid", idValue: nid, managedContext: managedContext) as! [NMoQParkDetailEntity]
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
                    }
                    DispatchQueue.main.async{
                        self.collectionTableView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            } else {
                var parkListArray = [NMoQParkDetailEntityAr]()
                parkListArray = checkAddedToCoredata(entityName: "NMoQParkDetailEntityAr", idKey: "nid", idValue: nid, managedContext: managedContext) as! [NMoQParkDetailEntityAr]
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
                    DispatchQueue.main.async{
                        self.collectionTableView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
        } catch let error as NSError {
            DDLogError("Could not fetch. \(error), \(error.userInfo)")
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if  (networkReachability?.isReachable)! {
            self.getCollectioDetailsFromServer()
        }
    }
    func showNoNetwork() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(COLLECTION_DETAIL, screenClass: screenClass)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func receiveNmoqParkDetailNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (nmoqParkDetailArray.count == 0)){
            self.fetchNMoQParkDetailFromCoredata()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @objc func receiveNmoqParkDetailNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (nmoqParkDetailArray.count == 0)){
            self.fetchNMoQParkDetailFromCoredata()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }

}
