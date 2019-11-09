//
//  CPCommonList.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
import Crashlytics
import Firebase

extension CPCommonListViewController {
    //MARK: CollectionList Coredata Method
    func saveOrUpdateCollectionCoredata(collection: [CPCollection], language: String) {
        if !collection.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateCollectionsEntity(managedContext: managedContext,
                                                        collection: collection, language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateCollectionsEntity(managedContext : managedContext,
                                                        collection: collection, language: CPUtils.getLanguageCode(language))
                }
            }
        }
    }
    
    
    func fetchCollectionListFromCoredata() {
        let managedContext = getContext()
        do {
            var collectionArray = [CollectionsEntity]()
            collectionArray = CPDataManager.checkAddedToCoredata(entityName: "CollectionsEntity",
                                                               idKey: "museumId",
                                                               idValue: museumId,
                                                               managedContext: managedContext) as! [CollectionsEntity]
            if (collectionArray.count > 0) {
                if museumId == "63" || museumId == "96" {
                    if (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getCollectionList()
                        }
                    }
                }
                
                for entity in collectionArray {
                    self.collection.append(CPCollection(entity: entity))
                }
                
                if collection.isEmpty {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                commonListTableView.reloadData()
            }
            else {
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.getCollectionList()//coreDataMigratio  solution
                }
            }
            
        }
    }
    
    //MARK: DiningList WebServiceCall
    func getDiningListFromServer()
    {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.DiningList(CPLocalizationLanguage.currentAppleLanguage())).responseObject { [weak self] (response: DataResponse<Dinings>) -> Void in
            switch response.result {
            case .success(let data):
                if(self?.diningListArray.count == 0) {
                    self?.diningListArray = data.dinings
                    self?.commonListTableView.reloadData()
                    if(self?.diningListArray.count == 0) {
                        self?.commonListLoadingView.stopLoading()
                        self?.commonListLoadingView.noDataView.isHidden = false
                        self?.commonListLoadingView.isHidden = false
                        self?.commonListLoadingView.showNoDataView()
                    }
                }
                if let count = self?.diningListArray.count,  count > 0 {
                    self?.saveOrUpdateDiningCoredata(diningListArray: data.dinings,
                                                    lang: CPLocalizationLanguage.currentAppleLanguage())
                }
            case .failure( _):
                if(self?.diningListArray.count == 0) {
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.noDataView.isHidden = false
                    self?.commonListLoadingView.isHidden = false
                    self?.commonListLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: Museum DiningWebServiceCall
    func getMuseumDiningListFromServer()
    {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.MuseumDiningList(["museum_id": museumId ?? 0])).responseObject { [weak self] (response: DataResponse<Dinings>) -> Void in
            switch response.result {
            case .success(let data):
                self?.saveOrUpdateDiningCoredata(diningListArray: data.dinings, lang: CPLocalizationLanguage.currentAppleLanguage())
            case .failure( _):
                print("error")
            }
        }
    }
    //MARK: Dining Coredata Method
    func saveOrUpdateDiningCoredata(diningListArray : [CPDining]?, lang: String) {
        if ((diningListArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate?.persistentContainer
                container?.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateDinings(managedContext: managedContext,
                                              diningListArray: diningListArray!,
                                              language: lang)
                }
            } else {
                let managedContext = appDelegate?.managedObjectContext
                managedContext?.perform {
                    CPDataManager.updateDinings(managedContext : managedContext!,
                                              diningListArray: diningListArray!, language: lang)
                }
            }
        }
    }
    
    func fetchMuseumDiningListFromCoredata() {
        let managedContext = getContext()
        do {
            var diningArray = [DiningEntity]()
            diningArray = CPDataManager.checkAddedToCoredata(entityName: "DiningEntity",
                                                           idKey: "museumId",
                                                           idValue: museumId,
                                                           managedContext: managedContext) as! [DiningEntity]
            
            if !diningArray.isEmpty {
                for dining in diningArray {
                    self.diningListArray.append(CPDining(entity: dining))
                }
                
                if diningListArray.isEmpty {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                DispatchQueue.main.async{
                    self.commonListTableView.reloadData()
                }
            } else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.commonListLoadingView.showNoDataView()
                }
            }
        }
    }
    
    func fetchDiningListFromCoredata() {
        let managedContext = getContext()
        do {
            var diningArray = [DiningEntity]()
            
            diningArray = CPDataManager.checkAddedToCoredata(entityName: "DiningEntity",
                                                           idKey: "lang", idValue: CPUtils.getLanguage(),
                                                           managedContext: managedContext) as! [DiningEntity]
            if (diningArray.count > 0) {
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getDiningListFromServer()
                    }
                }
                for dining in diningArray {
                    self.diningListArray.append(CPDining(entity: dining))
                }
                
                if(diningListArray.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                DispatchQueue.main.async{
                    self.commonListTableView.reloadData()
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
            _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetNMoQTourDetail(["event_id" : tourDetailId!])).responseObject { [weak self] (response: DataResponse<NMoQTourDetailList>) -> Void in
                switch response.result {
                case .success(let data):
                    self?.nmoqTourDetail = data.nmoqTourDetailList ?? []
                    if self?.nmoqTourDetail.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                        self?.nmoqTourDetail = self?.nmoqTourDetail.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! }) ?? []
                    }
                    self?.commonListTableView.reloadData()
                    if(self?.nmoqTourDetail.count == 0) {
                        let noResultMsg = NSLocalizedString("NO_RESULT_MESSAGE",
                                                            comment: "Setting the content of the alert")
                        self?.commonListLoadingView.stopLoading()
                        self?.commonListLoadingView.noDataView.isHidden = false
                        self?.commonListLoadingView.isHidden = false
                        self?.commonListLoadingView.showNoDataView()
                        self?.commonListLoadingView.noDataLabel.text = noResultMsg
                    } else {
                        self?.saveOrUpdateTourDetailCoredata()
                    }
                case .failure( _):
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.noDataView.isHidden = false
                    self?.commonListLoadingView.isHidden = false
                    self?.commonListLoadingView.showNoDataView()
                    self?.commonListLoadingView.noDataLabel.text = errorMessage
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
                    CPDataManager.updateNmoqTourDetails(managedContext : managedContext,
                                                      eventID: self.tourDetailId,
                                                      events: self.nmoqTourDetail)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateNmoqTourDetails(managedContext : managedContext,
                                                      eventID: self.tourDetailId,
                                                      events: self.nmoqTourDetail)
                }
            }
        }
    }
    
    func fetchTourDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            var tourDetailArray = [NmoqTourDetailEntity]()
            tourDetailArray = CPDataManager.checkAddedToCoredata(entityName: "NmoqTourDetailEntity",
                                                               idKey: "nmoqEvent",
                                                               idValue: tourDetailId,
                                                               managedContext: managedContext) as! [NmoqTourDetailEntity]
            if (tourDetailArray.count > 0) {
                
                for entity in tourDetailArray {
                    self.nmoqTourDetail.append(CPNMoQTourDetail(entity: entity))
                }
                
                if(nmoqTourDetail.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                DispatchQueue.main.async{
                    self.commonListTableView.reloadData()
                }
            }
            else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.commonListLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: Facilities SecondaryList ServiceCall
    func getFacilitiesDetail() {
        if(tourDetailId != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetFacilitiesDetail(["category_id" : tourDetailId!])).responseObject { [weak self] (response: DataResponse<FacilitiesDetailData>) -> Void in
                switch response.result {
                case .success(let data):
                    self?.facilitiesDetail = data.facilitiesDetail
                    self?.commonListTableView.reloadData()
                    if(self?.nmoqTourDetail.count == 0) {
                        let noResultMsg = NSLocalizedString("NO_RESULT_MESSAGE",
                                                            comment: "Setting the content of the alert")
                        self?.commonListLoadingView.stopLoading()
                        self?.commonListLoadingView.noDataView.isHidden = false
                        self?.commonListLoadingView.isHidden = false
                        self?.commonListLoadingView.showNoDataView()
                        self?.commonListLoadingView.noDataLabel.text = noResultMsg
                    } else {
                        self?.saveOrUpdateFacilitiesDetailCoredata()
                    }
                case .failure( _):
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.noDataView.isHidden = false
                    self?.commonListLoadingView.isHidden = false
                    self?.commonListLoadingView.showNoDataView()
                    self?.commonListLoadingView.noDataLabel.text = errorMessage
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
                    CPDataManager.updateFacilitiesDetails(managedContext : managedContext,
                                                        category: self.tourDetailId,
                                                        facilities: self.facilitiesDetail)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateFacilitiesDetails(managedContext : managedContext,
                                                        category: self.tourDetailId,
                                                        facilities: self.facilitiesDetail)
                }
            }
        }
    }
    
    func fetchFacilitiesDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            var facilitiesDetailArray = [FacilitiesDetailEntity]()
            facilitiesDetailArray = CPDataManager.checkAddedToCoredata(entityName: "FacilitiesDetailEntity",
                                                                     idKey: "category",
                                                                     idValue: tourDetailId,
                                                                     managedContext: managedContext) as! [FacilitiesDetailEntity]
            if (facilitiesDetailArray.count > 0) {
                for i in 0 ... facilitiesDetailArray.count-1 {
                    var imagesArray : [String] = []
                    let imagesInfoArray = (facilitiesDetailArray[i].facilitiesDetailRelation!.allObjects) as! [ImageEntity]
                    for info in imagesInfoArray {
                        if let image = info.image {
                            imagesArray.append(image)
                        }
                    }
                    self.facilitiesDetail.insert(CPFacilitiesDetail(entity: facilitiesDetailArray[i]), at: i)
                    
                }
                if(facilitiesDetail.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                DispatchQueue.main.async{
                    self.commonListTableView.reloadData()
                }
            }
            else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.commonListLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: WebServiceCall
    func getTourGuideDataFromServer() {
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.MuseumTourGuide(CPLocalizationLanguage.currentAppleLanguage(), ["museum_id": museumId ?? 0]))
            .responseObject { [weak self] (response: DataResponse<TourGuides>) -> Void in
                switch response.result {
                case .success(let data):
                    if(self?.miaTourDataFullArray.count == 0) {
                        self?.miaTourDataFullArray = data.tourGuide!
                        self?.commonListTableView.reloadData()
                        //if no result after api call
                        if(self?.miaTourDataFullArray.count == 0) {
                            self?.commonListLoadingView.stopLoading()
                            self?.commonListLoadingView.noDataView.isHidden = false
                            self?.commonListLoadingView.isHidden = false
                            self?.commonListLoadingView.showNoDataView()
                        }
                    }
                    if let count = self?.miaTourDataFullArray.count, count > 0 {
                        self?.saveOrUpdateTourGuideCoredata(data: data.tourGuide)
                    }
                case .failure(let error):
                    if(self?.miaTourDataFullArray.count == 0) {
                        self?.commonListLoadingView.stopLoading()
                        self?.commonListLoadingView.noDataView.isHidden = false
                        self?.commonListLoadingView.isHidden = false
                        self?.commonListLoadingView.showNoDataView()
                    }
                }
        }
    }
    
    //MARK: Coredata Method
    func saveOrUpdateTourGuideCoredata(data: [CPTourGuide]?) {
        if let tourData = data, !tourData.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateTourGuide(managedContext: managedContext,
                                                miaTourDataFullArray: tourData,
                                                museumID: self.museumId,
                                                language: CPUtils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateTourGuide(managedContext : managedContext,
                                                miaTourDataFullArray: tourData,
                                                museumID: self.museumId,
                                                language: CPUtils.getLanguage())
                }
            }
        }
    }
    
    func fetchTourGuideListFromCoredata(museumID: String) {
        let managedContext = getContext()
        do {
            var tourGuideArray = [TourGuideEntity]()
            tourGuideArray = CPDataManager.checkAddedToCoredata(entityName: "TourGuideEntity",
                                                              idKey: "museumsEntity",
                                                              idValue: museumID,
                                                              managedContext: managedContext) as! [TourGuideEntity]
            
            if (tourGuideArray.count > 0) {
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getTourGuideDataFromServer()
                    }
                }
                for tourguideInfo in tourGuideArray {
                    self.miaTourDataFullArray.append(CPTourGuide(entity: tourguideInfo))
                }
                DispatchQueue.main.async {
                    self.commonListTableView.reloadData()
                }
                if(miaTourDataFullArray.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
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
        if ((CPLocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            searchstring = "12181"
        } else {
            searchstring = "12186"
        }
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.HomeList(CPLocalizationLanguage.currentAppleLanguage())).responseObject { [weak self] (response: DataResponse<HomeList>) -> Void in
            switch response.result {
            case .success(let data):
//                DDLogInfo(NSStringFromClass(type(of: self ?? "")) + "Function: \(#function), SearchString: \(searchstring)")
                if(self?.museumsList.count == 0) {
                    if ((CPLocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                        searchstring = "12181"
                    } else {
                        searchstring = "12186"
                    }
                    self?.museumsList = data.homeList
                    //Removed Exhibition from Tour List
                    if let arrayOffset = self?.museumsList.index(where: {$0.id == searchstring}) {
                        self?.museumsList.remove(at: arrayOffset)
                    }
                    self?.commonListTableView.reloadData()
                }
                if let count = self?.museumsList.count, count > 0 {
                    
                    //Removed Exhibition from Tour List
                    if let arrayOffset = self?.museumsList.index(where: {$0.id == searchstring}) {
                        self?.museumsList.remove(at: arrayOffset)
                    }
                    if let homeList = data.homeList {
                        self?.saveOrUpdateMuseumsCoredata(museumsList: homeList,
                                                         language: CPLocalizationLanguage.currentAppleLanguage())
                    }
                }
            case .failure(let error):
                print("error")
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateMuseumsCoredata(museumsList: [CPHome], language: String) {
        if !museumsList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateHomeEntity(managedContext: managedContext,
                                                 homeList: museumsList,
                                                 language: CPUtils.getLanguageCode(language))
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateHomeEntity(managedContext: managedContext,
                                                 homeList: museumsList,
                                                 language: CPUtils.getLanguageCode(language))
                }
            }
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
            
        }
    }
    
    func fetchMuseumsInfoFromCoredata() {
        self.commonListLoadingView.stopLoading()
        self.commonListLoadingView.isHidden = true
        let managedContext = getContext()
        var searchstring = String()
        if ((CPLocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            searchstring = "12181"
        } else {
            searchstring = "12186"
        }
        do {
            var museumsArray = [HomeEntity]()
            museumsArray = CPDataManager.checkAddedToCoredata(entityName: "HomeEntity",
                                                            idKey: "lang",
                                                            idValue: CPUtils.getLanguage(),
                                                            managedContext: managedContext) as! [HomeEntity]
            if (museumsArray.count > 0) {
                for entity in museumsArray {
                    if let duplicateId = museumsList.first(where: {$0.id == entity.id}) {
                    } else {
                        self.museumsList.append(CPHome(entity: entity))
                    }
                }
                
                if(museumsList.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                } else {
                    //Removed Exhibition from Tour List
                    if let arrayOffset = self.museumsList.index(where: {$0.id == searchstring}) {
                        self.museumsList.remove(at: arrayOffset)
                    }
                }
                commonListTableView.reloadData()
            }
            else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.commonListLoadingView.showNoDataView()
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
        let miaView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CPCommonListViewController
        miaView.exhibitionsPageNameString = CPExhbitionPageName.miaTourGuideList
        if (museumsList != nil) {
            miaView.museumId = museumsList[currentRow!].id!
            self.present(miaView, animated: false, completion: nil)
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func getNmoqParkListFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetNmoqParkList(CPLocalizationLanguage.currentAppleLanguage())).responseObject { [weak self] (response: DataResponse<NmoqParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                if(self?.nmoqParkList.count == 0) {
                    self?.nmoqParkList = data.nmoqParkList
                    if let count = self?.nmoqParkList.count, count > 0 {
                        self?.commonListHeaderView.headerTitle.text = self?.nmoqParkList[0].title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
                    }
                    self?.commonListTableView.reloadData()
                    if(self?.nmoqParkList.count == 0) {
                        self?.commonListLoadingView.stopLoading()
                        self?.commonListLoadingView.noDataView.isHidden = false
                        self?.commonListLoadingView.isHidden = false
                        self?.commonListLoadingView.showNoDataView()
                    }
                }
                if let count = self?.nmoqParkList.count, count > 0 {
                    if let nmoqParkList = data.nmoqParkList {
                        self?.saveOrUpdateNmoqParkListCoredata(nmoqParkList: nmoqParkList)
                    }
                }
            case .failure( _):
                if(self?.nmoqParkList.count == 0) {
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.noDataView.isHidden = false
                    self?.commonListLoadingView.isHidden = false
                    self?.commonListLoadingView.showNoDataView()
                }
            }
        }
    }
    
    func getNmoqListOfParksFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetNmoqListParks(CPLocalizationLanguage.currentAppleLanguage()))
            .responseObject { [weak self] (response: DataResponse<NMoQParks>) -> Void in
            switch response.result {
            case .success(let data):
                if let count = self?.nmoqParks.count, count == 0 {
                    self?.nmoqParks = data.nmoqParks
                    self?.commonListTableView.reloadData()
                    if(self?.nmoqParks.count == 0) {
                        self?.commonListLoadingView.stopLoading()
                        self?.commonListLoadingView.noDataView.isHidden = false
                        self?.commonListLoadingView.isHidden = false
                        self?.commonListLoadingView.showNoDataView()
                    }
                }
                if let count = self?.nmoqParks.count, count > 0 {
                    if let nmoqParks = data.nmoqParks {
                        self?.saveOrUpdateNmoqParksCoredata(nmoqParkList: nmoqParks)
                    }
                }
                
            case .failure( _):
                if let count = self?.nmoqParks.count, count == 0 {
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.noDataView.isHidden = false
                    self?.commonListLoadingView.isHidden = false
                    self?.commonListLoadingView.showNoDataView()
                }
            }
        }
    }
    
    //MARK: NMoqPark List Coredata Method
    func saveOrUpdateNmoqParkListCoredata(nmoqParkList: [NMoQParksList]) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if !nmoqParkList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateNmoqParkList(nmoqParkList: nmoqParkList,
                                                   managedContext: managedContext,
                                                   language: CPUtils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateNmoqParkList(nmoqParkList: nmoqParkList,
                                                   managedContext : managedContext,
                                                   language: CPUtils.getLanguage())
                }
            }
        }
    }
    
    
    //MARK: NMoq List of Parks Coredata Method
    func saveOrUpdateNmoqParksCoredata(nmoqParkList: [NMoQPark]) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if !nmoqParkList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateNmoqPark(nmoqParkList: nmoqParkList,
                                               managedContext: managedContext,
                                               language: CPUtils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateNmoqPark(nmoqParkList: nmoqParkList,
                                               managedContext : managedContext,
                                               language: CPUtils.getLanguage())
                }
            }
        }
    }
    
    
    func fetchNmoqParkListFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            let parkListArray = CPDataManager.checkAddedToCoredata(entityName: "NMoQParkListEntity",
                                                                 idKey: "language",
                                                                 idValue: CPUtils.getLanguage(),
                                                                 managedContext: managedContext) as! [NMoQParkListEntity]
            if (parkListArray.count > 0) {
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getNmoqParkListFromServer()
                    }
                }
                
                for parkListDict in parkListArray {
                    self.nmoqParkList.append(NMoQParksList(entity: parkListDict))
                }
                
                if(nmoqParkList.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                } else {
                    self.commonListHeaderView.headerTitle.text = self.nmoqParkList[0].title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
                }
                commonListTableView.reloadData()
            } else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    //self.loadingView.showNoDataView()
                    self.getNmoqParkListFromServer()//coreDataMigratio  solution
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
            
            
            let parkListArray = CPDataManager.checkAddedToCoredata(entityName: "NMoQParksEntity",
                                                                 idKey: "language",
                                                                 idValue: CPUtils.getLanguage(),
                                                                 managedContext: managedContext) as! [NMoQParksEntity]
            
            if (parkListArray.count > 0) {
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getNmoqListOfParksFromServer()
                    }
                }
                
                for parkListDict in parkListArray {
                    self.nmoqParks.append(NMoQPark(entity: parkListDict))
                }
                
                if(nmoqParks.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                } else {
                    if self.nmoqParks.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                        self.nmoqParks = self.nmoqParks.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                }
                DispatchQueue.main.async{
                    self.commonListTableView.reloadData()
                }
            } else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    //self.loadingView.showNoDataView()
                    self.getNmoqListOfParksFromServer()//coreDataMigratio  solution
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: Service call
    func getExhibitionDataFromServer() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.ExhibitionList(CPLocalizationLanguage.currentAppleLanguage())).responseObject { [weak self] (response: DataResponse<Exhibitions>) -> Void in
            switch response.result {
            case .success(let data):
                if(self?.exhibition.count == 0) {
                    self?.exhibition = data.exhibitions
                    self?.commonListTableView.reloadData()
                    if(self?.exhibition.count == 0) {
                        self?.commonListLoadingView.stopLoading()
                        self?.commonListLoadingView.noDataView.isHidden = false
                        self?.commonListLoadingView.isHidden = false
                        self?.commonListLoadingView.showNoDataView()
                    }
                }
                if let count = self?.exhibition.count, count > 0 {
                    if let exhibitions = data.exhibitions {
                        self?.saveOrUpdateExhibitionsCoredata(exhibition: exhibitions,
                                                             isHomeExhibition: "1")
                    }
                }
            case .failure( _):
                if(self?.exhibition.count == 0) {
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.noDataView.isHidden = false
                    self?.commonListLoadingView.isHidden = false
                    self?.commonListLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: MuseumExhibitions Service Call
    func getMuseumExhibitionDataFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.MuseumExhibitionList(["museum_id": museumId ?? 0]))
            .responseObject { [weak self] (response: DataResponse<Exhibitions>) -> Void in
            switch response.result {
            case .success(let data):
                self?.exhibition = data.exhibitions
                if let exhibitions = data.exhibitions {
                    self?.saveOrUpdateExhibitionsCoredata(exhibition: exhibitions,
                                                         isHomeExhibition: "0")
                }
                self?.commonListTableView.reloadData()
                self?.commonListLoadingView.stopLoading()
                self?.commonListLoadingView.isHidden = true
                if (self?.exhibition.count == 0) {
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.noDataView.isHidden = false
                    self?.commonListLoadingView.isHidden = false
                    self?.commonListLoadingView.showNoDataView()
                }
            case .failure(let error):
                if let controller = self, let unhandledError = handleError(viewController: controller, errorType: error as! CPBackendError) {
                    var errorMessage: String
                    var errorTitle: String
                    switch unhandledError.code {
                    default: print(unhandledError.code)
                    errorTitle = String(format: NSLocalizedString("UNKNOWN_ERROR_ALERT_TITLE",
                                                                  comment: "Setting the title of the alert"))
                    errorMessage = String(format: NSLocalizedString("ERROR_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    }
                    presentAlert(controller, title: errorTitle, message: errorMessage)
                }
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateExhibitionsCoredata(exhibition:[CPExhibition], isHomeExhibition : String?) {
        if !exhibition.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateExhibitionsEntity(managedContext: managedContext,
                                                        exhibition: exhibition,
                                                        isHomeExhibition :isHomeExhibition,
                                                        language: CPUtils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateExhibitionsEntity(managedContext : managedContext,
                                                        exhibition: exhibition,
                                                        isHomeExhibition :isHomeExhibition,
                                                        language: CPUtils.getLanguage())
                }
            }
        }
    }
    
    
    func fetchExhibitionsListFromCoredata() {
        let managedContext = getContext()
        do {
            
            let exhibitionArray = checkMultiplePredicate(entityName: "ExhibitionsEntity",
                                                         idKey: "isHomeExhibition",
                                                         idValue: "1",
                                                         langKey: "lang",
                                                         langValue: CPUtils.getLanguage(),
                                                         managedContext: managedContext) as! [ExhibitionsEntity]
            if (exhibitionArray.count > 0) {
                if((self.networkReachability?.isReachable)!) {
                    DispatchQueue.global(qos: .background).async {
                        self.getExhibitionDataFromServer()
                    }
                }
                for entity in exhibitionArray {
                    self.exhibition.append(CPExhibition(entity: entity))
                }
                
                if(exhibition.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                DispatchQueue.main.async{
                    self.commonListTableView.reloadData()
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
            exhibitionArray = CPDataManager.checkAddedToCoredata(entityName: "ExhibitionsEntity",
                                                               idKey: "museumId",
                                                               idValue: museumId,
                                                               managedContext: managedContext) as! [ExhibitionsEntity]
            if (exhibitionArray.count > 0) {
                for entity in exhibitionArray {
                    self.exhibition.append(CPExhibition(entity: entity))
                }
                
                if(exhibition.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                DispatchQueue.main.async{
                    self.commonListTableView.reloadData()
                }
            } else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.commonListLoadingView.showNoDataView()
                }
            }
        }
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
    func getCollectionList() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.CollectionList(CPLocalizationLanguage.currentAppleLanguage(),["museum_id": museumId ?? 0])).responseObject { [weak self] (response: DataResponse<Collections>) -> Void in
            switch response.result {
            case .success(let data):
                if((self?.museumId == "63") && (self?.museumId == "96")) {
                    if(self?.collection.count == 0) {
                        self?.collection = data.collections!
                        self?.commonListLoadingView.stopLoading()
                        self?.commonListLoadingView.isHidden = true
                    }
                } else {
                    self?.collection = data.collections!
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.isHidden = true
                }
                if(self?.collection.count == 0) {
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.noDataView.isHidden = false
                    self?.commonListLoadingView.isHidden = false
                    self?.commonListLoadingView.showNoDataView()
                }else {
                    self?.commonListTableView.reloadData()
                    if let collections = data.collections {
                        self?.saveOrUpdateCollectionCoredata(collection: collections,
                                                            language: CPLocalizationLanguage.currentAppleLanguage())
                    }
                }
                
            case .failure( _):
                print("error")
                if((self?.museumId != "63") && (self?.museumId != "96")) {
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.noDataView.isHidden = false
                    self?.commonListLoadingView.isHidden = false
                    self?.commonListLoadingView.showNoDataView()
                    self?.commonListLoadingView.noDataLabel.text = errorMessage
                }
            }
        }
    }
    
    //MARK: PublicArts Functions
    //MARK: WebServiceCall
    func getPublicArtsListDataFromServer() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.PublicArtsList(CPLocalizationLanguage.currentAppleLanguage())).responseObject { [weak self](response: DataResponse<PublicArtsLists>) -> Void in
            switch response.result {
            case .success(let data):
                if(self?.publicArtsListArray.count == 0) {
                    self?.publicArtsListArray = data.publicArtsList
                    self?.commonListTableView.reloadData()
                    if(self?.publicArtsListArray.count == 0) {
                        self?.commonListLoadingView.stopLoading()
                        self?.commonListLoadingView.noDataView.isHidden = false
                        self?.commonListLoadingView.isHidden = false
                        self?.commonListLoadingView.showNoDataView()
                    }
                }
                if let count = self?.publicArtsListArray.count, count > 0 {
                    self?.saveOrUpdatePublicArtsCoredata(publicArtsListArray: data.publicArtsList,
                                                        lang: CPLocalizationLanguage.currentAppleLanguage())
                }
            case .failure( _):
                if(self?.publicArtsListArray.count == 0) {
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.noDataView.isHidden = false
                    self?.commonListLoadingView.isHidden = false
                    self?.commonListLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdatePublicArtsCoredata(publicArtsListArray:[CPPublicArtsList]?, lang: String) {
        if ((publicArtsListArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updatePublicArts(managedContext: managedContext,
                                                 publicArtsListArray: publicArtsListArray, language: CPUtils.getLanguageCode(lang))
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updatePublicArts(managedContext : managedContext,
                                                 publicArtsListArray: publicArtsListArray, language: CPUtils.getLanguageCode(lang))
                }
            }
        }
    }
    
    func fetchPublicArtsListFromCoredata() {
        let managedContext = getContext()
        do {
            
            
            let publicArtsArray = CPDataManager.checkAddedToCoredata(entityName: "PublicArtsEntity",
                                                                   idKey: "language",
                                                                   idValue: CPUtils.getLanguage(),
                                                                   managedContext: managedContext) as! [PublicArtsEntity]
            if (publicArtsArray.count > 0) {
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getPublicArtsListDataFromServer()
                    }
                }
                
                for publicArtsDict in publicArtsArray {
                    self.publicArtsListArray.append(CPPublicArtsList(entity: publicArtsDict))
                }
                
                if(publicArtsListArray.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                commonListTableView.reloadData()
            }
            else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    //self.exbtnLoadingView.showNoDataView()
                    self.getPublicArtsListDataFromServer()//coreDataMigratio  solution
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if (networkReachability?.isReachable == false) {
                self.showNoNetwork()
            }
        }
    }
    //MARK: Heritage Page WebServiceCall
    func getHeritageDataFromServer() {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.HeritageList(CPLocalizationLanguage.currentAppleLanguage())).responseObject { [weak self] (response: DataResponse<Heritages>) -> Void in
            switch response.result {
            case .success(let data):
                if(self?.heritageListArray.count == 0) {
                    self?.heritageListArray = data.heritage
                    self?.commonListTableView.reloadData()
                    if(self?.heritageListArray.count == 0) {
                        self?.commonListLoadingView.stopLoading()
                        self?.commonListLoadingView.noDataView.isHidden = false
                        self?.commonListLoadingView.isHidden = false
                        self?.commonListLoadingView.showNoDataView()
                    }
                }
                if let count = self?.heritageListArray.count, count > 0 {
                    if let heritage = data.heritage {
                        self?.saveOrUpdateHeritageCoredata(heritageListArray: heritage)
                    }
                }
            case .failure( _):
                if(self?.heritageListArray.count == 0) {
                    self?.commonListLoadingView.stopLoading()
                    self?.commonListLoadingView.noDataView.isHidden = false
                    self?.commonListLoadingView.isHidden = false
                    self?.commonListLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateHeritageCoredata(heritageListArray: [CPHeritage]) {
        if !heritageListArray.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateHeritage(managedContext: managedContext,
                                               heritageListArray: heritageListArray,
                                               language: CPUtils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateHeritage(managedContext : managedContext,
                                               heritageListArray: heritageListArray,
                                               language: CPUtils.getLanguage())
                }
            }
        }
    }
    
    func fetchHeritageListFromCoredata() {
        let managedContext = getContext()
        do {
            var heritageArray = [HeritageEntity]()
            if ((CPLocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                heritageArray = CPDataManager.checkAddedToCoredata(entityName: "HeritageEntity",
                                                                 idKey: "lang",
                                                                 idValue: "1",
                                                                 managedContext: managedContext) as! [HeritageEntity]
                
            } else {
                heritageArray = CPDataManager.checkAddedToCoredata(entityName: "HeritageEntity",
                                                                 idKey: "lang",
                                                                 idValue: "0",
                                                                 managedContext: managedContext) as! [HeritageEntity]
                
            }
            if (heritageArray.count > 0) {
                if((self.networkReachability?.isReachable)!) {
                    DispatchQueue.global(qos: .background).async {
                        self.getHeritageDataFromServer()
                    }
                }
                
                for heritageDict in heritageArray {
                    self.heritageListArray.append(CPHeritage(entity: heritageDict))
                }
                
                if(heritageListArray.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                DispatchQueue.main.async{
                    self.commonListTableView.reloadData()
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
}
