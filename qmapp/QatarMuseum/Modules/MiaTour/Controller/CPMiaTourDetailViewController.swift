//
//  CPMiaTourDetailViewController.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 17/07/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//

import Crashlytics
import Firebase
import Kingfisher
import UIKit


class CPMiaTourDetailViewController: UIViewController {
    @IBOutlet weak var tourGuideDescription: UITextView!
    @IBOutlet weak var startTourButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var headerView: CPCommonHeaderView!
    @IBOutlet weak var slideshowView: KASlideShow!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scienceTourTitle: UITextView!
    
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var overlayView: UIView!
    var slideshowImages : NSArray!
    var popupView : CPComingSoonPopUp = CPComingSoonPopUp()
    var i = 0
    var museumId :String? = nil
    var tourGuide: [CPTourGuide] = []
    var tourGuideDetail : CPTourGuide?
    var totalImgCount = Int()
    var sliderImgCount : Int? = 0
    var sliderImgArray = NSMutableArray()
    var titleString : String? = ""
    let networkReachability = NetworkReachabilityManager()
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        loadingView.isHidden = false
        loadingView.showLoading()
        setDetails()
        setupUI()
        setGradientLayer()
        self.recordScreenView()
    }

    func setupUI() {
        scienceTourTitle.font = UIFont.miatourGuideFont
        tourGuideDescription.font = UIFont.englishTitleFont
        startTourButton.titleLabel?.font = UIFont.startTourFont
        startTourButton.setTitle(NSLocalizedString("START_TOUR", comment: "START_TOUR in science tour page"), for: .normal)
        headerView.headerViewDelegate = self
        headerView.headerTitle.text = NSLocalizedString("MIA_TOUR_GUIDES_TITLE", comment: "MIA_TOUR_GUIDES_TITLE in the Mia tour guide page")
        
        if ((museumId == "66") || (museumId == "638")) {
            headerView.headerTitle.text = NSLocalizedString("NMOQ_TOUR_HEADER", comment: "NMoQ in the nmoq tour guide page")
            scienceTourTitle.font = UIFont.nmoqtourGuideFont
            
            
            if(UIDevice.current.screenType.rawValue == "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"){
                self.scienceTourTitle.textContainer.maximumNumberOfLines = 2
                scienceTourTitle.font = scienceTourTitle.font!.withSize(30)
            }
            
        }

       // slideshowView.imagesContentMode = .scaleAspectFill
        self.slideshowView.addImage(UIImage(named: "sliderPlaceholder"))
        if ((CPLocalizationLanguage.currentAppleLanguage()) == "en") {
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
       // self.scienceTourTitle.text = titleString?.uppercased()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func didTapPlayButton(_ sender: UIButton) {
        self.playButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_tourguide_play,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
        
        loadComingSoonPopup()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @IBAction func playButtonTouchDown(_ sender: UIButton) {
        self.playButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @IBAction func didTapStartTour(_ sender: UIButton) {
        self.startTourButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), tourGuideDetailID: \(String(describing: tourGuideDetail?.nid))")
        // self.performSegue(withIdentifier: "miaTourToPreviewSegue", sender: self)
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        let shortDetailsView =  self.storyboard?.instantiateViewController(withIdentifier: "previewContainerId") as! CPPreviewContainerViewController
        shortDetailsView.museumId = museumId ?? "0"
        shortDetailsView.tourGuideId = tourGuideDetail?.nid
        if ((tourGuideDetail?.nid == "12216") || (tourGuideDetail?.nid == "12226")) {
            shortDetailsView.fromScienceTour = true
            
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: tourGuideDetail?.title as Any,
            AnalyticsParameterItemName: "MIA Tour Guide Start",
            AnalyticsParameterContentType: "Tour Guide Selected"
            ])
            
            self.present(shortDetailsView, animated: false, completion: nil)
        } else {
            //if (tourGuideDetail?.nid == "12471") || (tourGuideDetail?.nid == "12916") {
            shortDetailsView.fromScienceTour = false
            
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: tourGuideDetail?.title as Any,
            AnalyticsParameterItemName: "NMoQ Audio Guide Start",
            AnalyticsParameterContentType: "Tour Guide Selected"
            ])
            
            self.present(shortDetailsView, animated: false, completion: nil)
        }
        
        
    }
    
    @IBAction func startTourButtonTouchDown(_ sender: UIButton) {
        self.startTourButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func setDetails () {
        loadingView.stopLoading()
        loadingView.isHidden = true
        if(tourGuideDetail != nil) {
            self.scienceTourTitle.text = tourGuideDetail?.title
            self.scienceTourTitle.textContainer.lineBreakMode = .byTruncatingTail;
            self.tourGuideDescription.text = tourGuideDetail?.tourGuideDescription
            self.setImageArray(tourGuideImgDict: tourGuideDetail)
        } else if((titleString != nil) && (titleString != "")){
            self.scienceTourTitle.text = titleString
            self.scienceTourTitle.textContainer.lineBreakMode = .byTruncatingTail;
        }
        self.tourGuideDescription.textContainer.lineBreakMode = .byTruncatingTail;
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    func setImageArray(tourGuideImgDict : CPTourGuide?) {
        self.sliderImgArray[0] = UIImage(named: "sliderPlaceholder")!
        self.sliderImgArray[1] = UIImage(named: "sliderPlaceholder")!
        self.sliderImgArray[2] = UIImage(named: "sliderPlaceholder")!
        if ((tourGuideImgDict?.multimediaFile?.count)! > 0) {
            for  var i in 0 ... (tourGuideImgDict?.multimediaFile?.count)!-1 {
                let imageUrlString = tourGuideImgDict?.multimediaFile![i]
                downloadImage(imageUrlString: imageUrlString)
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func downloadImage(imageUrlString : String?)  {
        if (imageUrlString != nil) {
            let imageUrl = URL(string: imageUrlString!)
            ImageDownloader.default.downloadImage(with: imageUrl!, options: [], progressBlock: nil) {
                (image, error, url, data) in
                if let image = image {
                    self.sliderImgCount = self.sliderImgCount!+1
                    self.sliderImgArray[self.sliderImgCount!-1] = image
                    self.setSlideShow(imgArray: self.sliderImgArray)
                    self.slideshowView.start()
                } else {
                    if(self.sliderImgCount == 0) {
                        self.sliderImgArray[0] = UIImage(named: "sliderPlaceholder")!
                    } else {
                        self.sliderImgArray[self.sliderImgCount!-1] = UIImage(named: "sliderPlaceholder")!
                    }
                    self.sliderImgCount = self.sliderImgCount!+1
                    self.setSlideShow(imgArray: self.sliderImgArray)
                    self.slideshowView.start()
                }
                DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
            }
        }
    }
    func setGradientLayer() {
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0 , 1.3]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.overlayView.layer.insertSublayer(gradient, at: 0)
        
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(MIA_TOUR_DETAIL, screenClass: screenClass)
    }
}

//MARK:- ReusableView methods
extension CPMiaTourDetailViewController: CPHeaderViewProtocol, CPComingSoonPopUpProtocol {
    //MARK: Poup Delegate
    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_header_close,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    func loadComingSoonPopup() {
        popupView  = CPComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadPopup()
        self.view.addSubview(popupView)
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    //MARK: Header delegate
    func headerCloseButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
        
    }
}

//MARK:- KASlideShow Methods
extension CPMiaTourDetailViewController: KASlideShowDelegate {
    func setSlideShow(imgArray : NSArray) {
        //sliderLoading.stopAnimating()
        // sliderLoading.isHidden = true
        
        //KASlideshow
        slideshowView.delegate = self
        slideshowView.delay = 0.5
        slideshowView.transitionDuration = 2.7
        slideshowView.transitionType = KASlideShowTransitionType.fade
        slideshowView.images = imgArray as! NSMutableArray
        slideshowView.add(KASlideShowGestureType.swipe)
        slideshowView.imagesContentMode = .scaleAspectFill
        slideshowView.start()
        if slideshowView.images.count > 0 {
            let dot = pageControl.subviews[0]
            dot.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        }
        
        pageControl.numberOfPages = imgArray.count
        pageControl.currentPage = Int(slideshowView.currentIndex)
        pageControl.addTarget(self, action: #selector(CPMiaTourDetailViewController.pageChanged), for: .valueChanged)
    }
    //KASlideShow delegate
    func kaSlideShowWillShowNext(_ slideshow: KASlideShow) {
        
    }
    
    func kaSlideShowWillShowPrevious(_ slideshow: KASlideShow) {
        
    }
    
    func kaSlideShowDidShowNext(_ slideshow: KASlideShow) {
        let currentIndex = Int(slideshowView.currentIndex)
        pageControl.currentPage = Int(slideshowView.currentIndex)
        customizePageControlDot(currentIndex: currentIndex)
    }
    
    func kaSlideShowDidShowPrevious(_ slideshow: KASlideShow) {
        let currentIndex = Int(slideshowView.currentIndex)
        pageControl.currentPage = Int(slideshowView.currentIndex)
        customizePageControlDot(currentIndex: currentIndex)
    }
    
    func customizePageControlDot(currentIndex: Int) {
        for i in 0...2 {
            if (i == currentIndex) {
                let dot = pageControl.subviews[i]
                for j in 0...2 {
                    let dot1 = pageControl.subviews[j]
                    dot1.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
                dot.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                break
            }
        }
    }
    @objc func pageChanged() {
        
    }
}

//MARK:- Segue controller
extension CPMiaTourDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "miaTourToPreviewSegue") {
            let previewPage = segue.destination as! CPPreviewContainerViewController
            previewPage.museumId = museumId ?? "0"
            previewPage.tourGuideId = tourGuideDetail?.nid
            if ((tourGuideDetail?.nid == "12216") || (tourGuideDetail?.nid == "12226")) {
                previewPage.fromScienceTour = true
            } else {
                previewPage.fromScienceTour = false
            }
        }
    }
}
