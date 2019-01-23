//
//  NMoQTourViewController.swift
//  QatarMuseums
//
//  Created by Developer on 30/11/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import UIKit

class NMoQTourViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,HeaderViewProtocol,LoadingViewProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var headerView: CommonHeaderView!
    
    var tourTitle : String! = ""
    let networkReachability = NetworkReachabilityManager()
    var tourDesc: String = ""
    var tourDetailId : String? = nil
    var headerTitle : String? = nil
    var nmoqTourDetail: [NMoQTourDetail]! = []
    var isFromTour: Bool? =  false

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setupUI()
    }
    
    func setupUI() {
        loadingView.isHidden = false
        loadingView.showLoading()
        if (networkReachability?.isReachable)! {
            getNMoQTourDetail()
        } else {
            fetchTourDetailsFromCoredata()
        }
        
        loadingView.loadingViewDelegate = self
        headerView.headerViewDelegate = self
        tourDesc = NSLocalizedString("NMoQ_TOUR_DESC", comment: "NMoQ_TOUR_DESC in the NMoQ Tour page")
        headerView.headerTitle.text = headerTitle?.uppercased()
            if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
            } else {
                headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
            }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func registerCell() {
        self.tableView.register(UINib(nibName: "NMoQListCell", bundle: nil), forCellReuseIdentifier: "nMoQListCellId")
        self.tableView.register(UINib(nibName: "NMoQTourDescriptionCell", bundle: nil), forCellReuseIdentifier: "nMoQTourDescriptionCellId")
        self.tableView.register(UINib(nibName: "PanelDetailView", bundle: nil), forCellReuseIdentifier: "panelCellID")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nmoqTourDetail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadingView.stopLoading()
        loadingView.isHidden = true
        let cell = tableView.dequeueReusableCell(withIdentifier: "nMoQListCellId", for: indexPath) as! NMoQListCell
        cell.setTourMiddleDate(tourList: nmoqTourDetail[indexPath.row])
                return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (isFromTour)! {
            loadTourSecondDetailPage(selectedRow: indexPath.row, fromTour: true)
        } else {
            loadTourSecondDetailPage(selectedRow: indexPath.row, fromTour: false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let heightValue = UIScreen.main.bounds.height/100
            return heightValue*27
    }
    func loadTourSecondDetailPage(selectedRow: Int?,fromTour:Bool?) {
        let panelView =  self.storyboard?.instantiateViewController(withIdentifier: "paneldetailViewId") as! PanelDiscussionDetailViewController
        panelView.nmoqTourDetail = nmoqTourDetail
        panelView.selectedRow = selectedRow
        if (fromTour)! {
            panelView.pageNameString = NMoQPanelPage.TourDetailPage
        } else {
            panelView.pageNameString = NMoQPanelPage.PanelDetailPage
        }
        panelView.panelDetailId = tourDetailId
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(panelView, animated: false, completion: nil)
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
    }
    
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    //MARK: ServiceCall
    func getNMoQTourDetail() {
        if(tourDetailId != nil) {
            _ = Alamofire.request(QatarMuseumRouter.GetNMoQTourDetail(["event_id" : tourDetailId!])).responseObject { (response: DataResponse<NMoQTourDetailList>) -> Void in
                switch response.result {
                case .success(let data):
                    self.nmoqTourDetail = data.nmoqTourDetailList
                    if self.nmoqTourDetail.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                        self.nmoqTourDetail = self.nmoqTourDetail.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                    self.tableView.reloadData()
                    if(self.nmoqTourDetail.count == 0) {
                        let noResultMsg = NSLocalizedString("NO_RESULT_MESSAGE",
                                                            comment: "Setting the content of the alert")
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                        self.loadingView.noDataLabel.text = noResultMsg
                    } else {
                        self.saveOrUpdateTourDetailCoredata()
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
        
    }
    
    //MARK: Coredata Method
    func saveOrUpdateTourDetailCoredata() {
        if (nmoqTourDetail.count > 0) {
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
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let fetchData = checkAddedToCoredata(entityName: "NmoqTourDetailEntity", idKey: "nmoqEvent", idValue: tourDetailId, managedContext: managedContext) as! [NmoqTourDetailEntity]
            if (fetchData.count > 0) {
                for i in 0 ... nmoqTourDetail.count-1 {
                    let tourDetailDict = nmoqTourDetail[i]
                    let fetchResult = checkAddedToCoredata(entityName: "NmoqTourDetailEntity", idKey: "nid", idValue: tourDetailDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let tourDetaildbDict = fetchResult[0] as! NmoqTourDetailEntity
                        tourDetaildbDict.title = tourDetailDict.title
                        tourDetaildbDict.date = tourDetailDict.date
                        tourDetaildbDict.nmoqEvent =  tourDetailDict.nmoqEvent
                        tourDetaildbDict.register =  tourDetailDict.register
                        tourDetaildbDict.contactEmail = tourDetailDict.contactEmail
                        tourDetaildbDict.contactPhone = tourDetailDict.contactPhone
                        tourDetaildbDict.mobileLatitude =  tourDetailDict.mobileLatitude
                        tourDetaildbDict.longitude =  tourDetailDict.longitude
                        tourDetaildbDict.sort_id = tourDetailDict.sortId
                        tourDetaildbDict.body = tourDetailDict.body
                        tourDetaildbDict.registered =  tourDetailDict.registered
                        tourDetaildbDict.nid =  tourDetailDict.nid
                        
                        if(tourDetailDict.imageBanner != nil){
                            if((tourDetailDict.imageBanner?.count)! > 0) {
                                for i in 0 ... (tourDetailDict.imageBanner?.count)!-1 {
                                    var tourImage: NMoqTourDetailImagesEntity
                                    let tourImgaeArray: NMoqTourDetailImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoqTourDetailImagesEntity", into: managedContext) as! NMoqTourDetailImagesEntity
                                    tourImgaeArray.imgBanner = tourDetailDict.imageBanner?[i]
                                    
                                    tourImage = tourImgaeArray
                                    tourDetaildbDict.addToNmoqTourDetailImgBannerRelation(tourImage)
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
                        self.saveTourDetailsToCoreData(tourDetailDict: tourDetailDict, managedObjContext: managedContext)
                        
                    }
                }
            }
            else {
                for i in 0 ... nmoqTourDetail.count-1 {
                    let tourDetailDict : NMoQTourDetail?
                    tourDetailDict = nmoqTourDetail[i]
                    self.saveTourDetailsToCoreData(tourDetailDict: tourDetailDict!, managedObjContext: managedContext)
                    
                }
            }
        }
        
    }
    func saveTourDetailsToCoreData(tourDetailDict: NMoQTourDetail, managedObjContext: NSManagedObjectContext) {
            let tourDetaildbDict: NmoqTourDetailEntity = NSEntityDescription.insertNewObject(forEntityName: "NmoqTourDetailEntity", into: managedObjContext) as! NmoqTourDetailEntity
        tourDetaildbDict.title = tourDetailDict.title
        tourDetaildbDict.date = tourDetailDict.date
        tourDetaildbDict.nmoqEvent =  tourDetailDict.nmoqEvent
        tourDetaildbDict.register =  tourDetailDict.register
        tourDetaildbDict.contactEmail = tourDetailDict.contactEmail
        tourDetaildbDict.contactPhone = tourDetailDict.contactPhone
        tourDetaildbDict.mobileLatitude =  tourDetailDict.mobileLatitude
        tourDetaildbDict.longitude =  tourDetailDict.longitude
        tourDetaildbDict.sort_id = tourDetailDict.sortId
        tourDetaildbDict.body = tourDetailDict.body
        tourDetaildbDict.registered =  tourDetailDict.registered
        tourDetaildbDict.nid =  tourDetailDict.nid
        if(tourDetailDict.imageBanner != nil){
            if((tourDetailDict.imageBanner?.count)! > 0) {
                for i in 0 ... (tourDetailDict.imageBanner?.count)!-1 {
                    var tourImage: NMoqTourDetailImagesEntity
                    let tourImgaeArray: NMoqTourDetailImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoqTourDetailImagesEntity", into: managedObjContext) as! NMoqTourDetailImagesEntity
                    tourImgaeArray.imgBanner = tourDetailDict.imageBanner?[i]
                    
                    tourImage = tourImgaeArray
                    tourDetaildbDict.addToNmoqTourDetailImgBannerRelation(tourImage)
                    do {
                        try managedObjContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
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

    func fetchTourDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                var tourDetailArray = [NmoqTourDetailEntity]()
                tourDetailArray = checkAddedToCoredata(entityName: "NmoqTourDetailEntity", idKey: "nmoqEvent", idValue: tourDetailId, managedContext: managedContext) as! [NmoqTourDetailEntity]
                if (tourDetailArray.count > 0) {
                    for i in 0 ... tourDetailArray.count-1 {
                        var imagesArray : [String] = []
                        let imagesInfoArray = (tourDetailArray[i].nmoqTourDetailImgBannerRelation?.allObjects) as! [NMoqTourDetailImagesEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].imgBanner!)
                            }
                        }
                        self.nmoqTourDetail.insert(NMoQTourDetail(title: tourDetailArray[i].title, imageBanner: imagesArray, date: tourDetailArray[i].date, nmoqEvent: tourDetailArray[i].nmoqEvent, register: tourDetailArray[i].register, contactEmail: tourDetailArray[i].contactEmail, contactPhone: tourDetailArray[i].contactPhone, mobileLatitude: tourDetailArray[i].mobileLatitude, longitude: tourDetailArray[i].longitude, sortId: tourDetailArray[i].sort_id, body: tourDetailArray[i].body, registered: tourDetailArray[i].registered, nid: tourDetailArray[i].nid), at: i)
                        
                    }
                    if(nmoqTourDetail.count == 0){
                        self.showNoNetwork()
                    }
                    tableView.reloadData()
                }
                else{
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
