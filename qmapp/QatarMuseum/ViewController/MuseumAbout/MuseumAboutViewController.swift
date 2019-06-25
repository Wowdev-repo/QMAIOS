//
//  MuseumAboutViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 01/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//




import AVFoundation
import AVKit

import Firebase
import  MapKit
import MessageUI
import UIKit


enum PageName2{
    case museumAbout
    case museumEvent
    case museumTravel
}
class MuseumAboutViewController: UIViewController,UIGestureRecognizerDelegate {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func receiveNmoqAboutNotification(notification: NSNotification) {
        if (pageNameString == PageName2.museumEvent) {
            self.fetchAboutDetailsFromCoredata()
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

//MARK:- ReusableView Methods
extension MuseumAboutViewController: comingSoonPopUpProtocol,LoadingViewProtocol {
    
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
}
