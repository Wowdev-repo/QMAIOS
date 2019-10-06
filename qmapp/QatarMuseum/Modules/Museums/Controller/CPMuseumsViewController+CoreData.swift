//
//  CPMuseumsViewController+CoreData.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation

extension CPMuseumsViewController {
    //MARK: WebServiceCall
    func getMuseumDataFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(CPQatarMuseumRouter.LandingPageMuseums(["nid": museumId ?? 0]))
            .responseObject { [weak self] (response: DataResponse<Museums>) -> Void in
                switch response.result {
                case .success(let data):
                    if(self?.museumArray.count == 0) {
                        self?.museumArray = data.museum!
                    }
                    if let count = self?.museumArray.count, count > 0 {
                        self?.setImageArray(imageArray: self?.museumArray[0].multimediaFile)
                        self?.saveOrUpdateAboutCoredata(aboutDetailtArray: data.museum)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    //MARK: About CoreData
    func saveOrUpdateAboutCoredata(aboutDetailtArray:[CPMuseum]?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if ((aboutDetailtArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    CPDataManager.saveAboutDetails(managedContext: managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: self.fromHomeBanner,
                                                 language: CPUtils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    CPDataManager.saveAboutDetails(managedContext : managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: self.fromHomeBanner,
                                                 language: CPUtils.getLanguage())
                }
            }
        }
    }
    
    func fetchMuseumLandingImagesFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.museumArray = CPDataManager.fetchMuseumLandingImages(museumId!)
        if self.museumArray.isEmpty, let reachable = networkReachability?.isReachable, reachable {
            DispatchQueue.global(qos: .background).async {
                self.getMuseumDataFromServer()
            }
        } else {
            guard self.museumArray.count > 0 else {
                return;
            }
            self.setImageArray(imageArray: self.museumArray[0].multimediaFile)
        }
    }
}
