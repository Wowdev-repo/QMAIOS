//
//  UserProfileTableViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 11/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import KeychainSwift
import SwiftyJSON
import JGProgressHUD

class UserProfileTableViewController: UITableViewController,QMTLTabViewControllerDelegate,QMTLSignInUserViewControllerDelegate,APIServiceResponse, APIServiceProtocolForConnectionError {

    //MARK:- Decleration
    let additionalSafeAreaInset = 20
    
    let keychain = KeychainSwift()
    var tabViewController = QMTLTabViewController()
    var apiServices = QMTLAPIServices()
    
    var subscribedObj = Subscription()
    var subscribedArr = [Subscription]()
    var subscriptionArticleArr = [SubscriptionArticle]()
    
    var cartTableViewController = QMTLCartTableTableViewController()
    var findSubscriptionArticleResponseJsonValue : JSON = []
    var findSubscriptionResponseJsonValue : JSON = []
    
    let hud = JGProgressHUD(style: .extraLight)
    
    @IBOutlet weak var membershipTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellOneContainerView: UIView!
    @IBOutlet weak var cellTwoContainerView: UIView!
    @IBOutlet weak var cellThreeContainerView: UIView!
    @IBOutlet weak var cellFourContainerView: UIView!
    
    @IBOutlet weak var i_MembershipRenewal: UILabel!
    @IBOutlet weak var membershipExpiryDateLbl : UILabel!
    @IBOutlet weak var i_MyVisits: UILabel!
    @IBOutlet weak var i_MyProfile: UILabel!
    @IBOutlet weak var i_LogOut: UILabel!
    
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
      
        
        if !QMTLSingleton.sharedInstance.userInfo.isLoggedIn {
            self.performSegue(withIdentifier: QMTLConstants.Segue.segueQMTLSignInUserViewControllerFromProfile, sender: nil)
        }
        
        viewSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.topTabBarView.myProfileBtn.isHidden = true
        
        tabViewController.topTabBarView.backBtn.isHidden = false
        tabViewController.qmtlTabViewControllerDelegate = self
        
        /*
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            var topTabBarRect = tabViewController.topTabBarView.frame
            topTabBarRect.size.height = (self.navigationController?.navigationBar.frame.height)! + topPadding!
            tabViewController.topTabBarView.frame = topTabBarRect
        }*/
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabViewController.topTabBarView.myProfileBtn.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        callServiceToGetSubscriptionArticle()
    }
    
    func viewSetup(){
        localizationSetup()
        
        membershipTitleTopConstraint.constant = 24
        membershipExpiryDateLbl.isHidden = true
        
        if self.view !=  nil{
            let window: UIWindow? = UIApplication.shared.windows[0]
            var hudRect = hud.hudView.frame

            hudRect.origin.y = (window!.frame.size.height/2) - 190
            hud.hudView.frame = hudRect
        }
        
        drawDottedLine(start: CGPoint(x: 0, y: cellOneContainerView!.frame.size.height - 0.2), end: CGPoint(x: tableView.frame.size.width, y: cellOneContainerView!.frame.size.height - 0.2), view: cellOneContainerView!)
        
        drawDottedLine(start: CGPoint(x: 0, y: cellTwoContainerView!.frame.size.height - 0.2), end: CGPoint(x: tableView.frame.size.width, y: cellTwoContainerView!.frame.size.height - 0.2), view: cellTwoContainerView!)

        drawDottedLine(start: CGPoint(x: 0, y: cellThreeContainerView!.frame.size.height - 0.2), end: CGPoint(x: tableView.frame.size.width, y: cellThreeContainerView!.frame.size.height - 0.2), view: cellThreeContainerView!)

        drawDottedLine(start: CGPoint(x: 0, y: cellFourContainerView!.frame.size.height - 0.2), end: CGPoint(x: tableView.frame.size.width, y: cellFourContainerView!.frame.size.height - 0.2), view: cellFourContainerView!)
        
        
    }
    
    func callServiceToGetSubscriptionArticle(){
        
        let flags = [QMTLConstants.FindSubscriptionArticlesKeys.prices:true,QMTLConstants.FindSubscriptionArticlesKeys.imageurl:true]
        let includes = [QMTLConstants.commonRequestKeys.includes:flags]
        
        apiServices.findSubscriptionArticles(searchCriteria: includes, serviceFor: QMTLConstants.ServiceFor.findSubscriptionArticles, view: self.view)
        
    }
    
    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("~~~~~~~ Error ResponseJSON = \(String(describing: errInfo))")
        hud.dismiss()
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
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
                
                let parentId = subscription[QMTLConstants.FindSubscriptionsKeys.id].stringValue
                
                let article = subscription[QMTLConstants.FindSubscriptionsKeys.article].dictionaryValue
                let id = article[QMTLConstants.FindSubscriptionsKeys.id]?.stringValue
                
                if id == subscriptionArticle.id {

                    let subscribedInterObj = Subscription()
                    
                    subscribedInterObj.parentId = parentId
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
        
        var isToHideExpiryDateLbl = false
        
        if subscribedArr.count > 0 {
             print("subscribed subscribedArr is",subscribedArr.count);
            subscribedObj = subscribedArr[0]
            
            for subs in subscribedArr {
                print("subscribed subscribedArr is1",subscribedArr.count);
                if subscribedObj.creationDate < subs.creationDate {
                    subscribedObj = subs
                    print("subscribed subscribedArr is2",subs);
                }
            }
        }else{
            isToHideExpiryDateLbl = true
        }
        
        if dateToString(date: subscribedObj.endDateTime)  == dateToString(date: Date()) {
            isToHideExpiryDateLbl = true
        }
        
        if isToHideExpiryDateLbl {
            membershipTitleTopConstraint.constant = 24
            membershipExpiryDateLbl.isHidden = true
        }else{
            membershipTitleTopConstraint.constant = 10
            membershipExpiryDateLbl.isHidden = false
        }
        
        print("subscribed object is",subscribedObj);
        
        QMTLSingleton.sharedInstance.userInfo.currentSubscribtion = subscribedObj
        
        membershipExpiryDateLbl.text = "\(getLocalizedStr(str: "Expires On")) \(dateToString(date: subscribedObj.endDateTime))"
        
        hud.dismiss()
            
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: QMTLConstants.Segue.segueCulturePassTableViewController, sender: nil)
        }else if indexPath.row == 1{
            self.performSegue(withIdentifier: QMTLConstants.Segue.segueMyVisitsTableViewController, sender: nil)
        }else if indexPath.row == 2{
            self.performSegue(withIdentifier: QMTLConstants.Segue.segueUserInfoTableViewController, sender: nil)
        }else if indexPath.row == 3 {
            
            let refreshAlert = UIAlertController(title: getLocalizedStr(str: "Log Oxut"), message: getLocalizedStr(str: "Are you sure you want to log out?"), preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: getLocalizedStr(str: "Ok"), style: .default, handler: { (action: UIAlertAction!) in
                
                self.cleanUserSession()
                self.backBtnSelected()
            }))
            
            refreshAlert.addAction(UIAlertAction(title: getLocalizedStr(str: "Cancel"), style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            
            
            
        }
    }


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
    
    //MARK:- QMTLSignInUserViewControllerDelegate
    func signinSuccess() {
        //callServiceToGetSubscriptionArticle()
    }

    func cleanUserSession(){
        
        print("cleanUserSession called")
        
        QMTLSingleton.sharedInstance.userInfo.id = ""
        QMTLSingleton.sharedInstance.userInfo.name = ""
        QMTLSingleton.sharedInstance.userInfo.email = ""
        QMTLSingleton.sharedInstance.userInfo.phone = ""
        QMTLSingleton.sharedInstance.userInfo.username = ""
        QMTLSingleton.sharedInstance.userInfo.password = ""
        QMTLSingleton.sharedInstance.userInfo.isLoggedIn = false
        QMTLSingleton.sharedInstance.userInfo.isSubscribed = false
        
        self.keychain.set("", forKey: QMTLConstants.UserValues.username)
        self.keychain.set("", forKey: QMTLConstants.UserValues.password)
        self.keychain.set("", forKey: QMTLConstants.UserValues.personId)
        self.keychain.set("", forKey: QMTLConstants.UserValues.name)
        self.keychain.set("", forKey: QMTLConstants.UserValues.email)
        self.keychain.set("", forKey: QMTLConstants.UserValues.phone)
        self.keychain.set(false, forKey: QMTLConstants.UserValues.isLoggedIn)

    }
    //MARK:- TabBar Delegate
    
    func backBtnSelected() {
        //tabViewController.navigationController?.popToRootViewController(animated: true)
        
        if !QMTLSingleton.sharedInstance.userInfo.isLoggedIn {
            tabViewController.dismiss(animated: true, completion: nil)
            NSLog("Back button 1");
        }else if QMTLSingleton.sharedInstance.initialViewControllerToCall != "" {
            
            if QMTLSingleton.sharedInstance.initialViewControllerToCall == QMTLConstants.viewController.UserProfileTableViewController {
                tabViewController.dismiss(animated: true, completion: nil)
                NSLog("Back button 2");
            }else{
                tabViewController.selectedIndex = 0
                NSLog("Back button 3");
                
//                cartTableViewController = storyboard!.instantiateViewController(withIdentifier: QMTLConstants.StoryboardControllerID.cartTableViewController) as! QMTLCartTableTableViewController
//                cartTableViewController.qmtlCartTableTableViewControllerDelegate = self as? QMTLCartTableTableViewControllerDelegate
            }
            
        }else{
            tabViewController.dismiss(animated: true, completion: nil)
            NSLog("Back button 4");
        }
        
        
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        
        i_MembershipRenewal.text = NSLocalizedString(i_MembershipRenewal.text!,comment: "")
        i_MyVisits.text = NSLocalizedString(i_MyVisits.text!,comment: "")
        i_MyProfile.text = NSLocalizedString(i_MyProfile.text!,comment: "")
        i_LogOut.text = NSLocalizedString(i_LogOut.text!,comment: "")

    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == QMTLConstants.Segue.segueQMTLSignInUserViewControllerFromProfile{
            
            let signInViewController:QMTLSignInUserViewController = segue.destination as! QMTLSignInUserViewController
            signInViewController.qmtlSignInUserViewControllerDelegate = self
        }
        
        
    }
    

}
