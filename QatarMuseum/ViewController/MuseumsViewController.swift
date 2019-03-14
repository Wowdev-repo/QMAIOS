//
//  MuseumsViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 23/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import Firebase
import Kingfisher
import UIKit
class MuseumsViewController: UIViewController,KASlideShowDelegate,TopBarProtocol,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,comingSoonPopUpProtocol {
    
    @IBOutlet weak var museumsTopbar: TopBarView!
    @IBOutlet weak var museumsSlideView: KASlideShow!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var museumsBottomCollectionView: UICollectionView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var museumTitle: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    
    var collectionViewImages : NSArray!
    var collectionViewNames : NSArray!
    var popUpView : ComingSoonPopUp = ComingSoonPopUp()
    var museumArray: [Museum] = []
    var museumId:String? = nil
    var museumTitleString:String? = nil
    var totalImgCount = Int()
    var sliderImgCount : Int? = 0
    var sliderImgArray = NSMutableArray()
    var apnDelegate : APNProtocol?
    var fromHomeBanner : Bool? = false
    var bannerId: String? = nil
    var bannerImageArray : [String]? = []
    let networkReachability = NetworkReachabilityManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.recordScreenView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupUI() {
        if (fromHomeBanner == false) {
            fetchMuseumLandingImagesFromCoredata()
        } else {
            self.setImageArray(imageArray: bannerImageArray)
        }
        museumsSlideView.imagesContentMode = .scaleAspectFill
        let aboutName = NSLocalizedString("ABOUT", comment: "ABOUT  in the Museum")
        let tourGuideName = NSLocalizedString("TOURGUIDE_LABEL", comment: "TOURGUIDE_LABEL  in the Museum page")
        let exhibitionsName = NSLocalizedString("EXHIBITIONS_LABEL", comment: "EXHIBITIONS_LABEL  in the Museum page")
        let collectionsName = NSLocalizedString("COLLECTIONS_TITLE", comment: "COLLECTIONS_TITLE  in the Museum page")
        let experienceName = NSLocalizedString("EXPERIENCE_TITLE", comment: "EXPERIENCE_TITLE  in the Museum page")
        let parkName = NSLocalizedString("PARKS_LABEL", comment: "PARKS_LABEL  in the Museum page")
        let diningName = NSLocalizedString("DINING_LABEL", comment: "DINING_LABEL  in the Museum page")
        let highlightTourName = NSLocalizedString("HIGHLIGHTS_TOUR", comment: "HIGHLIGHTS_TOUR  in the Museum page")
        let facilitiesName = NSLocalizedString("FACILITIES", comment: "FACILITIES  in the Museum page")
        let eventsName = NSLocalizedString("EVENTS_LABEL", comment: "EVENTS_LABEL  in the Museum page")
        
        museumsTopbar.topbarDelegate = self
        museumsTopbar.menuButton.isHidden = true
        museumsTopbar.backButton.isHidden = false
        museumTitle.text = museumTitleString
        museumTitle.font = UIFont.museumTitleFont
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            museumsTopbar.backButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
            previousButton.isHidden = true
            nextButton.isHidden = false
        } else {
            museumsTopbar.backButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
            previousButton.isHidden = false
            nextButton.isHidden = true
            previousButton.setImage(UIImage(named: "nextImg"), for: .normal)
        }
        if(fromHomeBanner)! {
            let aboutBanner = NSLocalizedString("ABOUT", comment: "ABOUT  in the Museum")
            let tourBanner = NSLocalizedString("TOURS", comment: "TOURS  in the Museum page")
            let travelBanner = NSLocalizedString("TRAVEL_ARRANGEMENTS", comment: "TRAVEL_ARRANGEMENTS  in the Museum page")
            let panelBanner = NSLocalizedString("PANEL_DISCUSSION", comment: "PANEL_DISCUSSION  in the Museum page")
            collectionViewImages = ["about-launchX1","tours-launchX1","travel-launchX1","discussion-launchX1"]
            collectionViewNames = [aboutBanner,tourBanner,travelBanner,panelBanner]
            previousButton.isHidden = true
            nextButton.isHidden = true
            museumsTopbar.eventButton.isHidden = true
            museumsTopbar.notificationButton.isHidden = true
            museumsTopbar.profileButton.isHidden = true
        } else {
            if ((museumId != nil) && ((museumId == "63") || (museumId == "96"))) {
                collectionViewImages = ["MIA_AboutX1","Audio CircleX1","exhibition_blackX1","collectionsX1","park_blackX1","diningX1",]
                collectionViewNames = [aboutName,tourGuideName,exhibitionsName,collectionsName,parkName,diningName]
            }else if ((museumId == "61") || (museumId == "635")) {
                collectionViewImages = ["MIA_AboutX1","Audio CircleX1","exhibition_blackX1","collectionsX1","diningX1",]
                collectionViewNames = [aboutName,tourGuideName,exhibitionsName,collectionsName,diningName]
            }else if ((museumId == "66") || (museumId == "638")) {
                collectionViewImages = ["about-launchX1","facilitiesX1","exhibition_blackX1","experienceX1","Audio CircleX1","events_BlackX1","park_blackX1"]
                collectionViewNames = [aboutName,facilitiesName,exhibitionsName,experienceName,highlightTourName,eventsName,parkName]
            } else {
                collectionViewImages = ["MIA_AboutX1","exhibition_blackX1","collectionsX1","diningX1",]
                collectionViewNames = [aboutName,exhibitionsName,collectionsName,diningName]
                previousButton.isHidden = true
                nextButton.isHidden = true
            }
        }
    }
    func setImageArray(imageArray: [String]?) {
        if ((imageArray?.count)! >= 4) {
            totalImgCount = 3
        } else if ((imageArray?.count)! > 1){
            totalImgCount = (imageArray?.count)!-1
        } else {
            totalImgCount = 0
        }
        if (totalImgCount > 0) {
            for  i in 1 ... totalImgCount {
                let imageUrlString = imageArray![i]
                downloadImage(imageUrlString: imageUrlString)
            }
        }
    }
    func downloadImage(imageUrlString : String?)  {
        if (imageUrlString != nil) {
            let imageUrl = URL(string: imageUrlString!)
            
            KingfisherManager.shared.retrieveImage(with: imageUrl!, options: [], progressBlock: nil, completionHandler: {  (image, error, cacheType, imageUrl) in
                if let image = image {
                    self.sliderImgCount = self.sliderImgCount!+1
                    self.sliderImgArray[self.sliderImgCount!-1] = image
                    self.setSlideShow(imgArray: self.sliderImgArray)
                    self.museumsSlideView.start()
                } else {
                    if(self.sliderImgCount == 0) {
                        self.sliderImgArray[0] = UIImage(named: "sliderPlaceholder")!
                    } else {
                        self.sliderImgArray[self.sliderImgCount!-1] = UIImage(named: "sliderPlaceholder")!
                    }
                    self.sliderImgCount = self.sliderImgCount!+1
                    self.setSlideShow(imgArray: self.sliderImgArray)
                    self.museumsSlideView.start()
                }
            })
            
        }
    }
    func setSlideShow(imgArray: NSArray) {
        //KASlideshow
        museumsSlideView.delegate = self
        museumsSlideView.delay = 0.5
        museumsSlideView.transitionDuration = 1.2
        museumsSlideView.transitionType = KASlideShowTransitionType.fade
        museumsSlideView.imagesContentMode = .scaleAspectFill
        museumsSlideView.images = imgArray as? NSMutableArray
        museumsSlideView.add(KASlideShowGestureType.swipe)
        museumsSlideView.start()
        pageControl.numberOfPages = imgArray.count
        if museumsSlideView.images.count > 0 {
            let dot = pageControl.subviews[0]
            dot.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        }
        
        pageControl.currentPage = Int(museumsSlideView.currentIndex)
        pageControl.addTarget(self, action: #selector(MuseumsViewController.pageChanged), for: .valueChanged)
    }
    func updateNotificationBadge() {
        museumsTopbar.updateNotificationBadgeCount()
    }
    
    //KASlideShow delegate
    
    func kaSlideShowDidShowNext(_ slideshow: KASlideShow) {
        let currentIndex = Int(museumsSlideView.currentIndex)
        pageControl.currentPage = Int(museumsSlideView.currentIndex)
        customizePageControlDot(currentIndex: currentIndex)
    }
    
    func kaSlideShowDidShowPrevious(_ slideshow: KASlideShow) {
        let currentIndex = Int(museumsSlideView.currentIndex)
        pageControl.currentPage = Int(museumsSlideView.currentIndex)
        customizePageControlDot(currentIndex: currentIndex)
    }
    
    func customizePageControlDot(currentIndex: Int) {
        for i in 0...pageControl.numberOfPages-1 {
            let dot = pageControl.subviews[i]
            if (i == currentIndex) {
                dot.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            } else {
                dot.transform = CGAffineTransform(scaleX: 1, y: 1)
                //  break
            }
        }
    }
    @objc func pageChanged() {
        
    }
    //MARK: Topbar delegate
    func backButtonPressed() {
        museumsSlideView.stop()
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.dismiss(animated: false, completion: nil)
        self.view.window!.layer.add(transition, forKey: kCATransition)
    }
    //MARK: CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let museumsCell : MuseumBottomCell = museumsBottomCollectionView.dequeueReusableCell(withReuseIdentifier: "museumCellId", for: indexPath) as! MuseumBottomCell
        museumsCell.itemButton.setImage(UIImage(named: collectionViewImages.object(at: indexPath.row) as! String), for: .normal)
        let itemName = collectionViewNames.object(at: indexPath.row) as? String
        museumsCell.itemName.text = collectionViewNames.object(at: indexPath.row) as? String
        if (fromHomeBanner)! {
            if((itemName == "About Event") || (itemName == "")) {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 9, bottom: 12, right: 9)
            } else if((itemName == "Tours") || (itemName == "")) {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 13, bottom: 15, right: 13)
            } else if((itemName == "Travel Arrangements") || (itemName == "")) {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 17, left: 14, bottom: 17, right: 14)
                let itemNameArray = itemName?.components(separatedBy: " ")
                if((itemNameArray?.count)! > 0) {
                    museumsCell.itemName.text = itemNameArray?[0]
                    museumsCell.itemNameSecondLine.text = itemNameArray?[1]
                }
            }
            else if(itemName == "Special Events")  {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            }
        } else {
            if((itemName == "About") && (museumId == "66") || (itemName == "عن") && (museumId == "638")) {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 8, bottom: 15, right: 6)
            }else if((itemName == "Tour Guide") || (itemName == "الدليل السياحي") || (itemName == "Highlights Tour")) {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 9, bottom: 10, right: 9)
            }
            else if((itemName == "Exhibitions") || (itemName == "المعارض")) {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 13, bottom: 12, right: 13)
            }
            else if((itemName == "Collections") || (itemName == "المجموعات")) {
                
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 19, left: 15, bottom: 19, right: 15)
                
            }
            else if ((itemName == "Parks") || (itemName == "الحدائق"))  {
                if((museumId == "66") || (museumId == "638")) {
                    museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 6)
                } else {
                    museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
                }
                
            }
            else if  ((itemName == "Dining") || (itemName == "العشاء") ) {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 18, left: 15, bottom: 18, right: 15)
            } else if   (itemName == "Facilities") {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            }
            else if(itemName == "Experience") {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
            } else if(itemName == "Events") {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
            }
        }
        
        if((museumId != nil) && ((museumId == "63") || (museumId == "96"))) {
            if (museumsBottomCollectionView.contentOffset.x <= 0.0) {
                if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                    previousButton.isHidden = true
                    nextButton.isHidden = false
                }
                else{
                    previousButton.isHidden = false
                    nextButton.isHidden = true
                    previousButton.setImage(UIImage(named: "nextImg"), for: .normal)
                    
                }
            }
            else {
                if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                    previousButton.isHidden = false
                    nextButton.isHidden = true
                    
                }
                else {
                    previousButton.isHidden = true
                    nextButton.isHidden = false
                    nextButton.setImage(UIImage(named: "previousImg"), for: .normal)
                }
            }
        }
        museumsCell.cellItemBtnTapAction = {
            () in
            self.loadBottomCellPages(cellObj: museumsCell, selectedItem: itemName )
        }
        return museumsCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: museumsBottomCollectionView.frame.width/4, height: 110)
    }
    func loadBottomCellPages(cellObj: MuseumBottomCell, selectedItem: String?) {
        
        if(fromHomeBanner)! {
            let aboutBanner = NSLocalizedString("ABOUT", comment: "ABOUT  in the Museum")
            let tourBanner = NSLocalizedString("TOURS", comment: "TOURS  in the Museum page")
            let travelBanner = NSLocalizedString("TRAVEL_ARRANGEMENTS", comment: "TRAVEL_ARRANGEMENTS  in the Museum page")
            let panelBanner = NSLocalizedString("PANEL_DISCUSSION", comment: "PANEL_DISCUSSION  in the Museum page")
            if (selectedItem == aboutBanner) {
                let detailStoryboard: UIStoryboard = UIStoryboard(name: "DetailPageStoryboard", bundle: nil)
                
                let heritageDtlView = detailStoryboard.instantiateViewController(withIdentifier: "heritageDetailViewId2") as! MuseumAboutViewController
                heritageDtlView.pageNameString = PageName2.museumEvent
                heritageDtlView.museumId = bannerId
                
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionFade
                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                view.window!.layer.add(transition, forKey: kCATransition)
                self.present(heritageDtlView, animated: false, completion: nil)
            } else if (selectedItem == tourBanner) {
                let tourView =  self.storyboard?.instantiateViewController(withIdentifier: "tourAndPanelId") as! TourAndPanelListViewController
                tourView.pageNameString = NMoQPageName.Tours
                let transition = CATransition()
                transition.duration = 0.25
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                self.present(tourView, animated: false, completion: nil)
                
            } else if (selectedItem == travelBanner) {
                let travelView =  self.storyboard?.instantiateViewController(withIdentifier: "tourAndPanelId") as! TourAndPanelListViewController
                travelView.bannerId = bannerId
                travelView.pageNameString = NMoQPageName.TravelArrangementList
                let transition = CATransition()
                transition.duration = 0.25
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                self.present(travelView, animated: false, completion: nil)
            }
            else if (selectedItem == panelBanner) {
                let panelView =  self.storyboard?.instantiateViewController(withIdentifier: "tourAndPanelId") as! TourAndPanelListViewController
                panelView.pageNameString = NMoQPageName.PanelDiscussion
                let transition = CATransition()
                transition.duration = 0.25
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                self.present(panelView, animated: false, completion: nil)
            }
        } else {
            if ((selectedItem == "About") || (selectedItem == "عن")) {
                let detailStoryboard: UIStoryboard = UIStoryboard(name: "DetailPageStoryboard", bundle: nil)
                let heritageDtlView = detailStoryboard.instantiateViewController(withIdentifier: "heritageDetailViewId2") as! MuseumAboutViewController
                heritageDtlView.pageNameString = PageName2.museumAbout
                heritageDtlView.museumId = museumId
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionFade
                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                view.window!.layer.add(transition, forKey: kCATransition)
                self.present(heritageDtlView, animated: false, completion: nil)
            } else if ((selectedItem == "Tour Guide") || (selectedItem == "الدليل السياحي")){
                if((museumId == "63") || (museumId == "96")) {
                    let tourGuideView =  self.storyboard?.instantiateViewController(withIdentifier: "miaTourGuideId") as! MiaTourGuideViewController
                    tourGuideView.museumId = museumId!
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    view.window!.layer.add(transition, forKey: kCATransition)
                    self.present(tourGuideView, animated: false, completion: nil)
                } else {
                    self.loadComingSoonPopup()
                }
                
            } else if ((selectedItem == "Exhibitions") || (selectedItem == "المعارض")){
                let exhibitionView = self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! ExhibitionsViewController
                exhibitionView.museumId = museumId
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                exhibitionView.exhibitionsPageNameString = ExhbitionPageName.museumExhibition
                self.present(exhibitionView, animated: false, completion: nil)
            } else if ((selectedItem == "Collections") || (selectedItem == "المجموعات")){
                let musmCollectionnView = self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! ExhibitionsViewController
                musmCollectionnView.museumId = museumId
                musmCollectionnView.exhibitionsPageNameString = ExhbitionPageName.museumCollectionsList
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                self.present(musmCollectionnView, animated: false, completion: nil)
            } else if ((selectedItem == "Parks") || (selectedItem == "الحدائق")){
                let parkView = self.storyboard?.instantiateViewController(withIdentifier: "parkViewId") as! ParksViewController
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionFade
                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                view.window!.layer.add(transition, forKey: kCATransition)
                self.present(parkView, animated: false, completion: nil)
            } else if((selectedItem == "Dining") || (selectedItem == "الطعام")) {
                let diningView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! ExhibitionsViewController
                diningView.museumId = museumId
                diningView.fromHome = false
                diningView.fromSideMenu = false
                diningView.exhibitionsPageNameString = ExhbitionPageName.diningList
                let transition = CATransition()
                transition.duration = 0.25
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                self.present(diningView, animated: false, completion: nil)
            }  else if(selectedItem == "Facilities") {
                loadComingSoonPopup()
//                let tourView =  self.storyboard?.instantiateViewController(withIdentifier: "tourAndPanelId") as! TourAndPanelListViewController
//                tourView.pageNameString = NMoQPageName.Facilities
//                let transition = CATransition()
//                transition.duration = 0.25
//                transition.type = kCATransitionPush
//                transition.subtype = kCATransitionFromRight
//                view.window!.layer.add(transition, forKey: kCATransition)
//                self.present(tourView, animated: false, completion: nil)
            }else {
                loadComingSoonPopup()
            }
        }
    }
    
    @IBAction func didTapPrevious(_ sender: UIButton) {
        
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let collectionBounds = self.museumsBottomCollectionView.bounds
            let contentOffset = CGFloat(floor(self.museumsBottomCollectionView.contentOffset.x - collectionBounds.size.width))
            self.moveCollectionToFrame(contentOffset: contentOffset)
            nextButton.isHidden = false
            previousButton.isHidden = true
        }
        else {
            self.museumsBottomCollectionView.isScrollEnabled = true
            let collectionBounds = self.museumsBottomCollectionView.bounds
            let contentOffset = CGFloat(floor(self.museumsBottomCollectionView.contentOffset.x + collectionBounds.size.width))
            self.moveCollectionToFrame(contentOffset: contentOffset)
            nextButton.isHidden = false
            previousButton.isHidden = true
        }
    }
    @IBAction func didTapNext(_ sender: UIButton) {
        
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            self.museumsBottomCollectionView.isScrollEnabled = true
            let collectionBounds = self.museumsBottomCollectionView.bounds
            let contentOffset = CGFloat(floor(self.museumsBottomCollectionView.contentOffset.x + collectionBounds.size.width))
            self.moveCollectionToFrame(contentOffset: contentOffset)
            nextButton.isHidden = true
            previousButton.isHidden = false
        }
        else {
            let collectionBounds = self.museumsBottomCollectionView.bounds
            let contentOffset = CGFloat(floor(self.museumsBottomCollectionView.contentOffset.x - collectionBounds.size.width))
            self.moveCollectionToFrame(contentOffset: contentOffset)
            nextButton.isHidden = true
            previousButton.isHidden = false
            previousButton.setImage(UIImage(named: "nextImg"), for: .normal)
        }
    }
    func moveCollectionToFrame(contentOffset : CGFloat) {
        
        let frame: CGRect = CGRect(x : contentOffset ,y : self.museumsBottomCollectionView.contentOffset.y ,width : self.museumsBottomCollectionView.frame.width,height : self.museumsBottomCollectionView.frame.height)
        self.museumsBottomCollectionView.scrollRectToVisible(frame, animated: false)
        
    }
    func loadComingSoonPopup() {
        popUpView  = ComingSoonPopUp(frame: self.view.frame)
        popUpView.comingSoonPopupDelegate = self
        popUpView.loadPopup()
        self.view.addSubview(popUpView)
    }
    //MARk: ComingSoonPopUp Delegates
    func closeButtonPressed() {
        self.popUpView.removeFromSuperview()
    }
    //MARK: Header Deleagate
    func eventButtonPressed() {
        let eventView =  self.storyboard?.instantiateViewController(withIdentifier: "eventPageID") as! EventViewController
        eventView.fromHome = false
        eventView.isLoadEventPage = true
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(eventView, animated: false, completion: nil)
    }
    
    func notificationbuttonPressed() {
        let notificationsView =  self.storyboard?.instantiateViewController(withIdentifier: "notificationId") as! NotificationsViewController
        notificationsView.fromHome = false
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(notificationsView, animated: false, completion: nil)
    }
    
    func profileButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        if (UserDefaults.standard.value(forKey: "accessToken") as? String != nil) {
            let profileView =  self.storyboard?.instantiateViewController(withIdentifier: "profileViewId") as! ProfileViewController
            self.present(profileView, animated: false, completion: nil)
        } else {
            let culturePassView =  self.storyboard?.instantiateViewController(withIdentifier: "culturePassViewId") as! CulturePassViewController
            culturePassView.fromHome = false
            self.present(culturePassView, animated: false, completion: nil)
        }
    }
    func menuButtonPressed() {
        
    }
    
    //MARK: WebServiceCall
    func getMuseumDataFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.LandingPageMuseums(["nid": museumId ?? 0])).responseObject { (response: DataResponse<Museums>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.museumArray.count == 0) {
                    self.museumArray = data.museum!
                }
                if(self.museumArray.count > 0) {
                    self.setImageArray(imageArray: self.museumArray[0].multimediaFile)
                    self.saveOrUpdateAboutCoredata(aboutDetailtArray: data.museum)
                }
            case .failure(let error):
                print(error)
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
                    self.deleteExistingEvent(managedContext: managedContext, entityName: "AboutDescriptionEntity")
                    self.deleteExistingEvent(managedContext: managedContext, entityName: "AboutMultimediaFileEntity")
                    self.deleteExistingEvent(managedContext: managedContext, entityName: "AboutDownloadLinkEntity")
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
                    self.deleteExistingEvent(managedContext: managedContext, entityName: "AboutDescriptionEntityAr")
                    self.deleteExistingEvent(managedContext: managedContext, entityName: "AboutMultimediaFileEntityAr")
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
            if(fromHomeBanner == false) {
                aboutdbDict.openingTime = aboutDetailDict.openingTime
            } else {
                aboutdbDict.openingTime = aboutDetailDict.eventDate
            }
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
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
            return true
        }catch _ as NSError {
            return false
        }
    }
    func fetchMuseumLandingImagesFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var aboutArray = [AboutEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "AboutEntity")
                if(museumId != nil) {
                    fetchRequest.predicate = NSPredicate(format: "id == %@", museumId!)
                    aboutArray = (try managedContext.fetch(fetchRequest) as? [AboutEntity])!
                    if (aboutArray.count > 0 ){
                        let aboutDict = aboutArray[0]
                        var multimediaArray : [String] = []
                        let mutimediaInfoArray = (aboutDict.multimediaRelation?.allObjects) as! [AboutMultimediaFileEntity]
                        if(mutimediaInfoArray.count > 0) {
                            for i in 0 ... mutimediaInfoArray.count-1 {
                                multimediaArray.append(mutimediaInfoArray[i].image!)
                            }
                        }
                        self.museumArray.insert(Museum(name: aboutDict.name, id: aboutDict.id, tourguideAvailable: nil, contactNumber: nil, contactEmail: nil, mobileLongtitude: nil, subtitle: nil, openingTime: nil, mobileDescription: nil, multimediaFile: multimediaArray, mobileLatitude: nil, tourGuideAvailability: nil,multimediaVideo: nil, downloadable:nil,eventDate:nil),at: 0)
                        if(museumArray.count != 0){
                            self.setImageArray(imageArray: self.museumArray[0].multimediaFile)
                        }
                    } else {
                        if (networkReachability?.isReachable)! {
                            DispatchQueue.global(qos: .background).async {
                                self.getMuseumDataFromServer()
                            }
                        }
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
                        var multimediaArray : [String] = []
                        let mutimediaInfoArray = (aboutDict.multimediaRelation?.allObjects) as! [AboutMultimediaFileEntityAr]
                        if(mutimediaInfoArray.count > 0){
                            for i in 0 ... mutimediaInfoArray.count-1 {
                                multimediaArray.append(mutimediaInfoArray[i].image!)
                            }
                        }
                        self.museumArray.insert(Museum(name: aboutDict.nameAr, id: aboutDict.id, tourguideAvailable: nil, contactNumber: nil, contactEmail: nil, mobileLongtitude: nil, subtitle: nil, openingTime: nil, mobileDescription: nil, multimediaFile: multimediaArray, mobileLatitude: nil, tourGuideAvailability: nil,multimediaVideo: nil,downloadable:nil,eventDate:nil),at: 0)
                        if(museumArray.count != 0){
                            self.setImageArray(imageArray: self.museumArray[0].multimediaFile)
                        }
                    }
                    else{
                        if (networkReachability?.isReachable)! {
                            DispatchQueue.global(qos: .background).async {
                                self.getMuseumDataFromServer()
                            }
                        }
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
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(MUSEUM_VC, screenClass: screenClass)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
