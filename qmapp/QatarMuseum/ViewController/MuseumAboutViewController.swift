//
//  MuseumAboutViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 01/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//



import Alamofire
import AVFoundation
import AVKit
import CoreData
import Firebase
import  MapKit
import UIKit
enum PageName2{
    case heritageDetail
    case publicArtsDetail
    case museumAbout
    case museumEvent
    case museumTravel
}
class MuseumAboutViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, comingSoonPopUpProtocol,iCarouselDelegate,iCarouselDataSource,UIGestureRecognizerDelegate,LoadingViewProtocol {
    @IBOutlet weak var heritageDetailTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
   
    let imageView = UIImageView()
    let closeButton = UIButton()
    var blurView = UIVisualEffectView()
    var pageNameString : PageName2?
    var heritageDetailtArray: [Heritage] = []
    var publicArtsDetailtArray: [PublicArtsDetail] = []
    //var aboutDetailtArray: [MuseumAbout] = []
    var aboutDetailtArray : [Museum] = []
    var heritageDetailId : String? = nil
    var publicArtsDetailId : String? = nil
    let networkReachability = NetworkReachabilityManager()
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var museumId : String? = nil
   // var imgArray = NSArray()
    var carousel = iCarousel()
    var imgButton = UIButton()
    var transparentView = UIView()
    var selectedCell : MuseumAboutCell?
    var travelImage: String!
    var travelTitle: String!
    var aboutBannerId: String? = nil
    var travelDetail: HomeBanner?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIContents()
        if ((pageNameString == PageName2.heritageDetail) && (heritageDetailId != nil)) {
            if  (networkReachability?.isReachable)! {
                getHeritageDetailsFromServer()
            } else {
                self.fetchHeritageDetailsFromCoredata()
            }
        } else if ((pageNameString == PageName2.publicArtsDetail) && (publicArtsDetailId != nil)) {
            if  (networkReachability?.isReachable)! {
                getPublicArtsDetailsFromServer()
            } else {
                self.fetchPublicArtsDetailsFromCoredata()
            }
            
        } else if (pageNameString == PageName2.museumAbout) {
            if  (networkReachability?.isReachable)! {
                getAboutDetailsFromServer()
            } else {
                self.fetchAboutDetailsFromCoredata()
            }
        } else if (pageNameString == PageName2.museumEvent) {
             NotificationCenter.default.addObserver(self, selector: #selector(MuseumAboutViewController.receiveNmoqAboutNotification(notification:)), name: NSNotification.Name(nmoqAboutNotification), object: nil)
            self.fetchAboutDetailsFromCoredata()
            if  (networkReachability?.isReachable)! {
                DispatchQueue.global(qos: .background).async {
                    self.getNmoQAboutDetailsFromServer()
                }
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
        if (pageNameString == PageName2.heritageDetail) {
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
        } else if (pageNameString == PageName2.publicArtsDetail){
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
        } else if ((pageNameString == PageName2.museumAbout) || (pageNameString == PageName2.museumEvent)){
            
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
                if(imageView.image == nil) {
                     imageView.image = UIImage(named: "default_imageX2")
                }
            }
            else {
                imageView.image = nil
            }
            
        } else if (pageNameString == PageName2.museumTravel){
            if(travelDetail != nil) {
                if let imageUrl = travelDetail?.bannerLink {
                    imageView.kf.setImage(with: URL(string: imageUrl))
                }
                else {
                    imageView.image = UIImage(named: "default_imageX2")
                }
            } else {
                imageView.image = UIImage(named: "default_imageX2")
            }
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        
        if (pageNameString != PageName2.museumTravel) {
            imgButton.setTitle("", for: .normal)
            imgButton.setTitleColor(UIColor.blue, for: .normal)
            imgButton.frame = imageView.frame
            
            imgButton.addTarget(self, action: #selector(self.imgButtonPressed(sender:)), for: .touchUpInside)
            
            self.view.addSubview(imgButton)
        }
        
        
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
        if (pageNameString == PageName2.heritageDetail) {
            return heritageDetailtArray.count
        } else if (pageNameString == PageName2.publicArtsDetail){
            return publicArtsDetailtArray.count
        } else if ((pageNameString == PageName2.museumAbout) || (pageNameString == PageName2.museumEvent)){
            if(aboutDetailtArray.count > 0) {
                return aboutDetailtArray.count
                // return 1
            } else {
                return 0
            }
            
        } else  if (pageNameString == PageName2.museumTravel){
            return 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let heritageCell = tableView.dequeueReusableCell(withIdentifier: "heritageDetailCellId2", for: indexPath) as! MuseumAboutCell
        if (pageNameString == PageName2.heritageDetail) {
            heritageCell.setHeritageDetailData(heritageDetail: heritageDetailtArray[indexPath.row])
            heritageCell.midTitleDescriptionLabel.textAlignment = .center
        } else if(pageNameString == PageName2.publicArtsDetail){
            heritageCell.setPublicArtsDetailValues(publicArsDetail: publicArtsDetailtArray[indexPath.row])
        } else if(pageNameString == PageName2.museumAbout){
            heritageCell.setMuseumAboutCellData(aboutData: aboutDetailtArray[indexPath.row])
            // heritageCell.setMuseumAboutCellData(aboutData: aboutDetailtArray[0])
            if (isImgArrayAvailable()) {
                heritageCell.pageControl.isHidden = false
            } else {
                heritageCell.pageControl.isHidden = true
            }
        } else if(pageNameString == PageName2.museumEvent){
            heritageCell.videoOuterView.isHidden = true
            heritageCell.videoOuterViewHeight.constant = 0
            heritageCell.setNMoQAboutCellData(aboutData: aboutDetailtArray[indexPath.row])
            // heritageCell.setMuseumAboutCellData(aboutData: aboutDetailtArray[0])
            heritageCell.pageControl.isHidden = false
            heritageCell.downloadBtnTapAction = {
                () in
                self.downloadButtonAction()
            }
        } else if(pageNameString == PageName2.museumTravel){
            heritageCell.videoOuterView.isHidden = true
            heritageCell.selectionStyle = .none
            heritageCell.videoOuterViewHeight.constant = 0
            heritageCell.setNMoQTravelCellData(travelDetailData: travelDetail!)
            heritageCell.pageControl.isHidden = true
            heritageCell.claimOfferBtnTapAction = {
                () in
                self.claimOfferButtonAction(offerLink: self.travelDetail?.claimOffer)
            }
        }
        
        heritageCell.favBtnTapAction = {
            () in
           // self.setFavouritesAction(cellObj: heritageCell)
        }
        heritageCell.shareBtnTapAction = {
            () in
           // self.setShareAction(cellObj: heritageCell)
        }
        heritageCell.locationButtonTapAction = {
            () in
            self.loadLocationInMap(currentRow: indexPath.row)
        }
        heritageCell.loadMapView = {
            () in
            if (self.aboutDetailtArray[0].mobileLatitude != nil && self.aboutDetailtArray[0].mobileLatitude != "" && self.aboutDetailtArray[0].mobileLongtitude != nil && self.aboutDetailtArray[0].mobileLongtitude != "") {
                let latitudeString = (self.aboutDetailtArray[0].mobileLatitude)!
                let longitudeString = (self.aboutDetailtArray[0].mobileLongtitude)!
                var latitude : Double?
                var longitude : Double?
                if let lat : Double = Double(latitudeString) {
                    latitude = lat
                }
                if let long : Double = Double(longitudeString) {
                    longitude = long
                }
                
                let destinationLocation = CLLocationCoordinate2D(latitude: latitude!,
                                                                 longitude: longitude!)
                let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                self.loadLocationMap(currentRow: indexPath.row, destination: destinationMapItem)
            }
        }
        heritageCell.loadAboutVideo = {
            () in
            self.showVideoInAboutPage(currentRow: indexPath.row)
        }
        selectedCell = heritageCell
        loadingView.stopLoading()
        loadingView.isHidden = true
        return heritageCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
//    func setFavouritesAction(cellObj :HeritageDetailCell) {
//        if (cellObj.favoriteButton.tag == 0) {
//            cellObj.favoriteButton.tag = 1
//            cellObj.favoriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
//        } else {
//            cellObj.favoriteButton.tag = 0
//            cellObj.favoriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
//        }
//    }
    
//    func setShareAction(cellObj :HeritageDetailCell) {
//
//    }
    func loadLocationMap(currentRow: Int, destination: MKMapItem) {
        let detailStoryboard: UIStoryboard = UIStoryboard(name: "DetailPageStoryboard", bundle: nil)

        let mapDetailView = detailStoryboard.instantiateViewController(withIdentifier: "mapViewId") as! MapViewController
       // mapDetailView.aboutData = aboutDetailtArray[0]
        mapDetailView.latitudeString = aboutDetailtArray[0].mobileLatitude
        mapDetailView.longiudeString = aboutDetailtArray[0].mobileLongtitude
        mapDetailView.destination = destination
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(mapDetailView, animated: false, completion: nil)

    }
    func showVideoInAboutPage(currentRow: Int) {
        let aboutData = aboutDetailtArray[currentRow]
        if (aboutData.multimediaVideo != nil) {
            if((aboutData.multimediaVideo?.count)! > 0) {
                let urlString = aboutData.multimediaVideo![0]
                if (urlString != nil && urlString != "") {
                    let player = AVPlayer(url: URL(string: urlString)!)
                    //let player = AVPlayer(url: filePathURL)
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    
                    self.present(playerController, animated: true) {
                        player.play()
                    }
                }
            }
        } 
    }
    
    func loadLocationInMap(currentRow: Int) {
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        if ((pageNameString == PageName2.museumAbout) && (aboutDetailtArray[0].mobileLatitude != nil) && (aboutDetailtArray[0].mobileLongtitude != nil)) {
            latitudeString = (aboutDetailtArray[0].mobileLatitude)!
            longitudeString = (aboutDetailtArray[0].mobileLongtitude)!
        } else if ((pageNameString == PageName2.heritageDetail) && (heritageDetailtArray[currentRow].latitude != nil) && (heritageDetailtArray[currentRow].longitude != nil)) {
            latitudeString = heritageDetailtArray[currentRow].latitude!
            longitudeString = heritageDetailtArray[currentRow].longitude!
        }
        //else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailtArray[currentRow]. != nil) && (publicArtsDetailtArray[currentRow].longitude != nil))
        //        {
        //            latitudeString = publicArtsDetailtArray[currentRow].latitude
        //            longitudeString = publicArtsDetailtArray[currentRow].longitude
        //        }
        
        if latitudeString != nil && longitudeString != nil && latitudeString != "" && longitudeString != ""{
            if (pageNameString == PageName2.museumAbout) {
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
                let locationUrl = URL(string: "https://maps.google.com/?q=@\(latitude!),\(longitude!)")!
                UIApplication.shared.openURL(locationUrl)
            }
        } else {
            showLocationErrorPopup()
        }
    }
    func downloadButtonAction() {
       let downloadLink = aboutDetailtArray[0].downloadable
        if ((downloadLink?.count)! > 0) {
            if(downloadLink![0] != "") {
                if let downloadUrl = URL(string: downloadLink![0]) {
                    // show alert to choose app
                    if UIApplication.shared.canOpenURL(downloadUrl as URL) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(downloadUrl, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(downloadUrl)
                        }
                    }
                }
            }
        }
       
    }
    func claimOfferButtonAction(offerLink: String?) {
        
        if(offerLink != "") {
            if let offerUrl = URL(string: offerLink!) {
                // show alert to choose app
                if UIApplication.shared.canOpenURL(offerUrl as URL) {
//                    let storyBoardName : UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
//                    let webViewVc:WebViewController = storyBoardName.instantiateViewController(withIdentifier: "webViewId") as! WebViewController
//                    webViewVc.webViewUrl = offerUrl
//                    webViewVc.titleString = NSLocalizedString("WEBVIEW_TITLE", comment: "WEBVIEW_TITLE  in the Webview")
//                    self.present(webViewVc, animated: false, completion: nil)
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(offerUrl, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(offerUrl)
                    }
                }
            }
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
        imgButton.frame = imageView.frame
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
        selectedCell?.player.pause()
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
                                self.showNodata()
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                        }else{
                            self.showNodata()
                        }
                    }else{
                        self.showNodata()
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
                                self.showNodata()
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                            
                        }else{
                            self.showNodata()
                        }
                    }
                    else{
                        self.showNodata()
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
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
            } else {
                let publicArtsDetailDict : PublicArtsDetail?
                publicArtsDetailDict = publicArtsDetailtArray[0]
                self.saveToCoreData(publicArtseDetailDict: publicArtsDetailDict!, managedObjContext: managedContext)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "PublicArtsEntityArabic", idKey:"id" , idValue: publicArtsDetailtArray[0].id, managedContext: managedContext) as! [PublicArtsEntityArabic]
            if (fetchData.count > 0) {
                let publicArtsDetailDict = publicArtsDetailtArray[0]
                
                //update
                let publicArtsdbDict = fetchData[0]
                publicArtsdbDict.namearabic = publicArtsDetailDict.name
                publicArtsdbDict.descriptionarabic = publicArtsDetailDict.description
                publicArtsdbDict.shortdescriptionarabic = publicArtsDetailDict.shortdescription
                publicArtsdbDict.imagearabic = publicArtsDetailDict.image
                do{
                    try managedContext.save()
                }
                catch{
                    print(error)
                }
            } else {
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
        } else {
            let publicArtsInfo: PublicArtsEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsEntityArabic", into: managedObjContext) as! PublicArtsEntityArabic
            publicArtsInfo.id = publicArtseDetailDict.id
            publicArtsInfo.namearabic = publicArtseDetailDict.name
            publicArtsInfo.descriptionarabic = publicArtseDetailDict.description
            publicArtsInfo.shortdescriptionarabic = publicArtseDetailDict.shortdescription
            publicArtsInfo.imagearabic = publicArtseDetailDict.image
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
                                self.showNodata()
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                        } else {
                            self.showNodata()
                        }
                    } else {
                        self.showNodata()
                    }
                }
                
            } else {
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
                                self.showNodata()
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                        }
                        else{
                            self.showNodata()
                        }
                    }
                    else{
                        self.showNodata()
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: ABout Webservice
    func getAboutDetailsFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.LandingPageMuseums(["nid": museumId ?? 0])).responseObject { (response: DataResponse<Museums>) -> Void in
            switch response.result {
            case .success(let data):
                self.aboutDetailtArray = data.museum!
                self.setTopBarImage()
                self.saveOrUpdateAboutCoredata(aboutDetailtArray: data.museum)
                self.heritageDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if(self.aboutDetailtArray.count != 0) {
                    if(self.aboutDetailtArray[0].multimediaFile != nil) {
                        if((self.aboutDetailtArray[0].multimediaFile?.count)! > 0) {
                            self.carousel.reloadData()
                        }
                    }
                }
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
    //MARK: NMoQ ABoutEvent Webservice
    func getNmoQAboutDetailsFromServer() {
        if(museumId != nil) {
            
            _ = Alamofire.request(QatarMuseumRouter.GetNMoQAboutEvent(["nid": museumId!])).responseObject { (response: DataResponse<Museums>) -> Void in
            switch response.result {
            case .success(let data):
                self.saveOrUpdateAboutCoredata(aboutDetailtArray: data.museum)
            case .failure( _):
                print("error")
            }
        }
    }
    }
    //MARK: About CoreData
    func saveOrUpdateAboutCoredata(aboutDetailtArray:[Museum]?) {
        if ((aboutDetailtArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.aboutCoreDataInBackgroundThread(managedContext: managedContext, aboutDetailtArray: aboutDetailtArray)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.aboutCoreDataInBackgroundThread(managedContext : managedContext, aboutDetailtArray: aboutDetailtArray)
                }
            }
        }
    }
    

    func aboutCoreDataInBackgroundThread(managedContext: NSManagedObjectContext,aboutDetailtArray:[Museum]?) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "AboutEntity", idKey: "id" , idValue: aboutDetailtArray![0].id, managedContext: managedContext) as! [AboutEntity]
            
            if (fetchData.count > 0) {
                let aboutDetailDict = aboutDetailtArray![0]
                let isDeleted = self.deleteExistingEvent(managedContext: managedContext, entityName: "AboutEntity")
                if(isDeleted == true) {
                   // self.saveToCoreData(educationEventDict: educationDict, dateId: dateID, managedObjContext: managedContext)
                    self.saveToCoreData(aboutDetailDict: aboutDetailDict, managedObjContext: managedContext)
                }
               
            } else {
                let aboutDetailDict : Museum?
                aboutDetailDict = aboutDetailtArray?[0]
                self.saveToCoreData(aboutDetailDict: aboutDetailDict!, managedObjContext: managedContext)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "AboutEntityArabic", idKey:"id" , idValue: aboutDetailtArray![0].id, managedContext: managedContext) as! [AboutEntityArabic]
            if (fetchData.count > 0) {
                let aboutDetailDict = aboutDetailtArray![0]
                let isDeleted = self.deleteExistingEvent(managedContext: managedContext, entityName: "AboutEntityArabic")
                if(isDeleted == true) {
                    self.saveToCoreData(aboutDetailDict: aboutDetailDict, managedObjContext: managedContext)
                }
                
            } else {
                let aboutDetailDict : Museum?
                aboutDetailDict = aboutDetailtArray?[0]
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
                    aboutDesc.id = Int16(i)
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
            //Download File
            if(aboutDetailDict.downloadable != nil){
                if((aboutDetailDict.downloadable?.count)! > 0) {
                    for i in 0 ... (aboutDetailDict.downloadable?.count)!-1 {
                        var aboutImage: AboutDownloadLinkEntity
                        let aboutImgaeArray: AboutDownloadLinkEntity = NSEntityDescription.insertNewObject(forEntityName: "AboutDownloadLinkEntity", into: managedObjContext) as! AboutDownloadLinkEntity
                        aboutImgaeArray.downloadLink = aboutDetailDict.downloadable![i]
                        
                        aboutImage = aboutImgaeArray
                        aboutdbDict.addToDownloadLinkRelation(aboutImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        } else {
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
                    aboutDesc.id = Int16(i)
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
    func deleteExistingEvent(managedContext:NSManagedObjectContext,entityName : String?) ->Bool? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName!)
        //fetchRequest.predicate = NSPredicate.init(format: "\("dateId") == \(dateID!)")
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
            return true
        }catch let error as NSError {
            //handle error here
            return false
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
                                descriptionArray.append("")
                            }
                            for i in 0 ... aboutInfoArray.count-1 {
                                descriptionArray.remove(at: Int(aboutInfoArray[i].id))
                        descriptionArray.insert(aboutInfoArray[i].mobileDesc!, at: Int(aboutInfoArray[i].id))
                                
                            }

                        }
                        var multimediaArray : [String] = []
                        let mutimediaInfoArray = (aboutDict.multimediaRelation?.allObjects) as! [AboutMultimediaFileEntity]
                        if(mutimediaInfoArray.count > 0) {
                            for i in 0 ... mutimediaInfoArray.count-1 {
                                multimediaArray.append(mutimediaInfoArray[i].image!)
                            }
                        }
                        
                        var downloadArray : [String] = []
                        let downloadInfoArray = (aboutDict.downloadLinkRelation?.allObjects) as! [AboutDownloadLinkEntity]
                        if(downloadInfoArray.count > 0) {
                            for i in 0 ... downloadInfoArray.count-1 {
                                downloadArray.append(downloadInfoArray[i].downloadLink!)
                            }
                        }
                        self.aboutDetailtArray.insert(Museum(name: aboutDict.name, id: aboutDict.id, tourguideAvailable: aboutDict.tourguideAvailable, contactNumber: aboutDict.contactNumber, contactEmail: aboutDict.contactEmail, mobileLongtitude: aboutDict.mobileLongtitude, subtitle: aboutDict.subtitle, openingTime: aboutDict.openingTime, mobileDescription: descriptionArray, multimediaFile: multimediaArray, mobileLatitude: aboutDict.mobileLatitude, tourGuideAvailability: aboutDict.tourGuideAvailability,multimediaVideo: nil, downloadable:downloadArray),at: 0)
                        
                        
                        if(aboutDetailtArray.count == 0){
                            self.showNoNetwork()
                        }
                        self.setTopBarImage()
                        heritageDetailTableView.reloadData()
                    } else {
                        self.showNoNetwork()
                    }
                }
            } else {
                var aboutArray = [AboutEntityArabic]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "AboutEntityArabic")
                if(museumId != nil) {
                    fetchRequest.predicate = NSPredicate.init(format: "id == \(museumId!)")
                    aboutArray = (try managedContext.fetch(fetchRequest) as? [AboutEntityArabic])!
                    
                    if (aboutArray.count > 0) {
                        let aboutDict = aboutArray[0]
                        var descriptionArray : [String] = []
                        let aboutInfoArray = (aboutDict.mobileDescRelation?.allObjects) as! [AboutDescriptionEntityAr]
                        if(aboutInfoArray.count > 0){
                            for i in 0 ... aboutInfoArray.count-1 {
                                descriptionArray.append("")
                            }
                            for i in 0 ... aboutInfoArray.count-1 {
                                //descriptionArray.append(aboutInfoArray[i].mobileDesc!)
                                descriptionArray.insert(aboutInfoArray[i].mobileDesc!, at: Int(aboutInfoArray[i].id))
                            }
                        }
                        var multimediaArray : [String] = []
                        let mutimediaInfoArray = (aboutDict.multimediaRelation?.allObjects) as! [AboutMultimediaFileEntity]
                        if(mutimediaInfoArray.count > 0){
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
    
    //MARK: iCarousel Delegate
    func numberOfItems(in carousel: iCarousel) -> Int {
        if(self.aboutDetailtArray.count != 0) {
            if(self.aboutDetailtArray[0].multimediaFile != nil) {
                if((self.aboutDetailtArray[0].multimediaFile?.count)! > 0) {
                    return (self.aboutDetailtArray[0].multimediaFile?.count)!
                }
            }
        }
        return 0
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIImageView
        itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: carousel.frame.width, height: 300))
        itemView.contentMode = .scaleAspectFit
        let carouselImg = self.aboutDetailtArray[0].multimediaFile
        let imageUrl = carouselImg![index]
        if(imageUrl != nil){
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
    
    @objc func imgButtonPressed(sender: UIButton!) {
        if((imageView.image != nil) && (imageView.image != UIImage(named: "default_imageX2"))) {
            setiCarouselView()
        }
    }
    
    func isImgArrayAvailable() -> Bool {
        if(self.aboutDetailtArray.count != 0) {
            if(self.aboutDetailtArray[0].multimediaFile != nil) {
                if((self.aboutDetailtArray[0].multimediaFile?.count)! > 0) {
                    return true
                }
            }
        }
        return false
    }
    
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            self.getAboutDetailsFromServer()
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
    @objc func receiveNmoqAboutNotification(notification: NSNotification) {
        if (pageNameString == PageName2.museumEvent) {
            self.fetchAboutDetailsFromCoredata()
        }
    }
    
    
    
}
