//
//  SignUpTableViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 26/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import Toast_Swift
import ActionSheetPicker_3_0
import SwiftyJSON
import KeychainSwift

class SignUpTableViewController: UITableViewController, UITextFieldDelegate,QMTLTabViewControllerDelegate,APIServiceResponse, APIServiceProtocolForConnectionError {
    

    //MARK:- Decleration
    var toastStyle = ToastStyle()
    var tabViewController = QMTLTabViewController()
    var apiServices = QMTLAPIServices()
    let keychain = KeychainSwift()
    
    var userRegResponseJsonValue : JSON = []
    var listCountriesResponseJsonValue : JSON = []
    var listPersonTitlesResponseJsonValue : JSON = []
    var findPersonResponseJsonValue : JSON = []
    
    var currTxtFld = UITextField()
    
    var isAgreementChecked = false
    var isNewsletterChecked = false
    
    var isThisViewForEditUser = false
        
    //MARK:- IBOutlet
    
    @IBOutlet weak var membershipContainerView: UIView!
    @IBOutlet weak var yourAccDetailContainerView: UIView!    
    @IBOutlet weak var setPassContainerView: UIView!
    @IBOutlet weak var confirmPassContainerView: UIView!
    @IBOutlet weak var aboutUContainerView: UIView!
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passTxtFld: UITextField!
    @IBOutlet weak var confPassTxtFld: UITextField!
    @IBOutlet weak var titleTxtFld: UITextField!
    @IBOutlet weak var fNameTxtFld: UITextField!
    @IBOutlet weak var lNameTxtFld: UITextField!
    @IBOutlet weak var contryOfResTxtFld: UITextField!
    @IBOutlet weak var nationalityTxtFld: UITextField!
    @IBOutlet weak var phoneCodeTxtFld: UITextField!
    @IBOutlet weak var mobileNumTxtFld: UITextField!
    
    @IBOutlet weak var subscribeNewsBtn: UIButton!
    @IBOutlet weak var TandCbtn: UIButton!
    
    @IBOutlet weak var titleLbl: UILabel!
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
    @IBOutlet weak var i_15: UILabel!
    
    @IBOutlet weak var i_14_TandCBtn: UIButton!
    
    //MARK:- Controller Defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        apiServices.delegateForConnectionError = self
        apiServices.delegateForAPIServiceResponse = self
        
        toastStyle.messageColor = .white
        toastStyle.backgroundColor = .darkGray
        
        //QMTLSingleton.sharedInstance.userInfo.subscriptionArticle = nil
        
        setupView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    func setupView(){
        
        localizationSetup()
        
        yourAccDetailContainerView.layer.cornerRadius = 10.0
        setPassContainerView.layer.cornerRadius = 10.0
        confirmPassContainerView.layer.cornerRadius = 10.0
        aboutUContainerView.layer.cornerRadius = 10.0
        membershipContainerView.layer.cornerRadius = 10.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.membershipViewTapAction(sender:)))
        membershipContainerView.addGestureRecognizer(tap)
        
        if QMTLSingleton.sharedInstance.listCountriesArr.count == 0{
            apiServices.getCountriesList(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.ListCountries, view: self.view)
        }else{
            if QMTLSingleton.sharedInstance.listPersonTitlesArr.count == 0{
                apiServices.getListPersonTitles(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.ListPersonTitles, view: self.view)
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.qmtlTabViewControllerDelegate = self
        tabViewController.bottomBtn.isHidden = false
        tabViewController.bottomBtn.setTitle(getLocalizedStr(str: "Save") , for: .normal)
        tabViewController.topTabBarView.myProfileBtn.isHidden = true
        
        print ("subscribed obj is",QMTLSingleton.sharedInstance.userInfo.subscriptionArticle?.name as Any);
        
        if let subscribedObj = QMTLSingleton.sharedInstance.userInfo.subscriptionArticle {
            
            membershipNameLbl.text = getLocalizedStr(str: subscribedObj.name)
            let imgURLStr = "\(QMTLConstants.GantnerAPI.baseImgURLTest + subscribedObj.imgUrl)"
            membershipImageView.kf.indicatorType = .activity
            membershipImageView.kf.setImage(with: URL(string: imgURLStr))
        }else{
            self.membershipViewTapAction(sender: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabViewController.bottomBtn.isHidden = true
        tabViewController.bottomBtn.setTitle("", for: .normal)
    }
    
    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("Member Registration Error ResponseJSON = \(String(describing: errInfo))")
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.savePerson:
                userRegResponseJsonValue = json
                checkUpUser()
                break
            case QMTLConstants.ServiceFor.ListCountries:
                listCountriesResponseJsonValue = json
                setUpCountryList()
                break
            case QMTLConstants.ServiceFor.findPerson:
                findPersonResponseJsonValue = json
                findUserProfileToCheckEmailIdAlreadyExist()
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
    
    func setUpCountryList() {
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
    
    func setUpPersonTitles(){
        QMTLSingleton.sharedInstance.listPersonTitlesArr.removeAll()
        let result = listPersonTitlesResponseJsonValue[QMTLConstants.ListPersonTitlesKeys.titleResult].arrayValue
        for title in result {
            let listPersonTitle = ListPersonTitles()
            
            listPersonTitle.id = title[QMTLConstants.ListPersonTitlesKeys.id].stringValue
            listPersonTitle.shortName = title[QMTLConstants.ListPersonTitlesKeys.shortName].stringValue
            listPersonTitle.desc = title[QMTLConstants.ListPersonTitlesKeys.description].stringValue
            
            QMTLSingleton.sharedInstance.listPersonTitlesArr.append(listPersonTitle)
        }
    }
    
    func checkUpUser() {
        
        let result = userRegResponseJsonValue[QMTLConstants.PersonKeys.result].dictionaryValue
        let validationResults = result[QMTLConstants.PersonKeys.validationResults]?.arrayValue
        if validationResults?.count ?? 0 > 0 {
            let message = validationResults?[0][QMTLConstants.PersonKeys.message].stringValue
            showToast(message: message ?? "User registration failed")
        }else{
            
            let person = result[QMTLConstants.UserValues.person]?.dictionaryValue
            let id = person?[QMTLConstants.PersonKeys.id]?.stringValue ?? ""
            let name = person?[QMTLConstants.UserValues.name]?.dictionaryValue
            let firstName = name?[QMTLConstants.UserValues.first]?.stringValue ?? ""
            let lastName = name?[QMTLConstants.UserValues.last]?.stringValue ?? ""
            let email = person?[QMTLConstants.UserValues.email]?.stringValue ?? ""
            let phone = person?[QMTLConstants.UserValues.phone]?.stringValue ?? ""
            
            
            QMTLSingleton.sharedInstance.userInfo.id = id
            QMTLSingleton.sharedInstance.userInfo.name = "\(firstName) \(lastName)"
            QMTLSingleton.sharedInstance.userInfo.email = email
            QMTLSingleton.sharedInstance.userInfo.phone = phone
            QMTLSingleton.sharedInstance.userInfo.username = email
            QMTLSingleton.sharedInstance.userInfo.password = passTxtFld.text ?? ""
            QMTLSingleton.sharedInstance.userInfo.isLoggedIn = true
                        
            self.apiServices.cpRegistrationEmail(toEmail: QMTLSingleton.sharedInstance.userInfo.email, username: QMTLConstants.QMAPI.userName, password: QMTLConstants.QMAPI.password, serviceFor: QMTLConstants.ServiceFor.CPRegistration, view: self.view)

            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.username, forKey: QMTLConstants.UserValues.username)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.password, forKey: QMTLConstants.UserValues.password)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.id, forKey: QMTLConstants.UserValues.personId)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.name, forKey: QMTLConstants.UserValues.name)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.email, forKey: QMTLConstants.UserValues.email)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.phone, forKey: QMTLConstants.UserValues.phone)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.isLoggedIn, forKey: QMTLConstants.UserValues.isLoggedIn)
            
            if QMTLSingleton.sharedInstance.userInfo.isSubscribed {
                
                self.navigationController?.popToRootViewController(animated: false)
            }else{
                
                var messageStr = ""
                
                if let _ = QMTLSingleton.sharedInstance.userInfo.subscriptionArticle {
                    messageStr = getLocalizedStr(str: "Continue to checkout the selected membership plan")
                }else{
                    messageStr = getLocalizedStr(str: "Please subscribe to any of the membership plan")
                }
                
                let alert = UIAlertController(title: "", message: messageStr, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: getLocalizedStr(str: "Continue"), style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        self.performSegue(withIdentifier: QMTLConstants.Segue.segueCulturePassTableViewController, sender: nil)
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
    
    func findUserProfileToCheckEmailIdAlreadyExist() {
        let result = findPersonResponseJsonValue[QMTLConstants.PersonKeys.result].arrayValue
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
    
    //MARK:- Show Toast
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height/2 - 17, width: 150, height: 35))
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
//        scrollToTop()
//        
//        self.view.makeToast(getLocalizedStr(str: message), duration: 2.0, position: .center, style: toastStyle)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//            self.view.hideAllToasts()
//        })
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
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
    
    //MARK:- IBAction
    
    @IBAction func tANDcBtnAction(_ sender: Any) {
        
        if isAgreementChecked {
            let image = UIImage(named: "unchecked.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            TandCbtn.setImage(image, for: .normal)
            isAgreementChecked = false
        }else{
            let image = UIImage(named: "checked.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            TandCbtn.setImage(image, for: .normal)
            isAgreementChecked = true
        }
    }
    
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
    
    @objc func membershipViewTapAction(sender: UITapGestureRecognizer? = nil) {
            //self.performSegue(withIdentifier: QMTLConstants.Segue.segueCulturePassTableViewController, sender: nil)
        for vc in (self.navigationController?.viewControllers ?? []) {
            print("view controller presented is ",vc);
            if vc is CulturePassTableViewController {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                let culturePassTableViewController = CulturePassTableViewController()
                culturePassTableViewController.isFromSignUpPage = true
                break
            }
        }
    }
    
    func callSavePerson(){
        
        var valDict = [String:Any]()
        
        valDict[QMTLConstants.PersonKeys.username] = emailTxtField.text
        valDict[QMTLConstants.PersonKeys.email] = emailTxtField.text
        valDict[QMTLConstants.PersonKeys.password] = passTxtFld.text
        
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
        apiServices.savePerson(searchCriteria: valDict, serviceFor: QMTLConstants.ServiceFor.savePerson, view: self.view,isToEditUser: false)
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
    
    //MARK:- TabBar Delegate
    
    func backBtnSelected() {
        print("Guest page backBtnSelected")
        //self.navigationController?.popViewController(animated: false)
        for vc in (self.navigationController?.viewControllers ?? []) {
            print("view controller presented is ",vc);
            if vc is CulturePassTableViewController {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
        //self.dismiss(animated: false, completion: nil);
    }
    
    func bottomBtnAction() {
        if isValid(){
            //callSavePerson()
            let searchCriteria = [QMTLConstants.PersonKeys.email:emailTxtField.text]
            apiServices.findPerson(searchCriteria: searchCriteria as! [String : String], serviceFor: QMTLConstants.ServiceFor.findPerson, view: self.view)
        }
    }
    
    //MARK:- Validation
    
    func isValid() -> Bool {
        var returnVal = true
        
        let email = emailTxtField.text
        let password = passTxtFld.text
        let confPassword = confPassTxtFld.text
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
        }else if password?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            passTxtFld.becomeFirstResponder()
            showToast(message: "Please enter new password")
        }else if !isValidPassword(value: password!){
            returnVal = false
            passTxtFld.becomeFirstResponder()
            showToast(message: "Password should have atlease 1 character, 1 number, 1 special character and minimum 6 characters")
        }else if confPassword?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            confPassTxtFld.becomeFirstResponder()
            showToast(message: "Please re enter password")
        }else if password != confPassword {
            returnVal = false
            confPassTxtFld.text = ""
            confPassTxtFld.becomeFirstResponder()
            showToast(message: "Re entered password is not matching with new password")
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
            mobileNumTxtFld.becomeFirstResponder()
            showToast(message: "Please enter valid mobile number")
        }else if !isAgreementChecked {
            returnVal = false
            showToast(message: "Please accept terms and conditions")
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
    
    func isValidPassword(value: String) -> Bool{
        let pwdRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[d$@$!%_.*?&#])[A-Za-z\\dd$@$!%_.*?&#]{6,}$"
        
        let pwd = NSPredicate(format:"SELF MATCHES %@", pwdRegEx)
        return pwd.evaluate(with: value)
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
            let indexPath = IndexPath(item: 0, section: 3)
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
        case passTxtFld:
            indexPath = IndexPath(item: 0, section: 1)
            break
        case confPassTxtFld:
            indexPath = IndexPath(item: 0, section: 2)
            break
        case titleTxtFld,fNameTxtFld,lNameTxtFld,contryOfResTxtFld,nationalityTxtFld,phoneCodeTxtFld,mobileNumTxtFld:
            indexPath = IndexPath(item: 0, section: 3)
            break
        default:
            break
        }
        
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        let ACCEPTABLE_ALPHA_NUMERIC_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@"
        let PASSWORD_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@$!%*?&#"
        let ACCEPTABLE_NUMBERS = "0123456789+"
        
        var returnVal = true
        let currentCharacterCount = textField.text?.count ?? 0
        
        switch textField {
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
        case passTxtFld,confPassTxtFld:
            
            let cs = NSCharacterSet(charactersIn: PASSWORD_CHARACTERS).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if !(string == filtered){
                return false
            }
            
            
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            returnVal = newLength <= 16
            break
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
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        
        emailTxtField.placeholder = getLocalizedStr(str: emailTxtField.placeholder!)
        passTxtFld.placeholder = getLocalizedStr(str: passTxtFld.placeholder!)
        confPassTxtFld.placeholder = getLocalizedStr(str: confPassTxtFld.placeholder!)
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
        i_15.decideTextDirection()
        
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
        i_15.text = getLocalizedStr(str: i_15.text!)
        
        i_14_TandCBtn.setTitle(getLocalizedStr(str: i_14_TandCBtn.titleLabel!.text!), for: .normal)
        
        if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
            i_14_TandCBtn.titleLabelFont =  UIFont.init(name: "DINNextLTPro-Bold", size: 15)
            //nxtBtn.setTitle ("Next", for: .normal);
        }
        else{
            i_14_TandCBtn.titleLabelFont = UIFont.init(name: "DINNextLTArabic-Bold", size: 15)
            //nxtBtn.setTitle ("التالي", for: .normal);
        }
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == QMTLConstants.Segue.segueCulturePassTableViewController{
            
            let culturePassTableViewController:CulturePassTableViewController = segue.destination as! CulturePassTableViewController
            culturePassTableViewController.isFromSignUpPage = true
            
        }
    }
    

}
