//
//  PanelDiscussionDetailViewController+Extend.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 21/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation


extension PanelDiscussionDetailViewController {
    
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
                self.panelDetailTableView.reloadData()
            }
            
        }
    }
    //MARK: WebServiceCall
    func getCollectioDetailsFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.CollectionDetail(["category": collectionName!])).responseObject { (response: DataResponse<CollectionDetails>) -> Void in
            switch response.result {
            case .success(let data):
                self.collectionDetailArray = data.collectionDetails ?? []
                self.saveOrUpdateCollectionDetailCoredata()
                self.panelDetailTableView.reloadData()
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
                    self.panelDetailTableView.reloadData()
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
                    DataManager.updateCollectionDetailsEntity(managedContext: managedContext,
                                                              collectionDetailArray: self.collectionDetailArray,
                                                              collectionName: self.collectionName)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.updateCollectionDetailsEntity(managedContext : managedContext,
                                                              collectionDetailArray: self.collectionDetailArray,
                                                              collectionName: self.collectionName)
                }
            }
            DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        }
    }
    
    
    
    func fetchCollectionDetailsFromCoredata() {
        let managedContext = getContext()
        do {
            if let collectionArray = DataManager.checkAddedToCoredata(entityName: "CollectionDetailsEntity",
                                                                      idKey: "categoryCollection",
                                                                      idValue: collectionName,
                                                                      managedContext: managedContext) as? [CollectionDetailsEntity],
                !collectionArray.isEmpty {
                for collectionDict in collectionArray {
                    if collectionDict.title == nil && collectionDict.body == nil {
                        self.showNodata()
                    } else {
                        self.collectionDetailArray.insert(CollectionDetail(entity: collectionDict), at: 0)
                    }
                }
            } else {
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.loadingView.showNoDataView()
                }
            }
            
            
            panelDetailTableView.reloadData()
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    //MARK: NMoq Playground Parks Detail Coredata Method
    func saveOrUpdateNmoqParkDetailCoredata(nmoqParkList: [NMoQParkDetail]) {
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
                                                     managedContext: managedContext)                }
            }
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
                }
                DispatchQueue.main.async{
                    self.panelDetailTableView.reloadData()
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
}
