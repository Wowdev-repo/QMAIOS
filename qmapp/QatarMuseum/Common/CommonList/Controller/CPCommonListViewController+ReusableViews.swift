//
//  CPCommonListViewController+ReusableViewa.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
import Crashlytics
import Firebase

extension CPCommonListViewController: CPHeaderViewProtocol,CPComingSoonPopUpProtocol,LoadingViewProtocol {
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
                let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! CPHomeViewController
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = homeViewController
            case .museumExhibition?,.museumCollectionsList?,.nmoqTourSecondList?,.facilitiesSecondList?,.miaTourGuideList?,.parkList?:
                self.dismiss(animated: false, completion: nil)
            case .diningList?:
                if (fromHome == true) {
                    let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! CPHomeViewController
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

extension CPCommonListViewController {
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
            if (exhibitionsPageNameString == CPExhbitionPageName.homeExhibition) {
                appDelegate?.getExhibitionDataFromServer(lang: CPLocalizationLanguage.currentAppleLanguage())
            } else if (exhibitionsPageNameString == CPExhbitionPageName.museumExhibition){
                self.getMuseumExhibitionDataFromServer()
            } else if (exhibitionsPageNameString == CPExhbitionPageName.heritageList){
                appDelegate?.getHeritageDataFromServer(lang: CPLocalizationLanguage.currentAppleLanguage())
            } else if (exhibitionsPageNameString == CPExhbitionPageName.publicArtsList){
                appDelegate?.getPublicArtsListDataFromServer(lang: CPLocalizationLanguage.currentAppleLanguage())
            } else if (exhibitionsPageNameString == CPExhbitionPageName.museumCollectionsList){
                if((museumId == "63") || (museumId == "96")) {
                    appDelegate?.getCollectionList(museumId: museumId, lang: CPLocalizationLanguage.currentAppleLanguage())
                    
                } else {
                    self.getCollectionList()
                }
            } else if (exhibitionsPageNameString == CPExhbitionPageName.museumCollectionsList){
                if(fromHome == true) {
                    appDelegate?.getDiningListFromServer(language: CPLocalizationLanguage.currentAppleLanguage())
                } else {
                    self.getMuseumDiningListFromServer()
                }
            } else if (exhibitionsPageNameString == CPExhbitionPageName.nmoqTourSecondList){
                self.getNMoQTourDetail()
            } else if (exhibitionsPageNameString == CPExhbitionPageName.miaTourGuideList){
                self.getTourGuideDataFromServer()
            } else if (exhibitionsPageNameString == CPExhbitionPageName.tourGuideList){
                self.getTourGuideMuseumsList()
            } else if (exhibitionsPageNameString == CPExhbitionPageName.parkList){
                appDelegate?.getNmoqParkListFromServer(lang: CPLocalizationLanguage.currentAppleLanguage())
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
