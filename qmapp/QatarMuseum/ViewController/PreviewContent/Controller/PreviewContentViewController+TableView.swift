
//
//  File.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import UIKit
import Crashlytics
import Firebase

extension PreviewContentViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: TableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tourGuideDict != nil) {
            return 3
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
            let objectImageView = UIImageView()
            objectImageView.frame = CGRect(x: 0, y: 20, width: tableView.frame.width, height: 300)
            objectImageView.image = UIImage(named: "default_imageX2")
            if let imageUrl = tourGuideDict.image {
                objectImageView.kf.setImage(with: URL(string: imageUrl))
            }
            if(objectImageView.image == nil) {
                objectImageView.image = UIImage(named: "default_imageX2")
            }
            
            objectImageView.backgroundColor = UIColor.white
            objectImageView.contentMode = .scaleAspectFit
            objectImageView.clipsToBounds = true
            cell.addSubview(objectImageView)
            cell.selectionStyle = .none
            objectImageView.isUserInteractionEnabled = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "objectDetailCellId", for: indexPath) as! ObjectDetailTableViewCell
            if (indexPath.row == 1) {
                cell.setObjectDetail(objectDetail: tourGuideDict)
            } else if (indexPath.row == 2) {
                cell.setObjectHistoryDetail(historyDetail: tourGuideDict)
            }
            
            cell.favBtnTapAction = {
                () in
                self.setFavouritesAction(cellObj: cell)
            }
            cell.shareBtnTapAction = {
                () in
                self.setShareAction(cellObj: cell)
            }
            cell.playBtnTapAction = {
                () in
                self.setPlayButtonAction(cellObj: cell)
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if((indexPath.row == 0) && (tourGuideDict.image != "")) {
            if let imageUrl = tourGuideDict.image {
                self.loadObjectImagePopup(imgName: imageUrl )
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_floormap_loadmap,
                    AnalyticsParameterItemName: imageUrl,
                    AnalyticsParameterContentType: "cont"
                    ])
            }
            
        }
    }
}
