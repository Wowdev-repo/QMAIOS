//
//  EventViewController+CoreData.swift
//  QatarMuseums
//
//  Created by Exalture on 24/06/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation

extension EventViewController {
    //MARK: WebServiceCall
    func getEducationEventFromServer() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        // let dateString = toMillis()
        let getDate = toDayMonthYear()
        if ((getDate.day != nil) && (getDate.month != nil) && (getDate.year != nil)) {
            _ = CPSessionManager.sharedInstance.apiManager()?.request(QatarMuseumRouter.EducationEvent(["field_eduprog_repeat_field_date_value[value][month]" : getDate.month!, "field_eduprog_repeat_field_date_value[value][day]" : getDate.day!,"field_eduprog_repeat_field_date_value[value][year]" : getDate.year!,"cck_multiple_field_remove_fields" : "All","institution" : institutionType ?? "All","age" : ageGroupType ?? "All", "programe" : programmeType ?? "All"] )).responseObject { (response: DataResponse<EducationEventList>) -> Void in
                switch response.result {
                case .success(let data):
                    self.educationEventArray = data.educationEvent!
                    if (self.isLoadEventPage == true) {
                        self.saveOrUpdateEventCoredata()
                    }
                    else {
                        self.saveOrUpdateEducationEventCoredata()
                    }
                    self.eventCollectionView.reloadData()
                    self.loadingView.stopLoading()
                    self.loadingView.isHidden = true
                    if (self.educationEventArray.count == 0) {
                        self.loadingView.stopLoading()
                        self.loadingView.noDataView.isHidden = false
                        self.loadingView.isHidden = false
                        self.loadingView.showNoDataView()
                        let message = NSLocalizedString("NO_EVENTS",
                                                        comment: "Setting the content of the alert")
                        self.loadingView.noDataLabel.text = message
                    }
                case .failure( _):
                    var errorMessage: String
                    errorMessage = String(format: NSLocalizedString("NO_EVENTS",
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
    func toDayMonthYear() ->(day:String?, month:String?, year:String?) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let date = selectedDateForEvent
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        dateFormatter.dateFormat = "M"
        dateFormatter.locale = Locale(identifier: "en")
        let selectedMonth: String = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "d"
        let selectedDay: String = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "yyyy"
        let selectedYear: String = dateFormatter.string(from: date)
        return(selectedDay,selectedMonth,selectedYear)
    }
    func toMillis() ->String?  {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let timestamp = selectedDateForEvent.timeIntervalSince1970
        let dateString = String(timestamp)
        let delimiter = "."
        var token = dateString.components(separatedBy: delimiter)
        if token.count > 0 {
            return token[0]
        }
        return nil
    }
    func sundayOrWednesday() -> Bool {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let components = calendar!.components([.weekday], from: selectedDateForEvent)
        if ((components.weekday == 1) || (components.weekday == 4)) {
            return true
        } else {
            return false
        }
    }
    
    //MARK: Coredata Method
    func saveOrUpdateEducationEventCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (educationEventArray.count > 0) {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() { managedContext in
                    DataManager.saveEducationEvents(self.educationEventArray,
                                                    date: self.selectedDateForEvent,
                                                    managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.saveEducationEvents(self.educationEventArray,
                                                    date: self.selectedDateForEvent,
                                                    managedContext: managedContext)
                }
            }
        }
    }
    
    func saveOrUpdateEventCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if !educationEventArray.isEmpty {
            let appDelegate =  UIApplication.shared.delegate as? AppDelegate
            if #available(iOS 10.0, *) {
                let container = appDelegate!.persistentContainer
                container.performBackgroundTask() { managedContext in
                    DataManager.storeEvents(events: self.educationEventArray,
                                            for: self.selectedDateForEvent,
                                            managedContext: managedContext,
                                            language: Utils.getLanguage())
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.storeEvents(events: self.educationEventArray,
                                            for: self.selectedDateForEvent,
                                            managedContext: managedContext,
                                            language: Utils.getLanguage())
                }
            }
        }
    }
    
    
    
    func fetchEducationEventFromCoredata() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let managedContext = getContext()
        do {
            //            if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            var educationArray = [EducationEventEntity]()
            let dateID = Utils.uniqueDate(selectedDateForEvent)
            educationArray = DataManager.checkAddedToCoredata(entityName: "EducationEventEntity",
                                                              idKey: "dateId",
                                                              idValue: dateID,
                                                              managedContext: managedContext) as! [EducationEventEntity]
            
            if (educationArray.count > 0) {
                for educationInfo in educationArray {
                    self.educationEventArray.append(EducationEvent(entity: educationInfo))
                }
                
                if self.educationEventArray.isEmpty {
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
                self.eventCollectionView.reloadData()
            } else{
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
    
    func fetchEventFromCoredata() {
        let managedContext = getContext()
        _ = DataManager.fetchEvents(managedContext, for: selectedDateForEvent)
        
        do {
            let dateID = Utils.uniqueDate(selectedDateForEvent)
            let educationArray = DataManager.checkAddedToCoredata(entityName: "EventEntity",
                                                                  idKey: "dateId",
                                                                  idValue: dateID,
                                                                  managedContext: managedContext)  as! [EventEntity]
            
            if (educationArray.count > 0) {
                for i in 0 ... educationArray.count-1 {
                    var dateArray : [String] = []
                    let educationInfo = educationArray[i]
                    let educationInfoArray = (educationInfo.fieldRepeatDates?.allObjects) as! [DateEntity]
                    for i in 0 ... educationInfoArray.count-1 {
                        dateArray.append(educationInfoArray[i].date!)
                    }
                    var ageGrpArray : [String] = []
                    let ageInfoArray = (educationInfo.ageGroupRelation?.allObjects) as! [EventAgeGroupEntity]
                    for i in 0 ... ageInfoArray.count-1 {
                        ageGrpArray.append(ageInfoArray[i].ageGroup!)
                    }
                    var topicsArray : [String] = []
                    let topicsInfoArray = (educationInfo.assTopicRelation?.allObjects) as! [EventTopicsEntity]
                    for i in 0 ... topicsInfoArray.count-1 {
                        topicsArray.append(topicsInfoArray[i].associatedTopic!)
                    }
                    var startDateArray : [String] = []
                    let startDateInfoArray = (educationInfo.startDateRelation?.allObjects) as! [DateEntity]
                    for i in 0 ... startDateInfoArray.count-1 {
                        startDateArray.append(startDateInfoArray[i].date!)
                    }
                    var endDateArray : [String] = []
                    let endDateInfoArray = (educationInfo.endDateRelation?.allObjects) as! [DateEntity]
                    for i in 0 ... endDateInfoArray.count-1 {
                        endDateArray.append(endDateInfoArray[i].date!)
                    }
                    
                    
                    self.educationEventArray.insert(EducationEvent(itemId: educationArray[i].itemId, introductionText: educationArray[i].introductionText, register: educationArray[i].register, fieldRepeatDate: dateArray, title: educationArray[i].title, programType: educationArray[i].pgmType, mainDescription: educationArray[i].mainDesc, ageGroup: ageGrpArray, associatedTopics: topicsArray, museumDepartMent: educationArray[i].museumDepartMent, startDate: startDateArray, endDate: endDateArray), at: i)
                }
                if(educationEventArray.count == 0){
                    if(self.networkReachability?.isReachable == false) {
                        self.showNoNetwork()
                    } else {
                        self.loadingView.showNoDataView()
                    }
                }
                eventCollectionView.reloadData()
            } else {
                if(self.networkReachability?.isReachable == false) {
                    self.showNoNetwork()
                } else {
                    self.loadingView.showNoDataView()
                }
            }
        }
    }
}
