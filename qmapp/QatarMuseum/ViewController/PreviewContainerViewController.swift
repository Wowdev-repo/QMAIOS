//
//  PreviewContainerViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 03/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import Firebase
import UIKit
import CocoaLumberjack

class PreviewContainerViewController: UIViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource,HeaderViewProtocol,UIGestureRecognizerDelegate,LoadingViewProtocol {
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
    
    func setUpPageControl() {
       DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        pageViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewControllerId") as! UIPageViewController
        self.pageViewController.delegate = self;
         self.pageViewController.dataSource = self;
        let startingViewController: PreviewContentViewController = self.viewControllerAtIndex(index: 0)!
        let viewControllers = [startingViewController]
        currentContentViewController = startingViewController

        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        
        
        self.pageViewController.view.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        self.contentView.addSubview((pageViewController.view)!)
        
        pageImageViewOne.image = UIImage(named: "selectedControl")
        showOrHidePageControlView(countValue: tourGuideArray.count, scrolling: false)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func showOrHidePageControlView(countValue: Int?,scrolling:Bool?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if countValue == 0 {
            pageViewOne.isHidden = true
            pageViewTwo.isHidden = true
            pageViewThree.isHidden = true
            pageViewFour.isHidden = true
            pageViewFive.isHidden = true
            
            pageImageViewOne.isHidden = true
            pageImageViewTwo.isHidden = true
            pageImageViewThree.isHidden = true
            pageImageViewFour.isHidden = true
            pageImageViewFive.isHidden = true
            
            viewOneLineOne.isHidden = true
            viewOneLineTwo.isHidden = true
            viewTwoLineOne.isHidden = true
            viewTwoLineTwo.isHidden = true
            viewThreeLineOne.isHidden = true
            viewThreeLineTwo.isHidden = true
            viewFourLineOne.isHidden = true
            viewFourLineTwo.isHidden = true
            viewFiveLineOne.isHidden = true
            viewFiveLineTwo.isHidden = true
        } else if countValue == 1 {
            pageViewOne.isHidden = false
            pageViewTwo.isHidden = true
            pageViewThree.isHidden = true
            pageViewFour.isHidden = true
            pageViewFive.isHidden = true
            
            pageImageViewOne.isHidden = false
            pageImageViewTwo.isHidden = true
            pageImageViewThree.isHidden = true
            pageImageViewFour.isHidden = true
            pageImageViewFive.isHidden = true
            
            viewOneLineOne.isHidden = false
            if(scrolling)! {
                viewOneLineTwo.isHidden = true
                pageImageOneWidth.constant = 15
                pageImageOneHeight.constant = 15
                pageImageViewOne.image = UIImage(named: "stripper_inactive_end")
            } else {
                viewOneLineTwo.isHidden = false
            }
            
            viewTwoLineOne.isHidden = true
            //viewTwoLineTwo.isHidden = true
            viewThreeLineOne.isHidden = true
            viewThreeLineTwo.isHidden = true
            viewFourLineOne.isHidden = true
            viewFourLineTwo.isHidden = true
            viewFiveLineOne.isHidden = true
            viewFiveLineTwo.isHidden = true
        } else if countValue == 2 {
            pageViewOne.isHidden = false
            pageViewTwo.isHidden = false
            pageViewThree.isHidden = true
            pageViewFour.isHidden = true
            pageViewFive.isHidden = true
            
            pageImageViewOne.isHidden = false
            pageImageViewTwo.isHidden = false
            pageImageViewThree.isHidden = true
            pageImageViewFour.isHidden = true
            pageImageViewFive.isHidden = true
            
            if(scrolling)! {
                viewTwoLineTwo.isHidden = true
                pageImageTwoWidth.constant = 15
                pageImageTwoHeight.constant = 15
                pageImageViewTwo.image = UIImage(named: "stripper_inactive_end")
            } else {
                viewTwoLineTwo.isHidden = false
            }
            viewOneLineOne.isHidden = false
            viewOneLineTwo.isHidden = false
            viewTwoLineOne.isHidden = false
            //viewTwoLineTwo.isHidden = false
            viewThreeLineOne.isHidden = true
            viewThreeLineTwo.isHidden = true
            viewFourLineOne.isHidden = true
            viewFourLineTwo.isHidden = true
            viewFiveLineOne.isHidden = true
            viewFiveLineTwo.isHidden = true
            
        }
        else if countValue == 3 {
            pageViewOne.isHidden = false
            pageViewTwo.isHidden = false
            pageViewThree.isHidden = false
            pageViewFour.isHidden = true
            pageViewFive.isHidden = true
            
            pageImageViewOne.isHidden = false
            pageImageViewTwo.isHidden = false
            pageImageViewThree.isHidden = false
            pageImageViewFour.isHidden = true
            pageImageViewFive.isHidden = true
            
            if(scrolling)! {
                viewThreeLineTwo.isHidden = true
                pageImageThreeWidth.constant = 15
                pageImageThreeHeight.constant = 15
                pageImageViewThree.image = UIImage(named: "stripper_inactive_end")
            } else {
                viewThreeLineTwo.isHidden = false
            }
            viewOneLineOne.isHidden = false
            viewOneLineTwo.isHidden = false
            viewTwoLineOne.isHidden = false
            viewTwoLineTwo.isHidden = false
            viewThreeLineOne.isHidden = false
            // viewThreeLineTwo.isHidden = false
            viewFourLineOne.isHidden = true
            viewFourLineTwo.isHidden = true
            viewFiveLineOne.isHidden = true
            viewFiveLineTwo.isHidden = true
        }
        else if countValue == 4{
            pageViewOne.isHidden = false
            pageViewTwo.isHidden = false
            pageViewThree.isHidden = false
            pageViewFour.isHidden = false
            pageViewFive.isHidden = true
            
            pageImageViewOne.isHidden = false
            pageImageViewTwo.isHidden = false
            pageImageViewThree.isHidden = false
            pageImageViewFour.isHidden = false
            pageImageViewFive.isHidden = true
            
            if(scrolling)! {
                viewFourLineTwo.isHidden = true
                pageImageFourWidth.constant = 15
                pageImageFourHeight.constant = 15
                pageImageViewFour.image = UIImage(named: "stripper_inactive_end")
            } else {
                viewFourLineTwo.isHidden = false
            }
            viewOneLineOne.isHidden = false
            viewOneLineTwo.isHidden = false
            viewTwoLineOne.isHidden = false
            viewTwoLineTwo.isHidden = false
            viewThreeLineOne.isHidden = false
            viewThreeLineTwo.isHidden = false
            viewFourLineOne.isHidden = false
            //viewFourLineTwo.isHidden = false
            viewFiveLineOne.isHidden = true
            viewFiveLineTwo.isHidden = true
        }else{
            pageViewOne.isHidden = false
            pageViewTwo.isHidden = false
            pageViewThree.isHidden = false
            pageViewFour.isHidden = false
            pageViewFive.isHidden = false
            
            pageImageViewOne.isHidden = false
            pageImageViewTwo.isHidden = false
            pageImageViewThree.isHidden = false
            pageImageViewFour.isHidden = false
            pageImageViewFive.isHidden = false
            
            if(scrolling)! {
                viewFiveLineTwo.isHidden = true
                pageImageFiveWidth.constant = 15
                pageImageFiveHeight.constant = 15
                pageImageViewFive.image = UIImage(named: "stripper_inactive_end")
            } else {
                viewFiveLineTwo.isHidden = false
            }
            viewOneLineOne.isHidden = false
            viewOneLineTwo.isHidden = false
            viewTwoLineOne.isHidden = false
            viewTwoLineTwo.isHidden = false
            viewThreeLineOne.isHidden = false
            viewThreeLineTwo.isHidden = false
            viewFourLineOne.isHidden = false
            viewFourLineTwo.isHidden = false
            viewFiveLineOne.isHidden = false
            // viewFiveLineTwo.isHidden = false
        }
    }
    func showPageControlAtFirstTime() {
        if (tourGuideArray.count <= 5) {
            if(tourGuideArray.count == 4) {
                viewFourLineTwo.isHidden = true
                pageImageFourWidth.constant = 15
                pageImageFourHeight.constant = 15
                pageImageViewFour.image = UIImage(named: "stripper_inactive_end")
            } else if (tourGuideArray.count == 3) {
                viewThreeLineTwo.isHidden = true
                pageImageThreeWidth.constant = 15
                pageImageThreeHeight.constant = 15
                pageImageViewThree.image = UIImage(named: "stripper_inactive_end")
            } else if(tourGuideArray.count == 2) {
                viewTwoLineTwo.isHidden = true
                pageImageTwoWidth.constant = 15
                pageImageTwoHeight.constant = 15
                pageImageViewTwo.image = UIImage(named: "stripper_inactive_end")
            }
            else if(tourGuideArray.count == 1) {
                viewOneLineTwo.isHidden = true
                pageViewOne.isHidden = true
                pageImageOneWidth.constant = 15
                pageImageOneHeight.constant = 15
                pageImageViewOne.image = UIImage(named: "stripper_inactive_end")
            }
            if(tourGuideArray.count == 5) {
                pageImageViewFive.image = UIImage(named: "stripper_inactive_end")
                pageImageFiveHeight.constant = 15
                pageImageFiveWidth.constant = 15
                pageImageViewFive.image = UIImage(named: "stripper_inactive_end")
            }
            viewFiveLineTwo.isHidden = true
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_previewcontainer_pgctrlfirsttime,
            AnalyticsParameterItemName: tourGuideArray.count,
            AnalyticsParameterContentType: "cont"
            ])
        
        viewOneLineOne.isHidden = true
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index: Int? = (viewController as? PreviewContentViewController)?.pageIndex
        if ((index == 0) || (index == NSNotFound)) {
            return nil
        }
        index = index! - 1

        return self.viewControllerAtIndex(index: index!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index: Int? = (viewController as? PreviewContentViewController)?.pageIndex
        if (index == NSNotFound) {
            return nil
        }
        index = index! + 1
        
        if (index == self.tourGuideArray.count) {
            return nil
        }
        return self.viewControllerAtIndex(index: index!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        loadingView.stopLoading()
        loadingView.isHidden = true
        if (!completed)
        {
            return
        }
        currentContentViewController = self.viewControllerAtIndex(index: currentPreviewItem)
        self.closeAudio()
        if let currentViewController = pageViewController.viewControllers![0] as? PreviewContentViewController {
             let currentPageIndex = currentViewController.pageIndex
            reloaded = true
            var remainingCount = Int()
            if(currentPageIndex % 5 == 0) {
                //setPageViewVisible()
                
                pageImageViewOne.image = UIImage(named: "selectedControl")
                pageImageViewTwo.image = UIImage(named: "unselected")
                pageImageViewThree.image = UIImage(named: "unselected")
                pageImageViewFour.image = UIImage(named: "unselected")
                pageImageViewFive.image = UIImage(named: "unselected")
                remainingCount = tourGuideArray.count - ( currentPageIndex+1)
                if(currentPageIndex > currentPreviewItem) {
                    
                    if (remainingCount < 5) {
                        showOrHidePageControlView(countValue: remainingCount+1, scrolling: true)
                        if(remainingCount+1 == 1) {
                            pageImageViewOne.image = UIImage(named: "selectedControl")
                        }
                        if(remainingCount+1 == 2) {
                            pageImageViewTwo.image = UIImage(named: "stripper_inactive_end")
                        } else if(remainingCount+1 == 3) {
                            pageImageViewThree.image = UIImage(named: "stripper_inactive_end")
                        } else if(remainingCount+1 == 4) {
                            pageImageViewFour.image = UIImage(named: "stripper_inactive_end")
                        } else if(remainingCount+1 == 5) {
                            pageImageViewFive.image = UIImage(named: "stripper_inactive_end")
                        }
                    }
                } else  {
                    //remainingCount = pageCount! - ( indexPath.row+1)
                    if(remainingCount+1 == 2) {
                        pageImageViewTwo.image = UIImage(named: "stripper_inactive_end")
                        pageImageTwoHeight.constant = 15
                        pageImageTwoWidth.constant = 15
                    } else if(remainingCount+1 == 3) {
                        pageImageViewThree.image = UIImage(named: "stripper_inactive_end")
                        pageImageThreeHeight.constant = 15
                        pageImageThreeWidth.constant = 15
                    } else if(remainingCount+1 == 4) {
                        pageImageViewFour.image = UIImage(named: "stripper_inactive_end")
                        pageImageFourHeight.constant = 15
                        pageImageFourWidth.constant = 15
                    } else if(remainingCount+1 == 5) {
                        pageImageViewFive.image = UIImage(named: "stripper_inactive_end")
                        pageImageFiveHeight.constant = 15
                        pageImageFiveWidth.constant = 15
                    }
                    
                }
                if(currentPageIndex == 0) {
                    viewOneLineOne.isHidden = true
                } else {
                    viewOneLineOne.isHidden = false
                    pageImageOneHeight.constant = 20
                    pageImageOneWidth.constant = 20
                }
            } else if(currentPageIndex%5 == 1) {
                pageImageTwoHeight.constant = 20
                pageImageTwoWidth.constant = 20
                pageImageViewTwo.image = UIImage(named: "selectedControl")
                pageImageViewThree.image = UIImage(named: "unselected")
                pageImageViewFour.image = UIImage(named: "unselected")
                pageImageViewFive.image = UIImage(named: "unselected")
                
                if(currentPageIndex > currentPreviewItem) {
                    remainingCount = tourGuideArray.count - ( currentPageIndex+1)
                    if ((remainingCount < 4) && (remainingCount != 0)) {
                        showOrHidePageControlView(countValue: remainingCount+2, scrolling: true)
                        if(remainingCount+2 == 3) {
                            pageImageViewThree.image = UIImage(named: "stripper_inactive_end")
                        } else if(remainingCount+2 == 4) {
                            pageImageViewFour.image = UIImage(named: "stripper_inactive_end")
                        } else if(remainingCount+2 == 5) {
                            pageImageViewFive.image = UIImage(named: "stripper_inactive_end")
                        }
                    }
                } else {
                    remainingCount = tourGuideArray.count - ( currentPageIndex+1)
                    if(remainingCount+2 == 3) {
                        pageImageViewThree.image = UIImage(named: "stripper_inactive_end")
                        pageImageThreeHeight.constant = 15
                        pageImageThreeWidth.constant = 15
                    } else if(remainingCount+2 == 4) {
                        pageImageViewFour.image = UIImage(named: "stripper_inactive_end")
                        pageImageFourHeight.constant = 15
                        pageImageFourWidth.constant = 15
                    } else if(remainingCount+2 == 5) {
                        pageImageViewFive.image = UIImage(named: "stripper_inactive_end")
                        pageImageFiveHeight.constant = 15
                        pageImageFiveWidth.constant = 15
                    }
                    
                }
                
                if(currentPageIndex == 1) {
                    pageImageOneHeight.constant = 15
                    pageImageOneWidth.constant = 15
                    pageImageViewOne.image = UIImage(named: "stripper_inactive_end")
                    viewOneLineOne.isHidden = true
                } else {
                    pageImageOneHeight.constant = 20
                    pageImageOneWidth.constant = 20
                    pageImageViewOne.image = UIImage(named: "unselected")
                }
            } else if(currentPageIndex%5 == 2) {
                pageImageThreeHeight.constant = 20
                pageImageThreeWidth.constant = 20
                //pageImageViewOne.image = UIImage(named: "stripper_inactive_end")
                pageImageViewTwo.image = UIImage(named: "unselected")
                pageImageViewThree.image = UIImage(named: "selectedControl")
                pageImageViewFour.image = UIImage(named: "unselected")
                pageImageViewFive.image = UIImage(named: "unselected")
                if(currentPageIndex > currentPreviewItem) {
                    remainingCount = tourGuideArray.count - ( currentPageIndex+1)
                    if ((remainingCount < 3) && (remainingCount != 0)) {
                        showOrHidePageControlView(countValue: remainingCount+3, scrolling: true)
                        if(remainingCount+3 == 4) {
                            pageImageViewFour.image = UIImage(named: "stripper_inactive_end")
                        } else if(remainingCount+3 == 5) {
                            pageImageViewFive.image = UIImage(named: "stripper_inactive_end")
                        }
                    }
                } else  {
                    remainingCount = tourGuideArray.count - ( currentPageIndex+1)
                    if(remainingCount+3 == 4) {
                        pageImageViewFour.image = UIImage(named: "stripper_inactive_end")
                        pageImageFourHeight.constant = 15
                        pageImageFourWidth.constant = 15
                    } else if(remainingCount+3 == 5) {
                        pageImageViewFive.image = UIImage(named: "stripper_inactive_end")
                        pageImageFiveHeight.constant = 15
                        pageImageFiveWidth.constant = 15
                    }
                    
                }
                
            } else if(currentPageIndex%5 == 3) {
                pageImageFourHeight.constant = 20
                pageImageFourWidth.constant = 20
                //setPageViewVisible()
                // pageImageViewOne.image = UIImage(named: "stripper_inactive_end")
                pageImageViewTwo.image = UIImage(named: "unselected")
                pageImageViewThree.image = UIImage(named: "unselected")
                pageImageViewFour.image = UIImage(named: "selectedControl")
                pageImageViewFive.image = UIImage(named: "unselected")
                
                
                if(currentPageIndex > currentPreviewItem) {
                    remainingCount = tourGuideArray.count - ( currentPageIndex+1)
                    if ((remainingCount < 2) && (remainingCount != 0)) {
                        showOrHidePageControlView(countValue: remainingCount+4, scrolling: true)
                        if(remainingCount+4 == 5) {
                            pageImageViewFive.image = UIImage(named: "stripper_inactive_end")
                        }
                    }
                    
                }
                else  {
                    remainingCount = tourGuideArray.count - ( currentPageIndex+1)
                    if(remainingCount+4 == 5) {
                        pageImageViewFive.image = UIImage(named: "stripper_inactive_end")
                        pageImageFiveHeight.constant = 15
                        pageImageFiveWidth.constant = 15
                    }
                    
                }
                
                
            }
            else if(currentPageIndex%5 == 4) {
                if(currentPageIndex > currentPreviewItem) {
                    let remnCount = tourGuideArray.count - ( currentPageIndex+1)
                    if(remnCount <= 0) {
                        viewFiveLineTwo.isHidden = true
                    }
                }
                else {
                    setPageViewVisible()
                    if(currentPageIndex == 4) {
                        viewOneLineOne.isHidden = true
                        pageImageOneHeight.constant = 15
                        pageImageOneWidth.constant = 15
                        pageImageViewOne.image = UIImage(named: "stripper_inactive_end")
                        
                        pageImageTwoHeight.constant = 20
                        pageImageTwoWidth.constant = 20
                        pageImageThreeHeight.constant = 20
                        pageImageThreeWidth.constant = 20
                        pageImageFourHeight.constant = 20
                        pageImageFourWidth.constant = 20
                        pageImageFiveHeight.constant = 20
                        pageImageFiveWidth.constant = 20
                    }
                }
                pageImageFiveHeight.constant = 20
                pageImageFiveWidth.constant = 20
                pageImageViewTwo.image = UIImage(named: "unselected")
                pageImageViewThree.image = UIImage(named: "unselected")
                pageImageViewFour.image = UIImage(named: "unselected")
                pageImageViewFive.image = UIImage(named: "selectedControl")
            }
            
            if(currentPageIndex == 0) {
                viewOneLineOne.isHidden = true
                pageImageOneHeight.constant = 20
                pageImageOneWidth.constant = 20
            }
            currentPreviewItem = currentPageIndex
            currentContentViewController = self.viewControllerAtIndex(index: currentPreviewItem)
        }
       
    }
   
    func viewControllerAtIndex(index : Int) -> PreviewContentViewController? {
        if ((self.tourGuideArray.count == 0) || (index > self.tourGuideArray.count)){
            return nil
        }
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageContentViewControllerId") as! PreviewContentViewController
        pageContentViewController.pageIndex = index
        pageContentViewController.tourGuideDict = tourGuideArray[index]
        return pageContentViewController
    }
    
    func setPageViewVisible() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        
        pageViewOne.isHidden = false
        pageViewTwo.isHidden = false
        pageViewThree.isHidden = false
        pageViewFour.isHidden = false
        pageViewFive.isHidden = false
        
        pageImageViewOne.isHidden = false
        pageImageViewTwo.isHidden = false
        pageImageViewThree.isHidden = false
        pageImageViewFour.isHidden = false
        pageImageViewFive.isHidden = false
        
        viewOneLineOne.isHidden = false
        viewOneLineTwo.isHidden = false
        viewTwoLineOne.isHidden = false
        viewTwoLineTwo.isHidden = false
        viewThreeLineOne.isHidden = false
        viewThreeLineTwo.isHidden = false
        viewFourLineOne.isHidden = false
        viewFourLineTwo.isHidden = false
        viewFiveLineOne.isHidden = false
        viewFiveLineTwo.isHidden = false
        
        pageImageOneHeight.constant = 20
        pageImageOneWidth.constant = 20
        pageImageTwoHeight.constant = 20
        pageImageTwoWidth.constant = 20
        pageImageThreeHeight.constant = 20
        pageImageThreeWidth.constant = 20
        pageImageFourHeight.constant = 20
        pageImageFourWidth.constant = 20
       // pageImageOneHeight.constant = 20
       // pageImageOneWidth.constant = 20
        pageImageViewOne.image = UIImage(named: "unselected")
        pageImageViewTwo.image = UIImage(named: "unselected")
        pageImageViewThree.image = UIImage(named: "unselected")
        pageImageViewFour.image = UIImage(named: "unselected")
    }
    
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
    
    //MARK: WebServiceCall
    func getTourGuideDataFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.CollectionByTourGuide(LocalizationLanguage.currentAppleLanguage(),["tour_guide_id": tourGuideId!])).responseObject { (response: DataResponse<TourGuideFloorMaps>) -> Void in
            switch response.result {
            case .success(let data):
                self.tourGuideArray = data.tourGuideFloorMap
                self.countValue = self.tourGuideArray.count
                if(self.tourGuideArray.count != 0) {
                    self.headerView.settingsButton.isHidden = false
                    if((self.museumId == "63") || (self.museumId == "96")) {
                        self.headerView.settingsButton.setImage(UIImage(named: "locationImg"), for: .normal)
                    } else {
                        self.headerView.settingsButton.isHidden = true
                    }
                    self.headerView.settingsButton.contentEdgeInsets = UIEdgeInsets(top: 9, left: 10, bottom:9, right: 10)
                    self.setUpPageControl()
                    self.showOrHidePageControlView(countValue: self.tourGuideArray.count, scrolling: false)
                    self.showPageControlAtFirstTime()
                    self.saveOrUpdateTourGuideCoredata()
                }
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                
                if (self.tourGuideArray.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            case .failure(let error):
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
    
    func getTourGuideDataFromServerInBackgound() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let queue = DispatchQueue(label: "", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.CollectionByTourGuide(LocalizationLanguage.currentAppleLanguage(),["tour_guide_id": tourGuideId!])).responseObject(queue: queue) { (response: DataResponse<TourGuideFloorMaps>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.tourGuideFloorMap?.count != 0) {
                    self.saveOrUpdateTourGuideCoredata()
                }
            case .failure(let error):
                print(error)
            }
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
    
    //MARK: TourGuide DataBase
    func saveOrUpdateTourGuideCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (tourGuideArray.count > 0) {
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateFloorMap(managedContext : managedContext,
                                               floorMapArray: self.tourGuideArray,
                                               tourGuideID: self.tourGuideId)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateFloorMap(managedContext : managedContext,
                                               floorMapArray: self.tourGuideArray,
                                               tourGuideID: self.tourGuideId)
                }
            }
        }
    }
    
    
    func fetchTourGuideFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let managedContext = getContext()
        do {
            var tourGuideArray = [FloorMapTourGuideEntity]()
            tourGuideArray = DataManager.checkAddedToCoredata(entityName: "FloorMapTourGuideEntity",
                                                              idKey: "tourGuideId",
                                                              idValue: tourGuideId,
                                                              managedContext: managedContext) as! [FloorMapTourGuideEntity]
            if (tourGuideArray.count > 0) {
                for tourGuideDict in tourGuideArray {
                    if self.tourGuideArray.first(where: {$0.nid == tourGuideDict.nid}) != nil {
                    } else {
                        self.tourGuideArray.append(TourGuideFloorMap(entity: tourGuideDict))
                    }
                }
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.tourGuideArray.count > 0) {
                    self.headerView.settingsButton.isHidden = false
                    if((self.museumId == "63") || (self.museumId == "96")) {
                        self.headerView.settingsButton.setImage(UIImage(named: "locationImg"), for: .normal)
                        self.headerView.settingsButton.contentEdgeInsets = UIEdgeInsets(top: 9, left: 10, bottom:9, right: 10)
                    } else {
                        self.headerView.settingsButton.isHidden = true
                    }
                    self.setUpPageControl()
                    self.showOrHidePageControlView(countValue: self.tourGuideArray.count, scrolling: false)
                    self.showPageControlAtFirstTime()
                } else if (networkReachability?.isReachable)! {
                    self.showNoData()
                } else {
                    self.showNoNetwork()
                }
                
            } else if (networkReachability?.isReachable)! && self.tourGuideArray.count == 0 {
                self.getTourGuideDataFromServer()
            } else {
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                self.showNoNetwork()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(PREVIEW_CONTAINER_VC, screenClass: screenClass)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "previewToObjectDetailSegue") {
            let objectDetailView = segue.destination as! ObjectDetailViewController
            objectDetailView.detailArray.append(tourGuideArray[currentPreviewItem])
        }
    }
}
