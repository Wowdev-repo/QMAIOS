//
//  CommonDetailViewController+CoreData.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension CommonDetailViewController {
    //MARK: WebServiceCall
    func getHeritageDetailsFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.HeritageDetail(["nid": heritageDetailId!])).responseObject { (response: DataResponse<Heritages>) -> Void in
            switch response.result {
            case .success(let data):
                self.heritageDetailtArray = data.heritage!
                self.setTopBarImage()
                self.saveOrUpdateHeritageCoredata()
                self.commonDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.heritageDetailtArray.count == 0) {
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
    
    //MARK: PublicArts webservice call
    func getPublicArtsDetailsFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetPublicArtsDetail(["nid": publicArtsDetailId!])).responseObject { (response: DataResponse<PublicArtsDetails>) -> Void in
            switch response.result {
            case .success(let data):
                self.publicArtsDetailtArray = data.publicArtsDetail!
                self.setTopBarImage()
                self.saveOrUpdatePublicArtsCoredata()
                self.commonDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.publicArtsDetailtArray.count == 0) {
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
    //MARK: Heritage Coredata Method
    func saveOrUpdateHeritageCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (heritageDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateHeritage(managedContext : managedContext,
                                               heritageListArray: self.heritageDetailtArray,
                                               language: Utils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateHeritage(managedContext : managedContext,
                                               heritageListArray: self.heritageDetailtArray,
                                               language: Utils.getLanguage())
                }
            }
        }
    }
    
    
    func fetchHeritageDetailsFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            let heritageArray = DataManager.checkAddedToCoredata(entityName: "HeritageEntity",
                                                                 idKey: "listid",
                                                                 idValue: heritageDetailId,
                                                                 managedContext: managedContext) as! [HeritageEntity]
            
            if (heritageArray.count > 0) {
                let heritageDict = heritageArray[0]
                if((heritageDict.detailshortdescription != nil) && (heritageDict.detaillongdescription != nil) ) {
                    self.heritageDetailtArray.append(Heritage(entity: heritageDict))
                    
                    if(heritageDetailtArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    self.setTopBarImage()
                    commonDetailTableView.reloadData()
                }else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            } else {
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.loadingView.showNoDataView()
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: PublicArts Coredata Method
    func saveOrUpdatePublicArtsCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (publicArtsDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updatePublicArtsDetailsEntity(managedContext: managedContext,
                                                              publicArtsListArray: self.publicArtsDetailtArray)                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updatePublicArtsDetailsEntity(managedContext: managedContext,
                                                              publicArtsListArray: self.publicArtsDetailtArray)
                }
            }
        }
    }
    
    func fetchPublicArtsDetailsFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            var publicArtsArray = [PublicArtsEntity]()
            let publicArtsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "PublicArtsEntity")
            if(publicArtsDetailId != nil) {
                publicArtsFetchRequest.predicate = NSPredicate.init(format: "id == \(publicArtsDetailId!)")
                publicArtsArray = (try managedContext.fetch(publicArtsFetchRequest) as? [PublicArtsEntity])!
                
                if (publicArtsArray.count > 0) {
                    let publicArtsDict = publicArtsArray[0]
                    if((publicArtsDict.detaildescription != nil) && (publicArtsDict.shortdescription != nil) ) {
                        self.publicArtsDetailtArray.append(PublicArtsDetail(entity: publicArtsDict))
                        
                        if(publicArtsDetailtArray.count == 0){
                            if(self.networkReachability?.isReachable == false) {
                                self.showNoNetwork()
                            } else {
                                self.loadingView.showNoDataView()
                            }
                        }
                        self.setTopBarImage()
                        commonDetailTableView.reloadData()
                    }else {
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                }
                else{
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: ExhibitionDetail Webservice call
    func getExhibitionDetail() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.ExhibitionDetail(["nid": exhibitionId!])).responseObject { (response: DataResponse<Exhibitions>) -> Void in
            switch response.result {
            case .success(let data):
                self.exhibition = data.exhibitions!
                self.setTopBarImage()
                self.saveOrUpdateExhibitionsCoredata()
                self.commonDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.exhibition.count == 0) {
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
    //MARK: Coredata Method
    func saveOrUpdateExhibitionsCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if !self.exhibition.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateExhibitionsEntity(managedContext : managedContext,
                                                        exhibition: self.exhibition,
                                                        isHomeExhibition:"0",
                                                        language: Utils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateExhibitionsEntity(managedContext: managedContext,
                                                        exhibition: self.exhibition,
                                                        isHomeExhibition: "0",
                                                        language: Utils.getLanguage())
                }
            }
        }
    }
    
    func fetchExhibitionDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            
            let exhibitionArray = DataManager.checkAddedToCoredata(entityName: "ExhibitionsEntity",
                                                                   idKey: "id",
                                                                   idValue: self.exhibitionId,
                                                                   managedContext: managedContext) as! [ExhibitionsEntity]
            
            let exhibitionDict = exhibitionArray[0]
            if ((exhibitionArray.count > 0)
                && (exhibitionDict.detailLongDesc != nil)
                && (exhibitionDict.detailShortDesc != nil)) {
                
                self.exhibition.append(Exhibition(entity: exhibitionDict))
                
                if(self.exhibition.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
                self.self.setTopBarImage()
                self.commonDetailTableView.reloadData()
            }
            else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.loadingView.showNoDataView()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    //MARK: Parks WebServiceCall
    func getParksDataFromServer()
    {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.ParksList(LocalizationLanguage.currentAppleLanguage())).responseObject { (response: DataResponse<ParksLists>) -> Void in
            switch response.result {
            case .success(let data):
                if (self.parksListArray.count == 0) {
                    self.parksListArray = data.parkList
                    self.commonDetailTableView.reloadData()
                    if(self.parksListArray.count == 0) {
                        self.addCloseButton()
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
                if (self.parksListArray.count > 0)  {
                    if let parkList = data.parkList {
                        self.saveOrUpdateParksCoredata(parksListArray: parkList)
                    }
                    
                    self.setTopBarImage()
                }
                
            case .failure( _):
                print("error")
                if(self.parksListArray.count == 0) {
                    self.addCloseButton()
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
    func saveOrUpdateParksCoredata(parksListArray: [ParksList] ) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if !parksListArray.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateParks(managedContext: managedContext,
                                            parksListArray: parksListArray,
                                            language: Utils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateParks(managedContext : managedContext,
                                            parksListArray: parksListArray,
                                            language: Utils.getLanguage())
                }
            }
        }
    }
    
    func fetchParksFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            var parksArray = [ParksEntity]()
            let parksFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "ParksEntity")
            parksArray = (try managedContext.fetch(parksFetchRequest) as? [ParksEntity])!
            
            if (parksArray.count > 0) {
                if  (networkReachability?.isReachable)! {
                    DispatchQueue.global(qos: .background).async {
                        self.getParksDataFromServer()
                    }
                }
                for entity in parksArray {
                    self.parksListArray.append(ParksList(title: entity.title,
                                                         description: entity.parksDescription,
                                                         sortId: entity.sortId,
                                                         image: entity.image,
                                                         language: entity.language))
                    
                }
                if(parksListArray.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
                //if let imageUrl = parksListArray[0].image {
                self.setTopBarImage()
                //                    } else {
                //                        imageView.image = UIImage(named: "default_imageX2")
                //                    }
                
                commonDetailTableView.reloadData()
            }
            else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                    self.addCloseButton()
                } else {
                    //self.loadingView.showNoDataView()
                    self.getParksDataFromServer()//coreDataMigratio  solution
                    self.addCloseButton()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if(self.networkReachability?.isReachable == false) {
                self.showNoNetwork()
                self.addCloseButton()
            }
        }
    }
    //MARK : NMoQPark
    func getNMoQParkDetailFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (parkDetailId != nil) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetNMoQPlaygroundDetail(LocalizationLanguage.currentAppleLanguage(), ["nid": parkDetailId!])).responseObject { (response: DataResponse<NMoQParksDetail>) -> Void in
                switch response.result {
                case .success(let data):
                    self.nmoqParkDetailArray = data.nmoqParksDetail
                    // self.saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: data.nmoqParksDetail)
                    self.commonDetailTableView.reloadData()
                    //                    if(self.nmoqParkDetailArray.count > 0) {
                    //                        if ( (self.nmoqParkDetailArray[0].images?.count)! > 0) {
                    //                            if let imageUrl = self.nmoqParkDetailArray[0].images?[0] {
                    self.setTopBarImage()
                    //                            } else {
                    //                                self.imageView.image = UIImage(named: "default_imageX2")
                    //                            }
                    //
                    //                        }
                    //                    }
                    
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    if (self.nmoqParkDetailArray.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                    }
                    
                case .failure( _):
                    self.addCloseButton()
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
    //MARK: NMoq Playground Parks Detail Coredata Method
    func saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: [NMoQParkDetail]) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if !nmoqParkList.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.updateNmoqParkDetail(nmoqParkList: nmoqParkList,
                                                     managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateNmoqParkDetail(nmoqParkList: nmoqParkList,
                                                     managedContext : managedContext)
                }
            }
        }
    }
    
    
    func fetchNMoQParkDetailFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            var parkListArray = [NMoQParkDetailEntity]()
            parkListArray = DataManager.checkAddedToCoredata(entityName: "NMoQParkDetailEntity",
                                                             idKey: "nid",
                                                             idValue: parkDetailId,
                                                             managedContext: managedContext) as! [NMoQParkDetailEntity]
            if (parkListArray.count > 0) {
                for parkListDict in parkListArray {
                    self.nmoqParkDetailArray.append(NMoQParkDetail(entity: parkListDict))
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
                    // if ( (self.nmoqParkDetailArray[0].images?.count)! > 0) {
                    // if let imageUrl = self.nmoqParkDetailArray[0].images?[0] {
                    self.setTopBarImage()
                    //                            } else {
                    //                                self.imageView.image = UIImage(named: "default_imageX2")
                    //                            }
                    
                    //}
                }
                commonDetailTableView.reloadData()
            } else{
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.loadingView.showNoDataView()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            if(self.networkReachability?.isReachable == false) {
                self.showNoNetwork()
                self.addCloseButton()
            }
        }
    }
    //MARK: Dining WebServiceCall
    func getDiningDetailsFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.GetDiningDetail(["nid": diningDetailId!])).responseObject { (response: DataResponse<Dinings>) -> Void in
            switch response.result {
            case .success(let data):
                self.diningDetailtArray = data.dinings!
                self.setTopBarImage()
                self.saveOrUpdateDiningDetailCoredata()
                self.commonDetailTableView.reloadData()
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.diningDetailtArray.count == 0) {
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
    //MARK: Dining Coredata Method
    func saveOrUpdateDiningDetailCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (diningDetailtArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    self.diningCoreDataInBackgroundThread(managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    self.diningCoreDataInBackgroundThread(managedContext : managedContext)
                }
            }
        }
    }
    
    func diningCoreDataInBackgroundThread(managedContext: NSManagedObjectContext) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let fetchData = DataManager.checkAddedToCoredata(entityName: "DiningEntity",
                                                         idKey: "id",
                                                         idValue: diningDetailtArray[0].id,
                                                         managedContext: managedContext) as! [DiningEntity]
        let diningDetailDict = diningDetailtArray[0]
        if (fetchData.count > 0) {
            let diningdbDict = fetchData[0]
            DataManager.saveToDiningCoreData(diningListDict: diningDetailDict,
                                             managedObjContext: managedContext,
                                             entity: diningdbDict,
                                             language: Utils.getLanguage())
            
        } else {
            DataManager.saveToDiningCoreData(diningListDict: diningDetailDict,
                                             managedObjContext: managedContext,
                                             entity: nil,
                                             language: Utils.getLanguage())
        }
    }
    
    func fetchDiningDetailsFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            let diningArray = DataManager.checkAddedToCoredata(entityName: "DiningEntity",
                                                               idKey: "id",
                                                               idValue: diningDetailId!,
                                                               managedContext: managedContext) as! [DiningEntity]
            
            let diningDict = diningArray[0]
            if ((diningArray.count > 0) && (diningDict.diningdescription != nil)) {
                
                self.diningDetailtArray.append(Dining(entity: diningDict))
                
                if diningDetailtArray.isEmpty {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
                self.setTopBarImage()
                commonDetailTableView.reloadData()
            } else {
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.loadingView.showNoDataView()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
