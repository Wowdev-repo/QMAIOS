//
//  QMTLCartTableTableViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 04/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SwiftyJSON
import Kingfisher

protocol QMTLCartTableTableViewControllerDelegate: class {
    func clearCart()
}

class QMTLCartTableTableViewController: UITableViewController, APIServiceResponse, APIServiceProtocolForConnectionError,PaymentGatewayViewControllerDelegate {
    
    //MARK:- Decleration
    
    var prices = [PriceItem]()
    var apiServices = QMTLAPIServices()
    
    var tabViewController = QMTLTabViewController()
    
    var paymentGatewayViewController = PaymentGatewayViewController()
    
    var recalculateBasketResponseJsonValue : JSON = []
    var validateBasketResponseJsonValue : JSON = []
    
    var memberRecalculateBasketResponseJsonValue : JSON = []
    var memberValidateBasketResponseJsonValue : JSON = []
    
    var qmtlCartTableTableViewControllerDelegate : QMTLCartTableTableViewControllerDelegate?
    
    var isFromMemberShipRenewal = false
    var isFromSignUp = false
    
    var paymentId = ""
    
    //MARK:- IBOutlet
    @IBOutlet weak var thumbNailImgView : UIImageView!
    @IBOutlet weak var grandTotalLbl: UILabel!
    @IBOutlet weak var museumName: UILabel!
    @IBOutlet weak var datePicked: UILabel!
    
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var personEmail: UILabel!
    
    @IBOutlet weak var clearCartBtn: UIButton!
    @IBOutlet weak var i_cartLbl: UILabel!
    @IBOutlet weak var i_totalLbl: UILabel!
    
    @IBOutlet weak var thumbnailImgWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
       
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        apiServices.delegateForConnectionError = self
        apiServices.delegateForAPIServiceResponse = self
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("------------- 1")
        if isFromSignUp{
            print("------------- 2")
            tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
            tabViewController.topTabBarView.myProfileBtn.isHidden = false
            tabViewController.topTabBarView.backBtn.isHidden = false
        }
    }

    //MARK:- SetUpViews
    
    func setupViews(){
        
        localizationSetup()
        
        if isFromMemberShipRenewal {
            print("isFromMemberShipRenewal true")
            
            var bottomSafeAreaHeight: CGFloat = 0
            
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.windows[0]
                let safeFrame = window.safeAreaLayoutGuide.layoutFrame
                bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
            }
            
            let completeOrderBtn = UIButton(frame: CGRect(x: 25, y: (self.view.frame.size.height - bottomSafeAreaHeight) - 80, width: self.view.frame.size.width-50, height: 50))
            completeOrderBtn.backgroundColor = .black
            completeOrderBtn.layer.cornerRadius = 25
            completeOrderBtn.setTitle("\(getLocalizedStr(str: "Complete Order"))", for: .normal)
            completeOrderBtn.setTitleColor(.white, for: .normal)
            completeOrderBtn.addTarget(self, action: #selector(completeOrderAction), for: .touchUpInside)
            self.view.addSubview(completeOrderBtn)
            
            let expiresIn = QMTLSingleton.sharedInstance.memberShipInfo.division.memberShipDurationInMonths
            
            if expiresIn == 0{
                datePicked.text = "\(getLocalizedStr(str: "Valid for Life time"))"
            }else{
                
                if expiresIn > 1 {
                    datePicked.text = "\(getLocalizedStr(str: "Valid for")) \(expiresIn) \(getLocalizedStr(str: "Months"))"
                }else{
                    datePicked.text = "\(getLocalizedStr(str: "Valid for")) \(expiresIn) \(getLocalizedStr(str: "Month"))"
                }
                
            }
            
            let imgURLStr = "\(QMTLConstants.GantnerAPI.baseImgURLTest + QMTLSingleton.sharedInstance.memberShipInfo.division.imgUrl)"
            thumbNailImgView.kf.indicatorType = .activity
            thumbNailImgView.kf.setImage(with: URL(string: imgURLStr))
            
            thumbnailImgWidthConstraint.constant = 80
            
            
        }else{
            print("isFromMemberShipRenewal false")
            thumbnailImgWidthConstraint.constant = 0
            setUpSelectedDate(dateObj: QMTLSingleton.sharedInstance.ticketInfo.date)
        }
        
        thumbNailImgView.layoutIfNeeded()
        
        clearCartBtn.layer.cornerRadius = 5.0
        clearCartBtn.layer.borderColor = UIColor.lightGray.cgColor
        clearCartBtn.layer.borderWidth = 0.5
        
        personName.text = QMTLSingleton.sharedInstance.userInfo.name
        personEmail.text = QMTLSingleton.sharedInstance.userInfo.email
        
        if isFromMemberShipRenewal {
            museumName.text = QMTLSingleton.sharedInstance.memberShipInfo.division.name
            prices = QMTLSingleton.sharedInstance.memberShipInfo.prices
        }else{
            museumName.text = QMTLSingleton.sharedInstance.ticketInfo.division.name
            prices = QMTLSingleton.sharedInstance.ticketInfo.prices
        }
        
        if !isFromMemberShipRenewal {
            for price in prices {
                if price.ticketPicked == 0 {
                    prices.remove(at: prices.firstIndex(of: price)!)
                }
            }
        }        
        
        museumName.text = getLocalizedStr(str: museumName.text!)
        
        self.tableView.reloadData()
        calculateGrandTotal()
        
    }
    
    func callRecalculateBasket(){
        apiServices.recalculateBasket(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.reCalculateBasket, view: self.view)
    }
    
    //MARK:-
    func setUpSelectedDate(dateObj : Date){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        
        let pickedDateString = formatter.string(from: dateObj)
        print("pickedDateString = \(pickedDateString)")
        datePicked.text = pickedDateString
    }
    
    func getDateByAddingMonths(monthsToAdd : Int) -> String{
        
        var dateComponent = DateComponents()
        dateComponent.month = monthsToAdd
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        
        let pickedDateString = formatter.string(from: futureDate!)
        print("pickedDateString = \(pickedDateString)")
        return pickedDateString
    }
    
    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("Cart Error ResponseJSON = \(String(describing: errInfo))")
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.reCalculateBasket:
                recalculateBasketResponseJsonValue = json
                setUpRecalculateBasket()
                break
            case QMTLConstants.ServiceFor.validateBasket :
                validateBasketResponseJsonValue = json
                break
            case QMTLConstants.ServiceFor.reCalculateBasketForMembership:
                memberRecalculateBasketResponseJsonValue = json
                apiServices.validateBasketForMembership(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.validateBasketForMembership, view: self.view)
                break
            case QMTLConstants.ServiceFor.validateBasketForMembership:
                memberValidateBasketResponseJsonValue = json
                checkValidation()
                break
            default:
                break
            }
        }
        
        
    }
    
    func setUpRecalculateBasket(){
        
        let basket = recalculateBasketResponseJsonValue[QMTLConstants.BasketKey.basket].dictionaryValue
        QMTLSingleton.sharedInstance.userInfo.id = (basket[QMTLConstants.BasketKey.customerID]?.stringValue)!
        
        apiServices.validateBasket(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.validateBasket, view: self.view)
    }
    
    func checkValidation(){
        
        let result = memberValidateBasketResponseJsonValue[QMTLConstants.BasketKey.result].dictionaryValue
        
        if result[QMTLConstants.BasketKey.isValid]?.boolValue ?? false {
            
            var grandTotal = 0
            
            for price in prices {
                grandTotal = price.totalAmount + grandTotal
            }
            
            if grandTotal > 0 {
                 self.performSegue(withIdentifier: QMTLConstants.Segue.seguePaymentGatewayViewControllerFromTicketCounter, sender: nil)
            }else{
                paymentSucceeded(paymentId: " ")
            }
           
        }
        
    }
    
    //MARK:- Payment Controller Delegate
    
    func paymentSucceeded(paymentId : String) {
       
        
       self.paymentId = paymentId
        paymentGatewayViewController.navigationController?.popViewController(animated: false)
        self.performSegue(withIdentifier: QMTLConstants.Segue.segueMembershipPurchasedViewController, sender: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return prices.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let height = 60.0
        
        return CGFloat(height)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QMTLConstants.CellId.cartTableViewCell, for: indexPath)

        // Configure the cell...
        
        let priceTypeNameLbl = cell.viewWithTag(10) as! UILabel
        let unitPriceLbl = cell.viewWithTag(11) as! UILabel
        let ticketCountLbl = cell.viewWithTag(12) as! UILabel
        let totalAmountLbl = cell.viewWithTag(13) as! UILabel
        
        ticketCountLbl.layer.cornerRadius = 10.0
        
        let priceItem = prices[indexPath.row]
        
        priceTypeNameLbl.text = getLocalizedStr(str: priceItem.name)
        unitPriceLbl.text = ""
        ticketCountLbl.text = "\(priceItem.ticketPicked)"
        totalAmountLbl.text = "QAR \(priceItem.totalAmount)"
        
        priceTypeNameLbl.decideTextDirection()
        
        if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
            totalAmountLbl.textAlignment = .right
        } else {
            totalAmountLbl.textAlignment = .left
        }

        if isFromMemberShipRenewal {
            unitPriceLbl.isHidden = true
            ticketCountLbl.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell selected = \(indexPath.row)")
        /*
        ActionSheetMultipleStringPicker.show(withTitle: "Pick Tickets", rows: [
            ["0","1", "2", "3","4", "5", "6","7", "8", "9","10"]], initialSelection: nil, doneBlock: {
                picker, indexes, values in
                
                print("values = \(String(describing: values))")
                print("indexes = \(String(describing: indexes))")
                print("picker = \(String(describing: picker))")
                
                let price = self.prices[indexPath.row]
                let countStr = "\(String(describing: indexes![0]))"
                let count =  Int(countStr) ?? 0
                price.ticketPicked = count
                price.totalAmount = price.amount * count
                
                print("count = \(count)")
                
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                self.calculateGrandTotal()
                
                return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: self.view)
         */
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
    func backBtnSelected() {
        print("cart page back button selected");
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK:- IBAction
    
    @IBAction func clearCartBtnAction(_ sender: Any)  {
        
        if isFromMemberShipRenewal{
            print("isFromMemberShipRenewal true")
            QMTLSingleton.sharedInstance.memberShipInfo.isCartContainsItem = false
            QMTLSingleton.sharedInstance.memberShipInfo.prices.removeAll()

            if isFromSignUp {
                self.navigationController?.popToRootViewController(animated: false)
            }else{
                self.navigationController?.popViewController(animated: false)
            }
            
            
        }else{
            print("isFromMemberShipRenewal false")
            QMTLSingleton.sharedInstance.ticketInfo.prices.removeAll()

            qmtlCartTableTableViewControllerDelegate?.clearCart()
        }
        
        
    }
    
    @IBAction func completeOrderAction(_ sender: Any)  {
        
        apiServices.recalculateBasketForMembership(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.reCalculateBasketForMembership, view: self.view)
        
    }
    
    //MARK:- Total Calc
    
    func calculateGrandTotal() {
        
        var grandTotal = 0
        
        for price in prices {
            grandTotal = price.totalAmount + grandTotal
        }
        
        grandTotalLbl.text = "QAR \(grandTotal)"
    }

    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        
        museumName.decideTextDirection()
        datePicked.decideTextDirection()
        personName.decideTextDirection()
        personEmail.decideTextDirection()
        
        clearCartBtn.setTitle("\(getLocalizedStr(str: clearCartBtn.titleLabel!.text!))", for: .normal)
        i_cartLbl.text = getLocalizedStr(str: i_cartLbl.text!)
        i_totalLbl.text = getLocalizedStr(str: i_totalLbl.text!)
        
        //i_BenefitsLbl.text = NSLocalizedString(i_BenefitsLbl.text!,comment: "")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == QMTLConstants.Segue.seguePaymentGatewayViewControllerFromTicketCounter{
            
            paymentGatewayViewController = segue.destination as! PaymentGatewayViewController
            paymentGatewayViewController.paymentGatewayViewControllerDelegate = self
            paymentGatewayViewController.isFromMemberShipRenewal = isFromMemberShipRenewal
                        
        }else if segue.identifier == QMTLConstants.Segue.segueMembershipPurchasedViewController{
            
            let membershipPurchasedViewController:MembershipPurchasedViewController = segue.destination as! MembershipPurchasedViewController
            
            membershipPurchasedViewController.paymentId = self.paymentId
        }
        
    }
    

}
