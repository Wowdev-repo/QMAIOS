//
//  CommonDetailViewController+TableView.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import UIKit
import Firebase

extension CommonDetailViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (pageNameString == PageName.heritageDetail) {
            return heritageDetailtArray.count
        } else if (pageNameString == PageName.publicArtsDetail){
            return publicArtsDetailtArray.count
        } else if (pageNameString == PageName.exhibitionDetail){
            if (fromHome == true) {
                return exhibition.count
            }
        } else if (pageNameString == PageName.SideMenuPark) {
            return parksListArray.count
        } else if (pageNameString == PageName.NMoQPark) {
            return nmoqParkDetailArray.count
        } else if (pageNameString == PageName.DiningDetail) {
            return diningDetailtArray.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadingView.stopLoading()
        loadingView.isHidden = true
        let heritageCell = tableView.dequeueReusableCell(withIdentifier: "heritageDetailCellId", for: indexPath) as! CPCommonDetailCell
        if ((pageNameString == PageName.heritageDetail) || (pageNameString == PageName.publicArtsDetail)) {
            if (pageNameString == PageName.heritageDetail) {
                heritageCell.setHeritageDetailData(heritageDetail: heritageDetailtArray[indexPath.row])
                heritageCell.midTitleDescriptionLabel.textAlignment = .center
            } else if(pageNameString == PageName.publicArtsDetail){
                heritageCell.setPublicArtsDetailValues(publicArsDetail: publicArtsDetailtArray[indexPath.row])
            }
            if (isHeritageImgArrayAvailable() || isPublicArtImgArrayAvailable()) {
                heritageCell.pageControl.isHidden = false
            } else {
                heritageCell.pageControl.isHidden = true
            }
            heritageCell.favBtnTapAction = {
                () in
                self.setFavouritesAction(cellObj: heritageCell)
            }
            heritageCell.shareBtnTapAction = {
                () in
                self.setShareAction(cellObj: heritageCell)
            }
            heritageCell.locationButtonTapAction = {
                () in
                self.loadLocationInMap(currentRow: indexPath.row)
            }
            
        } else if(pageNameString == PageName.exhibitionDetail){
            let cell = tableView.dequeueReusableCell(withIdentifier: "exhibitionDetailCellId", for: indexPath) as! CPExhibitionDetailTableViewCell
            cell.descriptionLabel.textAlignment = .center
            if (fromHome == true) {
                cell.setHomeExhibitionDetail(exhibition: exhibition[indexPath.row])
            } else {
                cell.setMuseumExhibitionDetail()
            }
            cell.favBtnTapAction = {
                () in
                self.setFavouritesAction(cellObj: cell)
            }
            cell.shareBtnTapAction = {
                () in
                self.setShareAction(cellObj: cell)
            }
            cell.locationButtonAction = {
                () in
                self.loadLocationInMap(currentRow: indexPath.row)
            }
            cell.loadEmailComposer = {
                self.openEmail(email:self.exhibition[indexPath.row].mail ?? "info@mia.org.qa")
            }
            cell.loadPhoneNumber = {
                self.dialNumber(number: self.exhibition[indexPath.row].phone ?? "+974 4402 8202")
            }
            
            
            return cell
        } else if(pageNameString == PageName.SideMenuPark){
            let parkCell = tableView.dequeueReusableCell(withIdentifier: "parkCellId", for: indexPath) as! CPParkTableViewCell
            if (indexPath.row != 0) {
                parkCell.titleLineView.isHidden = true
                parkCell.imageViewHeight.constant = 200
                
            }
            else {
                parkCell.titleLineView.isHidden = false
                parkCell.imageViewHeight.constant = 0
            }
            parkCell.favouriteButtonAction = {
                ()in
                self.setFavouritesAction(cellObj: parkCell)
            }
            parkCell.shareButtonAction = {
                () in
            }
            parkCell.locationButtonTapAction = {
                () in
                self.loadLocationInMap(currentRow: indexPath.row)
            }
            parkCell.setParksCellValues(parksList: parksListArray[indexPath.row], currentRow: indexPath.row)
            
            
            
            var latitudeString  = String()
            var longitudeString = String()
            var latitude : Double?
            var longitude : Double?
            if ((pageNameString == PageName.heritageDetail) && (heritageDetailtArray[indexPath.row].latitude != nil) && (heritageDetailtArray[indexPath.row].longitude != nil)) {
                latitudeString = heritageDetailtArray[indexPath.row].latitude!
                longitudeString = heritageDetailtArray[indexPath.row].longitude!
            }
            else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailtArray[indexPath.row].latitude != nil) && (publicArtsDetailtArray[indexPath.row].longitude != nil))
            {
                latitudeString = publicArtsDetailtArray[indexPath.row].latitude!
                longitudeString = publicArtsDetailtArray[indexPath.row].longitude!
            }
            else if (( pageNameString == PageName.exhibitionDetail) && ( self.fromHome == true) && (exhibition[indexPath.row].latitude != nil) && (exhibition[indexPath.row].longitude != nil)) {
                latitudeString = exhibition[indexPath.row].latitude!
                longitudeString = exhibition[indexPath.row].longitude!
            } else if ( pageNameString == PageName.SideMenuPark) {
                // showLocationErrorPopup()
            } else if (( pageNameString == PageName.DiningDetail) && (diningDetailtArray[indexPath.row].latitude != nil) && (diningDetailtArray[indexPath.row].longitude != nil)) {
                latitudeString = diningDetailtArray[indexPath.row].latitude!
                longitudeString = diningDetailtArray[indexPath.row].longitude!
            }
            if latitudeString != nil && longitudeString != nil && latitudeString != "" && longitudeString != ""{
                if (latitudeString != "0° 0\' 0\" N" && longitudeString != "0° 0\' 0\" E")  {
                    if let lat : Double = Double(latitudeString) {
                        latitude = lat
                    }
                    if let long : Double = Double(longitudeString) {
                        longitude = long
                    }
                    
                } else {
                    latitude = convertDMSToDDCoordinate(latLongString: latitudeString)
                    longitude = convertDMSToDDCoordinate(latLongString: longitudeString)
                }
            }
            
            parkCell.setLocationOnMap(lat:latitude ?? 0.0,long:longitude ?? 0.0)
            
            
            
            
            
            
            
            return parkCell
        } else if(pageNameString == PageName.NMoQPark){
            let parkCell = tableView.dequeueReusableCell(withIdentifier: "parkCellId", for: indexPath) as! CPParkTableViewCell
            parkCell.titleLineView.isHidden = false
            parkCell.imageViewHeight.constant = 0
            parkCell.setNmoqParkDetailValues(parkDetails: nmoqParkDetailArray[indexPath.row])
            
            
            var latitudeString  = String()
            var longitudeString = String()
            var latitude : Double?
            var longitude : Double?
            if ((pageNameString == PageName.heritageDetail) && (heritageDetailtArray[indexPath.row].latitude != nil) && (heritageDetailtArray[indexPath.row].longitude != nil)) {
                latitudeString = heritageDetailtArray[indexPath.row].latitude!
                longitudeString = heritageDetailtArray[indexPath.row].longitude!
            }
            else if ((pageNameString == PageName.publicArtsDetail) && (publicArtsDetailtArray[indexPath.row].latitude != nil) && (publicArtsDetailtArray[indexPath.row].longitude != nil))
            {
                latitudeString = publicArtsDetailtArray[indexPath.row].latitude!
                longitudeString = publicArtsDetailtArray[indexPath.row].longitude!
            }
            else if (( pageNameString == PageName.exhibitionDetail) && ( self.fromHome == true) && (exhibition[indexPath.row].latitude != nil) && (exhibition[indexPath.row].longitude != nil)) {
                latitudeString = exhibition[indexPath.row].latitude!
                longitudeString = exhibition[indexPath.row].longitude!
            } else if ( pageNameString == PageName.SideMenuPark) {
                // showLocationErrorPopup()
            } else if (( pageNameString == PageName.DiningDetail) && (diningDetailtArray[indexPath.row].latitude != nil) && (diningDetailtArray[indexPath.row].longitude != nil)) {
                latitudeString = diningDetailtArray[indexPath.row].latitude!
                longitudeString = diningDetailtArray[indexPath.row].longitude!
            }
            if latitudeString != nil && longitudeString != nil && latitudeString != "" && longitudeString != ""{
                if (latitudeString != "0° 0\' 0\" N" && longitudeString != "0° 0\' 0\" E")  {
                    if let lat : Double = Double(latitudeString) {
                        latitude = lat
                    }
                    if let long : Double = Double(longitudeString) {
                        longitude = long
                    }
                    
                } else {
                    latitude = convertDMSToDDCoordinate(latLongString: latitudeString)
                    longitude = convertDMSToDDCoordinate(latLongString: longitudeString)
                }
            }
            
            parkCell.setLocationOnMap(lat:latitude ?? 0.0,long:longitude ?? 0.0)
            
            
            return parkCell
        } else if(pageNameString == PageName.DiningDetail){
            let diningCell = tableView.dequeueReusableCell(withIdentifier: "diningDetailCellId", for: indexPath) as! CPDiningDetailTableViewCell
            diningCell.titleLineView.isHidden = true
            diningCell.setDiningDetailValues(diningDetail: diningDetailtArray[indexPath.row])
            if (isImgArrayAvailable()) {
                diningCell.pageControl.isHidden = false
            } else {
                diningCell.pageControl.isHidden = true
            }
            diningCell.locationButtonAction = {
                ()in
                self.loadLocationInMap(currentRow: indexPath.row)
            }
            diningCell.favBtnTapAction = {
                () in
                self.setFavouritesAction(cellObj: diningCell)
            }
            diningCell.shareBtnTapAction = {
                () in
                self.setShareAction(cellObj: diningCell)
            }
            return diningCell
        }
        return heritageCell
    }
}


extension CommonDetailViewController {
    func setFavouritesAction(cellObj :CPCommonDetailCell) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (cellObj.favoriteButton.tag == 0) {
            cellObj.favoriteButton.tag = 1
            cellObj.favoriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
        } else {
            cellObj.favoriteButton.tag = 0
            cellObj.favoriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
    }
    
    func setShareAction(cellObj :CPCommonDetailCell) {
        
    }
    func setFavouritesAction(cellObj :CPExhibitionDetailTableViewCell) {
    }
    
    func setShareAction(cellObj :CPExhibitionDetailTableViewCell) {
        
    }
    func setFavouritesAction(cellObj :CPParkTableViewCell) {
        if (cellObj.favouriteButton.tag == 0) {
            cellObj.favouriteButton.tag = 1
            cellObj.favouriteButton.setImage(UIImage(named: "heart_fillX1"), for: .normal)
            
        }
        else {
            cellObj.favouriteButton.tag = 0
            cellObj.favouriteButton.setImage(UIImage(named: "heart_emptyX1"), for: .normal)
        }
    }
}
