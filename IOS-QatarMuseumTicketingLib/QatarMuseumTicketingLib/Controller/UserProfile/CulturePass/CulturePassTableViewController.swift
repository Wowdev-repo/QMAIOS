//
//  CulturePassTableViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 12/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class CulturePassTableViewController: UITableViewController,QMTLTabViewControllerDelegate,APIServiceResponse, APIServiceProtocolForConnectionError,CulturePassTableViewCellDelegate {
   
    
    //MARK:- Decleration
    var tabViewController = QMTLTabViewController()
    var apiServices = QMTLAPIServices()
    
    var subscriptionArticleArr = [SubscriptionArticle]()
    var selectedSubscriptionArticle = SubscriptionArticle()
    
    var findSubscriptionArticleResponseJsonValue : JSON = []
    
    var isFromSignUpPage = false
    var isFromLoginPage = false
    
    //MARK:- IBOutlet
    
    @IBOutlet weak var titleLbl: UILabel!
    
    //MARK:- Controller Defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        apiServices.delegateForConnectionError = self
        apiServices.delegateForAPIServiceResponse = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
                
        self.tableView.register(UINib(nibName: QMTLConstants.NibName.culturePassTableViewCell, bundle: QMTLSingleton.sharedInstance.bundle), forCellReuseIdentifier: QMTLConstants.CellId.CulturePassTableViewCellID)
        
        callServiceToGetSubscriptionArticle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.qmtlTabViewControllerDelegate = self
        tabViewController.topTabBarView.backBtn.isHidden = false
        tabViewController.topTabBarView.myProfileBtn.isHidden = true

        if isFromSignUpPage {
            titleLbl.text = "\(getLocalizedStr(str: "CHOOSE MEMBERSHIP TYPE"))"
        }else{
            titleLbl.text = "\(getLocalizedStr(str: "UPGRADE CULTURE PASS TYPE"))"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isFromSignUpPage{
            
            if QMTLSingleton.sharedInstance.memberShipInfo.isCartContainsItem {
                
                if QMTLSingleton.sharedInstance.userInfo.isLoggedIn{
                    if let subscribedObj = QMTLSingleton.sharedInstance.userInfo.subscriptionArticle {
                        navToCartPage(subscriptionArticle: subscribedObj)
                    }
                }
                
            }
            
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        resetCollaps()
        
    }
    
    func callServiceToGetSubscriptionArticle(){
        
        let flags = [QMTLConstants.FindSubscriptionArticlesKeys.prices:true,QMTLConstants.FindSubscriptionArticlesKeys.imageurl:true]
        let includes = [QMTLConstants.commonRequestKeys.includes:flags]
        
        apiServices.findSubscriptionArticles(searchCriteria: includes, serviceFor: QMTLConstants.ServiceFor.findSubscriptionArticles, view: self.view)
        
    }

    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("SubscriptionArticles Error ResponseJSON = \(String(describing: errInfo))")
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.findSubscriptionArticles:
                findSubscriptionArticleResponseJsonValue = json
                setupSubscriptArticle()
                break
            default:
                break
            }
        }
        
        
    }
    
    func setupSubscriptArticle(){
        
        let subscriptionArticle = findSubscriptionArticleResponseJsonValue[QMTLConstants.FindSubscriptionArticlesKeys.subscriptionArticles].arrayValue
        
        for obj in subscriptionArticle {
            if (obj[QMTLConstants.FindSubscriptionArticlesKeys.shortDescription].stringValue != "N"){
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
                
                let period = obj[QMTLConstants.FindSubscriptionArticlesKeys.periodDuration].dictionaryValue
                
                if period[QMTLConstants.FindSubscriptionArticlesKeys.months] != JSON.null {
                    itemSA.durationInMonths = period[QMTLConstants.FindSubscriptionArticlesKeys.months]?.intValue ?? 0
                }
                
                itemSA.cellHeight = 250
                
                subscriptionArticleArr.append(itemSA)
            }
           
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return subscriptionArticleArr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QMTLConstants.CellId.CulturePassTableViewCellID) as! CulturePassTableViewCell
        
        cell.culturePassTableViewCellDelegate = self
        
        let subscriptionArticle = subscriptionArticleArr[indexPath.row]
        
        
        
        var priceStr = ""
        
        if subscriptionArticle.price == 0 {
            priceStr = getLocalizedStr(str: "Free")
        }else{
            priceStr = "QAR \(subscriptionArticle.price)"
        }
        
        cell.subscriptionName.text = "\(getLocalizedStr(str: subscriptionArticle.name))"
        cell.subscriptionAmount.text = priceStr
        
        let imgURLStr = "\(QMTLConstants.GantnerAPI.baseImgURLTest + subscriptionArticle.imgUrl)"
        //let url = URL(string: imgURLStr)
        //cell.culturePassImgView?.kf.setImage(with: url)
        print("*** imgURLStr = \(imgURLStr)")
        cell.culturePassImgView?.kf.indicatorType = .activity
        cell.culturePassImgView?.kf.setImage(with: URL(string: imgURLStr))
         print("*** subscribed plan = \(subscriptionArticle.id)");
        if subscriptionArticle.id == QMTLConstants.FindSubscriptionArticlesKeys.basicId ||
            subscriptionArticle.id == QMTLConstants.FindSubscriptionArticlesKeys.staffBasic {
            cell.setSelectedDict(dictFor: QMTLConstants.FindSubscriptionArticlesKeys.basicId)
        }else if subscriptionArticle.id == QMTLConstants.FindSubscriptionArticlesKeys.familyId ||
            subscriptionArticle.id == QMTLConstants.FindSubscriptionArticlesKeys.staffFamily ||
            subscriptionArticle.id == QMTLConstants.FindSubscriptionArticlesKeys.promoFamily ||
            subscriptionArticle.id == QMTLConstants.FindSubscriptionArticlesKeys.limEdition {
            cell.setSelectedDict(dictFor: QMTLConstants.FindSubscriptionArticlesKeys.familyId)
        }else if subscriptionArticle.id == QMTLConstants.FindSubscriptionArticlesKeys.plusId ||
            subscriptionArticle.id == QMTLConstants.FindSubscriptionArticlesKeys.staffPlus ||
            subscriptionArticle.id == QMTLConstants.FindSubscriptionArticlesKeys.promoPlus{
            cell.setSelectedDict(dictFor: QMTLConstants.FindSubscriptionArticlesKeys.plusId)
        }
        
        if !isFromSignUpPage {
            if subscriptionArticle.id == QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id{
                print ("in if")
                cell.subscribedIndicatorLbl.isHidden = false
                cell.subscribedIndicatorLbl.text = "\(getLocalizedStr(str: cell.subscribedIndicatorLbl.text!))"
                
                if dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime) != dateToString(date: Date()){
                    cell.expiresOnLbl.text = "\(getLocalizedStr(str: "Expires On")) \(dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime))"
                }else{
                    cell.expiresOnLbl.text = ""
                }
            }
            else{
                print ("in else curre id is = ",QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased())
                print ("family code is =",QMTLConstants.FindSubscriptionArticlesKeys.staffFamily)
                print ("index path is = ",indexPath.row)
                
                if (indexPath.row==0 && QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.staffBasic){
                    cell.subscribedIndicatorLbl.isHidden = false
                    cell.subscribedIndicatorLbl.text = "\(getLocalizedStr(str: cell.subscribedIndicatorLbl.text!))"
                    
                    if dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime) != dateToString(date: Date()){
                        cell.expiresOnLbl.text = "\(getLocalizedStr(str: "Expires On")) \(dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime))"
                    }else{
                        cell.expiresOnLbl.text = ""
                    }
                }
                else if (indexPath.row == 1 && (QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.staffFamily || QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.promoFamily ||  QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.limEdition)){
                    cell.subscribedIndicatorLbl.isHidden = false
                    cell.subscribedIndicatorLbl.text = "\(getLocalizedStr(str: cell.subscribedIndicatorLbl.text!))"
                    
                    if dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime) != dateToString(date: Date()){
                        cell.expiresOnLbl.text = "\(getLocalizedStr(str: "Expires On")) \(dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime))"
                    }else{
                        cell.expiresOnLbl.text = ""
                    }
                }
                else if (indexPath.row == 2 && (QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.staffPlus || QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.promoPlus)){
                    cell.subscribedIndicatorLbl.isHidden = false
                    cell.subscribedIndicatorLbl.text = "\(getLocalizedStr(str: cell.subscribedIndicatorLbl.text!))"
                    
                    if dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime) != dateToString(date: Date()){
                        cell.expiresOnLbl.text = "\(getLocalizedStr(str: "Expires On")) \(dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime))"
                    }else{
                        cell.expiresOnLbl.text = ""
                    }
                }
                else{
                    cell.subscribedIndicatorLbl.isHidden = true
                    cell.expiresOnLbl.text = ""
                }
            }
        }else{
            cell.subscribedIndicatorLbl.isHidden = true
            cell.expiresOnLbl.text = ""
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        let subscriptionArticle = subscriptionArticleArr[indexPath.row]
        
        return CGFloat(subscriptionArticle.cellHeight)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let subscriptionArticle = subscriptionArticleArr[indexPath.row]
        if isFromLoginPage{
            QMTLSingleton.sharedInstance.userInfo.subscriptionArticle = subscriptionArticle
            self.performSegue(withIdentifier: QMTLConstants.Segue.signupFromCardSegue, sender: nil)
        }
        else if isFromSignUpPage{
            if QMTLSingleton.sharedInstance.userInfo.isLoggedIn {
                print("sign up")
                navToCartPage(subscriptionArticle: subscriptionArticle)
            }else{
                QMTLSingleton.sharedInstance.userInfo.subscriptionArticle = subscriptionArticle
                QMTLSingleton.sharedInstance.memberShipInfo.isCartContainsItem = true
                self.navigationController?.popViewController(animated: false)
            }
        }else{
            print("no sign up")
            if (indexPath.row==0 && QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.staffBasic){
                navToCartPagePromo(subscriptionArticle: subscriptionArticle, indexPath: indexPath.row)
            }
            else if (indexPath.row == 1 && (QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.staffFamily || QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.promoFamily ||  QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.limEdition)){
                navToCartPagePromo(subscriptionArticle: subscriptionArticle, indexPath: indexPath.row)
            }
            else if (indexPath.row == 2 && (QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.staffPlus || QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id.uppercased() == QMTLConstants.FindSubscriptionArticlesKeys.promoPlus)){
                navToCartPagePromo(subscriptionArticle: subscriptionArticle, indexPath: indexPath.row)
                
            }
            else{
                 navToCartPage(subscriptionArticle: subscriptionArticle)
            }
            
        }
        
    }


    func dateToString(date : Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
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
    
    func resetCollaps(){
     
        var index = 0
        for itemSA in subscriptionArticleArr {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView(self.tableView, cellForRowAt: indexPath) as! CulturePassTableViewCell
            cell.isBenefitOpened = false
            
            itemSA.cellHeight = 250
            
            index = index + 1
        }
         self.tableView.reloadData()
        
    }
    //MARK:-
    func navToCartPage(subscriptionArticle : SubscriptionArticle) {
        
        if isFromSignUpPage {
            letsGoToCartPage(subscriptionArticle: subscriptionArticle)
        }else{
            
            let currentSubscriptionName = QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.name
            let selectedSubscriptionName = subscriptionArticle.name
            
            if subscriptionArticle.id == QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.id {
                
                let alertMsg = "\(getLocalizedStr(str: "You already a member of this plan"))"
                
                let alert = UIAlertController(title: "", message: alertMsg, preferredStyle: .alert)
                
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
            }else{
                
                let alertMsg = "\(getLocalizedStr(str: "Do you want to change your subscription plan from existing"))(\(getLocalizedStr(str: currentSubscriptionName))) \(getLocalizedStr(str: "to new"))(\(getLocalizedStr(str: selectedSubscriptionName)))"
                
                let alert = UIAlertController(title: "", message: alertMsg, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: getLocalizedStr(str:"Continue"), style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        self.letsGoToCartPage(subscriptionArticle: subscriptionArticle)
                        break
                    case .cancel:
                        break
                    case .destructive:
                        break
                    @unknown default:
                        break
                    }}))
                alert.addAction(UIAlertAction(title: getLocalizedStr(str: "Cancel"), style: .cancel, handler: { action in
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
    }
    
    //MARK:-
    func navToCartPagePromo(subscriptionArticle : SubscriptionArticle, indexPath:Int) {
        
        if isFromSignUpPage {
            letsGoToCartPage(subscriptionArticle: subscriptionArticle)
        }else{

                let alertMsg = "\(getLocalizedStr(str: "You already a member of this plan"))"
                
                let alert = UIAlertController(title: "", message: alertMsg, preferredStyle: .alert)
                
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
    
    func letsGoToCartPage(subscriptionArticle : SubscriptionArticle){
        
        QMTLSingleton.sharedInstance.memberShipInfo.isCartContainsItem = true
        
        var prices = [PriceItem]()
        
        let price = PriceItem()
        let division = Divisions()
        
        
        price.id = subscriptionArticle.id
        price.name = subscriptionArticle.name
        price.totalAmount = Int(subscriptionArticle.price)
        
        prices.append(price)
        
        division.id = subscriptionArticle.id
        division.name = subscriptionArticle.name
        division.imgUrl = subscriptionArticle.imgUrl
        division.memberShipDurationInMonths = subscriptionArticle.durationInMonths
        
        QMTLSingleton.sharedInstance.memberShipInfo.prices = prices
        QMTLSingleton.sharedInstance.memberShipInfo.division = division
        
        
        self.performSegue(withIdentifier: QMTLConstants.Segue.segueQMTLCartTableTableViewController, sender: nil)
    }
    
    //MARK:- Cell Delegate
    func readBenefitTapped(cell: CulturePassTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        print("readBenefitTapped = \(indexPath!.row)")
        
        selectedSubscriptionArticle = subscriptionArticleArr[(indexPath?.row)!]
        
        self.performSegue(withIdentifier: QMTLConstants.Segue.segueReadBenefitsViewController, sender: nil)
        
        /*
        var index = 0
        
        for itemSA in subscriptionArticleArr {
            
            itemSA.cellHeight = 200
            
            index = index + 1
        }
        
        let itemSA = subscriptionArticleArr[(indexPath?.row)!]
        
        if cell.isBenefitOpened {
            cell.isBenefitOpened = false
        }else{
            if itemSA.id == QMTLConstants.FindSubscriptionArticlesKeys.basicId || itemSA.id == QMTLConstants.FindSubscriptionArticlesKeys.familyId || itemSA.id == QMTLConstants.FindSubscriptionArticlesKeys.plusId {
                
                itemSA.cellHeight = 500
                
                cell.isBenefitOpened = true
                
                tableView.scrollToRow(at: indexPath!, at: .top, animated: true)
            }
        }        
        
        self.tableView.reloadData()
 */
    }
    
    //MARK:- TabBar Delegate
    
    func backBtnSelected() {
        
//        if isFromLoginPage{
//            print ("in back1");
//            for vc in (self.navigationController?.viewControllers ?? []) {
//                 print ("in back1",vc);
//                if vc is QMTLSignInUserViewController {
//                    _ = self.navigationController?.popToViewController(vc, animated: true)
//                    break
//                }
//            }
//        }
//        else
            if isFromSignUpPage{
             print ("in back2");
            let allControllers = self.navigationController?.viewControllers
            let controllerToPop = allControllers?[(allControllers?.count)! - 3]
            self.navigationController?.popToViewController(controllerToPop!, animated: false) 
        }else{
             print ("in back3");
            self.navigationController?.popViewController(animated: false)
        }
        
    }
    func moveToTabRoot() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == QMTLConstants.Segue.segueQMTLCartTableTableViewController{
            
            let cartViewController:QMTLCartTableTableViewController = segue.destination as! QMTLCartTableTableViewController
            cartViewController.isFromMemberShipRenewal = true
            cartViewController.isFromSignUp = isFromSignUpPage
        }else if segue.identifier == QMTLConstants.Segue.segueReadBenefitsViewController{
            
            let readBenefitController:ReadBenefitsViewController = segue.destination as! ReadBenefitsViewController
            readBenefitController.subscriptionArticle = selectedSubscriptionArticle
            readBenefitController.isFromSignUpPage = isFromSignUpPage
        }
    }
    

}
