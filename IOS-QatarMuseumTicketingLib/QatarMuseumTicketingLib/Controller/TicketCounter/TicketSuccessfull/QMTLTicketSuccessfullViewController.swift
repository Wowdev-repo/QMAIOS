//
//  QMTLTicketSuccessfullViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 13/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import SwiftyJSON
import QRCode

class QMTLTicketSuccessfullViewController: UIViewController,UITableViewDelegate, UITableViewDataSource , APIServiceResponse, APIServiceProtocolForConnectionError,QMTLTabViewControllerDelegate{
    
    //MARK:- Decleration
    var tabViewController = QMTLTabViewController()
    var apiServices = QMTLAPIServices()
    
    var checkoutBasketResponseJsonValue : JSON = []
    var findPersonCardsResponseJsonValue : JSON = []
    
    var barcodeStrArr = [String]()
    var checkOutBasket = CheckoutBasket()
    
    var paymentId = ""
    
    var salesId = ""

    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var transactionIdHeadLbl: UILabel!
    @IBOutlet weak var paymentMethodHeadLbl: UILabel!
    
    @IBOutlet weak var paymentSuccessfulTblView: UITableView!
    @IBOutlet weak var paymentMethodLbl: UILabel!
    @IBOutlet weak var museumNameLbl: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var transactionIdLbl: UILabel!
    
    @IBOutlet weak var myVisitsBtn: UIButton!
    @IBOutlet weak var printBtn: UIButton!
    
    //MARK:- View Defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        // Do any additional setup after loading the view.
        
        apiServices.delegateForConnectionError = self
        apiServices.delegateForAPIServiceResponse = self
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.qmtlTabViewControllerDelegate = self
    }
    
    func setUpView(){
        
        /*
        drawDottedLine(start: CGPoint(x: 0, y: qrInfoContainerView.frame.size.height - 0.2), end: CGPoint(x: qrInfoContainerView.frame.size.width + 100, y: qrInfoContainerView!.frame.size.height - 0.2), view: qrInfoContainerView)
        */
        
        localizationSetup()
        
        if !QMTLSingleton.sharedInstance.userInfo.isLoggedIn {
            myVisitsBtn.isEnabled = false
            //myVisitsBtn.isHighlighted = false
            //myVisitsBtn.alpha = 0.5
            myVisitsBtn.backgroundColor = .gray
        }
        
        apiServices.checkoutBasket(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.checkoutBasket, view: self.view)
        
        print("---2 self.paymentId = \(self.paymentId)")
        
        if paymentId == "" {
            transactionIdLbl.isHidden = true
            paymentMethodLbl.isHidden = true
        }else{
            transactionIdLbl.isHidden = false
            paymentMethodLbl.isHidden = false
        }
        
        transactionIdLbl.text = paymentId
        
        var totalAmount = 0
        
        let prices = QMTLSingleton.sharedInstance.ticketInfo.prices
        for price in prices {
            totalAmount = totalAmount + price.totalAmount
        }
        
        if totalAmount == 0 {
            titleLbl.text = getLocalizedStr(str: "TICKET PURCHASED SUCCESSFULLY")
        }
    }
    
    //MARK:-
    func setUpSelectedDate() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        
        let pickedDateString = formatter.string(from: QMTLSingleton.sharedInstance.ticketInfo.date)
        
        return pickedDateString
    }
    
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
    
    
    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("Ticket Book Error ResponseJSON = \(String(describing: errInfo))")
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.checkoutBasket:
                checkoutBasketResponseJsonValue = json
                setUpCheckoutBasketValues()
                break
            case QMTLConstants.ServiceFor.findPersonCards:
                findPersonCardsResponseJsonValue = json
                setUpBarcodeTypes()
                break
            default:
                break
            }
        }
        
    }
    
    
    func setUpCheckoutBasketValues(){
        
        let result = checkoutBasketResponseJsonValue[QMTLConstants.BasketKey.result].dictionaryValue
        let validationResult = result[QMTLConstants.BasketKey.basketValidationResult]?.dictionaryValue
        let isValid = validationResult![QMTLConstants.BasketKey.isValid]?.boolValue
        var message = ""
        if !isValid! {
            message = validationResult![QMTLConstants.BasketKey.message]?.stringValue ?? ""
        }else{
            let resultState = result[QMTLConstants.BasketKey.resultState]?.intValue
            let salesOrderNumber = result[QMTLConstants.BasketKey.salesOrderNumber]?.stringValue ?? ""
            let salesSeriesId = result[QMTLConstants.BasketKey.salesSeriesId]?.stringValue ?? ""
            
            let salesItems = result[QMTLConstants.BasketKey.salesItems]?.arrayValue
            
            var salesItemArr = [SalesItem]()
            barcodeStrArr.removeAll()
            
            for salesItemObj in salesItems! {
                
                salesId = salesItemObj["id"].stringValue
                let salesDetails = salesItemObj[QMTLConstants.BasketKey.saleDetails].arrayValue
                var index = 0
                for saleDetail in salesDetails {
                    
                    let salesItem = SalesItem()
                    
                    salesItem.id = saleDetail["id"].stringValue
                    salesItem.barcodes.append(salesItemObj[QMTLConstants.BasketKey.barcodes].arrayValue[index])
                    barcodeStrArr.append(salesItemObj[QMTLConstants.BasketKey.barcodes].arrayValue[index].stringValue)
                    salesItem.name = saleDetail["name"].stringValue
                    salesItem.quantity = saleDetail["quantity"].intValue
                    salesItem.unitPrice = Double(saleDetail["unitPrice"].floatValue)
                    salesItem.salesHeaderID = saleDetail["salesHeaderID"].stringValue
                    salesItem.date = saleDetail["date"].stringValue
                    salesItem.salesNumber = saleDetail["salesNumber"].stringValue
                    
                    salesItemArr.append(salesItem)
                    index = index + saleDetail["quantity"].intValue
                }
            }
            
            let tktPurchaseShopID = "\(QMTLConstants.AuthCreds.shopID)/\("en")/\(salesId)"
            self.apiServices.ticketPurchasedEmail(toEmail: QMTLSingleton.sharedInstance.userInfo.email, shopid: tktPurchaseShopID, username: QMTLConstants.QMAPI.userName, password: QMTLConstants.QMAPI.password, serviceFor: QMTLConstants.ServiceFor.TicketPurchase, view: self.view)

            //ticketPurchaseURL
            
            checkOutBasket.isValid = isValid ?? false
            checkOutBasket.message = message
            checkOutBasket.resultState = resultState ?? 0
            checkOutBasket.salesOrderNumber = salesOrderNumber
            checkOutBasket.salesSeriesId = salesSeriesId
            checkOutBasket.salesItem = salesItemArr
            
            print("checkOutBasket.salesItem = \(checkOutBasket.salesItem.count)")
            
            paymentSuccessfulTblView.reloadData()
            
            
            
        }
        
        if barcodeStrArr.count > 0 {
            getBarcodeType ()
        }
        
    }
    
    func setUpBarcodeTypes(){
        
        let personCards = findPersonCardsResponseJsonValue[QMTLConstants.FindPersonCardsKeys.personCards].arrayValue
        for personCard in personCards {
            let desc = personCard[QMTLConstants.FindPersonCardsKeys.description].stringValue
            let card = personCard[QMTLConstants.FindPersonCardsKeys.card].dictionaryValue
            let barcode = card[QMTLConstants.FindPersonCardsKeys.cardNumber]?.stringValue
            
            var index = 0
            for salesItem in checkOutBasket.salesItem {
                
                let salesItemObj = checkOutBasket.salesItem[index]
                let qrCodeStr = salesItemObj.barcodes[0].stringValue
                
                print("qrCodeStr = \(qrCodeStr)")
                print("desc = \(desc)")
                
                
                if qrCodeStr == barcode {
                    print("*******************")
                    print("----- qrCodeStr = \(qrCodeStr)")
                    print("----- desc = \(desc)")
                    print("*******************")
                    salesItem.name = desc
                }
                
                index = index + 1
            }
        }
        
        paymentSuccessfulTblView.reloadData()
        
        if barcodeStrArr.count > 0 {
            getBarcodeType ()
        }
        
    }
    
    func getBarcodeType (){
        
        for barcodeStr in  barcodeStrArr {
            
            let searchCriteria = [QMTLConstants.FindPersonCardsKeys.cardString : barcodeStr]
            apiServices.findPersonCards(searchCriteria: searchCriteria, serviceFor: QMTLConstants.ServiceFor.findPersonCards, view: self.view)
            
            barcodeStrArr.remove(at:0)
            
            break
        }
        
    }
    
    //MARK:- UITableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tbl checkOutBasket.salesItem = \(checkOutBasket.salesItem.count)")

        return checkOutBasket.salesItem.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 365
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: QMTLConstants.CellId.checkoutBasketTblCell, for: indexPath)
        
        let topContainerView = cell.viewWithTag(100)
        let bottomContainerView = cell.viewWithTag(101)
        let firstDotView = cell.viewWithTag(102)
        let secondDotView = cell.viewWithTag(103)
        
        let qrImageView = cell.viewWithTag(104) as! UIImageView
        
        let museumNameLbl = cell.viewWithTag(10) as! UILabel
        let dateLbl = cell.viewWithTag(11) as! UILabel
        let ticketIdLbl = cell.viewWithTag(12) as! UILabel
        let userNameLbl = cell.viewWithTag(13) as! UILabel
        let ticketInoLbl = cell.viewWithTag(14) as! UILabel
        let titleLbl = cell.viewWithTag(15) as! UILabel
        let subtitleLbl = cell.viewWithTag(16) as! UILabel
        
        topContainerView?.layer.cornerRadius = 10.0
        bottomContainerView?.layer.cornerRadius = 10.0
        firstDotView?.layer.cornerRadius = 10.0
        secondDotView?.layer.cornerRadius = 10.0
        
        userNameLbl.text = QMTLSingleton.sharedInstance.userInfo.name
        museumNameLbl.text = getLocalizedStr(str: QMTLSingleton.sharedInstance.ticketInfo.division.name)
        if QMTLLocalizationLanguage.currentAppleLanguage() == QMTLConstants.Language.AR_LANGUAGE {
            museumNameLbl.textAlignment = .right
            dateLbl.textAlignment = .right
            ticketIdLbl.textAlignment = .right
            userNameLbl.textAlignment = .right
            ticketInoLbl.textAlignment = .right
        }
        else{
            museumNameLbl.textAlignment = .left
            dateLbl.textAlignment = .left
            ticketIdLbl.textAlignment = .left
            userNameLbl.textAlignment = .left
            ticketInoLbl.textAlignment = .left
        }
        
        dateLbl.text = setUpSelectedDate()
        
        let salesItemObj = checkOutBasket.salesItem[indexPath.row]

        let qrCodeStr = salesItemObj.barcodes[0].stringValue
        
        var qrCode = QRCode(qrCodeStr)
        qrCode?.size = CGSize(width: 100, height: 100)
        qrCode?.color = CIColor(red: 255.0/255.0, green: 193.0/255.0, blue: 64.0/255.0)
        qrCode?.backgroundColor = .white
        qrImageView.image = qrCode?.image
        
        ticketIdLbl.text = "\(getLocalizedStr(str: "Ticket ID")) \(qrCodeStr)"
        ticketInoLbl.text = "\(getLocalizedStr(str: salesItemObj.name)) x \(salesItemObj.quantity)"
        subtitleLbl.text = "\(getLocalizedStr(str: subtitleLbl.text!))"
        drawDottedLine(start: CGPoint(x: 0, y: topContainerView!.frame.size.height - 0.2), end: CGPoint(x: tableView.frame.size.width + 100, y: topContainerView!.frame.size.height - 0.2), view: topContainerView!)
        
        titleLbl.text = getLocalizedStr(str: titleLbl.text!)
        
        return cell
    }
    
    //MARK:- IBAction
    
    @IBAction func myVisitsBtnAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: QMTLConstants.Segue.segueMyVisitsTableViewControllerFromPaymentSuccess, sender: sender)
    }
    
    @IBAction func printBtnAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: QMTLConstants.Segue.seguePrintTicketViewController, sender: sender)
    }
    
    //MARK:- TabBar Delegate
    
    func backBtnSelected() {
        tabViewController.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){

        titleLbl.text = getLocalizedStr(str: titleLbl.text!)
        
        transactionIdHeadLbl.text = getLocalizedStr(str: transactionIdHeadLbl.text!)
        paymentMethodHeadLbl.text = getLocalizedStr(str: paymentMethodHeadLbl.text!)
        
        paymentMethodLbl.text = getLocalizedStr(str: paymentMethodLbl.text!)
        transactionIdLbl.text = getLocalizedStr(str: transactionIdLbl.text!)
        
        myVisitsBtn.setTitle(getLocalizedStr(str: myVisitsBtn.titleLabel!.text!), for: .normal)
        printBtn.setTitle(getLocalizedStr(str: printBtn.titleLabel!.text!), for: .normal)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == QMTLConstants.Segue.seguePrintTicketViewController{
        
            let printTicketViewController:PrintTicketViewController = segue.destination as! PrintTicketViewController
            printTicketViewController.ticketForIdStr = salesId
            printTicketViewController.isFromMyVisits = false
        }
    }
    

}
