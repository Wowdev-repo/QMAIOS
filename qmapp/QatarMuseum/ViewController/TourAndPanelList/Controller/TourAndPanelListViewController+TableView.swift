//
//  TourAndPanelListViewController+TableView.swift
//  QatarMuseums
//
//  Created by Exalture on 24/06/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation

extension TourAndPanelListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (pageNameString == NMoQPageName.Tours) {
            return nmoqTourList.count
        } else if (pageNameString == NMoQPageName.PanelDiscussion) {
            return nmoqActivityList.count
        } else if (pageNameString == NMoQPageName.TravelArrangementList) {
            return travelList.count
        } else if (pageNameString == NMoQPageName.Facilities){
            return facilitiesList.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commonListCellId", for: indexPath) as! CommonListCell
        if (pageNameString == NMoQPageName.Tours) {
            cell.setTourListDate(tourList: nmoqTourList[indexPath.row], isTour: true)
        } else if (pageNameString == NMoQPageName.PanelDiscussion){
            cell.setActivityListDate(activityList: nmoqActivityList[indexPath.row])
        } else if (pageNameString == NMoQPageName.TravelArrangementList){
            cell.setTravelListData(travelListData: travelList[indexPath.row])
        } else if (pageNameString == NMoQPageName.Facilities){
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
        if (pageNameString == NMoQPageName.Tours) {
            loadTourViewPage(selectedRow: indexPath.row, isFromTour: true, pageName: NMoQPageName.Tours)
        } else if (pageNameString == NMoQPageName.PanelDiscussion) {
            loadTourViewPage(selectedRow: indexPath.row, isFromTour: false, pageName: NMoQPageName.PanelDiscussion)
        } else if (pageNameString == NMoQPageName.TravelArrangementList) {
            loadTravelDetailPage(selectedIndex: indexPath.row)
        }
        else if (pageNameString == NMoQPageName.Facilities) {
            if((facilitiesList[indexPath.row].nid == "15256") || (facilitiesList[indexPath.row].nid == "15826")) {
                loadTourViewPage(selectedRow: indexPath.row, isFromTour: false, pageName: NMoQPageName.Facilities)
            } else {
                loadPanelDiscussionDetailPage(selectedRow: indexPath.row)
            }
            
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), pageNameString: \(String(describing: pageNameString))")
    }
}
