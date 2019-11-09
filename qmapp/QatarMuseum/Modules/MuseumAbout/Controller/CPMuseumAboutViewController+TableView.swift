//
//  CPMuseumAboutViewController+TableView.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Firebase
import  MapKit
import MessageUI
import UIKit

extension CPMuseumAboutViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ((pageNameString == PageName2.museumAbout) || (pageNameString == PageName2.museumEvent)){
            if(aboutDetailtArray.count > 0) {
                return aboutDetailtArray.count
                // return 1
            } else {
                return 0
            }
            
        } else  if (pageNameString == PageName2.museumTravel){
            return 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let heritageCell = tableView.dequeueReusableCell(withIdentifier: "heritageDetailCellId2", for: indexPath) as! CPMuseumAboutCell
        if(pageNameString == PageName2.museumAbout){
            heritageCell.setMuseumAboutCellData(aboutData: aboutDetailtArray[indexPath.row])
            // heritageCell.setMuseumAboutCellData(aboutData: aboutDetailtArray[0])
            if (isImgArrayAvailable()) {
                heritageCell.pageControl.isHidden = false
            } else {
                heritageCell.pageControl.isHidden = true
            }
            heritageCell.downloadBtnTapAction = {
                () in
                self.downloadButtonAction()
            }
            heritageCell.loadEmailComposer = {
                self.openEmail(email:self.aboutDetailtArray[indexPath.row].contactEmail ?? "info@mia.org.qa")
            }
            heritageCell.callPhone = {
                self.dialNumber(number: self.aboutDetailtArray[indexPath.row].contactNumber ?? "+974 4402 8202")
            }
        } else if(pageNameString == PageName2.museumEvent){
            heritageCell.videoOuterView.isHidden = true
            heritageCell.videoOuterViewHeight.constant = 0
            heritageCell.setNMoQAboutCellData(aboutData: aboutDetailtArray[indexPath.row])
            // heritageCell.setMuseumAboutCellData(aboutData: aboutDetailtArray[0])
            heritageCell.pageControl.isHidden = false
            heritageCell.downloadBtnTapAction = {
                () in
                self.downloadButtonAction()
            }
            heritageCell.loadEmailComposer = {
                self.openEmail(email:self.aboutDetailtArray[indexPath.row].contactEmail ?? "info@mia.org.qa")
            }
            heritageCell.callPhone = {
                self.dialNumber(number: self.aboutDetailtArray[indexPath.row].contactNumber ?? "+974 4402 8202")
            }
        } else if(pageNameString == PageName2.museumTravel){
            heritageCell.videoOuterView.isHidden = true
            heritageCell.selectionStyle = .none
            heritageCell.videoOuterViewHeight.constant = 0
            heritageCell.setNMoQTravelCellData(travelDetailData: travelDetail!)
            heritageCell.pageControl.isHidden = true
            heritageCell.claimOfferBtnTapAction = {
                () in
                self.claimOfferButtonAction(offerLink: self.travelDetail?.claimOffer)
            }
            heritageCell.loadEmailComposer = {
                self.openEmail(email:self.travelDetail?.email ?? "info@mia.org.qa")
            }
            heritageCell.callPhone = {
                self.dialNumber(number: self.travelDetail?.contactNumber ?? "+974 4402 8202")
            }
        }
        
        heritageCell.favBtnTapAction = {
            () in
            // self.setFavouritesAction(cellObj: heritageCell)
        }
        heritageCell.shareBtnTapAction = {
            () in
            // self.setShareAction(cellObj: heritageCell)
        }
        heritageCell.locationButtonTapAction = {
            () in
            self.loadLocationInMap(currentRow: indexPath.row)
        }
        heritageCell.loadMapView = {
            () in
            if (self.aboutDetailtArray[0].mobileLatitude != nil && self.aboutDetailtArray[0].mobileLatitude != "" && self.aboutDetailtArray[0].mobileLongtitude != nil && self.aboutDetailtArray[0].mobileLongtitude != "") {
                let latitudeString = (self.aboutDetailtArray[0].mobileLatitude)!
                let longitudeString = (self.aboutDetailtArray[0].mobileLongtitude)!
                var latitude : Double?
                var longitude : Double?
                if let lat : Double = Double(latitudeString) {
                    latitude = lat
                }
                if let long : Double = Double(longitudeString) {
                    longitude = long
                }
                
                let destinationLocation = CLLocationCoordinate2D(latitude: latitude!,
                                                                 longitude: longitude!)
                let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                self.loadLocationMap(currentRow: indexPath.row, destination: destinationMapItem)
            }
        }
        heritageCell.loadAboutVideo = {
            () in
            self.showVideoInAboutPage(currentRow: indexPath.row)
        }
        selectedCell = heritageCell
        loadingView.stopLoading()
        loadingView.isHidden = true
        return heritageCell
    }
    
    //    func setFavouritesAction(cellObj :HeritageDetailCell) {
    //        if (cellObj.favoriteButton.tag == 0) {
    //            cellObj.favoriteButton.tag = 1
    //            cellObj.favoriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
    //        } else {
    //            cellObj.favoriteButton.tag = 0
    //            cellObj.favoriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
    //        }
    //    }
    
    //    func setShareAction(cellObj :HeritageDetailCell) {
    //
    //    }
}
