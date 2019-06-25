//
//  CommonDetailViewController.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 21/06/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//




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
class CommonDetailViewController: UIViewController {
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
        print(publicArtsDetailId)
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
            
            print("Error in calling phone ...")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:- ReusableView methods
extension CommonDetailViewController: comingSoonPopUpProtocol,LoadingViewProtocol {
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
}

//MARK:- Notification methods
extension CommonDetailViewController {
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
}
