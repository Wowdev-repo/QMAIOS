//
//  PreviewContainerViewController.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 03/10/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//



import Crashlytics
import Firebase
import UIKit


class PreviewContainerViewController: UIViewController,UIGestureRecognizerDelegate {
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pageViewOne: UIView!
    @IBOutlet weak var pageViewTwo: UIView!
    @IBOutlet weak var pageViewThree: UIView!
    @IBOutlet weak var pageViewFour: UIView!
    @IBOutlet weak var pageViewFive: UIView!
    @IBOutlet weak var pageImageViewOne: UIImageView!
    @IBOutlet weak var pageImageViewTwo: UIImageView!
    @IBOutlet weak var pageImageViewThree: UIImageView!
    @IBOutlet weak var pageImageViewFour: UIImageView!
    @IBOutlet weak var pageImageViewFive: UIImageView!
    @IBOutlet weak var viewOneLineOne: UIView!
    @IBOutlet weak var viewOneLineTwo: UIView!
    @IBOutlet weak var viewTwoLineOne: UIView!
    @IBOutlet weak var viewTwoLineTwo: UIView!
    @IBOutlet weak var viewThreeLineOne: UIView!
    @IBOutlet weak var viewThreeLineTwo: UIView!
    @IBOutlet weak var viewFourLineOne: UIView!
    @IBOutlet weak var viewFourLineTwo: UIView!
    @IBOutlet weak var viewFiveLineOne: UIView!
    @IBOutlet weak var viewFiveLineTwo: UIView!
    @IBOutlet weak var pageImageOneHeight: NSLayoutConstraint!
    @IBOutlet weak var pageImageOneWidth: NSLayoutConstraint!
    @IBOutlet weak var pageImageTwoHeight: NSLayoutConstraint!
    @IBOutlet weak var pageImageTwoWidth: NSLayoutConstraint!
    @IBOutlet weak var pageImageThreeHeight: NSLayoutConstraint!
    @IBOutlet weak var pageImageThreeWidth: NSLayoutConstraint!
    @IBOutlet weak var pageImageFourHeight: NSLayoutConstraint!
    @IBOutlet weak var pageImageFourWidth: NSLayoutConstraint!
    @IBOutlet weak var pageImageFiveHeight: NSLayoutConstraint!
    @IBOutlet weak var pageImageFiveWidth: NSLayoutConstraint!
    
    var pageViewController = UIPageViewController()
    var pageImages = NSArray()
    var currentPreviewItem = Int()
    let pageCount: Int? = 11
    var reloaded: Bool = false
    var tourGuideArray: [TourGuideFloorMap]! = []
    var countValue : Int? = 0
    var fromScienceTour : Bool = false
    var tourGuideId : String? = nil
    let networkReachability = NetworkReachabilityManager()
    var currentContentViewController: PreviewContentViewController!
    let appDelegate =  UIApplication.shared.delegate as? AppDelegate
    var museumId :String? = nil

    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        
        loadUI()
        self.recordScreenView()
    }
    
    func loadUI() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        fetchTourGuideFromCoredata()
        if (networkReachability?.isReachable)! {
            getTourGuideDataFromServerInBackgound()
        }
        
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
        headerView.headerViewDelegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func closeAudio() {
        if (currentContentViewController != nil) {
            currentContentViewController.stopAudio()
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_previewcontainer_stopaudio,
                AnalyticsParameterItemName: "",
                AnalyticsParameterContentType: "cont"
                ])
        }
    }
    
    func filterButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.closeAudio()
        if (tourGuideArray.count != 0) {
            let selectedItem = tourGuideArray[currentPreviewItem]
            if((selectedItem.artifactPosition != nil) && (selectedItem.artifactPosition != "") && (selectedItem.floorLevel != nil) && (selectedItem.floorLevel != "")) {
                let floorMapView =  self.storyboard?.instantiateViewController(withIdentifier: "floorMapId") as!FloorMapViewController
                
                floorMapView.selectedScienceTour = selectedItem.artifactPosition
                floorMapView.selectedScienceTourLevel = selectedItem.floorLevel
                floorMapView.selectednid = selectedItem.nid
//                if let imageUrl = selectedItem.image{
//                    if(imageUrl != "") {
//                        if let data = try? Data(contentsOf: URL(string: imageUrl)!) {
//                            let image: UIImage = UIImage(data: data)!
//                            floorMapView.selectedImageFromPreview = image
//                        }
//                    }
//                }
                
                if(fromScienceTour) {
                    floorMapView.fromTourString = fromTour.scienceTour
                } else {
                    floorMapView.fromTourString = fromTour.HighlightTour
                }
                let transition = CATransition()
                transition.duration = 0.9
                transition.type = "flip"
                transition.subtype = kCATransitionFromLeft
                view.window!.layer.add(transition, forKey: kCATransition)
                //floorMapView.modalTransitionStyle = .flipHorizontal
                self.present(floorMapView, animated: true, completion: nil)
            } else {
                self.view.hideAllToasts()
                let locationMissingMessage =  NSLocalizedString("LOCATION_MISSING_MESSAGE", comment: "LOCATION_MISSING_MESSAGE")
                self.view.makeToast(locationMissingMessage)
            }
            
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_previewcontainer_filter,
                AnalyticsParameterItemName: "",
                AnalyticsParameterContentType: "cont"
                ])
            
        } else {
            
        }
    }
    @objc func loadDetailPage(sender: UITapGestureRecognizer? = nil) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.performSegue(withIdentifier: "previewToObjectDetailSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(PREVIEW_CONTAINER_VC, screenClass: screenClass)
    }
}

//MARK:- ReusableViews methods
extension PreviewContainerViewController: HeaderViewProtocol, LoadingViewProtocol {
    //MARK: Header Delegate
    func headerCloseButtonPressed() {
        self.closeAudio()
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_header_close,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
        self.dismiss(animated: false, completion: nil)
    }
    
    func showNodata() {
        
    }
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if  (networkReachability?.isReachable)! {
            self.getTourGuideDataFromServer()
        }
    }
    
    func showNoNetwork() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    
    func showNoData() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoDataView()
    }
}

extension PreviewContainerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "previewToObjectDetailSegue") {
            let objectDetailView = segue.destination as! ObjectDetailViewController
            objectDetailView.detailArray.append(tourGuideArray[currentPreviewItem])
        }
    }
}
