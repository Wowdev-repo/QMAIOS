//
//  EventViewController.swift
//  QatarMuseum
//
//  Created by Exalture on 07/06/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Alamofire
import CoreData
import Crashlytics
import EventKit
import Firebase
import UIKit
import CocoaLumberjack

class EventViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, HeaderViewProtocol,FSCalendarDelegate,FSCalendarDataSource,UICollectionViewDelegateFlowLayout,EventPopUpProtocol,UIViewControllerTransitioningDelegate,UIGestureRecognizerDelegate,comingSoonPopUpProtocol,LoadingViewProtocol {
    
    @IBOutlet weak var eventCollectionView: UICollectionView!
    @IBOutlet weak var calendarView: FSCalendar!

    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var calendarInnerView: UIView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var listTitleLabel: UILabel!
    @IBOutlet weak var calendarLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previousConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingView: LoadingView!
    var effect:UIVisualEffect!
    var eventPopup : EventPopupView = EventPopupView()
    var selectedDateForEvent : Date = Date()
    var fromHome : Bool = false
    var fromSideMenu : Bool = false
    var isLoadEventPage : Bool = false
    var popupView : ComingSoonPopUp = ComingSoonPopUp()
    var educationEventArray: [EducationEvent] = []
    var selectedEvent: EducationEvent?
    var needToRegister : String? = "false"
    let networkReachability = NetworkReachabilityManager()
    let store = EKEventStore()
    let anyString = NSLocalizedString("ANYSTRING", comment: "ANYSTRING in the Filter page")
    var institutionType : String? = "All"
    var ageGroupType: String? = "All"
    var programmeType:String? = "All"

    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendarView, action: #selector(self.calendarView.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    override func viewDidLoad() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")

        super.viewDidLoad()
        registerNib()
        institutionType = anyString
        ageGroupType = anyString
        programmeType = anyString
        self.recordScreenView()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        setUpUiContent()
    }
    func registerNib() {
        let nib = UINib(nibName: "EventCellView", bundle: nil)
        eventCollectionView?.register(nib, forCellWithReuseIdentifier: "eventCellId")
    }
    func setUpUiContent() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        loadingView.isHidden = false
        loadingView.showLoading()
        loadingView.loadingViewDelegate = self
        headerView.settingsButton.isEnabled = false
        headerView.settingsButton.isUserInteractionEnabled = false
        self.educationEventArray = [EducationEvent]()
        headerView.headerViewDelegate = self
        headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        self.view.addGestureRecognizer(self.scopeGesture)
        listTitleLabel.font = UIFont.eventPopupTitleFont
        self.eventCollectionView.panGestureRecognizer.require(toFail: self.scopeGesture)
        calendarView.appearance.headerMinimumDissolvedAlpha = -1
        
        if (isLoadEventPage == true) {
            listTitleLabel.text = NSLocalizedString("CALENDAR_EVENT_TITLE", comment: "CALENDAR_EVENT_TITLE Label in the Event page")
            headerView.headerTitle.text = NSLocalizedString("CALENDAR_TITLE", comment: "CALENDAR_TITLE Label in the Event page")
            listTitleLabel.textColor = UIColor.eventlisBlue
            institutionType = anyString
            ageGroupType = anyString
            programmeType = anyString
            if  (networkReachability?.isReachable)! {
                self.getEducationEventFromServer()
            }
            else {
                self.fetchEventFromCoredata()

            }
        }
        else {
            listTitleLabel.text = NSLocalizedString("EDUCATION_EVENT_TITLE", comment: "EDUCATION_EVENT_TITLE Label in the Event page")
            headerView.headerTitle.text = NSLocalizedString("EDUCATIONCALENDAR_TITILE", comment: "EDUCATIONCALENDAR_TITILE Label in the Event page")
            listTitleLabel.textColor = UIColor.blackColor
            headerView.settingsButton.isHidden = false
            if  (networkReachability?.isReachable)! {
                self.getEducationEventFromServer()
            }
            else {
                self.fetchEducationEventFromCoredata()
            }
        }
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            UserDefaults.standard.set(false, forKey: "Arabic")
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
            previousButton.setImage(UIImage(named: "previousImg"), for: .normal)
            nextButton.setImage(UIImage(named: "nextImg"), for: .normal)
            calendarView.locale = NSLocale.init(localeIdentifier: "en") as Locale
            calendarView.identifier = NSCalendar.Identifier.gregorian.rawValue
            calendarView.appearance.titleFont = UIFont.init(name: "DINNextLTPro-Bold", size: 19)
            
            calendarView.appearance.titleWeekendColor = UIColor.profilePink
            previousConstraint.constant = 30
            nextConstraint.constant = 30
            
        }
        else {
           
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
            //For RTL
            calendarView?.locale = Locale(identifier: "ar")
            self.calendarView.transform = CGAffineTransform(scaleX: -1, y: 1)
            calendarView.setCurrentPage(Date(), animated: false)
            UserDefaults.standard.set(true, forKey: "Arabic")
            calendarView.appearance.titleFont = UIFont.init(name: "DINNextLTArabic-Bold", size: 18)
            calendarView.appearance.weekdayFont =  UIFont.init(name: "DINNextLTArabic-Regular", size: 13)
            previousButton.setImage(UIImage(named: "nextImg"), for: .normal)
            nextButton.setImage(UIImage(named: "previousImg"), for: .normal)
            calendarView.appearance.titleWeekendColor = UIColor.profilePink
            previousConstraint.constant = 30
            nextConstraint.constant = 30
        }
    }
    //For RTL
    func minimumDate(for calendar: FSCalendar) -> Date {
        return self.formatter.date(from: "2016-07-08")!
    }
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        if ((LocalizationLanguage.currentAppleLanguage()) == AR_LANGUAGE) {
            formatter.locale = NSLocale(localeIdentifier: "ar") as Locale?
        }
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: CollectionView delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightValue = UIScreen.main.bounds.height/100
        
        return CGSize(width: eventCollectionView.frame.width, height: heightValue*18)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return educationEventArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : EventCollectionViewCell = eventCollectionView.dequeueReusableCell(withReuseIdentifier: "eventCellId", for: indexPath) as! EventCollectionViewCell
        cell.viewDetailsBtnAction = {
            () in
            self.loadEventPopup(currentRow: indexPath.row)
                
            }
        if (indexPath.row % 2 == 0) {
            cell.cellBackgroundView?.backgroundColor = UIColor.eventCellAshColor
        }
        else {
            cell.cellBackgroundView.backgroundColor = UIColor.whiteColor
        }
        if (isLoadEventPage == true) {
            cell.setEventCellValues(event: educationEventArray[indexPath.row])
        }
        else {
            cell.setEducationCalendarValues(educationEvent: educationEventArray[indexPath.row])
        }
        loadingView.stopLoading()
        loadingView.isHidden = true
        return cell
    
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        loadEventPopup(currentRow: indexPath.row)
    }
    //MARK: header delegate
    func headerCloseButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.3
        if (fromSideMenu == true) {
            transition.type = kCATransitionFade
            transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            dismiss(animated: false, completion: nil)
        } else {
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            self.view.window!.layer.add(transition, forKey: kCATransition)
            if (fromHome == true) {
                let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController
                
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = homeViewController
            } else {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    @objc func filterButtonPressed() {
        let filterView =  self.storyboard?.instantiateViewController(withIdentifier: "filterVcId") as! FilterViewController
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_filter_event_item,
            AnalyticsParameterItemName: "",
            AnalyticsParameterContentType: "cont"
            ])
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(filterView, animated: false, completion: nil)
    }
    func loadEventPopup(currentRow: Int) {
        eventPopup.tag = 0
        eventPopup  = EventPopupView(frame: self.view.frame)
        eventPopup.eventPopupDelegate = self
        selectedEvent = educationEventArray[currentRow]
        needToRegister = educationEventArray[currentRow].register
        if(needToRegister == "true") {
            let buttonTitle = NSLocalizedString("EDUCATION_POPUP_BUTTON_TITLE", comment: "POPUP_ADD_BUTTON_TITLE  in the popup view")
            eventPopup.addToCalendarButton.setTitle(buttonTitle, for: .normal)
            eventPopup.addToCalendarButton.backgroundColor = UIColor.lightGrayColor
            eventPopup.addToCalendarButton.setTitleColor(UIColor.whiteColor, for: .normal)
            eventPopup.addToCalendarButton.isEnabled = false
            
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_event_popup,
                AnalyticsParameterItemName: buttonTitle ,
                AnalyticsParameterContentType: "cont"
                ])
        }
        else {
            let buttonTitle = NSLocalizedString("POPUP_ADD_BUTTON_TITLE", comment: "POPUP_ADD_BUTTON_TITLE  in the popup view")
            eventPopup.addToCalendarButton.setTitle(buttonTitle, for: .normal)
        }
        if (isLoadEventPage == true) {
            let title = educationEventArray[currentRow].title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
            eventPopup.eventTitle.text = title?.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
            var mainDesc = String()
            if educationEventArray[currentRow].mainDescription != nil {
                mainDesc = educationEventArray[currentRow].mainDescription!.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#", with: "", options: .regularExpression, range: nil)
                mainDesc =  mainDesc.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
                eventPopup.eventDescription.text = mainDesc
                
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_event_popup,
                    AnalyticsParameterItemName: eventPopup.eventTitle.text ?? "",
                    AnalyticsParameterContentType: "cont"
                    ])
            }
        }
        else {
            let title = educationEventArray[currentRow].title?.replacingOccurrences(of: "<[^>]+>|&nbsp;", with: "", options: .regularExpression, range: nil).uppercased()
            eventPopup.eventTitle.text = title?.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
            var mainDesc = String()
            if educationEventArray[currentRow].mainDescription != nil {
                mainDesc = educationEventArray[currentRow].mainDescription!.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#", with: "", options: .regularExpression, range: nil)
                mainDesc = mainDesc.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
                eventPopup.eventDescription.text = mainDesc
            }
            
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_event_popup,
                AnalyticsParameterItemName: eventPopup.eventTitle.text ?? "",
                AnalyticsParameterContentType: "cont"
                ])
        }
        self.view.addSubview(eventPopup)
     
        
    }
  
    //MARK: Event popup delegate
    func eventCloseButtonPressed() {
        self.eventPopup.removeFromSuperview()
    }
    func addToCalendarButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (eventPopup.tag == 0) {
            if(needToRegister == "true") {
                self.eventPopup.removeFromSuperview()
                popupView  = ComingSoonPopUp(frame: self.view.frame)
                popupView.comingSoonPopupDelegate = self
                popupView.loadPopup()
                self.view.addSubview(popupView)
            }
            else {
                self.eventPopup.removeFromSuperview()
                let calendar = Calendar.current
                var startDt = Date()
                var endDt = Date()
                if((selectedEvent?.startDate?.count)! > 0) {
                    let dateArray = selectedEvent?.startDate![0].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil).components(separatedBy: " ")
                    if((dateArray?.count)! > 0) {
                        
                        let time = dateArray![(dateArray?.count)!-1]
                        let timeArray = time.components(separatedBy: ":")
                        if(timeArray.count > 1) {
                            let hr = Int(timeArray[0])
                            let min = Int(timeArray[1])
                            startDt = calendar.date(bySettingHour:hr!, minute: min!, second: 0, of: selectedDateForEvent)!
                        } else if(timeArray.count > 0) {
                            let hr = Int(timeArray[0])
                            startDt = calendar.date(bySettingHour:hr!, minute: 0, second: 0, of: selectedDateForEvent)!
                        }
                    }
            }
                if((selectedEvent?.endDate?.count)! > 0) {
                    let dateArray2 = selectedEvent?.endDate![0].replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#039;", with: "", options: .regularExpression, range: nil).components(separatedBy: " ")
                    if((dateArray2?.count)! > 0) {
                        
                        let time = dateArray2![(dateArray2?.count)!-1]
                        let timeArray = time.components(separatedBy: ":")
                        if(timeArray.count > 1) {
                            let hr = Int(timeArray[0])
                            let min = Int(timeArray[1])
                            endDt = calendar.date(bySettingHour: hr!, minute: min!, second: 0, of: selectedDateForEvent)!
                        } else if(timeArray.count > 0) {
                            let hr = Int(timeArray[0])
                            endDt = calendar.date(bySettingHour: hr!, minute: 0, second: 0, of: selectedDateForEvent)!
                        }

                    }
            }

                self.addEventToCalendar(title:  (selectedEvent?.title)!, description: selectedEvent?.mainDescription, startDate: startDt, endDate: endDt)
                
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: FirebaseAnalyticsEvents.tapped_add_to_calender_item,
                    AnalyticsParameterItemName: selectedEvent?.title ?? "",
                    AnalyticsParameterContentType: "cont"
                    ])
                
            }
        }
        else {
            self.eventPopup.removeFromSuperview()
            let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(openSettingsUrl!)
        }

        
    }
   
    func closeButtonPressed() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.popupView.removeFromSuperview()
    }
    func addEventToCalendar(title: String, description: String?, startDate: Date?, endDate: Date?, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let eventStore = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .event)
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (granted) && (error == nil) {
                    DispatchQueue.main.async {
                    let event = EKEvent.init(eventStore: self.store)
                        let eventTitle = title.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#", with: "", options: .regularExpression, range: nil)
                    event.title = eventTitle.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
                    event.calendar = self.store.defaultCalendarForNewEvents
                    event.startDate = startDate
                    event.endDate = endDate
                    let notes = description?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#", with: "", options: .regularExpression, range: nil)
                    event.notes = notes?.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
                    
                    do {
                        try self.store.save(event, span: .thisEvent)
                        self.view.hideAllToasts()
                        let eventAddedMessage =  NSLocalizedString("EVENT_ADDED_MESSAGE", comment: "EVENT_ADDED_MESSAGE")
                        self.view.makeToast(eventAddedMessage)
                    } catch let e as NSError {
                        completion?(false, e)
                        return
                    }
                    completion?(true, nil)
                }
                } else {
                    completion?(false, error as NSError?)
                }
            })
        case EKAuthorizationStatus.authorized:
            let event = EKEvent.init(eventStore: self.store)
            let eventTitle = title.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#", with: "", options: .regularExpression, range: nil)
            event.title = eventTitle.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
            event.calendar = self.store.defaultCalendarForNewEvents
            event.startDate = startDate
            event.endDate = endDate
            let notes = description?.replacingOccurrences(of: "<[^>]+>|&nbsp;|&|#", with: "", options: .regularExpression, range: nil)
            event.notes = notes?.replacingOccurrences(of: "&#039;", with: "'", options: .regularExpression, range: nil)
            do {
                try self.store.save(event, span: .thisEvent)
                self.view.hideAllToasts()
                let eventAddedMessage =  NSLocalizedString("EVENT_ADDED_MESSAGE", comment: "EVENT_ADDED_MESSAGE")
                self.view.makeToast(eventAddedMessage)
            } catch _ as NSError {
                return
            }
        case EKAuthorizationStatus.denied, EKAuthorizationStatus.restricted:
            
            self.loadPermissionPopup()
        default:
            break
        }
       
    }
    
    // MARK:- UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.eventCollectionView.contentOffset.y <= -self.eventCollectionView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendarView.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
    //MARK: FSCalendar delegate
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        calendarHeight.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        loadingView.isHidden = false
        loadingView.showLoading()
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
            
        }
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            self.educationEventArray = []
            self.eventCollectionView.reloadData()
            group.leave()
        }
        selectedDateForEvent = date
        group.notify(queue: .main) {
            if (self.isLoadEventPage == true) {
                if  (self.networkReachability?.isReachable)! {
                    self.institutionType = "All"
                    self.ageGroupType = "All"
                    self.programmeType = "All"
                    self.getEducationEventFromServer()
                }
                else {
                    self.fetchEventFromCoredata()
                    
                }
            }
            else {
                if  (self.networkReachability?.isReachable)! {
                    self.getEducationEventFromServer()
                }
                else {
                    self.fetchEducationEventFromCoredata()
                }
            }
        }
    }
    func calendarCurrentMonthDidChange(_ calendar: FSCalendar) {
        
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        return UIColor.red
    }
    
    @IBAction func previoudDateSelected(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let _calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.month = -1 // For prev button
            calendarView.currentPage = _calendar.date(byAdding: dateComponents, to: calendarView.currentPage)!
            calendarView.setCurrentPage(calendarView.currentPage, animated: true)// calender is object of FSCalendar
        }
        else {
            let _calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.month = 1 // For next button
            calendarView.currentPage = _calendar.date(byAdding: dateComponents, to: calendarView.currentPage)!
            calendarView.setCurrentPage(calendarView.currentPage, animated: true)// calender is object of FSCalendar
        }
    }
    
    @IBAction func nextDateSelected(_ sender: UIButton) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            let _calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.month = 1 // For next button
            calendarView.currentPage = _calendar.date(byAdding: dateComponents, to: calendarView.currentPage)!
            calendarView.setCurrentPage(calendarView.currentPage, animated: true)// calender is object of FSCalendar
        }
        else {
            let _calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.month = -1 // For prev button
            calendarView.currentPage = _calendar.date(byAdding: dateComponents, to: calendarView.currentPage)!
            calendarView.setCurrentPage(calendarView.currentPage, animated: true)// calender is object of FSCalendar
        }
        
    }
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
                                            managedContext: managedContext)
                }
            } else {
                let managedContext = appDelegate!.managedObjectContext
                managedContext.perform {
                    DataManager.storeEvents(events: self.educationEventArray,
                                            for: self.selectedDateForEvent,
                                            managedContext: managedContext)
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
    
    func showNodata() {
        var errorMessage: String
        errorMessage = String(format: NSLocalizedString("NO_RESULT_MESSAGE",
                                                        comment: "Setting the content of the alert"))
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoDataView()
        self.loadingView.noDataLabel.text = errorMessage
    }
    //MARK: Event Popup Delegate
    func loadPermissionPopup() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        eventPopup  = EventPopupView(frame: self.view.frame)
        eventPopup.eventPopupDelegate = self
        eventPopup.eventTitle.text = NSLocalizedString("PERMISSION_TITLE", comment: "PERMISSION_TITLE  in the popup view")
        eventPopup.eventDescription.text = NSLocalizedString("CALENDAR_PERMISSION", comment: "CALENDAR_PERMISSION  in the popup view")
        eventPopup.addToCalendarButton.setTitle(NSLocalizedString("SIDEMENU_SETTINGS_LABEL", comment: "SIDEMENU_SETTINGS_LABEL  in the popup view"), for: .normal)
        eventPopup.tag = 1
        self.view.addSubview(eventPopup)
    }
    
    //MARK: LoadingView Delegate
    func tryAgainButtonPressed() {
        if  (networkReachability?.isReachable)! {
            self.getEducationEventFromServer()
        }
    }
    func showNoNetwork() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        self.loadingView.stopLoading()
        self.loadingView.noDataView.isHidden = false
        self.loadingView.isHidden = false
        self.loadingView.showNoNetworkView()
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(EVENT_VC, screenClass: screenClass)
    }
}
