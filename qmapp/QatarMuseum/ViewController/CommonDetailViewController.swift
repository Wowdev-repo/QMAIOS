//
//  CommonDetailViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 21/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CocoaLumberjack
import CoreData
import Firebase
import MessageUI
import UIKit

enum PageName{
    case heritageDetail
    case publicArtsDetail
    case exhibitionDetail
    case SideMenuPark
    case NMoQPark
    case DiningDetail
}
class CommonDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, comingSoonPopUpProtocol,LoadingViewProtocol, iCarouselDelegate,iCarouselDataSource,MFMailComposeViewControllerDelegate {
    @IBOutlet weak var heritageDetailTableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    
    let imageView = UIImageView()
    let closeButton = UIButton()
    var blurView = UIVisualEffectView()
    var pageNameString : PageName?
    var heritageDetailtArray: [Heritage] = []
    var publicArtsDetailtArray: [PublicArtsDetail] = []
    var exhibition: [Exhibition] = []
    var parksListArray: [ParksList]! = []
    var nmoqParkDetailArray: [NMoQParkDetail]! = []
    var diningDetailtArray: [Dining] = []
    var diningDetailId : String? = nil
    var heritageDetailId : String? = nil
    var publicArtsDetailId : String? = nil
    let networkReachability = NetworkReachabilityManager()
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var museumId : String? = nil
    var carousel = iCarousel()
    var transparentView = UIView()
    var fromHome : Bool = false
    var exhibitionId : String? = nil
    var parkDetailId: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        setupUIContents()
        registerCells()
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
        } else if (pageNameString == PageName.exhibitionDetail) {
            if (fromHome == true) {
                if  (networkReachability?.isReachable)! {
                    getExhibitionDetail()
                } else {
                    self.fetchExhibitionDetailsFromCoredata()
                }
            }
        } else if (pageNameString == PageName.SideMenuPark) {
            NotificationCenter.default.addObserver(self, selector: #selector(CommonDetailViewController.receiveParksNotificationEn(notification:)), name: NSNotification.Name(parksNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonDetailViewController.receiveParksNotificationAr(notification:)), name: NSNotification.Name(parksNotificationAr), object: nil)
            self.fetchParksFromCoredata()
        } else if (pageNameString == PageName.NMoQPark) {
            if  (networkReachability?.isReachable)! {
                getNMoQParkDetailFromServer()
            } else {
                //self.fetchNMoQParkDetailFromCoredata()
                self.showNoNetwork()
                addCloseButton()
            }
        } else if (pageNameString == PageName.DiningDetail) {
            if  (networkReachability?.isReachable)! {
                getDiningDetailsFromServer()
            } else {
                self.fetchDiningDetailsFromCoredata()
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), pageNameString: \(String(describing: pageNameString)), networkReachabil: \(String(describing: networkReachability?.isReachable))")
        recordScreenView()
    }
    
    func setupUIContents() {
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        setTopBarImage()
    }
    func registerCells() {
        self.heritageDetailTableView.register(UINib(nibName: "HeritageDetailView", bundle: nil), forCellReuseIdentifier: "heritageDetailCellId")
        self.heritageDetailTableView.register(UINib(nibName: "ExhibitionDetailView", bundle: nil), forCellReuseIdentifier: "exhibitionDetailCellId")
        self.heritageDetailTableView.register(UINib(nibName: "ParkTableCellXib", bundle: nil), forCellReuseIdentifier: "parkCellId")
        self.heritageDetailTableView.register(UINib(nibName: "CollectionDetailView", bundle: nil), forCellReuseIdentifier: "collectionCellId")
        self.heritageDetailTableView.register(UINib(nibName: "DiningDetailCellView", bundle: nil), forCellReuseIdentifier: "diningDetailCellId")
    }
    func setTopBarImage() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
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
        } else if (pageNameString == PageName.exhibitionDetail){
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
        } else if (pageNameString == PageName.SideMenuPark){
            if parksListArray.count != 0 {
                if let imageUrl = parksListArray[0].image{
                    imageView.kf.setImage(with: URL(string: imageUrl))
                }
                else {
                    imageView.image = UIImage(named: "default_imageX2")
                }
            }
            else {
                imageView.image = nil
            }
        } else if (pageNameString == PageName.NMoQPark){
            if nmoqParkDetailArray.count != 0 {
                if ( (self.nmoqParkDetailArray[0].images?.count)! > 0) {
                    if let imageUrl = nmoqParkDetailArray[0].images?[0]{
                        imageView.kf.setImage(with: URL(string: imageUrl))
                    }
                    else {
                        imageView.image = UIImage(named: "default_imageX2")
                    }
                }
                
            }
            else {
                imageView.image = nil
            }
        } else if (pageNameString == PageName.DiningDetail){
            if diningDetailtArray.count != 0 {
                if let imageUrl = diningDetailtArray[0].image{
                    imageView.kf.setImage(with: URL(string: imageUrl))
                } else if ( (self.diningDetailtArray[0].images?.count)! > 0) {
                    if let imageUrl = diningDetailtArray[0].images?[0]{
                        imageView.kf.setImage(with: URL(string: imageUrl))
                    }
                    else {
                        imageView.image = UIImage(named: "default_imageX2")
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
        addCloseButton()
    }
    func addCloseButton() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
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
        closeButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        closeButton.layer.shadowRadius = 5
        closeButton.layer.shadowOpacity = 1.0
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
        } else if (pageNameString == PageName.exhibitionDetail){
            if (fromHome == true) {
                return exhibition.count
            }
        } else if (pageNameString == PageName.SideMenuPark) {
            return parksListArray.count
        } else if (pageNameString == PageName.NMoQPark) {
            return nmoqParkDetailArray.count
        } else if (pageNameString == PageName.DiningDetail) {
            return diningDetailtArray.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadingView.stopLoading()
        loadingView.isHidden = true
        let heritageCell = tableView.dequeueReusableCell(withIdentifier: "heritageDetailCellId", for: indexPath) as! HeritageDetailCell
        if ((pageNameString == PageName.heritageDetail) || (pageNameString == PageName.publicArtsDetail)) {
            if (pageNameString == PageName.heritageDetail) {
                heritageCell.setHeritageDetailData(heritageDetail: heritageDetailtArray[indexPath.row])
                heritageCell.midTitleDescriptionLabel.textAlignment = .center
            } else if(pageNameString == PageName.publicArtsDetail){
                heritageCell.setPublicArtsDetailValues(publicArsDetail: publicArtsDetailtArray[indexPath.row])
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
            
        } else if(pageNameString == PageName.exhibitionDetail){
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
            cell.loadEmailComposer = {
                self.openEmail(email:"nmoq@qm.org.qa")
            }
            return cell
        } else if(pageNameString == PageName.SideMenuPark){
            let parkCell = tableView.dequeueReusableCell(withIdentifier: "parkCellId", for: indexPath) as! ParkTableViewCell
            if (indexPath.row != 0) {
                parkCell.titleLineView.isHidden = true
                parkCell.imageViewHeight.constant = 200
                
            }
            else {
                parkCell.titleLineView.isHidden = false
                parkCell.imageViewHeight.constant = 0
            }
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
            
            
            
            var latitudeString  = String()
            var longitudeString = String()
            var latitude : Double?
            var longitude : Double?
            if ((pageNameString == PageName.heritageDetail) && (heritageDetailtArray[indexPath.row].latitude != nil) && (heritageDetailtArray[indexPath.row].longitude != nil)) {
                latitudeString = heritageDetailtArray[indexPath.row].latitude!
                longitudeString = heritageDetailtArray[indexPath.row].longitude!
            }
            else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailtArray[indexPath.row].latitude != nil) && (publicArtsDetailtArray[indexPath.row].longitude != nil))
            {
                latitudeString = publicArtsDetailtArray[indexPath.row].latitude!
                longitudeString = publicArtsDetailtArray[indexPath.row].longitude!
            }
            else if (( pageNameString == PageName.exhibitionDetail) && ( self.fromHome == true) && (exhibition[indexPath.row].latitude != nil) && (exhibition[indexPath.row].longitude != nil)) {
                latitudeString = exhibition[indexPath.row].latitude!
                longitudeString = exhibition[indexPath.row].longitude!
            } else if ( pageNameString == PageName.SideMenuPark) {
                // showLocationErrorPopup()
            } else if (( pageNameString == PageName.DiningDetail) && (diningDetailtArray[indexPath.row].latitude != nil) && (diningDetailtArray[indexPath.row].longitude != nil)) {
                latitudeString = diningDetailtArray[indexPath.row].latitude!
                longitudeString = diningDetailtArray[indexPath.row].longitude!
            }
            if latitudeString != nil && longitudeString != nil && latitudeString != "" && longitudeString != ""{
                if ((pageNameString == PageName.publicArtsDetail) || (pageNameString == PageName.DiningDetail))  {
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
            }
            
            parkCell.setLocationOnMap(lat:latitude ?? 0.0,long:longitude ?? 0.0)
            
            
            
            
 
            
            
            return parkCell
        } else if(pageNameString == PageName.NMoQPark){
            let parkCell = tableView.dequeueReusableCell(withIdentifier: "parkCellId", for: indexPath) as! ParkTableViewCell
            parkCell.titleLineView.isHidden = false
            parkCell.imageViewHeight.constant = 0
            parkCell.setNmoqParkDetailValues(parkDetails: nmoqParkDetailArray[indexPath.row])
            
            
            var latitudeString  = String()
            var longitudeString = String()
            var latitude : Double?
            var longitude : Double?
            if ((pageNameString == PageName.heritageDetail) && (heritageDetailtArray[indexPath.row].latitude != nil) && (heritageDetailtArray[indexPath.row].longitude != nil)) {
                latitudeString = heritageDetailtArray[indexPath.row].latitude!
                longitudeString = heritageDetailtArray[indexPath.row].longitude!
            }
            else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailtArray[indexPath.row].latitude != nil) && (publicArtsDetailtArray[indexPath.row].longitude != nil))
            {
                latitudeString = publicArtsDetailtArray[indexPath.row].latitude!
                longitudeString = publicArtsDetailtArray[indexPath.row].longitude!
            }
            else if (( pageNameString == PageName.exhibitionDetail) && ( self.fromHome == true) && (exhibition[indexPath.row].latitude != nil) && (exhibition[indexPath.row].longitude != nil)) {
                latitudeString = exhibition[indexPath.row].latitude!
                longitudeString = exhibition[indexPath.row].longitude!
            } else if ( pageNameString == PageName.SideMenuPark) {
                // showLocationErrorPopup()
            } else if (( pageNameString == PageName.DiningDetail) && (diningDetailtArray[indexPath.row].latitude != nil) && (diningDetailtArray[indexPath.row].longitude != nil)) {
                latitudeString = diningDetailtArray[indexPath.row].latitude!
                longitudeString = diningDetailtArray[indexPath.row].longitude!
            }
            if latitudeString != nil && longitudeString != nil && latitudeString != "" && longitudeString != ""{
                if ((pageNameString == PageName.publicArtsDetail) || (pageNameString == PageName.DiningDetail))  {
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
            }
            
            parkCell.setLocationOnMap(lat:latitude ?? 0.0,long:longitude ?? 0.0)
            
            
            return parkCell
        } else if(pageNameString == PageName.DiningDetail){
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
            return diningCell
        }
        return heritageCell
    }
    
    func setFavouritesAction(cellObj :HeritageDetailCell) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
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
    func setFavouritesAction(cellObj :ExhibitionDetailTableViewCell) {
    }
    
    func setShareAction(cellObj :ExhibitionDetailTableViewCell) {
        
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
    func loadLocationInMap(currentRow: Int) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        var latitudeString  = String()
        var longitudeString = String()
        var latitude : Double?
        var longitude : Double?
            if ((pageNameString == PageName.heritageDetail) && (heritageDetailtArray[currentRow].latitude != nil) && (heritageDetailtArray[currentRow].longitude != nil)) {
            latitudeString = heritageDetailtArray[currentRow].latitude!
            longitudeString = heritageDetailtArray[currentRow].longitude!
        }
            else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailtArray[currentRow].latitude != nil) && (publicArtsDetailtArray[currentRow].longitude != nil))
        {
            latitudeString = publicArtsDetailtArray[currentRow].latitude!
            longitudeString = publicArtsDetailtArray[currentRow].longitude!
        }
            else if (( pageNameString == PageName.exhibitionDetail) && ( self.fromHome == true) && (exhibition[currentRow].latitude != nil) && (exhibition[currentRow].longitude != nil)) {
                latitudeString = exhibition[currentRow].latitude!
                longitudeString = exhibition[currentRow].longitude!
            } else if ( pageNameString == PageName.SideMenuPark) {
               // showLocationErrorPopup()
            } else if (( pageNameString == PageName.DiningDetail) && (diningDetailtArray[currentRow].latitude != nil) && (diningDetailtArray[currentRow].longitude != nil)) {
                latitudeString = diningDetailtArray[currentRow].latitude!
                longitudeString = diningDetailtArray[currentRow].longitude!
        }
        if latitudeString != nil && longitudeString != nil && latitudeString != "" && longitudeString != ""{
            if ((pageNameString == PageName.publicArtsDetail) || (pageNameString == PageName.DiningDetail))  {
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
            let mapDetailView = self.storyboard?.instantiateViewController(withIdentifier: "mapViewId") as! MapViewController
            mapDetailView.latitudeString = String(latitude ?? 0.0)
            mapDetailView.longiudeString = String(longitude ?? 0.0)
//            mapDetailView.destination = destination
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            self.present(mapDetailView, animated: false, completion: nil)
            
//            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
//                if #available(iOS 10.0, *) {
//                    UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(latitude!),\(longitude!)&zoom=14&views=traffic&q=\(latitude!),\(longitude!)")!, options: [:], completionHandler: nil)
//                } else {
//                    UIApplication.shared.openURL(URL(string:"comgooglemaps://?center=\(latitude!),\(longitude!)&zoom=14&views=traffic&q=\(latitude!),\(longitude!)")!)
//                }
//            } else if ((latitude != nil) && (longitude != nil)) {
//                let locationUrl = URL(string: "https://maps.google.com/?q=\(latitude!),\(longitude!)")!
//                UIApplication.shared.openURL(locationUrl)
//            } else {
//                showLocationErrorPopup()
//            }
        } else {
            showLocationErrorPopup()
        }
    }
    
    func showLocationErrorPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
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
        } else if(isImgArrayAvailable()) {
            return (self.diningDetailtArray[0].images?.count)!
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
        } else if (pageNameString == PageName.DiningDetail) {
            carouselImg = self.diningDetailtArray[0].images
        }
        if (carouselImg != nil) {
            let imageUrl = carouselImg?[index]
            if(imageUrl != nil){
                itemView.kf.setImage(with: URL(string: imageUrl!))
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if((imageView.image != nil) && (imageView.image != UIImage(named: "default_imageX2"))) {
            if (isHeritageImgArrayAvailable() || isPublicArtImgArrayAvailable() || isImgArrayAvailable()) {
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.HeritageDetail(["nid": heritageDetailId!])).responseObject { (response: DataResponse<Heritages>) -> Void in
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetPublicArtsDetail(["nid": publicArtsDetailId!])).responseObject { (response: DataResponse<PublicArtsDetails>) -> Void in
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (heritageDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateHeritage(managedContext : managedContext,
                                               heritageListArray: self.heritageDetailtArray)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateHeritage(managedContext : managedContext,
                                               heritageListArray: self.heritageDetailtArray)
                }
            }
        }
    }
    
    
    func fetchHeritageDetailsFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            let heritageArray = DataManager.checkAddedToCoredata(entityName: "HeritageEntity",
                                                                 idKey: "listid",
                                                                 idValue: heritageDetailId,
                                                                 managedContext: managedContext) as! [HeritageEntity]
            
            if (heritageArray.count > 0) {
                let heritageDict = heritageArray[0]
                if((heritageDict.detailshortdescription != nil) && (heritageDict.detaillongdescription != nil) ) {
                    self.heritageDetailtArray.append(Heritage(entity: heritageDict))
                    
                    if(heritageDetailtArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    self.setTopBarImage()
                    heritageDetailTableView.reloadData()
                }else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            } else {
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.loadingView.showNoDataView()
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: PublicArts Coredata Method
    func saveOrUpdatePublicArtsCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (publicArtsDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updatePublicArtsDetailsEntity(managedContext: managedContext,
                                                              publicArtsListArray: self.publicArtsDetailtArray)                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updatePublicArtsDetailsEntity(managedContext: managedContext,
                                                              publicArtsListArray: self.publicArtsDetailtArray)
                }
            }
        }
    }
    
    func fetchPublicArtsDetailsFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
                var publicArtsArray = [PublicArtsEntity]()
                let publicArtsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "PublicArtsEntity")
                if(publicArtsDetailId != nil) {
                    publicArtsFetchRequest.predicate = NSPredicate.init(format: "id == \(publicArtsDetailId!)")
                    publicArtsArray = (try managedContext.fetch(publicArtsFetchRequest) as? [PublicArtsEntity])!
                    
                    if (publicArtsArray.count > 0) {
                        let publicArtsDict = publicArtsArray[0]
                        if((publicArtsDict.detaildescription != nil) && (publicArtsDict.shortdescription != nil) ) {
                            self.publicArtsDetailtArray.append(PublicArtsDetail(entity: publicArtsDict))
                            
                            if(publicArtsDetailtArray.count == 0){
                                if(self.networkReachability?.isReachable == false) {
                                    self.showNoNetwork()
                                } else {
                                    self.loadingView.showNoDataView()
                                }
                            }
                            self.setTopBarImage()
                            heritageDetailTableView.reloadData()
                        }else {
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
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: ExhibitionDetail Webservice call
    func getExhibitionDetail() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.ExhibitionDetail(["nid": exhibitionId!])).responseObject { (response: DataResponse<Exhibitions>) -> Void in
            switch response.result {
            case .success(let data):
                self.exhibition = data.exhibitions!
                self.setTopBarImage()
                self.saveOrUpdateExhibitionsCoredata()
                self.heritageDetailTableView.reloadData()
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if !self.exhibition.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateExhibitionsEntity(managedContext : managedContext,
                                                        exhibition: self.exhibition,
                                                        isHomeExhibition:"0")
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateExhibitionsEntity(managedContext: managedContext,
                                                        exhibition: self.exhibition,
                                                        isHomeExhibition: "0")
                }
            }
        }
    }
    
    func fetchExhibitionDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            
            let exhibitionArray = DataManager.checkAddedToCoredata(entityName: "ExhibitionsEntity",
                                                                   idKey: "id",
                                                                   idValue: self.exhibitionId,
                                                                   managedContext: managedContext) as! [ExhibitionsEntity]
           
                let exhibitionDict = exhibitionArray[0]
                if ((exhibitionArray.count > 0)
                    && (exhibitionDict.detailLongDesc != nil)
                    && (exhibitionDict.detailShortDesc != nil)) {
                    
                    self.exhibition.append(Exhibition(entity: exhibitionDict))
                    
                    if(self.exhibition.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    self.self.setTopBarImage()
                    self.heritageDetailTableView.reloadData()
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: Parks WebServiceCall
    func getParksDataFromServer()
    {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.ParksList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<ParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                if (self.parksListArray.count == 0) {
                    self.parksListArray = data.parkList
                    self.heritageDetailTableView.reloadData()
                    if(self.parksListArray.count == 0) {
                        self.addCloseButton()
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
                if (self.parksListArray.count > 0)  {
                    if let parkList = data.parkList {
                        self.saveOrUpdateParksCoredata(parksListArray: parkList)
                    }
                    
                        self.setTopBarImage()
                }
                
            case .failure( _):
                print("error")
                if(self.parksListArray.count == 0) {
                    self.addCloseButton()
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
    func saveOrUpdateParksCoredata(parksListArray: [ParksList] ) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if !parksListArray.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateParks(managedContext: managedContext,
                                                         parksListArray: parksListArray,
                                                         language: Utils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateParks(managedContext : managedContext,
                                                         parksListArray: parksListArray,
                                                         language: Utils.getLanguage())
                }
            }
        }
    }
    
    func fetchParksFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
                var parksArray = [ParksEntity]()
                let parksFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ParksEntity")
                parksArray = (try managedContext.fetch(parksFetchRequest) as? [ParksEntity])!
                
                if (parksArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getParksDataFromServer()
                        }
                    }
                    for entity in parksArray {
                        self.parksListArray.append(ParksList(title: entity.title,
                                                             description: entity.parksDescription,
                                                             sortId: entity.sortId,
                                                             image: entity.image,
                                                             language: entity.language))
                        
                    }
                    if(parksListArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    //if let imageUrl = parksListArray[0].image {
                    self.setTopBarImage()
//                    } else {
//                        imageView.image = UIImage(named: "default_imageX2")
//                    }
                    
                    heritageDetailTableView.reloadData()
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                        self.addCloseButton()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getParksDataFromServer()//coreDataMigratio  solution
                        self.addCloseButton()
                    }
                }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if(self.networkReachability?.isReachable == false) {
                self.showNoNetwork()
                self.addCloseButton()
            }
        }
    }
    //MARK : NMoQPark
    func getNMoQParkDetailFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (parkDetailId != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQPlaygroundDetail(LocalizationLanguage.currentAppleLanguage(), ["nid": parkDetailId!])).responseObject { (response: DataResponse<NMoQParksDetail>) -> Void in
                switch response.result {
                case .success(let data):
                    self.nmoqParkDetailArray = data.nmoqParksDetail
                    // self.saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: data.nmoqParksDetail)
                    self.heritageDetailTableView.reloadData()
//                    if(self.nmoqParkDetailArray.count > 0) {
//                        if ( (self.nmoqParkDetailArray[0].images?.count)! > 0) {
//                            if let imageUrl = self.nmoqParkDetailArray[0].images?[0] {
                    self.setTopBarImage()
//                            } else {
//                                self.imageView.image = UIImage(named: "default_imageX2")
//                            }
//
//                        }
//                    }
                    
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    if (self.nmoqParkDetailArray.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                    
                case .failure( _):
                    self.addCloseButton()
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
    //MARK: NMoq Playground Parks Detail Coredata Method
    func saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: [NMoQParkDetail]) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if !nmoqParkList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateNmoqParkDetail(nmoqParkList: nmoqParkList,
                                                                  managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateNmoqParkDetail(nmoqParkList: nmoqParkList,
                                                                  managedContext : managedContext)
                }
            }
        }
    }
    
    
    func fetchNMoQParkDetailFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
                var parkListArray = [NMoQParkDetailEntity]()
                parkListArray = DataManager.checkAddedToCoredata(entityName: "NMoQParkDetailEntity",
                                                     idKey: "nid",
                                                     idValue: parkDetailId,
                                                     managedContext: managedContext) as! [NMoQParkDetailEntity]
                if (parkListArray.count > 0) {
                    for parkListDict in parkListArray {
                        self.nmoqParkDetailArray.append(NMoQParkDetail(entity: parkListDict))
                    }
                    
                    if(nmoqParkDetailArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        if self.nmoqParkDetailArray.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParkDetailArray = self.nmoqParkDetailArray.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                       // if ( (self.nmoqParkDetailArray[0].images?.count)! > 0) {
                           // if let imageUrl = self.nmoqParkDetailArray[0].images?[0] {
                        self.setTopBarImage()
//                            } else {
//                                self.imageView.image = UIImage(named: "default_imageX2")
//                            }
                            
                        //}
                    }
                    heritageDetailTableView.reloadData()
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if(self.networkReachability?.isReachable == false) {
                self.showNoNetwork()
                self.addCloseButton()
            }
        }
    }
    //MARK: Dining WebServiceCall
    func getDiningDetailsFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetDiningDetail(["nid": diningDetailId!])).responseObject { (response: DataResponse<Dinings>) -> Void in
            switch response.result {
            case .success(let data):
                self.diningDetailtArray = data.dinings!
                self.setTopBarImage()
                self.saveOrUpdateDiningDetailCoredata()
                self.heritageDetailTableView.reloadData()
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
    //MARK: Dining Coredata Method
    func saveOrUpdateDiningDetailCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (diningDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.diningCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.diningCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    
    func diningCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
            let fetchData = DataManager.checkAddedToCoredata(entityName: "DiningEntity",
                                                             idKey: "id",
                                                             idValue: diningDetailtArray[0].id,
                                                             managedContext: managedContext) as! [DiningEntity]
        let diningDetailDict = diningDetailtArray[0]
            if (fetchData.count > 0) {
                let diningdbDict = fetchData[0]
                DataManager.saveToDiningCoreData(diningListDict: diningDetailDict,
                                                 managedObjContext: managedContext,
                                                 entity: diningdbDict,
                                                 language: Utils.getLanguage())
                
            } else {
                DataManager.saveToDiningCoreData(diningListDict: diningDetailDict,
                                                 managedObjContext: managedContext,
                                                 entity: nil,
                                                 language: Utils.getLanguage())
            }
    }
    
    func fetchDiningDetailsFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            let diningArray = DataManager.checkAddedToCoredata(entityName: "DiningEntity",
                                                           idKey: "id",
                                                           idValue: diningDetailId!,
                                                           managedContext: managedContext) as! [DiningEntity]
            
            let diningDict = diningArray[0]
            if ((diningArray.count > 0) && (diningDict.diningdescription != nil)) {
                
                self.diningDetailtArray.append(Dining(entity: diningDict))
                
                if diningDetailtArray.isEmpty {
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
                    self.loadingView.showNoDataView()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func setFavouritesAction(cellObj :DiningDetailTableViewCell) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if  (networkReachability?.isReachable)! {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if ((pageNameString == PageName.heritageDetail) && (heritageDetailId != nil)) {
                self.getHeritageDetailsFromServer()
            } else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailId != nil)) {
                self.getPublicArtsDetailsFromServer()
            } else if (pageNameString == PageName.exhibitionDetail) {
                self.getExhibitionDetail()
            } else if (pageNameString == PageName.SideMenuPark) {
                appDelegate?.getParksDataFromServer(lang: LocalizationLanguage.currentAppleLanguage())
            } else if (pageNameString == PageName.NMoQPark) {
                getNMoQParkDetailFromServer()
            } else if (pageNameString == PageName.DiningDetail) {
                self.getDiningDetailsFromServer()
            }
        }
    }
    func showNoNetwork() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    func recordScreenView() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let screenClass = String(describing: type(of: self))
        if (pageNameString == PageName.publicArtsDetail) {
            Analytics.setScreenName(PUBLICARTS_DETAIL, screenClass: screenClass)
        } else if (pageNameString == PageName.exhibitionDetail) {
            Analytics.setScreenName(EXHIBITION_DETAIL, screenClass: screenClass)
        } else if (pageNameString == PageName.SideMenuPark) {
            Analytics.setScreenName(PARKS_VC, screenClass: screenClass)
        } else if (pageNameString == PageName.NMoQPark) {
            Analytics.setScreenName(NMOQ_PARKS_DETAIL, screenClass: screenClass)
        }else if (pageNameString == PageName.DiningDetail) {
            Analytics.setScreenName(DINING_DETAIL, screenClass: screenClass)
        }else {
            Analytics.setScreenName(HERITAGE_DETAIL, screenClass: screenClass)
        }
    }
    @objc func receiveParksNotificationEn(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (parksListArray.count == 0)){
            self.fetchParksFromCoredata()
        } else if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (parksListArray.count == 0)){
            self.fetchParksFromCoredata()
        }
    }
    @objc func receiveParksNotificationAr(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (parksListArray.count == 0)){
            self.fetchParksFromCoredata()
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
        
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            print("You pressed OK")
        }
        sendMailErrorAlert.addAction(okAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
