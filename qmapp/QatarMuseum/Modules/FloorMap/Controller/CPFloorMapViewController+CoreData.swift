//
//  CPFloorMapViewController+CoreData.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation

extension CPFloorMapViewController {
    //MARK: WebServiceCall
    //    func getFloorMapDataFromServer() {
    //        // let queue = DispatchQueue(label: "", qos: .background, attributes: .concurrent)
    //        _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.CollectionByTourGuide(LocalizationLanguage.currentAppleLanguage(),["tour_guide_id": tourGuideId!])).responseObject { (response: DataResponse<TourGuideFloorMaps>) -> Void in
    //            switch response.result {
    //            case .success(let data):
    //                if (self.floorMapArray.count > 0) {
    //                    self.saveOrUpdateFloormapCoredata(floorMapArray: data.tourGuideFloorMap)
    //                }
    //
    //            case .failure(let error):
    //                print("error")
    //
    //            }
    //        }
    //    }
    func getFloorMapDataFromServer()
    {
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.CollectionByTourGuide(CPLocalizationLanguage.currentAppleLanguage(),["tour_guide_id": tourGuideId!])).responseObject { [weak self] (response: DataResponse<TourGuideFloorMaps>) -> Void in
            switch response.result {
            case .success(let data):
                self?.floorMapArray = data.tourGuideFloorMap
                self?.loadingView.stopLoading()
                self?.loadingView.isHidden = true
                if let count = self?.floorMapArray.count, count > 0 {
                    if let tourGuideFloorMap = data.tourGuideFloorMap {
                        self?.saveOrUpdateFloormapCoredata(floorMapArray: tourGuideFloorMap)
                    }
                    if ((self?.fromTourString == fromTour.HighlightTour) || (self?.fromTourString == fromTour.exploreTour)){
                        //if(self.selectedScienceTourLevel == "2" ) {
                        self?.showOrHideLevelTwoHighlightTour()
                        // } else if (self.selectedScienceTourLevel == "3" ) {
                        self?.showOrHideLevelThreeHighlightTour()
                        // }
                        if let arrayOffset = self?.floorMapArray.index(where: {$0.nid == self?.selectednid}) {
                            self?.addBottomSheetView(index: arrayOffset)
                        }
                    } else if(self?.fromTourString == fromTour.scienceTour) {
                        // if(self.selectedScienceTourLevel == "2" ) {
                        self?.showOrHideLevelTwoScienceTour()
                        // } else if(self.selectedScienceTourLevel == "3") {
                        self?.showOrHideLevelThreeScienceTour()
                        // }
                        if let arrayOffset = self?.floorMapArray.index(where: {$0.nid == self?.selectednid}) {
                            self?.addBottomSheetView(index: arrayOffset)
                        }
                    }
                }
                
            case .failure(let error):
                var errorMessage: String
                errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                                comment: "Setting the content of the alert"))
                self?.loadingView.stopLoading()
                self?.loadingView.noDataView.isHidden = false
                self?.loadingView.isHidden = false
                self?.loadingView.showNoDataView()
                self?.loadingView.noDataLabel.text = errorMessage
                
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    //MARK: TourGuide DataBase
    func saveOrUpdateFloormapCoredata(floorMapArray: [CPTourGuideFloorMap]) {
        if !floorMapArray.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate?.persistentContainer
                container?.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateFloorMap(managedContext : managedContext,
                                               floorMapArray: floorMapArray,
                                               tourGuideID: self.tourGuideId)
                }
            } else {
                let managedContext = appDelegate?.managedObjectContext
                managedContext?.perform {
                    CPDataManager.updateFloorMap(managedContext : managedContext!,
                                               floorMapArray: floorMapArray,
                                               tourGuideID: self.tourGuideId)
                }
            }
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
    
    
    
    func fetchTourGuideFromCoredata() {
        let managedContext = getContext()
        do {
            var tourGuideArray = [FloorMapTourGuideEntity]()
            tourGuideArray = CPDataManager.checkAddedToCoredata(entityName: "FloorMapTourGuideEntity",
                                                              idKey: "tourGuideId",
                                                              idValue: tourGuideId,
                                                              managedContext: managedContext) as! [FloorMapTourGuideEntity]
            
            if (tourGuideArray.count > 0) {
                for tourGuideDict in tourGuideArray {
                    self.floorMapArray.append(CPTourGuideFloorMap(entity: tourGuideDict))
                }
                
                if (self.floorMapArray.count > 0) {
                    
                    if ((self.fromTourString == fromTour.HighlightTour) || (self.fromTourString == fromTour.exploreTour)){
                        self.showOrHideLevelTwoHighlightTour()
                        self.showOrHideLevelThreeHighlightTour()
                        if let arrayOffset = floorMapArray.index(where: {$0.nid == selectednid}) {
                            self.addBottomSheetView(index: arrayOffset)
                        }
                    } else if(self.fromTourString == fromTour.scienceTour) {
                        self.showOrHideLevelTwoScienceTour()
                        self.showOrHideLevelThreeScienceTour()
                        if let arrayOffset = floorMapArray.index(where: {$0.nid == selectednid}) {
                            self.addBottomSheetView(index: arrayOffset)
                        }
                    }
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    
                    
                } else if (self.floorMapArray.count == 0) {
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
            DDLogError("Could not fetch. \(error), \(error.userInfo)")
        }
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
    }
}
