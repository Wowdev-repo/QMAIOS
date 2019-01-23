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
import UIKit

class ParksViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,comingSoonPopUpProtocol,LoadingViewProtocol {
    
    
    
    @IBOutlet weak var parksTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    let imageView = UIImageView()
    let closeButton = UIButton()
    var blurView = UIVisualEffectView()
    var parksListArray: [ParksList]! = []
    let networkReachability = NetworkReachabilityManager()
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIContents()
        if  (networkReachability?.isReachable)! {
            getParksDataFromServer()
        }
        else {
            self.fetchParksFromCoredata()
        }
        registerCell()
    }
    func setupUIContents() {
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        setTopbarImage()
        
        
        
    }
    func setTopbarImage() {
        parksTableView.estimatedRowHeight = 50
        parksTableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0)
        
        imageView.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 300)
        imageView.image = UIImage(named: "default_imageX2")
        if parksListArray.count != 0 {
            if let imageUrl = parksListArray[0].image{
                imageView.kf.setImage(with: URL(string: imageUrl))
            }
            else {
                imageView.image = UIImage(named: "default_imageX2")
            }
        }else {
            imageView.image = nil
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
            return parksListArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let parkCell = tableView.dequeueReusableCell(withIdentifier: "parkCellId", for: indexPath) as! ParkTableViewCell
            if (indexPath.row != 0) {
                parkCell.titleLineView.isHidden = true
                parkCell.imageViewHeight.constant = 200
                
            }
            else {
                parkCell.titleLineView.isHidden = false
                parkCell.imageViewHeight.constant = 0
            }
//            if(indexPath.row == parksListArray.count-1) {
//                parkCell.favouriteViewHeight.constant = 130
//                parkCell.favouriteView.isHidden = false
//                parkCell.shareView.isHidden = false
//                parkCell.favouriteButton.isHidden = false
//                parkCell.shareButton.isHidden = false
//            }
//            else {
                parkCell.favouriteViewHeight.constant = 0
                parkCell.favouriteView.isHidden = true
                parkCell.shareView.isHidden = true
                parkCell.favouriteButton.isHidden = true
                parkCell.shareButton.isHidden = true
           // }
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
        
            loadingView.stopLoading()
            loadingView.isHidden = true
            return parkCell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func setFavouritesAction(cellObj :ParkTableViewCell) {
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
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadLocationErrorPopup()
        self.view.addSubview(popupView)
    }
    @objc func buttonAction(sender: UIButton!) {
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
        _ = Alamofire.request(QatarMuseumRouter.ParksList()).responseObject { (response: DataResponse<ParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                self.parksListArray = data.parkList
                self.setTopbarImage()
                self.saveOrUpdateParksCoredata()
                self.parksTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.parksListArray.count == 0) {
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
    //MARK: Coredata Method
    func saveOrUpdateParksCoredata() {
        if (parksListArray.count > 0) {
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
            let fetchData = checkAddedToCoredata(entityName: "ParksEntity", parksId: nil, managedContext: managedContext) as! [ParksEntity]
            if (fetchData.count > 0) {
                for i in 0 ... parksListArray.count-1 {
                    let parksDict = parksListArray[i]
                    let fetchResult = checkAddedToCoredata(entityName: "ParksEntity", parksId: nil, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let parksdbDict = fetchResult[0] as! ParksEntity
                        parksdbDict.title = parksDict.title
                        parksdbDict.parksDescription = parksDict.description
                        parksdbDict.sortId =  parksDict.sortId
                        parksdbDict.image =  parksDict.image

                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    }
                    else {
                        //save
                        self.saveToCoreData(parksDict: parksDict, managedObjContext: managedContext)

                    }
                }
            }
            else {
                for i in 0 ... parksListArray.count-1 {
                    let parksDict : ParksList?
                    parksDict = parksListArray[i]
                    self.saveToCoreData(parksDict: parksDict!, managedObjContext: managedContext)

                }
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "ParksEntityArabic", parksId: nil, managedContext: managedContext) as! [ParksEntityArabic]
            if (fetchData.count > 0) {
                for i in 0 ... parksListArray.count-1 {
                    let parksDict = parksListArray[i]
                    let fetchResult = checkAddedToCoredata(entityName: "ParksEntityArabic", parksId: nil, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let parksdbDict = fetchResult[0] as! ParksEntityArabic
                        parksdbDict.titleArabic = parksDict.title
                        parksdbDict.descriptionArabic = parksDict.description
                        parksdbDict.sortIdArabic =  parksDict.sortId
                        parksdbDict.imageArabic =  parksDict.image
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    }
                    else {
                        //save
                        self.saveToCoreData(parksDict: parksDict, managedObjContext: managedContext)

                    }
                }
            }
            else {
                for i in 0 ... parksListArray.count-1 {
                    let parksDict : ParksList?
                    parksDict = parksListArray[i]
                    self.saveToCoreData(parksDict: parksDict!, managedObjContext: managedContext)

                }
            }
        }
    }
    
    func saveToCoreData(parksDict: ParksList, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
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
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                var parksArray = [ParksEntity]()
                let parksFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ParksEntity")
                parksArray = (try managedContext.fetch(parksFetchRequest) as? [ParksEntity])!
                
                if (parksArray.count > 0) {
                    for i in 0 ... parksArray.count-1 {
                        self.parksListArray.insert(ParksList(title: parksArray[i].title, description: parksArray[i].parksDescription, sortId: parksArray[i].sortId, image: parksArray[i].image), at: i)

                    }
                    if(parksListArray.count == 0){
                        self.showNoNetwork()
                    }
                    self.setTopbarImage()
                    parksTableView.reloadData()
                }
                else{
                    self.showNoNetwork()
                }
            }
            else {
                var parksArray = [ParksEntityArabic]()
                let parksFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ParksEntityArabic")
                parksArray = (try managedContext.fetch(parksFetchRequest) as? [ParksEntityArabic])!
                if (parksArray.count > 0) {
                    for i in 0 ... parksArray.count-1 {
                        self.parksListArray.insert(ParksList(title: parksArray[i].titleArabic, description: parksArray[i].descriptionArabic, sortId: parksArray[i].sortIdArabic, image: parksArray[i].imageArabic), at: i)
                    }
                    if(parksArray.count == 0){
                        self.showNoNetwork()
                    }
                    self.setTopbarImage()
                    parksTableView.reloadData()
                }
                else{
                    self.showNoNetwork()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    func checkAddedToCoredata(entityName: String?, parksId: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults : [NSManagedObject] = []
        let homeFetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
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
     //MARK: Poup Delegate
    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
    }
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            self.getParksDataFromServer()
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
        // Dispose of any resources that can be recreated.
    }
    

 

}
