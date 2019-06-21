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
import MessageUI
import UIKit
import CocoaLumberjack

enum PageName2{
    case museumAbout
    case museumEvent
    case museumTravel
}
class MuseumAboutViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, comingSoonPopUpProtocol,iCarouselDelegate,iCarouselDataSource,UIGestureRecognizerDelegate,LoadingViewProtocol,MFMailComposeViewControllerDelegate {
    @IBOutlet weak var heritageDetailTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
   
    let imageView = UIImageView()
    let closeButton = UIButton()
    var blurView = UIVisualEffectView()
    var pageNameString : PageName2?
    var aboutDetailtArray : [Museum] = []
    var heritageDetailId : String? = nil
    var publicArtsDetailId : String? = nil
    let networkReachability = NetworkReachabilityManager()
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var museumId : String? = nil
    var carousel = iCarousel()
    var imgButton = UIButton()
    var transparentView = UIView()
    var selectedCell : MuseumAboutCell?
    var travelImage: String!
    var travelTitle: String!
    var aboutBannerId: String? = nil
    var travelDetail: HomeBanner?

    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        
        setupUIContents()
        if (pageNameString == PageName2.museumAbout) {
            if  (networkReachability?.isReachable)! {
                getAboutDetailsFromServer()
            } else {
                self.fetchAboutDetailsFromCoredata()
            }
        } else if (pageNameString == PageName2.museumEvent) {
             NotificationCenter.default.addObserver(self, selector: #selector(MuseumAboutViewController.receiveNmoqAboutNotification(notification:)), name: NSNotification.Name(nmoqAboutNotification), object: nil)
            self.fetchAboutDetailsFromCoredata()
//            if  (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getNmoQAboutDetailsFromServer()
//                }
//            }
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        heritageDetailTableView.estimatedRowHeight = 50
        heritageDetailTableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0)
        
        imageView.frame = CGRect(x: 0, y:20, width: UIScreen.main.bounds.size.width, height: 300)
        imageView.image = UIImage(named: "default_imageX2")
        if ((pageNameString == PageName2.museumAbout) || (pageNameString == PageName2.museumEvent)){
            
            if (aboutDetailtArray.count > 0)  {
                if(aboutDetailtArray[0].multimediaFile != nil) {
                    if ((aboutDetailtArray[0].multimediaFile?.count)! > 0) {
                        let url = aboutDetailtArray[0].multimediaFile
                            imageView.kf.setImage(with: URL(string: url![0]))
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
        if ((pageNameString == PageName2.museumAbout) || (pageNameString == PageName2.museumEvent)){
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
        if(pageNameString == PageName2.museumAbout){
            heritageCell.setMuseumAboutCellData(aboutData: aboutDetailtArray[indexPath.row])
            // heritageCell.setMuseumAboutCellData(aboutData: aboutDetailtArray[0])
            if (isImgArrayAvailable()) {
                heritageCell.pageControl.isHidden = false
            } else {
                heritageCell.pageControl.isHidden = true
            }
            heritageCell.downloadBtnTapAction = {
                () in
                self.downloadButtonAction()
            }
            heritageCell.loadEmailComposer = {
                self.openEmail(email:self.aboutDetailtArray[indexPath.row].contactEmail ?? "info@mia.org.qa")
            }
            heritageCell.callPhone = {
                self.dialNumber(number: self.aboutDetailtArray[indexPath.row].contactNumber ?? "+974 4402 8202")
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
            heritageCell.loadEmailComposer = {
                self.openEmail(email:self.aboutDetailtArray[indexPath.row].contactEmail ?? "info@mia.org.qa")
            }
            heritageCell.callPhone = {
                self.dialNumber(number: self.aboutDetailtArray[indexPath.row].contactNumber ?? "+974 4402 8202")
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
            heritageCell.loadEmailComposer = {
                self.openEmail(email:self.travelDetail?.email ?? "info@mia.org.qa")
            }
            heritageCell.callPhone = {
                self.dialNumber(number: self.travelDetail?.contactNumber ?? "+974 4402 8202")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let mapDetailView = self.storyboard?.instantiateViewController(withIdentifier: "mapViewId") as! MapViewController
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let aboutData = aboutDetailtArray[currentRow]
        if (aboutData.multimediaVideo != nil) {
            if((aboutData.multimediaVideo?.count)! > 0) {
                let urlString = aboutData.multimediaVideo![0]
                if (urlString != "") {
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
        if ((pageNameString == PageName2.museumAbout) && (aboutDetailtArray[0].mobileLatitude != nil) && (aboutDetailtArray[0].mobileLongtitude != nil)) {
            latitudeString = (aboutDetailtArray[0].mobileLatitude)!
            longitudeString = (aboutDetailtArray[0].mobileLongtitude)!
        }
        //else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailtArray[currentRow]. != nil) && (publicArtsDetailtArray[currentRow].longitude != nil))
        //        {
        //            latitudeString = publicArtsDetailtArray[currentRow].latitude
        //            longitudeString = publicArtsDetailtArray[currentRow].longitude
        //        }
        
        if  latitudeString != "" && longitudeString != ""{
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_header_close,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
    //MARK: ABout Webservice
    func getAboutDetailsFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.LandingPageMuseums(["nid": museumId ?? 0])).responseObject { (response: DataResponse<Museums>) -> Void in
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if(museumId != nil) {
            
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQAboutEvent(LocalizationLanguage.currentAppleLanguage(),["nid": museumId!])).responseObject { (response: DataResponse<Museums>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.aboutDetailtArray.count == 0) {
                    self.aboutDetailtArray = data.museum!
                    self.heritageDetailTableView.reloadData()
                    if(self.aboutDetailtArray.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                }
                if(self.aboutDetailtArray.count > 0) {
                    self.saveOrUpdateAboutCoredata(aboutDetailtArray: data.museum)
                }
                
            case .failure( _):
                if(self.aboutDetailtArray.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
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
                container.performBackgroundTask() { managedContext in
                    DataManager.saveAboutDetails(managedContext: managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: false)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.saveAboutDetails(managedContext: managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: false)
                }
            }
        }
    }
    
    func fetchAboutDetailsFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let managedContext = getContext()
        do {
//            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var aboutArray = [AboutEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "AboutEntity")
                
                if(museumId != nil) {
                    //fetchRequest.predicate = NSPredicate.init(format: "id == \(museumId!)")
                    fetchRequest.predicate = NSPredicate(format: "id == %@", museumId!)
                    aboutArray = (try managedContext.fetch(fetchRequest) as? [AboutEntity])!
                    
                    if (aboutArray.count > 0 ){
                        if  (networkReachability?.isReachable)! {
                            DispatchQueue.global(qos: .background).async {
                                self.getNmoQAboutDetailsFromServer()
                            }
                        }
                        let aboutDict = aboutArray[0]
                        var descriptionArray = [String]()

                        if let aboutInfoArray = (aboutDict.mobileDescRelation?.allObjects) as? [AboutDescriptionEntity] {
                            for _ in aboutInfoArray {
                                descriptionArray.append("")
                            }
                            for info in aboutInfoArray {
                                descriptionArray.remove(at: Int(info.id))
                                if let mobileDesc = info.mobileDesc {
                                    descriptionArray.insert(mobileDesc, at: Int(info.id))
                                }
                            }
                        }
                        
                        var multimediaArray = [String]()
                        if let mutimediaInfoArray = (aboutDict.multimediaRelation?.allObjects) as? [AboutMultimediaFileEntity] {
                            for info in mutimediaInfoArray {
                                if let image = info.image {
                                    multimediaArray.append(image)
                                }
                            }
                        }
                        
                        var downloadArray : [String] = []
                        if let downloadInfoArray = (aboutDict.downloadLinkRelation?.allObjects) as? [AboutDownloadLinkEntity] {
                            for info in downloadInfoArray {
                                if let downloadLink = info.downloadLink {
                                    downloadArray.append(downloadLink)
                                }
                            }
                        }
                        
                        var nmoqTime: String?
                        var aboutTime: String? = nil
                        if(pageNameString == PageName2.museumAbout) {
                            aboutTime = aboutDict.openingTime!
                        } else if (pageNameString == PageName2.museumEvent){
                            nmoqTime = aboutDict.openingTime!
                        }
                        self.aboutDetailtArray.insert(Museum(name: aboutDict.name, id: aboutDict.id, tourguideAvailable: aboutDict.tourguideAvailable, contactNumber: aboutDict.contactNumber, contactEmail: aboutDict.contactEmail, mobileLongtitude: aboutDict.mobileLongtitude, subtitle: aboutDict.subtitle, openingTime: aboutTime, mobileDescription: descriptionArray, multimediaFile: multimediaArray, mobileLatitude: aboutDict.mobileLatitude, tourGuideAvailability: aboutDict.tourGuideAvailability,multimediaVideo: nil, downloadable:downloadArray,eventDate:nmoqTime),at: 0)
                        
                        
                        if(aboutDetailtArray.count == 0){
                            if(self.networkReachability?.isReachable == false) {
                                self.showNoNetwork()
                            } else {
                                self.loadingView.showNoDataView()
                            }
                        }
                        self.setTopBarImage()
                        heritageDetailTableView.reloadData()
                    } else {
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                           // self.loadingView.showNoDataView()
                            self.getNmoQAboutDetailsFromServer() //coreDataMigratio  solution
                        }
                    }
                }

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func showNodata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        var errorMessage: String
        errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                        comment: "Setting the content of the alert"))
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoDataView()
        self.loadingView.noDataLabel.text = errorMessage
    }
    
    
    //MARK: iCarousel Delegate
    func numberOfItems(in carousel: iCarousel) -> Int {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)" + "Carousel Item Count: \(aboutDetailtArray.count)")
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
        if(imageUrl != ""){
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        transparentView.removeFromSuperview()
        carousel.tag = 0
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museumabout_closecarousel,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
        carousel.removeFromSuperview()
    }
    
    @objc func imgButtonPressed(sender: UIButton!) {
        if((imageView.image != nil) && (imageView.image != UIImage(named: "default_imageX2"))) {
            setiCarouselView()
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museumabout_gallerypressed,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if  (networkReachability?.isReachable)! {
            self.getAboutDetailsFromServer()
        }
    }
    func showNoNetwork() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    func openEmail(email : String) {
        let mailComposeViewController = configuredMailComposeViewController(emailId:email)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museumabout_openemail,
            AnalyticsParameterItemName: email,
            AnalyticsParameterContentType: "cont"
            ])
    }
    func configuredMailComposeViewController(emailId:String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([emailId])
        mailComposerVC.setSubject("NMOQ Event:")
        mailComposerVC.setMessageBody("Greetings, Thanks for contacting NMOQ event support team", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            DDLogInfo("You pressed OK")
        }
        sendMailErrorAlert.addAction(okAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
        
    }

    func dialNumber(number : String) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let phoneNumber = number.replacingOccurrences(of: " ", with: "")
        
        if let url = URL(string: "tel://\(String(phoneNumber))"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
            
            DDLogError("Error in calling phone ...")
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museumabout_dialphone,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(MUSEUMS_ABOUT_VC, screenClass: screenClass)
    }
    
}
