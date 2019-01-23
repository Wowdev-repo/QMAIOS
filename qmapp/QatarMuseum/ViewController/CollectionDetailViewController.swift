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
import UIKit

class CollectionDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,HeaderViewProtocol,LoadingViewProtocol {
    @IBOutlet weak var collectionTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var headerView: CommonHeaderView!
    
    var collectionDetailArray: [CollectionDetail]! = []
    var collectionName: String? = nil
    let networkReachability = NetworkReachabilityManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setUI()
        
    }
    func setUI() {
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        if  (networkReachability?.isReachable)! {
            getCollectioDetailsFromServer()
        } else {
            self.fetchCollectionDetailsFromCoredata()
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
        return collectionDetailArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let collectionCell = tableView.dequeueReusableCell(withIdentifier: "collectionCellId", for: indexPath) as! CollectionDetailCell
//        if(indexPath.row == collectionListArray.count-1) {
//            collectionCell.favouriteHeight.constant = 130
//            collectionCell.favouriteView.isHidden = false
//            collectionCell.shareView.isHidden = false
//            collectionCell.favouriteButton.isHidden = false
//            collectionCell.shareButton.isHidden = false
//        } else {
            collectionCell.favouriteHeight.constant = 0
            collectionCell.favouriteView.isHidden = true
            collectionCell.shareView.isHidden = true
            collectionCell.favouriteButton.isHidden = true
            collectionCell.shareButton.isHidden = true
//        }
        collectionCell.favouriteButtonAction = {
            () in
            
        }
        collectionCell.shareButtonAction = {
            () in
            
        }
        collectionCell.setCollectionCellValues(collectionValues: collectionDetailArray[indexPath.row], currentRow: indexPath.row)
        loadingView.stopLoading()
        loadingView.isHidden = true
        return collectionCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
            print("Could not save. \(error), \(error.userInfo)")
        }
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
                            self.showNoNetwork()
                        }
                        collectionTableView.reloadData()
                    }
                    else{
                        self.showNoNetwork()
                    }
                

            }
            else {
                var collectionArray = [CollectionDetailsEntityAr]()
                collectionArray = checkAddedToCoredata(entityName: "CollectionDetailsEntityAr", idKey: "categoryCollection", idValue: collectionName, managedContext: managedContext) as! [CollectionDetailsEntityAr]
                if(collectionArray.count > 0) {
                    for i in 0 ... collectionArray.count-1 {
                        let collectionDict = collectionArray[i]
                        if((collectionDict.titleAr == nil) && (collectionDict.bodyAr == nil)) {
                            self.showNoNetwork()
                        } else {
                           self.collectionDetailArray.insert(CollectionDetail(title: collectionDict.titleAr, image: collectionDict.imageAr, body: collectionDict.bodyAr, nid: collectionDict.nid, categoryCollection: collectionDict.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)), at: 0)
                        
                        }
                    }
                    if(collectionDetailArray.count == 0){
                        self.showNoNetwork()
                    }
                    collectionTableView.reloadData()
                }else{
                    self.showNoNetwork()
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
            self.getCollectioDetailsFromServer()
        }
    }
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

   

}
