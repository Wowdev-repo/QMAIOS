//
//  HeritageDetailViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 21/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Firebase
import UIKit
enum PageName{
    case heritageDetail
    case publicArtsDetail
    case museumAbout
}
class HeritageDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, comingSoonPopUpProtocol,LoadingViewProtocol, iCarouselDelegate,iCarouselDataSource {
    @IBOutlet weak var heritageDetailTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    
    let imageView = UIImageView()
    let closeButton = UIButton()
    var blurView = UIVisualEffectView()
    var pageNameString : PageName?
    var heritageDetailtArray: [Heritage] = []
    var publicArtsDetailtArray: [PublicArtsDetail] = []
    //var aboutDetailtArray: [MuseumAbout] = []
    var aboutDetailtArray : [Museum] = []
    var heritageDetailId : String? = nil
    var publicArtsDetailId : String? = nil
    let networkReachability = NetworkReachabilityManager()
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var museumId : String? = nil
    var carousel = iCarousel()
    var transparentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUIContents()
        if ((pageNameString == PageName.heritageDetail) && (heritageDetailId != nil)) {
            if  (networkReachability?.isReachable)! {
                getHeritageDetailsFromServer()
            } else {
                self.fetchHeritageDetailsFromCoredata()
            }
        } else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailId != nil)) {
            if  (networkReachability?.isReachable)! {
                getPublicArtsDetailsFromServer()
            } else {
                self.fetchPublicArtsDetailsFromCoredata()
            }
            
        } else if (pageNameString == PageName.museumAbout) {
            if  (networkReachability?.isReachable)! {
                getAboutDetailsFromServer()
            
                //saveOrUpdateAboutCoredata()
            } else {
                self.fetchAboutDetailsFromCoredata()
                
            }
        }
        recordScreenView()
    }
    
    func setupUIContents() {
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        setTopBarImage()
    }
    
    func setTopBarImage() {
        heritageDetailTableView.estimatedRowHeight = 50
        heritageDetailTableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0)
        
        imageView.frame = CGRect(x: 0, y:20, width: UIScreen.main.bounds.size.width, height: 300)
        imageView.image = UIImage(named: "default_imageX2")
        if (pageNameString == PageName.heritageDetail) {
        
            if heritageDetailtArray.count != 0 {
                if let imageUrl = heritageDetailtArray[0].image{
                    imageView.kf.setImage(with: URL(string: imageUrl))
                }
                else {
                    imageView.image = UIImage(named: "default_imageX2")
                }
            }
            else {
                imageView.image = nil
            }
        } else if (pageNameString == PageName.publicArtsDetail){
            
            if publicArtsDetailtArray.count != 0 {
                if let imageUrl = publicArtsDetailtArray[0].image{
                    imageView.kf.setImage(with: URL(string: imageUrl))
                }
                else {
                    imageView.image = UIImage(named: "default_imageX2")
                }
            }
            else {
                imageView.image = nil
            }
        } else if (pageNameString == PageName.museumAbout){

            if (aboutDetailtArray.count > 0)  {
                if(aboutDetailtArray[0].multimediaFile != nil) {
                if ((aboutDetailtArray[0].multimediaFile?.count)! > 0) {
                let url = aboutDetailtArray[0].multimediaFile
                if( url![0] != nil) {
                    imageView.kf.setImage(with: URL(string: url![0]))
                }
                else {
                    imageView.image = UIImage(named: "default_imageX2")
                }
                }
                }
            }
            else {
                imageView.image = nil
            }
 
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
        
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            closeButton.frame = CGRect(x: 10, y: 30, width: 40, height: 40)
        } else {
            closeButton.frame = CGRect(x: self.view.frame.width-50, y: 30, width: 40, height: 40)
        }
        closeButton.setImage(UIImage(named: "closeX1"), for: .normal)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom:12, right: 12)
        
        closeButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTouchDownAction), for: .touchDown)
        
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        closeButton.layer.shadowRadius = 3
        closeButton.layer.shadowOpacity = 2.0
        view.addSubview(closeButton)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (pageNameString == PageName.heritageDetail) {
            return heritageDetailtArray.count
        } else if (pageNameString == PageName.publicArtsDetail){
            return publicArtsDetailtArray.count
        } else if (pageNameString == PageName.museumAbout){
            if(aboutDetailtArray.count > 0) {
                return aboutDetailtArray.count
               // return 1
            } else {
                return 0
            }
            
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let heritageCell = tableView.dequeueReusableCell(withIdentifier: "heritageDetailCellId", for: indexPath) as! HeritageDetailCell
        if (pageNameString == PageName.heritageDetail) {
            heritageCell.setHeritageDetailData(heritageDetail: heritageDetailtArray[indexPath.row])
            heritageCell.midTitleDescriptionLabel.textAlignment = .center
        } else if(pageNameString == PageName.publicArtsDetail){
            heritageCell.setPublicArtsDetailValues(publicArsDetail: publicArtsDetailtArray[indexPath.row])
        } else {
            heritageCell.setMuseumAboutCellData(aboutData: aboutDetailtArray[indexPath.row])
           // heritageCell.setMuseumAboutCellData(aboutData: aboutDetailtArray[0])
        }
        if (isHeritageImgArrayAvailable() || isPublicArtImgArrayAvailable()) {
            heritageCell.pageControl.isHidden = false
        } else {
            heritageCell.pageControl.isHidden = true
        }
        heritageCell.favBtnTapAction = {
            () in
            self.setFavouritesAction(cellObj: heritageCell)
        }
        heritageCell.shareBtnTapAction = {
            () in
            self.setShareAction(cellObj: heritageCell)
        }
        heritageCell.locationButtonTapAction = {
            () in
            self.loadLocationInMap(currentRow: indexPath.row)
        }
        loadingView.stopLoading()
        loadingView.isHidden = true
        return heritageCell
    }
    
    func setFavouritesAction(cellObj :HeritageDetailCell) {
        if (cellObj.favoriteButton.tag == 0) {
            cellObj.favoriteButton.tag = 1
            cellObj.favoriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        } else {
            cellObj.favoriteButton.tag = 0
            cellObj.favoriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
    }
    
    func setShareAction(cellObj :HeritageDetailCell) {
        
    }
    
    func loadLocationInMap(currentRow: Int) {
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        if ((pageNameString == PageName.museumAbout) && (aboutDetailtArray[0].mobileLatitude != nil) && (aboutDetailtArray[0].mobileLongtitude != nil)) {
            latitudeString = (aboutDetailtArray[0].mobileLatitude)!
            longitudeString = (aboutDetailtArray[0].mobileLongtitude)!
        } else if ((pageNameString == PageName.heritageDetail) && (heritageDetailtArray[currentRow].latitude != nil) && (heritageDetailtArray[currentRow].longitude != nil)) {
            latitudeString = heritageDetailtArray[currentRow].latitude!
            longitudeString = heritageDetailtArray[currentRow].longitude!
        }
            else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailtArray[currentRow].latitude != nil) && (publicArtsDetailtArray[currentRow].longitude != nil))
        {
            latitudeString = publicArtsDetailtArray[currentRow].latitude!
            longitudeString = publicArtsDetailtArray[currentRow].longitude!
        }
        
        if latitudeString != nil && longitudeString != nil && latitudeString != "" && longitudeString != ""{
            if ((pageNameString == PageName.museumAbout) || (pageNameString == PageName.publicArtsDetail)) {
                if let lat : Double = Double(latitudeString) {
                    latitude = lat
                }
                if let long : Double = Double(longitudeString) {
                    longitude = long
                }
                
            } else {
                latitude = convertDMSToDDCoordinate(latLongString: latitudeString)
                longitude = convertDMSToDDCoordinate(latLongString: longitudeString)
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
    
    @objc func closeTouchDownAction(sender: UIButton!) {
        sender.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    //MARK: iCarousel Delegate
    func numberOfItems(in carousel: iCarousel) -> Int {
        if (isHeritageImgArrayAvailable()) {
            return (self.heritageDetailtArray[0].images?.count)!
        } else if (isPublicArtImgArrayAvailable()) {
            return (self.publicArtsDetailtArray[0].images?.count)!
        }
        return 0
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIImageView
        itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: carousel.frame.width, height: 300))
        itemView.contentMode = .scaleAspectFit
        var carouselImg: [String]?
        if (pageNameString == PageName.heritageDetail) {
            carouselImg = self.heritageDetailtArray[0].images
        } else if (pageNameString == PageName.publicArtsDetail) {
            carouselImg = self.publicArtsDetailtArray[0].images
        }
        if (carouselImg != nil) {
            let imageUrl = carouselImg![index]
            if(imageUrl != nil){
                itemView.kf.setImage(with: URL(string: imageUrl))
            }
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
            if (isHeritageImgArrayAvailable() || isPublicArtImgArrayAvailable()) {
                setiCarouselView()
            }
        }
    }
    
    func isHeritageImgArrayAvailable() -> Bool {
        if (pageNameString == PageName.heritageDetail) {
            if(self.heritageDetailtArray.count != 0) {
                if(self.heritageDetailtArray[0].images != nil) {
                    if((self.heritageDetailtArray[0].images?.count)! > 0) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func isPublicArtImgArrayAvailable() -> Bool {
        if (pageNameString == PageName.publicArtsDetail) {
            if(self.publicArtsDetailtArray.count != 0) {
                if(self.publicArtsDetailtArray[0].images != nil) {
                    if((self.publicArtsDetailtArray[0].images?.count)! > 0) {
                        return true
                    }
                }
            }
        }
        return false
    }
    //MARK: WebServiceCall
    func getHeritageDetailsFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.HeritageDetail(["nid": heritageDetailId!])).responseObject { (response: DataResponse<Heritages>) -> Void in
            switch response.result {
            case .success(let data):
                self.heritageDetailtArray = data.heritage!
                self.setTopBarImage()
                self.saveOrUpdateHeritageCoredata()
                self.heritageDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.heritageDetailtArray.count == 0) {
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
    
    //MARK: PublicArts webservice call
    func getPublicArtsDetailsFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.GetPublicArtsDetail(["nid": publicArtsDetailId!])).responseObject { (response: DataResponse<PublicArtsDetails>) -> Void in
            switch response.result {
            case .success(let data):
                self.publicArtsDetailtArray = data.publicArtsDetail!
                self.setTopBarImage()
                self.saveOrUpdatePublicArtsCoredata()
                self.heritageDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.publicArtsDetailtArray.count == 0) {
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
    //MARK: Heritage Coredata Method
    func saveOrUpdateHeritageCoredata() {
        if (heritageDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.heritageCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.heritageCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    
    func heritageCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "HeritageEntity", idKey: "listid" , idValue: heritageDetailtArray[0].id, managedContext: managedContext) as! [HeritageEntity]
           if (fetchData.count > 0) {
                let heritageDetailDict = heritageDetailtArray[0]
            
                //update
                let heritagedbDict = fetchData[0]
            
                heritagedbDict.listname = heritageDetailDict.name
                heritagedbDict.listimage = heritageDetailDict.image
                heritagedbDict.listsortid =  heritageDetailDict.sortid
                heritagedbDict.detaillocation = heritageDetailDict.location
                heritagedbDict.detailshortdescription = heritageDetailDict.shortdescription
                heritagedbDict.detaillongdescription =  heritageDetailDict.longdescription
                heritagedbDict.detaillatitude =  heritageDetailDict.latitude
                heritagedbDict.detaillongitude = heritageDetailDict.longitude
            
            
            if((heritageDetailDict.images?.count)! > 0) {
                for i in 0 ... (heritageDetailDict.images?.count)!-1 {
                    var heritageImagesEntity: HeritageImagesEntity!
                    let heritageImage: HeritageImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "HeritageImagesEntity", into: managedContext) as! HeritageImagesEntity
                    heritageImage.images = heritageDetailDict.images![i]
                    
                    heritageImagesEntity = heritageImage
                    heritagedbDict.addToImagesRelation(heritageImagesEntity)
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
            let heritageListDict : Heritage?
            heritageListDict = heritageDetailtArray[0]
            self.saveToCoreData(heritageDetailDict: heritageListDict!, managedObjContext: managedContext)
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "HeritageEntityArabic", idKey:"listid" , idValue: heritageDetailtArray[0].id, managedContext: managedContext) as! [HeritageEntityArabic]
            if (fetchData.count > 0) {
                let heritageDetailDict = heritageDetailtArray[0]
                
                //update
                
                let heritagedbDict = fetchData[0]
                heritagedbDict.listnamearabic = heritageDetailDict.name
                heritagedbDict.listimagearabic = heritageDetailDict.image
                heritagedbDict.listsortidarabic =  heritageDetailDict.sortid
                heritagedbDict.detaillocationarabic = heritageDetailDict.location
                heritagedbDict.detailshortdescarabic = heritageDetailDict.shortdescription
                heritagedbDict.detaillongdescriptionarabic =  heritageDetailDict.longdescription
                heritagedbDict.detaillatitudearabic =  heritageDetailDict.latitude
                heritagedbDict.detaillongitudearabic = heritageDetailDict.longitude
                
                if((heritageDetailDict.images?.count)! > 0) {
                    for i in 0 ... (heritageDetailDict.images?.count)!-1 {
                        var heritageImagesEntity: HeritageImagesEntityAr!
                        let heritageImage: HeritageImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "HeritageImagesEntityAr", into: managedContext) as! HeritageImagesEntityAr
                        heritageImage.images = heritageDetailDict.images![i]
                        
                        heritageImagesEntity = heritageImage
                        heritagedbDict.addToImagesRelation(heritageImagesEntity)
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
            }
            else {
                let heritageListDict : Heritage?
                heritageListDict = heritageDetailtArray[0]
                self.saveToCoreData(heritageDetailDict: heritageListDict!, managedObjContext: managedContext)
            }
        }
    }
    
    func saveToCoreData(heritageDetailDict: Heritage, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let heritageInfo: HeritageEntity = NSEntityDescription.insertNewObject(forEntityName: "HeritageEntity", into: managedObjContext) as! HeritageEntity
            heritageInfo.listid = heritageDetailDict.id
            heritageInfo.listname = heritageDetailDict.name
            
            heritageInfo.listimage = heritageDetailDict.image
            heritageInfo.detaillocation = heritageDetailDict.location
            heritageInfo.detailshortdescription = heritageDetailDict.shortdescription
            heritageInfo.detaillongdescription =  heritageDetailDict.longdescription
            heritageInfo.detaillatitude =  heritageDetailDict.latitude
            heritageInfo.detaillongitude = heritageDetailDict.longitude
            if(heritageDetailDict.sortid != nil) {
                heritageInfo.listsortid = heritageDetailDict.sortid
            }
            
            if((heritageDetailDict.images?.count)! > 0) {
                for i in 0 ... (heritageDetailDict.images?.count)!-1 {
                    var heritageImagesEntity: HeritageImagesEntity!
                    let heritageImage: HeritageImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "HeritageImagesEntity", into: managedObjContext) as! HeritageImagesEntity
                    heritageImage.images = heritageDetailDict.images![i]
                    
                    heritageImagesEntity = heritageImage
                    heritageInfo.addToImagesRelation(heritageImagesEntity)
                    do {
                        try managedObjContext.save()
                        
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                }
            }
        }
        else {
            let heritageInfo: HeritageEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "HeritageEntityArabic", into: managedObjContext) as! HeritageEntityArabic
            heritageInfo.listid = heritageDetailDict.id
            heritageInfo.listnamearabic = heritageDetailDict.name
            
            heritageInfo.listimagearabic = heritageDetailDict.image
            heritageInfo.detaillocationarabic = heritageDetailDict.location
            heritageInfo.detailshortdescarabic = heritageDetailDict.shortdescription
            heritageInfo.detaillongdescriptionarabic =  heritageDetailDict.longdescription
            heritageInfo.detaillatitudearabic =  heritageDetailDict.latitude
            heritageInfo.detaillongitudearabic = heritageDetailDict.longitude
            if(heritageDetailDict.sortid != nil) {
                heritageInfo.listsortidarabic = heritageDetailDict.sortid
            }
            
            
            if((heritageDetailDict.images?.count)! > 0) {
                for i in 0 ... (heritageDetailDict.images?.count)!-1 {
                    var heritageImagesEntity: HeritageImagesEntityAr!
                    let heritageImage: HeritageImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "HeritageImagesEntityAr", into: managedObjContext) as! HeritageImagesEntityAr
                    heritageImage.images = heritageDetailDict.images![i]
                    
                    heritageImagesEntity = heritageImage
                    heritageInfo.addToImagesRelation(heritageImagesEntity)
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
    
    func fetchHeritageDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var heritageArray = [HeritageEntity]()
                let heritageFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "HeritageEntity")
                if(heritageDetailId != nil) {
                    heritageFetchRequest.predicate = NSPredicate.init(format: "listid == \(heritageDetailId!)")
                    heritageArray = (try managedContext.fetch(heritageFetchRequest) as? [HeritageEntity])!
                    
                    if (heritageArray.count > 0) {
                        let heritageDict = heritageArray[0]
                        
                        
                        if((heritageDict.detailshortdescription != nil) && (heritageDict.detaillongdescription != nil) ) {
                            var imagesArray : [String] = []
                            let heritageImagesArray = (heritageDict.imagesRelation?.allObjects) as! [HeritageImagesEntity]
                            if(heritageImagesArray.count > 0) {
                                for i in 0 ... heritageImagesArray.count-1 {
                                    imagesArray.append(heritageImagesArray[i].images!)
                                }
                            }
                            self.heritageDetailtArray.insert(Heritage(id: heritageDict.listid, name: heritageDict.listname, location: heritageDict.detaillocation, latitude: heritageDict.detaillatitude, longitude: heritageDict.detaillongitude, image: heritageDict.listimage, shortdescription: heritageDict.detailshortdescription, longdescription: heritageDict.detaillongdescription, images: imagesArray, sortid: heritageDict.listsortid), at: 0)
                            
                          
                            if(heritageDetailtArray.count == 0){
                                self.showNoNetwork()
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                        }else{
                            self.showNoNetwork()
                        }
                    }else{
                        self.showNoNetwork()
                    }
                }

            }
            else {
                var heritageArray = [HeritageEntityArabic]()
                let heritageFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "HeritageEntityArabic")
                if(heritageDetailId != nil) {
                    heritageFetchRequest.predicate = NSPredicate.init(format: "listid == \(heritageDetailId!)")
                    heritageArray = (try managedContext.fetch(heritageFetchRequest) as? [HeritageEntityArabic])!
                    
                    if (heritageArray.count > 0) {
                        let heritageDict = heritageArray[0]
                       
                        if( (heritageDict.detailshortdescarabic != nil) && (heritageDict.detaillongdescriptionarabic != nil)) {
                            var imagesArray : [String] = []
                            let heritageImagesArray = (heritageDict.imagesRelation?.allObjects) as! [HeritageImagesEntityAr]
                            if(heritageImagesArray.count > 0) {
                                for i in 0 ... heritageImagesArray.count-1 {
                                    imagesArray.append(heritageImagesArray[i].images!)
                                }
                            }
                            self.heritageDetailtArray.insert(Heritage(id: heritageDict.listid, name: heritageDict.listnamearabic, location: heritageDict.detaillocationarabic, latitude: heritageDict.detaillatitudearabic, longitude: heritageDict.detaillongitudearabic, image: heritageDict.listimagearabic, shortdescription: heritageDict.detailshortdescarabic, longdescription: heritageDict.detaillongdescriptionarabic,images: imagesArray, sortid: heritageDict.listsortidarabic), at: 0)
                            
                            
                            if(heritageDetailtArray.count == 0){
                                self.showNoNetwork()
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                            
                        }else{
                            self.showNoNetwork()
                        }
                    }
                    else{
                        self.showNoNetwork()
                    }
                }

            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: PublicArts Coredata Method
    func saveOrUpdatePublicArtsCoredata() {
        if (publicArtsDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.publicArtCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.publicArtCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    
    func publicArtCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "PublicArtsEntity", idKey: "id" , idValue: publicArtsDetailtArray[0].id, managedContext: managedContext) as! [PublicArtsEntity]
            if (fetchData.count > 0) {
                let publicArtsDetailDict = publicArtsDetailtArray[0]
                
                //update
                let publicArtsbDict = fetchData[0]
                publicArtsbDict.name = publicArtsDetailDict.name
                publicArtsbDict.detaildescription = publicArtsDetailDict.description
                publicArtsbDict.shortdescription = publicArtsDetailDict.shortdescription
                publicArtsbDict.image = publicArtsDetailDict.image
                publicArtsbDict.latitude = publicArtsDetailDict.latitude
                publicArtsbDict.longitude = publicArtsDetailDict.longitude
                if(publicArtsDetailDict.images != nil) {
                if((publicArtsDetailDict.images?.count)! > 0) {
                    for i in 0 ... (publicArtsDetailDict.images?.count)!-1 {
                        var publicArtsImagesEntity: PublicArtsImagesEntity!
                        let publicArtsImage: PublicArtsImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsImagesEntity", into: managedContext) as! PublicArtsImagesEntity
                        publicArtsImage.images = publicArtsDetailDict.images![i]
                        publicArtsImagesEntity = publicArtsImage
                        publicArtsbDict.addToPublicImagesRelation(publicArtsImagesEntity)
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
                let publicArtsDetailDict : PublicArtsDetail?
                publicArtsDetailDict = publicArtsDetailtArray[0]
                self.saveToCoreData(publicArtseDetailDict: publicArtsDetailDict!, managedObjContext: managedContext)
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "PublicArtsEntityArabic", idKey:"id" , idValue: publicArtsDetailtArray[0].id, managedContext: managedContext) as! [PublicArtsEntityArabic]
            if (fetchData.count > 0) {
                let publicArtsDetailDict = publicArtsDetailtArray[0]
                
                //update
                
                let publicArtsdbDict = fetchData[0]
                publicArtsdbDict.namearabic = publicArtsDetailDict.name
                publicArtsdbDict.descriptionarabic = publicArtsDetailDict.description
                publicArtsdbDict.shortdescriptionarabic = publicArtsDetailDict.shortdescription
                publicArtsdbDict.imagearabic = publicArtsDetailDict.image
                publicArtsdbDict.latitudearabic = publicArtsDetailDict.latitude
                publicArtsdbDict.longitudearabic = publicArtsDetailDict.longitude
                if((publicArtsDetailDict.images?.count)! > 0) {
                    for i in 0 ... (publicArtsDetailDict.images?.count)!-1 {
                        var publicArtsImagesEntity: PublicArtsImagesEntityAr!
                        let publicArtsImage: PublicArtsImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsImagesEntityAr", into: managedContext) as! PublicArtsImagesEntityAr
                        publicArtsImage.images = publicArtsDetailDict.images![i]
                        publicArtsImagesEntity = publicArtsImage
                        publicArtsdbDict.addToPublicImagesRelation(publicArtsImagesEntity)
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
            }
            else {
                let publicArtsListDict : PublicArtsDetail?
                publicArtsListDict = publicArtsDetailtArray[0]
                self.saveToCoreData(publicArtseDetailDict: publicArtsListDict!, managedObjContext: managedContext)
            }
        }
    }
    
    func saveToCoreData(publicArtseDetailDict: PublicArtsDetail, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let publicArtsInfo: PublicArtsEntity = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsEntity", into: managedObjContext) as! PublicArtsEntity
            publicArtsInfo.id = publicArtseDetailDict.id
            publicArtsInfo.name = publicArtseDetailDict.name
            publicArtsInfo.detaildescription = publicArtseDetailDict.description
            publicArtsInfo.shortdescription = publicArtseDetailDict.shortdescription
            publicArtsInfo.image = publicArtseDetailDict.image
            publicArtsInfo.latitude = publicArtseDetailDict.latitude
            publicArtsInfo.longitude = publicArtseDetailDict.longitude
            
            if((publicArtseDetailDict.images?.count)! > 0) {
                for i in 0 ... (publicArtseDetailDict.images?.count)!-1 {
                    var publicArtsImagesEntity: PublicArtsImagesEntity!
                    let publicArtsImage: PublicArtsImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsImagesEntity", into: managedObjContext) as! PublicArtsImagesEntity
                    publicArtsImage.images = publicArtseDetailDict.images![i]
                    publicArtsImagesEntity = publicArtsImage
                    publicArtsInfo.addToPublicImagesRelation(publicArtsImagesEntity)
                    do {
                        try managedObjContext.save()
                        
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                }
            }
            
        }
        else {
            let publicArtsInfo: PublicArtsEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsEntityArabic", into: managedObjContext) as! PublicArtsEntityArabic
            publicArtsInfo.id = publicArtseDetailDict.id
            publicArtsInfo.namearabic = publicArtseDetailDict.name
            publicArtsInfo.descriptionarabic = publicArtseDetailDict.description
            publicArtsInfo.shortdescriptionarabic = publicArtseDetailDict.shortdescription
            publicArtsInfo.imagearabic = publicArtseDetailDict.image
            publicArtsInfo.latitudearabic = publicArtseDetailDict.latitude
            publicArtsInfo.longitudearabic = publicArtseDetailDict.longitude
            
            if((publicArtseDetailDict.images?.count)! > 0) {
                for i in 0 ... (publicArtseDetailDict.images?.count)!-1 {
                    var publicArtsImagesEntity: PublicArtsImagesEntityAr!
                    let publicArtsImage: PublicArtsImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsImagesEntityAr", into: managedObjContext) as! PublicArtsImagesEntityAr
                    publicArtsImage.images = publicArtseDetailDict.images![i]
                    publicArtsImagesEntity = publicArtsImage
                    publicArtsInfo.addToPublicImagesRelation(publicArtsImagesEntity)
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
    
    func fetchPublicArtsDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var publicArtsArray = [PublicArtsEntity]()
                let publicArtsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "PublicArtsEntity")
                if(publicArtsDetailId != nil) {
                    publicArtsFetchRequest.predicate = NSPredicate.init(format: "id == \(publicArtsDetailId!)")
                    publicArtsArray = (try managedContext.fetch(publicArtsFetchRequest) as? [PublicArtsEntity])!
                    
                    if (publicArtsArray.count > 0) {
                        let publicArtsDict = publicArtsArray[0]
                        if((publicArtsDict.detaildescription != nil) && (publicArtsDict.shortdescription != nil) ) {
                            
                            var imagesArray : [String] = []
                            let publicArtsImagesArray = (publicArtsDict.publicImagesRelation?.allObjects) as! [PublicArtsImagesEntity]
                            if(publicArtsImagesArray.count > 0) {
                                for i in 0 ... publicArtsImagesArray.count-1 {
                                    imagesArray.append(publicArtsImagesArray[i].images!)
                                }
                            }
                            self.publicArtsDetailtArray.insert(PublicArtsDetail(id:publicArtsDict.id , name:publicArtsDict.name, description: publicArtsDict.detaildescription, shortdescription: publicArtsDict.shortdescription, image: publicArtsDict.image, images: imagesArray,longitude: publicArtsDict.longitude, latitude: publicArtsDict.latitude), at: 0)
                            
                            if(publicArtsDetailtArray.count == 0){
                                self.showNoNetwork()
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                        }else {
                            self.showNoNetwork()
                        }
                    }
                    else{
                        self.showNoNetwork()
                    }
                }

            }
            else {
                var publicArtsArray = [PublicArtsEntityArabic]()
                let publicArtsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "PublicArtsEntityArabic")
                if(publicArtsDetailId != nil) {
                    publicArtsFetchRequest.predicate = NSPredicate.init(format: "id == \(publicArtsDetailId!)")
                    publicArtsArray = (try managedContext.fetch(publicArtsFetchRequest) as? [PublicArtsEntityArabic])!
                    
                    if (publicArtsArray.count > 0)  {
                        let publicArtsDict = publicArtsArray[0]
                        if((publicArtsDict.descriptionarabic != nil) && (publicArtsDict.shortdescriptionarabic != nil)) {
                            var imagesArray : [String] = []
                            let publicArtsImagesArray = (publicArtsDict.publicImagesRelation?.allObjects) as! [PublicArtsImagesEntityAr]
                            if(publicArtsImagesArray.count > 0) {
                                for i in 0 ... publicArtsImagesArray.count-1 {
                                    imagesArray.append(publicArtsImagesArray[i].images!)
                                }
                            }
                            self.publicArtsDetailtArray.insert(PublicArtsDetail(id:publicArtsDict.id , name:publicArtsDict.namearabic, description: publicArtsDict.descriptionarabic, shortdescription: publicArtsDict.shortdescriptionarabic, image: publicArtsDict.imagearabic,images: imagesArray,longitude: publicArtsDict.longitudearabic, latitude: publicArtsDict.latitudearabic), at: 0)
                            
                            
                            if(publicArtsDetailtArray.count == 0){
                                self.showNoNetwork()
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                        }
                        else{
                            self.showNoNetwork()
                        }
                    }
                    else{
                        self.showNoNetwork()
                    }
                }

            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK:MUSEUMABOUT
    /*
    
    func getAboutDetailsFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.MuseumAbout(["mid": museumId ?? "0"])).responseObject { (response: DataResponse<MuseumAboutDetails>) -> Void in
            switch response.result {
            case .success(let data):
                self.aboutDetailtArray = data.museumAbout!
                self.setTopBarImage()
                self.saveOrUpdateAboutCoredata()
                self.heritageDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.aboutDetailtArray.count == 0) {
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
 */
    
    func getAboutDetailsFromServer()
    {
        _ = Alamofire.request(QatarMuseumRouter.LandingPageMuseums(["nid": museumId ?? 0])).responseObject { (response: DataResponse<Museums>) -> Void in
            switch response.result {
            case .success(let data):
                self.aboutDetailtArray = data.museum!
                self.setTopBarImage()
                self.saveOrUpdateAboutCoredata()
                self.heritageDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.aboutDetailtArray.count == 0) {
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
    
    //MARK: About CoreData
    func saveOrUpdateAboutCoredata() {
        if (aboutDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.aboutCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.aboutCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    
    func aboutCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "AboutEntity", idKey: "id" , idValue: aboutDetailtArray[0].id, managedContext: managedContext) as! [AboutEntity]
           
            if (fetchData.count > 0) {
                let aboutDetailDict = aboutDetailtArray[0]
                
                //update
                let aboutdbDict = fetchData[0]

                aboutdbDict.name = aboutDetailDict.name
                aboutdbDict.id = aboutDetailDict.id
                aboutdbDict.tourguideAvailable = aboutDetailDict.tourguideAvailable
                aboutdbDict.contactNumber = aboutDetailDict.contactNumber
                aboutdbDict.contactEmail = aboutDetailDict.contactEmail
                aboutdbDict.mobileLongtitude = aboutDetailDict.mobileLongtitude
                aboutdbDict.subtitle = aboutDetailDict.subtitle
                aboutdbDict.openingTime = aboutDetailDict.openingTime

                aboutdbDict.mobileLatitude = aboutDetailDict.mobileLatitude
                aboutdbDict.tourGuideAvailability = aboutDetailDict.tourGuideAvailability
                
                
                if((aboutDetailDict.mobileDescription?.count)! > 0) {
                    for i in 0 ... (aboutDetailDict.mobileDescription?.count)!-1 {
                        var aboutDescEntity: AboutDescriptionEntity!
                        let aboutDesc: AboutDescriptionEntity = NSEntityDescription.insertNewObject(forEntityName: "AboutDescriptionEntity", into: managedContext) as! AboutDescriptionEntity
                        aboutDesc.mobileDesc = aboutDetailDict.mobileDescription![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                        
                        aboutDescEntity = aboutDesc
                        aboutdbDict.addToMobileDescRelation(aboutDescEntity)

                        do {
                            try managedContext.save()
                            
                            
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                    }
                }
                
                //MultimediaFile
                if(aboutDetailDict.multimediaFile != nil){
                    if((aboutDetailDict.multimediaFile?.count)! > 0) {
                        for i in 0 ... (aboutDetailDict.multimediaFile?.count)!-1 {
                            var aboutImage: AboutMultimediaFileEntity!
                            let aboutImgaeArray: AboutMultimediaFileEntity = NSEntityDescription.insertNewObject(forEntityName: "AboutMultimediaFileEntity", into: managedContext) as! AboutMultimediaFileEntity
                            aboutImgaeArray.image = aboutDetailDict.multimediaFile![i]
                            
                            aboutImage = aboutImgaeArray
                            aboutdbDict.addToMultimediaRelation(aboutImage)
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
                let aboutDetailDict : Museum?
                aboutDetailDict = aboutDetailtArray[0]
                self.saveToCoreData(aboutDetailDict: aboutDetailDict!, managedObjContext: managedContext)
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "AboutEntityArabic", idKey:"id" , idValue: aboutDetailtArray[0].id, managedContext: managedContext) as! [AboutEntityArabic]
            if (fetchData.count > 0) {
                let aboutDetailDict = aboutDetailtArray[0]
                
                //update
                
                let aboutdbDict = fetchData[0]
                aboutdbDict.nameAr = aboutDetailDict.name
                aboutdbDict.id = aboutDetailDict.id
                aboutdbDict.tourguideAvailableAr = aboutDetailDict.tourguideAvailable
                aboutdbDict.contactNumberAr = aboutDetailDict.contactNumber
                aboutdbDict.contactEmailAr = aboutDetailDict.contactEmail
                aboutdbDict.mobileLongtitudeAr = aboutDetailDict.mobileLongtitude
                aboutdbDict.subtitleAr = aboutDetailDict.subtitle
                aboutdbDict.openingTimeAr = aboutDetailDict.openingTime

                aboutdbDict.mobileLatitudear = aboutDetailDict.mobileLatitude
                aboutdbDict.tourGuideAvlblyAr = aboutDetailDict.tourGuideAvailability
                
                
                if((aboutDetailDict.mobileDescription?.count)! > 0) {
                    for i in 0 ... (aboutDetailDict.mobileDescription?.count)!-1 {
                        var aboutDescEntity: AboutDescriptionEntityAr!
                        let aboutDesc: AboutDescriptionEntityAr = NSEntityDescription.insertNewObject(forEntityName: "AboutDescriptionEntityAr", into: managedContext) as! AboutDescriptionEntityAr
                        aboutDesc.mobileDesc = aboutDetailDict.mobileDescription![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                        
                        aboutDescEntity = aboutDesc
                        aboutdbDict.addToMobileDescRelation(aboutDescEntity)
                        
                        do {
                            try managedContext.save()
                            
                            
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                    }
                }
                
                //MultimediaFile
                if(aboutDetailDict.multimediaFile != nil){
                    if((aboutDetailDict.multimediaFile?.count)! > 0) {
                        for i in 0 ... (aboutDetailDict.multimediaFile?.count)!-1 {
                            var aboutImage: AboutMultimediaFileEntityAr!
                            let aboutImgaeArray: AboutMultimediaFileEntityAr = NSEntityDescription.insertNewObject(forEntityName: "AboutMultimediaFileEntityAr", into: managedContext) as! AboutMultimediaFileEntityAr
                            aboutImgaeArray.image = aboutDetailDict.multimediaFile![i]
                            
                            aboutImage = aboutImgaeArray
                            aboutdbDict.addToMultimediaRelation(aboutImage)
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
                let aboutDetailDict : Museum?
                aboutDetailDict = aboutDetailtArray[0]
                self.saveToCoreData(aboutDetailDict: aboutDetailDict!, managedObjContext: managedContext)
            }
        }
    }
    
    func saveToCoreData(aboutDetailDict: Museum, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let aboutdbDict: AboutEntity = NSEntityDescription.insertNewObject(forEntityName: "AboutEntity", into: managedObjContext) as! AboutEntity

            aboutdbDict.name = aboutDetailDict.name
            aboutdbDict.id = aboutDetailDict.id
            aboutdbDict.tourguideAvailable = aboutDetailDict.tourguideAvailable
            aboutdbDict.contactNumber = aboutDetailDict.contactNumber
            aboutdbDict.contactEmail = aboutDetailDict.contactEmail
            aboutdbDict.mobileLongtitude = aboutDetailDict.mobileLongtitude
            aboutdbDict.subtitle = aboutDetailDict.subtitle
            aboutdbDict.openingTime = aboutDetailDict.openingTime

            aboutdbDict.mobileLatitude = aboutDetailDict.mobileLatitude
            aboutdbDict.tourGuideAvailability = aboutDetailDict.tourGuideAvailability
            
            if((aboutDetailDict.mobileDescription?.count)! > 0) {
                for i in 0 ... (aboutDetailDict.mobileDescription?.count)!-1 {
                    var aboutDescEntity: AboutDescriptionEntity!
                    let aboutDesc: AboutDescriptionEntity = NSEntityDescription.insertNewObject(forEntityName: "AboutDescriptionEntity", into: managedObjContext) as! AboutDescriptionEntity
                    aboutDesc.mobileDesc = aboutDetailDict.mobileDescription![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                    
                    aboutDescEntity = aboutDesc
                    aboutdbDict.addToMobileDescRelation(aboutDescEntity)
                    
                    do {
                        try managedObjContext.save()
                        
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                }
            }
            
            //MultimediaFile
            if(aboutDetailDict.multimediaFile != nil){
                if((aboutDetailDict.multimediaFile?.count)! > 0) {
                    for i in 0 ... (aboutDetailDict.multimediaFile?.count)!-1 {
                        var aboutImage: AboutMultimediaFileEntity!
                        let aboutImgaeArray: AboutMultimediaFileEntity = NSEntityDescription.insertNewObject(forEntityName: "AboutMultimediaFileEntity", into: managedObjContext) as! AboutMultimediaFileEntity
                        aboutImgaeArray.image = aboutDetailDict.multimediaFile![i]
                        
                        aboutImage = aboutImgaeArray
                        aboutdbDict.addToMultimediaRelation(aboutImage)
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
            let aboutdbDict: AboutEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "AboutEntityArabic", into: managedObjContext) as! AboutEntityArabic
            

            aboutdbDict.nameAr = aboutDetailDict.name
            aboutdbDict.id = aboutDetailDict.id
            aboutdbDict.tourguideAvailableAr = aboutDetailDict.tourguideAvailable
            aboutdbDict.contactNumberAr = aboutDetailDict.contactNumber
            aboutdbDict.contactEmailAr = aboutDetailDict.contactEmail
            aboutdbDict.mobileLongtitudeAr = aboutDetailDict.mobileLongtitude
            aboutdbDict.subtitleAr = aboutDetailDict.subtitle
            aboutdbDict.openingTimeAr = aboutDetailDict.openingTime

            aboutdbDict.mobileLatitudear = aboutDetailDict.mobileLatitude
            aboutdbDict.tourGuideAvlblyAr = aboutDetailDict.tourGuideAvailability
            
            if((aboutDetailDict.mobileDescription?.count)! > 0) {
                for i in 0 ... (aboutDetailDict.mobileDescription?.count)!-1 {
                    var aboutDescEntity: AboutDescriptionEntityAr!
                    let aboutDesc: AboutDescriptionEntityAr = NSEntityDescription.insertNewObject(forEntityName: "AboutDescriptionEntityAr", into: managedObjContext) as! AboutDescriptionEntityAr
                    aboutDesc.mobileDesc = aboutDetailDict.mobileDescription![i].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                    
                    aboutDescEntity = aboutDesc
                    aboutdbDict.addToMobileDescRelation(aboutDescEntity)
                    
                    do {
                        try managedObjContext.save()
                        
                        
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                }
            }
            
            //MultimediaFile
            if(aboutDetailDict.multimediaFile != nil){
                if((aboutDetailDict.multimediaFile?.count)! > 0) {
                    for i in 0 ... (aboutDetailDict.multimediaFile?.count)!-1 {
                        var aboutImage: AboutMultimediaFileEntityAr!
                        let aboutImgaeArray: AboutMultimediaFileEntityAr = NSEntityDescription.insertNewObject(forEntityName: "AboutMultimediaFileEntityAr", into: managedObjContext) as! AboutMultimediaFileEntityAr
                        aboutImgaeArray.image = aboutDetailDict.multimediaFile![i]
                        
                        aboutImage = aboutImgaeArray
                        aboutdbDict.addToMultimediaRelation(aboutImage)
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
    
    func fetchAboutDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var aboutArray = [AboutEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "AboutEntity")
                
                if(museumId != nil) {
                    //fetchRequest.predicate = NSPredicate.init(format: "id == \(museumId!)")
                    fetchRequest.predicate = NSPredicate(format: "id == %@", museumId!)
                    aboutArray = (try managedContext.fetch(fetchRequest) as? [AboutEntity])!
                    
                    if (aboutArray.count > 0 ){
                        let aboutDict = aboutArray[0]
  
                        var descriptionArray : [String] = []
                        let aboutInfoArray = (aboutDict.mobileDescRelation?.allObjects) as! [AboutDescriptionEntity]
                        if(aboutInfoArray.count > 0) {
                            for i in 0 ... aboutInfoArray.count-1 {
                                descriptionArray.append(aboutInfoArray[i].mobileDesc!)
                            }
                        }
                        
                        var multimediaArray : [String] = []
                        let mutimediaInfoArray = (aboutDict.multimediaRelation?.allObjects) as! [AboutMultimediaFileEntity]
                        if(mutimediaInfoArray.count > 0) {
                            for i in 0 ... mutimediaInfoArray.count-1 {
                                multimediaArray.append(mutimediaInfoArray[i].image!)
                            }
                        }
                        
                        
                        self.aboutDetailtArray.insert(Museum(name: aboutDict.name, id: aboutDict.id, tourguideAvailable: aboutDict.tourguideAvailable, contactNumber: aboutDict.contactNumber, contactEmail: aboutDict.contactEmail, mobileLongtitude: aboutDict.mobileLongtitude, subtitle: aboutDict.subtitle, openingTime: aboutDict.openingTime, mobileDescription: descriptionArray, multimediaFile: multimediaArray, mobileLatitude: aboutDict.mobileLatitude, tourGuideAvailability: aboutDict.tourGuideAvailability,multimediaVideo: nil,downloadable:nil),at: 0)
                       
                        
                        if(aboutDetailtArray.count == 0){
                            self.showNoNetwork()
                        }
                        self.setTopBarImage()
                        heritageDetailTableView.reloadData()
                    }
                    else{
                        self.showNoNetwork()
                    }
                }

            }
            else {
                var aboutArray = [AboutEntityArabic]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "AboutEntityArabic")
                if(museumId != nil) {
                    fetchRequest.predicate = NSPredicate.init(format: "id == \(museumId!)")
                    aboutArray = (try managedContext.fetch(fetchRequest) as? [AboutEntityArabic])!
                    
                    if (aboutArray.count > 0) {
                        let aboutDict = aboutArray[0]
                        var descriptionArray : [String] = []
                        let aboutInfoArray = (aboutDict.mobileDescRelation?.allObjects) as! [AboutDescriptionEntityAr]
                        if(aboutInfoArray.count > 0) {
                            for i in 0 ... aboutInfoArray.count-1 {
                                descriptionArray.append(aboutInfoArray[i].mobileDesc!)
                            }
                        }
                        
                        
                        
                        var multimediaArray : [String] = []
                        let mutimediaInfoArray = (aboutDict.multimediaRelation?.allObjects) as! [AboutMultimediaFileEntity]
                        if(mutimediaInfoArray.count > 0) {
                            for i in 0 ... mutimediaInfoArray.count-1 {
                                multimediaArray.append(mutimediaInfoArray[i].image!)
                            }
                        }
                        self.aboutDetailtArray.insert(Museum(name: aboutDict.nameAr, id: aboutDict.id, tourguideAvailable: aboutDict.tourguideAvailableAr, contactNumber: aboutDict.contactNumberAr, contactEmail: aboutDict.contactEmailAr, mobileLongtitude: aboutDict.mobileLongtitudeAr, subtitle: aboutDict.subtitleAr, openingTime: aboutDict.openingTimeAr, mobileDescription: descriptionArray, multimediaFile: multimediaArray, mobileLatitude: aboutDict.mobileLatitudear, tourGuideAvailability: aboutDict.tourGuideAvlblyAr,multimediaVideo: nil,downloadable:nil),at: 0)
                        if(aboutDetailtArray.count == 0){
                            self.showNoNetwork()
                        }
                        self.setTopBarImage()
                        heritageDetailTableView.reloadData()
                    }
                    else{
                        self.showNoNetwork()
                    }
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
            if ((pageNameString == PageName.heritageDetail) && (heritageDetailId != nil)) {
                self.getHeritageDetailsFromServer()
            } else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailId != nil)) {
                self.getPublicArtsDetailsFromServer()
            } else if (pageNameString == PageName.museumAbout) {
                self.getAboutDetailsFromServer()
            }
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
