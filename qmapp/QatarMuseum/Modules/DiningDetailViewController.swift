//
//  DiningDetailViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 29/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import Firebase
import UIKit
import CocoaLumberjack

class DiningDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, comingSoonPopUpProtocol,LoadingViewProtocol, iCarouselDelegate,iCarouselDataSource {
    @IBOutlet weak var diningTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    
    let imageView = UIImageView()
    let closeButton = UIButton()
    var blurView = UIVisualEffectView()
    var diningDetailtArray: [Dining] = []
    var diningDetailId : String? = nil
    let networkReachability = NetworkReachabilityManager()
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var carousel = iCarousel()
    var transparentView = UIView()

    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()

        setupUIContents()
        if  (networkReachability?.isReachable)! {
            getDiningDetailsFromServer()
        } else {
            self.fetchDiningDetailsFromCoredata()
        }
        setTopBarImage()
        self.recordScreenView()
    }
    
    func setupUIContents() {
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
    }
    
    func setTopBarImage() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        diningTableView.estimatedRowHeight = 50
        diningTableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0)
        
        imageView.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 300)
        imageView.image = UIImage(named: "default_imageX2")
        if diningDetailtArray.count != 0 {
            if let imageUrl = diningDetailtArray[0].image{
                imageView.kf.setImage(with: URL(string: imageUrl))
            }
            else {
                imageView.image = UIImage(named: "default_imageX2")
            }
        }
        else {
            imageView.image = nil
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imgButtonPressed))
        imageView.addGestureRecognizer(tapGesture)
        
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = imageView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        imageView.addSubview(blurView)
        
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            closeButton.frame = CGRect(x: 10, y: 30, width: 40, height: 40)
        } else {
            closeButton.frame = CGRect(x: self.view.frame.width-50, y: 30, width: 40, height: 40)
        }
        closeButton.setImage(UIImage(named: "closeX1"), for: .normal)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom:12, right: 12)
        
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTouchDownAction), for: .touchDown)
        view.addSubview(closeButton)
    }
    
    //MARK: TableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return diningDetailtArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let diningCell = tableView.dequeueReusableCell(withIdentifier: "diningDetailCellId", for: indexPath) as! DiningDetailTableViewCell
        diningCell.titleLineView.isHidden = true
        diningCell.setDiningDetailValues(diningDetail: diningDetailtArray[indexPath.row])
        if (isImgArrayAvailable()) {
            diningCell.pageControl.isHidden = false
        } else {
            diningCell.pageControl.isHidden = true
        }
        diningCell.locationButtonAction = {
            ()in
            self.loadLocationInMap(currentRow: indexPath.row)
        }
        diningCell.favBtnTapAction = {
            () in
            self.setFavouritesAction(cellObj: diningCell)
        }
        diningCell.shareBtnTapAction = {
            () in
            self.setShareAction(cellObj: diningCell)
        }
        loadingView.stopLoading()
        loadingView.isHidden = true
        return diningCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func setFavouritesAction(cellObj :DiningDetailTableViewCell) {
        if (cellObj.favoriteButton.tag == 0) {
            cellObj.favoriteButton.tag = 1
            cellObj.favoriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        } else {
            cellObj.favoriteButton.tag = 0
            cellObj.favoriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
    }
    
    func setShareAction(cellObj :DiningDetailTableViewCell) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 300 - (scrollView.contentOffset.y + 300)
        let height = min(max(y, 60), 400)
        imageView.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: height)
        if (imageView.frame.height >= 300 ){
            blurView.alpha  = 0.0
        } else if (imageView.frame.height >= 250 ){
            blurView.alpha  = 0.2
        } else if (imageView.frame.height >= 200 ){
            blurView.alpha  = 0.4
        } else if (imageView.frame.height >= 150 ){
            blurView.alpha  = 0.6
        } else if (imageView.frame.height >= 100 ){
            blurView.alpha  = 0.8
        } else if (imageView.frame.height >= 50 ){
            blurView.alpha  = 0.9
        }
    }
    
    func loadLocationInMap(currentRow: Int) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        var latitudeString = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        if ((diningDetailtArray[currentRow].latitude != nil) && (diningDetailtArray[currentRow].longitude != nil)) {
            latitudeString = diningDetailtArray[currentRow].latitude!
            longitudeString = diningDetailtArray[currentRow].longitude!
        }
        
        if ((latitudeString != nil) && (longitudeString != nil) && (latitudeString != "") && (longitudeString != "")) {
            //latitude = convertDMSToDDCoordinate(latLongString: latitudeString!)
           // longitude = convertDMSToDDCoordinate(latLongString: longitudeString!)
            if let lat : Double = Double(latitudeString) {
                latitude = lat
            }
            if let long : Double = Double(longitudeString) {
                longitude = long
            }
            
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(latitude!),\(longitude!)&zoom=14&views=traffic&q=\(latitude!),\(longitude!)")!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string:"comgooglemaps://?center=\(latitude!),\(longitude!)&zoom=14&views=traffic&q=\(latitude!),\(longitude!)")!)
                }
            } else {
                let locationUrl = URL(string: "https://maps.google.com/?q=\(latitude!),\(longitude!)")!
                UIApplication.shared.openURL(locationUrl)
            }
        } else {
            showLocationErrorPopup()
        }
    }
    
    func showLocationErrorPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadLocationErrorPopup()
        self.view.addSubview(popupView)
    }
    
    //MARK: Poup Delegate
    func closeButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.popupView.removeFromSuperview()
    }
    
    @objc func buttonAction(sender: UIButton!) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: iCarousel Delegate
    func numberOfItems(in carousel: iCarousel) -> Int {
        if (isImgArrayAvailable()) {
            return (self.diningDetailtArray[0].images?.count)!
        }
        return 0
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIImageView
        itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: carousel.frame.width, height: 300))
        itemView.contentMode = .scaleAspectFit
        let carouselImg = self.diningDetailtArray[0].images
        let imageUrl = carouselImg![index]
        if(imageUrl != nil) {
            itemView.kf.setImage(with: URL(string: imageUrl))
        }
        return itemView
    }

    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.4
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
    }
    
    func setiCarouselView() {
        if (carousel.tag == 0) {
            transparentView.frame = self.view.frame
            transparentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
            transparentView.isUserInteractionEnabled = true
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(closeCarouselView))
            transparentView.addGestureRecognizer(recognizer)
            self.view.addSubview(transparentView)
            
            carousel = iCarousel(frame: CGRect(x: (self.view.frame.width - 320)/2, y: 200, width: 350, height: 300))
            carousel.delegate = self
            carousel.dataSource = self
            carousel.type = .rotary
            carousel.tag = 1
            view.addSubview(carousel)
        }
    }
    
    @objc func closeCarouselView() {
        transparentView.removeFromSuperview()
        carousel.tag = 0
        carousel.removeFromSuperview()
    }
    
    @objc func imgButtonPressed() {
        if((imageView.image != nil) && (imageView.image != UIImage(named: "default_imageX2"))) {
            if(isImgArrayAvailable()) {
                setiCarouselView()
            }
        }
    }
    
    func isImgArrayAvailable() -> Bool {
        if(self.diningDetailtArray.count != 0) {
            if(self.diningDetailtArray[0].images != nil) {
                if((self.diningDetailtArray[0].images?.count)! > 0) {
                    return true
                }
            }
        }
        return false
    }
    
    //MARK: WebServiceCall
    func getDiningDetailsFromServer() {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = Alamofire.request(QatarMuseumRouter.GetDiningDetail(["nid": diningDetailId!])).responseObject { (response: DataResponse<Dinings>) -> Void in
            switch response.result {
            case .success(let data):
                self.diningDetailtArray = data.dinings!
                self.setTopBarImage()
                self.saveOrUpdateDiningDetailCoredata()
                self.diningTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.diningDetailtArray.count == 0) {
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
    
    //MARK: Coredata Method
    func saveOrUpdateDiningDetailCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (diningDetailtArray.count > 0) {
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let fetchData = checkAddedToCoredata(entityName: "DiningEntity", diningId: diningDetailtArray[0].id, managedContext: managedContext) as! [DiningEntity]
            if (fetchData.count > 0) {
                let diningDetailDict = diningDetailtArray[0]
            
                //update
                let diningdbDict = fetchData[0] as! DiningEntity
                diningdbDict.name = diningDetailDict.name
                diningdbDict.image = diningDetailDict.image
                diningdbDict.diningdescription = diningDetailDict.description
                diningdbDict.closetime = diningDetailDict.closetime
                diningdbDict.openingtime =  diningDetailDict.openingtime
                diningdbDict.sortid =  diningDetailDict.sortid
                diningdbDict.location =  diningDetailDict.location
                if((diningDetailDict.images?.count)! > 0) {
                    for i in 0 ... (diningDetailDict.images?.count)!-1 {
                        var diningImagesEntity: DiningImagesEntity!
                        let diningImage: DiningImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "DiningImagesEntity", into: managedContext) as! DiningImagesEntity
                        diningImage.images = diningDetailDict.images![i]
                        
                        diningImagesEntity = diningImage
                        diningdbDict.addToImagesRelation(diningImagesEntity)
                        do {
                            try managedContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
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
                let diningListDict : Dining?
                diningListDict = diningDetailtArray[0]
                self.saveToCoreData(diningDetailDict: diningListDict!, managedObjContext: managedContext)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "DiningEntityArabic", diningId: diningDetailtArray[0].id, managedContext: managedContext) as! [DiningEntityArabic]
            if (fetchData.count > 0) {
                let diningDetailDict = diningDetailtArray[0]
                
                //update
                let diningdbDict = fetchData[0]
                diningdbDict.namearabic = diningDetailDict.name
                diningdbDict.imagearabic = diningDetailDict.image
                diningdbDict.sortidarabic =  diningDetailDict.sortid
                diningdbDict.descriptionarabic = diningDetailDict.description
                diningdbDict.closetimearabic = diningDetailDict.closetime
                diningdbDict.openingtimearabic =  diningDetailDict.openingtime
                diningdbDict.locationarabic =  diningDetailDict.location
                if((diningDetailDict.images?.count)! > 0) {
                    for i in 0 ... (diningDetailDict.images?.count)!-1 {
                        var diningImagesEntity: DiningImagesEntityAr!
                        let diningImage: DiningImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "DiningImagesEntityAr", into: managedContext) as! DiningImagesEntityAr
                        diningImage.images = diningDetailDict.images![i]
                        
                        diningImagesEntity = diningImage
                        diningdbDict.addToImagesRelation(diningImagesEntity)
                        do {
                            try managedContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
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
                let diningListDict : Dining?
                diningListDict = diningDetailtArray[0]
                self.saveToCoreData(diningDetailDict: diningListDict!, managedObjContext: managedContext)
            }
        }
    }
    
    func saveToCoreData(diningDetailDict: Dining, managedObjContext: NSManagedObjectContext) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let diningInfo: DiningEntity = NSEntityDescription.insertNewObject(forEntityName: "DiningEntity", into: managedObjContext) as! DiningEntity
            diningInfo.id = diningDetailDict.id
            diningInfo.name = diningDetailDict.name
            diningInfo.image = diningDetailDict.image
            diningInfo.diningdescription = diningDetailDict.description
            diningInfo.closetime = diningDetailDict.closetime
            diningInfo.openingtime =  diningDetailDict.openingtime
            diningInfo.location =  diningDetailDict.location
            if((diningDetailDict.images?.count)! > 0) {
                for i in 0 ... (diningDetailDict.images?.count)!-1 {
                    var diningImagesEntity: DiningImagesEntity!
                    let diningImage: DiningImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "DiningImagesEntity", into: managedObjContext) as! DiningImagesEntity
                    diningImage.images = diningDetailDict.images![i]
                    
                    diningImagesEntity = diningImage
                    diningInfo.addToImagesRelation(diningImagesEntity)
                    do {
                        try managedObjContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                }
            }
            if(diningDetailDict.sortid != nil) {
                diningInfo.sortid = diningDetailDict.sortid
            }
        } else {
            let diningInfo: DiningEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "DiningEntityArabic", into: managedObjContext) as! DiningEntityArabic
            diningInfo.locationarabic = diningDetailDict.id
            diningInfo.namearabic = diningDetailDict.name
            
            diningInfo.imagearabic = diningDetailDict.image
            diningInfo.descriptionarabic = diningDetailDict.description
            diningInfo.closetimearabic = diningDetailDict.closetime
            diningInfo.openingtimearabic =  diningDetailDict.openingtime
            diningInfo.locationarabic =  diningDetailDict.location
            if((diningDetailDict.images?.count)! > 0) {
                for i in 0 ... (diningDetailDict.images?.count)!-1 {
                    var diningImagesEntity: DiningImagesEntityAr!
                    let diningImage: DiningImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "DiningImagesEntityAr", into: managedObjContext) as! DiningImagesEntityAr
                    diningImage.images = diningDetailDict.images![i]
                    
                    diningImagesEntity = diningImage
                    diningInfo.addToImagesRelation(diningImagesEntity)
                    do {
                        try managedObjContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
            if(diningDetailDict.sortid != nil) {
                diningInfo.sortidarabic = diningDetailDict.sortid
            }
        }
        do {
            try managedObjContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchDiningDetailsFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                var diningArray = [DiningEntity]()
                let diningFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "DiningEntity")
                if(diningDetailId != nil) {
                    diningFetchRequest.predicate = NSPredicate.init(format: "id == \(diningDetailId!)")
                }
                diningArray = (try managedContext.fetch(diningFetchRequest) as? [DiningEntity])!
                let diningDict = diningArray[0]
                if ((diningArray.count > 0) && (diningDict.diningdescription != nil)) {
                    var imagesArray : [String] = []
                    let diningImagesArray = (diningDict.imagesRelation?.allObjects) as! [DiningImagesEntity]
                    if(diningImagesArray.count > 0) {
                        for i in 0 ... diningImagesArray.count-1 {
                            imagesArray.append(diningImagesArray[i].images!)
                        }
                    }
                    self.diningDetailtArray.insert(Dining(id: diningDict.id, name: diningDict.name, location: diningDict.location, description: diningDict.diningdescription, image: diningDict.image, openingtime: diningDict.openingtime, closetime: diningDict.closetime, sortid: diningDict.sortid, museumId: nil, images: imagesArray), at: 0)
                    if(diningDetailtArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    self.setTopBarImage()
                    diningTableView.reloadData()
                } else {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
            else {
                var diningArray = [DiningEntityArabic]()
                let diningFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "DiningEntityArabic")
                if(diningDetailId != nil) {
                    diningFetchRequest.predicate = NSPredicate.init(format: "id == \(diningDetailId!)")
                }
                diningArray = (try managedContext.fetch(diningFetchRequest) as? [DiningEntityArabic])!
                let diningDict = diningArray[0]
                if ((diningArray.count > 0) && (diningDict.descriptionarabic != nil)) {var imagesArray : [String] = []
                    let diningImagesArray = (diningDict.imagesRelation?.allObjects) as! [DiningImagesEntityAr]
                    if(diningImagesArray.count > 0) {
                        for i in 0 ... diningImagesArray.count-1 {
                            imagesArray.append(diningImagesArray[i].images!)
                        }
                    }
                    self.diningDetailtArray.insert(Dining(id: diningDict.id, name: diningDict.namearabic, location: diningDict.locationarabic, description: diningDict.descriptionarabic, image: diningDict.imagearabic, openingtime: diningDict.openingtimearabic, closetime: diningDict.closetimearabic, sortid: diningDict.sortidarabic, museumId:nil, images: imagesArray), at: 0)
                        
                    if(diningDetailtArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    self.setTopBarImage()
                    diningTableView.reloadData()
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

    func checkAddedToCoredata(entityName: String?, diningId: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults : [NSManagedObject] = []
        let diningFetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
        if (diningId != nil) {
            diningFetchRequest.predicate = NSPredicate.init(format: "id == \(diningId!)")
        }
        fetchResults = try! managedContext.fetch(diningFetchRequest)
        return fetchResults
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
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            self.getDiningDetailsFromServer()
        }
    }
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(DINING_DETAIL, screenClass: screenClass)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
