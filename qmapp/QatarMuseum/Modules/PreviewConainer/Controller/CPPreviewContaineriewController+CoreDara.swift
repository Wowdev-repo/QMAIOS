//
//  CPPreviewContaineriewController+CoreDara.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Crashlytics
import Firebase
import UIKit

extension CPPreviewContainerViewController {
    //MARK: TourGuide DataBase
    func saveOrUpdateTourGuideCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if (tourGuideArray.count > 0) {
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.updateFloorMap(managedContext : managedContext,
                                               floorMapArray: self.tourGuideArray,
                                               tourGuideID: self.tourGuideId)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.updateFloorMap(managedContext : managedContext,
                                               floorMapArray: self.tourGuideArray,
                                               tourGuideID: self.tourGuideId)
                }
            }
        }
    }
    
    
    func fetchTourGuideFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let managedContext = getContext()
        do {
            var tourGuideArray = [FloorMapTourGuideEntity]()
            tourGuideArray = CPDataManager.checkAddedToCoredata(entityName: "FloorMapTourGuideEntity",
                                                              idKey: "tourGuideId",
                                                              idValue: tourGuideId,
                                                              managedContext: managedContext) as! [FloorMapTourGuideEntity]
            if (tourGuideArray.count > 0) {
                for tourGuideDict in tourGuideArray {
                    if self.tourGuideArray.first(where: {$0.nid == tourGuideDict.nid}) != nil {
                    } else {
                        self.tourGuideArray.append(CPTourGuideFloorMap(entity: tourGuideDict))
                    }
                }
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                if (self.tourGuideArray.count > 0) {
                    self.headerView.settingsButton.isHidden = false
                    if((self.museumId == "63") || (self.museumId == "96")) {
                        self.headerView.settingsButton.setImage(UIImage(named: "locationImg"), for: .normal)
                        self.headerView.settingsButton.contentEdgeInsets = UIEdgeInsets(top: 9, left: 10, bottom:9, right: 10)
                    } else {
                        self.headerView.settingsButton.isHidden = true
                    }
                    self.setUpPageControl()
                    self.showOrHidePageControlView(countValue: self.tourGuideArray.count, scrolling: false)
                    self.showPageControlAtFirstTime()
                } else if (networkReachability?.isReachable)! {
                    self.showNoData()
                } else {
                    self.showNoNetwork()
                }
                
            } else if (networkReachability?.isReachable)! && self.tourGuideArray.count == 0 {
                self.getTourGuideDataFromServer()
            } else {
                self.loadingView.stopLoading()
                self.loadingView.isHidden = true
                self.showNoNetwork()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

//MARK:- WebServiceCalls
extension CPPreviewContainerViewController {
    func getTourGuideDataFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.CollectionByTourGuide(CPLocalizationLanguage.currentAppleLanguage(),["tour_guide_id": tourGuideId!])).responseObject { [weak self] (response: DataResponse<TourGuideFloorMaps>) -> Void in
            switch response.result {
            case .success(let data):
                self?.tourGuideArray = data.tourGuideFloorMap
                self?.countValue = self?.tourGuideArray.count
                if(self?.tourGuideArray.count != 0) {
                    self?.headerView.settingsButton.isHidden = false
                    if((self?.museumId == "63") || (self?.museumId == "96")) {
                        self?.headerView.settingsButton.setImage(UIImage(named: "locationImg"), for: .normal)
                    } else {
                        self?.headerView.settingsButton.isHidden = true
                    }
                    self?.headerView.settingsButton.contentEdgeInsets = UIEdgeInsets(top: 9, left: 10, bottom:9, right: 10)
                    self?.setUpPageControl()
                    self?.showOrHidePageControlView(countValue: self?.tourGuideArray.count, scrolling: false)
                    self?.showPageControlAtFirstTime()
                    self?.saveOrUpdateTourGuideCoredata()
                }
                self?.loadingView.stopLoading()
                self?.loadingView.isHidden = true
                
                if (self?.tourGuideArray.count == 0) {
                    self?.loadingView.stopLoading()
                    self?.loadingView.noDataView.isHidden = false
                    self?.loadingView.isHidden = false
                    self?.loadingView.showNoDataView()
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
    }
    
    func getTourGuideDataFromServerInBackgound() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let queue = DispatchQueue(label: "", qos: .background, attributes: .concurrent)
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.CollectionByTourGuide(CPLocalizationLanguage.currentAppleLanguage(),["tour_guide_id": tourGuideId!])).responseObject(queue: queue) { [weak self] (response: DataResponse<TourGuideFloorMaps>) -> Void in
            switch response.result {
            case .success(let data):
                if(data.tourGuideFloorMap?.count != 0) {
                    self?.saveOrUpdateTourGuideCoredata()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
