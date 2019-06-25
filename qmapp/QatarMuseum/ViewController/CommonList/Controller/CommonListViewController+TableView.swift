//
//  CommonListViewController+TableView.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
import Crashlytics
import Firebase

extension CommonListViewController: UITableViewDelegate,UITableViewDataSource, UICollectionViewDelegateFlowLayout {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch exhibitionsPageNameString {
        case .homeExhibition?:
            return exhibition.count
        case .museumExhibition?:
            return exhibition.count
        case .heritageList?:
            return heritageListArray.count
        case .publicArtsList?:
            return publicArtsListArray.count
        case .museumCollectionsList?:
            return collection.count
        case .diningList?:
            return diningListArray.count
        case .nmoqTourSecondList?:
            return nmoqTourDetail.count
        case .facilitiesSecondList?:
            return facilitiesDetail.count
        case .miaTourGuideList?:
            if (miaTourDataFullArray.count > 0) {
                return miaTourDataFullArray.count+1
            }
            return 0
        case .tourGuideList?:
            if(museumsList.count > 0) {
                return museumsList.count+1
            }
            return 0
        case .parkList?:
            if (nmoqParkList.count > 0) {
                return 2 + nmoqParks.count
            }
            return 0
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        exbtnLoadingView.stopLoading()
        exbtnLoadingView.isHidden = true
        if ((exhibitionsPageNameString == ExhbitionPageName.homeExhibition) || (exhibitionsPageNameString == ExhbitionPageName.museumExhibition)) {
            let exhibitionCell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
            exhibitionCell.setExhibitionCellValues(exhibition: exhibition[indexPath.row])
            exhibitionCell.exhibitionCellItemBtnTapAction = {
                () in
                self.loadExhibitionCellPages(cellObj: exhibitionCell, selectedIndex: indexPath.row)
            }
            exhibitionCell.selectionStyle = .none
            
            return exhibitionCell
        } else if (exhibitionsPageNameString == ExhbitionPageName.heritageList) {
            let heritageCell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
            heritageCell.setHeritageListCellValues(heritageList: heritageListArray[indexPath.row])
            return heritageCell
        } else if (exhibitionsPageNameString == ExhbitionPageName.publicArtsList) {
            let publicArtsCell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
            publicArtsCell.setPublicArtsListCellValues(publicArtsList: publicArtsListArray[indexPath.row])
            return publicArtsCell
        } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList) {
            let collectionsCell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
            collectionsCell.setCollectionsCellValues(collectionList: collection[indexPath.row])
            return collectionsCell
        } else if (exhibitionsPageNameString == ExhbitionPageName.diningList) {
            let diningListCell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
            diningListCell.setDiningListValues(diningList: diningListArray[indexPath.row])
            return diningListCell
        } else if (exhibitionsPageNameString == ExhbitionPageName.nmoqTourSecondList){
            let nmoqTourSecondListCell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
            nmoqTourSecondListCell.setTourMiddleDate(tourList: nmoqTourDetail[indexPath.row])
            return nmoqTourSecondListCell
        } else if (exhibitionsPageNameString == ExhbitionPageName.facilitiesSecondList){
            let facilitiesSecondListCell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
            facilitiesSecondListCell.setFacilitiesDetail(FacilitiesDetailData: facilitiesDetail[indexPath.row])
            return facilitiesSecondListCell
        } else if (exhibitionsPageNameString == ExhbitionPageName.miaTourGuideList){
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "miaHeaderId", for: indexPath) as! MiaCollectionReusableView
                cell.selectionStyle = .none
                if (miaTourDataFullArray.count > 0) {
                    if((museumId == "66") || (museumId == "638")) {
                        cell.setNMoQHeaderData()
                    } else {
                        cell.setHeader()
                        cell.exploreButtonTapAction = {
                            () in
                            self.exploreButtonAction()
                        }
                    }
                }
                return cell
            } else {
                let tourGuideCell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
                tourGuideCell.setScienceTourGuideCellData(homeCellData: miaTourDataFullArray[indexPath.row-1])
                return tourGuideCell
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.tourGuideList){
            if (indexPath.row == 0) {
                let cell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "miaHeaderId", for: indexPath) as! MiaCollectionReusableView
                cell.selectionStyle = .none
                cell.setTourHeader()
                return cell
            } else {
                let cell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
                cell.tourGuideImage.image = UIImage(named: "location")
                cell.setTourGuideCellData(museumsListData: museumsList[indexPath.row - 1])
                return cell
            }
        } else {
            if (indexPath.row == 0) {
                let cell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "parkTopCellId", for: indexPath) as! NMoQParkTopTableViewCell
                cell.setTopCellDescription(topDescription: nmoqParkList[0].mainDescription)
                return cell
            } else if indexPath.row > nmoqParks.count {
                let parkListSecondCell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "parkListCellId", for: indexPath) as! ParkListTableViewCell
                parkListSecondCell.selectionStyle = .none
                parkListSecondCell.setParkListValues(parkListData: nmoqParkList[0])
                parkListSecondCell.loadMapView = {
                    () in
                    self.loadLocationMap(mobileLatitude: self.nmoqParkList[0].latitude, mobileLongitude: self.nmoqParkList[0].longitude)
                }
                return parkListSecondCell
            } else {
                let parkListCell = exhibitionCollectionView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
                parkListCell.selectionStyle = .none
                if (nmoqParks.count > 0) {
                    parkListCell.setParkListData(parkList: nmoqParks[indexPath.row - 1])
                }
                
                return parkListCell
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((exhibitionsPageNameString == ExhbitionPageName.miaTourGuideList) || (exhibitionsPageNameString == ExhbitionPageName.tourGuideList)) {
            if (indexPath.row == 0) {
                return UITableViewAutomaticDimension
            } else {
                let heightValue = UIScreen.main.bounds.height/100
                return heightValue*27
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.parkList) {
            if ((indexPath.row != 0) && (indexPath.row <= nmoqParks.count)) {
                let heightValue = UIScreen.main.bounds.height/100
                return heightValue*27
            } else if(indexPath.row == 0) {
                if((nmoqParkList[0].mainDescription == nil) || (nmoqParkList[0].mainDescription?.trimmingCharacters(in: NSCharacterSet.whitespaces) == "")) {
                    return 0
                }
            }
            return UITableViewAutomaticDimension
        } else {
            let heightValue = UIScreen.main.bounds.height/100
            return heightValue*27
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        if ((exhibitionsPageNameString == ExhbitionPageName.homeExhibition) || (exhibitionsPageNameString == ExhbitionPageName.museumExhibition)) {
            if let exhibitionId = exhibition[indexPath.row].id {
                DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), ExhibitionId: \(String(describing: exhibition[indexPath.row].id))")
                self.performSegue(withIdentifier: "commonListToDetailSegue", sender: self)
                loadExhibitionDetailAnimation(exhibitionId: exhibitionId)
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_exhibition_detail,
                    AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                    AnalyticsParameterContentType: "cont"
                    ])
            }
            else {
                addComingSoonPopup()
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.heritageList) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
            self.performSegue(withIdentifier: "commonListToDetailSegue", sender: self)
            let heritageId = heritageListArray[indexPath.row].id
            loadHeritageDetail(heritageListId: heritageId!)
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_heritage_detail,
                AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                AnalyticsParameterContentType: "cont"
                ])
        } else if (exhibitionsPageNameString == ExhbitionPageName.publicArtsList) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
            loadPublicArtsDetail(idValue: publicArtsListArray[indexPath.row].id ?? "")
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_publicart_detail,
                AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                AnalyticsParameterContentType: "cont"
                ])
        } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
            loadCollectionDetail(currentRow: indexPath.row)
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_collections_detail,
                AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                AnalyticsParameterContentType: "cont"
                ])
        } else if (exhibitionsPageNameString == ExhbitionPageName.diningList) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
            let diningId = diningListArray[indexPath.row].id
            loadDiningDetailAnimation(idValue: diningId!)
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_dining_detail,
                AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                AnalyticsParameterContentType: "cont"
                ])
        }  else if (exhibitionsPageNameString == ExhbitionPageName.nmoqTourSecondList) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
            self.performSegue(withIdentifier: "commonListToPanelDetailSegue", sender: self)
        } else if (exhibitionsPageNameString == ExhbitionPageName.miaTourGuideList) {
            if (indexPath.row != 0) {
                DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
                self.performSegue(withIdentifier: "commonListToMiaTourSegue", sender: self)
            }
        }
        else if (exhibitionsPageNameString == ExhbitionPageName.facilitiesSecondList) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
            self.performSegue(withIdentifier: "commonListToPanelDetailSegue", sender: self)
            //                loadMiaTourDetail(currentRow: indexPath.row - 1)
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_miatour_detail,
                AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                AnalyticsParameterContentType: "cont"
                ])
        }
        else if (exhibitionsPageNameString == ExhbitionPageName.facilitiesSecondList) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
            loadTourSecondDetailPage(selectedRow: indexPath.row, fromTour: false, pageName: ExhbitionPageName.facilitiesSecondList)
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_facilities_second_detail,
                AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                AnalyticsParameterContentType: "cont"
                ])
        } else if (exhibitionsPageNameString == ExhbitionPageName.tourGuideList) {
            if (indexPath.row != 0) {
                if (museumsList != nil) {
                    if(((museumsList[indexPath.row - 1].id) == "63") || ((museumsList[indexPath.row - 1].id) == "96") || /*((museumsList[indexPath.row - 1].id) == "61") || ((museumsList[indexPath.row - 1].id) == "635") ||*/ ((museumsList[indexPath.row - 1].id) == "66") || ((museumsList[indexPath.row - 1].id) == "638")) {
                        loadMiaTour(currentRow: indexPath.row - 1)
                        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
                        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), Museum ID: \(String(describing: museumsList[indexPath.row].id))")
                    } else {
                        addComingSoonPopup(isTourGuide: true)
                    }
                    
                    Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                        AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_miatourlist_detail,
                        AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                        AnalyticsParameterContentType: "cont"
                        ])
                }
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.parkList) {
            if ((nmoqParks.count > 0) && (indexPath.row != 0) && (indexPath.row != 3)) {
                if((nmoqParks[indexPath.row - 1].nid == "15616") || (nmoqParks[indexPath.row - 1].nid == "15851")) {
                    DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
                    self.performSegue(withIdentifier: "commonListToPanelDetailSegue", sender: self)
                } else {
                    DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
                    self.performSegue(withIdentifier: "commonListToDetailSegue", sender: self)
                }
                
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_parklist_detail,
                    AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                    AnalyticsParameterContentType: "cont"
                    ])
            }
        }
        
        
    }

}
