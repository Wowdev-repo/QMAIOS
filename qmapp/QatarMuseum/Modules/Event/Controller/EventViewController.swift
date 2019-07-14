//
//  EventViewController.swift
//  QatarMuseum
//
//  Created by Wakralab Software Labs on 07/06/18.
//  Copyright © 2018 Qatar Museums. All rights reserved.
//




import Crashlytics
import EventKit
import Firebase
import UIKit


class EventViewController: UIViewController,UIViewControllerTransitioningDelegate {
    
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
        
        calendarView.appearance.titleWeekendColor = UIColor.profilePink
        previousConstraint.constant = 30
        nextConstraint.constant = 30
        
        if ((LocalizationLanguage.currentAppleLanguage()) == ENG_LANGUAGE) {
            UserDefaults.standard.set(false, forKey: "Arabic")
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
            previousButton.setImage(UIImage(named: "previousImg"), for: .normal)
            nextButton.setImage(UIImage(named: "nextImg"), for: .normal)
            calendarView.locale = NSLocale.init(localeIdentifier: "en") as Locale
//            calendarView.identifier = NSCalendar.Identifier.gregorian.rawValue
            calendarView.appearance.titleFont = UIFont.init(name: "DINNextLTPro-Bold", size: 19)
            
//            calendarView.appearance.titleWeekendColor = UIColor.profilePink
//            previousConstraint.constant = 30
//            nextConstraint.constant = 30
            
        }
        else {
            //For RTL
            previousButton.setImage(UIImage(named: "nextImg"), for: .normal)
            nextButton.setImage(UIImage(named: "previousImg"), for: .normal)
            headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
            calendarView?.locale = Locale(identifier: "ar")
            self.calendarView.transform = CGAffineTransform(scaleX: -1, y: 1)
            calendarView.setCurrentPage(Date(), animated: false)
            UserDefaults.standard.set(true, forKey: "Arabic")
            calendarView.appearance.titleFont = UIFont.init(name: "DINNextLTArabic-Bold", size: 18)
            calendarView.appearance.weekdayFont =  UIFont.init(name: "DINNextLTArabic-Regular", size: 13)
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

    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(EVENT_VC, screenClass: screenClass)
    }
}

//MARK:- ReusableView methods
extension EventViewController: HeaderViewProtocol,comingSoonPopUpProtocol,
LoadingViewProtocol,EventPopUpProtocol {
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
    //MARK: Event popup delegate
    func eventCloseButtonPressed() {
        self.eventPopup.removeFromSuperview()
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
}

//MARK:- Calendar methods
extension EventViewController: FSCalendarDelegate,FSCalendarDataSource {
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
}

extension EventViewController: UIGestureRecognizerDelegate {
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
}
