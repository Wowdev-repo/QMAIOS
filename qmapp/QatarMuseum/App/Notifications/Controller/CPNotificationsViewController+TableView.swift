//
//  CPNotificationsViewController+TableView.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation

extension CPNotificationsViewController: UITableViewDelegate,UITableViewDataSource {
    //MARK:- TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightValue = UIScreen.main.bounds.height/100
        return heightValue*12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCellId", for: indexPath) as! CPNotificationsTableViewCell
        if ((CPLocalizationLanguage.currentAppleLanguage()) == "en") {
            cell.detailArrowButton.setImage(UIImage(named: "nextImg"), for: .normal)
        } else {
            cell.detailArrowButton.setImage(UIImage(named: "previousImg"), for: .normal)
        }
        if (indexPath.row % 2 == 0) {
            cell.innerView.backgroundColor = UIColor.notificationCellAsh
        } else {
            cell.innerView.backgroundColor = UIColor.white
        }
        
        cell.notificationLabel.text = notificationArray[indexPath.row].title
        cell.notificationDetailSelection = {
            () in
            self.loadNotificationDetail(cellObj: cell)
        }
        loadingView.stopLoading()
        loadingView.isHidden = true
        return cell
    }
    func loadNotificationDetail(cellObj: CPNotificationsTableViewCell) {
        
    }
}
