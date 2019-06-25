//
//  CommonList.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
import Crashlytics
import Firebase

extension CommonListViewController {
    //MARK: CollectionList Coredata Method
    func saveOrUpdateCollectionCoredata(collection: [Collection], language: String) {
        if !collection.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateCollectionsEntity(managedContext: managedContext,
                                                        collection: collection, language: Utils.getLanguageCode(language))
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateCollectionsEntity(managedContext : managedContext,
                                                        collection: collection, language: Utils.getLanguageCode(language))
                }
            }
        }
    }
    
    
    func fetchCollectionListFromCoredata() {
        let managedContext = getContext()
        do {
            var collectionArray = [CollectionsEntity]()
            collectionArray = DataManager.checkAddedToCoredata(entityName: "CollectionsEntity",
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
                    self.collection.append(Collection(entity: entity))
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
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.DiningList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<Dinings>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.diningListArray.count == 0) {
                    self.diningListArray = data.dinings
                    self.commonListTableView.reloadData()
                    if(self.diningListArray.count == 0) {
                        self.commonListLoadingView.stopLoading()
                        self.commonListLoadingView.noDataView.isHidden = false
                        self.commonListLoadingView.isHidden = false
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                if(self.diningListArray.count > 0) {
                    self.saveOrUpdateDiningCoredata(diningListArray: data.dinings,
                                                    lang: LocalizationLanguage.currentAppleLanguage())
                }
            case .failure( _):
                if(self.diningListArray.count == 0) {
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.noDataView.isHidden = false
                    self.commonListLoadingView.isHidden = false
                    self.commonListLoadingView.showNoDataView()
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
    func saveOrUpdateDiningCoredata(diningListArray : [Dining]?, lang: String) {
        if ((diningListArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate?.persistentContainer
                container?.performBackgroundTask() {(managedContext) in
                    DataManager.updateDinings(managedContext: managedContext,
                                              diningListArray: diningListArray!,
                                              language: lang)
                }
            } else {
                let managedContext = appDelegate?.managedObjectContext
                managedContext?.perform {
                    DataManager.updateDinings(managedContext : managedContext!,
                                              diningListArray: diningListArray!, language: lang)
                }
            }
        }
    }
    
    func fetchMuseumDiningListFromCoredata() {
        let managedContext = getContext()
        do {
            var diningArray = [DiningEntity]()
            diningArray = DataManager.checkAddedToCoredata(entityName: "DiningEntity",
                                                           idKey: "museumId",
                                                           idValue: museumId,
                                                           managedContext: managedContext) as! [DiningEntity]
            
            if !diningArray.isEmpty {
                for dining in diningArray {
                    self.diningListArray.append(Dining(entity: dining))
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
            
            diningArray = DataManager.checkAddedToCoredata(entityName: "DiningEntity",
                                                           idKey: "lang", idValue: Utils.getLanguage(),
                                                           managedContext: managedContext) as! [DiningEntity]
            if (diningArray.count > 0) {
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getDiningListFromServer()
                    }
                }
                for dining in diningArray {
                    self.diningListArray.append(Dining(entity: dining))
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
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQTourDetail(["event_id" : tourDetailId!])).responseObject { (response: DataResponse<NMoQTourDetailList>) -> Void in
                switch response.result {
                case .success(let data):
                    self.nmoqTourDetail = data.nmoqTourDetailList ?? []
                    if self.nmoqTourDetail.first(where: {$0.sortId != "" && $0.sortId != nil} ) != nil {
                        self.nmoqTourDetail = self.nmoqTourDetail.sorted(by: { Int16($0.sortId!)! < Int16($1.sortId!)! })
                    }
                    self.commonListTableView.reloadData()
                    if(self.nmoqTourDetail.count == 0) {
                        let noResultMsg = NSLocalizedString("NO_RESULT_MESSAGE",
                                                            comment: "Setting the content of the alert")
                        self.commonListLoadingView.stopLoading()
                        self.commonListLoadingView.noDataView.isHidden = false
                        self.commonListLoadingView.isHidden = false
                        self.commonListLoadingView.showNoDataView()
                        self.commonListLoadingView.noDataLabel.text = noResultMsg
                    } else {
                        self.saveOrUpdateTourDetailCoredata()
                    }
                case .failure( _):
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.noDataView.isHidden = false
                    self.commonListLoadingView.isHidden = false
                    self.commonListLoadingView.showNoDataView()
                    self.commonListLoadingView.noDataLabel.text = errorMessage
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
                    DataManager.updateNmoqTourDetails(managedContext : managedContext,
                                                      eventID: self.tourDetailId,
                                                      events: self.nmoqTourDetail)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateNmoqTourDetails(managedContext : managedContext,
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
            tourDetailArray = DataManager.checkAddedToCoredata(entityName: "NmoqTourDetailEntity",
                                                               idKey: "nmoqEvent",
                                                               idValue: tourDetailId,
                                                               managedContext: managedContext) as! [NmoqTourDetailEntity]
            if (tourDetailArray.count > 0) {
                
                for entity in tourDetailArray {
                    self.nmoqTourDetail.append(NMoQTourDetail(entity: entity))
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
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetFacilitiesDetail(["category_id" : tourDetailId!])).responseObject { (response: DataResponse<FacilitiesDetailData>) -> Void in
                switch response.result {
                case .success(let data):
                    self.facilitiesDetail = data.facilitiesDetail
                    self.commonListTableView.reloadData()
                    if(self.nmoqTourDetail.count == 0) {
                        let noResultMsg = NSLocalizedString("NO_RESULT_MESSAGE",
                                                            comment: "Setting the content of the alert")
                        self.commonListLoadingView.stopLoading()
                        self.commonListLoadingView.noDataView.isHidden = false
                        self.commonListLoadingView.isHidden = false
                        self.commonListLoadingView.showNoDataView()
                        self.commonListLoadingView.noDataLabel.text = noResultMsg
                    } else {
                        self.saveOrUpdateFacilitiesDetailCoredata()
                    }
                case .failure( _):
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.noDataView.isHidden = false
                    self.commonListLoadingView.isHidden = false
                    self.commonListLoadingView.showNoDataView()
                    self.commonListLoadingView.noDataLabel.text = errorMessage
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
                    DataManager.updateFacilitiesDetails(managedContext : managedContext,
                                                        category: self.tourDetailId,
                                                        facilities: self.facilitiesDetail)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateFacilitiesDetails(managedContext : managedContext,
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
            facilitiesDetailArray = DataManager.checkAddedToCoredata(entityName: "FacilitiesDetailEntity",
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
                    self.facilitiesDetail.insert(FacilitiesDetail(entity: facilitiesDetailArray[i]), at: i)
                    
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
            .request(QatarMuseumRouter.MuseumTourGuide(LocalizationLanguage.currentAppleLanguage(), ["museum_id": museumId ?? 0]))
            .responseObject { (response: DataResponse<TourGuides>) -> Void in
                switch response.result {
                case .success(let data):
                    if(self.miaTourDataFullArray.count == 0) {
                        self.miaTourDataFullArray = data.tourGuide!
                        self.commonListTableView.reloadData()
                        //if no result after api call
                        if(self.miaTourDataFullArray.count == 0) {
                            self.commonListLoadingView.stopLoading()
                            self.commonListLoadingView.noDataView.isHidden = false
                            self.commonListLoadingView.isHidden = false
                            self.commonListLoadingView.showNoDataView()
                        }
                    }
                    if(self.miaTourDataFullArray.count > 0) {
                        self.saveOrUpdateTourGuideCoredata(miaTourDataFullArray: data.tourGuide)
                    }
                case .failure(let error):
                    if(self.miaTourDataFullArray.count == 0) {
                        self.commonListLoadingView.stopLoading()
                        self.commonListLoadingView.noDataView.isHidden = false
                        self.commonListLoadingView.isHidden = false
                        self.commonListLoadingView.showNoDataView()
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
                    DataManager.updateTourGuide(managedContext: managedContext,
                                                miaTourDataFullArray: self.miaTourDataFullArray,
                                                museumID: self.museumId,
                                                language: Utils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateTourGuide(managedContext : managedContext,
                                                miaTourDataFullArray: self.miaTourDataFullArray,
                                                museumID: self.museumId,
                                                language: Utils.getLanguage())
                }
            }
        }
    }
    
    func fetchTourGuideListFromCoredata() {
        let managedContext = getContext()
        do {
            var tourGuideArray = [TourGuideEntity]()
            tourGuideArray = DataManager.checkAddedToCoredata(entityName: "TourGuideEntity",
                                                              idKey: "museumsEntity",
                                                              idValue: museumId,
                                                              managedContext: managedContext) as! [TourGuideEntity]
            
            if (tourGuideArray.count > 0) {
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getTourGuideDataFromServer()
                    }
                }
                for tourguideInfo in tourGuideArray {
                    self.miaTourDataFullArray.append(TourGuide(entity: tourguideInfo))
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
                    self.commonListTableView.reloadData()
                }
                if(self.museumsList.count > 0) {
                    
                    //Removed Exhibition from Tour List
                    if let arrayOffset = self.museumsList.index(where: {$0.id == searchstring}) {
                        self.museumsList.remove(at: arrayOffset)
                    }
                    if let homeList = data.homeList {
                        self.saveOrUpdateMuseumsCoredata(museumsList: homeList,
                                                         language: LocalizationLanguage.currentAppleLanguage())
                    }
                }
            case .failure(let error):
                print("error")
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateMuseumsCoredata(museumsList: [Home], language: String) {
        if !museumsList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateHomeEntity(managedContext: managedContext,
                                                 homeList: museumsList,
                                                 language: Utils.getLanguageCode(language))
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateHomeEntity(managedContext: managedContext,
                                                 homeList: museumsList,
                                                 language: Utils.getLanguageCode(language))
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
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            searchstring = "12181"
        } else {
            searchstring = "12186"
        }
        do {
            var museumsArray = [HomeEntity]()
            museumsArray = DataManager.checkAddedToCoredata(entityName: "HomeEntity",
                                                            idKey: "lang",
                                                            idValue: Utils.getLanguage(),
                                                            managedContext: managedContext) as! [HomeEntity]
            if (museumsArray.count > 0) {
                for entity in museumsArray {
                    if let duplicateId = museumsList.first(where: {$0.id == entity.id}) {
                    } else {
                        self.museumsList.append(Home(entity: entity))
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
        let miaView =  self.storyboard?.instantiateViewController(withIdentifier: "exhibitionViewId") as! CommonListViewController
        miaView.exhibitionsPageNameString = ExhbitionPageName.miaTourGuideList
        if (museumsList != nil) {
            miaView.museumId = museumsList[currentRow!].id!
            self.present(miaView, animated: false, completion: nil)
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    func getNmoqParkListFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNmoqParkList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<NmoqParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.nmoqParkList.count == 0) {
                    self.nmoqParkList = data.nmoqParkList
                    if(self.nmoqParkList.count > 0) {
                        self.commonListHeaderView.headerTitle.text = self.nmoqParkList[0].title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
                    }
                    self.commonListTableView.reloadData()
                    if(self.nmoqParkList.count == 0) {
                        self.commonListLoadingView.stopLoading()
                        self.commonListLoadingView.noDataView.isHidden = false
                        self.commonListLoadingView.isHidden = false
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                if(self.nmoqParkList.count > 0) {
                    if let nmoqParkList = data.nmoqParkList {
                        self.saveOrUpdateNmoqParkListCoredata(nmoqParkList: nmoqParkList)
                    }
                }
            case .failure( _):
                if(self.nmoqParkList.count == 0) {
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.noDataView.isHidden = false
                    self.commonListLoadingView.isHidden = false
                    self.commonListLoadingView.showNoDataView()
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
                    self.commonListTableView.reloadData()
                    if(self.nmoqParks.count == 0) {
                        self.commonListLoadingView.stopLoading()
                        self.commonListLoadingView.noDataView.isHidden = false
                        self.commonListLoadingView.isHidden = false
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                if(self.nmoqParks.count > 0) {
                    if let nmoqParks = data.nmoqParks {
                        self.saveOrUpdateNmoqParksCoredata(nmoqParkList: nmoqParks)
                    }
                }
                
            case .failure( _):
                if(self.nmoqParks.count == 0) {
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.noDataView.isHidden = false
                    self.commonListLoadingView.isHidden = false
                    self.commonListLoadingView.showNoDataView()
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
                    DataManager.updateNmoqParkList(nmoqParkList: nmoqParkList,
                                                   managedContext: managedContext,
                                                   language: Utils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateNmoqParkList(nmoqParkList: nmoqParkList,
                                                   managedContext : managedContext,
                                                   language: Utils.getLanguage())
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
                    DataManager.updateNmoqPark(nmoqParkList: nmoqParkList,
                                               managedContext: managedContext,
                                               language: Utils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateNmoqPark(nmoqParkList: nmoqParkList,
                                               managedContext : managedContext,
                                               language: Utils.getLanguage())
                }
            }
        }
    }
    
    
    func fetchNmoqParkListFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            var parkListArray = [NMoQParkListEntity]()
            let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "NMoQParkListEntity")
            parkListArray = (try managedContext.fetch(fetchRequest) as? [NMoQParkListEntity])!
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
            
            
            let parkListArray = DataManager.checkAddedToCoredata(entityName: "NMoQParksEntity",
                                                                 idKey: "language",
                                                                 idValue: Utils.getLanguage(),
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
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.ExhibitionList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<Exhibitions>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.exhibition.count == 0) {
                    self.exhibition = data.exhibitions
                    self.commonListTableView.reloadData()
                    if(self.exhibition.count == 0) {
                        self.commonListLoadingView.stopLoading()
                        self.commonListLoadingView.noDataView.isHidden = false
                        self.commonListLoadingView.isHidden = false
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                if(self.exhibition.count > 0) {
                    if let exhibitions = data.exhibitions {
                        self.saveOrUpdateExhibitionsCoredata(exhibition: exhibitions,
                                                             isHomeExhibition: "1")
                    }
                }
            case .failure( _):
                if(self.exhibition.count == 0) {
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.noDataView.isHidden = false
                    self.commonListLoadingView.isHidden = false
                    self.commonListLoadingView.showNoDataView()
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
                if let exhibitions = data.exhibitions {
                    self.saveOrUpdateExhibitionsCoredata(exhibition: exhibitions,
                                                         isHomeExhibition: "0")
                }
                self.commonListTableView.reloadData()
                self.commonListLoadingView.stopLoading()
                self.commonListLoadingView.isHidden = true
                if (self.exhibition.count == 0) {
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.noDataView.isHidden = false
                    self.commonListLoadingView.isHidden = false
                    self.commonListLoadingView.showNoDataView()
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
    //MARK: Coredata Method
    func saveOrUpdateExhibitionsCoredata(exhibition:[Exhibition], isHomeExhibition : String?) {
        if !exhibition.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateExhibitionsEntity(managedContext: managedContext,
                                                        exhibition: exhibition,
                                                        isHomeExhibition :isHomeExhibition,
                                                        language: Utils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateExhibitionsEntity(managedContext : managedContext,
                                                        exhibition: exhibition,
                                                        isHomeExhibition :isHomeExhibition,
                                                        language: Utils.getLanguage())
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
                                                         langValue: Utils.getLanguage(),
                                                         managedContext: managedContext) as! [ExhibitionsEntity]
            if (exhibitionArray.count > 0) {
                if((self.networkReachability?.isReachable)!) {
                    DispatchQueue.global(qos: .background).async {
                        self.getExhibitionDataFromServer()
                    }
                }
                for entity in exhibitionArray {
                    self.exhibition.append(Exhibition(entity: entity))
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
            exhibitionArray = DataManager.checkAddedToCoredata(entityName: "ExhibitionsEntity",
                                                               idKey: "museumId",
                                                               idValue: museumId,
                                                               managedContext: managedContext) as! [ExhibitionsEntity]
            if (exhibitionArray.count > 0) {
                for entity in exhibitionArray {
                    self.exhibition.append(Exhibition(entity: entity))
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
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.CollectionList(LocalizationLanguage.currentAppleLanguage(),["museum_id": museumId ?? 0])).responseObject { (response: DataResponse<Collections>) -> Void in
            switch response.result {
            case .success(let data):
                if((self.museumId == "63") && (self.museumId == "96")) {
                    if(self.collection.count == 0) {
                        self.collection = data.collections!
                        self.commonListLoadingView.stopLoading()
                        self.commonListLoadingView.isHidden = true
                    }
                } else {
                    self.collection = data.collections!
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.isHidden = true
                }
                if(self.collection.count == 0) {
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.noDataView.isHidden = false
                    self.commonListLoadingView.isHidden = false
                    self.commonListLoadingView.showNoDataView()
                }else {
                    self.commonListTableView.reloadData()
                    if let collections = data.collections {
                        self.saveOrUpdateCollectionCoredata(collection: collections,
                                                            language: LocalizationLanguage.currentAppleLanguage())
                    }
                }
                
            case .failure( _):
                print("error")
                if((self.museumId != "63") && (self.museumId != "96")) {
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                    comment: "Setting the content of the alert"))
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.noDataView.isHidden = false
                    self.commonListLoadingView.isHidden = false
                    self.commonListLoadingView.showNoDataView()
                    self.commonListLoadingView.noDataLabel.text = errorMessage
                }
            }
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
                    self.commonListTableView.reloadData()
                    if(self.publicArtsListArray.count == 0) {
                        self.commonListLoadingView.stopLoading()
                        self.commonListLoadingView.noDataView.isHidden = false
                        self.commonListLoadingView.isHidden = false
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                if(self.publicArtsListArray.count > 0) {
                    self.saveOrUpdatePublicArtsCoredata(publicArtsListArray: data.publicArtsList,
                                                        lang: LocalizationLanguage.currentAppleLanguage())
                }
            case .failure( _):
                if(self.publicArtsListArray.count == 0) {
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.noDataView.isHidden = false
                    self.commonListLoadingView.isHidden = false
                    self.commonListLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdatePublicArtsCoredata(publicArtsListArray:[PublicArtsList]?, lang: String) {
        if ((publicArtsListArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updatePublicArts(managedContext: managedContext,
                                                 publicArtsListArray: publicArtsListArray, language: Utils.getLanguageCode(lang))
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updatePublicArts(managedContext : managedContext,
                                                 publicArtsListArray: publicArtsListArray, language: Utils.getLanguageCode(lang))
                }
            }
        }
    }
    
    func fetchPublicArtsListFromCoredata() {
        let managedContext = getContext()
        do {
            
            
            let publicArtsArray = DataManager.checkAddedToCoredata(entityName: "PublicArtsEntity",
                                                                   idKey: "language",
                                                                   idValue: Utils.getLanguage(),
                                                                   managedContext: managedContext) as! [PublicArtsEntity]
            if (publicArtsArray.count > 0) {
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getPublicArtsListDataFromServer()
                    }
                }
                
                for publicArtsDict in publicArtsArray {
                    self.publicArtsListArray.append(PublicArtsList(entity: publicArtsDict))
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
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.HeritageList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<Heritages>) -> Void in
            switch response.result {
            case .success(let data):
                if(self.heritageListArray.count == 0) {
                    self.heritageListArray = data.heritage
                    self.commonListTableView.reloadData()
                    if(self.heritageListArray.count == 0) {
                        self.commonListLoadingView.stopLoading()
                        self.commonListLoadingView.noDataView.isHidden = false
                        self.commonListLoadingView.isHidden = false
                        self.commonListLoadingView.showNoDataView()
                    }
                }
                if(self.heritageListArray.count > 0) {
                    if let heritage = data.heritage {
                        self.saveOrUpdateHeritageCoredata(heritageListArray: heritage)
                    }
                }
            case .failure( _):
                if(self.heritageListArray.count == 0) {
                    self.commonListLoadingView.stopLoading()
                    self.commonListLoadingView.noDataView.isHidden = false
                    self.commonListLoadingView.isHidden = false
                    self.commonListLoadingView.showNoDataView()
                }
            }
        }
    }
    //MARK: Coredata Method
    func saveOrUpdateHeritageCoredata(heritageListArray: [Heritage]) {
        if !heritageListArray.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateHeritage(managedContext: managedContext,
                                               heritageListArray: heritageListArray,
                                               language: Utils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateHeritage(managedContext : managedContext,
                                               heritageListArray: heritageListArray,
                                               language: Utils.getLanguage())
                }
            }
        }
    }
    
    func fetchHeritageListFromCoredata() {
        let managedContext = getContext()
        do {
            var heritageArray = [HeritageEntity]()
            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
                heritageArray = DataManager.checkAddedToCoredata(entityName: "HeritageEntity",
                                                                 idKey: "lang",
                                                                 idValue: "1",
                                                                 managedContext: managedContext) as! [HeritageEntity]
                
            } else {
                heritageArray = DataManager.checkAddedToCoredata(entityName: "HeritageEntity",
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
                    self.heritageListArray.append(Heritage(entity: heritageDict))
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
