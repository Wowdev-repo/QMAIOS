//
//  MuseumsViewController+CollectioView.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Firebase
import UIKit

extension MuseumsViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    //MARK: CollectionView Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let museumsCell : MuseumBottomCell = museumsBottomCollectionView.dequeueReusableCell(withReuseIdentifier: "museumCellId", for: indexPath) as! MuseumBottomCell
        museumsCell.itemButton.setImage(UIImage(named: collectionViewImages.object(at: indexPath.row) as! String), for: .normal)
        let itemName = collectionViewNames.object(at: indexPath.row) as? String
        museumsCell.itemName.text = collectionViewNames.object(at: indexPath.row) as? String
        if fromHomeBanner {
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
            }else if((itemName == "Audio Guide") || (itemName == "الدليل الصوتي") || (itemName == "Highlights Tour")) {
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
            else if  ((itemName == "Dining") || (itemName == "الطعام") ) {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 18, left: 15, bottom: 18, right: 15)
            } else if ((itemName == "Facilities") || (itemName == "المرافق")) {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            }
            else if((itemName == "Experience") || (itemName == "المحتويات")) {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
            } else if(itemName == "Events") {
                museumsCell.itemButton.contentEdgeInsets = UIEdgeInsets(top: 17, left: 16, bottom: 17, right: 16)
            }
        }
        
        if((museumId != nil) && ((museumId == "63") || (museumId == "66") || (museumId == "638") || (museumId == "96") )) {
            if (museumsBottomCollectionView.contentOffset.x <= 0.0) {
                if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
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
                if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
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
            self.selectedItemName = itemName
            self.loadBottomCellPages(cellObj: museumsCell, selectedItem: itemName )
            
        }
        return museumsCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: museumsBottomCollectionView.frame.width/4, height: 110)
    }
    func loadBottomCellPages(cellObj: MuseumBottomCell, selectedItem: String?) {
        
        if fromHomeBanner {
            let aboutBanner = NSLocalizedString("ABOUT", comment: "ABOUT  in the Museum")
            let tourBanner = NSLocalizedString("TOURS", comment: "TOURS  in the Museum page")
            let travelBanner = NSLocalizedString("TRAVEL_ARRANGEMENTS", comment: "TRAVEL_ARRANGEMENTS  in the Museum page")
            let panelBanner = NSLocalizedString("PANEL_DISCUSSION", comment: "PANEL_DISCUSSION  in the Museum page")
            if (selectedItem == aboutBanner) {
                self.performSegue(withIdentifier: "museumsToAboutSegue", sender: self)
            } else if (selectedItem == tourBanner) {
                self.performSegue(withIdentifier: "museumsToTourAndPanelSegue", sender: self)
                
            } else if (selectedItem == travelBanner) {
                self.performSegue(withIdentifier: "museumsToTourAndPanelSegue", sender: self)
            }
            else if (selectedItem == panelBanner) {
                self.performSegue(withIdentifier: "museumsToTourAndPanelSegue", sender: self)
            }
        } else {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), Selected Item: \(String(describing: selectedItem))")
            if ((selectedItem == "About") || (selectedItem == "عن")) {
                let detailStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let heritageDtlView = detailStoryboard.instantiateViewController(withIdentifier: "heritageDetailViewId2") as! MuseumAboutViewController
                heritageDtlView.pageNameString = PageName2.museumAbout
                heritageDtlView.museumId = museumId
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionFade
                transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                view.window!.layer.add(transition, forKey: kCATransition)
                
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_about,
                    AnalyticsParameterItemName: heritageDtlView.pageNameString ?? "",
                    AnalyticsParameterContentType: "cont"
                    ])
                
                self.present(heritageDtlView, animated: false, completion: nil)
            } else if ((selectedItem == "Audio Guide") || (selectedItem == "الدليل الصوتي")){
                if((museumId == "63") || (museumId == "96") || (museumId == "66") || (museumId == "638")) {
                    let tourGuideView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
                    tourGuideView.exhibitionsPageNameString = ExhbitionPageName.miaTourGuideList
                    tourGuideView.museumId = museumId!
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    view.window!.layer.add(transition, forKey: kCATransition)
                    
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_tourguide,
                        AnalyticsParameterItemName: tourGuideView.exhibitionsPageNameString ?? "",
                        AnalyticsParameterContentType: "cont"
                        ])
                    
                    self.present(tourGuideView, animated: false, completion: nil)
                } else {
                    self.loadComingSoonPopup()
                }
                
            } else if ((selectedItem == "Exhibitions") || (selectedItem == "المعارض")){
                let exhibitionView = self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
                exhibitionView.museumId = museumId
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                exhibitionView.exhibitionsPageNameString = ExhbitionPageName.museumExhibition
                
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_exhibition,
                    AnalyticsParameterItemName: exhibitionView.exhibitionsPageNameString ?? "",
                    AnalyticsParameterContentType: "cont"
                    ])
                
                self.present(exhibitionView, animated: false, completion: nil)
            } else if ((selectedItem == "Collections") || (selectedItem == "المجموعات")){
                let musmCollectionnView = self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
                musmCollectionnView.museumId = museumId
                musmCollectionnView.exhibitionsPageNameString = ExhbitionPageName.museumCollectionsList
                let transition = CATransition()
                transition.duration = 0.3
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_collections,
                    AnalyticsParameterItemName: musmCollectionnView.exhibitionsPageNameString ?? "",
                    AnalyticsParameterContentType: "cont"
                    ])
                
                self.present(musmCollectionnView, animated: false, completion: nil)
            } else if ((selectedItem == "Parks") || (selectedItem == "الحدائق")){
                if((museumId == "66") || (museumId == "638")) {
                    let parkView = self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
                    parkView.exhibitionsPageNameString = ExhbitionPageName.parkList
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.type = kCATransitionFade
                    transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                    view.window!.layer.add(transition, forKey: kCATransition)
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_parks,
                        AnalyticsParameterItemName: parkView.exhibitionsPageNameString ?? "",
                        AnalyticsParameterContentType: "cont"
                        ])
                    self.present(parkView, animated: false, completion: nil)
                } else {
                    let parkView = self.storyboard?.instantiateViewController(withIdentifier: "heritageDetailViewId") as! CommonDetailViewController
                    parkView.pageNameString = PageName.SideMenuPark
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.type = kCATransitionFade
                    transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
                    view.window!.layer.add(transition, forKey: kCATransition)
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_parksside,
                        AnalyticsParameterItemName: parkView.pageNameString ?? "",
                        AnalyticsParameterContentType: "cont"
                        ])
                    self.present(parkView, animated: false, completion: nil)
                }
            } else if((selectedItem == "Dining") || (selectedItem == "الطعام")) {
                let diningView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
                diningView.museumId = museumId
                diningView.fromHome = false
                diningView.fromSideMenu = false
                diningView.exhibitionsPageNameString = ExhbitionPageName.diningList
                let transition = CATransition()
                transition.duration = 0.25
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_dining,
                    AnalyticsParameterItemName: diningView.exhibitionsPageNameString ?? "",
                    AnalyticsParameterContentType: "cont"
                    ])
                self.present(diningView, animated: false, completion: nil)
            }  else if((selectedItem == "Facilities") || (selectedItem == "المرافق")) {
                let tourView =  self.storyboard?.instantiateViewController(withIdentifier: "tourAndPanelId") as! TourAndPanelListViewController
                tourView.pageNameString = NMoQPageName.Facilities
                let transition = CATransition()
                transition.duration = 0.25
                transition.type = kCATransitionPush
                transition.subtype = kCATransitionFromRight
                view.window!.layer.add(transition, forKey: kCATransition)
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_facilities,
                    AnalyticsParameterItemName: tourView.pageNameString ?? "",
                    AnalyticsParameterContentType: "cont"
                    ])
                self.present(tourView, animated: false, completion: nil)
            }else {
                loadComingSoonPopup()
            }
        }
    }
    
}
