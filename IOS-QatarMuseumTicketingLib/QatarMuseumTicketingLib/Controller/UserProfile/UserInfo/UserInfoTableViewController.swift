//
//  UserInfoTableViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 15/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift
import ActionSheetPicker_3_0
import KeychainSwift

class UserInfoTableViewController: UITableViewController,UITextFieldDelegate,QMTLTabViewControllerDelegate,APIServiceResponse, APIServiceProtocolForConnectionError {

    //MARK:- Decleration
    var toastStyle = ToastStyle()
    var tabViewController = QMTLTabViewController()
    var apiServices = QMTLAPIServices()
    let keychain = KeychainSwift()
    
    var subscribedObj = Subscription()
    var subscriptionArticleArr = [SubscriptionArticle]()
    
    var findSubscriptionArticleResponseJsonValue : JSON = []
    var findSubscriptionResponseJsonValue : JSON = []
    
    var findPersonResponseJsonValue : JSON = []
    var findPersonForEmailValidationResponseJsonValue : JSON = []
    var userRegResponseJsonValue : JSON = []
    var listCountriesResponseJsonValue : JSON = []
    var listPersonTitlesResponseJsonValue : JSON = []
    
    var currTxtFld = UITextField()
    
    var emailIdFromFindPerson = ""
    
    var isNewsletterChecked = false
    var isToCheckEmailAlreadyExist = false
    
    //MARK:- IBOutlet
    
    @IBOutlet weak var membershipExpiryLbl: UILabel!
    @IBOutlet weak var memExpBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var membershipContainerView: UIView!
    @IBOutlet weak var yourAccDetailContainerView: UIView!
    @IBOutlet weak var aboutUContainerView: UIView!
    @IBOutlet weak var changePWLinkContainerView: UIView!
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var titleTxtFld: UITextField!
    @IBOutlet weak var fNameTxtFld: UITextField!
    @IBOutlet weak var lNameTxtFld: UITextField!
    @IBOutlet weak var contryOfResTxtFld: UITextField!
    @IBOutlet weak var nationalityTxtFld: UITextField!
    @IBOutlet weak var phoneCodeTxtFld: UITextField!
    @IBOutlet weak var mobileNumTxtFld: UITextField!
    
    @IBOutlet weak var subscribeNewsBtn: UIButton!
    
    @IBOutlet weak var membershipNameLbl: UILabel!
    
    @IBOutlet weak var membershipImageView: UIImageView!
    
    
    @IBOutlet weak var i_1: UILabel!
    @IBOutlet weak var i_2: UILabel!
    @IBOutlet weak var i_3: UILabel!
    @IBOutlet weak var i_4: UILabel!
    @IBOutlet weak var i_5: UILabel!
    @IBOutlet weak var i_6: UILabel!
    @IBOutlet weak var i_7: UILabel!
    @IBOutlet weak var i_8: UILabel!
    @IBOutlet weak var i_9: UILabel!
    @IBOutlet weak var i_10: UILabel!
    @IBOutlet weak var i_11: UILabel!
    @IBOutlet weak var i_12: UILabel!
    @IBOutlet weak var i_13: UILabel!
    
    
    //MARK:- View Defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set("REGISTER", forKey: "SCREEN") //setObject
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
          self.navigationItem.rightBarButtonItem = nil;
        
        doAPICall()
        
        toastStyle.messageColor = .white
        toastStyle.backgroundColor = .darkGray
        
        setupView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.qmtlTabViewControllerDelegate = self
        tabViewController.bottomBtn.isHidden = false
        //self.view .addSubview(tabViewController.bottomBtn);
        tabViewController.bottomBtn.setTitle(getLocalizedStr(str: "Save"), for: .normal)
        tabViewController.topTabBarView.backBtn.isHidden = false
        tabViewController.topTabBarView.myProfileBtn.isHidden=true
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabViewController.bottomBtn.isHidden = true
        tabViewController.bottomBtn.setTitle("", for: .normal)
    }
    
    func setupView(){
        localizationSetup()
        
        yourAccDetailContainerView.layer.cornerRadius = 10.0
        aboutUContainerView.layer.cornerRadius = 10.0
        changePWLinkContainerView.layer.cornerRadius = 10.0
        membershipContainerView.layer.cornerRadius = 10.0
        
        changePWLinkContainerView.layer.borderColor = UIColor.darkGray.cgColor
        changePWLinkContainerView.layer.borderWidth = 1.0
        
        //let tapmembershipView = UITapGestureRecognizer(target: self, action: #selector(self.membershipViewTapAction(sender:)))
        //membershipContainerView.addGestureRecognizer(tapmembershipView)
                
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.changePWLinkViewTapAction(sender:)))
        changePWLinkContainerView.addGestureRecognizer(tap)
        
        membershipNameLbl.text = getLocalizedStr(str: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.name)
        
        if membershipNameLbl.text == ""
        {
            membershipNameLbl.text = "No Membership"
        }
        
        if QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.imgUrl != "" {
            let imgURLStr = "\(QMTLConstants.GantnerAPI.baseImgURLTest + QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.imgUrl)"
            membershipImageView.kf.indicatorType = .activity
            membershipImageView.kf.setImage(with: URL(string: imgURLStr))
        }
        
        if dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime)  == dateToString(date: Date()) {
            membershipExpiryLbl.text = ""
            memExpBottomConstraint.constant = 8
        }else{
            membershipExpiryLbl.text = "\(NSLocalizedString("Expires On", comment: "")) \(dateToString(date: QMTLSingleton.sharedInstance.userInfo.currentSubscribtion.endDateTime))"
            memExpBottomConstraint.constant = 1.5
        }
    }

    func doAPICall() {
        
        if QMTLSingleton.sharedInstance.listCountriesArr.count == 0 {
            apiServices.getCountriesList(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.ListCountries, view: self.view)
        }else{
            if QMTLSingleton.sharedInstance.listPersonTitlesArr.count == 0{
                apiServices.getListPersonTitles(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.ListPersonTitles, view: self.view)
            }else{
                let searchCriteria = [QMTLConstants.PersonKeys.id:QMTLSingleton.sharedInstance.userInfo.id]
                apiServices.findPerson(searchCriteria: searchCriteria, serviceFor: QMTLConstants.ServiceFor.findPerson, view: self.view)
            }
        }
        
    }
    
    //MARK:- Show Toast
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
    
//    func showToast(message : String){
//
//        let indexPath = IndexPath(row: 0, section: 0)
//        self.tableView.scrollToRow(at: indexPath, at:.middle, animated: true)
//
//        self.view.makeToast(getLocalizedStr(str: message) , duration: 2.0, position: .center, style: toastStyle)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//            self.view.hideAllToasts()
//        })
//    }
    
    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("UserInfo ResponseJSON = \(String(describing: errInfo))")
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.findPerson:
                
                if isToCheckEmailAlreadyExist {
                    findPersonForEmailValidationResponseJsonValue = json
                    findUserProfileToCheckEmailIdAlreadyExist()
                }else{
                    findPersonResponseJsonValue = json
                    setUpUserProfile()
                }
                
                break
            case QMTLConstants.ServiceFor.savePerson:
                userRegResponseJsonValue = json
                checkUpUser()
                break
            case QMTLConstants.ServiceFor.PasswordReset:
                //showToast(message: "Password reset link has been sent to your mail")
                break
            case QMTLConstants.ServiceFor.ListCountries:
                listCountriesResponseJsonValue = json
                setUpCountryList()
                break
            case QMTLConstants.ServiceFor.findSubscriptionArticles:
                findSubscriptionArticleResponseJsonValue = json
                //setupSubscriptArticle()
                break
            case QMTLConstants.ServiceFor.findSubscriptions:
                findSubscriptionResponseJsonValue = json
                //getSubscribedDetail()
                break
            case QMTLConstants.ServiceFor.ListPersonTitles:
                listPersonTitlesResponseJsonValue = json
                setUpPersonTitles()
                break
            default:
                break
            }
        }
    }
    
    
    
    //MARK:-
    
    func stringToDate(dateStr : String) -> Date{
        
        let string = dateStr
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
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
    
    func setUpCountryList() {
        
        QMTLSingleton.sharedInstance.listCountriesArr.removeAll()
        
        let result = listCountriesResponseJsonValue[QMTLConstants.ListCountries.result].arrayValue
        for country in result {
            let countryList = CountryList()
            
            countryList.id = country[QMTLConstants.ListCountries.id].stringValue
            countryList.code = country[QMTLConstants.ListCountries.code].stringValue
            countryList.name = country[QMTLConstants.ListCountries.name].stringValue
            
            QMTLSingleton.sharedInstance.listCountriesArr.append(countryList)
        }
        
        apiServices.getListPersonTitles(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.ListPersonTitles, view: self.view)
        
        
    }
    
    func setUpPersonTitles() {
        QMTLSingleton.sharedInstance.listPersonTitlesArr.removeAll()
        let result = listPersonTitlesResponseJsonValue[QMTLConstants.ListPersonTitlesKeys.titleResult].arrayValue
        for title in result {
            let listPersonTitle = ListPersonTitles()
            
            listPersonTitle.id = title[QMTLConstants.ListPersonTitlesKeys.id].stringValue
            listPersonTitle.shortName = title[QMTLConstants.ListPersonTitlesKeys.shortName].stringValue
            listPersonTitle.desc = title[QMTLConstants.ListPersonTitlesKeys.description].stringValue
            
            QMTLSingleton.sharedInstance.listPersonTitlesArr.append(listPersonTitle)
        }
        
        let searchCriteria = [QMTLConstants.PersonKeys.id:QMTLSingleton.sharedInstance.userInfo.id]
        apiServices.findPerson(searchCriteria: searchCriteria, serviceFor: QMTLConstants.ServiceFor.findPerson, view: self.view)
        
    }
    
    func callServiceToGetSubscriptionArticle(){
        
        let flags = [QMTLConstants.FindSubscriptionArticlesKeys.prices:true,QMTLConstants.FindSubscriptionArticlesKeys.imageurl:true]
        let includes = [QMTLConstants.commonRequestKeys.includes:flags]
        
        apiServices.findSubscriptionArticles(searchCriteria: includes, serviceFor: QMTLConstants.ServiceFor.findSubscriptionArticles, view: self.view)
        
    }
    
    func setUpUserProfile() {
        
        let result = findPersonResponseJsonValue[QMTLConstants.PersonKeys.result].arrayValue
        let resultObj = result[0]
        let credentialObj = resultObj[QMTLConstants.PersonKeys.credential].dictionaryValue
        let nameObj = resultObj[QMTLConstants.PersonKeys.name].dictionaryValue
        let titleObj = resultObj["title"].dictionaryValue

        let title = titleObj["shortName"]?.stringValue
        let nationality = resultObj["info1"].stringValue
        //let isSubscridedStr = resultObj["info3"].stringValue
        let country = resultObj["info4"].stringValue
        let userName = credentialObj[QMTLConstants.PersonKeys.username]?.stringValue
        let email = resultObj[QMTLConstants.PersonKeys.email].stringValue
        let firstName = nameObj[QMTLConstants.PersonKeys.first]?.stringValue
        let lastName = nameObj[QMTLConstants.PersonKeys.last]?.stringValue
        let phoneNumber = resultObj[QMTLConstants.PersonKeys.phone].stringValue
        let code = resultObj["code"].stringValue
        
        let settings = resultObj["settings"].dictionaryValue

        isNewsletterChecked = settings["subscribeMailingList"]?.boolValue ?? false

        //let memberShipName = group[QMTLConstants.PersonKeys.shortName]?.stringValue
        
        emailIdFromFindPerson = email
        
        
        if isNewsletterChecked {

            let image = UIImage(named: "checked.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            subscribeNewsBtn.setImage(image, for: .normal)
        }else{

            let image = UIImage(named: "unchecked.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            subscribeNewsBtn.setImage(image, for: .normal)
        }
        
        titleTxtFld.text = title
        nationalityTxtFld.text = nationality
        if(userName != nil || userName != ""){
            emailTxtField.isUserInteractionEnabled = false
        } else {
            emailTxtField.isUserInteractionEnabled = true
        }
        emailTxtField.text = userName
        fNameTxtFld.text = firstName
        lNameTxtFld.text = lastName
        contryOfResTxtFld.text = country
        phoneCodeTxtFld.text = code
        mobileNumTxtFld.text = phoneNumber
        //membershipNameLbl.text = memberShipName
        
        //callServiceToGetSubscriptionArticle()
    }
    
    func checkUpUser() {
        
        let result = userRegResponseJsonValue[QMTLConstants.PersonKeys.result].dictionaryValue
        let validationResults = result[QMTLConstants.PersonKeys.validationResults]?.arrayValue
        if validationResults?.count ?? 0 > 0 {
            let message = validationResults?[0][QMTLConstants.PersonKeys.message].stringValue
            showToast(message: message ?? "User registration failed")
        }else{
            
            let person = result[QMTLConstants.UserValues.person]?.dictionaryValue
            let name = person?[QMTLConstants.UserValues.name]?.dictionaryValue
            let firstName = name?[QMTLConstants.UserValues.first]?.stringValue ?? ""
            let lastName = name?[QMTLConstants.UserValues.last]?.stringValue ?? ""
            let email = person?[QMTLConstants.UserValues.email]?.stringValue ?? ""
            let phone = person?[QMTLConstants.UserValues.phone]?.stringValue ?? ""
            
            
            QMTLSingleton.sharedInstance.userInfo.name = "\(firstName) \(lastName)"
            QMTLSingleton.sharedInstance.userInfo.email = email
            QMTLSingleton.sharedInstance.userInfo.phone = phone
            
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.id, forKey: QMTLConstants.UserValues.personId)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.name, forKey: QMTLConstants.UserValues.name)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.email, forKey: QMTLConstants.UserValues.email)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.phone, forKey: QMTLConstants.UserValues.phone)
            
            showToast(message: "Your profile updated successfully")

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.navigationController?.popViewController(animated: false)
            })
            
        }
        
    }
    
    func findUserProfileToCheckEmailIdAlreadyExist() {

        let result = findPersonForEmailValidationResponseJsonValue[QMTLConstants.PersonKeys.result].arrayValue
        if result.count > 0 {
            showToast(message: "Email id already exist")
        }else{
            callSavePerson()
        }
    }
    
    
    func scrollToTop(){
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func callSavePerson(){
    
        var valDict = [String:Any]()
        
        valDict[QMTLConstants.PersonKeys.username] = emailTxtField.text
        valDict[QMTLConstants.PersonKeys.email] = emailTxtField.text
        
        if titleTxtFld.text == "Mr" {
            valDict[QMTLConstants.PersonKeys.gender] = 0
        }else{
            valDict[QMTLConstants.PersonKeys.gender] = 1
        }
        
        valDict[QMTLConstants.PersonKeys.first] = fNameTxtFld.text
        valDict[QMTLConstants.PersonKeys.last] = lNameTxtFld.text
        valDict[QMTLConstants.PersonKeys.country] = nationalityTxtFld.text
        valDict[QMTLConstants.PersonKeys.Code] = phoneCodeTxtFld.text
        valDict[QMTLConstants.PersonKeys.phone] = mobileNumTxtFld.text
        valDict[QMTLConstants.PersonKeys.subscribeMailingList] = isNewsletterChecked
        
        valDict[QMTLConstants.PersonKeys.Info1] = nationalityTxtFld.text
        valDict[QMTLConstants.PersonKeys.Info2] = titleTxtFld.text
        
        if isNewsletterChecked {
            valDict[QMTLConstants.PersonKeys.Info3] = "Yes"
        }else{
            valDict[QMTLConstants.PersonKeys.Info3] = "No"
        }
        
        valDict[QMTLConstants.PersonKeys.Info4] = contryOfResTxtFld.text
        
        valDict[QMTLConstants.PersonKeys.Title] = getTitleObj()
        
        scrollToTop()
        apiServices.savePerson(searchCriteria: valDict, serviceFor: QMTLConstants.ServiceFor.savePerson, view: self.view,isToEditUser: true)
    }
    
    func getTitleObj() -> ListPersonTitles{
        var titleObj = ListPersonTitles()
        
        for title in QMTLSingleton.sharedInstance.listPersonTitlesArr {
            if title.shortName == titleTxtFld.text {
                titleObj = title
                break
            }
        }
        
        return titleObj
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
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
    
    //MARK:- IBAction
    @IBAction func newsletterBtnAction(_ sender: Any) {
        
        if isNewsletterChecked {
            let image = UIImage(named: "unchecked.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            subscribeNewsBtn.setImage(image, for: .normal)
            isNewsletterChecked = false
        }else{
            let image = UIImage(named: "checked.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            subscribeNewsBtn.setImage(image, for: .normal)
            isNewsletterChecked = true
        }
    }
    
    @objc func changePWLinkViewTapAction(sender: UITapGestureRecognizer? = nil) {
        
        if isForgotPassEmailValid() {
            
            print("Forgot Password API URL = \(QMTLConstants.ServiceFor.PasswordReset)")
            
            apiServices.forgotPasswordLink(emailStr: self.emailTxtField.text!, username: QMTLConstants.QMAPI.userName, password: QMTLConstants.QMAPI.password, personID: QMTLSingleton.sharedInstance.userInfo.id, serviceFor: QMTLConstants.ServiceFor.PasswordReset, view: self.view)

            showToast(message: "Password reset link has been sent to your mail")

        }
        
    }
    
    @objc func membershipViewTapAction(sender: UITapGestureRecognizer? = nil) {

        let cardView =  self.storyboard?.instantiateViewController(withIdentifier: "cardViewId") as! CulturePassCardViewController

        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(cardView, animated: false, completion: nil)
    }
    
    //MARK:- TabBar Delegate
    func moveToTabRoot() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func backBtnSelected() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func bottomBtnAction() {
        if isValid(){
            
            let emailStr = emailTxtField.text
            
            if emailIdFromFindPerson.trimmingCharacters(in: .whitespacesAndNewlines) == emailStr?.trimmingCharacters(in: .whitespacesAndNewlines) {
                callSavePerson()
            }else{
                isToCheckEmailAlreadyExist = true
                let searchCriteria = [QMTLConstants.PersonKeys.email:emailTxtField.text]
                apiServices.findPerson(searchCriteria: searchCriteria as! [String : String], serviceFor: QMTLConstants.ServiceFor.findPerson, view: self.view)
            }
            
        }
    }
    
    
    
    //MARK:- Validation
    
    func isValid() -> Bool {
        var returnVal = true
        
        let email = emailTxtField.text
        let firstName = fNameTxtFld.text
        let lastName = lNameTxtFld.text
        let countryOfRes = contryOfResTxtFld.text
        let mobile = mobileNumTxtFld.text
        
        if email?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            emailTxtField.becomeFirstResponder()
            showToast(message: "Please enter email id")
        }else if !isValidEmail(emailAddressString: email ?? ""){
            returnVal = false
            emailTxtField.becomeFirstResponder()
            showToast(message: "Please enter valid email id")
        }else if firstName?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            fNameTxtFld.becomeFirstResponder()
            showToast(message: "Please enter first name")
        }else if lastName?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            lNameTxtFld.becomeFirstResponder()
            showToast(message: "Please enter last name")
        }else if countryOfRes?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            contryOfResTxtFld.becomeFirstResponder()
            showToast(message: "Please enter country of residence")
        }else if mobile?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            mobileNumTxtFld.becomeFirstResponder()
            showToast(message: "Please enter mobile number")
        }else if !isValidPhoneNumber(value: mobile ?? ""){
            returnVal = false
            //mobileNumTxtFld.becomeFirstResponder()
            showToast(message: "Please enter valid mobile number")
        }
        
        return returnVal
    }
    
    func isForgotPassEmailValid() -> Bool {
        var returnVal = true
        
        let emailStr = emailTxtField.text
        
        print(">>> |\(String(describing: emailStr))| = |\(emailIdFromFindPerson)|")
        
        if emailStr?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            emailTxtField.becomeFirstResponder()
            showToast(message: "Please enter email id")
        }else if !isValidEmail(emailAddressString: emailStr ?? ""){
            returnVal = false
            emailTxtField.becomeFirstResponder()
            showToast(message: "Please enter valid email id")
        }else if emailIdFromFindPerson != emailStr?.trimmingCharacters(in: .whitespacesAndNewlines) {
            returnVal = false
            emailTxtField.becomeFirstResponder()
            showToast(message: "Failed to find your Profile Kindly try with Correct email")
        }
        
        return returnVal
    }
    
    func isValidEmail(emailAddressString:String) -> Bool {
        var returnValue = false
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        returnValue = emailTest.evaluate(with: emailAddressString)
        
        if returnValue {
            let eStrArr = emailAddressString.components(separatedBy: "@")
            let afterAtStr = eStrArr[1]
            if afterAtStr.first == "." {
                returnValue = false
            }
        }
        
        return  returnValue
    }
    
    func isValidPhoneNumber(value: String) -> Bool {
        let PHONE_REGEX = "^[0-9]+$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func showActionOptionsForTxtFlds(_ textField: UITextField){
        
        lNameTxtFld.becomeFirstResponder()
        lNameTxtFld.resignFirstResponder()
        
        var titleStr = ""
        var itemsArr = [String]()
        var countryDialCodeArray = [String]()

        switch textField {
        case titleTxtFld:
            titleStr = "Title"
            
            for title in QMTLSingleton.sharedInstance.listPersonTitlesArr {
                itemsArr.append(title.shortName)
            }
            break
        case contryOfResTxtFld,nationalityTxtFld:
            
            if textField == contryOfResTxtFld{
                titleStr = self.getLocalizedStr(str: "Country")
            }else{
                titleStr = self.getLocalizedStr(str: "Nationality")
            }
            
            for country in QMTLSingleton.sharedInstance.listCountriesArr {
                itemsArr.append(country.name)
            }

            break
        case phoneCodeTxtFld:
            titleStr = self.getLocalizedStr(str: "Code")
            
            do {
                if let file = Bundle.main.url(forResource: "countries", withExtension: "json") {
                    let data = try Data(contentsOf: file)
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let object = json as? [Any] {
                        // json is an array
                        for (_, element) in object.enumerated() {
                            if let element = element as? NSDictionary {
                                let countryName = element.value(forKey: "name") as! String
                                let countryDialCode = element.value(forKey: "dial_code") as! String
                                let countryDialCodeWithName = "\(countryDialCode) \(countryName)" // Format this String to show in the picker view
                                countryDialCodeArray.append(countryDialCode)
                                itemsArr.append(countryDialCodeWithName)
                            }
                        }
                        print(object)
                    } else {
                        print("JSON is invalid")
                    }
                } else {
                    print("no file")
                }
            } catch {
                print(error.localizedDescription)
            }
            
            break
        default:
            break
        }
        
        
        ActionSheetMultipleStringPicker.show(withTitle: titleStr, rows: [
            itemsArr], initialSelection: nil, doneBlock: {
                picker, indexes, values in
                
                let countStr = "\(String(describing: indexes![0]))"
                let count =  Int(countStr) ?? 0
                if titleStr == self.getLocalizedStr(str: "Code") {
                    textField.text = countryDialCodeArray[count]
                } else {
                    textField.text = itemsArr[count]
                }
                
                
                return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: self.view)
        
    }
    
    // MARK:- KeyBoard Show or Hide
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    //MARK:- UITextField Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        currTxtFld = textField
        
        var returnVal = true
        
        switch textField {
        case titleTxtFld,contryOfResTxtFld,nationalityTxtFld,phoneCodeTxtFld:
            returnVal = false
            break
        default:
            break
        }
        
        if !returnVal {
            showActionOptionsForTxtFlds(textField)
            let indexPath = IndexPath(item: 0, section: 2)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
        return returnVal
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currTxtFld = textField
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currTxtFld = textField
        
        var indexPath = IndexPath(item: 0, section: 0)
        
        switch textField {
        case emailTxtField:
            indexPath = IndexPath(item: 0, section: 0)
            break
        case titleTxtFld,fNameTxtFld,lNameTxtFld,contryOfResTxtFld,nationalityTxtFld,phoneCodeTxtFld,mobileNumTxtFld:
            indexPath = IndexPath(item: 0, section: 2)
            break
        default:
            break
        }
        
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        let ACCEPTABLE_ALPHA_NUMERIC_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@"
        let ACCEPTABLE_NUMBERS = "0123456789+"
        
        var returnVal = true
        let currentCharacterCount = textField.text?.count ?? 0
        
        switch textField {

        case fNameTxtFld,lNameTxtFld,contryOfResTxtFld,nationalityTxtFld:
            
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if !(string == filtered){
                return false
            }
            
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            returnVal = newLength <= 50
            break
        case emailTxtField :
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_ALPHA_NUMERIC_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if !(string == filtered){
                return false
            }
            
            
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            returnVal = newLength <= 50
            break
        case titleTxtFld,phoneCodeTxtFld:
            
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if !(string == filtered){
                return false
            }
            
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            returnVal = newLength <= 3
            break
        case mobileNumTxtFld:
            
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_NUMBERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if !(string == filtered){
                return false
            }
            
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            returnVal = newLength <= 15
            break
        default:
            break
        }
        
        
        return returnVal
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
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
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        
        emailTxtField.placeholder = getLocalizedStr(str: emailTxtField.placeholder!)
        titleTxtFld.placeholder = getLocalizedStr(str: titleTxtFld.placeholder!)
        fNameTxtFld.placeholder = getLocalizedStr(str: fNameTxtFld.placeholder!)
        lNameTxtFld.placeholder = getLocalizedStr(str: lNameTxtFld.placeholder!)
        contryOfResTxtFld.placeholder = getLocalizedStr(str: contryOfResTxtFld.placeholder!)
        nationalityTxtFld.placeholder = getLocalizedStr(str: nationalityTxtFld.placeholder!)
        phoneCodeTxtFld.placeholder = getLocalizedStr(str: phoneCodeTxtFld.placeholder!)
        mobileNumTxtFld.placeholder = getLocalizedStr(str: mobileNumTxtFld.placeholder!)
        
        i_1.decideTextDirection()
        i_2.decideTextDirection()
        i_3.decideTextDirection()
        i_4.decideTextDirection()
        i_5.decideTextDirection()
        i_6.decideTextDirection()
        i_7.decideTextDirection()
        i_8.decideTextDirection()
        i_9.decideTextDirection()
        i_10.decideTextDirection()
        i_11.decideTextDirection()
        i_12.decideTextDirection()
        i_13.decideTextDirection()
        
        i_1.text = getLocalizedStr(str: i_1.text!)
        i_2.text = getLocalizedStr(str: i_2.text!)
        i_3.text = getLocalizedStr(str: i_3.text!)
        i_4.text = getLocalizedStr(str: i_4.text!)
        i_5.text = getLocalizedStr(str: i_5.text!)
        i_6.text = getLocalizedStr(str: i_6.text!)
        i_7.text = getLocalizedStr(str: i_7.text!)
        i_8.text = getLocalizedStr(str: i_8.text!)
        i_9.text = getLocalizedStr(str: i_9.text!)
        i_10.text = getLocalizedStr(str: i_10.text!)
        i_11.text = getLocalizedStr(str: i_11.text!)
        i_12.text = getLocalizedStr(str: i_12.text!)
        i_13.text = getLocalizedStr(str: i_13.text!)
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

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
