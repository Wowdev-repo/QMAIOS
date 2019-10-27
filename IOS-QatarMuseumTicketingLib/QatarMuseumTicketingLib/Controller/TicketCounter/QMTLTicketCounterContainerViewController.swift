//
//  QMTLDateChooserViewController.swift
//  QMLibPreProduction
//
//  Created by Jeeva.S.K on 19/02/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import SwiftyJSON
import FSPagerView
import Toast_Swift
import Reachability

class QMTLTicketCounterContainerViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,QMTLCalendarViewControllerDelegate,QMTLGuestUserViewControllerDelegate,QMTLCartTableTableViewControllerDelegate, FSPagerViewDelegate,FSPagerViewDataSource,QMTLTabViewControllerDelegate,PaymentGatewayViewControllerDelegate, APIServiceResponse, APIServiceProtocolForConnectionError,MuseumSelectionDelegate {
    
    //MARK:- Declerations
    
    let additionalSafeAreaInset = 20
    
    var apiServices = QMTLAPIServices()
    var selectedDate = Date()
    
    var tabViewController = QMTLTabViewController()
    
    var subViewControllers = [UIViewController]()
    
    var toastStyle = ToastStyle()
    
    var listDivisionsResponseJsonValue : JSON = []
    var findExpositionResponseJSONValue : JSON = []
    var expositionPeriodResponseJSONValue : JSON = []
    var lockBasketResponseJsonValue : JSON = []
    var recalculateBasketResponseJsonValue : JSON = []
    var validateBasketResponseJsonValue : JSON = []
    
    var divisionsList = [Divisions]()
    var expositionList = [Exposition]()
    var selectedExposition = Exposition()
    var expositionPeriodsList = [ExpositionPeriods]()
    
    var calendarViewController = QMTLCalendarViewController()
    var ticketCounterTableViewController = QMTLTicketCounterTableViewController()
    var timePickerViewController = QMTLTimePickerViewController()
    var cartTableViewController = QMTLCartTableTableViewController()
    var paymentGatewayViewController = PaymentGatewayViewController()
    var museumListViewController = MuseumListViewController()
    
    var selectedExpositionIndex = 0
    var selectedPageIndex = 0
    var divisionSelectedIndex = 0
    
    var paymentId = ""
    var anonymousUserId = ""
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var divisionListPagerViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var infoContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftArrowImg : UIImageView!
    @IBOutlet weak var rightArrowImg : UIImageView!
    
    @IBOutlet weak var firstPageIndicator : UILabel!
    @IBOutlet weak var secondPageIndicator : UILabel!
    @IBOutlet weak var thirdPageIndicator : UILabel!
    @IBOutlet weak var firstPageCompletedIndicator : UILabel!
    @IBOutlet weak var secondPageCompletedIndicator : UILabel!
    
    @IBOutlet weak var errinfoLbl : UILabel!
    @IBOutlet weak var headerLblView : UILabel!
    //@IBOutlet weak var dateLblView: UILabel!
    @IBOutlet weak var infoLbl1 : UILabel!
    @IBOutlet weak var infoLbl2 : UILabel!
    
    @IBOutlet weak var infoView : UIView!
    
    @IBOutlet weak var subViewListCollectionView: UICollectionView!
    @IBOutlet var nxtBtn: UIButton!
    @IBOutlet weak var divisionListPagerView: FSPagerView! {
        didSet {
            self.divisionListPagerView.register(UINib(nibName:QMTLConstants.NibName.divisionListCollectionViewCell, bundle: QMTLSingleton.sharedInstance.bundle), forCellWithReuseIdentifier: QMTLConstants.CellId.divisionListCollectionViewCell)
        }
    }
    //MARK:- Controller Defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = CGFloat(additionalSafeAreaInset)
        }
        self.infoLbl1.font = UIFont.appBoldFontWith(size: 17)
        
        apiServices.delegateForAPIServiceResponse = self
        apiServices.delegateForConnectionError = self
        
        divisionListPagerView.transformer = FSPagerViewTransformer(type:.linear)
        divisionListPagerView.itemSize = CGSize(width: self.view.frame.size.width - 70, height: 60)
        divisionListPagerView.isInfinite = true
        divisionListPagerView.interitemSpacing = 1

        selectedDate = Date()
        
        setUpView()
        getInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.qmtlTabViewControllerDelegate = self
        tabViewController.topTabBarView.myProfileBtn.isHidden = false
        tabViewController.topTabBarView.backBtn.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if selectedPageIndex == 1 {
            ticketCounterTableViewController.setUpView()
        }
    }
    
    
    override func viewDidLayoutSubviews() {
    }
    
    func setUpView(){
        
        localizationSetup()
        
        headerLblView.isHidden = true
        nxtBtn.isEnabled = false
        errinfoLbl.isHidden = true
        
        firstPageIndicator.layer.cornerRadius = firstPageIndicator.frame.size.width/2
        secondPageIndicator.layer.cornerRadius = secondPageIndicator.frame.size.width/2
        thirdPageIndicator.layer.cornerRadius = thirdPageIndicator.frame.size.width/2
        firstPageIndicator.text = self.getLocalizedStr(str: "1")
        secondPageIndicator.text = self.getLocalizedStr(str: "2")
        thirdPageIndicator.text = self.getLocalizedStr(str: "3")
        
        indicatorSelector(pageNumber: 0)
        
        toastStyle.messageColor = .white
        toastStyle.backgroundColor = .darkGray
        
        infoLbl2.decideTextDirection()
        
        let leftTap = UITapGestureRecognizer(target: self, action: #selector(self.leftArrowTapAction(sender:)))
        leftArrowImg.addGestureRecognizer(leftTap)
        
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(self.rightArrowTapAction(sender:)))
        rightArrowImg.addGestureRecognizer(rightTap)
    }
    
    //MARK:- API Service Callers
    
    func getInitialData() {
        apiServices.getDivisionList(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.listDivisions, view: self.view)
        
    }
    
    func getExpostionPeriod(expostion : Exposition, from : String, until : String){
        let searchCriteria = [QMTLConstants.ExpostionPeriodsKeys.expositionId:expostion.id,QMTLConstants.ExpostionPeriodsKeys.from:from,QMTLConstants.ExpostionPeriodsKeys.until:until]
        apiServices.getExpositionPeriods(searchCriteria: searchCriteria, serviceFor: QMTLConstants.ServiceFor.findExpositionPeriod, view: self.view)
    }
    
    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("Ticket Counter Error ResponseJSON = \(String(describing: errInfo))")
        
        if selectedPageIndex > 0 {
            selectedPageIndex = selectedPageIndex - 1
        }
        
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.findExposition:
                findExpositionResponseJSONValue = json
                setUpExpositionList()
                break
            case QMTLConstants.ServiceFor.findExpositionPeriod:
                expositionPeriodResponseJSONValue = json
                setUpExpositionPeriods()
                break
            case QMTLConstants.ServiceFor.listDivisions:
                listDivisionsResponseJsonValue = json
                setUpDivisionList()
                break
            case QMTLConstants.ServiceFor.lockBasketItems:
                lockBasketResponseJsonValue = json
                checkLockBasket()
                break
            case QMTLConstants.ServiceFor.reCalculateBasket:
                recalculateBasketResponseJsonValue = json
                setUpRecalculateBasket()
                break
            case QMTLConstants.ServiceFor.validateBasket :
                validateBasketResponseJsonValue = json
                break
            default:
                break
            }
        }
    }
    
    //MARK:-
    
    func setUpDivisionList(){
        let divisionArr = listDivisionsResponseJsonValue[QMTLConstants.ListDivisionKeys.divisions].arrayValue
        
        for division in divisionArr {
            
            let address = division[QMTLConstants.ListDivisionKeys.address].dictionaryValue
            let box = address[QMTLConstants.ListDivisionKeys.box]?.string
            
            if box == "N" {
                continue
            }
            
            let divisionObj = Divisions()
            divisionObj.id = division[QMTLConstants.ListDivisionKeys.id].stringValue
            divisionObj.name = division[QMTLConstants.ListDivisionKeys.name].stringValue
            
            divisionsList.append(divisionObj)
        }
        
        if divisionsList.count > 0 {
            divisionListPagerView.reloadData()
            apiServices.getExpositionList(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.findExposition, view: self.view)
        }
    }
    
    func setUpExpositionList(){
        
        let expositionsArr = findExpositionResponseJSONValue[QMTLConstants.ExpositionsKeys.expositions].arrayValue
        
        for exposition in expositionsArr {
            
            let code = exposition[QMTLConstants.ExpositionsKeys.code].stringValue
            let id = exposition[QMTLConstants.ExpositionsKeys.id].stringValue
            let divisionId = exposition[QMTLConstants.ExpositionsKeys.divisionId].stringValue
            let name = exposition[QMTLConstants.ExpositionsKeys.name].stringValue
            let prices = exposition[QMTLConstants.ExpositionsKeys.prices].arrayValue
            let startDate = exposition[QMTLConstants.ExpositionsKeys.startDate].stringValue
            let endDate = exposition[QMTLConstants.ExpositionsKeys.endDate].stringValue
            
            let expositionObj = Exposition()
            
            expositionObj.code = code
            expositionObj.id = id
            expositionObj.divisionId = divisionId
            expositionObj.name = name
            expositionObj.prices = prices
            expositionObj.startDate = startDate
            expositionObj.endDate = endDate
            
            expositionList.append(expositionObj)
        }
        
        tabViewController.topTabBarView.myProfileBtn.alpha = 0.5
        tabViewController.topTabBarView.backBtn.alpha = 0.5
        tabViewController.topTabBarView.isUserInteractionEnabled = false
        
        museumListViewController = storyboard!.instantiateViewController(withIdentifier: "MuseumListViewController") as! MuseumListViewController
        museumListViewController.museumArrayList = divisionsList
        museumListViewController.museumSelectionDelegate = self
        museumListViewController.providesPresentationContextTransitionStyle = true
        museumListViewController.definesPresentationContext = true
        museumListViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        museumListViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(museumListViewController, animated: true, completion: nil)
        
        if expositionList.count > 0 {
            setupSubViews()
            nxtBtn.isEnabled = true
        }
    }
    
    func setupSubViews(){
        
        calendarViewController = storyboard!.instantiateViewController(withIdentifier: QMTLConstants.StoryboardControllerID.calendarViewController) as! QMTLCalendarViewController
        calendarViewController.qmtlCalendarViewControllerDelegate = self
        
        ticketCounterTableViewController = storyboard!.instantiateViewController(withIdentifier: QMTLConstants.StoryboardControllerID.ticketCounterTableViewController) as! QMTLTicketCounterTableViewController
        
        timePickerViewController = storyboard!.instantiateViewController(withIdentifier: QMTLConstants.StoryboardControllerID.timePickerViewController) as! QMTLTimePickerViewController
        
        cartTableViewController = storyboard!.instantiateViewController(withIdentifier: QMTLConstants.StoryboardControllerID.cartTableViewController) as! QMTLCartTableTableViewController
        cartTableViewController.qmtlCartTableTableViewControllerDelegate = self
        
        subViewControllers.append(calendarViewController)
        subViewControllers.append(ticketCounterTableViewController)
        subViewControllers.append(cartTableViewController)
        //subViewControllers.append(timePickerViewController)        
        
        subViewListCollectionView.reloadData()
        selectedPageIndex = 0
        scrollToSelectedPage()
        
        setExpositionForDivision()
        
    }
    
    func setExpositionForDivision(){
        
        let findExpositionForDivision = getExpositionObjForDivision(Division: divisionsList[divisionSelectedIndex])
        print("Division Name = \(divisionsList[divisionSelectedIndex].name)")
        if findExpositionForDivision.0 {
            selectedExposition = findExpositionForDivision.1
            print("selectedExposition id = \(selectedExposition.id)")
            print("startDate = \(selectedExposition.startDate)")
            print("endDate = \(selectedExposition.endDate)")
            
            calendarViewController.startDate = stringToDate(dateStr: selectedExposition.startDate)
            calendarViewController.endDate = stringToDate(dateStr: selectedExposition.endDate)
            calendarViewController.reloadCalendarView()
            
            errinfoLbl.isHidden = true
            subViewListCollectionView.isHidden = false
            nxtBtn.isHidden = false
            
        }else{
            
            errinfoLbl.isHidden = false
            subViewListCollectionView.isHidden = true
            nxtBtn.isHidden = true
        }
        
    }
    
    func getExpositionObjForDivision(Division division: Divisions) -> (Bool,Exposition) {
        
        var exposition = Exposition()
        var isExpositionAvail = false
        
        for obj in expositionList {
            if obj.divisionId == division.id {
                isExpositionAvail = true
                exposition = obj
                break
            }
        }
        
        return (isExpositionAvail,exposition)
    }
    
    func stringToDate(dateStr : String) -> Date {
        var date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        date = dateFormatter.date(from: dateStr) ?? Date()
        
        return date
    }
    
    func setUpExpositionPeriods(){
        
        let expositionPeriodArr = expositionPeriodResponseJSONValue[QMTLConstants.ExpostionPeriodsKeys.expositionPeriods].arrayValue
        
        for expositionPeriod in expositionPeriodArr {
            let expositionPeriodObj = ExpositionPeriods()
            expositionPeriodObj.expositionId = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.expositionId].stringValue
            expositionPeriodObj.finalSubscriptionDate = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.finalSubscriptionDate].stringValue
            expositionPeriodObj.from = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.from].stringValue
            expositionPeriodObj.id = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.id].stringValue
            expositionPeriodObj.occupancy = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.occupancy].stringValue
            expositionPeriodObj.current = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.current].intValue
            expositionPeriodObj.maximum = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.maximum].intValue
            expositionPeriodObj.remaining = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.remaining].intValue
            expositionPeriodObj.controlType = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.expositionId].stringValue
            expositionPeriodObj.maxVisitorsPerGroup = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.controlType].intValue
            expositionPeriodObj.until = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.until].stringValue
            expositionPeriodObj.finalSubscriptionDateBo = expositionPeriod[QMTLConstants.ExpostionPeriodsKeys.finalSubscriptionDateBo].stringValue
            
            expositionPeriodsList.append(expositionPeriodObj)
        }
        
        if expositionPeriodsList.count > 0 {
            //timePickerViewController.expositionPeriodsList = expositionPeriodsList
            //timePickerViewController.timePickerCollectionView.reloadData()
            
            QMTLSingleton.sharedInstance.ticketInfo.expositionPeriod = expositionPeriodsList[0]
            
            QMTLSingleton.sharedInstance.ticketInfo.division = divisionsList[divisionSelectedIndex]
            QMTLSingleton.sharedInstance.ticketInfo.expositions = selectedExposition
            QMTLSingleton.sharedInstance.ticketInfo.date = selectedDate
            
            ticketCounterTableViewController.exposition = selectedExposition
            ticketCounterTableViewController.setUpView()
            
            indicatorSelector(pageNumber: selectedPageIndex)
            scrollToSelectedPage()
            
        }else{
            
            if selectedPageIndex > 0{
                selectedPageIndex = selectedPageIndex - 1
            }
            
            showToast(message: QMTLConstants.ErrorMessage.periodsNotAvail)
        }
        
    }
    
    func checkLockBasket(){
        let lockBasketResult = lockBasketResponseJsonValue[QMTLConstants.BasketKey.lockBasketResult].dictionaryValue
        if lockBasketResult[QMTLConstants.BasketKey.isLocked]?.boolValue ?? false {
            let basketItems = lockBasketResult["basketItems"]?.arrayValue
            let basketItem = basketItems?[0]
            //QMTLSingleton.sharedInstance.userInfo.id = basketItem![QMTLConstants.BasketKey.customerID].stringValue
            let lockTicket = basketItem?[QMTLConstants.BasketKey.lockTicket].dictionaryValue
            let lockBasket = LockBasket()
            lockBasket.id = lockTicket?["id"]?.stringValue ?? ""
            lockBasket.expirationTime = lockTicket?[QMTLConstants.BasketKey.expirationTime]?.stringValue ?? ""
            print("lockBasket.expirationTime \(lockBasket.expirationTime)")
            lockBasket.isLocked = true
            QMTLSingleton.sharedInstance.ticketInfo.lockBasket = lockBasket
            
            //cartTableViewController.prices =
            //cartTableViewController.setupViews()
            //selectedPageIndex = selectedPageIndex + 1
            //indicatorSelector(pageNumber: selectedPageIndex)
            //scrollToSelectedPage()
            //cartTableViewController.callRecalculateBasket()
            
            apiServices.recalculateBasket(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.reCalculateBasket, view: self.view)
            
        }else{
            QMTLSingleton.sharedInstance.ticketInfo.lockBasket.isLocked = false
            
            let validationResult = lockBasketResult[QMTLConstants.BasketKey.validationResult]?.dictionaryValue
            if !(validationResult?[QMTLConstants.BasketKey.isValid]?.boolValue ?? false) {
                let msg = validationResult?[QMTLConstants.BasketKey.message]!.stringValue
                
                selectedPageIndex = selectedPageIndex - 1
                indicatorSelector(pageNumber: selectedPageIndex)
                scrollToSelectedPage()
                
                showToast(message: msg ?? "Cannot lock the ticket, Please try again" )
            }
        }
    }
    
    func setUpRecalculateBasket(){
        
        let basket = recalculateBasketResponseJsonValue["basket"].dictionaryValue
        QMTLSingleton.sharedInstance.userInfo.anonymousUserId = basket["customerId"]!.stringValue
                
        anonymousUserId = QMTLSingleton.sharedInstance.userInfo.id
        
        //apiServices.validateBasket(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.validateBasket, view: self.view)
    }
    
    func navToPaymentGateway(){
        var totalAmount = 0
        
        let prices = QMTLSingleton.sharedInstance.ticketInfo.prices
        for price in prices {
            totalAmount = totalAmount + price.totalAmount
        }
        
        if totalAmount > 0 {
            self.performSegue(withIdentifier: QMTLConstants.Segue.seguePaymentGatewayViewControllerFromTicketCounter, sender: nil)
        }else{
            paymentSucceeded(paymentId: "")
        }
    }
    
    //MARK:- Show Toast
    
//    func showToast(message : String){
//        self.view.makeToast(getLocalizedStr(str: message), duration: 2.0, position: .center, style: toastStyle)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//            self.view.hideAllToasts()
//        })
//    }
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height/2 - 17, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.darkGray
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = getLocalizedStr(str: message)
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    //MARK:- Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subViewControllers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        /*
        guard case let cell as DeviceDetailContainerCollectionViewCell = cell else {
            return
        }
        
        var rect = cell.subView.frame
        rect.origin.x = 0
        rect.origin.y = 0
        rect.size.height = cell.containerView.frame.size.height
        rect.size.width = cell.containerView.frame.size.width
        cell.subView.frame = rect
        
        cell.contentView.addSubview(cell.subView)
         */
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        let cellID = QMTLConstants.CellId.subViewListCollectionViewCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        
        let view = cell.viewWithTag(101)
        
        let subView = subViewControllers[indexPath.row].view
        subView?.frame = (view?.frame)!
        view?.addSubview(subView!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width, height: (collectionView.frame.size.height))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        indicatorSelector(pageNumber: indexPath.row)
    }
    
    //MARK:- Indicator selector
    
    func indicatorSelector(pageNumber : Int) {
        
        let selectedColor = UIColor(red: 255.0/255.0, green: 193.0/255.0, blue: 64.0/255.0, alpha: 1.0)
        
        switch pageNumber {
        case 0:
            nxtBtn.setTitle(getLocalizedStr(str: "Next") , for: .normal)
            
               if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
                nxtBtn.titleLabelFont =  UIFont.init(name: "DINNextLTPro-Bold", size: 18)
                //nxtBtn.setTitle ("Next", for: .normal);
            }
            else{
               nxtBtn.titleLabelFont = UIFont.init(name: "DINNextLTArabic-Bold", size: 18)
               // nxtBtn.setTitle ("التالي", for: .normal);
               // nxtBtn.setTitle ("Next", for: .normal);
            }

            firstPageIndicator.backgroundColor = selectedColor
            secondPageIndicator.backgroundColor = UIColor.white
            thirdPageIndicator.backgroundColor = UIColor.white
            
            firstPageIndicator.textColor = UIColor.black
            secondPageIndicator.textColor = UIColor.lightGray
            thirdPageIndicator.textColor = UIColor.lightGray
            
            firstPageCompletedIndicator.backgroundColor = UIColor.white
            secondPageCompletedIndicator.backgroundColor = UIColor.white
            
            infoLbl1.text = getLocalizedStr(str: "WHEN WOULD YOU LIKE TO VISIT THE MUSEUM ?")
            infoLbl2.text = ""
            
            divisionListPagerViewHeightContraint.constant = 60
            infoContainerViewHeightConstraint.constant = 130
            
            divisionListPagerView.isHidden = false
            headerLblView.isHidden = true
            //dateLblView.isHidden = true
            headerLblView.text = ""
            //dateLblView.text = ""
            
            break
        case 1:
            nxtBtn.setTitle(getLocalizedStr(str: "Next") , for: .normal)
            
            if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
                nxtBtn.titleLabelFont =  UIFont.init(name: "DINNextLTPro-Bold", size: 18)
                //nxtBtn.setTitle ("Next", for: .normal);
            }
            else{
                nxtBtn.titleLabelFont = UIFont.init(name: "DINNextLTArabic-Bold", size: 18)
                //nxtBtn.setTitle ("التالي", for: .normal);
            }

            firstPageIndicator.backgroundColor = selectedColor
            secondPageIndicator.backgroundColor = selectedColor
            thirdPageIndicator.backgroundColor = UIColor.white
            
            firstPageIndicator.textColor = UIColor.black
            secondPageIndicator.textColor = UIColor.black
            thirdPageIndicator.textColor = UIColor.lightGray
            
            firstPageCompletedIndicator.backgroundColor = selectedColor
            secondPageCompletedIndicator.backgroundColor = UIColor.white
            
            infoLbl1.text = getLocalizedStr(str: "SELECT TICKETS")
            infoLbl2.text = getLocalizedStr(str: "You will need a ticket to enter the museum. Tickets are valid for three consecutive days starting with the first day of entry.")
            
            divisionListPagerViewHeightContraint.constant = 60
            infoContainerViewHeightConstraint.constant = 130
            
            divisionListPagerView.isHidden = true
            headerLblView.isHidden = false
            //dateLblView.isHidden = false
   
            headerLblView.text = getLocalizedStr(str: divisionsList[divisionSelectedIndex].name)
            
            //set date to date label
            setUpSelectedDate(dateObj: QMTLSingleton.sharedInstance.ticketInfo.date)
            
            break
        case 2:
            nxtBtn.setTitle(getLocalizedStr(str: "Complete Order"), for: .normal)
            
            if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
                nxtBtn.titleLabelFont =  UIFont.init(name: "DINNextLTPro-Bold", size: 18)
            }
            else{
                nxtBtn.titleLabelFont = UIFont.init(name: "DINNextLTArabic-Bold", size: 18)
            }

            firstPageIndicator.backgroundColor = selectedColor
            secondPageIndicator.backgroundColor = selectedColor
            thirdPageIndicator.backgroundColor = selectedColor
            
            firstPageIndicator.textColor = UIColor.black
            secondPageIndicator.textColor = UIColor.black
            thirdPageIndicator.textColor = UIColor.black
            
            firstPageCompletedIndicator.backgroundColor = selectedColor
            secondPageCompletedIndicator.backgroundColor = selectedColor
            
            infoLbl1.text = ""
            infoLbl2.text = ""
            
            divisionListPagerViewHeightContraint.constant = 0
            infoContainerViewHeightConstraint.constant = 40
            
            divisionListPagerView.isHidden = true
            headerLblView.isHidden = true
            
            headerLblView.text = ""
            
            //dateLblView.isHidden = true
            
            //dateLblView.text = ""
            
            break
        default:
            break
        }
        
        subViewListCollectionView.reloadData()
        
        divisionListPagerView.layoutIfNeeded()
        infoView.layoutIfNeeded()
        subViewListCollectionView.layoutIfNeeded()
    }
    //MARK:-
    func setUpSelectedDate(dateObj : Date){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        
        let pickedDateString = formatter.string(from: dateObj)
        print("pickedDateString = \(pickedDateString)")
        //dateLblView.text = pickedDateString
    }
    
    //MARK:- FSPagerView
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return divisionsList.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: QMTLConstants.CellId.divisionListCollectionViewCell, at: index) as! DivisionListCollectionViewCell
        
        let divisionObj = divisionsList[index]
        
        cell.divisionNameLbl.text = getLocalizedStr(str: divisionObj.name)
        
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            
            if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
                cell.divisionNameLbl?.font = UIFont.init(name: "DINNextLTPro-Bold", size: 12)
            }
            else{
                cell.divisionNameLbl?.font = UIFont.init(name: "DINNextLTArabic-Bold", size: 12)
            }
        }
        else {
            
            if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
                cell.divisionNameLbl?.font = UIFont.init(name: "DINNextLTPro-Bold", size: 15)
            }
            else{
                cell.divisionNameLbl?.font = UIFont.init(name: "DINNextLTArabic-Bold", size: 15)
            }
        }
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerViewSelected(pagerView, didSelectItemAt: index)
    }
    func pagerViewWillBeginDragging(_ pagerView: FSPagerView) {
        self.view.hideAllToasts()
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        pagerViewSelected(pagerView, didSelectItemAt: pagerView.currentIndex)
    }
    func pagerViewSelected(_ pagerView: FSPagerView, didSelectItemAt index: Int){
        
        divisionListPagerView.scrollToItem(at: index, animated: true)
        divisionSelectedIndex = index
        setExpositionForDivision()
    }
    
    //MARK:- MusuemNameSelection Delegate
    
    func selectedMuseumName(museumName: String, withSelectedIndex: Int) {
        tabViewController.topTabBarView.myProfileBtn.alpha = 1.0
        tabViewController.topTabBarView.backBtn.alpha = 1.0
        tabViewController.topTabBarView.isUserInteractionEnabled = true
        divisionListPagerView.scrollToItem(at: withSelectedIndex, animated: true)
        divisionSelectedIndex = withSelectedIndex
        setExpositionForDivision()
    }
    
    //MARK:- Cart View Delegate
    
    func clearCart() {
        selectedPageIndex = 0
        scrollToSelectedPage()
        indicatorSelector(pageNumber: selectedPageIndex)
    }
    
    //MARK:- Calendar view delegate
    func selectedDate(selectedDate: Date) {
        self.selectedDate = selectedDate
    }
    
    //MARK:- QMTLGuestUserViewControllerDelegate
    func continueUserSignIn() {
        print("continueUserSignIn")
        
        selectedPageIndex = selectedPageIndex + 1
        indicatorSelector(pageNumber: selectedPageIndex)
        scrollToSelectedPage()
        //cartTableViewController.callRecalculateBasket()
        
        apiServices.lockBasketItems(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.lockBasketItems, view: self.view)
        
    }
    //MARK:-
    func getSelectedDateStr() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let pickedDateString = formatter.string(from: selectedDate)
    
        return pickedDateString
    }
    
    //MARK:- Call Exp Period
    func callExpositionPeriodAPI()  {
        
        expositionPeriodsList.removeAll()
        
        let pickedDateString = getSelectedDateStr()
        //expositionList[selectedExpositionIndex]
        getExpostionPeriod(expostion:selectedExposition , from: "\(pickedDateString) 00:00:00", until: "\(pickedDateString) 23:59:59")
    }
    
    //MARK:- TabBar Delegate
    
    func backBtnSelected() {
        
        if selectedPageIndex > 0 && selectedPageIndex < 3{
            selectedPageIndex = selectedPageIndex - 1
            
            indicatorSelector(pageNumber: selectedPageIndex)
            scrollToSelectedPage()
            
            if !ticketCounterTableViewController.ticketPickerView.isHidden {
                ticketCounterTableViewController.ticketPickerView.isHidden = true
            }
            
            if selectedPageIndex == 1 {
                
            }
        }else{
            tabViewController.dismiss(animated: true, completion: nil)
            //tabViewController.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //MARK:- Payment Controller Delegate
    
    func paymentSucceeded(paymentId : String) {
       
        self.paymentId = paymentId
        print("---1 self.paymentId = \(self.paymentId)")
        paymentGatewayViewController.navigationController?.popViewController(animated: false)
        self.performSegue(withIdentifier: QMTLConstants.Segue.segueQMTLTicketSuccessfullViewController, sender: nil)
    }
    
    //MARK:- IBAction
    
    @objc func leftArrowTapAction(sender: UITapGestureRecognizer? = nil) {
        }
        
    @objc func rightArrowTapAction(sender: UITapGestureRecognizer? = nil) {
        
    }
        
    @IBAction func nxtBtnAction(_ sender: Any) {
        
        if selectedPageIndex <= subViewControllers.count {
            
            selectedPageIndex = selectedPageIndex + 1
            
            switch selectedPageIndex{
            case 0:
                
                indicatorSelector(pageNumber: selectedPageIndex)
                scrollToSelectedPage()
                
                break
            case 1:
                
                callExpositionPeriodAPI()
                
                break
            case 2:

                selectedPageIndex = selectedPageIndex - 1
                
                var isTicketChoosed = false
                
                let prices = QMTLSingleton.sharedInstance.ticketInfo.prices
                print("prices = \(prices.count)")
                for price in prices {
                    if price.ticketPicked > 0 {
                        isTicketChoosed = true
                        break
                    }
                }
                
                if isTicketChoosed {
                    
                    if !QMTLSingleton.sharedInstance.userInfo.isLoggedIn {
                        self.performSegue(withIdentifier: QMTLConstants.Segue.segueQMTLGuestUserViewController, sender: sender)
                    }else{
                        continueUserSignIn()
                    }
                }else{
                    if (internetConnected()){
                        showToast(message: "Please pick tickets")
                    }
                    else{
                        self.showToast(message: getLocalizedStr(str: "CHECK_INTERNET"))
                    }
                    
                }
                
                
                break
            case 3:
           
                selectedPageIndex = selectedPageIndex - 1
                
                if QMTLSingleton.sharedInstance.ticketInfo.lockBasket.isLocked {
                    navToPaymentGateway()
                }else{
                    showToast(message: "Ticket not locked please try again")
                }
                
                break
            default:
                break
            }
            
        }
        
        /*
        if timeContainerView.isHidden {
            callExpositionPeriodAPI()
        }else{
            self.performSegue(withIdentifier: QMTLConstants.Segue.ticketCounterViewControllerSegue, sender: expositionPeriodsList[selectedExpositionIndex])
        }
        */
    }
    
    func internetConnected() -> Bool {
        do {
            let reachability = try Reachability()
            if reachability.connection != .unavailable {
                return true
            }
            else{
                return false
            }
        }
        catch _ {
        }
        return false
    }
    
    func scrollToSelectedPage(){
        
        let indexPath = IndexPath(item: selectedPageIndex, section: 0)
        subViewListCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        if selectedPageIndex == 2 {
            cartTableViewController.setupViews()
        }
    }
    
    @IBAction func subViewBackBtnAction(_ sender: Any){
        
        if selectedPageIndex > 0 {
            selectedPageIndex = selectedPageIndex - 1
            
            indicatorSelector(pageNumber: selectedPageIndex)
            scrollToSelectedPage()

        }
        
    }
    
    @IBAction func timeContainerBackBtnAction(_ sender: Any) {

    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){

        if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
            let limage = UIImage(named: "leftarrowmuseum.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            leftArrowImg.image = limage
            
            let rimage = UIImage(named: "rightarrowmuseum.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            rightArrowImg.image = rimage
        }
        else {
            let limage = UIImage(named: "rightarrowmuseum.png",
                                 in: QMTLSingleton.sharedInstance.bundle,
                                 compatibleWith: nil)
            leftArrowImg.image = limage
            
            let rimage = UIImage(named: "leftarrowmuseum.png",
                                 in: QMTLSingleton.sharedInstance.bundle,
                                 compatibleWith: nil)
            rightArrowImg.image = rimage
        }
        
        errinfoLbl.text = getLocalizedStr(str: errinfoLbl.text!)
        headerLblView.text = getLocalizedStr(str: headerLblView.text!)
        
        setUpSelectedDate(dateObj: QMTLSingleton.sharedInstance.ticketInfo.date)
        //headerLblView.text = getLocalizedStr(str: headerLblView.text!)
        infoLbl1.text = getLocalizedStr(str: infoLbl1.text!)
        infoLbl2.text = getLocalizedStr(str: infoLbl2.text!)
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == QMTLConstants.Segue.segueQMTLGuestUserViewController{
            
            let guestViewController:QMTLGuestUserViewController = segue.destination as! QMTLGuestUserViewController
            guestViewController.qmtlGuestUserViewControllerDelegate = self
            
        }else if segue.identifier == QMTLConstants.Segue.seguePaymentGatewayViewControllerFromTicketCounter{
            
            paymentGatewayViewController = segue.destination as! PaymentGatewayViewController
            paymentGatewayViewController.paymentGatewayViewControllerDelegate = self
            
        }else if segue.identifier == QMTLConstants.Segue.segueQMTLTicketSuccessfullViewController{
            
            let ticketSuccessfullViewController:QMTLTicketSuccessfullViewController = segue.destination as! QMTLTicketSuccessfullViewController
            
            ticketSuccessfullViewController.paymentId = self.paymentId
        }
    }
    
    
}

extension UIColor {
    static var randomColor: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}


