//
//  TravelArrangementsViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 28/11/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import Alamofire
import CoreData
import UIKit

class TravelArrangementsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HeaderViewProtocol {
    
    

    @IBOutlet weak var travelHeaderView: CommonHeaderView!
    @IBOutlet weak var travelCollectionView: UICollectionView!
    @IBOutlet weak var loadingView: LoadingView!
    var travelList: [HomeBanner]! = []
    let networkReachability = NetworkReachabilityManager()
    var bannerId: String? = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
    }
    func setUI() {
        loadingView.isHidden = false
        loadingView.showLoading()
        
         travelHeaderView.headerViewDelegate = self
        
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            travelHeaderView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            travelHeaderView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
            travelHeaderView.headerTitle.text = NSLocalizedString("TRAVEL_ARRANGEMENTS", comment: "TRAVEL_ARRANGEMENTS Label in the Travel page page").uppercased()
        registerNib()
        NotificationCenter.default.addObserver(self, selector: #selector(TravelArrangementsViewController.receiveNmoqTravelListNotification(notification:)), name: NSNotification.Name(nmoqTravelListNotification), object: nil)
        fetchTravelInfoFromCoredata()
        if (networkReachability?.isReachable)! {
            DispatchQueue.global(qos: .background).async {
                self.getTravelList()
            }
        }
    }
    func registerNib() {
            let nib = UINib(nibName: "TravelCell", bundle: nil)
            travelCollectionView?.register(nib, forCellWithReuseIdentifier: "travelCellId")
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return travelList.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        loadingView.stopLoading()
        loadingView.isHidden = true
        let travelCell : TravelCollectionViewCell = travelCollectionView.dequeueReusableCell(withReuseIdentifier: "travelCellId", for: indexPath) as! TravelCollectionViewCell
        travelCell.setTravelListData(travelListData: travelList[indexPath.row])
            return travelCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: travelCollectionView.frame.width, height: self.travelCollectionView.frame.height/2)
        let heightValue = UIScreen.main.bounds.height/100
        return CGSize(width: travelCollectionView.frame.width, height: heightValue*27)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loadDetailPage(selectedIndex: indexPath.row)
    }

    func loadDetailPage(selectedIndex: Int) {
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
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    //MARK: Service Call
    func getTravelList() {
        _ = Alamofire.request(QatarMuseumRouter.GetNMoQTravelList()).responseObject { (response: DataResponse<HomeBannerList>) -> Void in
            switch response.result {
            case .success(let data):
                self.saveOrUpdateTravelListCoredata(travelList: data.homeBannerList)
            case .failure(let error):
                print("error")
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
        }
    }
    func saveTrevelListToCoreData(travelListDict: HomeBanner, managedObjContext: NSManagedObjectContext) {
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
        
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchTravelInfoFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                var travelListArray = [NMoQTravelListEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQTravelListEntity")
                travelListArray = (try managedContext.fetch(fetchRequest) as? [NMoQTravelListEntity])!
                if (travelListArray.count > 0) {
                    for i in 0 ... travelListArray.count-1 {
                        self.travelList.insert(HomeBanner(title: travelListArray[i].title, fullContentID: travelListArray[i].fullContentID, bannerTitle: travelListArray[i].bannerTitle, bannerLink: travelListArray[i].bannerLink, image: nil, introductionText: travelListArray[i].introductionText, email: travelListArray[i].email, contactNumber: travelListArray[i].contactNumber, promotionalCode: travelListArray[i].promotionalCode, claimOffer: travelListArray[i].claimOffer), at: i)
                    }
                    if(travelList.count == 0){
                        self.showNoNetwork()
                    } else {
                        if(bannerId != nil) {
                            if let arrayOffset = self.travelList.index(where: {$0.fullContentID == bannerId}) {
                                self.travelList.remove(at: arrayOffset)
                            }
                        }
                    }
                    travelCollectionView.reloadData()
                } else{
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
            // homeFetchRequest.predicate = NSPredicate.init(format: "id == \(homeId!)")
            fetchRequest.predicate = NSPredicate(format: "\(idKey!) == %@", idValue!)
        }
        fetchResults = try! managedContext.fetch(fetchRequest)
        return fetchResults
    }
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    @objc func receiveNmoqTravelListNotification(notification: NSNotification) {
        if (travelList.count == 0) {
            self.fetchTravelInfoFromCoredata()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

 

}
