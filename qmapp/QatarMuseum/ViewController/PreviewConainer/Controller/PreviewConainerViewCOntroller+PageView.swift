//
//  PreviewConainerViewCOntroller+PageView.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
import Crashlytics
import Firebase

extension PreviewContainerViewController: UIPageViewControllerDelegate,UIPageViewControllerDataSource {
    //MARk: PAgeViewController delegates
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
}

//MARK:- PageControlView Methods
extension PreviewContainerViewController {
    
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
}
