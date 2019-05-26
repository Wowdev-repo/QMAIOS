//
//  CommonListViewController.swift
//  QatarMuseum
//
//  Created by Exalture on 10/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//
import Alamofire
import CoreData
import Crashlytics
import Firebase
import MapKit
import UIKit
import CocoaLumberjack

enum ExhbitionPageName {
    case homeExhibition
    case museumExhibition
    case heritageList
    case publicArtsList
    case museumCollectionsList
    case diningList
    case nmoqTourSecondList
    case facilitiesSecondList
    case miaTourGuideList
    case tourGuideList
    case parkList
}
class CommonListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegateFlowLayout,HeaderViewProtocol,comingSoonPopUpProtocol,LoadingViewProtocol {
    @IBOutlet weak var exhibitionHeaderView: CommonHeaderView!
    @IBOutlet weak var exhibitionCollectionView: UITableView!
    @IBOutlet weak var exbtnLoadingView: LoadingView!
    
    var exhibition: [Exhibition]! = []
    var heritageListArray: [Heritage]! = []
    var publicArtsListArray: [PublicArtsList]! = []
    var collection: [Collection] = []
    var diningListArray : [Dining]! = []
    var nmoqTourDetail: [NMoQTourDetail]! = []
    var facilitiesDetail: [FacilitiesDetail]! = []
    var miaTourDataFullArray: [TourGuide] = []
    var museumsList: [Home]! = []
    var nmoqParkList: [NMoQParksList]! = []
    var nmoqParks: [NMoQPark]! = []
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var exhibitionsPageNameString : ExhbitionPageName?
    let networkReachability = NetworkReachabilityManager()
    var museumId : String? = nil
    var fromSideMenu : Bool = false
    var fromHome : Bool = false
    var isFromTour: Bool? =  false
    var tourTitle : String! = ""
    var tourDesc: String = ""
    var tourDetailId : String? = nil
    var headerTitle : String? = nil
    var dataInCoreData : Bool? = false
    var selectedRow : Int? = 0

    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        setUpExhibitionPageUi()
        registerNib()
        self.recordScreenView()
    }
    
    func setUpExhibitionPageUi() {
        exbtnLoadingView.isHidden = false
        exbtnLoadingView.showLoading()
        exbtnLoadingView.loadingViewDelegate = self
        exhibitionHeaderView.headerViewDelegate = self
        if ((exhibitionsPageNameString == ExhbitionPageName.homeExhibition) || (exhibitionsPageNameString == ExhbitionPageName.museumExhibition)) {
            exhibitionHeaderView.headerTitle.text = NSLocalizedString("EXHIBITIONS_TITLE", comment: "EXHIBITIONS_TITLE Label in the Exhibitions page")
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveExhibitionListNotificationEn(notification:)), name: NSNotification.Name(exhibitionsListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveExhibitionListNotificationAr(notification:)), name: NSNotification.Name(exhibitionsListNotificationAr), object: nil)
            
            
            if  (networkReachability?.isReachable)! {
                if (exhibitionsPageNameString == ExhbitionPageName.homeExhibition) {
//                    DispatchQueue.global(qos: .background).async {
//                        self.getExhibitionDataFromServer()
//                    }
                    self.fetchExhibitionsListFromCoredata()
                } else
                    if (exhibitionsPageNameString == ExhbitionPageName.museumExhibition){
                    getMuseumExhibitionDataFromServer()
                }
            } else {
                if (exhibitionsPageNameString == ExhbitionPageName.homeExhibition) {
                    self.fetchExhibitionsListFromCoredata()
                } else if (exhibitionsPageNameString == ExhbitionPageName.museumExhibition){
                    self.fetchMuseumExhibitionsListFromCoredata()
                }
            }
            
        } else if (exhibitionsPageNameString == ExhbitionPageName.heritageList) {
            exhibitionHeaderView.headerTitle.text = NSLocalizedString("HERITAGE_SITES_TITLE", comment: "HERITAGE_SITES_TITLE  in the Heritage page")
            exhibitionHeaderView.headerTitle.font = UIFont.headerFont
            self.fetchHeritageListFromCoredata()
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveHeritageListNotificationEn(notification:)), name: NSNotification.Name(heritageListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveHeritageListNotificationAr(notification:)), name: NSNotification.Name(heritageListNotificationAr), object: nil)
//            if  (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getHeritageDataFromServer()
//                }
//            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.publicArtsList) {
            exhibitionHeaderView.headerTitle.text = NSLocalizedString("PUBLIC_ARTS_TITLE", comment: "PUBLIC_ARTS_TITLE Label in the PublicArts page")
//            if  (networkReachability?.isReachable)! {
//                DispatchQueue.global(qos: .background).async {
//                    self.getPublicArtsListDataFromServer()
//                }
//            }
            self.fetchPublicArtsListFromCoredata()
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receivePublicArtsListNotificationEn(notification:)), name: NSNotification.Name(publicArtsListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receivePublicArtsListNotificationAr(notification:)), name: NSNotification.Name(publicArtsListNotificationAr), object: nil)
        } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList) {
            exhibitionHeaderView.headerTitle.text = NSLocalizedString("COLLECTIONS_TITLE", comment: "COLLECTIONS_TITLE Label in the collections page").uppercased()
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveCollectionListNotificationEn(notification:)), name: NSNotification.Name(collectionsListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveCollectionListNotificationAr(notification:)), name: NSNotification.Name(collectionsListNotificationAr), object: nil)
            if((museumId == "63") || (museumId == "96")) {
//                if (networkReachability?.isReachable)! {
//                    DispatchQueue.global(qos: .background).async {
//                        self.getCollectionList()
//                    }
//                }
                self.fetchCollectionListFromCoredata()
            } else {
                if (networkReachability?.isReachable)! {
                    self.getCollectionList()
                } else {
                    self.fetchCollectionListFromCoredata()
                }
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.diningList) {
            exhibitionHeaderView.headerTitle.text = NSLocalizedString("DINING_TITLE", comment: "DINING_TITLE in the Dining page")
            if(fromHome) {
                self.fetchDiningListFromCoredata()
//                if  (networkReachability?.isReachable)! {
//                    DispatchQueue.global(qos: .background).async {
//                        self.getDiningListFromServer()
//                    }
//                }
            } else {
                self.fetchMuseumDiningListFromCoredata()
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getMuseumDiningListFromServer()
                    }
                }
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.nmoqTourSecondList) {
            tourDesc = NSLocalizedString("NMoQ_TOUR_DESC", comment: "NMoQ_TOUR_DESC in the NMoQ Tour page")
            exhibitionHeaderView.headerTitle.text = headerTitle?.uppercased()
            if (networkReachability?.isReachable)! {
                getNMoQTourDetail()
            } else {
                fetchTourDetailsFromCoredata()
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.facilitiesSecondList) {
            exhibitionHeaderView.headerTitle.text = headerTitle?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).replacingOccurrences(of: "&amp;", with: "&", options: .regularExpression, range: nil).uppercased()
            if (networkReachability?.isReachable)! {
                getFacilitiesDetail()
            } else {
                fetchFacilitiesDetailsFromCoredata()
            }
        } else if (exhibitionsPageNameString == ExhbitionPageName.miaTourGuideList) {
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveMiaTourNotification(notification:)), name: NSNotification.Name(miaTourNotification), object: nil)
            DispatchQueue.main.async {
                self.fetchTourGuideListFromCoredata()
            }
            exhibitionHeaderView.headerTitle.isHidden = true
        } else if (exhibitionsPageNameString == ExhbitionPageName.tourGuideList) {
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveHomePageNotificationEn(notification:)), name: NSNotification.Name(homepageNotificationEn), object: nil)
            if  (networkReachability?.isReachable)! {
                DispatchQueue.global(qos: .background).async {
                    self.getTourGuideMuseumsList()
                }
            }
            self.fetchMuseumsInfoFromCoredata()
        } else if (exhibitionsPageNameString == ExhbitionPageName.parkList) {
            fetchNmoqParkListFromCoredata()
            fetchNmoqParkFromCoredata()
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveNmoqParkListNotificationEn(notification:)), name: NSNotification.Name(heritageListNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveNmoqParkListNotificationAr(notification:)), name: NSNotification.Name(heritageListNotificationAr), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveNmoqParkNotificationEn(notification:)), name: NSNotification.Name(nmoqParkNotificationEn), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(CommonListViewController.receiveNmoqParkNotificationAr(notification:)), name: NSNotification.Name(nmoqParkNotificationAr), object: nil)
        }
        popupView.comingSoonPopupDelegate = self
        
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            exhibitionHeaderView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            exhibitionHeaderView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    func registerNib() {
        self.exhibitionCollectionView.register(UINib(nibName: "CommonListCellXib", bundle: nil), forCellReuseIdentifier: "commonListCellId")
        self.exhibitionCollectionView.register(UINib(nibName: "MiaTourHeaderView", bundle: nil), forCellReuseIdentifier: "miaHeaderId")
        self.exhibitionCollectionView.register(UINib(nibName: "ParkListView", bundle: nil), forCellReuseIdentifier: "parkListCellId")
        self.exhibitionCollectionView.register(UINib(nibName: "NMoQPArkTopCell", bundle: nil), forCellReuseIdentifier: "parkTopCellId")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Service call
    func getExhibitionDataFromServer() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.ExhibitionList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<Exhibitions>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.exhibition.count == 0) {
                    self.exhibition = data.exhibitions
                    self.exhibitionCollectionView.reloadData()
                    if(self.exhibition.count == 0) {
                        self.exbtnLoadingView.stopLoading()
                        self.exbtnLoadingView.noDataView.isHidden = false
                        self.exbtnLoadingView.isHidden = false
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
                if(self.exhibition.count > 0) {
                    self.saveOrUpdateExhibitionsCoredata(exhibition: data.exhibitions, isHomeExhibition: "1")
                }
            case .failure( _):
                if(self.exhibition.count == 0) {
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: MuseumExhibitions Service Call
    func getMuseumExhibitionDataFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.MuseumExhibitionList(["museum_id": museumId ?? 0])).responseObject { (response: DataResponse<Exhibitions>) -> Void in
            switch response.result {
            case .success(let data):
                self.exhibition = data.exhibitions
                self.saveOrUpdateExhibitionsCoredata(exhibition: data.exhibitions, isHomeExhibition: "0")
                self.exhibitionCollectionView.reloadData()
                self.exbtnLoadingView.stopLoading()
                self.exbtnLoadingView.isHidden = true
                if (self.exhibition.count == 0) {
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                }
            case .failure(let error):
                if let unhandledError = handleError(viewController: self, errorType: error as! BackendError) {
                    var errorMessage: String
                    var errorTitle: String
                    switch unhandledError.code {
                    default: print(unhandledError.code)
                    errorTitle = String(format: NSLocalizedString("UNKNOWN_ERROR_ALERT_TITLE",
                                                                  comment: "Setting the title of the alert"))
                    errorMessage = String(format: NSLocalizedString("ERROR_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    }
                    presentAlert(self, title: errorTitle, message: errorMessage)
                }
            }
        }
    }
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
        } else if (exhibitionsPageNameString == ExhbitionPageName.publicArtsList) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
            self.performSegue(withIdentifier: "commonListToDetailSegue", sender: self)
        } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList) {
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
            self.performSegue(withIdentifier: "commonListToPanelDetailSegue", sender: self)
        } else if (exhibitionsPageNameString == ExhbitionPageName.diningList) {
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
            loadPublicArtsDetail(idValue: publicArtsListArray[indexPath.row].id!)
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_publicart_detail,
                AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                AnalyticsParameterContentType: "cont"
                ])
        } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList) {
            loadCollectionDetail(currentRow: indexPath.row)
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_collections_detail,
                AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                AnalyticsParameterContentType: "cont"
                ])
        } else if (exhibitionsPageNameString == ExhbitionPageName.diningList) {
            let diningId = diningListArray[indexPath.row].id
//            loadDiningDetailAnimation(idValue: diningId!)
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
            loadTourSecondDetailPage(selectedRow: indexPath.row, fromTour: false, pageName: ExhbitionPageName.facilitiesSecondList)
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_facilities_second_detail,
                AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
                AnalyticsParameterContentType: "cont"
                ])
        } else if (exhibitionsPageNameString == ExhbitionPageName.tourGuideList) {
            if (indexPath.row != 0) {
                if (museumsList != nil) {
                    if(((museumsList[indexPath.row - 1].id) == "63") || ((museumsList[indexPath.row - 1].id) == "96") || ((museumsList[indexPath.row - 1].id) == "61") || ((museumsList[indexPath.row - 1].id) == "635") || ((museumsList[indexPath.row - 1].id) == "66") || ((museumsList[indexPath.row - 1].id) == "638")) {
                        loadMiaTour(currentRow: indexPath.row - 1)
                        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
                        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), Museum ID: \(String(describing: museumsList[indexPath.row].id))")
                    } else {
                        addComingSoonPopup()
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

    func loadExhibitionCellPages(cellObj: CommonListCell, selectedIndex: Int) {
    }
    func loadPublicArtsDetail(idValue: String) {
    }
    func loadCollectionDetail(currentRow: Int?) {
        let collectionDetailView =  self.storyboard?.instantiateViewController(withIdentifier: "paneldetailViewId") as! PanelDiscussionDetailViewController
        collectionDetailView.pageNameString = NMoQPanelPage.CollectionDetail
        collectionDetailView.collectionName = collection[currentRow!].name?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(collectionDetailView, animated: false, completion: nil)
    }
    func addComingSoonPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        let viewFrame : CGRect = self.view.frame
        popupView.frame = viewFrame
        popupView.loadPopup()
        self.view.addSubview(popupView)
    }
    func loadHeritageDetail(heritageListId: String) {
    }
    func loadExhibitionDetailAnimation(exhibitionId: String) {
    }
    func loadTourSecondDetailPage(selectedRow: Int?,fromTour:Bool?,pageName: ExhbitionPageName?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        let panelView =  self.storyboard?.instantiateViewController(withIdentifier: "paneldetailViewId") as! PanelDiscussionDetailViewController

        panelView.selectedRow = selectedRow

        if(pageName == ExhbitionPageName.nmoqTourSecondList) {
            panelView.nmoqTourDetail = nmoqTourDetail
            panelView.panelDetailId = tourDetailId

            if (fromTour)! {
                panelView.pageNameString = NMoQPanelPage.TourDetailPage
            } else {
                panelView.pageNameString = NMoQPanelPage.PanelDetailPage
            }
        } else if(pageName == ExhbitionPageName.facilitiesSecondList) {
            panelView.pageNameString = NMoQPanelPage.FacilitiesDetailPage
            panelView.panelDetailId = facilitiesDetail![selectedRow!].nid
            panelView.facilitiesDetail = facilitiesDetail
            panelView.fromCafeOrDining = true
        }
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(panelView, animated: false, completion: nil)
    }
    //MARK: Header delegate
    func headerCloseButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        let transition = CATransition()
        transition.duration = 0.25
        if (fromSideMenu == true) {
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            dismiss(animated: false, completion: nil)
        } else {
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.add(transition, forKey: kCATransition)
            switch exhibitionsPageNameString {
            case .homeExhibition?:
                let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = homeViewController
        case .museumExhibition?,.museumCollectionsList?,.nmoqTourSecondList?,.facilitiesSecondList?,.miaTourGuideList?,.parkList?:
                self.dismiss(animated: false, completion: nil)
            case .diningList?:
                if (fromHome == true) {
                    let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController
                    let appDelegate = UIApplication.shared.delegate
                    appDelegate?.window??.rootViewController = homeViewController
                } else {
                    self.dismiss(animated: false, completion: nil)
                }
            default:
                break
            }
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_add_to_calender_item,
            AnalyticsParameterItemName: exhibitionsPageNameString ?? "",
            AnalyticsParameterContentType: "cont"
            ])
    }

    func closeButtonPressed() {
        self.popupView.removeFromSuperview()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

    }
    
    //MARK: Coredata Method
    func saveOrUpdateExhibitionsCoredata(exhibition:[Exhibition]?,isHomeExhibition : String?) {
        if ((exhibition?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext, exhibition: exhibition,isHomeExhibition :isHomeExhibition)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext, exhibition: exhibition,isHomeExhibition :isHomeExhibition)
                }
            }
        }
    }
    
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext,exhibition:[Exhibition]?,isHomeExhibition : String?) {
        var fetchData = [ExhibitionsEntity]()
        var langVar : String? = nil
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
             fetchData = self.checkAddedToCoredata(entityName: "ExhibitionsEntity", idKey: "lang", idValue: langVar, managedContext: managedContext) as! [ExhibitionsEntity]
            if (fetchData.count > 0) {
                for i in 0 ... self.exhibition.count-1 {
                    let exhibitionsListDict = self.exhibition[i]
                    let fetchResult = self.checkAddedToCoredata(entityName: "ExhibitionsEntity", idKey: "id", idValue: self.exhibition[i].id, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let exhibitionsdbDict = fetchResult[0] as! ExhibitionsEntity
                        exhibitionsdbDict.name = exhibitionsListDict.name
                        exhibitionsdbDict.image = exhibitionsListDict.image
                        exhibitionsdbDict.startDate =  exhibitionsListDict.startDate
                        exhibitionsdbDict.endDate = exhibitionsListDict.endDate
                        exhibitionsdbDict.location =  exhibitionsListDict.location
                        exhibitionsdbDict.museumId = exhibitionsListDict.museumId
                        exhibitionsdbDict.status = exhibitionsListDict.status
                        exhibitionsdbDict.isHomeExhibition = isHomeExhibition
                        exhibitionsdbDict.lang = langVar
                        do {
                            try managedContext.save()
                        }
                        catch {
                            print(error)
                        }
                    } else {
                        //save
                        self.saveToCoreData(exhibitionDict: exhibitionsListDict, managedObjContext: managedContext, exhibition: exhibition,isHomeExhibition :isHomeExhibition)
                    }
                }//for
            } else {
                for i in 0 ... self.exhibition.count-1 {
                    let exhibitionListDict : Exhibition?
                    exhibitionListDict = self.exhibition[i]
                    self.saveToCoreData(exhibitionDict: exhibitionListDict!, managedObjContext: managedContext, exhibition: exhibition,isHomeExhibition :isHomeExhibition)
                }
            }
    }
    
    func saveToCoreData(exhibitionDict: Exhibition, managedObjContext: NSManagedObjectContext,exhibition:[Exhibition]?,isHomeExhibition : String?) {
        //if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
        var langVar : String? = nil
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
            let exhibitionInfo: ExhibitionsEntity = NSEntityDescription.insertNewObject(forEntityName: "ExhibitionsEntity", into: managedObjContext) as! ExhibitionsEntity
            
            exhibitionInfo.id = exhibitionDict.id
            exhibitionInfo.name = exhibitionDict.name
            exhibitionInfo.image = exhibitionDict.image
            exhibitionInfo.startDate =  exhibitionDict.startDate
            exhibitionInfo.endDate = exhibitionDict.endDate
            exhibitionInfo.location =  exhibitionDict.location
            exhibitionInfo.museumId =  exhibitionDict.museumId
            exhibitionInfo.status =  exhibitionDict.status
            exhibitionInfo.isHomeExhibition =  isHomeExhibition
            exhibitionInfo.lang = langVar
        do {
            try managedObjContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchExhibitionsListFromCoredata() {
        let managedContext = getContext()
        do {
            var exhibitionArray = [ExhibitionsEntity]()
            var langVar : String? = nil
            if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
                langVar = "1"
                
            } else {
                langVar = "0"
            }
            exhibitionArray = checkMultiplePredicate(entityName: "ExhibitionsEntity", idKey: "isHomeExhibition", idValue: "1", langKey: "lang", langValue: langVar, managedContext: managedContext) as! [ExhibitionsEntity]
                if (exhibitionArray.count > 0) {
                    if((self.networkReachability?.isReachable)!) {
                        DispatchQueue.global(qos: .background).async {
                            self.getExhibitionDataFromServer()
                        }
                }
                    for i in 0 ... exhibitionArray.count-1 {
                        self.exhibition.insert(Exhibition(id: exhibitionArray[i].id, name: exhibitionArray[i].name, image: exhibitionArray[i].image,detailImage:nil, startDate: exhibitionArray[i].startDate, endDate: exhibitionArray[i].endDate, location: exhibitionArray[i].location, latitude: nil, longitude: nil, shortDescription: nil, longDescription: nil,museumId :exhibitionArray[i].museumId,status :exhibitionArray[i].status,displayDate :exhibitionArray[i].dispalyDate), at: i)
                        
                    }
                    if(exhibition.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    } 
                    DispatchQueue.main.async{
                        self.exhibitionCollectionView.reloadData()
                    }
                } else {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.exbtnLoadingView.showNoDataView()
                        self.getExhibitionDataFromServer() //coreDataMigratio  solution
                    }
                }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if (networkReachability?.isReachable == false) {
                self.showNoNetwork()
            }
        }
    }
    //MARK: MuseumExhibitionDatabase Fetch
    func fetchMuseumExhibitionsListFromCoredata() {
        let managedContext = getContext()
        do {
                var exhibitionArray = [ExhibitionsEntity]()
                exhibitionArray = checkAddedToCoredata(entityName: "ExhibitionsEntity", idKey: "museumId", idValue: museumId, managedContext: managedContext) as! [ExhibitionsEntity]
                if (exhibitionArray.count > 0) {
                    for i in 0 ... exhibitionArray.count-1 {
                        self.exhibition.insert(Exhibition(id: exhibitionArray[i].id, name: exhibitionArray[i].name, image: exhibitionArray[i].image,detailImage:nil, startDate: exhibitionArray[i].startDate, endDate: exhibitionArray[i].endDate, location: exhibitionArray[i].location, latitude: nil, longitude: nil, shortDescription: nil, longDescription: nil,museumId :exhibitionArray[i].museumId,status :exhibitionArray[i].status, displayDate :exhibitionArray[i].dispalyDate), at: i)
                        
                    }
                    if(exhibition.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    DispatchQueue.main.async{
                        self.exhibitionCollectionView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
        }
    }
    
    func checkAddedToCoredata(entityName: String?,idKey:String?, idValue: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults : [NSManagedObject] = []
        let homeFetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
        if (idValue != nil) {
            homeFetchRequest.predicate = NSPredicate.init(format: "\(idKey!) == \(idValue!)")
        }
        fetchResults = try! managedContext.fetch(homeFetchRequest)
        return fetchResults
    }
    func checkMultiplePredicate(entityName: String?,idKey:String?, idValue: String?,langKey:String?, langValue: String?, managedContext: NSManagedObjectContext) -> [NSManagedObject] {
        var fetchResults : [NSManagedObject] = []
        let homeFetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName!)
        if (idValue != nil) {
            let predicate1 = NSPredicate(format: "\(idKey!) == \(idValue!)")
            let predicate2 = NSPredicate(format: "\(langKey!) == \(langValue!)")
            let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: [predicate1,predicate2])
            homeFetchRequest.predicate = predicateCompound
            //homeFetchRequest.predicate = NSPredicate.init(format: "\(idKey!) == \(idValue!)")
        }
        fetchResults = try! managedContext.fetch(homeFetchRequest)
        return fetchResults
    }
    
    func showNodata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        var errorMessage: String
        errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                        comment: "Setting the content of the alert"))
        self.exbtnLoadingView.stopLoading()
        self.exbtnLoadingView.noDataView.isHidden = false
        self.exbtnLoadingView.isHidden = false
        self.exbtnLoadingView.showNoDataView()
        self.exbtnLoadingView.noDataLabel.text = errorMessage
    }
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if  (networkReachability?.isReachable)! {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if (exhibitionsPageNameString == ExhbitionPageName.homeExhibition) {
                appDelegate?.getExhibitionDataFromServer(lang: LocalizationLanguage.currentAppleLanguage())
            } else if (exhibitionsPageNameString == ExhbitionPageName.museumExhibition){
                self.getMuseumExhibitionDataFromServer()
            } else if (exhibitionsPageNameString == ExhbitionPageName.heritageList){
                appDelegate?.getHeritageDataFromServer(lang: LocalizationLanguage.currentAppleLanguage())
            } else if (exhibitionsPageNameString == ExhbitionPageName.publicArtsList){
                appDelegate?.getPublicArtsListDataFromServer(lang: LocalizationLanguage.currentAppleLanguage())
            } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList){
                if((museumId == "63") || (museumId == "96")) {
                    appDelegate?.getCollectionList(museumId: museumId, lang: LocalizationLanguage.currentAppleLanguage())
                    
                } else {
                    self.getCollectionList()
                }
            } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList){
                if(fromHome == true) {
                    appDelegate?.getDiningListFromServer(lang: LocalizationLanguage.currentAppleLanguage())
                } else {
                    self.getMuseumDiningListFromServer()
                }
            } else if (exhibitionsPageNameString == ExhbitionPageName.nmoqTourSecondList){
                self.getNMoQTourDetail()
            } else if (exhibitionsPageNameString == ExhbitionPageName.miaTourGuideList){
                self.getTourGuideDataFromServer()
            } else if (exhibitionsPageNameString == ExhbitionPageName.tourGuideList){
                self.getTourGuideMuseumsList()
            } else if (exhibitionsPageNameString == ExhbitionPageName.parkList){
                appDelegate?.getNmoqParkListFromServer(lang: LocalizationLanguage.currentAppleLanguage())
            }
        }
    }
    func showNoNetwork() {
        self.exbtnLoadingView.stopLoading()
        self.exbtnLoadingView.noDataView.isHidden = false
        self.exbtnLoadingView.isHidden = false
        self.exbtnLoadingView.showNoNetworkView()
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @objc func receiveExhibitionListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (exhibition.count == 0)){
            self.fetchExhibitionsListFromCoredata()
        }
    }
    @objc func receiveExhibitionListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (exhibition.count == 0)){
            self.fetchExhibitionsListFromCoredata()
        }
    }
    @objc func receiveMiaTourNotification(notification: NSNotification) {
        let data = notification.userInfo as? [String:String]
        if (data?.count)!>0 {
            if(museumId == data!["id"]) {
                self.fetchTourGuideListFromCoredata()
            }
        }
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        if ((exhibitionsPageNameString == ExhbitionPageName.homeExhibition) ||  (exhibitionsPageNameString == ExhbitionPageName.homeExhibition)) {
            Analytics.setScreenName(EXHIBITION_LIST, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.heritageList) {
            Analytics.setScreenName(HERITAGE_LIST, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.publicArtsList) {
             Analytics.setScreenName(PUBLIC_ARTS_LIST, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList) {
            Analytics.setScreenName(MUSEUM_COLLECTION, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.diningList) {
            Analytics.setScreenName(DINING_LIST, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.nmoqTourSecondList) {
            Analytics.setScreenName(NMOQ_TOUR_SECOND_LIST, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.miaTourGuideList) {
            Analytics.setScreenName(MIA_TOUR_GUIDE, screenClass: screenClass)
        } else if (exhibitionsPageNameString == ExhbitionPageName.tourGuideList) {
            Analytics.setScreenName(TOUR_GUIDE_VC, screenClass: screenClass)
        }
        
        
    }
    //MARK: Heritage Page WebServiceCall
    func getHeritageDataFromServer() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.HeritageList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<Heritages>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.heritageListArray.count == 0) {
                    self.heritageListArray = data.heritage
                    self.exhibitionCollectionView.reloadData()
                    if(self.heritageListArray.count == 0) {
                        self.exbtnLoadingView.stopLoading()
                        self.exbtnLoadingView.noDataView.isHidden = false
                        self.exbtnLoadingView.isHidden = false
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
                if(self.heritageListArray.count > 0) {
                    self.saveOrUpdateHeritageCoredata(heritageListArray: data.heritage)
                }
            case .failure( _):
                if(self.heritageListArray.count == 0) {
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateHeritageCoredata(heritageListArray:[Heritage]?) {
        if ((heritageListArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext, heritageListArray: heritageListArray)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext, heritageListArray: heritageListArray)
                }
            }
        }
    }
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext,heritageListArray:[Heritage]?) {
        var fetchData = [HeritageEntity]()
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
             fetchData = checkAddedToCoredata(entityName: "HeritageEntity", idKey: "lang", idValue: "1", managedContext: managedContext) as! [HeritageEntity]
        } else {
            fetchData = checkAddedToCoredata(entityName: "HeritageEntity", idKey: "lang", idValue: "0", managedContext: managedContext) as! [HeritageEntity]
        }
            if (fetchData.count > 0) {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict = heritageListArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "HeritageEntity", idKey: "listid", idValue: heritageListArray![i].id, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let heritagedbDict = fetchResult[0] as! HeritageEntity
                        heritagedbDict.listname = heritageListDict.name
                        heritagedbDict.listimage = heritageListDict.image
                        heritagedbDict.listsortid =  heritageListDict.sortid
                        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
                            heritagedbDict.lang =  "1"
                        } else {
                            heritagedbDict.lang =  "0"
                        }
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveToCoreData(heritageListDict: heritageListDict, managedObjContext: managedContext)
                        
                    }
                }
            } else {
                for i in 0 ... (heritageListArray?.count)!-1 {
                    let heritageListDict : Heritage?
                    heritageListDict = heritageListArray?[i]
                    self.saveToCoreData(heritageListDict: heritageListDict!, managedObjContext: managedContext)
                }
            }
        
       
    }
    
    func saveToCoreData(heritageListDict: Heritage, managedObjContext: NSManagedObjectContext) {
        //if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let heritageInfo: HeritageEntity = NSEntityDescription.insertNewObject(forEntityName: "HeritageEntity", into: managedObjContext) as! HeritageEntity
            heritageInfo.listid = heritageListDict.id
            heritageInfo.listname = heritageListDict.name
            heritageInfo.listimage = heritageListDict.image
            if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
                heritageInfo.lang =  "1"
            } else {
                heritageInfo.lang =  "0"
            }
            if(heritageListDict.sortid != nil) {
                heritageInfo.listsortid = heritageListDict.sortid
            }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchHeritageListFromCoredata() {
        let managedContext = getContext()
        do {
            var heritageArray = [HeritageEntity]()
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                heritageArray = checkAddedToCoredata(entityName: "HeritageEntity", idKey: "lang", idValue: "1", managedContext: managedContext) as! [HeritageEntity]

            } else {
                heritageArray = checkAddedToCoredata(entityName: "HeritageEntity", idKey: "lang", idValue: "0", managedContext: managedContext) as! [HeritageEntity]

            }
                if (heritageArray.count > 0) {
                    if((self.networkReachability?.isReachable)!) {
                        DispatchQueue.global(qos: .background).async {
                            self.getHeritageDataFromServer()
                        }
                    }
                    for i in 0 ... heritageArray.count-1 {
                        
                        self.heritageListArray.insert(Heritage(id: heritageArray[i].listid, name: heritageArray[i].listname, location: nil, latitude: nil, longitude: nil, image: heritageArray[i].listimage, shortdescription: nil, longdescription: nil,images: nil, sortid: heritageArray[i].listsortid), at: i)
                        
                    }
                    if(heritageListArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    DispatchQueue.main.async{
                        self.exhibitionCollectionView.reloadData()
                    }
                } else {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.getHeritageDataFromServer() //coreDataMigratio  solution
                    }
                }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if (networkReachability?.isReachable == false) {
                self.showNoNetwork()
            }
        }
    }
    @objc func receiveHeritageListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (heritageListArray.count == 0)){
            self.fetchHeritageListFromCoredata()
        }
    }
    @objc func receiveHeritageListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (heritageListArray.count == 0)){
            self.fetchHeritageListFromCoredata()
        }
    }
    //MARK: PublicArts Functions
    //MARK: WebServiceCall
    func getPublicArtsListDataFromServer() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.PublicArtsList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<PublicArtsLists>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.publicArtsListArray.count == 0) {
                    self.publicArtsListArray = data.publicArtsList
                    self.exhibitionCollectionView.reloadData()
                    if(self.publicArtsListArray.count == 0) {
                        self.exbtnLoadingView.stopLoading()
                        self.exbtnLoadingView.noDataView.isHidden = false
                        self.exbtnLoadingView.isHidden = false
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
                if(self.publicArtsListArray.count > 0) {
                    self.saveOrUpdatePublicArtsCoredata(publicArtsListArray: data.publicArtsList, lang: LocalizationLanguage.currentAppleLanguage())
                }
            case .failure( _):
                if(self.publicArtsListArray.count == 0) {
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdatePublicArtsCoredata(publicArtsListArray:[PublicArtsList]?,lang: String?) {
        if ((publicArtsListArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.publicArtsCoreDataInBackgroundThread(managedContext: managedContext, publicArtsListArray: publicArtsListArray, lang: lang)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.publicArtsCoreDataInBackgroundThread(managedContext : managedContext, publicArtsListArray: publicArtsListArray, lang: lang)
                }
            }
        }
    }
    func publicArtsCoreDataInBackgroundThread(managedContext: NSManagedObjectContext,publicArtsListArray:[PublicArtsList]?,lang: String?) {
        if (lang == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "PublicArtsEntity", idKey: "id", idValue: nil, managedContext: managedContext) as! [PublicArtsEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (publicArtsListArray?.count)!-1 {
                    let publicArtsListDict = publicArtsListArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "PublicArtsEntity", idKey: "id", idValue: publicArtsListArray![i].id, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let publicArtsdbDict = fetchResult[0] as! PublicArtsEntity
                        
                        publicArtsdbDict.name = publicArtsListDict.name
                        publicArtsdbDict.image = publicArtsListDict.image
                        publicArtsdbDict.latitude =  publicArtsListDict.latitude
                        publicArtsdbDict.longitude = publicArtsListDict.longitude
                        publicArtsdbDict.sortcoefficient = publicArtsListDict.sortcoefficient
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    }
                    else {
                        //save
                        self.saveToPublicArtsCoreData(publicArtsListDict: publicArtsListDict, managedObjContext: managedContext, lang: lang)
                    }
                }
            }
            else {
                for i in 0 ... (publicArtsListArray?.count)!-1 {
                    let publicArtsListDict : PublicArtsList?
                    publicArtsListDict = publicArtsListArray?[i]
                    self.saveToPublicArtsCoreData(publicArtsListDict: publicArtsListDict!, managedObjContext: managedContext, lang: lang)
                }
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "PublicArtsEntityArabic", idKey: "id", idValue: nil, managedContext: managedContext) as! [PublicArtsEntityArabic]
            if (fetchData.count > 0) {
                for i in 0 ... (publicArtsListArray?.count)!-1 {
                    let publicArtsListDict = publicArtsListArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "PublicArtsEntityArabic", idKey: "id", idValue: publicArtsListArray![i].id, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let publicArtsdbDict = fetchResult[0] as! PublicArtsEntityArabic
                        publicArtsdbDict.namearabic = publicArtsListDict.name
                        publicArtsdbDict.imagearabic = publicArtsListDict.image
                        publicArtsdbDict.latitudearabic =  publicArtsListDict.latitude
                        publicArtsdbDict.longitudearabic = publicArtsListDict.longitude
                        publicArtsdbDict.sortcoefficientarabic = publicArtsListDict.sortcoefficient
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    }
                    else {
                        //save
                        self.saveToPublicArtsCoreData(publicArtsListDict: publicArtsListDict, managedObjContext: managedContext, lang: lang)
                    }
                }
            }
            else {
                for i in 0 ... (publicArtsListArray?.count)!-1 {
                    let publicArtsListDict : PublicArtsList?
                    publicArtsListDict = publicArtsListArray?[i]
                    self.saveToPublicArtsCoreData(publicArtsListDict: publicArtsListDict!, managedObjContext: managedContext, lang: lang)
                    
                }
            }
        }
    }
    
    func saveToPublicArtsCoreData(publicArtsListDict: PublicArtsList, managedObjContext: NSManagedObjectContext,lang: String?) {
        if (lang == ENG_LANGUAGE) {
            let publicArtsInfo: PublicArtsEntity = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsEntity", into: managedObjContext) as! PublicArtsEntity
            publicArtsInfo.id = publicArtsListDict.id
            publicArtsInfo.name = publicArtsListDict.name
            publicArtsInfo.image = publicArtsListDict.image
            publicArtsInfo.latitude = publicArtsListDict.name
            publicArtsInfo.longitude = publicArtsListDict.image
            publicArtsInfo.sortcoefficient = publicArtsListDict.sortcoefficient
        }
        else {
            let publicArtsInfo: PublicArtsEntityArabic = NSEntityDescription.insertNewObject(forEntityName: "PublicArtsEntityArabic", into: managedObjContext) as! PublicArtsEntityArabic
            publicArtsInfo.id = publicArtsListDict.id
            publicArtsInfo.namearabic = publicArtsListDict.name
            publicArtsInfo.imagearabic = publicArtsListDict.image
            publicArtsInfo.latitudearabic = publicArtsListDict.name
            publicArtsInfo.longitudearabic = publicArtsListDict.image
            publicArtsInfo.sortcoefficientarabic = publicArtsListDict.sortcoefficient
        }
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchPublicArtsListFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var publicArtsArray = [PublicArtsEntity]()
                let publicArtsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "PublicArtsEntity")
                publicArtsArray = (try managedContext.fetch(publicArtsFetchRequest) as? [PublicArtsEntity])!
                if (publicArtsArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getPublicArtsListDataFromServer()
                        }
                    }
                    for i in 0 ... publicArtsArray.count-1 {
                        
                        self.publicArtsListArray.insert(PublicArtsList(id: publicArtsArray[i].id, name: publicArtsArray[i].name, latitude: publicArtsArray[i].latitude, longitude: publicArtsArray[i].longitude, image: publicArtsArray[i].image, sortcoefficient: publicArtsArray[i].sortcoefficient), at: i)
                        
                    }
                    if(publicArtsListArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    exhibitionCollectionView.reloadData()
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.exbtnLoadingView.showNoDataView()
                        self.getPublicArtsListDataFromServer()//coreDataMigratio  solution
                    }
                }
            }
            else {
                var publicArtsArray = [PublicArtsEntityArabic]()
                let publicArtsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "PublicArtsEntityArabic")
                publicArtsArray = (try managedContext.fetch(publicArtsFetchRequest) as? [PublicArtsEntityArabic])!
                if (publicArtsArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getPublicArtsListDataFromServer()
                        }
                    }
                    for i in 0 ... publicArtsArray.count-1 {
                        
                        self.publicArtsListArray.insert(PublicArtsList(id: publicArtsArray[i].id, name: publicArtsArray[i].namearabic, latitude: publicArtsArray[i].latitudearabic, longitude: publicArtsArray[i].longitudearabic, image: publicArtsArray[i].imagearabic, sortcoefficient: publicArtsArray[i].sortcoefficientarabic), at: i)
                    }
                    if(publicArtsListArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    exhibitionCollectionView.reloadData()
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.exbtnLoadingView.showNoDataView()
                         self.getPublicArtsListDataFromServer()//coreDataMigratio  solution
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if (networkReachability?.isReachable == false) {
                self.showNoNetwork()
            }
        }
    }
    @objc func receivePublicArtsListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (publicArtsListArray.count == 0)){
            self.fetchPublicArtsListFromCoredata()
        }
    }
    @objc func receivePublicArtsListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (publicArtsListArray.count == 0)){
            self.fetchPublicArtsListFromCoredata()
        }
    }
    func getCollectionList() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.CollectionList(LocalizationLanguage.currentAppleLanguage(),["museum_id": museumId ?? 0])).responseObject { (response: DataResponse<Collections>) -> Void in
            switch response.result {
            case .success(let data):
                if((self.museumId == "63") && (self.museumId == "96")) {
                    if(self.collection.count == 0) {
                        self.collection = data.collections!
                        self.exbtnLoadingView.stopLoading()
                        self.exbtnLoadingView.isHidden = true
                    }
                } else {
                    self.collection = data.collections!
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.isHidden = true
                }
                if(self.collection.count == 0) {
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                }else {
                    self.exhibitionCollectionView.reloadData()
                    self.saveOrUpdateCollectionCoredata(collection: data.collections)
                }
                
            case .failure( _):
                print("error")
                if((self.museumId != "63") && (self.museumId != "96")) {
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                    self.exbtnLoadingView.noDataLabel.text = errorMessage
                }
            }
        }
    }
    //MARK: CollectionList Coredata Method
    func saveOrUpdateCollectionCoredata(collection: [Collection]?) {
        if ((collection?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext, collection: collection!)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext, collection: collection!)
                }
            }
        }
    }
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext,collection: [Collection]?) {
        var fetchData = [CollectionsEntity]()
        var langVar : String? = nil
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
            fetchData = checkAddedToCoredata(entityName: "CollectionsEntity", idKey: "lang", idValue: langVar, managedContext: managedContext) as! [CollectionsEntity]
            if (fetchData.count > 0) {
                let isDeleted = self.deleteExistingEntityData(managedContext: managedContext, entityName: "CollectionsEntity")
                if(isDeleted == true) {
                    for i in 0 ... (collection?.count)!-1 {
                        let collectionListDict : Collection?
                        collectionListDict = collection?[i]
                        self.saveToCoreData(collectionListDict: collectionListDict!, managedObjContext: managedContext)
                    }
                }
            }
            else {
                for i in 0 ... (collection?.count)!-1 {
                    let collectionListDict : Collection?
                    collectionListDict = collection?[i]
                    self.saveToCoreData(collectionListDict: collectionListDict!, managedObjContext: managedContext)
                }
            }
    }
    func saveToCoreData(collectionListDict: Collection, managedObjContext: NSManagedObjectContext) {
        var langVar : String? = nil
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
            let collectionInfo: CollectionsEntity = NSEntityDescription.insertNewObject(forEntityName: "CollectionsEntity", into: managedObjContext) as! CollectionsEntity
            collectionInfo.listName = collectionListDict.name?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil)
            collectionInfo.listImage = collectionListDict.image
            collectionInfo.museumId = collectionListDict.museumId
            collectionInfo.lang = langVar
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchCollectionListFromCoredata() {
        let managedContext = getContext()
        do {
                var collectionArray = [CollectionsEntity]()
                collectionArray = checkAddedToCoredata(entityName: "CollectionsEntity", idKey: "museumId", idValue: museumId, managedContext: managedContext) as! [CollectionsEntity]
                if (collectionArray.count > 0) {
                    if((museumId == "63") || (museumId == "96")) {
                        if (networkReachability?.isReachable)! {
                            DispatchQueue.global(qos: .background).async {
                                self.getCollectionList()
                            }
                        }
                    }
                    for i in 0 ... collectionArray.count-1 {
                        self.collection.insert(Collection(name: collectionArray[i].listName?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil), image: collectionArray[i].listImage, museumId: collectionArray[i].museumId), at: i)
                    }
                    if(collection.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    exhibitionCollectionView.reloadData()
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.getCollectionList()//coreDataMigratio  solution
                    }
                }
   
        }
    }
    func deleteExistingEntityData(managedContext:NSManagedObjectContext,entityName : String?) ->Bool? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName!)
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        do{
            try managedContext.execute(deleteRequest)
            return true
        }catch _ as NSError {
            return false
        }
        
    }
    @objc func receiveCollectionListNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (collection.count == 0)){
            self.fetchCollectionListFromCoredata()
        }
    }
    @objc func receiveCollectionListNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (collection.count == 0)){
            self.fetchCollectionListFromCoredata()
        }
    }
    //MARK: DiningList WebServiceCall
    func getDiningListFromServer()
    {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.DiningList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<Dinings>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.diningListArray.count == 0) {
                    self.diningListArray = data.dinings
                    self.exhibitionCollectionView.reloadData()
                    if(self.diningListArray.count == 0) {
                        self.exbtnLoadingView.stopLoading()
                        self.exbtnLoadingView.noDataView.isHidden = false
                        self.exbtnLoadingView.isHidden = false
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
                if(self.diningListArray.count > 0) {
                    self.saveOrUpdateDiningCoredata(diningListArray: data.dinings, lang: LocalizationLanguage.currentAppleLanguage())
                }
            case .failure( _):
                if(self.diningListArray.count == 0) {
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: Museum DiningWebServiceCall
    func getMuseumDiningListFromServer()
    {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.MuseumDiningList(["museum_id": museumId ?? 0])).responseObject { (response: DataResponse<Dinings>) -> Void in
            switch response.result {
            case .success(let data):
                self.saveOrUpdateDiningCoredata(diningListArray: data.dinings, lang: LocalizationLanguage.currentAppleLanguage())
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Dining Coredata Method
    func saveOrUpdateDiningCoredata(diningListArray : [Dining]?,lang: String?) {
        if ((diningListArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate?.persistentContainer
                container?.performBackgroundTask() {(managedContext) in
                    self.diningCoreDataInBackgroundThread(managedContext: managedContext, diningListArray: diningListArray!, lang: lang)
                }
            } else {
                let managedContext = appDelegate?.managedObjectContext
                managedContext?.perform {
                    self.diningCoreDataInBackgroundThread(managedContext : managedContext!, diningListArray: diningListArray!, lang: lang)
                }
            }
        }
    }
    
    func diningCoreDataInBackgroundThread(managedContext: NSManagedObjectContext,diningListArray : [Dining]?,lang: String?) {
        var fetchData = [DiningEntity]()
        var langVar : String? = nil
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
            fetchData = checkAddedToCoredata(entityName: "DiningEntity",
                                             idKey: "lang",
                                             idValue: langVar,
                                             managedContext: managedContext) as! [DiningEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (diningListArray?.count)!-1 {
                    let diningListDict = diningListArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "DiningEntity",
                                                           idKey: "id",
                                                           idValue: diningListArray![i].id,
                                                           managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let diningdbDict = fetchResult[0] as! DiningEntity
                        diningdbDict.name = diningListDict.name
                        diningdbDict.image = diningListDict.image
                        diningdbDict.sortid =  diningListDict.sortid
                        diningdbDict.museumId =  diningListDict.museumId
                        diningdbDict.lang = langVar
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveToDiningCoreData(diningListDict: diningListDict, managedObjContext: managedContext, lang: lang)
                    }
                }
            }
            else {
                for i in 0 ... (diningListArray?.count)!-1 {
                    let diningListDict : Dining?
                    diningListDict = diningListArray?[i]
                    self.saveToDiningCoreData(diningListDict: diningListDict!, managedObjContext: managedContext, lang: lang)
                }
            }
    }
    
    func saveToDiningCoreData(diningListDict: Dining, managedObjContext: NSManagedObjectContext,lang: String?) {
        var langVar : String? = nil
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
            let diningInfoInfo: DiningEntity = NSEntityDescription.insertNewObject(forEntityName: "DiningEntity", into: managedObjContext) as! DiningEntity
            diningInfoInfo.id = diningListDict.id
            diningInfoInfo.name = diningListDict.name
            
            diningInfoInfo.image = diningListDict.image
            if(diningListDict.sortid != nil) {
                diningInfoInfo.sortid = diningListDict.sortid
            }
            diningInfoInfo.museumId = diningListDict.museumId
            diningInfoInfo.lang = langVar
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchMuseumDiningListFromCoredata() {
        let managedContext = getContext()
        do {
            
                var diningArray = [DiningEntity]()
                diningArray = checkAddedToCoredata(entityName: "DiningEntity", idKey: "museumId", idValue: museumId, managedContext: managedContext) as! [DiningEntity]
                
                if (diningArray.count > 0) {
                    for i in 0 ... diningArray.count-1 {
                        self.diningListArray.insert(Dining(id: diningArray[i].id, name: diningArray[i].name, location: diningArray[i].location, description: diningArray[i].diningdescription, image: diningArray[i].image, openingtime: diningArray[i].openingtime, closetime: diningArray[i].closetime, sortid: diningArray[i].sortid,museumId: diningArray[i].museumId, images: nil), at: i)
                    }
                    if(diningListArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    DispatchQueue.main.async{
                        self.exhibitionCollectionView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                         self.exbtnLoadingView.showNoDataView()
                    }
                }
        }
    }
    
    func fetchDiningListFromCoredata() {
        let managedContext = getContext()
        do {
            var diningArray = [DiningEntity]()
            var langVar : String? = nil
            if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
                langVar = "1"
                
            } else {
                langVar = "0"
            }
            diningArray = checkAddedToCoredata(entityName: "DiningEntity", idKey: "lang", idValue: langVar, managedContext: managedContext) as! [DiningEntity]
                if (diningArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getDiningListFromServer()
                        }
                    }
                    for i in 0 ... diningArray.count-1 {
                        self.diningListArray.insert(Dining(id: diningArray[i].id, name: diningArray[i].name, location: diningArray[i].location, description: diningArray[i].diningdescription, image: diningArray[i].image, openingtime: diningArray[i].openingtime, closetime: diningArray[i].closetime, sortid: diningArray[i].sortid,museumId: diningArray[i].museumId, images: nil), at: i)
                        
                    }
                    if(diningListArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    DispatchQueue.main.async{
                        self.exhibitionCollectionView.reloadData()
                    }
                } else {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                       // self.exbtnLoadingView.showNoDataView()
                        self.getDiningListFromServer()//coreDataMigratio  solution
                    }
                }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if (networkReachability?.isReachable == false) {
                self.showNoNetwork()
            }
        }
    }
    //MARK: NMoQTour SecondList Methods
    //MARK: ServiceCall
    func getNMoQTourDetail() {
        if(tourDetailId != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQTourDetail(["event_id" : tourDetailId!])).responseObject { (response: DataResponse<NMoQTourDetailList>) -> Void in
                switch response.result {
                case .success(let data):
                    self.nmoqTourDetail = data.nmoqTourDetailList
                    if self.nmoqTourDetail.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                        self.nmoqTourDetail = self.nmoqTourDetail.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                    self.exhibitionCollectionView.reloadData()
                    if(self.nmoqTourDetail.count == 0) {
                        let noResultMsg = NSLocalizedString("NO_RESULT_MESSAGE",
                                                            comment: "Setting the content of the alert")
                        self.exbtnLoadingView.stopLoading()
                        self.exbtnLoadingView.noDataView.isHidden = false
                        self.exbtnLoadingView.isHidden = false
                        self.exbtnLoadingView.showNoDataView()
                        self.exbtnLoadingView.noDataLabel.text = noResultMsg
                    } else {
                        self.saveOrUpdateTourDetailCoredata()
                    }
                case .failure( _):
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                    self.exbtnLoadingView.noDataLabel.text = errorMessage
                }
            }
        }
        
    }
    
    //MARK: Coredata Method
    func saveOrUpdateTourDetailCoredata() {
        if (nmoqTourDetail.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "NmoqTourDetailEntity", idKey: "nmoqEvent", idValue: tourDetailId, managedContext: managedContext) as! [NmoqTourDetailEntity]
            if (fetchData.count > 0) {
                for i in 0 ... nmoqTourDetail.count-1 {
                    let tourDetailDict = nmoqTourDetail[i]
                    let fetchResult = checkAddedToCoredata(entityName: "NmoqTourDetailEntity", idKey: "nid", idValue: tourDetailDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let tourDetaildbDict = fetchResult[0] as! NmoqTourDetailEntity
                        tourDetaildbDict.title = tourDetailDict.title
                        tourDetaildbDict.date = tourDetailDict.date
                        tourDetaildbDict.nmoqEvent =  tourDetailDict.nmoqEvent
                        tourDetaildbDict.register =  tourDetailDict.register
                        tourDetaildbDict.contactEmail = tourDetailDict.contactEmail
                        tourDetaildbDict.contactPhone = tourDetailDict.contactPhone
                        tourDetaildbDict.mobileLatitude =  tourDetailDict.mobileLatitude
                        tourDetaildbDict.longitude =  tourDetailDict.longitude
                        tourDetaildbDict.sort_id = tourDetailDict.sortId
                        tourDetaildbDict.body = tourDetailDict.body
                        tourDetaildbDict.registered =  tourDetailDict.registered
                        tourDetaildbDict.nid =  tourDetailDict.nid
                        tourDetaildbDict.seatsRemaining =  tourDetailDict.seatsRemaining
                        
                        if(tourDetailDict.imageBanner != nil){
                            if((tourDetailDict.imageBanner?.count)! > 0) {
                                for i in 0 ... (tourDetailDict.imageBanner?.count)!-1 {
                                    var tourImage: NMoqTourDetailImagesEntity
                                    let tourImgaeArray: NMoqTourDetailImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoqTourDetailImagesEntity", into: managedContext) as! NMoqTourDetailImagesEntity
                                    tourImgaeArray.imgBanner = tourDetailDict.imageBanner?[i]
                                    tourImage = tourImgaeArray
                                    tourDetaildbDict.addToNmoqTourDetailImgBannerRelation(tourImage)
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
                    }
                    else {
                        //save
                        self.saveTourDetailsToCoreData(tourDetailDict: tourDetailDict, managedObjContext: managedContext)
                    }
                }
            }
            else {
                for i in 0 ... nmoqTourDetail.count-1 {
                    let tourDetailDict : NMoQTourDetail?
                    tourDetailDict = nmoqTourDetail[i]
                    self.saveTourDetailsToCoreData(tourDetailDict: tourDetailDict!, managedObjContext: managedContext)
                }
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "NmoqTourDetailEntityAr", idKey: "nmoqEvent", idValue: tourDetailId, managedContext: managedContext) as! [NmoqTourDetailEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... nmoqTourDetail.count-1 {
                    let tourDetailDict = nmoqTourDetail[i]
                    let fetchResult = checkAddedToCoredata(entityName: "NmoqTourDetailEntityAr", idKey: "nid", idValue: tourDetailDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let tourDetaildbDict = fetchResult[0] as! NmoqTourDetailEntityAr
                        tourDetaildbDict.title = tourDetailDict.title
                        tourDetaildbDict.date = tourDetailDict.date
                        tourDetaildbDict.nmoqEvent =  tourDetailDict.nmoqEvent
                        tourDetaildbDict.register =  tourDetailDict.register
                        tourDetaildbDict.contactEmail = tourDetailDict.contactEmail
                        tourDetaildbDict.contactPhone = tourDetailDict.contactPhone
                        tourDetaildbDict.mobileLatitude =  tourDetailDict.mobileLatitude
                        tourDetaildbDict.longitude =  tourDetailDict.longitude
                        tourDetaildbDict.sort_id = tourDetailDict.sortId
                        tourDetaildbDict.body = tourDetailDict.body
                        tourDetaildbDict.registered =  tourDetailDict.registered
                        tourDetaildbDict.nid =  tourDetailDict.nid
                        tourDetaildbDict.seatsRemaining =  tourDetailDict.seatsRemaining
                        
                        if(tourDetailDict.imageBanner != nil){
                            if((tourDetailDict.imageBanner?.count)! > 0) {
                                for i in 0 ... (tourDetailDict.imageBanner?.count)!-1 {
                                    var tourImage: NMoqTourDetailImagesEntityAr
                                    let tourImgaeArray: NMoqTourDetailImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoqTourDetailImagesEntityAr", into: managedContext) as! NMoqTourDetailImagesEntityAr
                                    tourImgaeArray.imgBanner = tourDetailDict.imageBanner?[i]
                                    
                                    tourImage = tourImgaeArray
                                    tourDetaildbDict.addToNmoqTourDetailImgBannerRelationAr(tourImage)
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
                    }
                    else {
                        //save
                        self.saveTourDetailsToCoreData(tourDetailDict: tourDetailDict, managedObjContext: managedContext)
                    }
                }
            }
            else {
                for i in 0 ... nmoqTourDetail.count-1 {
                    let tourDetailDict : NMoQTourDetail?
                    tourDetailDict = nmoqTourDetail[i]
                    self.saveTourDetailsToCoreData(tourDetailDict: tourDetailDict!, managedObjContext: managedContext)
                }
            }
        }
    }
    func saveTourDetailsToCoreData(tourDetailDict: NMoQTourDetail, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let tourDetaildbDict: NmoqTourDetailEntity = NSEntityDescription.insertNewObject(forEntityName: "NmoqTourDetailEntity", into: managedObjContext) as! NmoqTourDetailEntity
            tourDetaildbDict.title = tourDetailDict.title
            tourDetaildbDict.date = tourDetailDict.date
            tourDetaildbDict.nmoqEvent =  tourDetailDict.nmoqEvent
            tourDetaildbDict.register =  tourDetailDict.register
            tourDetaildbDict.contactEmail = tourDetailDict.contactEmail
            tourDetaildbDict.contactPhone = tourDetailDict.contactPhone
            tourDetaildbDict.mobileLatitude =  tourDetailDict.mobileLatitude
            tourDetaildbDict.longitude =  tourDetailDict.longitude
            tourDetaildbDict.sort_id = tourDetailDict.sortId
            tourDetaildbDict.body = tourDetailDict.body
            tourDetaildbDict.registered =  tourDetailDict.registered
            tourDetaildbDict.nid =  tourDetailDict.nid
            tourDetaildbDict.seatsRemaining =  tourDetailDict.seatsRemaining
            if(tourDetailDict.imageBanner != nil){
                if((tourDetailDict.imageBanner?.count)! > 0) {
                    for i in 0 ... (tourDetailDict.imageBanner?.count)!-1 {
                        var tourImage: NMoqTourDetailImagesEntity
                        let tourImgaeArray: NMoqTourDetailImagesEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoqTourDetailImagesEntity", into: managedObjContext) as! NMoqTourDetailImagesEntity
                        tourImgaeArray.imgBanner = tourDetailDict.imageBanner?[i]
                        
                        tourImage = tourImgaeArray
                        tourDetaildbDict.addToNmoqTourDetailImgBannerRelation(tourImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        } else {
            let tourDetaildbDict: NmoqTourDetailEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NmoqTourDetailEntityAr", into: managedObjContext) as! NmoqTourDetailEntityAr
            tourDetaildbDict.title = tourDetailDict.title
            tourDetaildbDict.date = tourDetailDict.date
            tourDetaildbDict.nmoqEvent =  tourDetailDict.nmoqEvent
            tourDetaildbDict.register =  tourDetailDict.register
            tourDetaildbDict.contactEmail = tourDetailDict.contactEmail
            tourDetaildbDict.contactPhone = tourDetailDict.contactPhone
            tourDetaildbDict.mobileLatitude =  tourDetailDict.mobileLatitude
            tourDetaildbDict.longitude =  tourDetailDict.longitude
            tourDetaildbDict.sort_id = tourDetailDict.sortId
            tourDetaildbDict.body = tourDetailDict.body
            tourDetaildbDict.registered =  tourDetailDict.registered
            tourDetaildbDict.nid =  tourDetailDict.nid
            tourDetaildbDict.seatsRemaining =  tourDetailDict.seatsRemaining
            if(tourDetailDict.imageBanner != nil){
                if((tourDetailDict.imageBanner?.count)! > 0) {
                    for i in 0 ... (tourDetailDict.imageBanner?.count)!-1 {
                        var tourImage: NMoqTourDetailImagesEntityAr
                        let tourImgaeArray: NMoqTourDetailImagesEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoqTourDetailImagesEntityAr", into: managedObjContext) as! NMoqTourDetailImagesEntityAr
                        tourImgaeArray.imgBanner = tourDetailDict.imageBanner?[i]
                        
                        tourImage = tourImgaeArray
                        tourDetaildbDict.addToNmoqTourDetailImgBannerRelationAr(tourImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchTourDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var tourDetailArray = [NmoqTourDetailEntity]()
                tourDetailArray = checkAddedToCoredata(entityName: "NmoqTourDetailEntity", idKey: "nmoqEvent", idValue: tourDetailId, managedContext: managedContext) as! [NmoqTourDetailEntity]
                if (tourDetailArray.count > 0) {
                    for i in 0 ... tourDetailArray.count-1 {
                        var imagesArray : [String] = []
                        let imagesInfoArray = (tourDetailArray[i].nmoqTourDetailImgBannerRelation?.allObjects) as! [NMoqTourDetailImagesEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].imgBanner!)
                            }
                        }
                        
                        self.nmoqTourDetail.insert(NMoQTourDetail(title: tourDetailArray[i].title, imageBanner: imagesArray, date: tourDetailArray[i].date, nmoqEvent: tourDetailArray[i].nmoqEvent, register: tourDetailArray[i].register, contactEmail: tourDetailArray[i].contactEmail, contactPhone: tourDetailArray[i].contactPhone, mobileLatitude: tourDetailArray[i].mobileLatitude, longitude: tourDetailArray[i].longitude, sortId: tourDetailArray[i].sort_id, body: tourDetailArray[i].body, registered: tourDetailArray[i].registered, nid: tourDetailArray[i].nid,seatsRemaining: tourDetailArray[i].seatsRemaining), at: i)
                    }
                    if(nmoqTourDetail.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    DispatchQueue.main.async{
                        self.exhibitionCollectionView.reloadData()
                    }
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
            } else {
                var tourDetailArray = [NmoqTourDetailEntityAr]()
                tourDetailArray = checkAddedToCoredata(entityName: "NmoqTourDetailEntityAr", idKey: "nmoqEvent", idValue: tourDetailId, managedContext: managedContext) as! [NmoqTourDetailEntityAr]
                if (tourDetailArray.count > 0) {
                    for i in 0 ... tourDetailArray.count-1 {
                        var imagesArray : [String] = []
                        let imagesInfoArray = (tourDetailArray[i].nmoqTourDetailImgBannerRelationAr?.allObjects) as! [NMoqTourDetailImagesEntityAr]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].imgBanner!)
                            }
                        }
                        self.nmoqTourDetail.insert(NMoQTourDetail(title: tourDetailArray[i].title, imageBanner: imagesArray, date: tourDetailArray[i].date, nmoqEvent: tourDetailArray[i].nmoqEvent, register: tourDetailArray[i].register, contactEmail: tourDetailArray[i].contactEmail, contactPhone: tourDetailArray[i].contactPhone, mobileLatitude: tourDetailArray[i].mobileLatitude, longitude: tourDetailArray[i].longitude, sortId: tourDetailArray[i].sort_id, body: tourDetailArray[i].body, registered: tourDetailArray[i].registered, nid: tourDetailArray[i].nid,seatsRemaining: tourDetailArray[i].seatsRemaining), at: i)
                        
                    }
                    if(nmoqTourDetail.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    DispatchQueue.main.async{
                        self.exhibitionCollectionView.reloadData()
                    }
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
            }
        }
    }
    //MARK: Facilities SecondaryList ServiceCall
    func getFacilitiesDetail() {
        if(tourDetailId != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetFacilitiesDetail(["category_id" : tourDetailId!])).responseObject { (response: DataResponse<FacilitiesDetailData>) -> Void in
                switch response.result {
                case .success(let data):
                    self.facilitiesDetail = data.facilitiesDetail
                    self.exhibitionCollectionView.reloadData()
                    if(self.nmoqTourDetail.count == 0) {
                        let noResultMsg = NSLocalizedString("NO_RESULT_MESSAGE",
                                                            comment: "Setting the content of the alert")
                        self.exbtnLoadingView.stopLoading()
                        self.exbtnLoadingView.noDataView.isHidden = false
                        self.exbtnLoadingView.isHidden = false
                        self.exbtnLoadingView.showNoDataView()
                        self.exbtnLoadingView.noDataLabel.text = noResultMsg
                    } else {
                        self.saveOrUpdateFacilitiesDetailCoredata()
                    }
                case .failure( _):
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                    self.exbtnLoadingView.noDataLabel.text = errorMessage
                }
            }
        }
        
    }
    //MARK: Coredata Method
    func saveOrUpdateFacilitiesDetailCoredata() {
        if (facilitiesDetail.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.facilitiesDetailCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.facilitiesDetailCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    func facilitiesDetailCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "FacilitiesDetailEntity", idKey: "category", idValue: tourDetailId, managedContext: managedContext) as! [FacilitiesDetailEntity]
            if (fetchData.count > 0) {
                for i in 0 ... facilitiesDetail.count-1 {
                    let facilitiesDetailDict = facilitiesDetail[i]
                    let fetchResult = checkAddedToCoredata(entityName: "FacilitiesDetailEntity", idKey: "nid", idValue: facilitiesDetailDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let facilitiesDetaildbDict = fetchResult[0] as! FacilitiesDetailEntity
                        facilitiesDetaildbDict.title = facilitiesDetailDict.title
                        facilitiesDetaildbDict.subtitle = facilitiesDetailDict.subtitle
                        facilitiesDetaildbDict.facilitiesDes =  facilitiesDetailDict.facilitiesDes
                        facilitiesDetaildbDict.timing =  facilitiesDetailDict.timing
                        facilitiesDetaildbDict.titleTiming = facilitiesDetailDict.titleTiming
                        facilitiesDetaildbDict.nid = facilitiesDetailDict.nid
                        facilitiesDetaildbDict.longtitude =  facilitiesDetailDict.longtitude
                        facilitiesDetaildbDict.category =  facilitiesDetailDict.category
                        facilitiesDetaildbDict.latitude = facilitiesDetailDict.latitude
                        facilitiesDetaildbDict.locationTitle = facilitiesDetailDict.locationTitle
                        
                        
                        if(facilitiesDetailDict.images != nil){
                            if((facilitiesDetailDict.images?.count)! > 0) {
                                for i in 0 ... (facilitiesDetailDict.images?.count)!-1 {
                                    var facilitiesDetailImage: FacilitiesDetailImgEntity
                                    let facilitiesImgaeArray: FacilitiesDetailImgEntity = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesDetailImgEntity", into: managedContext) as! FacilitiesDetailImgEntity
                                    facilitiesImgaeArray.images = facilitiesDetailDict.images?[i]
                                    facilitiesDetailImage = facilitiesImgaeArray
                                    facilitiesDetaildbDict.addToFacilitiesDetailRelation(facilitiesDetailImage)
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
                    }
                    else {
                        //save
                        self.saveFacilitiesDetailsToCoreData(facilitiesDetailDict: facilitiesDetailDict, managedObjContext: managedContext)
                    }
                }
            }
            else {
                for i in 0 ... facilitiesDetail.count-1 {
                    let facilitiesDetailDict : FacilitiesDetail?
                    facilitiesDetailDict = facilitiesDetail[i]
                    self.saveFacilitiesDetailsToCoreData(facilitiesDetailDict: facilitiesDetailDict!, managedObjContext: managedContext)
                }
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "FacilitiesDetailEntityAr", idKey: "category", idValue: tourDetailId, managedContext: managedContext) as! [FacilitiesDetailEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... facilitiesDetail.count-1 {
                    let facilitiesDetailDict = facilitiesDetail[i]
                    let fetchResult = checkAddedToCoredata(entityName: "FacilitiesDetailEntityAr", idKey: "nid", idValue: facilitiesDetailDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let facilitiesDetaildbDict = fetchResult[0] as! FacilitiesDetailEntityAr
                        facilitiesDetaildbDict.title = facilitiesDetailDict.title
                        facilitiesDetaildbDict.subtitle = facilitiesDetailDict.subtitle
                        facilitiesDetaildbDict.facilitiesDes =  facilitiesDetailDict.facilitiesDes
                        facilitiesDetaildbDict.timing =  facilitiesDetailDict.timing
                        facilitiesDetaildbDict.titleTiming = facilitiesDetailDict.titleTiming
                        facilitiesDetaildbDict.nid = facilitiesDetailDict.nid
                        facilitiesDetaildbDict.longtitude =  facilitiesDetailDict.longtitude
                        facilitiesDetaildbDict.category =  facilitiesDetailDict.category
                        facilitiesDetaildbDict.latitude = facilitiesDetailDict.latitude
                        facilitiesDetaildbDict.locationTitle = facilitiesDetailDict.locationTitle
                        
                        if(facilitiesDetailDict.images != nil){
                            if((facilitiesDetailDict.images?.count)! > 0) {
                                for i in 0 ... (facilitiesDetailDict.images?.count)!-1 {
                                    var facilitiesDetailImage: FacilitiesDetailImgEntityAr
                                    let facilitiesImgaeArray: FacilitiesDetailImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesDetailImgEntityAr", into: managedContext) as! FacilitiesDetailImgEntityAr
                                    facilitiesImgaeArray.images = facilitiesDetailDict.images?[i]
                                    facilitiesDetailImage = facilitiesImgaeArray
                                    facilitiesDetaildbDict.addToFacilitiesDetailRelationAr(facilitiesDetailImage)
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
                    }
                    else {
                        //save
                        self.saveFacilitiesDetailsToCoreData(facilitiesDetailDict: facilitiesDetailDict, managedObjContext: managedContext)
                    }
                }
            }
            else {
                for i in 0 ... facilitiesDetail.count-1 {
                    let facilitiesDetailDict : FacilitiesDetail?
                    facilitiesDetailDict = facilitiesDetail[i]
                    self.saveFacilitiesDetailsToCoreData(facilitiesDetailDict: facilitiesDetailDict!, managedObjContext: managedContext)
                }
            }
        }
    }
    func saveFacilitiesDetailsToCoreData(facilitiesDetailDict: FacilitiesDetail, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let facilitiesDetaildbDict: FacilitiesDetailEntity = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesDetailEntity", into: managedObjContext) as! FacilitiesDetailEntity
            facilitiesDetaildbDict.title = facilitiesDetailDict.title
            facilitiesDetaildbDict.subtitle = facilitiesDetailDict.subtitle
            facilitiesDetaildbDict.facilitiesDes =  facilitiesDetailDict.facilitiesDes
            facilitiesDetaildbDict.timing =  facilitiesDetailDict.timing
            facilitiesDetaildbDict.titleTiming = facilitiesDetailDict.titleTiming
            facilitiesDetaildbDict.nid = facilitiesDetailDict.nid
            facilitiesDetaildbDict.longtitude =  facilitiesDetailDict.longtitude
            facilitiesDetaildbDict.category =  facilitiesDetailDict.category
            facilitiesDetaildbDict.latitude = facilitiesDetailDict.latitude
            facilitiesDetaildbDict.locationTitle = facilitiesDetailDict.locationTitle
            
            if(facilitiesDetailDict.images != nil){
                if((facilitiesDetailDict.images?.count)! > 0) {
                    for i in 0 ... (facilitiesDetailDict.images?.count)!-1 {
                        var facilitiesDetailImage: FacilitiesDetailImgEntity
                        let facilitiesImgaeArray: FacilitiesDetailImgEntity = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesDetailImgEntity", into: managedObjContext) as! FacilitiesDetailImgEntity
                        facilitiesImgaeArray.images = facilitiesDetailDict.images?[i]
                        facilitiesDetailImage = facilitiesImgaeArray
                        facilitiesDetaildbDict.addToFacilitiesDetailRelation(facilitiesDetailImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        } else {
            let facilitiesDetaildbDict: FacilitiesDetailEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesDetailEntityAr", into: managedObjContext) as! FacilitiesDetailEntityAr
            facilitiesDetaildbDict.title = facilitiesDetailDict.title
            facilitiesDetaildbDict.subtitle = facilitiesDetailDict.subtitle
            facilitiesDetaildbDict.facilitiesDes =  facilitiesDetailDict.facilitiesDes
            facilitiesDetaildbDict.timing =  facilitiesDetailDict.timing
            facilitiesDetaildbDict.titleTiming = facilitiesDetailDict.titleTiming
            facilitiesDetaildbDict.nid = facilitiesDetailDict.nid
            facilitiesDetaildbDict.longtitude =  facilitiesDetailDict.longtitude
            facilitiesDetaildbDict.category =  facilitiesDetailDict.category
            facilitiesDetaildbDict.latitude = facilitiesDetailDict.latitude
            facilitiesDetaildbDict.locationTitle = facilitiesDetailDict.locationTitle
            
            if(facilitiesDetailDict.images != nil){
                if((facilitiesDetailDict.images?.count)! > 0) {
                    for i in 0 ... (facilitiesDetailDict.images?.count)!-1 {
                        var facilitiesDetailImage: FacilitiesDetailImgEntityAr
                        let facilitiesImgaeArray: FacilitiesDetailImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "FacilitiesDetailImgEntityAr", into: managedObjContext) as! FacilitiesDetailImgEntityAr
                        facilitiesImgaeArray.images = facilitiesDetailDict.images?[i]
                        facilitiesDetailImage = facilitiesImgaeArray
                        facilitiesDetaildbDict.addToFacilitiesDetailRelationAr(facilitiesDetailImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchFacilitiesDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var facilitiesDetailArray = [FacilitiesDetailEntity]()
                facilitiesDetailArray = checkAddedToCoredata(entityName: "FacilitiesDetailEntity", idKey: "category", idValue: tourDetailId, managedContext: managedContext) as! [FacilitiesDetailEntity]
                if (facilitiesDetailArray.count > 0) {
                    for i in 0 ... facilitiesDetailArray.count-1 {
                        var imagesArray : [String] = []
                        let imagesInfoArray = (facilitiesDetailArray[i].facilitiesDetailRelation!.allObjects) as! [FacilitiesDetailImgEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.facilitiesDetail.insert(FacilitiesDetail(title: facilitiesDetailArray[i].title, images: imagesArray, subtitle: facilitiesDetailArray[i].subtitle, facilitiesDes: facilitiesDetailArray[i].facilitiesDes, timing: facilitiesDetailArray[i].timing, titleTiming: facilitiesDetailArray[i].titleTiming, nid: facilitiesDetailArray[i].nid, longtitude: facilitiesDetailArray[i].longtitude, category: facilitiesDetailArray[i].category, latitude: facilitiesDetailArray[i].latitude, locationTitle: facilitiesDetailArray[i].locationTitle), at: i)
                        
                    }
                    if(facilitiesDetail.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    DispatchQueue.main.async{
                        self.exhibitionCollectionView.reloadData()
                    }
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
            } else {
                var facilitiesDetailArray = [FacilitiesDetailEntityAr]()
                facilitiesDetailArray = checkAddedToCoredata(entityName: "FacilitiesDetailEntityAr", idKey: "category", idValue: tourDetailId, managedContext: managedContext) as! [FacilitiesDetailEntityAr]
                if (facilitiesDetailArray.count > 0) {
                    for i in 0 ... facilitiesDetailArray.count-1 {
                        var imagesArray : [String] = []
                        let imagesInfoArray = (facilitiesDetailArray[i].facilitiesDetailRelationAr?.allObjects) as! [FacilitiesDetailImgEntityAr]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.facilitiesDetail.insert(FacilitiesDetail(title: facilitiesDetailArray[i].title, images: imagesArray, subtitle: facilitiesDetailArray[i].subtitle, facilitiesDes: facilitiesDetailArray[i].facilitiesDes, timing: facilitiesDetailArray[i].timing, titleTiming: facilitiesDetailArray[i].titleTiming, nid: facilitiesDetailArray[i].nid, longtitude: facilitiesDetailArray[i].longtitude, category: facilitiesDetailArray[i].category, latitude: facilitiesDetailArray[i].latitude, locationTitle: facilitiesDetailArray[i].locationTitle), at: i)
                        
                    }
                    if(facilitiesDetail.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    DispatchQueue.main.async{
                        self.exhibitionCollectionView.reloadData()
                    }
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
            }
        }
    }
    //MARK: WebServiceCall
    func getTourGuideDataFromServer() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.MuseumTourGuide(LocalizationLanguage.currentAppleLanguage(),["museum_id": museumId ?? 0])).responseObject { (response: DataResponse<TourGuides>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.miaTourDataFullArray.count == 0) {
                    self.miaTourDataFullArray = data.tourGuide!
                    self.exhibitionCollectionView.reloadData()
                    //if no result after api call
                    if(self.miaTourDataFullArray.count == 0) {
                        self.exbtnLoadingView.stopLoading()
                        self.exbtnLoadingView.noDataView.isHidden = false
                        self.exbtnLoadingView.isHidden = false
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
                if(self.miaTourDataFullArray.count > 0) {
                    self.saveOrUpdateTourGuideCoredata(miaTourDataFullArray: data.tourGuide)
                }
            case .failure(let error):
                if(self.miaTourDataFullArray.count == 0) {
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                }
            }
        }
    }
    
    //MARK: Coredata Method
    func saveOrUpdateTourGuideCoredata(miaTourDataFullArray:[TourGuide]?) {
        if ((miaTourDataFullArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.coreDataInBackgroundThread(managedContext: managedContext, miaTourDataFullArray: miaTourDataFullArray)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.coreDataInBackgroundThread(managedContext : managedContext, miaTourDataFullArray: miaTourDataFullArray)
                }
            }
        }
    }
    
    func coreDataInBackgroundThread(managedContext: NSManagedObjectContext,miaTourDataFullArray:[TourGuide]?) {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let fetchData = checkAddedToCoredata(entityName: "TourGuideEntity", idKey: "museumsEntity", idValue: museumId, managedContext: managedContext) as! [TourGuideEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (miaTourDataFullArray?.count)!-1 {
                    let tourGuideListDict = miaTourDataFullArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "TourGuideEntity", idKey: "nid", idValue: miaTourDataFullArray![i].nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let tourguidedbDict = fetchResult[0] as! TourGuideEntity
                        tourguidedbDict.title = tourGuideListDict.title
                        tourguidedbDict.tourGuideDescription = tourGuideListDict.tourGuideDescription
                        tourguidedbDict.museumsEntity =  tourGuideListDict.museumsEntity
                        tourguidedbDict.nid =  tourGuideListDict.nid
                        
                        if(tourGuideListDict.multimediaFile != nil) {
                            if((tourGuideListDict.multimediaFile?.count)! > 0) {
                                for i in 0 ... (tourGuideListDict.multimediaFile?.count)!-1 {
                                    var multimediaEntity: TourGuideMultimediaEntity!
                                    let multimediaArray: TourGuideMultimediaEntity = NSEntityDescription.insertNewObject(forEntityName: "TourGuideMultimediaEntity", into: managedContext) as! TourGuideMultimediaEntity
                                    multimediaArray.multimediaFile = tourGuideListDict.multimediaFile![i]
                                    
                                    multimediaEntity = multimediaArray
                                    tourguidedbDict.addToTourGuideMultimediaRelation(multimediaEntity)
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
                    }
                    else {
                        //save
                        self.saveToCoreData(tourguideListDict: tourGuideListDict, managedObjContext: managedContext)
                        
                    }
                }
            }
            else {
                for i in 0 ... (miaTourDataFullArray?.count)!-1 {
                    let tourGuideListDict : TourGuide?
                    tourGuideListDict = miaTourDataFullArray?[i]
                    self.saveToCoreData(tourguideListDict: tourGuideListDict!, managedObjContext: managedContext)
                    
                }
            }
        }
        else {
            let fetchData = checkAddedToCoredata(entityName: "TourGuideEntityAr", idKey: "museumsEntity", idValue: museumId, managedContext: managedContext) as! [TourGuideEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (miaTourDataFullArray?.count)!-1 {
                    let tourGuideListDict = miaTourDataFullArray![i]
                    let fetchResult = checkAddedToCoredata(entityName: "TourGuideEntityAr", idKey: "nid" , idValue: miaTourDataFullArray![i].nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let tourguidedbDict = fetchResult[0] as! TourGuideEntityAr
                        tourguidedbDict.title = tourGuideListDict.title
                        tourguidedbDict.tourGuideDescription = tourGuideListDict.tourGuideDescription
                        tourguidedbDict.museumsEntity =  tourGuideListDict.museumsEntity
                        tourguidedbDict.nid =  tourGuideListDict.nid
                        
                        if(tourGuideListDict.multimediaFile != nil) {
                            if((tourGuideListDict.multimediaFile?.count)! > 0) {
                                for i in 0 ... (tourGuideListDict.multimediaFile?.count)!-1 {
                                    var multimediaEntity: TourGuideMultimediaEntityAr!
                                    let multimediaArray: TourGuideMultimediaEntityAr = NSEntityDescription.insertNewObject(forEntityName: "TourGuideMultimediaEntityAr", into: managedContext) as! TourGuideMultimediaEntityAr
                                    multimediaArray.multimediaFile = tourGuideListDict.multimediaFile![i]
                                    
                                    multimediaEntity = multimediaArray
                                    tourguidedbDict.addToTourGuideMultimediaRelation(multimediaEntity)
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
                    }
                    else {
                        //save
                        self.saveToCoreData(tourguideListDict: tourGuideListDict, managedObjContext: managedContext)
                        
                    }
                }
            }
            else {
                for i in 0 ... (miaTourDataFullArray?.count)!-1 {
                    let tourGuideListDict : TourGuide?
                    tourGuideListDict = miaTourDataFullArray?[i]
                    self.saveToCoreData(tourguideListDict: tourGuideListDict!, managedObjContext: managedContext)
                    
                }
            }
        }
    }
    
    func saveToCoreData(tourguideListDict: TourGuide, managedObjContext: NSManagedObjectContext) {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            let tourGuideInfo: TourGuideEntity = NSEntityDescription.insertNewObject(forEntityName: "TourGuideEntity", into: managedObjContext) as! TourGuideEntity
            tourGuideInfo.title = tourguideListDict.title
            tourGuideInfo.tourGuideDescription = tourguideListDict.tourGuideDescription
            tourGuideInfo.museumsEntity = tourguideListDict.museumsEntity
            tourGuideInfo.nid = tourguideListDict.nid
            
            if(tourguideListDict.multimediaFile != nil) {
                if((tourguideListDict.multimediaFile?.count)! > 0) {
                    for i in 0 ... (tourguideListDict.multimediaFile?.count)!-1 {
                        var multimediaEntity: TourGuideMultimediaEntity!
                        let multimediaArray: TourGuideMultimediaEntity = NSEntityDescription.insertNewObject(forEntityName: "TourGuideMultimediaEntity", into: managedObjContext) as! TourGuideMultimediaEntity
                        multimediaArray.multimediaFile = tourguideListDict.multimediaFile![i]
                        
                        multimediaEntity = multimediaArray
                        tourGuideInfo.addToTourGuideMultimediaRelation(multimediaEntity)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                    }
                }
            }
        }
        else {
            let tourGuideInfo: TourGuideEntityAr = NSEntityDescription.insertNewObject(forEntityName: "TourGuideEntityAr", into: managedObjContext) as! TourGuideEntityAr
            tourGuideInfo.title = tourguideListDict.title
            tourGuideInfo.tourGuideDescription = tourguideListDict.tourGuideDescription
            tourGuideInfo.museumsEntity = tourguideListDict.museumsEntity
            tourGuideInfo.nid = tourguideListDict.nid
            if(tourguideListDict.multimediaFile != nil) {
                if((tourguideListDict.multimediaFile?.count)! > 0) {
                    for i in 0 ... (tourguideListDict.multimediaFile?.count)!-1 {
                        var multimediaEntity: TourGuideMultimediaEntityAr!
                        let multimediaArray: TourGuideMultimediaEntityAr = NSEntityDescription.insertNewObject(forEntityName: "TourGuideMultimediaEntityAr", into: managedObjContext) as! TourGuideMultimediaEntityAr
                        multimediaArray.multimediaFile = tourguideListDict.multimediaFile![i]
                        
                        multimediaEntity = multimediaArray
                        tourGuideInfo.addToTourGuideMultimediaRelation(multimediaEntity)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        
                    }
                }
            }
        }
        do {
            try managedObjContext.save()
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchTourGuideListFromCoredata() {
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var tourGuideArray = [TourGuideEntity]()
                tourGuideArray = checkAddedToCoredata(entityName: "TourGuideEntity", idKey: "museumsEntity", idValue: museumId, managedContext: managedContext) as! [TourGuideEntity]
                
                if (tourGuideArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getTourGuideDataFromServer()
                        }
                    }
                    for i in 0 ... tourGuideArray.count-1 {
                        
                        var multimediaArray : [String] = []
                        let tourguideInfo = tourGuideArray[i]
                        let tourGuideInfoArray = (tourguideInfo.tourGuideMultimediaRelation?.allObjects) as! [TourGuideMultimediaEntity]
                        if(tourGuideInfoArray.count > 0) {
                            for i in 0 ... tourGuideInfoArray.count-1 {
                                multimediaArray.append(tourGuideInfoArray[i].multimediaFile!)
                            }
                        }
                        
                        self.miaTourDataFullArray.insert(TourGuide(title: tourGuideArray[i].title, tourGuideDescription: tourGuideArray[i].tourGuideDescription, multimediaFile: multimediaArray, museumsEntity: tourGuideArray[i].museumsEntity, nid: tourGuideArray[i].nid), at: i)
                    }
                    DispatchQueue.main.async {
                        self.exhibitionCollectionView.reloadData()
                    }
                    if(miaTourDataFullArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getTourGuideDataFromServer() //coreDataMigratio  solution
                    }
                }
            }
            else {
                var tourGuideArray = [TourGuideEntityAr]()
                tourGuideArray = checkAddedToCoredata(entityName: "TourGuideEntityAr", idKey: "museumsEntity", idValue: museumId, managedContext: managedContext) as! [TourGuideEntityAr]
                if (tourGuideArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getTourGuideDataFromServer()
                        }
                    }
                    for i in 0 ... tourGuideArray.count-1 {
                        var multimediaArray : [String] = []
                        let tourguideInfo = tourGuideArray[i]
                        let tourGuideInfoArray = (tourguideInfo.tourGuideMultimediaRelation?.allObjects) as! [TourGuideMultimediaEntityAr]
                        if(tourGuideInfoArray.count > 0) {
                            for i in 0 ... tourGuideInfoArray.count-1 {
                                multimediaArray.append(tourGuideInfoArray[i].multimediaFile!)
                            }
                        }
                        self.miaTourDataFullArray.insert(TourGuide(title: tourGuideArray[i].title, tourGuideDescription: tourGuideArray[i].tourGuideDescription, multimediaFile: multimediaArray, museumsEntity: tourGuideArray[i].museumsEntity, nid: tourGuideArray[i].nid), at: i)
                        
                        
                    }
                    if(miaTourDataFullArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    }
                    DispatchQueue.main.async {
                        self.exhibitionCollectionView.reloadData()
                    }
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        // self.loadingView.showNoDataView()
                        self.getTourGuideDataFromServer() //coreDataMigratio  solution
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: Mia Tour Guide Delegate
    func exploreButtonAction() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        self.performSegue(withIdentifier: "commonListToFloormapSegue", sender: self)
        
    }

    //MARK: TourGuide Service call
    func getTourGuideMuseumsList() {
        var searchstring = String()
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            searchstring = "12181"
        } else {
            searchstring = "12186"
        }
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.HomeList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<HomeList>) -> Void in
            switch response.result {
            case .success(let data):
                DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), SearchString: \(searchstring)")
                if(self.museumsList.count == 0) {
                    if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                        searchstring = "12181"
                    } else {
                        searchstring = "12186"
                    }
                    self.museumsList = data.homeList
                    //Removed Exhibition from Tour List
                    if let arrayOffset = self.museumsList.index(where: {$0.id == searchstring}) {
                        self.museumsList.remove(at: arrayOffset)
                    }
                    self.exhibitionCollectionView.reloadData()
                }
                if(self.museumsList.count > 0) {
                    
                    //Removed Exhibition from Tour List
                    if let arrayOffset = self.museumsList.index(where: {$0.id == searchstring}) {
                        self.museumsList.remove(at: arrayOffset)
                    }
                    self.saveOrUpdateMuseumsCoredata(museumsList: data.homeList)
                }
            case .failure(let error):
                print("error")
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateMuseumsCoredata(museumsList:[Home]?) {
        if ((museumsList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.tourGuideCoreDataInBackgroundThread(managedContext: managedContext, museumsList: museumsList)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.tourGuideCoreDataInBackgroundThread(managedContext : managedContext, museumsList: museumsList)
                }
            }
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")

        }
    }
    func tourGuideCoreDataInBackgroundThread(managedContext: NSManagedObjectContext,museumsList:[Home]?) {
        var fetchData = [HomeEntity]()
        var langVar : String? = nil
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
        fetchData = checkAddedToCoredata(entityName: "HomeEntity", idKey: "lang", idValue: langVar, managedContext: managedContext) as! [HomeEntity]
        if (fetchData.count > 0) {
            for i in 0 ... (museumsList?.count)!-1 {
                let museumListDict = museumsList![i]
                let fetchResult = checkAddedToCoredata(entityName: "HomeEntity", idKey: "id", idValue: museumsList![i].id, managedContext: managedContext)
                //update
                if(fetchResult.count != 0) {
                    let museumsdbDict = fetchResult[0] as! HomeEntity
                    
                    museumsdbDict.name = museumListDict.name
                    museumsdbDict.image = museumListDict.image
                    museumsdbDict.sortid =  (Int16(museumListDict.sortId!) ?? 0)
                    museumsdbDict.tourguideavailable = museumListDict.isTourguideAvailable
                    museumsdbDict.lang = langVar
                    
                    do{
                        try managedContext.save()
                    }
                    catch{
                        print(error)
                    }
                }
                else {
                    //save
                    self.saveToTourGuideCoreData(museumsListDict: museumListDict, managedObjContext: managedContext)
                    
                }
            }
        }
        else {
            for i in 0 ... (museumsList?.count)!-1 {
                let museumsListDict : Home?
                museumsListDict = museumsList?[i]
                self.saveToTourGuideCoreData(museumsListDict: museumsListDict!, managedObjContext: managedContext)
                
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    func saveToTourGuideCoreData(museumsListDict: Home, managedObjContext: NSManagedObjectContext) {
        var langVar : String? = nil
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            langVar = "1"
            
        } else {
            langVar = "0"
        }
        let museumsInfo: HomeEntity = NSEntityDescription.insertNewObject(forEntityName: "HomeEntity", into: managedObjContext) as! HomeEntity
        museumsInfo.id = museumsListDict.id
        museumsInfo.name = museumsListDict.name
        museumsInfo.image = museumsListDict.image
        museumsInfo.tourguideavailable = museumsListDict.isTourguideAvailable
        museumsInfo.image = museumsListDict.image
        museumsInfo.sortid = (Int16(museumsListDict.sortId!) ?? 0)
        museumsInfo.lang = langVar
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            DDLogError("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchMuseumsInfoFromCoredata() {
        self.exbtnLoadingView.stopLoading()
        self.exbtnLoadingView.isHidden = true
        let managedContext = getContext()
        var searchstring = String()
        var langVar : String? = nil
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            searchstring = "12181"
            langVar = "1"
        } else {
            searchstring = "12186"
            langVar = "0"
        }
        do {
            var museumsArray = [HomeEntity]()
            museumsArray = checkAddedToCoredata(entityName: "HomeEntity", idKey: "lang", idValue: langVar, managedContext: managedContext) as! [HomeEntity]
            var j:Int? = 0
            if (museumsArray.count > 0) {
                for i in 0 ... museumsArray.count-1 {
                    if let duplicateId = museumsList.first(where: {$0.id == museumsArray[i].id}) {
                    } else {
                        self.museumsList.insert(Home(id:museumsArray[i].id , name: museumsArray[i].name,image: museumsArray[i].image,
                                                     tourguide_available: museumsArray[i].tourguideavailable, sort_id: String(museumsArray[i].sortid)),
                                                at: j!)
                        j = j!+1
                    }
                }
                if(museumsList.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.exbtnLoadingView.showNoDataView()
                    }
                } else {
                    //Removed Exhibition from Tour List
                    if let arrayOffset = self.museumsList.index(where: {$0.id == searchstring}) {
                        self.museumsList.remove(at: arrayOffset)
                    }
                }
                exhibitionCollectionView.reloadData()
            }
            else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.exbtnLoadingView.showNoDataView()
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func loadMiaTour(currentRow: Int?) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        let miaView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
        miaView.exhibitionsPageNameString = ExhbitionPageName.miaTourGuideList
        if (museumsList != nil) {
            miaView.museumId = museumsList[currentRow!].id!
            self.present(miaView, animated: false, completion: nil)
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @objc func receiveHomePageNotificationEn(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (museumsList.count == 0)){
            DispatchQueue.main.async{
                self.fetchMuseumsInfoFromCoredata()
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    @objc func receiveHomePageNotificationAr(notification: NSNotification) {
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (museumsList.count == 0)){
            DispatchQueue.main.async{
                self.fetchMuseumsInfoFromCoredata()
            }
        }
    }
    func getNmoqParkListFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNmoqParkList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<NmoqParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.nmoqParkList.count == 0) {
                    self.nmoqParkList = data.nmoqParkList
                    if(self.nmoqParkList.count > 0) {
                        self.exhibitionHeaderView.headerTitle.text = self.nmoqParkList[0].title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
                    }
                    self.exhibitionCollectionView.reloadData()
                    if(self.nmoqParkList.count == 0) {
                        self.exbtnLoadingView.stopLoading()
                        self.exbtnLoadingView.noDataView.isHidden = false
                        self.exbtnLoadingView.isHidden = false
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
                if(self.nmoqParkList.count > 0) {
                    self.saveOrUpdateNmoqParkListCoredata(nmoqParkList: data.nmoqParkList)
                }
            case .failure( _):
                if(self.nmoqParkList.count == 0) {
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                }
            }
        }
    }
    
    func getNmoqListOfParksFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNmoqListParks(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<NMoQParks>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.nmoqParks.count == 0) {
                    self.nmoqParks = data.nmoqParks
                    self.exhibitionCollectionView.reloadData()
                    if(self.nmoqParks.count == 0) {
                        self.exbtnLoadingView.stopLoading()
                        self.exbtnLoadingView.noDataView.isHidden = false
                        self.exbtnLoadingView.isHidden = false
                        self.exbtnLoadingView.showNoDataView()
                    }
                }
                if(self.nmoqParks.count > 0) {
                    self.saveOrUpdateNmoqParksCoredata(nmoqParkList: data.nmoqParks)
                }
                
            case .failure( _):
                if(self.nmoqParks.count == 0) {
                    self.exbtnLoadingView.stopLoading()
                    self.exbtnLoadingView.noDataView.isHidden = false
                    self.exbtnLoadingView.isHidden = false
                    self.exbtnLoadingView.showNoDataView()
                }
            }
        }
    }
    
    //MARK: NMoqPark List Coredata Method
    func saveOrUpdateNmoqParkListCoredata(nmoqParkList:[NMoQParksList]?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((nmoqParkList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.nmoqParkListCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.nmoqParkListCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext : managedContext)
                }
            }
        }
    }
    func nmoqParkListCoreDataInBackgroundThread(nmoqParkList:[NMoQParksList]?,managedContext: NSManagedObjectContext) {
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "NMoQParkListEntity", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParkListEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParkListEntity", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParkListEntity
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.parkTitle = nmoqParkListDict.parkTitle
                        nmoqParkListdbDict.mainDescription = nmoqParkListDict.mainDescription
                        nmoqParkListdbDict.parkDescription =  nmoqParkListDict.parkDescription
                        nmoqParkListdbDict.hoursTitle = nmoqParkListDict.hoursTitle
                        nmoqParkListdbDict.hoursDesc = nmoqParkListDict.hoursDesc
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.longitude = nmoqParkListDict.longitude
                        nmoqParkListdbDict.latitude = nmoqParkListDict.latitude
                        nmoqParkListdbDict.locationTitle =  nmoqParkListDict.locationTitle
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveNmoqParkListToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationEn), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQParksList?
                    nmoqParkListDict = nmoqParkList?[i]
                    self.saveNmoqParkListToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationEn), object: self)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "NMoQParkListEntityAr", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParkListEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParkListEntityAr", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParkListEntityAr
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.parkTitle = nmoqParkListDict.parkTitle
                        nmoqParkListdbDict.mainDescription = nmoqParkListDict.mainDescription
                        nmoqParkListdbDict.parkDescription =  nmoqParkListDict.parkDescription
                        nmoqParkListdbDict.hoursTitle = nmoqParkListDict.hoursTitle
                        nmoqParkListdbDict.hoursDesc = nmoqParkListDict.hoursDesc
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.longitude = nmoqParkListDict.longitude
                        nmoqParkListdbDict.latitude = nmoqParkListDict.latitude
                        nmoqParkListdbDict.locationTitle =  nmoqParkListDict.locationTitle
                        
                        do{
                            try managedContext.save()
                        }
                        catch{
                            print(error)
                        }
                    } else {
                        //save
                        self.saveNmoqParkListToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationAr), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQParksList?
                    nmoqParkListDict = nmoqParkList![i]
                    self.saveNmoqParkListToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(facilitiesListNotificationAr), object: self)
            }
        }
    }
    func saveNmoqParkListToCoreData(nmoqParkListDict: NMoQParksList, managedObjContext: NSManagedObjectContext) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let nmoqParkListdbDict: NMoQParkListEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkListEntity", into: managedObjContext) as! NMoQParkListEntity
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.parkTitle = nmoqParkListDict.parkTitle
            nmoqParkListdbDict.mainDescription = nmoqParkListDict.mainDescription
            nmoqParkListdbDict.parkDescription =  nmoqParkListDict.parkDescription
            nmoqParkListdbDict.hoursTitle = nmoqParkListDict.hoursTitle
            nmoqParkListdbDict.hoursDesc = nmoqParkListDict.hoursDesc
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.longitude = nmoqParkListDict.longitude
            nmoqParkListdbDict.latitude = nmoqParkListDict.latitude
            nmoqParkListdbDict.locationTitle =  nmoqParkListDict.locationTitle
            
        } else {
            let nmoqParkListdbDict: NMoQParkListEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkListEntityAr", into: managedObjContext) as! NMoQParkListEntityAr
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.parkTitle = nmoqParkListDict.parkTitle
            nmoqParkListdbDict.mainDescription = nmoqParkListDict.mainDescription
            nmoqParkListdbDict.parkDescription =  nmoqParkListDict.parkDescription
            nmoqParkListdbDict.hoursTitle = nmoqParkListDict.hoursTitle
            nmoqParkListdbDict.hoursDesc = nmoqParkListDict.hoursDesc
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.longitude = nmoqParkListDict.longitude
            nmoqParkListdbDict.latitude = nmoqParkListDict.latitude
            nmoqParkListdbDict.locationTitle =  nmoqParkListDict.locationTitle
        }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: NMoq List of Parks Coredata Method
    func saveOrUpdateNmoqParksCoredata(nmoqParkList:[NMoQPark]?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((nmoqParkList?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.nmoqParkCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.nmoqParkCoreDataInBackgroundThread(nmoqParkList: nmoqParkList, managedContext : managedContext)
                }
            }
        }
    }
    
    func nmoqParkCoreDataInBackgroundThread(nmoqParkList:[NMoQPark]?,managedContext: NSManagedObjectContext) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let fetchData = checkAddedToCoredata(entityName: "NMoQParksEntity", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParksEntity]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParksEntity", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParksEntity
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
                        
                        if(nmoqParkListDict.images != nil){
                            if((nmoqParkListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                                    var parkListImage: NMoQParkImgEntity!
                                    let parkListImageArray: NMoQParkImgEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkImgEntity", into: managedContext) as! NMoQParkImgEntity
                                    parkListImageArray.images = nmoqParkListDict.images![i]
                                    
                                    parkListImage = parkListImageArray
                                    nmoqParkListdbDict.addToParkImgRelation(parkListImage)
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
                        self.saveNmoqParkToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationEn), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQPark?
                    nmoqParkListDict = nmoqParkList?[i]
                    self.saveNmoqParkToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationEn), object: self)
            }
        } else {
            let fetchData = checkAddedToCoredata(entityName: "NMoQParksEntityAr", idKey: "nid", idValue: nil, managedContext: managedContext) as! [NMoQParksEntityAr]
            if (fetchData.count > 0) {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict = nmoqParkList![i]
                    let fetchResult = checkAddedToCoredata(entityName: "NMoQParksEntityAr", idKey: "nid", idValue: nmoqParkListDict.nid, managedContext: managedContext)
                    //update
                    if(fetchResult.count != 0) {
                        let nmoqParkListdbDict = fetchResult[0] as! NMoQParksEntityAr
                        nmoqParkListdbDict.title = nmoqParkListDict.title
                        nmoqParkListdbDict.nid =  nmoqParkListDict.nid
                        nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
                        if(nmoqParkListDict.images != nil){
                            if((nmoqParkListDict.images?.count)! > 0) {
                                for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                                    var parkListImage: NMoQParkImgEntityAr!
                                    let parkListImageArray: NMoQParkImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkImgEntityAr", into: managedContext) as! NMoQParkImgEntityAr
                                    parkListImageArray.images = nmoqParkListDict.images![i]
                                    
                                    parkListImage = parkListImageArray
                                    nmoqParkListdbDict.addToParkImgRelationAr(parkListImage)
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
                        self.saveNmoqParkToCoreData(nmoqParkListDict: nmoqParkListDict, managedObjContext: managedContext)
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationAr), object: self)
            } else {
                for i in 0 ... (nmoqParkList?.count)!-1 {
                    let nmoqParkListDict : NMoQPark?
                    nmoqParkListDict = nmoqParkList![i]
                    self.saveNmoqParkToCoreData(nmoqParkListDict: nmoqParkListDict!, managedObjContext: managedContext)
                }
                NotificationCenter.default.post(name: NSNotification.Name(nmoqParkNotificationAr), object: self)
            }
        }
    }
    
    func saveNmoqParkToCoreData(nmoqParkListDict: NMoQPark, managedObjContext: NSManagedObjectContext) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE) {
            let nmoqParkListdbDict: NMoQParksEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParksEntity", into: managedObjContext) as! NMoQParksEntity
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
            
            if(nmoqParkListDict.images != nil){
                if((nmoqParkListDict.images?.count)! > 0) {
                    for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                        var parkListImage: NMoQParkImgEntity!
                        let parkListImageArray: NMoQParkImgEntity = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkImgEntity", into: managedObjContext) as! NMoQParkImgEntity
                        parkListImageArray.images = nmoqParkListDict.images![i]
                        
                        parkListImage = parkListImageArray
                        nmoqParkListdbDict.addToParkImgRelation(parkListImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        } else {
            let nmoqParkListdbDict: NMoQParksEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParksEntityAr", into: managedObjContext) as! NMoQParksEntityAr
            nmoqParkListdbDict.title = nmoqParkListDict.title
            nmoqParkListdbDict.nid =  nmoqParkListDict.nid
            nmoqParkListdbDict.sortId =  nmoqParkListDict.sortId
            
            if(nmoqParkListDict.images != nil){
                if((nmoqParkListDict.images?.count)! > 0) {
                    for i in 0 ... (nmoqParkListDict.images?.count)!-1 {
                        var parkListImage: NMoQParkImgEntityAr!
                        let parkListImageArray: NMoQParkImgEntityAr = NSEntityDescription.insertNewObject(forEntityName: "NMoQParkImgEntityAr", into: managedObjContext) as! NMoQParkImgEntityAr
                        parkListImageArray.images = nmoqParkListDict.images![i]
                        
                        parkListImage = parkListImageArray
                        nmoqParkListdbDict.addToParkImgRelationAr(parkListImage)
                        do {
                            try managedObjContext.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                }
            }
        }
        do {
            try managedObjContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchNmoqParkListFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var parkListArray = [NMoQParkListEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQParkListEntity")
                parkListArray = (try managedContext.fetch(fetchRequest) as? [NMoQParkListEntity])!
                if (parkListArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNmoqParkListFromServer()
                        }
                    }
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        self.nmoqParkList.insert(NMoQParksList(title: parkListDict.title, parkTitle: parkListDict.parkTitle, mainDescription: parkListDict.mainDescription, parkDescription: parkListDict.parkDescription, hoursTitle: parkListDict.hoursTitle, hoursDesc: parkListDict.hoursDesc, nid: parkListDict.nid, longitude: parkListDict.longitude, latitude: parkListDict.latitude, locationTitle: parkListDict.locationTitle), at: i)
                    }
                    if(nmoqParkList.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    } else {
                        self.exhibitionHeaderView.headerTitle.text = self.nmoqParkList[0].title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
                    }
                    exhibitionCollectionView.reloadData()
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getNmoqParkListFromServer()//coreDataMigratio  solution
                    }
                }
            } else {
                var parkListArray = [NMoQParkListEntityAr]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQParkListEntityAr")
                parkListArray = (try managedContext.fetch(fetchRequest) as? [NMoQParkListEntityAr])!
                if (parkListArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNmoqParkListFromServer()
                        }
                    }
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        self.nmoqParkList.insert(NMoQParksList(title: parkListDict.title,parkTitle: parkListDict.parkTitle, mainDescription: parkListDict.mainDescription, parkDescription: parkListDict.parkDescription, hoursTitle: parkListDict.hoursTitle, hoursDesc: parkListDict.hoursDesc, nid: parkListDict.nid, longitude: parkListDict.longitude, latitude: parkListDict.latitude, locationTitle: parkListDict.locationTitle), at: i)
                    }
                    if(nmoqParkList.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    } else {
                        self.exhibitionHeaderView.headerTitle.text = self.nmoqParkList[0].title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
                    }
                    exhibitionCollectionView.reloadData()
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getNmoqParkListFromServer()//coreDataMigratio  solution
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func fetchNmoqParkFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                var parkListArray = [NMoQParksEntity]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQParksEntity")
                parkListArray = (try managedContext.fetch(fetchRequest) as? [NMoQParksEntity])!
                
                if (parkListArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNmoqListOfParksFromServer()
                        }
                    }
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (parkListDict.parkImgRelation?.allObjects) as! [NMoQParkImgEntity]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.nmoqParks.insert(NMoQPark(title: parkListDict.title, sortId: parkListDict.sortId, nid: parkListDict.nid, images: imagesArray), at: i)
                    }
                    if(nmoqParks.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    } else {
                        if self.nmoqParks.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParks = self.nmoqParks.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                    }
                    DispatchQueue.main.async{
                        self.exhibitionCollectionView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        //self.loadingView.showNoDataView()
                        self.getNmoqListOfParksFromServer()//coreDataMigratio  solution
                    }
                }
            } else {
                var parkListArray = [NMoQParksEntityAr]()
                let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQParksEntityAr")
                parkListArray = (try managedContext.fetch(fetchRequest) as? [NMoQParksEntityAr])!
                if (parkListArray.count > 0) {
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNmoqListOfParksFromServer()
                        }
                    }
                    for i in 0 ... parkListArray.count-1 {
                        let parkListDict = parkListArray[i]
                        var imagesArray : [String] = []
                        let imagesInfoArray = (parkListDict.parkImgRelationAr?.allObjects) as! [NMoQParkImgEntityAr]
                        if(imagesInfoArray.count > 0) {
                            for i in 0 ... imagesInfoArray.count-1 {
                                imagesArray.append(imagesInfoArray[i].images!)
                            }
                        }
                        self.nmoqParks.insert(NMoQPark(title: parkListDict.title, sortId: parkListDict.sortId, nid: parkListDict.nid, images: imagesArray), at: i)
                    }
                    if(nmoqParks.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.exbtnLoadingView.showNoDataView()
                        }
                    } else {
                        if self.nmoqParks.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                            self.nmoqParks = self.nmoqParks.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                        }
                    }
                    DispatchQueue.main.async{
                        self.exhibitionCollectionView.reloadData()
                    }
                } else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        // self.loadingView.showNoDataView()
                        self.getNmoqListOfParksFromServer()//coreDataMigratio  solution
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func loadLocationMap( mobileLatitude: String?, mobileLongitude: String? ) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
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
    
    @objc func receiveNmoqParkListNotificationEn(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (nmoqParkList.count == 0)){
            self.fetchNmoqParkListFromCoredata()
        }
    }
    @objc func receiveNmoqParkListNotificationAr(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (nmoqParkList.count == 0)){
            self.fetchNmoqParkListFromCoredata()
        }
    }
    
    @objc func receiveNmoqParkNotificationEn(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE ) && (nmoqParks.count == 0)){
            self.fetchNmoqParkFromCoredata()
        }
    }
    
    @objc func receiveNmoqParkNotificationAr(notification: NSNotification) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage() == AR_LANGUAGE ) && (nmoqParks.count == 0)){
            self.fetchNmoqParkFromCoredata()
        }
    }
    
    func showLocationErrorPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        popupView  = ComingSoonPopUp(frame: self.view.frame)
        popupView.comingSoonPopupDelegate = self
        popupView.loadMapKitLocationErrorPopup()
        self.view.addSubview(popupView)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "commonListToDetailSegue") {
            let commonDetail = segue.destination as! CommonDetailViewController
            if ((exhibitionsPageNameString == ExhbitionPageName.homeExhibition) || (exhibitionsPageNameString == ExhbitionPageName.museumExhibition)) {
                commonDetail.pageNameString = PageName.exhibitionDetail
                commonDetail.fromHome = true
                commonDetail.exhibitionId = exhibition[selectedRow!].id
            } else if (exhibitionsPageNameString == ExhbitionPageName.heritageList) {
                commonDetail.pageNameString = PageName.heritageDetail
                commonDetail.heritageDetailId = heritageListArray[selectedRow!].id
            }else if (exhibitionsPageNameString == ExhbitionPageName.publicArtsList) {
                commonDetail.pageNameString = PageName.publicArtsDetail
                commonDetail.publicArtsDetailId = publicArtsListArray[selectedRow!].id
            } else if (exhibitionsPageNameString == ExhbitionPageName.diningList) {
                commonDetail.diningDetailId = diningListArray[selectedRow!].id
                commonDetail.pageNameString = PageName.DiningDetail
            } else if (exhibitionsPageNameString == ExhbitionPageName.parkList) {
                commonDetail.pageNameString = PageName.NMoQPark
                commonDetail.parkDetailId = nmoqParks[selectedRow! - 1].nid
            }
        } else if (segue.identifier == "commonListToPanelDetailSegue") {
            let panelDetail = segue.destination as! PanelDiscussionDetailViewController
            if (exhibitionsPageNameString == ExhbitionPageName.museumCollectionsList) {
                panelDetail.pageNameString = NMoQPanelPage.CollectionDetail
                panelDetail.collectionName = collection[selectedRow!].name?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil)
            } else if (exhibitionsPageNameString == ExhbitionPageName.nmoqTourSecondList) {
                panelDetail.selectedRow = selectedRow
                panelDetail.nmoqTourDetail = nmoqTourDetail
                panelDetail.panelDetailId = tourDetailId
                if (isFromTour)! {
                    panelDetail.pageNameString = NMoQPanelPage.TourDetailPage
                } else {
                    panelDetail.pageNameString = NMoQPanelPage.PanelDetailPage
                }
            } else if (exhibitionsPageNameString == ExhbitionPageName.facilitiesSecondList) {
                panelDetail.selectedRow = selectedRow
                panelDetail.pageNameString = NMoQPanelPage.FacilitiesDetailPage
                panelDetail.panelDetailId = facilitiesDetail![selectedRow!].nid
                panelDetail.facilitiesDetail = facilitiesDetail
                panelDetail.fromCafeOrDining = true
            } else if (exhibitionsPageNameString == ExhbitionPageName.parkList) {
                panelDetail.pageNameString = NMoQPanelPage.PlayGroundPark
                panelDetail.nid = nmoqParks[selectedRow! - 1].nid
            }
        } else if (segue.identifier == "commonListToMiaTourSegue") {
            let miaTouguideView = segue.destination as! MiaTourDetailViewController
            miaTouguideView.museumId = museumId ?? "0"
            if (miaTourDataFullArray != nil) {
                miaTouguideView.tourGuideDetail = miaTourDataFullArray[selectedRow! - 1]
            }
        } else if (segue.identifier == "commonListToFloormapSegue") {
            let floorMapView = segue.destination as! FloorMapViewController
            floorMapView.fromTourString = fromTour.exploreTour
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
