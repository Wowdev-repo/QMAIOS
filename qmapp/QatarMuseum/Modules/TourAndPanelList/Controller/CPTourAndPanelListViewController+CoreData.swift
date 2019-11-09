//
//  TourAndPanelListViewController+CoreData.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Crashlytics
import Firebase
import UIKit

extension CPTourAndPanelListViewController {
    
    //MARK: Tour List Coredata Method
    func saveOrUpdateTourListCoredata(nmoqTourList: [CPNMoQTour], isTourGuide:Bool) {
        if !nmoqTourList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateTourList(nmoqTourList: nmoqTourList,
                                               managedContext: managedContext,
                                               isTourGuide: isTourGuide,
                                               language: CPUtils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateTourList(nmoqTourList: nmoqTourList,
                                               managedContext : managedContext,
                                               isTourGuide: isTourGuide,
                                               language: CPUtils.getLanguage())
                }
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func fetchTourInfoFromCoredata(isTourGuide:Bool) {
        let managedContext = getContext()
        do {
            
            var tourListArray = CPDataManager.checkAddedToCoredata(entityName: "NMoQTourListEntity",
                                                                 idKey: "isTourGuide",
                                                                 idValue: "\(isTourGuide)",
                managedContext: managedContext) as! [NMoQTourListEntity]
            if (tourListArray.count > 0) {
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getNMoQTourList()
                    }
                }
                tourListArray.sort(by: {$0.sortId < $1.sortId})
                for tourListDict in tourListArray {
                    self.nmoqTourList.append(CPNMoQTour(entity: tourListDict))
                }
                
                if(nmoqTourList.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
                DispatchQueue.main.async{
                    self.collectionTableView.reloadData()
                }
            } else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    //self.loadingView.showNoDataView()
                    self.getNMoQTourList() //coreDataMigratio  solution
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: ActivityList Coredata Method
    func saveOrUpdateActivityListCoredata(nmoqActivityList: [CPNMoQActivitiesList]) {
        if !nmoqActivityList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateActivityList(nmoqActivityList: nmoqActivityList,
                                                   managedContext: managedContext,
                                                   language: CPUtils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateActivityList(nmoqActivityList: nmoqActivityList,
                                                   managedContext : managedContext,
                                                   language: CPUtils.getLanguage())
                }
            }
        }
    }
    
    func fetchActivityListFromCoredata() {
        let managedContext = getContext()
        do {
            var activityListArray = [NMoQActivitiesEntity]()
            let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQActivitiesEntity")
            activityListArray = (try managedContext.fetch(fetchRequest) as? [NMoQActivitiesEntity])!
            if (activityListArray.count > 0) {
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getNMoQSpecialEventList()
                    }
                }
                for activityListDict in activityListArray {
                    self.nmoqActivityList.append(CPNMoQActivitiesList(entity: activityListDict))
                }
                
                if(nmoqActivityList.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                } else {
                    if self.nmoqActivityList.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                        self.nmoqActivityList = self.nmoqActivityList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                }
                DispatchQueue.main.async{
                    self.collectionTableView.reloadData()
                }
            } else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    //self.loadingView.showNoDataView()
                    self.getNMoQSpecialEventList()//coreDataMigratio  solution
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    //MARK: Facilities List Coredata Method
    func saveOrUpdateFacilitiesListCoredata(facilitiesList: [CPFacilities],
                                            language: String) {
        if !facilitiesList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateFacilitiesEntity(facilitiesList: facilitiesList,
                                                       managedContext: managedContext,
                                                       language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateFacilitiesEntity(facilitiesList: facilitiesList,
                                                       managedContext : managedContext,
                                                       language: CPUtils.getLanguageCode(language))
                }
            }
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        }
    }
    
    
    
    func fetchFacilitiesListFromCoredata() {
        let managedContext = getContext()
        do {
            
            let facilitiesListArray = CPDataManager.checkAddedToCoredata(entityName: "FacilitiesEntity",
                                                                       idKey: "language",
                                                                       idValue: CPUtils.getLanguage(),
                                                                       managedContext: managedContext) as! [FacilitiesEntity]
            if (facilitiesListArray.count > 0) {
                if (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getFacilitiesListFromServer()
                    }
                }
                for facilitiesListDict in facilitiesListArray {
                    var imagesArray : [String] = []
                    let imagesInfoArray = (facilitiesListDict.facilitiesImgRelation?.allObjects) as! [ImageEntity]
                    for images in imagesInfoArray {
                        if let image = images.image {
                            imagesArray.append(image)
                        }
                    }
                    
                    self.facilitiesList.append(CPFacilities(title: facilitiesListDict.title,
                                                          sortId: facilitiesListDict.sortId,
                                                          nid: facilitiesListDict.nid,
                                                          images: imagesArray))
                }
                
                if(facilitiesList.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                } else {
                    if self.facilitiesList.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                        self.facilitiesList = self.facilitiesList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                }
                DispatchQueue.main.async{
                    self.collectionTableView.reloadData()
                }
            } else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    //self.loadingView.showNoDataView()
                    self.getFacilitiesListFromServer()//coreDataMigratio  solution
                }
            }
            
        } catch let error as NSError {
            DDLogError("Could not fetch. \(error), \(error.userInfo)")
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        if(pageNameString == CPNMoQPageName.Tours) {
            Analytics.setScreenName(NMOQ_TOUR_LIST, screenClass: screenClass)
        } else if(pageNameString == CPNMoQPageName.PanelDiscussion){
            Analytics.setScreenName(NMOQ_ACTIVITY_LIST, screenClass: screenClass)
        } else if(pageNameString == CPNMoQPageName.TravelArrangementList){
            Analytics.setScreenName(TRAVEL_ARRANGEMENT_VC, screenClass: screenClass)
        }
        
    }
    
    //MARK: Travel List Coredata
    func saveOrUpdateTravelListCoredata(travelList: [CPHomeBanner]) {
        if !travelList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateTravelList(travelList: travelList,
                                                 managedContext: managedContext,
                                                 language: CPUtils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateTravelList(travelList: travelList,
                                                 managedContext : managedContext,
                                                 language: CPUtils.getLanguage())
                }
            }
        }
    }
    
    
    
    func fetchTravelInfoFromCoredata() {
        let managedContext = getContext()
        do {
            //            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            var travelListArray = [NMoQTravelListEntity]()
            let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQTravelListEntity")
            travelListArray = (try managedContext.fetch(fetchRequest) as? [NMoQTravelListEntity])!
            if (travelListArray.count > 0) {
                if (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getTravelList()
                    }
                }
                for entity in travelListArray {
                    self.travelList.append(CPHomeBanner(travelEntity: entity))
                }
                if(travelList.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                } else {
                    if(bannerId != nil) {
                        if let arrayOffset = self.travelList.index(where: {$0.fullContentID == bannerId}) {
                            self.travelList.remove(at: arrayOffset)
                        }
                    }
                }
                DispatchQueue.main.async{
                    self.collectionTableView.reloadData()
                }
            } else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    //self.loadingView.showNoDataView()
                    self.getTravelList()//coreDataMigratio  solution
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

//MARK: Service calls
extension CPTourAndPanelListViewController {
    //MARK: TravelList Service Call
    func getTravelList() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetNMoQTravelList(CPLocalizationLanguage.currentAppleLanguage())).responseObject { [weak self] (response: DataResponse<HomeBannerList>) -> Void in
            switch response.result {
            case .success(let data):
                if(self?.travelList.count == 0) {
                    self?.travelList = data.homeBannerList
                    self?.collectionTableView.reloadData()
                    if(self?.travelList.count == 0) {
                        self?.loadingView.stopLoading()
                        self?.loadingView.noDataView.isHidden = false
                        self?.loadingView.isHidden = false
                        self?.loadingView.showNoDataView()
                    }
                }
                if let count = self?.nmoqActivityList.count, count > 0 {
                    if let homeBannerList = data.homeBannerList {
                        self?.saveOrUpdateTravelListCoredata(travelList: homeBannerList)
                    }
                }
            case .failure( _):
                if(self?.travelList.count == 0) {
                    self?.loadingView.stopLoading()
                    self?.loadingView.noDataView.isHidden = false
                    self?.loadingView.isHidden = false
                    self?.loadingView.showNoDataView()
                }
            }
        }
    }
    
    //MARK: Facilities API
    func getFacilitiesListFromServer()
    {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.FacilitiesList(CPLocalizationLanguage.currentAppleLanguage())).responseObject { [weak self] (response: DataResponse<FacilitiesData>) -> Void in
            switch response.result {
            case .success(let data):
                if(self?.facilitiesList.count == 0) {
                    self?.facilitiesList = data.facilitiesList
                    if self?.facilitiesList.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                        self?.facilitiesList = self?.facilitiesList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                    self?.collectionTableView.reloadData()
                    if(self?.facilitiesList.count == 0) {
                        self?.loadingView.stopLoading()
                        self?.loadingView.noDataView.isHidden = false
                        self?.loadingView.isHidden = false
                        self?.loadingView.showNoDataView()
                    }
                }
                if let count = self?.facilitiesList.count, count > 0 {
                    if let facilitiesList = data.facilitiesList {
                        self?.saveOrUpdateFacilitiesListCoredata(facilitiesList: facilitiesList,
                                                                language: CPLocalizationLanguage.currentAppleLanguage())
                    }
                }
            case .failure( _):
                if(self?.facilitiesList.count == 0) {
                    self?.loadingView.stopLoading()
                    self?.loadingView.noDataView.isHidden = false
                    self?.loadingView.isHidden = false
                    self?.loadingView.showNoDataView()
                }
            }
            
            DDLogInfo("Function: \(#function)")
        }
    }
    //Activities API
    func getNMoQSpecialEventList() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetNMoQSpecialEventList(CPLocalizationLanguage.currentAppleLanguage()))
            .responseObject { [weak self] (response: DataResponse<NMoQActivitiesListData>) -> Void in
            switch response.result {
            case .success(let data):
                if(self?.nmoqActivityList.count == 0) {
                    self?.nmoqActivityList = data.nmoqActivitiesList
                    if self?.nmoqActivityList.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                        self?.nmoqActivityList = self?.nmoqActivityList.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                    self?.collectionTableView.reloadData()
                    if(self?.nmoqActivityList.count == 0) {
                        self?.loadingView.stopLoading()
                        self?.loadingView.noDataView.isHidden = false
                        self?.loadingView.isHidden = false
                        self?.loadingView.showNoDataView()
                    }
                }
                if let count = self?.nmoqActivityList.count, count > 0 {
                    if let list = data.nmoqActivitiesList {
                        self?.saveOrUpdateActivityListCoredata(nmoqActivityList: list)
                    }
                }
            case .failure( _):
                if(self?.nmoqActivityList.count == 0) {
                    self?.loadingView.stopLoading()
                    self?.loadingView.noDataView.isHidden = false
                    self?.loadingView.isHidden = false
                    self?.loadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: Service call
    func getNMoQTourList() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetNMoQTourList(CPLocalizationLanguage.currentAppleLanguage()))
            .responseObject { [weak self] (response: DataResponse<NMoQTourList>) -> Void in
            switch response.result {
            case .success(let data):
                if(self?.nmoqTourList.count == 0) {
                    self?.nmoqTourList = data.nmoqTourList
                    self?.collectionTableView.reloadData()
                    if(self?.nmoqTourList.count == 0) {
                        self?.loadingView.stopLoading()
                        self?.loadingView.noDataView.isHidden = false
                        self?.loadingView.isHidden = false
                        self?.loadingView.showNoDataView()
                    }
                }
                if let count = self?.nmoqTourList.count, count > 0 {
                    if let nmoqTourList = data.nmoqTourList {
                        self?.saveOrUpdateTourListCoredata(nmoqTourList: nmoqTourList,
                                                          isTourGuide: true)
                    }
                }
                
            case .failure( _):
                
                if(self?.nmoqTourList.count == 0) {
                    self?.loadingView.stopLoading()
                    self?.loadingView.noDataView.isHidden = false
                    self?.loadingView.isHidden = false
                    self?.loadingView.showNoDataView()
                }
            }
        }
    }
    
}
