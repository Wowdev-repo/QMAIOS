//
//  TourAndPanelListViewController+TableView.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation

extension CPTourAndPanelListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (pageNameString == CPNMoQPageName.Tours) {
            return nmoqTourList.count
        } else if (pageNameString == CPNMoQPageName.PanelDiscussion) {
            return nmoqActivityList.count
        } else if (pageNameString == CPNMoQPageName.TravelArrangementList) {
            return travelList.count
        } else if (pageNameString == CPNMoQPageName.Facilities){
            return facilitiesList.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CPCommonListCell
        if (pageNameString == CPNMoQPageName.Tours) {
            cell.setTourListDate(tourList: nmoqTourList[indexPath.row], isTour: true)
        } else if (pageNameString == CPNMoQPageName.PanelDiscussion){
            cell.setActivityListDate(activityList: nmoqActivityList[indexPath.row])
        } else if (pageNameString == CPNMoQPageName.TravelArrangementList){
            cell.setTravelListData(travelListData: travelList[indexPath.row])
        } else if (pageNameString == CPNMoQPageName.Facilities){
            cell.setFacilitiesListData(facilitiesListData: facilitiesList[indexPath.row])
        }
        
        loadingView.stopLoading()
        loadingView.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightValue = UIScreen.main.bounds.height/100
        return heightValue*27
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (pageNameString == CPNMoQPageName.Tours) {
            loadTourViewPage(selectedRow: indexPath.row, isFromTour: true, pageName: CPNMoQPageName.Tours)
        } else if (pageNameString == CPNMoQPageName.PanelDiscussion) {
            loadTourViewPage(selectedRow: indexPath.row, isFromTour: false, pageName: CPNMoQPageName.PanelDiscussion)
        } else if (pageNameString == CPNMoQPageName.TravelArrangementList) {
            loadTravelDetailPage(selectedIndex: indexPath.row)
        }
        else if (pageNameString == CPNMoQPageName.Facilities) {
            if((facilitiesList[indexPath.row].nid == "15256") || (facilitiesList[indexPath.row].nid == "15826")) {
                loadTourViewPage(selectedRow: indexPath.row, isFromTour: false, pageName: CPNMoQPageName.Facilities)
            } else {
                loadPanelDiscussionDetailPage(selectedRow: indexPath.row)
            }
            
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), pageNameString: \(String(describing: pageNameString))")
    }
}
