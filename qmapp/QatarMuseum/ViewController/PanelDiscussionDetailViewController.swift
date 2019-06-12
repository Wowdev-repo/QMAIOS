//
//  PanelDiscussionDetailViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 01/12/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import Alamofire
import CoreData
import EventKit
import MapKit
import MessageUI
import Firebase
import UIKit
import KeychainSwift
import CocoaLumberjack

enum NMoQPanelPage {
    case PanelDetailPage
    case TourDetailPage
    case FacilitiesDetailPage
    case PlayGroundPark
    case CollectionDetail
}
class PanelDiscussionDetailViewController: UIViewController,LoadingViewProtocol,UITableViewDelegate,UITableViewDataSource,HeaderViewProtocol,comingSoonPopUpProtocol,DeclinePopupProtocol, MFMailComposeViewControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate,EventPopUpProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var overlayView: UIView!
    var panelTitle : String? = ""
    var pageNameString : NMoQPanelPage?
    var panelDetailId : String? = nil
    var nmoqSpecialEventDetail: [NMoQTour]! = []
    var nmoqTourDetail: [NMoQTourDetail]! = []
    var entityRegistration : NMoQEntityRegistration?
    var completedEntityReg : NMoQEntityRegistration?
    var userEventList: [NMoQUserEventList]! = []
    var facilitiesDetail = [FacilitiesDetail]()
    var collectionDetailArray: [CollectionDetail]! = []
    var nmoqParkDetailArray: [NMoQParkDetail]! = []
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var selectedRow : Int?
    var unRegisterPopupView : AcceptDeclinePopup = AcceptDeclinePopup()
    var selectedPanelCell : PanelDetailCell?
    var newRegistrationId : String? = nil
    var picker = UIPickerView()
    let toolBar = UIToolbar()
    var countArray = [String]()
    var currentPanelRow : Int?
    var selectedCount : String? = "1"
    var addToCalendarPopup : EventPopupView = EventPopupView()
    let store = EKEventStore()
    var fromCafeOrDining : Bool? = false
    var collectionName: String? = nil
    var nid: String? = nil
    let networkReachability = NetworkReachabilityManager()
    
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")

        super.viewDidLoad()
        registerCell()
        setupUI()
        self.recordScreenView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func setupUI() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        headerView.headerViewDelegate = self
        overlayView.isHidden = true
        headerView.headerBackButton.setImage(UIImage(named: "closeX1"), for: .normal)
        headerView.headerBackButton.contentEdgeInsets = UIEdgeInsets(top:12, left:17, bottom: 12, right:17)
        if((pageNameString == NMoQPanelPage.PanelDetailPage) || (pageNameString == NMoQPanelPage.TourDetailPage)) {
            fetchUserEventListFromCoredata()
            countArray = ["1","2","3","4","5"]
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissOverlay))
            tap.delegate = self // This is not required
            overlayView.addGestureRecognizer(tap)
        }
        else if((pageNameString == NMoQPanelPage.FacilitiesDetailPage) && (fromCafeOrDining == false)){
            if (networkReachability?.isReachable)! {
                getFacilitiesDetail()
            } else {
                fetchFacilitiesDetailsFromCoredata()
            }
        } else if(pageNameString == NMoQPanelPage.PlayGroundPark) {
            NotificationCenter.default.addObserver(self, selector: #selector(PanelDiscussionDetailViewController.receiveNmoqParkDetailNotificationEn(notification:)), name: NSNotification.Name(nmoqParkDetailNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(PanelDiscussionDetailViewController.receiveNmoqParkDetailNotificationAr(notification:)), name: NSNotification.Name(nmoqParkDetailNotificationAr), object: nil)
            if  (networkReachability?.isReachable)! {
                getNMoQParkDetailFromServer()
            } else {
                // self.fetchNMoQParkDetailFromCoredata()
                self.showNoNetwork()
            }
        } else if(pageNameString == NMoQPanelPage.CollectionDetail) {
            if  (networkReachability?.isReachable)! {
                getCollectioDetailsFromServer()
            } else {
                self.fetchCollectionDetailsFromCoredata()
            }
        }
        
    }
    func registerCell() {
        self.tableView.register(UINib(nibName: "PanelDetailView", bundle: nil), forCellReuseIdentifier: "panelCellID")
        self.tableView.register(UINib(nibName: "CollectionDetailView", bundle: nil), forCellReuseIdentifier: "collectionCellId")
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
        loadingView.stopLoading()
        loadingView.isHidden = true
        let cell = tableView.dequeueReusableCell(withIdentifier: "panelCellID", for: indexPath) as! PanelDetailCell
        cell.selectionStyle = .none
        if(pageNameString == NMoQPanelPage.PanelDetailPage) {
            //cell.setPanelDetailCellContent(panelDetailData: nmoqSpecialEventDetail[indexPath.row])
            cell.setTourSecondDetailCellContent(tourDetailData: nmoqTourDetail[self.selectedRow!], userEventList: userEventList, fromTour: false)
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
                self.openEmail(email:self.nmoqTourDetail[indexPath.row].contactEmail ?? "nmoq@qm.org.qa")
            }
            cell.callPhone = {
                self.dialNumber(number: self.nmoqTourDetail[indexPath.row].contactPhone ?? "+974 4402 8202")
            }
            
        } else if (pageNameString == NMoQPanelPage.TourDetailPage){
            cell.setTourSecondDetailCellContent(tourDetailData: nmoqTourDetail[self.selectedRow!], userEventList: userEventList, fromTour: true)
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
                self.openEmail(email:self.nmoqTourDetail[indexPath.row].contactEmail ?? "nmoq@qm.org.qa")
            }
            cell.callPhone = {
                self.dialNumber(number: self.nmoqTourDetail[indexPath.row].contactPhone ?? "+974 4402 8202")
            }
        } else if(pageNameString == NMoQPanelPage.FacilitiesDetailPage) {
            if(fromCafeOrDining!) {
                cell.setFacilitiesDetailData(facilitiesDetailData: facilitiesDetail[selectedRow!])
                cell.loadMapView = {
                    () in
                    //self.loadLocationMap(tourDetail: self.facilitiesDetail![self.selectedRow!])
                    self.loadLocationMap(mobileLatitude: self.facilitiesDetail[self.selectedRow!].latitude, mobileLongitude: self.facilitiesDetail[self.selectedRow!].longtitude)
                }
            } else {
                cell.setFacilitiesDetailData(facilitiesDetailData: facilitiesDetail[indexPath.row])
                cell.loadMapView = {
                    () in
                    //self.loadLocationMap(tourDetail: self.facilitiesDetail![indexPath.row])
                    self.loadLocationMap(mobileLatitude: self.facilitiesDetail[indexPath.row].latitude, mobileLongitude: self.facilitiesDetail[indexPath.row].longtitude)
                }
            }
           
        } else if(pageNameString == NMoQPanelPage.CollectionDetail) {
            let collectionCell = tableView.dequeueReusableCell(withIdentifier: "collectionCellId", for: indexPath) as! CollectionDetailCell
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
            collectionCell.setCollectionCellValues(collectionValues: collectionDetailArray[indexPath.row], currentRow: indexPath.row)
            return collectionCell
        } else {
            let collectionCell = tableView.dequeueReusableCell(withIdentifier: "collectionCellId", for: indexPath) as! CollectionDetailCell
            collectionCell.selectionStyle = .none
            collectionCell.setParkPlayGroundValues(parkPlaygroundDetails: nmoqParkDetailArray[indexPath.row])
            return collectionCell
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(pageNameString == NMoQPanelPage.PanelDetailPage) {
            return UITableViewAutomaticDimension
        } else {
            return UITableViewAutomaticDimension
        }
    }

    func loadLocationMap( mobileLatitude: String?, mobileLongitude: String? ) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), Latitude:\(String(describing: mobileLatitude)), Longitude:\(String(describing: mobileLongitude))")
        if (mobileLatitude != nil && mobileLatitude != "" && mobileLongitude != nil && mobileLongitude != "") {
            let latitudeString = (mobileLatitude)!
            let longitudeString = (mobileLongitude)!
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
            let destination = MKMapItem(placemark: destinationPlacemark)
            let mapDetailView = self.storyboard?.instantiateViewController(withIdentifier: "mapViewId") as! MapViewController
            mapDetailView.latitudeString = mobileLatitude
            mapDetailView.longiudeString = mobileLongitude
            mapDetailView.destination = destination
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            view.window!.layer.add(transition, forKey: kCATransition)
            self.present(mapDetailView, animated: false, completion: nil)
        }
        else {
            showLocationErrorPopup()
        }
    }
    func reisterOrUnregisterTapAction(currentRow: Int,selectedCell : PanelDetailCell?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (networkReachability?.isReachable)! {
            if (selectedCell?.registerButton.tag == 0) {
                let time = nmoqTourDetail[currentRow].date?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                let timeArray = time?.components(separatedBy: "-")
                if((timeArray?.count)! != 3) {
                    self.loadNoEndTimePopup()
                }else {
   //                 if(userEventList.count == 0) {
                        addPickerView()
//                    } else {
//                        let haveConflict = checkConflictWithAlreadyRegisteredEvent(currentRow: currentRow)
//                        if((haveConflict == false) || (haveConflict == nil)) {
//                            addPickerView()
//                        } else {
//                            loadAlreadyRegisteredPopup()
//                        }
//                    }
                }
            } else {
                loadConfirmationPopup()
            }
        } else {
            self.view.hideAllToasts()
            let noNetworkMessage =  NSLocalizedString("CHECK_NETWORK", comment: "CHECK_NETWORK")
            self.view.makeToast(noNetworkMessage)
        }
        
    }
    func headerCloseButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_header_close,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
        self.dismiss(animated: false, completion: nil)
    }
    
    func showNodata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        var errorMessage: String
        errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                        comment: "Setting the content of the alert"))
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoDataView()
        self.loadingView.noDataLabel.text = errorMessage
    }
    
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if  (networkReachability?.isReachable)! {
            if((pageNameString == NMoQPanelPage.FacilitiesDetailPage) && (fromCafeOrDining == false)){
                self.getFacilitiesDetail()
            } else if(pageNameString == NMoQPanelPage.CollectionDetail) {
                self.getCollectioDetailsFromServer()
            }
            
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_museum_tryagain,
                AnalyticsParameterItemName: "",
                AnalyticsParameterContentType: "cont"
                ])
        }
    }
    
    func showNoNetwork() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    //MARK: WebService Call
    func getNMoQSpecialEventDetail() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if(panelDetailId != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQSpecialEventDetail(["event_id" : panelDetailId!])).responseObject { (response: DataResponse<NMoQTourList>) -> Void in
                switch response.result {
                case .success(let data):
                    self.nmoqSpecialEventDetail = data.nmoqTourList
                    self.tableView.reloadData()
                    if(self.nmoqSpecialEventDetail.count == 0) {
                        let noResultMsg = NSLocalizedString("NO_RESULT_MESSAGE",
                                                            comment: "Setting the content of the alert")
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                        self.loadingView.noDataLabel.text = noResultMsg
                    }
                case .failure( _):
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                    self.loadingView.noDataLabel.text = errorMessage
                }
            }
        }
    }
    func getNMoQTourDetail() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if(panelDetailId != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQTourDetail(["event_id" : panelDetailId!])).responseObject { (response: DataResponse<NMoQTourDetailList>) -> Void in
                switch response.result {
                case .success(let data):
                    self.nmoqTourDetail = data.nmoqTourDetailList
                    //self.saveOrUpdateHomeCoredata()
                    self.tableView.reloadData()
                    if(self.nmoqTourDetail.count == 0) {
                        let noResultMsg = NSLocalizedString("NO_RESULT_MESSAGE",
                                                            comment: "Setting the content of the alert")
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                        self.loadingView.noDataLabel.text = noResultMsg
                    }
                case .failure( _):
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                    self.loadingView.noDataLabel.text = errorMessage
                }
            }
        }
        
    }
    
    //MARK: EntityRegistration API
    func getEntityRegistrationFromServer(currentRow: Int,selectedCell: PanelDetailCell?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let time = getTimeStamp(currentRow: currentRow)
        if (time.startTime != nil && time.endTime != nil) {
            
         if((nmoqTourDetail[currentRow].nid != nil) && (keychain.get(UserProfileInfo.user_id)) != nil) && ((keychain.get(UserProfileInfo.user_firstname) != nil) && (keychain.get(UserProfileInfo.user_lastname) != nil)) {
        let entityId = nmoqTourDetail[currentRow].nid
        let userId = keychain.get(UserProfileInfo.user_id)!
        let firstName = (keychain.get(UserProfileInfo.user_firstname))!
        let lastName = (keychain.get(UserProfileInfo.user_lastname))!
        let fieldConfirmAttendance =
            [
                "und":[[
                    "value": "1"
                    ]]
        ]
        let fieldNumberOfAttendees =
            [
                "und":[[
                    "value": "2"
                    ]]
        ]
        let fieldFirstName =
            [
                "und":[[
                    "value": firstName,
                    "safe_value": firstName
                    ]]
        ]
        let fieldNmoqLastName =
            [
                "und":[[
                    "value": lastName,
                    "safe_value": lastName
                    ]]
        ]
        let fieldMembershipNumber =
            [
                "und":[[
                    "value": "144386",
                    
                    ]]
        ]
        let fieldQmaEduRegDate =
            [
                "und":[[
                    "value": time.startTime!,
                    "value2": time.endTime!,
                    "timezone": "Asia/Qatar",
                    "offset": "10800",
                    "offset2": "10800",
                    "timezone_db": "Asia/Qatar",
                    "date_type": "datestamp"
                    
                    ]]
        ]
        let timestamp = Int(NSDate().timeIntervalSince1970)
        let timestampInString = String(timestamp)
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.NMoQEntityRegistration(["type" : "nmoq_event_registration","entity_id": entityId!,"entity_type" :"node","user_uid": userId,"count": selectedCount!,"author_uid": userId,"state": "pending","created": timestampInString,"updated": timestampInString,"field_confirm_attendance" :fieldConfirmAttendance,"field_number_of_attendees" : fieldNumberOfAttendees, "field_first_name_": fieldFirstName,"field_nmoq_last_name" : fieldNmoqLastName,"field_membership_number": fieldMembershipNumber,"field_qma_edu_reg_date":fieldQmaEduRegDate])).responseObject { (response: DataResponse<NMoQEntityRegistration>) -> Void in
                switch response.result {
                case .success(let data):
                    self.entityRegistration = data
                    self.newRegistrationId = self.entityRegistration?.registrationId
                    self.setEntityRegistrationAsComplete(currentRow: currentRow, timestamp: timestampInString, selectedCell: selectedCell)
                case .failure( _):
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    
                }
            }
         } else {
            self.loadingView.stopLoading()
            self.loadingView.isHidden = true
            }
    }
        
    }
    func setEntityRegistrationAsComplete(currentRow: Int, timestamp: String,selectedCell: PanelDetailCell?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if((newRegistrationId != nil) && (nmoqTourDetail[currentRow].nid != nil) && (keychain.get(UserProfileInfo.user_id) != nil) && (keychain.get(UserProfileInfo.user_firstname) != nil) && (keychain.get(UserProfileInfo.user_lastname) != nil)) {
            let time = getTimeStamp(currentRow: currentRow)
            if (time.startTime != nil && time.endTime != nil) {
            let regId = newRegistrationId
            let entityId = nmoqTourDetail[currentRow].nid
            let userId = keychain.get(UserProfileInfo.user_id)!
            let firstName = (keychain.get(UserProfileInfo.user_firstname) != nil)
            let lastName = (keychain.get(UserProfileInfo.user_lastname) != nil)
            let fieldConfirmAttendance =
                [
                    "und":[[
                        "value": "1"
                        ]]
            ]
            let fieldNumberOfAttendees =
                [
                    "und":[[
                        "value": "2"
                        ]]
            ]
            let fieldFirstName =
                [
                    "und":[[
                        "value": firstName,
                        "safe_value": firstName
                        ]]
            ]
            let fieldNmoqLastName =
                [
                    "und":[[
                        "value": lastName,
                        "safe_value": lastName
                        ]]
            ]
            let fieldMembershipNumber =
                [
                    "und":[[
                        "value": "144386",

                        ]]
            ]
            let fieldQmaEduRegDate =
                [
                    "und":[[
                        "value": time.startTime!,
                        "value2": time.endTime!,
                        "timezone": "Asia/Qatar",
                        "offset": "10800",
                        "offset2": "10800",
                        "timezone_db": "Asia/Qatar",
                        "date_type": "datestamp"

                        ]]
            ]
                _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.SetUserRegistrationComplete(regId!,["registration_id": regId!,"type" : "nmoq_event_registration","entity_id": entityId!,"entity_type" :"node","user_uid": userId,"count": selectedCount!,"author_uid": userId,"state": "complete","created": timestamp,"updated": timestamp,"field_confirm_attendance" :fieldConfirmAttendance,"field_number_of_attendees" : fieldNumberOfAttendees, "field_first_name_": fieldFirstName,"field_nmoq_last_name" : fieldNmoqLastName,"field_membership_number": fieldMembershipNumber,"field_qma_edu_reg_date":fieldQmaEduRegDate])).responseObject { (response: DataResponse<NMoQEntityRegistration>) -> Void in
                switch response.result {
                case .success(let data):
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    self.completedEntityReg = data
                    self.userEventList.append(NMoQUserEventList(title: self.panelTitle, eventID: self.completedEntityReg?.entityId, regID: self.completedEntityReg?.registrationId,seats:self.selectedCount))
                    self.saveOrUpdateEventReistratedCoredata(tourEntity: self.nmoqTourDetail[currentRow], registrationId: self.completedEntityReg?.registrationId)
                    self.loadAddToCalendarPopup()
                    //self.setRegistrationSwitchOn(selectedCell: selectedCell)
                case .failure( _):
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true

                }
            }
        }
        } else {
            self.loadingView.stopLoading()
            self.loadingView.isHidden = true
        }

    }
    func setEntityUnRegistration(currentRow: Int,selectedCell: PanelDetailCell?) {
        var regId : String? = nil
        if (newRegistrationId != nil) {
            regId = newRegistrationId
        } else {
            fetchUserEventListFromCoredata()
            if let registeredEvent = userEventList.first(where: {$0.eventID == nmoqTourDetail[currentRow].nid}) {
                regId = registeredEvent.regID
                
            }
        }
        if((regId != nil) && ((keychain.get(UserProfileInfo.user_password) != nil))  && (keychain.get(UserProfileInfo.user_dispaly_name) != nil)) {
           // let regId = nmoqTourDetail[currentRow].nid
            let userName = (keychain.get(UserProfileInfo.user_dispaly_name))!
            let pwd = (keychain.get(UserProfileInfo.user_password))! 
            
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.SetUserUnRegistration(regId!,["name":userName,"pass":pwd])).responseData { (response) -> Void in
                switch response.result {
                case .success( _):
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    if(response.response?.statusCode == 200) {
                        if let index = self.userEventList.index(where: {$0.eventID == self.nmoqTourDetail[currentRow].nid}) {
                            self.userEventList.remove(at: index)
                        }
                        self.deleteRegisteredEvent(registrationId: regId)
                        //self.setRegistrationSwitchOff(selectedCell: selectedCell)
                        
                    }
                case .failure( _):
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    
                }
            }
        }
        
    }
    
    //MARK: EventRegistrationCoreData
    func saveOrUpdateEventReistratedCoredata(tourEntity: NMoQTourDetail,registrationId: String?) {
        if (userEventList.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.userEventCoreDataInBackgroundThread(managedContext: managedContext, tourEntity: tourEntity, registrationId: registrationId)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.userEventCoreDataInBackgroundThread(managedContext : managedContext, tourEntity: tourEntity, registrationId: registrationId)
                }
            }
        }
    }
    
    func userEventCoreDataInBackgroundThread(managedContext: NSManagedObjectContext,tourEntity: NMoQTourDetail,registrationId: String?) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            if (userEventList.count > 0) {
                    let userEventInfo: RegisteredEventListEntity = NSEntityDescription.insertNewObject(forEntityName: "RegisteredEventListEntity", into: managedContext) as! RegisteredEventListEntity
                    userEventInfo.title = tourEntity.title
                    userEventInfo.eventId = tourEntity.nid
                    userEventInfo.regId = registrationId
                    userEventInfo.seats = selectedCount
                    do{
                        try managedContext.save()
                    }
                    catch{
                        print(error)
                    }
            }
        }
    }
    
   
    func calculateToursOverlap(times : [[String : String]]) -> Bool? {
        
        let dateFormat = "MM-dd-yyyy HH:mm" //Z is for zone

        if #available(iOS 10.0, *) {
            var intervals = [DateInterval]()
            // Loop through date ranges to convert them to date intervals
            
            for item in times {
                
                if let start = convertStringToDate(string: item["start"]!, withFormat: dateFormat),
                    
                    let end = convertStringToDate(string: item["end"]!, withFormat: dateFormat) {
                    
                    intervals.append(DateInterval(start: start, end: end))
                }
                
            }
            // Check for intersection
            
            let intersection = intersect(intervals: intervals)
            
            if (intersection == nil) {
                return false
            } else {
                return true
            }
        } else {
            //Older Version
            let d1 = convertStringToDate(string: times[0]["start"]!, withFormat: dateFormat)
            let d2 = convertStringToDate(string: times[0]["end"]!, withFormat: dateFormat)
            let startDateStamp:TimeInterval = d1!.timeIntervalSince1970
            let dateSt:Int = Int(startDateStamp)
            let EndDateStamp:TimeInterval = d2!.timeIntervalSince1970
            let dateEnd:Int = Int(EndDateStamp)
            let firstDayTimeDiff = dateEnd - dateSt
            
            let d3 = convertStringToDate(string: times[1]["start"]!, withFormat: dateFormat)
            let d4 = convertStringToDate(string: times[1]["end"]!, withFormat: dateFormat)
            let startDateStamp2:TimeInterval = d3!.timeIntervalSince1970
            let dateSt2:Int = Int(startDateStamp2)
            let EndDateStamp2:TimeInterval = d4!.timeIntervalSince1970
            let dateEnd2:Int = Int(EndDateStamp2)
            let SecondDayTimeDiff = dateEnd2 - dateSt2
            let totalDiff = SecondDayTimeDiff - firstDayTimeDiff
            if(totalDiff == 0) {
                return true
            }
            return false
        }
    }
    // Converts the string to date with given format if require
    
    func convertStringToDate(string: String, withFormat format: String)  -> Date? {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: string)
        
    }
    @available(iOS 10.0, *)
    func intersect(intervals: [DateInterval]) -> DateInterval? {
        var previous = intervals.first
        
        for (index, element) in intervals.enumerated() {
            
            if index == 0 {
                
                continue
            }
            previous = previous?.intersection(with: element)
            if previous == nil {
                break
            }
        }
        return previous
        
    }
    func checkConflictWithAlreadyRegisteredEvent(currentRow: Int?) -> Bool? {
        let selectedEventId = nmoqTourDetail[currentRow!].nid
        var conflictIdArray: [NMoQTourDetail]! = []
        for i in  0 ... nmoqTourDetail.count-1 {
            if(selectedEventId == nmoqTourDetail[i].nid) {
                conflictIdArray = nmoqTourDetail
                conflictIdArray.remove(at: i)
                break
                }
            }
        
        for i  in 0 ... userEventList.count-1 {
            if let idArray = conflictIdArray.first(where: {$0.nid == userEventList[i].eventID}) {
                var timeEvents :[NMoQTourDetail] = []
                timeEvents.append(idArray)
                timeEvents.append(nmoqTourDetail[currentRow!])
                let haveConflict = self.setTimeArray( selectedEvent: timeEvents)
                return haveConflict
            }
        }
        return nil
            
        
    }
    func setTimeArray(selectedEvent: [NMoQTourDetail])-> Bool? {
        var times: [[String : String]] = []
        for i in 0 ... selectedEvent.count-1 {
            let time = selectedEvent[i].date?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
            let timeArray = time?.components(separatedBy: "-")
            if((timeArray?.count)! == 3) {
                let startTime = timeArray![0] + "" + timeArray![1]
                let endTime = timeArray![0] + "" + timeArray![2]
                if(times.count == 0) {
                    times = [["start": startTime, "end":endTime]]
                } else {
                    times.append(["start": startTime, "end":endTime])
                    
                }
            }
        }
        
            let haveConflict = calculateToursOverlap(times: times)
            return haveConflict
    }

    func fetchUserEventListFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (userEventList.count > 0) {
            userEventList.removeAll()
        }
        
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
                var eventArray = [RegisteredEventListEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "RegisteredEventListEntity")
                eventArray = (try managedContext.fetch(fetchRequest) as? [RegisteredEventListEntity])!
                if (eventArray.count > 0) {
                    for i in 0 ... eventArray.count-1 {
                        self.userEventList.insert(NMoQUserEventList(title: eventArray[i].title, eventID: eventArray[i].eventId, regID: eventArray[i].regId,seats: eventArray[i].seats), at: i)
                        
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func deleteRegisteredEvent(registrationId: String?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let appDelegate =  UIApplication.shared.delegate as? AppDelegate
        if #available(iOS 10.0, *) {
            let container = appDelegate!.persistentContainer
            container.performBackgroundTask() {(managedContext) in
                self.deleteExistingEvent(managedContext: managedContext, registrationId: registrationId)
            }
        } else {
            let managedContext = appDelegate!.managedObjectContext
            managedContext.perform {
                self.deleteExistingEvent(managedContext: managedContext, registrationId: registrationId)
            }
        }
    }

    func deleteExistingEvent(managedContext:NSManagedObjectContext,registrationId: String?)  {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RegisteredEventListEntity")
        fetchRequest.predicate = NSPredicate.init(format: "\("regId") == \(registrationId!)")
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
            
        }catch _ as NSError {
            //handle error here
            
        }
        
    }
    func getTimeStamp(currentRow:Int?) ->(startTime:Int?,endTime:Int?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let time = nmoqTourDetail[currentRow!].date?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        let timeArray = time?.components(separatedBy: "-")
        if((timeArray?.count)! == 3) {
            let startTime = timeArray![0] + "" + timeArray![1]
            let endTime = timeArray![0] + "" + timeArray![2]
            let dateFormat = "MM-dd-yyyy HH:mm"
            let start = convertStringToDate(string: startTime, withFormat: dateFormat)
            let end = convertStringToDate(string: endTime, withFormat: dateFormat)
            let startDateStamp:TimeInterval = start!.timeIntervalSince1970
            let dateSt:Int = Int(startDateStamp)
            let EndDateStamp:TimeInterval = end!.timeIntervalSince1970
            let dateEnd:Int = Int(EndDateStamp)
            return (dateSt,dateEnd)
        }
        return (nil,nil)
    }
    func loadAddToCalendarPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        addToCalendarPopup.tag = 0
        addToCalendarPopup  = EventPopupView(frame: self.view.frame)
        addToCalendarPopup.eventPopupDelegate = self
        addToCalendarPopup.eventTitle.isHidden = true
        addToCalendarPopup.loadRegistrationPopup()
        self.view.addSubview(addToCalendarPopup)
    }
    func loadAlreadyRegisteredPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.tag = 1
        popupView.loadAlreadyRegisteredPopupMessage()
        self.view.addSubview(popupView)
    }
    func loadNoEndTimePopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.tag = 2
        popupView.loadNoEndTimePopupMessage()
        self.view.addSubview(popupView)
    }
    //ComingSoonPopup Delagate
    func closeButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if ((popupView.tag == 1) || (popupView.tag == 2))  {
            self.popupView.removeFromSuperview()
        }
        self.popupView.removeFromSuperview()

    }
    func loadConfirmationPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        unRegisterPopupView  = AcceptDeclinePopup(frame: self.view.frame)
        unRegisterPopupView.showUnregisterYesOrNoMessage()
        unRegisterPopupView.declinePopupDelegate = self
        self.view.addSubview(unRegisterPopupView)
    }
    func loadNoSeatAvailablePopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.tag = 0
        popupView.loadNoSeatAvailableMessage()
        self.view.addSubview(popupView)
    }
    func declinePopupCloseButtonPressed() {
        
    }
    
    func yesButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        setEntityUnRegistration(currentRow: selectedRow!, selectedCell: selectedPanelCell)
        setRegisteredButton()
        self.unRegisterPopupView.removeFromSuperview()
    }
    
    func noButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.unRegisterPopupView.removeFromSuperview()
    }
    func showLocationErrorPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadMapKitLocationErrorPopup()
        self.view.addSubview(popupView)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func openEmail(email : String) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let mailComposeViewController = configuredMailComposeViewController(emailId:email)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
   
    func configuredMailComposeViewController(emailId:String) -> MFMailComposeViewController {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([emailId])
        mailComposerVC.setSubject("NMOQ Event:")
        mailComposerVC.setMessageBody("Greetings, Thanks for contacting NMOQ event support team", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            print("You pressed OK")
        }
        sendMailErrorAlert.addAction(okAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)

    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    
    func dialNumber(number : String) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let phoneNumber = number.replacingOccurrences(of: " ", with: "")

        if let url = URL(string: "tel://\(String(phoneNumber))"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
            
            print("Error in calling phone ...")
        }
    }
    @objc func dismissOverlay(sender: UITapGestureRecognizer? = nil) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        overlayView.isHidden = true
        picker.removeFromSuperview()
        toolBar.removeFromSuperview()
    }
    //MARK: PickerView
    func addPickerView() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        picker.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-200, width: self.view.frame.width , height: 200)
        picker.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        overlayView.isHidden = false
 
        toolBar.frame = CGRect(x: 0, y: picker.frame.origin.y, width: self.view.frame.width, height: 100)
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PanelDiscussionDetailViewController.donePicker))
        doneButton.tintColor = UIColor.blue
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let numberOfVisitorsLabel = UIBarButtonItem(title: "Number of Visitors", style: UIBarButtonItemStyle.done, target: nil, action: nil)
        numberOfVisitorsLabel.tintColor = UIColor.black
        
        toolBar.setItems([numberOfVisitorsLabel, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.view.addSubview(picker)
        self.view.addSubview(toolBar)
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selectedCount = countArray[row]
        return countArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCount = countArray[row]
    }
    @objc func donePicker() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let countValue : Int? = Int(selectedCount!)
        let remainingSeat : Int? = Int(nmoqTourDetail[currentPanelRow!].seatsRemaining ?? "0")
        if (countValue! > remainingSeat!) {
            loadNoSeatAvailablePopup()
        } else {
            loadingView.isHidden = false
            loadingView.showLoading()
            self.getEntityRegistrationFromServer(currentRow: currentPanelRow!, selectedCell: selectedPanelCell)
        }
        overlayView.isHidden = true
        picker.removeFromSuperview()
        toolBar.removeFromSuperview()
        
    }
    func setUnRegisteredButton() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        selectedPanelCell?.numbOfRservationsLabel.isHidden = false
        if(selectedCount == "1") {
            let reservationCount = NSLocalizedString("NUMB_OF_RESERVATIONS", comment: "NUMB_OF_RESERVATIONS in panel detail") + selectedCount! +  NSLocalizedString("SPACE", comment: "SPACE in panel detail")
            selectedPanelCell?.numbOfRservationsLabel.text = reservationCount
        } else {
            let reservationCount = NSLocalizedString("NUMB_OF_RESERVATIONS", comment: "NUMB_OF_RESERVATIONS in panel detail") + selectedCount! +  NSLocalizedString("SPACES", comment: "SPACES in panel detail")
            selectedPanelCell?.numbOfRservationsLabel.text = reservationCount
        }
        
        selectedPanelCell?.registerButton.tag = 1
        selectedPanelCell?.registerButton.backgroundColor = UIColor.red
        let cancelBookingString = NSLocalizedString("CANCEL_BOOKING_STRING", comment: "CANCEL_BOOKING_STRING in panel detail")
        selectedPanelCell?.registerButton.setTitle(cancelBookingString, for: .normal)
    }
    func setRegisteredButton() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let remainingSeat : Int? = Int(nmoqTourDetail[currentPanelRow!].seatsRemaining ?? "0")
        if ((nmoqTourDetail[currentPanelRow!].seatsRemaining == "0") || (nmoqTourDetail[currentPanelRow!].seatsRemaining == nil) || (remainingSeat! < 0)) {
            selectedPanelCell?.numbOfRservationsLabel.text = NSLocalizedString("NO_SEAT_AVAILABLE", comment: "NO_SEAT_AVAILABLE in panel detail")
            selectedPanelCell?.registerButton.backgroundColor = UIColor.lightGray
            selectedPanelCell?.registerButton.isEnabled = false
        } else if (nmoqTourDetail[currentPanelRow!].seatsRemaining == "1") {
            selectedPanelCell?.numbOfRservationsLabel.text =  (nmoqTourDetail[currentPanelRow!].seatsRemaining ?? "1") + NSLocalizedString("TOUR_SEAT_AVAILABILITY_STRING3", comment: "TOUR_SEAT_AVAILABILITY_STRING3 in panel detail")
            selectedPanelCell?.registerButton.isEnabled = true
            selectedPanelCell?.registerButton.backgroundColor = UIColor(red: 60/255, green: 135/255, blue: 66/255, alpha: 1)
        } else {
            selectedPanelCell?.numbOfRservationsLabel.text =  (nmoqTourDetail[currentPanelRow!].seatsRemaining ?? "3") + NSLocalizedString("TOUR_SEAT_AVAILABILITY_STRING2", comment: "TOUR_SEAT_AVAILABILITY_STRING2 in panel detail")
            selectedPanelCell?.registerButton.isEnabled = true
            selectedPanelCell?.registerButton.backgroundColor = UIColor(red: 60/255, green: 135/255, blue: 66/255, alpha: 1)
        }
        selectedPanelCell?.registerButton.tag = 0
        
        selectedPanelCell?.registerButton.setTitle(NSLocalizedString("BOOK_TOUR_STRING", comment: "BOOK_TOUR_STRING in panel detail"), for: .normal)
        
    }
    //MARK: AddToCalendar Delegate
    func eventCloseButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (addToCalendarPopup.addToCalendarButton.tag == 0) {
            setUnRegisteredButton()
        }
        addToCalendarPopup.removeFromSuperview()
    }
    
    func addToCalendarButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.addToCalendarPopup.removeFromSuperview()
        if (addToCalendarPopup.tag == 0) {
            setUnRegisteredButton()
            
            let time = nmoqTourDetail[currentPanelRow!].date?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
            let timeArray = time?.components(separatedBy: "-")
            if((timeArray?.count)! == 3) {
                let dateFormat = "MM-dd-yyyy HH:mm"
                let startTime = timeArray![0] + "" + timeArray![1]
                let endTime = timeArray![0] + "" + timeArray![2]
                let start = convertStringToDate(string: startTime, withFormat: dateFormat)
                let end = convertStringToDate(string: endTime, withFormat: dateFormat)
                self.addEventToCalendar(title: nmoqTourDetail[currentPanelRow!].title!, description: nmoqTourDetail[currentPanelRow!].title, startDate: start, endDate: end)
            }
        } else {
            let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(openSettingsUrl!)
        }
    }
    
    func addEventToCalendar(title: String, description: String?, startDate: Date?, endDate: Date?, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let eventStore = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .event)
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (granted) && (error == nil) {
                    DispatchQueue.main.async {
                        let event = EKEvent.init(eventStore: self.store)
                        let eventTitle = title.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#", with: "", options: .regularExpression, range: nil)
                        event.title = eventTitle.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
                        event.calendar = self.store.defaultCalendarForNewEvents
                        event.startDate = startDate
                        event.endDate = endDate
                        let notes = description?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#", with: "", options: .regularExpression, range: nil)
                        event.notes = notes?.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
                        
                        do {
                            try self.store.save(event, span: .thisEvent)
                        } catch let e as NSError {
                            completion?(false, e)
                            return
                        }
                        completion?(true, nil)
                    }
                } else {
                    completion?(false, error as NSError?)
                }
            })
        case EKAuthorizationStatus.authorized:
            let event = EKEvent.init(eventStore: self.store)
            let eventTitle = title.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#", with: "", options: .regularExpression, range: nil)
            event.title = eventTitle.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
            event.calendar = self.store.defaultCalendarForNewEvents
            event.startDate = startDate
            event.endDate = endDate
            let notes = description?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#", with: "", options: .regularExpression, range: nil)
            event.notes = notes?.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
            do {
                try self.store.save(event, span: .thisEvent)
            } catch _ as NSError {
                return
            }
        case EKAuthorizationStatus.denied, EKAuthorizationStatus.restricted:
            
            self.loadCalendarPermissionPopup()
        default:
            break
        }
        
    }
    func loadCalendarPermissionPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        addToCalendarPopup  = EventPopupView(frame: self.view.frame)
        addToCalendarPopup.eventPopupDelegate = self

        addToCalendarPopup.eventTitle.text = NSLocalizedString("PERMISSION_TITLE", comment: "PERMISSION_TITLE  in the popup view")
        addToCalendarPopup.eventDescription.text = NSLocalizedString("CALENDAR_PERMISSION", comment: "CALENDAR_PERMISSION  in the popup view")
        addToCalendarPopup.addToCalendarButton.setTitle(NSLocalizedString("SIDEMENU_SETTINGS_LABEL", comment: "SIDEMENU_SETTINGS_LABEL  in the popup view"), for: .normal)
        addToCalendarPopup.tag = 1
        self.view.addSubview(addToCalendarPopup)
    }
    //MARK: Facilities SecondaryList ServiceCall
    func getFacilitiesDetail() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if(panelDetailId != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetFacilitiesDetail(["category_id" : panelDetailId!])).responseObject { (response: DataResponse<FacilitiesDetailData>) -> Void in
                switch response.result {
                case .success(let data):
                    self.facilitiesDetail = data.facilitiesDetail ?? []
                    //                    if self.nmoqTourDetail.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                    //                        self.nmoqTourDetail = self.nmoqTourDetail.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    //                    }
                    self.tableView.reloadData()
                    if(self.nmoqTourDetail.count == 0) {
                        let noResultMsg = NSLocalizedString("NO_RESULT_MESSAGE",
                                                            comment: "Setting the content of the alert")
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                        self.loadingView.noDataLabel.text = noResultMsg
                    } else {
                        self.saveOrUpdateFacilitiesDetailCoredata()
                    }
                case .failure( _):
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                    self.loadingView.noDataLabel.text = errorMessage
                }
            }
        }
        
    }
    //MARK: Coredata Method
    func saveOrUpdateFacilitiesDetailCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (facilitiesDetail.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateFacilitiesDetails(managedContext : managedContext,
                                                        category: self.panelDetailId,
                                                        facilities: self.facilitiesDetail)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateFacilitiesDetails(managedContext : managedContext,
                                                        category: self.panelDetailId,
                                                        facilities: self.facilitiesDetail)
                }
            }
        }
    }
    
    
    func fetchFacilitiesDetailsFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let managedContext = getContext()
        do {
                var facilitiesDetailArray = [FacilitiesDetailEntity]()
            facilitiesDetailArray = DataManager.checkAddedToCoredata(entityName: "FacilitiesDetailEntity",
                                                             idKey: "category",
                                                             idValue: panelDetailId,
                                                             managedContext: managedContext) as! [FacilitiesDetailEntity]
            
            for facilities in facilitiesDetailArray {
                self.facilitiesDetail.append(FacilitiesDetail(entity: facilities))
            }
            
            if facilitiesDetail.isEmpty {
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.loadingView.showNoDataView()
                }
            }
            
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
            
        }
    }
    //MARK: WebServiceCall
    func getCollectioDetailsFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.CollectionDetail(["category": collectionName!])).responseObject { (response: DataResponse<CollectionDetails>) -> Void in
            switch response.result {
            case .success(let data):
                self.collectionDetailArray = data.collectionDetails
                self.saveOrUpdateCollectionDetailCoredata()
                self.tableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.collectionDetailArray.count == 0) {
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                }
            case .failure( _):
                var errorMessage: String
                errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                comment: "Setting the content of the alert"))
                self.loadingView.stopLoading()
                self.loadingView.noDataView.isHidden = false
                self.loadingView.isHidden = false
                self.loadingView.showNoDataView()
                self.loadingView.noDataLabel.text = errorMessage
            }
        }
    }
    
    func getNMoQParkDetailFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (nid != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQPlaygroundDetail(LocalizationLanguage.currentAppleLanguage(), ["nid": nid!])).responseObject { (response: DataResponse<NMoQParksDetail>) -> Void in
                switch response.result {
                case .success(let data):
                    self.nmoqParkDetailArray = data.nmoqParksDetail
                    if (self.nmoqParkDetailArray.count > 0) {
                        if self.nmoqParkDetailArray.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParkDetailArray = self.nmoqParkDetailArray.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                    }
                    //self.saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: data.nmoqParksDetail)
                    self.tableView.reloadData()
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    if (self.nmoqParkDetailArray.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                    
                case .failure( _):
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.loadingView.stopLoading()
                    self.loadingView.noDataView.isHidden = false
                    self.loadingView.isHidden = false
                    self.loadingView.showNoDataView()
                    self.loadingView.noDataLabel.text = errorMessage
                }
            }
        }
        
    }
    //MARK: CollectionDetail Coredata Method
    func saveOrUpdateCollectionDetailCoredata() {
        if (collectionDetailArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.collectionDetailCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.collectionDetailCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        }
    }
    
    func collectionDetailCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        
        if let fetchData = DataManager.checkAddedToCoredata(entityName: "CollectionDetailsEntity",
                                                            idKey: "categoryCollection",
                                                            idValue: collectionName,
                                                            managedContext: managedContext) as? [CollectionDetailsEntity],
            !fetchData.isEmpty {
            for collectionDetailDict in collectionDetailArray {
                if let fetchData = DataManager.checkAddedToCoredata(entityName: "CollectionDetailsEntity",
                                                                    idKey: "nid",
                                                                    idValue: collectionDetailDict.nid,
                                                                    managedContext: managedContext) as? [CollectionDetailsEntity],
                    !fetchData.isEmpty {
                    let collectiondbDict = fetchData[0]
                    collectiondbDict.title = collectionDetailDict.title
                    collectiondbDict.body = collectionDetailDict.body
                    collectiondbDict.categoryCollection =  collectionDetailDict.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
                    collectiondbDict.nid = collectionDetailDict.nid
                    collectiondbDict.image = collectionDetailDict.image
                    collectiondbDict.language = Utils.getLanguage()
                    
                    do {
                        try managedContext.save()
                    }
                    catch{
                        print(error)
                    }
                    
                } else {
                    self.collectionDetailSaveToCoreData(collectionDetailDict: collectionDetailDict, managedObjContext: managedContext)
                }
            }
            
        } else {
            for collectionDetailDict in collectionDetailArray {
                self.collectionDetailSaveToCoreData(collectionDetailDict: collectionDetailDict,
                                                    managedObjContext: managedContext)
            }
        }
    }
    
    func collectionDetailSaveToCoreData(collectionDetailDict: CollectionDetail, managedObjContext: NSManagedObjectContext) {
            let collectiondbDict: CollectionDetailsEntity = NSEntityDescription.insertNewObject(forEntityName: "CollectionDetailsEntity", into: managedObjContext) as! CollectionDetailsEntity
            collectiondbDict.title = collectionDetailDict.title
            collectiondbDict.body = collectionDetailDict.body
            collectiondbDict.nid = collectionDetailDict.nid
            collectiondbDict.categoryCollection =  collectionDetailDict.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
            collectiondbDict.image = collectionDetailDict.image
        collectiondbDict.language = Utils.getLanguage()
        
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func fetchCollectionDetailsFromCoredata() {
        let managedContext = getContext()
        do {
//            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var collectionArray = [CollectionDetailsEntity]()
            collectionArray = DataManager.checkAddedToCoredata(entityName: "CollectionDetailsEntity",
                                                             idKey: "categoryCollection",
                                                             idValue: collectionName,
                                                             managedContext: managedContext) as! [CollectionDetailsEntity]
            
                if (collectionArray.count > 0) {
                    for i in 0 ... collectionArray.count-1 {
                        let collectionDict = collectionArray[i]
                        if((collectionDict.title == nil) && (collectionDict.body == nil)) {
                            self.showNodata()
                            
                        } else {
                            self.collectionDetailArray.insert(CollectionDetail(title: collectionDict.title,
                                                                               image: collectionDict.image,
                                                                               body: collectionDict.body,
                                                                               nid: collectionDict.nid,
                                                                               categoryCollection: collectionDict.categoryCollection?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)), at: 0)
                        }
                        
                    }
                    if(collectionDetailArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    tableView.reloadData()
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    //MARK: NMoq Playground Parks Detail Coredata Method
    func saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: [NMoQParkDetail]?) {
        if ((nmoqParkList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.nmoqParkDetailCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.nmoqParkDetailCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext : managedContext)
                }
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func nmoqParkDetailCoreDataInBackgroundThread(nmoqParkList: [NMoQParkDetail]?,
                                                  managedContext: NSManagedObjectContext) {
        let fetchData = DataManager.checkAddedToCoredata(entityName: "NMoQParkDetailEntity",
                                                                 idKey: "nid",
                                                                 idValue: nil,
                                                                 managedContext: managedContext) as! [NMoQParkDetailEntity]
        
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = DataManager.checkAddedToCoredata(entityName: "NMoQParkDetailEntity",
                                                                             idKey: "nid",
                                                                             idValue: nmoqParkListDict.nid,
                                                                             managedContext: managedContext)
                    
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParkDetailEntity
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
                        nmoqParkListdbDict.parkDesc =  nmoqParkListDict.parkDesc
                        nmoqParkListdbDict.language = Utils.getLanguage()
                        
                        if(nmoqParkListDict.images != nil){
                            if((nmoqParkListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                                    var parkListImage: ImageEntity!
                                    let parkListImageArray = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: managedContext) as! ImageEntity
                                    parkListImageArray.image = nmoqParkListDict.images![i]
                                    parkListImageArray.language = Utils.getLanguage()
                                    parkListImage = parkListImageArray
                                    nmoqParkListdbDict.addToParkDetailImgRelation(parkListImage)
                                    do {
                                        try managedContext.save()
                                    } catch let error as NSError {
                                        print("Could not save. \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        }
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveNMoQParkDetailToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationEn), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQParkDetail?
                    nmoqParkListDict = nmoqParkList?[i]
                    self.saveNMoQParkDetailToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkDetailNotificationEn), object: self)
            }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func saveNMoQParkDetailToCoreData(nmoqParkListDict: NMoQParkDetail, managedObjContext: NSManagedObjectContext) {
            let nmoqParkListdbDict: NMoQParkDetailEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkDetailEntity", into: managedObjContext) as! NMoQParkDetailEntity
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
            nmoqParkListdbDict.parkDesc =  nmoqParkListDict.parkDesc
        nmoqParkListdbDict.language = Utils.getLanguage()
            
            if(nmoqParkListDict.images != nil){
                if((nmoqParkListDict.images?.count)! > 0) {
                    for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                        var parkListImage: ImageEntity!
                        let parkListImageArray = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: managedObjContext) as! ImageEntity
                        parkListImageArray.image = nmoqParkListDict.images![i]
                        parkListImageArray.language = Utils.getLanguage()
                        parkListImage = parkListImageArray
                        nmoqParkListdbDict.addToParkDetailImgRelation(parkListImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            DDLogError("Could not save. \(error), \(error.userInfo)")
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func fetchNMoQParkDetailFromCoredata() {
        let managedContext = getContext()
        do {
                var parkListArray = [NMoQParkDetailEntity]()
            parkListArray = DataManager.checkAddedToCoredata(entityName: "NMoQParkDetailEntity",
                                                                     idKey: "nid",
                                                                     idValue: nid,
                                                                     managedContext: managedContext) as! [NMoQParkDetailEntity]
            
                if (parkListArray.count > 0) {
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (parkListDict.parkDetailImgRelation?.allObjects) as! [ImageEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].image!)
                            }
                        }
                        self.nmoqParkDetailArray.insert(NMoQParkDetail(title: parkListDict.title, sortId: parkListDict.sortId, nid: parkListDict.nid, images: imagesArray, parkDesc: parkListDict.parkDesc, language: parkListDict.language), at: i)
                    }
                    if(nmoqParkDetailArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    } else {
                        if self.nmoqParkDetailArray.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParkDetailArray = self.nmoqParkDetailArray.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                    }
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        if (pageNameString == NMoQPanelPage.TourDetailPage) {
            Analytics.setScreenName(NMOQ_TOUR_DETAIL, screenClass: screenClass)
        } else if ((pageNameString == NMoQPanelPage.CollectionDetail) || (pageNameString == NMoQPanelPage.PlayGroundPark)) {
            Analytics.setScreenName(COLLECTION_DETAIL, screenClass: screenClass)
        } else if (pageNameString == NMoQPanelPage.CollectionDetail) {
            Analytics.setScreenName(NMOQ_ACTIVITY_DETAIL, screenClass: screenClass)
        } else {
            Analytics.setScreenName(NMOQ_FACILITIES_DETAIL, screenClass: screenClass)
        }
    
    }
    @objc func receiveNmoqParkDetailNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (nmoqParkDetailArray.count == 0)){
            self.fetchNMoQParkDetailFromCoredata()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    @objc func receiveNmoqParkDetailNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (nmoqParkDetailArray.count == 0)){
            self.fetchNMoQParkDetailFromCoredata()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
}
