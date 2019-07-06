//
//  MuseumsViewController+CoreData.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation

extension MuseumsViewController {
    //MARK: WebServiceCall
    func getMuseumDataFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        _ = CPSessionManager.sharedInstance.apiManager()?
            .request(QatarMuseumRouter.LandingPageMuseums(["nid": museumId ?? 0]))
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
    func saveOrUpdateAboutCoredata(aboutDetailtArray:[Museum]?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        if ((aboutDetailtArray?.count)! > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() {(managedContext) in
                    DataManager.saveAboutDetails(managedContext: managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: self.fromHomeBanner,
                                                 language: Utils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.saveAboutDetails(managedContext : managedContext,
                                                 aboutDetailtArray: aboutDetailtArray,
                                                 fromHomeBanner: self.fromHomeBanner,
                                                 language: Utils.getLanguage())
                }
            }
        }
    }
    
    func fetchMuseumLandingImagesFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function)")
        self.museumArray = DataManager.fetchMuseumLandingImages(museumId!)
        if self.museumArray.isEmpty, let reachable = networkReachability?.isReachable, reachable {
            DispatchQueue.global(qos: .background).async {
                self.getMuseumDataFromServer()
            }
        } else {
            self.setImageArray(imageArray: self.museumArray[0].multimediaFile)
        }
    }
}
