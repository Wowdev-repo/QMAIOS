//
//  MiaTourGuideViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 17/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import UIKit

class MiaTourGuideViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,HeaderViewProtocol,comingSoonPopUpProtocol,UICollectionViewDelegateFlowLayout,MiaTourProtocol,LoadingViewProtocol {
    @IBOutlet weak var miaTourCollectionView: UICollectionView!
    @IBOutlet weak var topbarView: CommonHeaderView!
    
    @IBOutlet weak var loadingView: LoadingView!
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
 
    let networkReachability = NetworkReachabilityManager()
    var museumId :String = "63"
    var miaTourDataFullArray: [TourGuide] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        registerNib()
    }

    func setUpUI() {
        loadingView.isHidden = false
        loadingView.loadingViewDelegate = self
        loadingView.showLoading()
        NotificationCenter.default.addObserver(self, selector: #selector(MiaTourGuideViewController.receiveMiaTourNotification(notification:)), name: NSNotification.Name(miaTourNotification), object: nil)
        if  (networkReachability?.isReachable)! {
            DispatchQueue.global(qos: .background).async {
                self.getTourGuideDataFromServer()
            }
        }
        DispatchQueue.main.async {
        self.fetchTourGuideListFromCoredata()
        }
        topbarView.headerViewDelegate = self
        topbarView.headerTitle.isHidden = true
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            topbarView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            topbarView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func registerNib() {
        let nib = UINib(nibName: "HomeCollectionCell", bundle: nil)
        miaTourCollectionView?.register(nib, forCellWithReuseIdentifier: "homeCellId")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return miaTourDataFullArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        loadingView.stopLoading()
        loadingView.isHidden = true
        let cell : HomeCollectionViewCell = miaTourCollectionView.dequeueReusableCell(withReuseIdentifier: "homeCellId", for: indexPath) as! HomeCollectionViewCell
        cell.setScienceTourGuideCellData(homeCellData: miaTourDataFullArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loadMiaTourDetail(currentRow: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightValue = UIScreen.main.bounds.height/100
        return CGSize(width: miaTourCollectionView.frame.width, height: heightValue*27)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let miaTourHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "miaTourHeader", for: indexPath) as! MiaCollectionReusableView
        if (miaTourDataFullArray.count > 0) {
            miaTourHeaderView.setHeader()
        }
        miaTourHeaderView.miaTourDelegate = self
        return miaTourHeaderView
    }

    func loadMiaTourDetail(currentRow: Int?) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        
        let miaView =  self.storyboard?.instantiateViewController(withIdentifier: "miaDetailId") as! MiaTourDetailViewController
        if (miaTourDataFullArray != nil) {
            miaView.tourGuideDetail = miaTourDataFullArray[currentRow!]
        }
        self.present(miaView, animated: false, completion: nil)
    }
    func loadComingSoonPopup() {
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadTourGuidePopup()
        self.view.addSubview(popupView)
        
    }
    //MARK: Poup Delegate
    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
    }
    //MARK: Header delegate
    func headerCloseButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK: Mia Tour Guide Delegate
    func exploreButtonTapAction(miaHeader: MiaCollectionReusableView) {
        let floorMapView =  self.storyboard?.instantiateViewController(withIdentifier: "floorMapId") as! FloorMapViewController
        floorMapView.fromTourString = fromTour.exploreTour
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(floorMapView, animated: false, completion: nil)
        
    }
    //MARK: WebServiceCall
    func getTourGuideDataFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.MuseumTourGuide(LocalizationLanguage.currentAppleLanguage(),["museum_id": museumId])).responseObject { (response: DataResponse<TourGuides>) -> Void in
            switch response.result {
            case .success(let data):
                self.saveOrUpdateTourGuideCoredata(miaTourDataFullArray: data.tourGuide)
            case .failure(let error):
                print("error")
            }
        }
    }
   
    //MARK: Coredata Method
    func saveOrUpdateTourGuideCoredata(miaTourDataFullArray:[TourGuide]?) {
        if ((miaTourDataFullArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext, miaTourDataFullArray: miaTourDataFullArray)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext, miaTourDataFullArray: miaTourDataFullArray)
                }
            }
        }
    }
    
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext,miaTourDataFullArray:[TourGuide]?) {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let fetchData = checkAddedToCoredata(entityName: "TourGuideEntity", idKey: "museumsEntity", idValue: museumId, managedContext: managedContext) as! [TourGuideEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (miaTourDataFullArray?.count)!-1 {
                    let tourGuideListDict = miaTourDataFullArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "TourGuideEntity", idKey: "nid", idValue: miaTourDataFullArray![i].nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let tourguidedbDict = fetchResult[0] as! TourGuideEntity
                        tourguidedbDict.title = tourGuideListDict.title
                        tourguidedbDict.tourGuideDescription = tourGuideListDict.tourGuideDescription
                        tourguidedbDict.museumsEntity =  tourGuideListDict.museumsEntity
                        tourguidedbDict.nid =  tourGuideListDict.nid
                        
                        if(tourGuideListDict.multimediaFile != nil) {
                            if((tourGuideListDict.multimediaFile?.count)! > 0) {
                                for i in 0 ... (tourGuideListDict.multimediaFile?.count)!-1 {
                                    var multimediaEntity: TourGuideMultimediaEntity!
                                    let multimediaArray: TourGuideMultimediaEntity = NSEntityDescription.insertNewObject(forEntityName: "TourGuideMultimediaEntity", into: managedContext) as! TourGuideMultimediaEntity
                                    multimediaArray.multimediaFile = tourGuideListDict.multimediaFile![i]
                                    
                                    multimediaEntity = multimediaArray
                                    tourguidedbDict.addToTourGuideMultimediaRelation(multimediaEntity)
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
                    }
                    else {
                        //save
                        self.saveToCoreData(tourguideListDict: tourGuideListDict, managedObjContext: managedContext)
                        
                    }
                }
            }
            else {
                for i in 0 ... (miaTourDataFullArray?.count)!-1 {
                    let tourGuideListDict : TourGuide?
                    tourGuideListDict = miaTourDataFullArray?[i]
                    self.saveToCoreData(tourguideListDict: tourGuideListDict!, managedObjContext: managedContext)
                    
                }
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "TourGuideEntityAr", idKey: "museumsEntity", idValue: museumId, managedContext: managedContext) as! [TourGuideEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (miaTourDataFullArray?.count)!-1 {
                    let tourGuideListDict = miaTourDataFullArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "TourGuideEntityAr", idKey: "nid" , idValue: miaTourDataFullArray![i].nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let tourguidedbDict = fetchResult[0] as! TourGuideEntityAr
                        tourguidedbDict.title = tourGuideListDict.title
                        tourguidedbDict.tourGuideDescription = tourGuideListDict.tourGuideDescription
                        tourguidedbDict.museumsEntity =  tourGuideListDict.museumsEntity
                        tourguidedbDict.nid =  tourGuideListDict.nid
                        
                        if(tourGuideListDict.multimediaFile != nil) {
                            if((tourGuideListDict.multimediaFile?.count)! > 0) {
                                for i in 0 ... (tourGuideListDict.multimediaFile?.count)!-1 {
                                    var multimediaEntity: TourGuideMultimediaEntityAr!
                                    let multimediaArray: TourGuideMultimediaEntityAr = NSEntityDescription.insertNewObject(forEntityName: "TourGuideMultimediaEntityAr", into: managedContext) as! TourGuideMultimediaEntityAr
                                    multimediaArray.multimediaFile = tourGuideListDict.multimediaFile![i]
                                    
                                    multimediaEntity = multimediaArray
                                    tourguidedbDict.addToTourGuideMultimediaRelation(multimediaEntity)
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
                    }
                    else {
                        //save
                        self.saveToCoreData(tourguideListDict: tourGuideListDict, managedObjContext: managedContext)
                        
                    }
                }
            }
            else {
                for i in 0 ... (miaTourDataFullArray?.count)!-1 {
                    let tourGuideListDict : TourGuide?
                    tourGuideListDict = miaTourDataFullArray?[i]
                    self.saveToCoreData(tourguideListDict: tourGuideListDict!, managedObjContext: managedContext)
                    
                }
            }
        }
    }
    
    func saveToCoreData(tourguideListDict: TourGuide, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let tourGuideInfo: TourGuideEntity = NSEntityDescription.insertNewObject(forEntityName: "TourGuideEntity", into: managedObjContext) as! TourGuideEntity
            tourGuideInfo.title = tourguideListDict.title
            tourGuideInfo.tourGuideDescription = tourguideListDict.tourGuideDescription
            tourGuideInfo.museumsEntity = tourguideListDict.museumsEntity
            tourGuideInfo.nid = tourguideListDict.nid
            
            if(tourguideListDict.multimediaFile != nil) {
                if((tourguideListDict.multimediaFile?.count)! > 0) {
                    for i in 0 ... (tourguideListDict.multimediaFile?.count)!-1 {
                        var multimediaEntity: TourGuideMultimediaEntity!
                        let multimediaArray: TourGuideMultimediaEntity = NSEntityDescription.insertNewObject(forEntityName: "TourGuideMultimediaEntity", into: managedObjContext) as! TourGuideMultimediaEntity
                        multimediaArray.multimediaFile = tourguideListDict.multimediaFile![i]
                        
                        multimediaEntity = multimediaArray
                        tourGuideInfo.addToTourGuideMultimediaRelation(multimediaEntity)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                    }
                }
            }
        }
        else {
            let tourGuideInfo: TourGuideEntityAr = NSEntityDescription.insertNewObject(forEntityName: "TourGuideEntityAr", into: managedObjContext) as! TourGuideEntityAr
            tourGuideInfo.title = tourguideListDict.title
            tourGuideInfo.tourGuideDescription = tourguideListDict.tourGuideDescription
            tourGuideInfo.museumsEntity = tourguideListDict.museumsEntity
            tourGuideInfo.nid = tourguideListDict.nid
            if(tourguideListDict.multimediaFile != nil) {
                if((tourguideListDict.multimediaFile?.count)! > 0) {
                    for i in 0 ... (tourguideListDict.multimediaFile?.count)!-1 {
                        var multimediaEntity: TourGuideMultimediaEntityAr!
                        let multimediaArray: TourGuideMultimediaEntityAr = NSEntityDescription.insertNewObject(forEntityName: "TourGuideMultimediaEntityAr", into: managedObjContext) as! TourGuideMultimediaEntityAr
                        multimediaArray.multimediaFile = tourguideListDict.multimediaFile![i]
                        
                        multimediaEntity = multimediaArray
                        tourGuideInfo.addToTourGuideMultimediaRelation(multimediaEntity)
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
    
    func fetchTourGuideListFromCoredata() {

        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                var tourGuideArray = [TourGuideEntity]()
                tourGuideArray = checkAddedToCoredata(entityName: "TourGuideEntity", idKey: "museumsEntity", idValue: museumId, managedContext: managedContext) as! [TourGuideEntity]
                
                if (tourGuideArray.count > 0) {
                    for i in 0 ... tourGuideArray.count-1 {
                        
                        var multimediaArray : [String] = []
                        let tourguideInfo = tourGuideArray[i]
                        let tourGuideInfoArray = (tourguideInfo.tourGuideMultimediaRelation?.allObjects) as! [TourGuideMultimediaEntity]
                        if(tourGuideInfoArray.count > 0) {
                            for i in 0 ... tourGuideInfoArray.count-1 {
                                multimediaArray.append(tourGuideInfoArray[i].multimediaFile!)
                            }
                        }
                        
                        self.miaTourDataFullArray.insert(TourGuide(title: tourGuideArray[i].title, tourGuideDescription: tourGuideArray[i].tourGuideDescription, multimediaFile: multimediaArray, museumsEntity: tourGuideArray[i].museumsEntity, nid: tourGuideArray[i].nid), at: i)
                    }
                    DispatchQueue.main.async {
                        self.miaTourCollectionView.reloadData()
                    }
                    if(miaTourDataFullArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
            else {
                var tourGuideArray = [TourGuideEntityAr]()
                tourGuideArray = checkAddedToCoredata(entityName: "TourGuideEntityAr", idKey: "museumsEntity", idValue: museumId, managedContext: managedContext) as! [TourGuideEntityAr]
                if (tourGuideArray.count > 0) {
                    for i in 0 ... tourGuideArray.count-1 {
                        var multimediaArray : [String] = []
                        let tourguideInfo = tourGuideArray[i]
                        let tourGuideInfoArray = (tourguideInfo.tourGuideMultimediaRelation?.allObjects) as! [TourGuideMultimediaEntityAr]
                        if(tourGuideInfoArray.count > 0) {
                            for i in 0 ... tourGuideInfoArray.count-1 {
                                multimediaArray.append(tourGuideInfoArray[i].multimediaFile!)
                            }
                        }
                        self.miaTourDataFullArray.insert(TourGuide(title: tourGuideArray[i].title, tourGuideDescription: tourGuideArray[i].tourGuideDescription, multimediaFile: multimediaArray, museumsEntity: tourGuideArray[i].museumsEntity, nid: tourGuideArray[i].nid), at: i)
                        
                        
                    }
                    if(miaTourDataFullArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    miaTourCollectionView.reloadData()
                }
                else{
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
    
    func checkAddedToCoredata(entityName: String?, idKey:String?, idValue: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults : [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
        if (idValue != nil) {
            fetchRequest.predicate = NSPredicate(format: "\(idKey!) == %@", idValue!)
        }
        fetchResults = try! managedContext.fetch(fetchRequest)
        return fetchResults
    }
    
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            self.getTourGuideDataFromServer()
        }
    }
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    @objc func receiveMiaTourNotification(notification: NSNotification) {
        let data = notification.userInfo as? [String:String]
        if (data?.count)!>0 {
            if(museumId == data!["id"]) {
                    self.fetchTourGuideListFromCoredata()
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
