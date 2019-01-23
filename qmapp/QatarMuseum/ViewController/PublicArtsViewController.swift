//
//  PublicArtsViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 22/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Firebase

import UIKit

class PublicArtsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HeaderViewProtocol,comingSoonPopUpProtocol,LoadingViewProtocol {
    @IBOutlet weak var pulicArtsHeader: CommonHeaderView!
    @IBOutlet weak var publicArtsCollectionView: UICollectionView!
    @IBOutlet weak var loadingView: LoadingView!
    
    var publicArtsListImageArray = NSArray()
    var popUpView : ComingSoonPopUp = ComingSoonPopUp()
    var publicArtsListArray: [PublicArtsList]! = []
    let networkReachability = NetworkReachabilityManager()
    var fromSideMenu : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPublicArtsUi()
        registerNib()
        if  (networkReachability?.isReachable)! {
            DispatchQueue.global(qos: .background).async {
                self.getPublicArtsListDataFromServer()
            }
        }
        self.fetchPublicArtsListFromCoredata()
        NotificationCenter.default.addObserver(self, selector: #selector(PublicArtsViewController.receivePublicArtsListNotificationEn(notification:)), name: NSNotification.Name(publicArtsListNotificationEn), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PublicArtsViewController.receivePublicArtsListNotificationAr(notification:)), name: NSNotification.Name(publicArtsListNotificationAr), object: nil)
        recordScreenView()
    }

    func setupPublicArtsUi() {
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        pulicArtsHeader.headerViewDelegate = self
        pulicArtsHeader.headerTitle.text = NSLocalizedString("PUBLIC_ARTS_TITLE", comment: "PUBLIC_ARTS_TITLE Label in the PublicArts page")
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            pulicArtsHeader.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            pulicArtsHeader.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }

    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func registerNib() {
        let nib = UINib(nibName: "HeritageCell", bundle: nil)
        publicArtsCollectionView?.register(nib, forCellWithReuseIdentifier: "heritageCellId")
    }
    
    //MARK: collectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return publicArtsListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let publicArtsCell : HeritageCollectionCell = publicArtsCollectionView.dequeueReusableCell(withReuseIdentifier: "heritageCellId", for: indexPath) as! HeritageCollectionCell
        
        publicArtsCell.setPublicArtsListCellValues(publicArtsList: publicArtsListArray[indexPath.row])
        loadingView.stopLoading()
        loadingView.isHidden = true
        return publicArtsCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightValue = UIScreen.main.bounds.height/100
        return CGSize(width: publicArtsCollectionView.frame.width, height: heightValue*27)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        loadPublicArtsDetail(idValue: publicArtsListArray[indexPath.row].id!)
        
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
    func loadPublicArtsDetail(idValue: String) {
        let publicDtlView = self.storyboard?.instantiateViewController(withIdentifier: "heritageDetailViewId") as! HeritageDetailViewController
        publicDtlView.pageNameString = PageName.publicArtsDetail
        publicDtlView.publicArtsDetailId = idValue
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(publicDtlView, animated: false, completion: nil)
        
        
    }
    //MARK: Header delegate
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
    func getPublicArtsListDataFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.PublicArtsList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<PublicArtsLists>) -> Void in
            switch response.result {
            case .success(let data):
               // self.publicArtsListArray = data.publicArtsList
                self.saveOrUpdatePublicArtsCoredata(publicArtsListArray: data.publicArtsList, lang: LocalizationLanguage.currentAppleLanguage())
//                self.publicArtsCollectionView.reloadData()
//                self.loadingView.stopLoading()
//                self.loadingView.isHidden = true
//                if (self.publicArtsListArray.count == 0) {
//                    self.loadingView.stopLoading()
//                    self.loadingView.noDataView.isHidden = false
//                    self.loadingView.isHidden = false
//                    self.loadingView.showNoDataView()
//                }
            case .failure(let error):
//                var errorMessage: String
//                errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
//                                                                comment: "Setting the content of the alert"))
//                self.loadingView.stopLoading()
//                self.loadingView.noDataView.isHidden = false
//                self.loadingView.isHidden = false
//                self.loadingView.showNoDataView()
//                self.loadingView.noDataLabel.text = errorMessage
                print("error")
            }
        }
    }
    
    //MARK: Coredata Method
    func saveOrUpdatePublicArtsCoredata(publicArtsListArray:[PublicArtsList]?,lang: String?) {
        if ((publicArtsListArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.publicArtsCoreDataInBackgroundThread(managedContext: managedContext, publicArtsListArray: publicArtsListArray, lang: lang)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.publicArtsCoreDataInBackgroundThread(managedContext : managedContext, publicArtsListArray: publicArtsListArray, lang: lang)
                }
            }
        }
    }
    
    func publicArtsCoreDataInBackgroundThread(managedContext: NSManagedObjectContext,publicArtsListArray:[PublicArtsList]?,lang: String?) {
        if (lang == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "PublicArtsEntity", idKey: "id", idValue: nil, managedContext: managedContext) as! [PublicArtsEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (publicArtsListArray?.count)!-1 {
                    let publicArtsListDict = publicArtsListArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "PublicArtsEntity", idKey: "id", idValue: publicArtsListArray![i].id, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let publicArtsdbDict = fetchResult[0] as! PublicArtsEntity
                        
                        publicArtsdbDict.name = publicArtsListDict.name
                        publicArtsdbDict.image = publicArtsListDict.image
                        publicArtsdbDict.latitude =  publicArtsListDict.latitude
                        publicArtsdbDict.longitude = publicArtsListDict.longitude
                        publicArtsdbDict.sortcoefficient = publicArtsListDict.sortcoefficient
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    }
                    else {
                        //save
                        self.saveToPublicArtsCoreData(publicArtsListDict: publicArtsListDict, managedObjContext: managedContext, lang: lang)
                        
                    }
                }
            }
            else {
                for i in 0 ... (publicArtsListArray?.count)!-1 {
                    let publicArtsListDict : PublicArtsList?
                    publicArtsListDict = publicArtsListArray?[i]
                    self.saveToPublicArtsCoreData(publicArtsListDict: publicArtsListDict!, managedObjContext: managedContext, lang: lang)
                    
                }
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "PublicArtsEntityArabic", idKey: "id", idValue: nil, managedContext: managedContext) as! [PublicArtsEntityArabic]
            if (fetchData.count > 0) {
                for i in 0 ... (publicArtsListArray?.count)!-1 {
                    let publicArtsListDict = publicArtsListArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "PublicArtsEntityArabic", idKey: "id", idValue: publicArtsListArray![i].id, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let publicArtsdbDict = fetchResult[0] as! PublicArtsEntityArabic
                        publicArtsdbDict.namearabic = publicArtsListDict.name
                        publicArtsdbDict.imagearabic = publicArtsListDict.image
                        publicArtsdbDict.latitudearabic =  publicArtsListDict.latitude
                        publicArtsdbDict.longitudearabic = publicArtsListDict.longitude
                        publicArtsdbDict.sortcoefficientarabic = publicArtsListDict.sortcoefficient
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    }
                    else {
                        //save
                        self.saveToPublicArtsCoreData(publicArtsListDict: publicArtsListDict, managedObjContext: managedContext, lang: lang)
                        
                    }
                }
            }
            else {
                for i in 0 ... (publicArtsListArray?.count)!-1 {
                    let publicArtsListDict : PublicArtsList?
                    publicArtsListDict = publicArtsListArray?[i]
                    self.saveToPublicArtsCoreData(publicArtsListDict: publicArtsListDict!, managedObjContext: managedContext, lang: lang)
                    
                }
            }
        }
    }
    
    func saveToPublicArtsCoreData(publicArtsListDict: PublicArtsList, managedObjContext: NSManagedObjectContext,lang: String?) {
        if (lang == ENG_LANGUAGE) {
            let publicArtsInfo: PublicArtsEntity = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsEntity", into: managedObjContext) as! PublicArtsEntity
            publicArtsInfo.id = publicArtsListDict.id
            publicArtsInfo.name = publicArtsListDict.name
            publicArtsInfo.image = publicArtsListDict.image
            publicArtsInfo.latitude = publicArtsListDict.name
            publicArtsInfo.longitude = publicArtsListDict.image
            publicArtsInfo.sortcoefficient = publicArtsListDict.sortcoefficient
            
        }
        else {
            let publicArtsInfo: PublicArtsEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsEntityArabic", into: managedObjContext) as! PublicArtsEntityArabic
            publicArtsInfo.id = publicArtsListDict.id
            publicArtsInfo.namearabic = publicArtsListDict.name
            publicArtsInfo.imagearabic = publicArtsListDict.image
            publicArtsInfo.latitudearabic = publicArtsListDict.name
            publicArtsInfo.longitudearabic = publicArtsListDict.image
            publicArtsInfo.sortcoefficientarabic = publicArtsListDict.sortcoefficient
        }
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchPublicArtsListFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var publicArtsArray = [PublicArtsEntity]()
                let publicArtsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "PublicArtsEntity")
                publicArtsArray = (try managedContext.fetch(publicArtsFetchRequest) as? [PublicArtsEntity])!
                if (publicArtsArray.count > 0) {
                    for i in 0 ... publicArtsArray.count-1 {
                        
                        self.publicArtsListArray.insert(PublicArtsList(id: publicArtsArray[i].id, name: publicArtsArray[i].name, latitude: publicArtsArray[i].latitude, longitude: publicArtsArray[i].longitude, image: publicArtsArray[i].image, sortcoefficient: publicArtsArray[i].sortcoefficient), at: i)
                        
                    }
                    if(publicArtsListArray.count == 0){
                        self.showNoNetwork()
                    }
                    publicArtsCollectionView.reloadData()
                }
                else{
                    self.showNoNetwork()
                }
            }
            else {
                var publicArtsArray = [PublicArtsEntityArabic]()
                let publicArtsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "PublicArtsEntityArabic")
                publicArtsArray = (try managedContext.fetch(publicArtsFetchRequest) as? [PublicArtsEntityArabic])!
                if (publicArtsArray.count > 0) {
                    for i in 0 ... publicArtsArray.count-1 {
                        
                         self.publicArtsListArray.insert(PublicArtsList(id: publicArtsArray[i].id, name: publicArtsArray[i].namearabic, latitude: publicArtsArray[i].latitudearabic, longitude: publicArtsArray[i].longitudearabic, image: publicArtsArray[i].imagearabic, sortcoefficient: publicArtsArray[i].sortcoefficientarabic), at: i)
                        
                    }
                    if(publicArtsListArray.count == 0){
                        self.showNoNetwork()
                    }
                    publicArtsCollectionView.reloadData()
                }
                else{
                    self.showNoNetwork()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
//    func checkAddedToCoredata(entityName: String?, publicArtsId: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
//        var fetchResults : [NSManagedObject] = []
//        let publicArtsFetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
//        if (publicArtsId != nil) {
//            publicArtsFetchRequest.predicate = NSPredicate.init(format: "id == \(publicArtsId!)")
//        }
//        fetchResults = try! managedContext.fetch(publicArtsFetchRequest)
//        return fetchResults
//    }
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
            self.getPublicArtsListDataFromServer()
        }
    }
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
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

}
