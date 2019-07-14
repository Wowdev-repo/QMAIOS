//
//  TicketCounterTableViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 27/02/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SwiftyJSON
import JGProgressHUD

class QMTLTicketCounterTableViewController: UITableViewController,TicketPickerViewDelegate, APIServiceResponse, APIServiceProtocolForConnectionError,TicketCounterTableViewCellDelegate {
    
    //MARK:- Decleration
    
    var apiServices = QMTLAPIServices()
    
    var subscribedObj = Subscription()
    var subscribedArr = [Subscription]()
    var subscriptionArticleArr = [SubscriptionArticle]()
    
    var findSubscriptionArticleResponseJsonValue : JSON = []
    var findSubscriptionResponseJsonValue : JSON = []
    var findArticleResponseJsonValue : JSON = []
    
    var articleList = [FindArticle]()
    var exposition = Exposition()
    var prices = [PriceItem]()
    
    var ticketPickerView = TicketPickerView()
    
    let hud = JGProgressHUD(style: .extraLight)
    
    //MARK:- IBOutlet
    @IBOutlet weak var grandTotalLbl: UILabel!
    @IBOutlet weak var i_1: UILabel!
    
    //MARK:- View Defaults
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        apiServices.delegateForConnectionError = self
        apiServices.delegateForAPIServiceResponse = self
        
        ticketPickerView = TicketPickerView.instanceFromNib() as! TicketPickerView
        ticketPickerView.ticketPickerViewDelegate = self
        ticketPickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        ticketPickerView.setupView()
        self.view.addSubview(ticketPickerView)
        ticketPickerView.isHidden = true
        
        self.tableView.layer.cornerRadius = 10.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        localizationSetup()
    }
    
    func setUpView(){
        
        
        ticketPickerView.isHidden = true
        
        prices.removeAll()
        for priceObj in exposition.prices {
            
            let amount = priceObj[QMTLConstants.ExpositionsKeys.amount].intValue
            let group = priceObj[QMTLConstants.ExpositionsKeys.group].dictionaryValue
            let id = group[QMTLConstants.ExpositionsKeys.id]?.stringValue
            let name = group[QMTLConstants.ExpositionsKeys.name]?.stringValue
            let code = group[QMTLConstants.ExpositionsKeys.code]?.stringValue
            
            let priceItem = PriceItem()
            priceItem.amount = amount
            priceItem.id = id ?? ""
            priceItem.name = name ?? ""
            priceItem.code = code ?? ""
            
            prices.append(priceItem)
        }
        
        self.tableView.reloadData()
        calculateGrandTotal()
        
        apiServices.getArticleList(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.findArticles, view: self.view)
    }
    
    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("Ticket Counter Error ResponseJSON = \(String(describing: errInfo))")
        hud.dismiss()
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.findArticles:
                findArticleResponseJsonValue = json
                setupArticleList()
                break
            case QMTLConstants.ServiceFor.findSubscriptionArticles:
                let window: UIWindow? = UIApplication.shared.windows[0]
                hud.show(in: window!)
                findSubscriptionArticleResponseJsonValue = json
                setupSubscriptArticle()
                break
            case QMTLConstants.ServiceFor.findSubscriptions:
                findSubscriptionResponseJsonValue = json
                getSubscribedDetail()
                break
            default:
                break
            }
        }
        
    }
    
    
    func setupArticleList(){
        
        let articlesArr = findArticleResponseJsonValue[QMTLConstants.FindArticleKeys.articles].arrayValue
        
        for article in articlesArr {
            let articleObj = FindArticle()
            
            articleObj.id = article[QMTLConstants.FindArticleKeys.id].stringValue
            articleObj.name = article[QMTLConstants.FindArticleKeys.name].stringValue
            articleObj.desc = article[QMTLConstants.FindArticleKeys.description].stringValue
            
            articleList.append(articleObj)
        }
        
        callServiceToGetSubscriptionArticle()
    }
    
    func callServiceToGetSubscriptionArticle(){
        
        if !QMTLSingleton.sharedInstance.userInfo.isLoggedIn {
            
            for price in prices {
                
                let ticketName = price.name.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if isCPFamily(name: ticketName) {
                    price.isUserCanBuyThis = false
                }else if isCPPlus(name: ticketName) {
                    price.isUserCanBuyThis = false
                }else if isCPFamilyAdditional(name: ticketName) {
                    price.isUserCanBuyThis = false
                }else{
                    price.isUserCanBuyThis = true
                }
                
                if !price.isUserCanBuyThis {
                    price.cantBuyErrMsgStr = QMTLConstants.CPValidationKeys.guestErrMsg
                }else{
                    price.cantBuyErrMsgStr = ""
                }
            }
            
            reformPricesArr()
            
        }else{
            let flags = [QMTLConstants.FindSubscriptionArticlesKeys.prices:true,QMTLConstants.FindSubscriptionArticlesKeys.imageurl:true]
            let includes = [QMTLConstants.commonRequestKeys.includes:flags]
            
            apiServices.findSubscriptionArticles(searchCriteria: includes, serviceFor: QMTLConstants.ServiceFor.findSubscriptionArticles, view: self.view)
        }
    }
    func setupSubscriptArticle(){
        
        let subscriptionArticle = findSubscriptionArticleResponseJsonValue[QMTLConstants.FindSubscriptionArticlesKeys.subscriptionArticles].arrayValue
        
        for obj in subscriptionArticle {
            
            let itemSA = SubscriptionArticle()
            let priceItem = PriceItem()
            
            itemSA.id = obj[QMTLConstants.FindSubscriptionArticlesKeys.id].stringValue
            itemSA.name = obj[QMTLConstants.FindSubscriptionArticlesKeys.name].stringValue
            itemSA.imgUrl = obj[QMTLConstants.FindSubscriptionArticlesKeys.imageurl].stringValue
            itemSA.price = obj[QMTLConstants.FindSubscriptionArticlesKeys.price].intValue
            
            let prices = obj[QMTLConstants.FindSubscriptionArticlesKeys.prices].arrayValue
            if prices.count > 0 {
                let price = prices[0].dictionaryValue
                priceItem.id = price[QMTLConstants.FindSubscriptionArticlesKeys.id]?.stringValue ?? ""
                priceItem.amount = price[QMTLConstants.FindSubscriptionArticlesKeys.price]?.intValue ?? 0
                itemSA.prices.append(priceItem)
            }
            
            itemSA.cellHeight = 200
            
            subscriptionArticleArr.append(itemSA)
        }
        
        
        if subscriptionArticleArr.count > 0 {
            apiServices.findSubscriptions(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.findSubscriptions, view: self.view)
        }
    }
    
    func getSubscribedDetail(){
        
        let subscriptions = findSubscriptionResponseJsonValue[QMTLConstants.FindSubscriptionsKeys.subscriptions].arrayValue
        
        for subscriptionArticle in subscriptionArticleArr {
            
            for subscription in subscriptions{
                
                let article = subscription[QMTLConstants.FindSubscriptionsKeys.article].dictionaryValue
                let id = article[QMTLConstants.FindSubscriptionsKeys.id]?.stringValue
                
                if id == subscriptionArticle.id {
                    
                    let subscribedInterObj = Subscription()
                    
                    subscribedInterObj.id = id ?? ""
                    
                    let article = subscription[QMTLConstants.FindSubscriptionsKeys.article].dictionaryValue
                    
                    subscribedInterObj.name = article[QMTLConstants.FindSubscriptionsKeys.name]!.stringValue
                    subscribedInterObj.imgUrl = subscriptionArticle.imgUrl
                    
                    
                    let startDateTimeStr = subscription[QMTLConstants.FindSubscriptionsKeys.startDateTime].stringValue
                    let endDateTimeStr = subscription[QMTLConstants.FindSubscriptionsKeys.endDateTime].stringValue
                    let creationDateStr = subscription[QMTLConstants.FindSubscriptionsKeys.creationDate].stringValue
                    
                    
                    if creationDateStr != "" {
                        let creationDate = stringToDate(dateStr: subscription[QMTLConstants.FindSubscriptionsKeys.creationDate].stringValue, isForCreationDate: true)
                        
                        subscribedInterObj.creationDate = creationDate
                    }
                    
                    if startDateTimeStr != "" && endDateTimeStr != ""  {
                        let startDateTime = stringToDate(dateStr: subscription[QMTLConstants.FindSubscriptionsKeys.startDateTime].stringValue, isForCreationDate: false)
                        let endDateTime = stringToDate(dateStr: subscription[QMTLConstants.FindSubscriptionsKeys.endDateTime].stringValue, isForCreationDate: false)
                        
                        subscribedInterObj.startDateTime = startDateTime
                        subscribedInterObj.endDateTime = endDateTime
                        
                    }
                    subscribedArr.append(subscribedInterObj)
                }
                
            }
            
        }
        
        
        if subscribedArr.count > 0 {
            subscribedObj = subscribedArr[0]
            
            for subs in subscribedArr {
                if subscribedObj.creationDate < subs.creationDate {
                    subscribedObj = subs
                }
            }
        }
        
        QMTLSingleton.sharedInstance.userInfo.currentSubscribtion = subscribedObj
        
        var subsName = subscribedObj.name
        subsName = subsName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isCPBasic(name: subsName) {
            
            for price in prices {
                
                let ticketName = price.name.trimmingCharacters(in: .whitespacesAndNewlines)

                
                if isCPFamily(name: ticketName) {
                    price.isUserCanBuyThis = false
                }else if isCPPlus(name: ticketName) {
                    price.isUserCanBuyThis = false
                }else if isCPFamilyAdditional(name: ticketName) {
                    price.isUserCanBuyThis = false
                }else{
                    price.isUserCanBuyThis = true
                }
                
                if !price.isUserCanBuyThis {
                    price.cantBuyErrMsgStr = QMTLConstants.CPValidationKeys.basicOrPlusErrMsg
                }else{
                    price.cantBuyErrMsgStr = ""
                }
            }
            
        }else if isCPFamily(name: subsName) {
            for price in prices {
                
                let ticketName = price.name.trimmingCharacters(in: .whitespacesAndNewlines)

                
                if isCPFamily(name: ticketName) {
                    price.isUserCanBuyThis = true
                }else if isCPFamilyAdditional(name: ticketName){
                    price.isUserCanBuyThis = true
                }else if isCPPlus(name: ticketName) {
                    price.isUserCanBuyThis = false
                }else{
                    price.isUserCanBuyThis = true
                }
                
                if !price.isUserCanBuyThis {
                    price.cantBuyErrMsgStr = QMTLConstants.CPValidationKeys.familyErrMsg
                }else{
                    price.cantBuyErrMsgStr = ""
                }
            }
        }else if isCPPlus(name: subsName){
            for price in prices {
                
                let ticketName = price.name.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if isCPFamily(name: ticketName) {
                    price.isUserCanBuyThis = false
                }else if isCPFamilyAdditional(name: ticketName){
                    price.isUserCanBuyThis = false
                }else{
                    price.isUserCanBuyThis = true
                }
                
                if !price.isUserCanBuyThis {
                    price.cantBuyErrMsgStr = QMTLConstants.CPValidationKeys.basicOrPlusErrMsg
                }else{
                    price.cantBuyErrMsgStr = ""
                }
            }
        }
        
        
        reformPricesArr()
        
        hud.dismiss()
        
    }
    
    func reformPricesArr(){
        
        
        var buyableTickets = [PriceItem]()
       // var notBuyableTickets = [PriceItem]()
        for price in prices {
            
            let ticketName = price.name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if isCPFamily(name: ticketName) || isCPPlus(name: ticketName) {
                price.maxTicketAllowed = 2
            }
            
            buyableTickets.append(price)
//            if price.isUserCanBuyThis{
//                buyableTickets.append(price)
//            }else{
//                notBuyableTickets.append(price)
//            }
        }
        prices.removeAll()

        prices.append(contentsOf: buyableTickets)
        //prices.append(contentsOf: notBuyableTickets)
        
        self.tableView.reloadData()
    }
    
    func isCPBasic(name : String) -> Bool{
        
        var returnVal = false
        if name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.CP_Basic ) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.CP_Member_Basic) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.Culture_Pass_Basic_Card_Holder) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.Culture_Pass_Basic) == .orderedSame ||
            name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.QM_STAFF_CP_BASIC) == .orderedSame ||
            name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.QMA_STAFF_CP_Basic) == .orderedSame ||
            name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            returnVal = true
        }
        
        return returnVal
    }
    
    func isCPFamily(name : String) -> Bool {
        
        var returnVal = false
        
        if name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.CP_Family ) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.Culture_Pass_Family_Card_Holder ) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.Culture_Pass_Family ) == .orderedSame
            || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.QM_STAFF_CP_FAMILY ) == .orderedSame
            || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.CP_PROMO_FAMILY ) == .orderedSame
            || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.QMA_STAFF_CP_Family ) == .orderedSame
            || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.CP_Family_PROMO ) == .orderedSame
            {
        
            returnVal = true
        }
        
        return returnVal
    }
    
    func isCPPlus(name : String) -> Bool {
        
        var returnVal = false
        
        if name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.CP_Plus ) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.Culture_Pass_Plus_Card_Holder ) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.Culture_Pass_Plus ) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.QM_STAFF_CP_PLUS ) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.CP_PROMO_PLUS ) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.NMOQ_LIMITED_EDITION_PLUS ) == .orderedSame ||
            name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.QMA_STAFF_CP_Plus ) == .orderedSame ||
            name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.CP_Plus_PROMO ) == .orderedSame ||
            name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.VIP_LIMITED_EDITION_PLUS ) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.NMoQ_Limited_Edition1 ) == .orderedSame{
            
            returnVal = true
        }
        
        return returnVal
    }
    
    func isCPFamilyAdditional(name : String) -> Bool {
        
        var returnVal = false
        
        if name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.CP_Family_Additional ) == .orderedSame || name.caseInsensitiveCompare(QMTLConstants.CPValidationKeys.CP_Additional_Family ) == .orderedSame {
            
            returnVal = true
        }
        
        return returnVal
    }
    
    //MARK:-
    
    func stringToDate(dateStr : String, isForCreationDate : Bool) -> Date{
        print("dateStr = \(dateStr)")
        let string = dateStr
        let dateFormatter = DateFormatter()
        if isForCreationDate {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        }else{
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        }
        let date = dateFormatter.date(from: string) ?? Date()
        return date
    }
    
    func dateToString(date : Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        var height = 111.0

        for price in prices {
            height = height + Double(price.ticketCellHeight)
        }
        
        var ticketPickerViewFrame = ticketPickerView.frame
        ticketPickerViewFrame.size.height = CGFloat(height)
        ticketPickerView.frame = ticketPickerViewFrame
        
        
        return prices.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height = 111.0
        
        let priceItem = prices[indexPath.row]
        height = Double(priceItem.ticketCellHeight)
        
        
        
        /*if priceItem.isToShowDesc {
            height = 200.0
        }*/
        
        return CGFloat(height)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QMTLConstants.CellId.ticketCounterTableViewCell, for: indexPath) as! TicketCounterTableViewCell

        cell.ticketCounterTableViewCellDelegate = self
        // Configure the cell...
        
        if (indexPath.row == 0){
            cell.containerView?.layer.cornerRadius = 10.0
        }
        else if (indexPath.row == prices.count-1){
            cell.containerView?.layer.cornerRadius = 10.0
        }
        else{
            cell.containerView?.layer.cornerRadius = 0
        }
        
        cell.ticketCountBtn.layer.cornerRadius = 10.0
        cell.roundViewOne?.layer.cornerRadius = 10.0
        cell.roundViewTwo?.layer.cornerRadius = 10.0
        
        let priceItem = prices[indexPath.row]
        
        
        cell.priceTypeNameLbl.text = getLocalizedStr(str: priceItem.name)
        cell.unitPriceLbl.text = "QAR \(priceItem.amount)"
        cell.ticketCountBtn.setTitle("\(priceItem.ticketPicked)", for: .normal)
        cell.totalAmountLbl.text = "QAR \(priceItem.totalAmount)"
        
        //drawDottedLine(start: CGPoint(x: 0, y: cell.containerView!.frame.size.height - 0.2), end: CGPoint(x: self.view.frame.size.width, y: cell.containerView!.frame.size.height - 0.2), view: cell.containerView!)
        
        if (prices.count - 1) != indexPath.row {
            cell.roundViewOne?.isHidden = false
            cell.roundViewTwo?.isHidden = false
            cell.seperatorImgView.isHidden = false
        }else{
            cell.roundViewOne?.isHidden = true
            cell.roundViewTwo?.isHidden = true
            cell.seperatorImgView.isHidden = true
        }
        
        if priceItem.isToShowDesc {
            let image = UIImage(named: "Minus.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            cell.showOrHideDescBtn.setImage(image, for: .normal)
        }else{
            let image = UIImage(named: "Plus.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            cell.showOrHideDescBtn.setImage(image, for: .normal)
        }
        
        cell.descLblView.text = getTicketDesc(id: priceItem.id)
        
        cell.priceTypeNameLbl.decideTextDirection()
        
        if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
            cell.totalAmountLbl.textAlignment = .right
            cell.descLblView.textAlignment = .left
        } else {
            cell.totalAmountLbl.textAlignment = .left
             cell.descLblView.textAlignment = .right
        }
        
        if priceItem.isUserCanBuyThis {
            cell.priceTypeNameLbl.textColor = UIColor.black
            cell.unitPriceLbl.textColor = UIColor.black
            cell.totalAmountLbl.textColor = UIColor.black
            cell.ticketCountBtn.titleLabel?.textColor = UIColor.white
            cell.ticketCountBtn.isEnabled = true
        }else{
            cell.priceTypeNameLbl.textColor = UIColor.black
            cell.unitPriceLbl.textColor = UIColor.black
            cell.totalAmountLbl.textColor = UIColor.black
            cell.ticketCountBtn.titleLabel?.textColor = UIColor.white
            cell.ticketCountBtn.isEnabled = false
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let priceItem = prices[indexPath.row]

        let msgStr = getLocalizedStr(str: priceItem.cantBuyErrMsgStr)
   
            if !priceItem.isUserCanBuyThis {
                     if (priceItem.cantBuyErrMsgStr != ""){
                let alert = UIAlertController(title: getLocalizedStr(str:"Alert"), message: msgStr, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLocalizedStr(str:"OK"), style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        break
                    case .cancel:
                        break
                    case .destructive:
                        break
                    @unknown default:
                        break
                    }}))
                self.present(alert, animated: true, completion: nil)
                 }
            }
            else {
                let cell = tableView.cellForRow(at: indexPath) as! TicketCounterTableViewCell
                for priceItem in prices{
                    priceItem.isToShowDesc = false
                    priceItem.ticketCellHeight = 111
                }
                
                let priceItem = prices[(indexPath.row)]
                
                if cell.descShowingInPriceItem == priceItem {
                    if cell.isDescShowing {
                        cell.isDescShowing = false
                        priceItem.ticketCellHeight = 111
                    }else{
                        priceItem.isToShowDesc = true
                        cell.isDescShowing = true
                        priceItem.ticketCellHeight = Int(111 + cell.descLblView.frame.size.height + 20)
                    }
                }else{
                    cell.descShowingInPriceItem = priceItem
                    priceItem.isToShowDesc = true
                    cell.isDescShowing = true
                    priceItem.ticketCellHeight = Int(111 + cell.descLblView.frame.size.height + 20)
                }
                
                self.tableView.reloadData()
                
            }
    }
    
    //MARK:-
    
    func getTicketDesc(id : String) -> String {
        var desc = getLocalizedStr(str:"No description available");
        
        for article in articleList {
            
            if article.id == id {
                desc =  getLocalizedStr(str:article.desc);
                
                if desc == "" {
                    desc = getLocalizedStr(str:"No description available");
                }
                
                break
            }
        }
        
        
        return desc
    }
    
    //MARK:- Cell Delegate
    
    func ticketCountBtnTapped(cell: TicketCounterTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        
        let priceTypeNameLbl = cell.priceTypeNameLbl
        let ticketCountLbl = cell.ticketCountBtn
        
        let typeNameLblPoint = priceTypeNameLbl!.superview?.convert((priceTypeNameLbl?.frame.origin)!, to: nil)
        let countLblPoint = ticketCountLbl!.superview?.convert((ticketCountLbl?.frame.origin)!, to: nil)
        
        ticketPickerView.isHidden = false
        let price = self.prices[(indexPath?.row)!]
        
        ticketPickerView.setTypeName(typeName: price.name,indexChosen:indexPath!.row, totalItemCnt: prices.count, typeNameLblPoint: typeNameLblPoint!, countLblPoint: countLblPoint!)
        ticketPickerView.setTicketCount(count: price.maxTicketAllowed)
    }
    
    func showOrHideDescBtnTapped(cell: TicketCounterTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        
        for priceItem in prices{
            priceItem.isToShowDesc = false
            priceItem.ticketCellHeight = 111
        }
        
        let priceItem = prices[(indexPath?.row)!]
        
        if cell.descShowingInPriceItem == priceItem {
            if cell.isDescShowing {
                cell.isDescShowing = false
                priceItem.ticketCellHeight = 111
            }else{
                priceItem.isToShowDesc = true
                cell.isDescShowing = true
                priceItem.ticketCellHeight = Int(111 + cell.descLblView.frame.size.height + 20)
            }
        }else{
            cell.descShowingInPriceItem = priceItem
            priceItem.isToShowDesc = true
            cell.isDescShowing = true
            priceItem.ticketCellHeight = Int(111 + cell.descLblView.frame.size.height + 20)
        }
        
        self.tableView.reloadData()
        //self.tableView.scrollToRow(at: indexPath!, at: .top, animated: false)
    }
    

    
    func ticketCountLblAction(sender: UITapGestureRecognizer? = nil) {
        
        let countLbl = sender?.view as! UILabel
        
        print("ticketCountLblAction")
        
        guard let cell = countLbl.superview as? TicketCounterTableViewCell else {
            return // or fatalError() or whatever
        }
        let indexPath = self.tableView.indexPath(for: cell)
        
        print("ticketCountLblAction row = \(String(describing: indexPath?.row))")
        
    }

    //MARK:-
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1.0).cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.
        
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    //MARK:- TicketPickerView Delegate
    
    func selectedCount(count: Int, indexChosen : Int) {
        ticketPickerView.isHidden = true
        
        let price = self.prices[indexChosen]
        let countStr = "\(String(describing: count))"
        let count =  Int(countStr) ?? 0
        price.ticketPicked = count
        price.totalAmount = price.amount * count
        
        print("count = \(count)")
        
        self.tableView.reloadData()
        self.calculateGrandTotal()
    }
    
    func dismissView() {
        ticketPickerView.isHidden = true
    }
    
    //MARK:- Total Calc
    
    func calculateGrandTotal() {
        
        var grandTotal = 0
        
        for price in prices {
            grandTotal = price.totalAmount + grandTotal
        }
        
        grandTotalLbl.text = "QAR \(grandTotal)"
        
        QMTLSingleton.sharedInstance.ticketInfo.prices = prices
    }

    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        i_1.text = getLocalizedStr(str: i_1.text!)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
