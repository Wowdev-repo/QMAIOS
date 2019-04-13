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
        super.viewDidLoad()
        
        loadUI()
        self.recordScreenView()
    }
    
    func loadUI() {
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
//        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
//            if (fromScienceTour) {
//                tourGuideId = "12216"
//            } else {
//                //tourGuideId = "12476"
//                //tourGuideId = "12216"
//                tourGuideId = "12471"
//            }
//        } else {
//            if (fromScienceTour) {
//                tourGuideId = "12226"
//            } else {
//                tourGuideId = "12916"
//            }
//        }
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
       
        pageViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewControllerId") as! UIPageViewController
        self.pageViewController.delegate = self;
         self.pageViewController.dataSource = self;
        let startingViewController: PreviewContentViewController = self.viewControllerAtIndex(index: 0)!
        let viewControllers = [startingViewController]
        currentContentViewController = startingViewController

        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        
        
        self.pageViewController.view.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        //self.addChildViewController(pageViewController)
        self.contentView.addSubview((pageViewController.view)!)
        //self.pageViewController.didMove(toParentViewController: self)
        
        pageImageViewOne.image = UIImage(named: "selectedControl")
        showOrHidePageControlView(countValue: tourGuideArray.count, scrolling: false)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.loadDetailPage))
//        tap.delegate = self // This is not required
//        self.view.addGestureRecognizer(tap)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func showOrHidePageControlView(countValue: Int?,scrolling:Bool?) {
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
        self.dismiss(animated: false, completion: nil)
    }
    
    func closeAudio() {
        if (currentContentViewController != nil) {
            currentContentViewController.stopAudio()
        }
    }
    
    //MARK: WebServiceCall
    func getTourGuideDataFromServer() {
        _ = Alamofire.request(QatarMuseumRouter.CollectionByTourGuide(LocalizationLanguage.currentAppleLanguage(),["tour_guide_id": tourGuideId!])).responseObject { (response: DataResponse<TourGuideFloorMaps>) -> Void in
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
        let queue = DispatchQueue(label: "", qos: .background, attributes: .concurrent)
        _ = Alamofire.request(QatarMuseumRouter.CollectionByTourGuide(LocalizationLanguage.currentAppleLanguage(),["tour_guide_id": tourGuideId!])).responseObject(queue: queue) { (response: DataResponse<TourGuideFloorMaps>) -> Void in
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
        } else {
            
        }
    }
    @objc func loadDetailPage(sender: UITapGestureRecognizer? = nil) {
        let objectDetailView =  self.storyboard?.instantiateViewController(withIdentifier: "objectDetailId") as! ObjectDetailViewController
        objectDetailView.detailArray.append(tourGuideArray[currentPreviewItem])
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionFade
                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                view.window!.layer.add(transition, forKey: kCATransition)
        self.present(objectDetailView, animated: false, completion: nil)
    }
    
    //MARK: TourGuide DataBase
    func saveOrUpdateTourGuideCoredata() {
        if (tourGuideArray.count > 0) {
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "FloorMapTourGuideEntity", idKey: "tourGuideId" , idValue: tourGuideId, managedContext: managedContext) as! [FloorMapTourGuideEntity]
            if (fetchData.count > 0) {
                for i in 0 ... tourGuideArray.count-1 {
                    let tourGuideDeatilDict = tourGuideArray[i]
                    let fetchResult = checkAddedToCoredata(entityName: "FloorMapTourGuideEntity", idKey: "nid", idValue: tourGuideArray[i].nid, managedContext: managedContext) as! [FloorMapTourGuideEntity]
                    
                    if(fetchResult.count != 0) {
                        
                        //update
                        let tourguidedbDict = fetchResult[0]
                        tourguidedbDict.title = tourGuideDeatilDict.title
                        tourguidedbDict.accessionNumber = tourGuideDeatilDict.accessionNumber
                        tourguidedbDict.nid =  tourGuideDeatilDict.nid
                        tourguidedbDict.curatorialDescription = tourGuideDeatilDict.curatorialDescription
                        tourguidedbDict.diam = tourGuideDeatilDict.diam
                        
                        tourguidedbDict.dimensions = tourGuideDeatilDict.dimensions
                        tourguidedbDict.mainTitle = tourGuideDeatilDict.mainTitle
                        tourguidedbDict.objectEngSummary =  tourGuideDeatilDict.objectENGSummary
                        tourguidedbDict.objectHistory = tourGuideDeatilDict.objectHistory
                        tourguidedbDict.production = tourGuideDeatilDict.production
                        
                        tourguidedbDict.productionDates = tourGuideDeatilDict.productionDates
                        tourguidedbDict.image = tourGuideDeatilDict.image
                        tourguidedbDict.tourGuideId =  tourGuideDeatilDict.tourGuideId
                        tourguidedbDict.artifactNumber = tourGuideDeatilDict.artifactNumber
                        tourguidedbDict.artifactPosition = tourGuideDeatilDict.artifactPosition
                        
                        tourguidedbDict.audioDescriptif = tourGuideDeatilDict.audioDescriptif
                        tourguidedbDict.audioFile = tourGuideDeatilDict.audioFile
                        tourguidedbDict.floorLevel =  tourGuideDeatilDict.floorLevel
                        tourguidedbDict.galleyNumber = tourGuideDeatilDict.galleyNumber
                        tourguidedbDict.artistOrCreatorOrAuthor = tourGuideDeatilDict.artistOrCreatorOrAuthor
                        tourguidedbDict.periodOrStyle = tourGuideDeatilDict.periodOrStyle
                        tourguidedbDict.techniqueAndMaterials = tourGuideDeatilDict.techniqueAndMaterials
                        if let imageUrl = tourGuideDeatilDict.thumbImage{
                            
                            if(imageUrl != "") {
                                if let data = try? Data(contentsOf: URL(string: imageUrl)!){
                                    let image: UIImage = UIImage(data: data)!
                                    tourguidedbDict.artifactImg = UIImagePNGRepresentation(image)
                                }
                            }
                        }
                        
                        if(tourGuideDeatilDict.images != nil) {
                            if((tourGuideDeatilDict.images?.count)! > 0) {
                                for i in 0 ... (tourGuideDeatilDict.images?.count)!-1 {
                                    var tourGuideImgEntity: FloorMapImagesEntity!
                                    let tourGuideImg: FloorMapImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "FloorMapImagesEntity", into: managedContext) as! FloorMapImagesEntity
                                    tourGuideImg.image = tourGuideDeatilDict.images?[i]
                                    
                                    tourGuideImgEntity = tourGuideImg
                                    tourguidedbDict.addToImagesRelation(tourGuideImgEntity)
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
                    }else {
                        self.saveToCoreData(tourGuideDetailDict: tourGuideDeatilDict, managedObjContext: managedContext)
                    }
                }//for
            }//if
            else {
                for i in 0 ... tourGuideArray.count-1 {
                    let tourGuideDetailDict : TourGuideFloorMap?
                    tourGuideDetailDict = tourGuideArray[i]
                    self.saveToCoreData(tourGuideDetailDict: tourGuideDetailDict!, managedObjContext: managedContext)
                }
                
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "FloorMapTourGuideEntityAr", idKey:"tourGuideId" , idValue: tourGuideId, managedContext: managedContext) as! [FloorMapTourGuideEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... tourGuideArray.count-1 {
                    let tourGuideDeatilDict = tourGuideArray[i]
                    let fetchResult = checkAddedToCoredata(entityName: "FloorMapTourGuideEntityAr", idKey: "nid", idValue: tourGuideArray[i].nid, managedContext: managedContext) as! [FloorMapTourGuideEntityAr]
                    //update
                    if(fetchResult.count != 0) {
                        let tourguidedbDict = fetchResult[0]
                        tourguidedbDict.title = tourGuideDeatilDict.title
                        tourguidedbDict.accessionNumber = tourGuideDeatilDict.accessionNumber
                        tourguidedbDict.nid =  tourGuideDeatilDict.nid
                        tourguidedbDict.curatorialDescription = tourGuideDeatilDict.curatorialDescription
                        tourguidedbDict.diam = tourGuideDeatilDict.diam
                        
                        tourguidedbDict.dimensions = tourGuideDeatilDict.dimensions
                        tourguidedbDict.mainTitle = tourGuideDeatilDict.mainTitle
                        tourguidedbDict.objectEngSummary =  tourGuideDeatilDict.objectENGSummary
                        tourguidedbDict.objectHistory = tourGuideDeatilDict.objectHistory
                        tourguidedbDict.production = tourGuideDeatilDict.production
                        
                        tourguidedbDict.productionDates = tourGuideDeatilDict.productionDates
                        tourguidedbDict.image = tourGuideDeatilDict.image
                        tourguidedbDict.tourGuideId =  tourGuideDeatilDict.tourGuideId
                        tourguidedbDict.artifactNumber = tourGuideDeatilDict.artifactNumber
                        tourguidedbDict.artifactPosition = tourGuideDeatilDict.artifactPosition
                        
                        tourguidedbDict.audioDescriptif = tourGuideDeatilDict.audioDescriptif
                        tourguidedbDict.audioFile = tourGuideDeatilDict.audioFile
                        tourguidedbDict.floorLevel =  tourGuideDeatilDict.floorLevel
                        tourguidedbDict.galleyNumber = tourGuideDeatilDict.galleyNumber
                        tourguidedbDict.artistOrCreatorOrAuthor = tourGuideDeatilDict.artistOrCreatorOrAuthor
                        tourguidedbDict.periodOrStyle = tourGuideDeatilDict.periodOrStyle
                        tourguidedbDict.techniqueAndMaterials = tourGuideDeatilDict.techniqueAndMaterials
                        if let imageUrl = tourGuideDeatilDict.thumbImage{
                            if(imageUrl != "") {
                                if let data = try? Data(contentsOf: URL(string: imageUrl)!)
                                {
                                    let image: UIImage = UIImage(data: data)!
                                    tourguidedbDict.artifactImg = UIImagePNGRepresentation(image)
                                }
                            }
                            
                        }
                        if(tourGuideDeatilDict.images != nil) {
                            if((tourGuideDeatilDict.images?.count)! > 0) {
                                for i in 0 ... (tourGuideDeatilDict.images?.count)!-1 {
                                    var tourGuideImgEntity: FloorMapImagesEntityAr!
                                    let tourGuideImg: FloorMapImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FloorMapImagesEntityAr", into: managedContext) as! FloorMapImagesEntityAr
                                    tourGuideImg.image = tourGuideDeatilDict.images?[i]
                                    
                                    tourGuideImgEntity = tourGuideImg
                                    tourguidedbDict.addToImagesRelation(tourGuideImgEntity)
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
                    } else {
                        self.saveToCoreData(tourGuideDetailDict: tourGuideDeatilDict, managedObjContext: managedContext)
                    }
                }//for
            } //if
            else {
                for i in 0 ... tourGuideArray.count-1 {
                    let tourGuideDetailDict : TourGuideFloorMap?
                    tourGuideDetailDict = tourGuideArray[i]
                    self.saveToCoreData(tourGuideDetailDict: tourGuideDetailDict!, managedObjContext: managedContext)
                }
                
            }
        }
    }
    
    func saveToCoreData(tourGuideDetailDict: TourGuideFloorMap, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let tourguidedbDict: FloorMapTourGuideEntity = NSEntityDescription.insertNewObject(forEntityName: "FloorMapTourGuideEntity", into: managedObjContext) as! FloorMapTourGuideEntity
            tourguidedbDict.title = tourGuideDetailDict.title
            tourguidedbDict.accessionNumber = tourGuideDetailDict.accessionNumber
            tourguidedbDict.nid =  tourGuideDetailDict.nid
            tourguidedbDict.curatorialDescription = tourGuideDetailDict.curatorialDescription
            tourguidedbDict.diam = tourGuideDetailDict.diam
            
            tourguidedbDict.dimensions = tourGuideDetailDict.dimensions
            tourguidedbDict.mainTitle = tourGuideDetailDict.mainTitle
            tourguidedbDict.objectEngSummary =  tourGuideDetailDict.objectENGSummary
            tourguidedbDict.objectHistory = tourGuideDetailDict.objectHistory
            tourguidedbDict.production = tourGuideDetailDict.production
            
            tourguidedbDict.productionDates = tourGuideDetailDict.productionDates
            tourguidedbDict.image = tourGuideDetailDict.image
            tourguidedbDict.tourGuideId =  tourGuideDetailDict.tourGuideId
            tourguidedbDict.artifactNumber = tourGuideDetailDict.artifactNumber
            tourguidedbDict.artifactPosition = tourGuideDetailDict.artifactPosition
            
            tourguidedbDict.audioDescriptif = tourGuideDetailDict.audioDescriptif
            tourguidedbDict.audioFile = tourGuideDetailDict.audioFile
            tourguidedbDict.floorLevel =  tourGuideDetailDict.floorLevel
            tourguidedbDict.galleyNumber = tourGuideDetailDict.galleyNumber
            tourguidedbDict.artistOrCreatorOrAuthor = tourGuideDetailDict.artistOrCreatorOrAuthor
            tourguidedbDict.periodOrStyle = tourGuideDetailDict.periodOrStyle
            tourguidedbDict.techniqueAndMaterials = tourGuideDetailDict.techniqueAndMaterials
            if let imageUrl = tourGuideDetailDict.thumbImage{
                if(imageUrl != "") {
                if let data = try? Data(contentsOf: URL(string: imageUrl)!) {
                    let image: UIImage = UIImage(data: data)!
                    tourguidedbDict.artifactImg = UIImagePNGRepresentation(image)
                }
            }
            }
            if(tourGuideDetailDict.images != nil) {
                if((tourGuideDetailDict.images?.count)! > 0) {
                    for i in 0 ... (tourGuideDetailDict.images?.count)!-1 {
                        var tourGuideImgEntity: FloorMapImagesEntity!
                        let tourGuideImg: FloorMapImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "FloorMapImagesEntity", into: managedObjContext) as! FloorMapImagesEntity
                        tourGuideImg.image = tourGuideDetailDict.images?[i]
                        
                        tourGuideImgEntity = tourGuideImg
                        tourguidedbDict.addToImagesRelation(tourGuideImgEntity)
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
            let tourguidedbDict: FloorMapTourGuideEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FloorMapTourGuideEntityAr", into: managedObjContext) as! FloorMapTourGuideEntityAr
            tourguidedbDict.title = tourGuideDetailDict.title
            tourguidedbDict.accessionNumber = tourGuideDetailDict.accessionNumber
            tourguidedbDict.nid =  tourGuideDetailDict.nid
            tourguidedbDict.curatorialDescription = tourGuideDetailDict.curatorialDescription
            tourguidedbDict.diam = tourGuideDetailDict.diam
            
            tourguidedbDict.dimensions = tourGuideDetailDict.dimensions
            tourguidedbDict.mainTitle = tourGuideDetailDict.mainTitle
            tourguidedbDict.objectEngSummary =  tourGuideDetailDict.objectENGSummary
            tourguidedbDict.objectHistory = tourGuideDetailDict.objectHistory
            tourguidedbDict.production = tourGuideDetailDict.production
            
            tourguidedbDict.productionDates = tourGuideDetailDict.productionDates
            tourguidedbDict.image = tourGuideDetailDict.image
            tourguidedbDict.tourGuideId =  tourGuideDetailDict.tourGuideId
            tourguidedbDict.artifactNumber = tourGuideDetailDict.artifactNumber
            tourguidedbDict.artifactPosition = tourGuideDetailDict.artifactPosition
            
            tourguidedbDict.audioDescriptif = tourGuideDetailDict.audioDescriptif
            tourguidedbDict.audioFile = tourGuideDetailDict.audioFile
            tourguidedbDict.floorLevel =  tourGuideDetailDict.floorLevel
            tourguidedbDict.galleyNumber = tourGuideDetailDict.galleyNumber
            tourguidedbDict.artistOrCreatorOrAuthor = tourGuideDetailDict.artistOrCreatorOrAuthor
            tourguidedbDict.periodOrStyle = tourGuideDetailDict.periodOrStyle
            tourguidedbDict.techniqueAndMaterials = tourGuideDetailDict.techniqueAndMaterials
            if let imageUrl = tourGuideDetailDict.thumbImage{
                if(imageUrl != "") {
                    if let data = try? Data(contentsOf: URL(string: imageUrl)!) {
                        let image: UIImage = UIImage(data: data)!
                        tourguidedbDict.artifactImg = UIImagePNGRepresentation(image)
                    }
                }
            }
            if(tourGuideDetailDict.images != nil) {
                if((tourGuideDetailDict.images?.count)! > 0) {
                    for i in 0 ... (tourGuideDetailDict.images?.count)!-1 {
                        var tourGuideImgEntity: FloorMapImagesEntityAr!
                        let tourGuideImg: FloorMapImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FloorMapImagesEntityAr", into: managedObjContext) as! FloorMapImagesEntityAr
                        tourGuideImg.image = tourGuideDetailDict.images?[i]
                        
                        tourGuideImgEntity = tourGuideImg
                        tourguidedbDict.addToImagesRelation(tourGuideImgEntity)
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
    
    func fetchTourGuideFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var tourGuideArray = [FloorMapTourGuideEntity]()
                tourGuideArray = checkAddedToCoredata(entityName: "FloorMapTourGuideEntity", idKey: "tourGuideId", idValue: tourGuideId, managedContext: managedContext) as! [FloorMapTourGuideEntity]
                var j:Int? = 0
                if (tourGuideArray.count > 0) {
                    for i in 0 ... tourGuideArray.count-1 {
                        if let duplicateId = self.tourGuideArray.first(where: {$0.nid == tourGuideArray[i].nid}) {
                        } else {
                        let tourGuideDict = tourGuideArray[i]
                        var imgsArray : [String] = []
                        let imgInfoArray = (tourGuideDict.imagesRelation?.allObjects) as! [FloorMapImagesEntity]
                        if(imgInfoArray != nil) {
                            if(imgInfoArray.count > 0) {
                                for i in 0 ... imgInfoArray.count-1 {
                                    imgsArray.append(imgInfoArray[i].image!)
                                }
                            }
                        }
                        self.tourGuideArray.insert(TourGuideFloorMap(title: tourGuideDict.title, accessionNumber: tourGuideDict.accessionNumber, nid: tourGuideDict.nid, curatorialDescription: tourGuideDict.curatorialDescription, diam: tourGuideDict.diam, dimensions: tourGuideDict.dimensions, mainTitle: tourGuideDict.mainTitle, objectENGSummary: tourGuideDict.objectEngSummary, objectHistory: tourGuideDict.objectHistory, production: tourGuideDict.production, productionDates: tourGuideDict.productionDates, image: tourGuideDict.image, tourGuideId: tourGuideDict.tourGuideId,artifactNumber: tourGuideDict.artifactNumber, artifactPosition: tourGuideDict.artifactPosition, audioDescriptif: tourGuideDict.audioDescriptif, images: imgsArray, audioFile: tourGuideDict.audioFile, floorLevel: tourGuideDict.floorLevel, galleyNumber: tourGuideDict.galleyNumber, artistOrCreatorOrAuthor: tourGuideDict.artistOrCreatorOrAuthor, periodOrStyle: tourGuideDict.periodOrStyle, techniqueAndMaterials: tourGuideDict.techniqueAndMaterials,thumbImage: tourGuideDict.thumbImage,artifactImg: tourGuideDict.artifactImg), at: j!)
                             j = j!+1
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
            } else {
                var tourGuideArray = [FloorMapTourGuideEntityAr]()
                tourGuideArray = checkAddedToCoredata(entityName: "FloorMapTourGuideEntityAr", idKey: "tourGuideId", idValue: tourGuideId, managedContext: managedContext) as! [FloorMapTourGuideEntityAr]
                 var j:Int? = 0
                if(tourGuideArray.count > 0) {
                    for i in 0 ... tourGuideArray.count-1 {
                        if let duplicateId = self.tourGuideArray.first(where: {$0.nid == tourGuideArray[i].nid}) {
                        } else {
                        let tourGuideDict = tourGuideArray[i]
                        var imgsArray : [String] = []
                        let imgInfoArray = (tourGuideDict.imagesRelation?.allObjects) as! [FloorMapImagesEntityAr]
                        if(imgInfoArray != nil) {
                            if(imgInfoArray.count > 0) {
                                for i in 0 ... imgInfoArray.count-1 {
                                    imgsArray.append(imgInfoArray[i].image!)
                                }
                            }
                        }
                        self.tourGuideArray.insert(TourGuideFloorMap(title: tourGuideDict.title, accessionNumber: tourGuideDict.accessionNumber, nid: tourGuideDict.nid, curatorialDescription: tourGuideDict.curatorialDescription, diam: tourGuideDict.diam, dimensions: tourGuideDict.dimensions, mainTitle: tourGuideDict.mainTitle, objectENGSummary: tourGuideDict.objectEngSummary, objectHistory: tourGuideDict.objectHistory, production: tourGuideDict.production, productionDates: tourGuideDict.productionDates, image: tourGuideDict.image, tourGuideId: tourGuideDict.tourGuideId,artifactNumber: tourGuideDict.artifactNumber, artifactPosition: tourGuideDict.artifactPosition, audioDescriptif: tourGuideDict.audioDescriptif, images: imgsArray, audioFile: tourGuideDict.audioFile, floorLevel: tourGuideDict.floorLevel, galleyNumber: tourGuideDict.galleyNumber, artistOrCreatorOrAuthor: tourGuideDict.artistOrCreatorOrAuthor, periodOrStyle: tourGuideDict.periodOrStyle, techniqueAndMaterials: tourGuideDict.techniqueAndMaterials,thumbImage: tourGuideDict.thumbImage,artifactImg: tourGuideDict.artifactImg), at: j!)
                            j = j!+1
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
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func checkAddedToCoredata(entityName: String?, idKey:String?, idValue: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults : [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
        if (idValue != nil) {
            fetchRequest.predicate = NSPredicate(format: "\(idKey!) == %@", idValue!)
           // fetchRequest.predicate = NSPredicate(format: "\(idKey!) == \(idValue!)")
            
        }
        fetchResults = try! managedContext.fetch(fetchRequest)
        return fetchResults
    }
    
    func showNodata() {
        
    }
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            self.getTourGuideDataFromServer()
        }
    }
    
    func showNoNetwork() {
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    
    func showNoData() {
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
}
