//
//  PanelDiscussionDetailViewController+Tableview.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 21/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
extension PanelDiscussionDetailViewController : UITableViewDelegate,UITableViewDataSource {
    
    func registerCell() {
        self.panelDetailTableView.register(UINib(nibName: "PanelDetailView", bundle: nil), forCellReuseIdentifier: "customPanelCellIdentifier")
        self.panelDetailTableView.register(UINib(nibName: "CollectionDetailView", bundle: nil), forCellReuseIdentifier: "collectionCellId")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(pageNameString == NMoQPanelPage.PanelDetailPage) {
            if(nmoqTourDetail[selectedRow!] != nil) {
                return 1
            }
        } else if(pageNameString == NMoQPanelPage.TourDetailPage){
            //return nmoqTourDetail.count
            if(nmoqTourDetail[selectedRow!] != nil) {
                return 1
            }
        } else if(pageNameString == NMoQPanelPage.FacilitiesDetailPage){
            if(facilitiesDetail.count  > 0) {
                return 1
            }
        } else if(pageNameString == NMoQPanelPage.CollectionDetail) {
            return collectionDetailArray.count
        } else if(pageNameString == NMoQPanelPage.PlayGroundPark) {
            return nmoqParkDetailArray.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.loadingView.stopLoading()
        self.loadingView.isHidden = true
        print(indexPath)
        if let cell = tableView.dequeueReusableCell(withIdentifier: "customPanelCellIdentifier", for: indexPath) as? myCustomPanelCell {
            cell.selectionStyle = .none
            if(self.pageNameString == NMoQPanelPage.PanelDetailPage) {
                //cell.setPanelDetailCellContent(panelDetailData: nmoqSpecialEventDetail[indexPath.row])
                cell.setTourSecondDetailCellContent(tourDetailData: self.nmoqTourDetail[self.selectedRow!], userEventList: self.userEventList, fromTour: false)
                //cell.topDescription.textAlignment = .left
                //cell.descriptionLeftConstraint.constant = 30
                cell.registerOrUnRegisterAction = {
                    () in
                    self.selectedPanelCell = cell
                    self.currentPanelRow = indexPath.row
                    self.reisterOrUnregisterTapAction(currentRow: indexPath.row, selectedCell: cell)
                }
                cell.loadMapView = {
                    () in
                    //                self.loadLocationMap(tourDetail: self.nmoqTourDetail[indexPath.row])
                    self.loadLocationMap(mobileLatitude: self.nmoqTourDetail[indexPath.row].mobileLatitude, mobileLongitude: self.nmoqTourDetail[indexPath.row].longitude)
                }
                
                cell.loadEmailComposer = {
                    self.openEmail(email:self.nmoqTourDetail[indexPath.row].contactEmail ?? "info@mia.org.qa")
                }
                cell.callPhone = {
                    self.dialNumber(number: self.nmoqTourDetail[indexPath.row].contactPhone ?? "+974 4402 8202")
                }
                
            } else if (self.pageNameString == NMoQPanelPage.TourDetailPage){
                cell.setTourSecondDetailCellContent(tourDetailData: self.nmoqTourDetail[self.selectedRow!], userEventList: self.userEventList, fromTour: true)
                //            cell.topDescription.textAlignment = .left
                //            cell.descriptionLeftConstraint.constant = 30
                cell.registerOrUnRegisterAction = {
                    () in
                    self.selectedPanelCell = cell
                    self.currentPanelRow = self.selectedRow
                    self.reisterOrUnregisterTapAction(currentRow: self.selectedRow!, selectedCell: cell)
                }
                cell.loadMapView = {
                    () in
                    //self.loadLocationMap(tourDetail: self.nmoqTourDetail[self.selectedRow!])
                    self.loadLocationMap(mobileLatitude: self.nmoqTourDetail[self.selectedRow!].mobileLatitude, mobileLongitude: self.nmoqTourDetail[self.selectedRow!].longitude)
                }
                
                cell.loadEmailComposer = {
                    self.openEmail(email:self.nmoqTourDetail[indexPath.row].contactEmail ?? "info@mia.org.qa")
                }
                cell.callPhone = {
                    self.dialNumber(number: self.nmoqTourDetail[indexPath.row].contactPhone ?? "+974 4402 8202")
                }
            } else if(self.pageNameString == NMoQPanelPage.FacilitiesDetailPage) {
                if(self.fromCafeOrDining!) {
                    cell.setFacilitiesDetailData(facilitiesDetailData: self.facilitiesDetail[self.selectedRow!])
                    cell.loadMapView = {
                        () in
                        self.loadLocationMap(mobileLatitude: self.facilitiesDetail[self.selectedRow!].latitude, mobileLongitude: self.facilitiesDetail[self.selectedRow!].longtitude)
                    }
                } else {
                    cell.setFacilitiesDetailData(facilitiesDetailData: self.facilitiesDetail[indexPath.row])
                    cell.loadMapView = {
                        () in
                        self.loadLocationMap(mobileLatitude: self.facilitiesDetail[indexPath.row].latitude, mobileLongitude: self.facilitiesDetail[indexPath.row].longtitude)
                    }
                }
                
            } else if(self.pageNameString == NMoQPanelPage.CollectionDetail) {
                if let collectionCell = tableView.dequeueReusableCell(withIdentifier: "collectionCellId", for: indexPath) as? CollectionDetailCell {
                    collectionCell.favouriteHeight.constant = 0
                    collectionCell.favouriteView.isHidden = true
                    collectionCell.shareView.isHidden = true
                    collectionCell.favouriteButton.isHidden = true
                    collectionCell.shareButton.isHidden = true
                    collectionCell.selectionStyle = .none
                    collectionCell.favouriteButtonAction = {
                        () in
                    }
                    collectionCell.shareButtonAction = {
                        () in
                    }
                    collectionCell.setCollectionCellValues(collectionValues: self.collectionDetailArray[indexPath.row], currentRow: indexPath.row)
                    return collectionCell
                }
            } else {
                if let collectionCell = tableView.dequeueReusableCell(withIdentifier: "collectionCellId", for: indexPath) as? CollectionDetailCell {
                    collectionCell.selectionStyle = .none
                    collectionCell.setParkPlayGroundValues(parkPlaygroundDetails: self.nmoqParkDetailArray[indexPath.row])
                    return collectionCell
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(pageNameString == NMoQPanelPage.PanelDetailPage) {
            return UITableViewAutomaticDimension
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
}
