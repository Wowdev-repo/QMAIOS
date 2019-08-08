//
//  CPMuseumAboutViewController+CoreData.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation
import Firebase

extension CPMuseumAboutViewController {
    //MARK: ABout Webservice
    func getAboutDetailsFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.LandingPageMuseums(["nid": museumId ?? 0])).responseObject { [weak self] (response: DataResponse<Museums>) -> Void in
            switch response.result {
            case .success(let data):
                self?.aboutDetailtArray = data.museum!
                self?.setTopBarImage()
                self?.saveOrUpdateAboutCoredata(aboutDetailtArray: data.museum)
                self?.heritageDetailTableView.reloadData()
                self?.loadingView.stopLoading()
                self?.loadingView.isHidden = true
                if(self?.aboutDetailtArray.count != 0) {
                    if(self?.aboutDetailtArray[0].multimediaFile != nil) {
                        if((self?.aboutDetailtArray[0].multimediaFile?.count)! > 0) {
                            self?.carousel.reloadData()
                        }
                    }
                }
                if (self?.aboutDetailtArray.count == 0) {
                    self?.loadingView.stopLoading()
                    self?.loadingView.noDataView.isHidden = false
                    self?.loadingView.isHidden = false
                    self?.loadingView.showNoDataView()
                }
            case .failure( _):
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
    //MARK: NMoQ ABoutEvent Webservice
    func getNmoQAboutDetailsFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if(museumId != nil) {
            
            _ = CPSessionManager.sharedInstance.apiManager()?.request(CPQatarMuseumRouter.GetNMoQAboutEvent(CPLocalizationLanguage.currentAppleLanguage(),["nid": museumId!]))
                .responseObject { [weak self] (response: DataResponse<Museums>) -> Void in
                switch response.result {
                case .success(let data):
                    if(self?.aboutDetailtArray.count == 0) {
                        self?.aboutDetailtArray = data.museum!
                        self?.heritageDetailTableView.reloadData()
                        if(self?.aboutDetailtArray.count == 0) {
                            self?.loadingView.stopLoading()
                            self?.loadingView.noDataView.isHidden = false
                            self?.loadingView.isHidden = false
                            self?.loadingView.showNoDataView()
                        }
                    }
                    if let count = self?.aboutDetailtArray.count, count > 0 {
                        self?.saveOrUpdateAboutCoredata(aboutDetailtArray: data.museum)
                    }
                    
                case .failure( _):
                    if(self?.aboutDetailtArray.count == 0) {
                        self?.loadingView.stopLoading()
                        self?.loadingView.noDataView.isHidden = false
                        self?.loadingView.isHidden = false
                        self?.loadingView.showNoDataView()
                    }
                }
            }
        }
    }
    //MARK: About CoreData
    func saveOrUpdateAboutCoredata(aboutDetailtArray:[CPMuseum]?) {
        if ((aboutDetailtArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() { managedContext in
                    CPDataManager.saveAboutDetails(managedContext: managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: false,
                                                 language: CPUtils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.saveAboutDetails(managedContext: managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: false,
                                                 language: CPUtils.getLanguage())
                }
            }
        }
    }
    
    func fetchAboutDetailsFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        let managedContext = getContext()
        do {
            //            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            var aboutArray = [AboutEntity]()
            let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "AboutEntity")
            
            if(museumId != nil) {
                //fetchRequest.predicate = NSPredicate.init(format: "id == \(museumId!)")
                fetchRequest.predicate = NSPredicate(format: "id == %@", museumId!)
                aboutArray = (try managedContext.fetch(fetchRequest) as? [AboutEntity])!
                
                if (aboutArray.count > 0 ){
                    if  (networkReachability?.isReachable)! {
                        DispatchQueue.global(qos: .background).async {
                            self.getNmoQAboutDetailsFromServer()
                        }
                    }
                    let aboutDict = aboutArray[0]
                    var descriptionArray = [String]()
                    
                    if let aboutInfoArray = (aboutDict.mobileDescRelation?.allObjects) as? [AboutDescriptionEntity] {
                        for _ in aboutInfoArray {
                            descriptionArray.append("")
                        }
                        for info in aboutInfoArray {
                            descriptionArray.remove(at: Int(info.id))
                            if let mobileDesc = info.mobileDesc {
                                descriptionArray.insert(mobileDesc, at: Int(info.id))
                            }
                        }
                    }
                    
                    var multimediaArray = [String]()
                    if let mutimediaInfoArray = (aboutDict.multimediaRelation?.allObjects) as? [AboutMultimediaFileEntity] {
                        for info in mutimediaInfoArray {
                            if let image = info.image {
                                multimediaArray.append(image)
                            }
                        }
                    }
                    
                    var downloadArray : [String] = []
                    if let downloadInfoArray = (aboutDict.downloadLinkRelation?.allObjects) as? [AboutDownloadLinkEntity] {
                        for info in downloadInfoArray {
                            if let downloadLink = info.downloadLink {
                                downloadArray.append(downloadLink)
                            }
                        }
                    }
                    
                    var nmoqTime: String?
                    var aboutTime: String? = nil
                    if(pageNameString == PageName2.museumAbout) {
                        aboutTime = aboutDict.openingTime!
                    } else if (pageNameString == PageName2.museumEvent){
                        nmoqTime = aboutDict.openingTime!
                    }
                    self.aboutDetailtArray.insert(CPMuseum(name: aboutDict.name, id: aboutDict.id, tourguideAvailable: aboutDict.tourguideAvailable, contactNumber: aboutDict.contactNumber, contactEmail: aboutDict.contactEmail, mobileLongtitude: aboutDict.mobileLongtitude, subtitle: aboutDict.subtitle, openingTime: aboutTime, mobileDescription: descriptionArray, multimediaFile: multimediaArray, mobileLatitude: aboutDict.mobileLatitude, tourGuideAvailability: aboutDict.tourGuideAvailability,multimediaVideo: nil, downloadable:downloadArray,eventDate:nmoqTime),at: 0)
                    
                    
                    if(aboutDetailtArray.count == 0){
                        if(self.networkReachability?.isReachable == false) {
                            self.showNoNetwork()
                        } else {
                            self.loadingView.showNoDataView()
                        }
                    }
                    self.setTopBarImage()
                    heritageDetailTableView.reloadData()
                } else {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        // self.loadingView.showNoDataView()
                        self.getNmoQAboutDetailsFromServer() //coreDataMigratio  solution
                    }
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}
