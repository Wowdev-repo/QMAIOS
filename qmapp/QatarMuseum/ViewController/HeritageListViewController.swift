//
//  HeritageListViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 21/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import Firebase
import UIKit
import AVFoundation
import Foundation
class HeritageListViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HeaderViewProtocol,comingSoonPopUpProtocol,LoadingViewProtocol {
    
    @IBOutlet weak var heritageHeader: CommonHeaderView!
    @IBOutlet weak var heritageCollectionView: UICollectionView!
    @IBOutlet weak var loadingView: LoadingView!
    
    var popUpView : ComingSoonPopUp = ComingSoonPopUp()
    var heritageListArray: [Heritage]! = []
    let networkReachability = NetworkReachabilityManager()
    var fromSideMenu : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerNib()
        recordScreenView()
    }
    func setupUI() {
        loadingView.isHidden = false
        loadingView.loadingViewDelegate = self
        loadingView.showLoading()
        
        heritageHeader.headerViewDelegate = self
        heritageHeader.headerTitle.text = NSLocalizedString("HERITAGE_SITES_TITLE", comment: "HERITAGE_SITES_TITLE  in the Heritage page")
        heritageHeader.headerTitle.font = UIFont.headerFont
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            heritageHeader.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            heritageHeader.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
        
        self.fetchHeritageListFromCoredata()
        NotificationCenter.default.addObserver(self, selector: #selector(HeritageListViewController.receiveHeritageListNotificationEn(notification:)), name: NSNotification.Name(heritageListNotificationEn), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeritageListViewController.receiveHeritageListNotificationAr(notification:)), name: NSNotification.Name(heritageListNotificationAr), object: nil)
        if  (networkReachability?.isReachable)! {
            DispatchQueue.global(qos: .background).async {
                self.getHeritageDataFromServer()
            }
        }
    }
    
    func registerNib() {
        let nib = UINib(nibName: "HeritageCell", bundle: nil)
        heritageCollectionView?.register(nib, forCellWithReuseIdentifier: "heritageCellId")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   
    //MARK: collectionview delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heritageListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let heritageCell : HeritageCollectionCell = heritageCollectionView.dequeueReusableCell(withReuseIdentifier: "heritageCellId", for: indexPath) as! HeritageCollectionCell
        heritageCell.setHeritageListCellValues(heritageList: heritageListArray[indexPath.row])
        loadingView.stopLoading()
        loadingView.isHidden = true
        return heritageCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightValue = UIScreen.main.bounds.height/100
        return CGSize(width: heritageCollectionView.frame.width, height: heightValue*27)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let heritageId = heritageListArray[indexPath.row].id
        loadHeritageDetail(heritageListId: heritageId!)
    }
    func loadComingSoonPopup() {
        popUpView  = ComingSoonPopUp(frame: self.view.frame)
        popUpView.comingSoonPopupDelegate = self
        popUpView.loadPopup()
        self.view.addSubview(popUpView)
        
    }
    //MARk: ComingSoonPopUp Delegates
    func closeButtonPressed() {
        self.popUpView.removeFromSuperview()
    }
    func loadHeritageDetail(heritageListId: String) {
        let heritageDtlView = self.storyboard?.instantiateViewController(withIdentifier: "heritageDetailViewId") as! HeritageDetailViewController
        heritageDtlView.pageNameString = PageName.heritageDetail
        heritageDtlView.heritageDetailId = heritageListId
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(heritageDtlView, animated: false, completion: nil)
        
        
    }
    //MARK: Header delegates
    func headerCloseButtonPressed() {
        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController
        let transition = CATransition()
        transition.duration = 0.3
        if (fromSideMenu == true) {
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            dismiss(animated: false, completion: nil)
        } else {
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.add(transition, forKey: kCATransition)
            let appDelegate = UIApplication.shared.delegate
            appDelegate?.window??.rootViewController = homeViewController
        }
    }
    //MARK: WebServiceCall
    func getHeritageDataFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.HeritageList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<Heritages>) -> Void in
                switch response.result {
                case .success(let data):
                    self.saveOrUpdateHeritageCoredata(heritageListArray: data.heritage)
                case .failure(let error):
                    print("error")
                }
            }
    }
    
    //MARK: Coredata Method
    func saveOrUpdateHeritageCoredata(heritageListArray:[Heritage]?) {
        if ((heritageListArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext, heritageListArray: heritageListArray)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext, heritageListArray: heritageListArray)
                }
            }
        }
    }
    
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext,heritageListArray:[Heritage]?) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "HeritageEntity", heritageId: nil, managedContext: managedContext) as! [HeritageEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict = heritageListArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "HeritageEntity", heritageId: heritageListArray![i].id, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let heritagedbDict = fetchResult[0] as! HeritageEntity
                        heritagedbDict.listname = heritageListDict.name
                        heritagedbDict.listimage = heritageListDict.image
                        heritagedbDict.listsortid =  heritageListDict.sortid
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveToCoreData(heritageListDict: heritageListDict, managedObjContext: managedContext)
                        
                    }
                }
            } else {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict : Heritage?
                    heritageListDict = heritageListArray?[i]
                    self.saveToCoreData(heritageListDict: heritageListDict!, managedObjContext: managedContext)
                }
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "HeritageEntityArabic", heritageId: nil, managedContext: managedContext) as! [HeritageEntityArabic]
            if (fetchData.count > 0) {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict = heritageListArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "HeritageEntityArabic", heritageId: heritageListArray![i].id, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let heritagedbDict = fetchResult[0] as! HeritageEntityArabic
                        heritagedbDict.listnamearabic = heritageListDict.name
                        heritagedbDict.listimagearabic = heritageListDict.image
                        heritagedbDict.listsortidarabic =  heritageListDict.sortid
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    }
                    else {
                        //save
                        self.saveToCoreData(heritageListDict: heritageListDict, managedObjContext: managedContext)
                        
                    }
                }
            }
            else {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict : Heritage?
                    heritageListDict = heritageListArray?[i]
                    self.saveToCoreData(heritageListDict: heritageListDict!, managedObjContext: managedContext)
                    
                }
            }
        }
    }
    
    func saveToCoreData(heritageListDict: Heritage, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let heritageInfo: HeritageEntity = NSEntityDescription.insertNewObject(forEntityName: "HeritageEntity", into: managedObjContext) as! HeritageEntity
            heritageInfo.listid = heritageListDict.id
            heritageInfo.listname = heritageListDict.name
            
            heritageInfo.listimage = heritageListDict.image
            if(heritageListDict.sortid != nil) {
                heritageInfo.listsortid = heritageListDict.sortid
            }
        } else {
            let heritageInfo: HeritageEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "HeritageEntityArabic", into: managedObjContext) as! HeritageEntityArabic
            heritageInfo.listid = heritageListDict.id
            heritageInfo.listnamearabic = heritageListDict.name
            
            heritageInfo.listimagearabic = heritageListDict.image
            if(heritageListDict.sortid != nil) {
                heritageInfo.listsortidarabic = heritageListDict.sortid
            }
        }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchHeritageListFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var heritageArray = [HeritageEntity]()
                let homeFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "HeritageEntity")
                heritageArray = (try managedContext.fetch(homeFetchRequest) as? [HeritageEntity])!
                if (heritageArray.count > 0) {
                    for i in 0 ... heritageArray.count-1 {
                        
                        self.heritageListArray.insert(Heritage(id: heritageArray[i].listid, name: heritageArray[i].listname, location: nil, latitude: nil, longitude: nil, image: heritageArray[i].listimage, shortdescription: nil, longdescription: nil,images: nil, sortid: heritageArray[i].listsortid), at: i)
                        
                    }
                    if(heritageListArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    DispatchQueue.main.async{
                        self.heritageCollectionView.reloadData()
                    }
                } else {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            } else {
                var heritageArray = [HeritageEntityArabic]()
                let homeFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "HeritageEntityArabic")
                heritageArray = (try managedContext.fetch(homeFetchRequest) as? [HeritageEntityArabic])!
                if (heritageArray.count > 0) {
                    for i in 0 ... heritageArray.count-1 {
                        self.heritageListArray.insert(Heritage(id: heritageArray[i].listid, name: heritageArray[i].listnamearabic, location: nil, latitude: nil, longitude: nil, image: heritageArray[i].listimagearabic, shortdescription: nil, longdescription: nil,images: nil, sortid: heritageArray[i].listsortidarabic), at: i)
                        
                    }
                    if(heritageListArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    heritageCollectionView.reloadData()
                } else {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func checkAddedToCoredata(entityName: String?, heritageId: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults : [NSManagedObject] = []
        let homeFetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
        if (heritageId != nil) {
            homeFetchRequest.predicate = NSPredicate.init(format: "listid == \(heritageId!)")
        }
        fetchResults = try! managedContext.fetch(homeFetchRequest)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func recordScreenView() {
        title = self.nibName
        guard let screenName = title else {
            return
        }
        let screenClass = classForCoder.description()
        Analytics.setScreenName(screenName, screenClass: screenClass)
    }
    
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            //self.getHeritageDataFromServer()
            //self.fetchHeritageListFromCoredata()
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            appDelegate?.getHeritageDataFromServer(lang: LocalizationLanguage.currentAppleLanguage())
        }
    }
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
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
