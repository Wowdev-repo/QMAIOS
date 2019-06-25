//
//  CommonListViewController+ReusableViewa.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
import Crashlytics
import Firebase

extension CommonListViewController: HeaderViewProtocol,comingSoonPopUpProtocol,LoadingViewProtocol {
    //MARK: Header delegate
    func headerCloseButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        
        let transition = CATransition()
        transition.duration = 0.25
        if (fromSideMenu == true) {
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            dismiss(animated: false, completion: nil)
        } else {
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.add(transition, forKey: kCATransition)
            switch exhibitionsPageNameString {
            case .homeExhibition?:
                let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = homeViewController
            case .museumExhibition?,.museumCollectionsList?,.nmoqTourSecondList?,.facilitiesSecondList?,.miaTourGuideList?,.parkList?:
                self.dismiss(animated: false, completion: nil)
            case .diningList?:
                if (fromHome == true) {
                    let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController
                    let appDelegate = UIApplication.shared.delegate
                    appDelegate?.window??.rootViewController = homeViewController
                } else {
                    self.dismiss(animated: false, completion: nil)
                }
            default:
                break
            }
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_add_to_calender_item,
            AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    //    MARK: comingsoon delegate
    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        
    }
}

extension CommonListViewController {
    func showNodata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        
        var errorMessage: String
        errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                        comment: "Setting the content of the alert"))
        self.commonListLoadingView.stopLoading()
        self.commonListLoadingView.noDataView.isHidden = false
        self.commonListLoadingView.isHidden = false
        self.commonListLoadingView.showNoDataView()
        self.commonListLoadingView.noDataLabel.text = errorMessage
    }
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if  (networkReachability?.isReachable)! {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if (exhibitionsPageNameString == ExhbitionPageName.homeExhibition) {
                appDelegate?.getExhibitionDataFromServer(lang: LocalizationLanguage.currentAppleLanguage())
            } else if (exhibitionsPageNameString == ExhbitionPageName.museumExhibition){
                self.getMuseumExhibitionDataFromServer()
            } else if (exhibitionsPageNameString == ExhbitionPageName.heritageList){
                appDelegate?.getHeritageDataFromServer(lang: LocalizationLanguage.currentAppleLanguage())
            } else if (exhibitionsPageNameString == ExhbitionPageName.publicArtsList){
                appDelegate?.getPublicArtsListDataFromServer(lang: LocalizationLanguage.currentAppleLanguage())
            } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList){
                if((museumId == "63") || (museumId == "96")) {
                    appDelegate?.getCollectionList(museumId: museumId, lang: LocalizationLanguage.currentAppleLanguage())
                    
                } else {
                    self.getCollectionList()
                }
            } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList){
                if(fromHome == true) {
                    appDelegate?.getDiningListFromServer(language: LocalizationLanguage.currentAppleLanguage())
                } else {
                    self.getMuseumDiningListFromServer()
                }
            } else if (exhibitionsPageNameString == ExhbitionPageName.nmoqTourSecondList){
                self.getNMoQTourDetail()
            } else if (exhibitionsPageNameString == ExhbitionPageName.miaTourGuideList){
                self.getTourGuideDataFromServer()
            } else if (exhibitionsPageNameString == ExhbitionPageName.tourGuideList){
                self.getTourGuideMuseumsList()
            } else if (exhibitionsPageNameString == ExhbitionPageName.parkList){
                appDelegate?.getNmoqParkListFromServer(lang: LocalizationLanguage.currentAppleLanguage())
            }
        }
    }
    func showNoNetwork() {
        self.commonListLoadingView.stopLoading()
        self.commonListLoadingView.noDataView.isHidden = false
        self.commonListLoadingView.isHidden = false
        self.commonListLoadingView.showNoNetworkView()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
}
