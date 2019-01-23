//
//  ExhibitionDetailViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 12/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics
import Alamofire

class ExhibitionDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, comingSoonPopUpProtocol,LoadingViewProtocol {
    @IBOutlet weak var exhibitionDetailTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    
    let imageView = UIImageView()
    let closeButton = UIButton()
    var blurView = UIVisualEffectView()
    var fromHome : Bool = false
    var exhibitionId : String!
    var exhibition: [Exhibition] = []
    let networkReachability = NetworkReachabilityManager()
    var popupView : ComingSoonPopUp = ComingSoonPopUp()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUi()
        if (fromHome == true) {
            if  (networkReachability?.isReachable)! {
                getExhibitionDetail()
            } else {
                self.fetchExhibitionDetailsFromCoredata()
            }
        }
    }
    
    func setUi() {
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        setTopImageUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (fromHome == true) {
            return exhibition.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exhibitionDetailCellId", for: indexPath) as! ExhibitionDetailTableViewCell
        cell.descriptionLabel.textAlignment = .center
        if (fromHome == true) {
            cell.setHomeExhibitionDetail(exhibition: exhibition[indexPath.row])
        } else {
            cell.setMuseumExhibitionDetail()
        }
        cell.favBtnTapAction = {
            () in
            self.setFavouritesAction(cellObj: cell)
        }
        cell.shareBtnTapAction = {
            () in
            self.setShareAction(cellObj: cell)
        }
        cell.locationButtonAction = {
            () in
            self.loadLocationInMap(currentRow: indexPath.row)
        }
        
        loadingView.stopLoading()
        loadingView.isHidden = true
        return cell
    }
    
    func setFavouritesAction(cellObj :ExhibitionDetailTableViewCell) {
        //cellObj.favoriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
    }
    
    func setShareAction(cellObj :ExhibitionDetailTableViewCell) {
       
    }
    
    func setTopImageUI() {
        exhibitionDetailTableView.estimatedRowHeight = 50
        exhibitionDetailTableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0)
        
        imageView.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 300)
        imageView.image = UIImage(named: "default_imageX2")
        if (fromHome == true) {
            if exhibition.count > 0 {
                
                if let imageUrl = exhibition[0].detailImage {
                    if(imageUrl != "") {
                         imageView.kf.setImage(with: URL(string: imageUrl))
                    }else {
                        imageView.image = UIImage(named: "default_imageX2")
                    }
                   
                }
                else {
                    imageView.image = UIImage(named: "default_imageX2")
                }
            }
            else {
                imageView.image = nil
            }
            
        } else {
            if exhibition.count > 0 {
                
                if let imageUrl = exhibition[0].detailImage {
                    if(imageUrl != "") {
                        imageView.kf.setImage(with: URL(string: imageUrl))
                    }else {
                        imageView.image = UIImage(named: "default_imageX2")
                    }
                    
                }
                else {
                    imageView.image = UIImage(named: "default_imageX2")
                }
            } else {
                imageView.image = nil
            }
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
        
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            closeButton.frame = CGRect(x: 10, y: 30, width: 40, height: 40)
        } else {
            closeButton.frame = CGRect(x: self.view.frame.width-50, y: 30, width: 40, height: 40)
        }
        closeButton.setImage(UIImage(named: "closeX1"), for: .normal)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom:12, right: 12)
        
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTouchDownAction), for: .touchDown)
        
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        closeButton.layer.shadowRadius = 5
        closeButton.layer.shadowOpacity = 1.0
        view.addSubview(closeButton)
    }
    
    func loadLocationInMap(currentRow: Int) {
        var latitudeString = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        
        if (( self.fromHome == true) && (exhibition[currentRow].latitude != nil) && (exhibition[currentRow].longitude != nil)) {
            latitudeString = exhibition[currentRow].latitude!
            longitudeString = exhibition[currentRow].longitude!
        }
        
        if ((latitudeString != nil) && (longitudeString != nil) && (latitudeString != "") && (longitudeString != "")) {
            latitude = convertDMSToDDCoordinate(latLongString: latitudeString)
            longitude = convertDMSToDDCoordinate(latLongString: longitudeString)
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
            } else if ((latitude != nil) && (longitude != nil)) {
                let locationUrl = URL(string: "https://maps.google.com/?q=\(latitude!),\(longitude!)")!
                UIApplication.shared.openURL(locationUrl)
            } else {
                showLocationErrorPopup()
            }
        } else {
            showLocationErrorPopup()
        }
    }
    
    func showLocationErrorPopup() {
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadLocationErrorPopup()
        self.view.addSubview(popupView)
    }
    
    //MARK: Poup Delegate
    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
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
    
    @objc func buttonAction(sender: UIButton!) {
        sender.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
            dismiss(animated: false, completion: nil)
    }
    
    @objc func closeButtonTouchDownAction(sender: UIButton!) {
        sender.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    //MARK: Webservice call
    func getExhibitionDetail() {
        _ = Alamofire.request(QatarMuseumRouter.ExhibitionDetail(["nid": exhibitionId!])).responseObject { (response: DataResponse<Exhibitions>) -> Void in
            switch response.result {
            case .success(let data):
                self.exhibition = data.exhibitions!
                self.setTopImageUI()
                self.saveOrUpdateExhibitionsCoredata()
                self.exhibitionDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.exhibition.count == 0) {
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
    func saveOrUpdateExhibitionsCoredata() {
        if (exhibition.count > 0) {
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
            let fetchData = checkAddedToCoredata(entityName: "ExhibitionsEntity", idKey: "id" , idValue: exhibition[0].id, managedContext: managedContext) as! [ExhibitionsEntity]
            if (fetchData.count > 0) {
                let exhibitionDetailDict = exhibition[0]
                
                //update
                let exhibitiondbDict = fetchData[0]
                exhibitiondbDict.detailName = exhibitionDetailDict.name
                exhibitiondbDict.detailImage = exhibitionDetailDict.detailImage
                exhibitiondbDict.detailStartDate =  exhibitionDetailDict.startDate
                exhibitiondbDict.detailEndDate = exhibitionDetailDict.endDate
                exhibitiondbDict.detailShortDesc = exhibitionDetailDict.shortDescription
                exhibitiondbDict.detailLongDesc =  exhibitionDetailDict.longDescription
                exhibitiondbDict.detailLocation =  exhibitionDetailDict.location
                exhibitiondbDict.detailLatitude = exhibitionDetailDict.latitude
                exhibitiondbDict.detailLongitude = exhibitionDetailDict.longitude
                exhibitiondbDict.status = exhibitionDetailDict.status
                
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
            }
            else {
                let exhibitionListDict : Exhibition?
                exhibitionListDict = exhibition[0]
                self.saveToCoreData(exhibitionDetailDict: exhibitionListDict!, managedObjContext: managedContext)
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "ExhibitionsEntityArabic", idKey:"id" , idValue: exhibition[0].id, managedContext: managedContext) as! [ExhibitionsEntityArabic]
            if (fetchData.count > 0) {
                let exhibitionDetailDict = exhibition[0]
                
                //update
                
                let exhibitiondbDict = fetchData[0]
                exhibitiondbDict.detailNameAr = exhibitionDetailDict.name
                exhibitiondbDict.detailImgeAr = exhibitionDetailDict.detailImage
                exhibitiondbDict.detailStartDateAr =  exhibitionDetailDict.startDate
                exhibitiondbDict.detailendDateAr = exhibitionDetailDict.endDate
                exhibitiondbDict.detailShortDescAr = exhibitionDetailDict.shortDescription
                exhibitiondbDict.detailLongDescAr =  exhibitionDetailDict.longDescription
                exhibitiondbDict.detailLocationAr =  exhibitionDetailDict.location
                exhibitiondbDict.detailLatituedeAr = exhibitionDetailDict.latitude
                exhibitiondbDict.detailLongitudeAr = exhibitionDetailDict.longitude
                exhibitiondbDict.status = exhibitionDetailDict.status
                
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
            } else {
                let exhibitionListDict : Exhibition?
                exhibitionListDict = exhibition[0]
                self.saveToCoreData(exhibitionDetailDict: exhibitionListDict!, managedObjContext: managedContext)
            }
        }
    }

    func saveToCoreData(exhibitionDetailDict: Exhibition, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let exhibitionInfo: ExhibitionsEntity = NSEntityDescription.insertNewObject(forEntityName: "ExhibitionsEntity", into: managedObjContext) as! ExhibitionsEntity
            exhibitionInfo.id = exhibitionDetailDict.id
            exhibitionInfo.detailName = exhibitionDetailDict.name
            exhibitionInfo.detailImage = exhibitionDetailDict.detailImage
            exhibitionInfo.detailStartDate = exhibitionDetailDict.startDate
            exhibitionInfo.detailEndDate = exhibitionDetailDict.endDate
            exhibitionInfo.detailShortDesc =  exhibitionDetailDict.shortDescription
            exhibitionInfo.detailLongDesc =  exhibitionDetailDict.longDescription
            exhibitionInfo.detailLocation = exhibitionDetailDict.location
            exhibitionInfo.detailLatitude =  exhibitionDetailDict.latitude
            exhibitionInfo.detailLongitude = exhibitionDetailDict.longitude
            exhibitionInfo.status = exhibitionDetailDict.status
            
        }
        else {
            let exhibitionInfo: ExhibitionsEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "ExhibitionsEntityArabic", into: managedObjContext) as! ExhibitionsEntityArabic
            exhibitionInfo.id = exhibitionDetailDict.id
            exhibitionInfo.detailNameAr = exhibitionDetailDict.name
            exhibitionInfo.detailImgeAr = exhibitionDetailDict.detailImage
            exhibitionInfo.detailStartDateAr = exhibitionDetailDict.startDate
            exhibitionInfo.detailendDateAr = exhibitionDetailDict.endDate
            exhibitionInfo.detailShortDescAr =  exhibitionDetailDict.shortDescription
            exhibitionInfo.detailLongDescAr =  exhibitionDetailDict.longDescription
            exhibitionInfo.detailLocationAr = exhibitionDetailDict.location
            exhibitionInfo.detailLatituedeAr =  exhibitionDetailDict.latitude
            exhibitionInfo.detailLongitudeAr = exhibitionDetailDict.longitude
            exhibitionInfo.status = exhibitionDetailDict.status
        }
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func fetchExhibitionDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var exhibitionArray = [ExhibitionsEntity]()
                let exhibitionFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ExhibitionsEntity")
                if(self.exhibitionId != nil) {
                    exhibitionFetchRequest.predicate = NSPredicate.init(format: "id == \(self.exhibitionId!)")
                }
                exhibitionArray = (try managedContext.fetch(exhibitionFetchRequest) as? [ExhibitionsEntity])!
                let exhibitionDict = exhibitionArray[0]
                if ((exhibitionArray.count > 0) && (exhibitionDict.detailLongDesc != nil) && (exhibitionDict.detailShortDesc != nil) ){
                   
                    self.exhibition.insert(Exhibition(id: exhibitionDict.id, name: exhibitionDict.detailName, image: nil,detailImage:exhibitionDict.detailImage, startDate: exhibitionDict.detailStartDate, endDate: exhibitionDict.detailEndDate, location: exhibitionDict.detailLocation, latitude: exhibitionDict.detailLatitude, longitude: exhibitionDict.detailLongitude, shortDescription: exhibitionDict.detailShortDesc, longDescription: exhibitionDict.detailLongDesc,museumId:nil,status: exhibitionDict.status, displayDate: exhibitionDict.dispalyDate), at: 0)
                    
                    if(self.exhibition.count == 0){
                        self.showNoNetwork()
                    }
                    self.self.setTopImageUI()
                    self.exhibitionDetailTableView.reloadData()
                }
                else{
                    self.showNoNetwork()
                }
            }
            else {
                var exhibitionArray = [ExhibitionsEntityArabic]()
                let exhibitionFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ExhibitionsEntityArabic")
                if(self.exhibitionId != nil) {
                    exhibitionFetchRequest.predicate = NSPredicate.init(format: "id == \(self.exhibitionId!)")
                }
                exhibitionArray = (try managedContext.fetch(exhibitionFetchRequest) as? [ExhibitionsEntityArabic])!
                let exhibitionDict = exhibitionArray[0]
                if ((exhibitionArray.count > 0) && (exhibitionDict.detailLongDescAr != nil) && (exhibitionDict.detailShortDescAr != nil)) {
                    
                    self.exhibition.insert(Exhibition(id: exhibitionDict.id, name: exhibitionDict.detailNameAr, image: nil,detailImage:exhibitionDict.detailImgeAr, startDate: exhibitionDict.detailStartDateAr, endDate: exhibitionDict.detailendDateAr, location: exhibitionDict.detailLocationAr, latitude: exhibitionDict.detailLatituedeAr, longitude: exhibitionDict.detailLongitudeAr, shortDescription: exhibitionDict.detailShortDescAr, longDescription: exhibitionDict.detailLongDescAr,museumId:nil,status: exhibitionDict.status, displayDate: exhibitionDict.displayDateAr), at: 0)
                    
                    
                    if(self.exhibition.count == 0){
                        self.showNoNetwork()
                    }
                    self.setTopImageUI()
                    self.exhibitionDetailTableView.reloadData()
                }
                else{
                    self.showNoNetwork()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func checkAddedToCoredata(entityName: String?,idKey:String?, idValue: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults : [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
        if (idValue != nil) {
            fetchRequest.predicate = NSPredicate.init(format: "\(idKey!) == \(idValue!)")
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
            self.getExhibitionDetail()
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
