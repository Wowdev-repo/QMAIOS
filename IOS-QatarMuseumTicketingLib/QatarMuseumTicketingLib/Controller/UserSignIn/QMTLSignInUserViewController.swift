//
//  SignInUserViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 28/02/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import Toast_Swift
import SwiftyJSON
import KeychainSwift

protocol QMTLSignInUserViewControllerDelegate: class {
    func signinSuccess()
}

class QMTLSignInUserViewController: UIViewController, UITextFieldDelegate, APIServiceResponse, APIServiceProtocolForConnectionError,QMTLTabViewControllerDelegate {
    
    //MARK:- Decleration
    let additionalSafeAreaInset = 20
    
    var tabViewController = QMTLTabViewController()
    var apiServices = QMTLAPIServices()
    let keychain = KeychainSwift()
    
    var guestUserViewController = QMTLGuestUserViewController()
    
    var userAuthResponseJsonValue : JSON = []
    
    var isFromGuestUserPage = false
     var isFromSelectTicketPage = false

    //MARK:- IBOutlet
    
    @IBOutlet weak var i_SignIn_Lbl: UILabel!
    @IBOutlet weak var i_Info_Lbl: UILabel!
    @IBOutlet weak var i_ForgotPass_Btn: UIButton!
    @IBOutlet weak var i_SignUp_Btn: UIButton!
    @IBOutlet weak var i_Login_Btn: UIButton!
    
    @IBOutlet weak var fieldsContainerView: UIView!
    @IBOutlet weak var emailIdTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var scrollView : UIScrollView!
    
    //MARK:- Decleration
    var qmtlSignInUserViewControllerDelegate : QMTLSignInUserViewControllerDelegate?

    var toastStyle = ToastStyle()

    
    //MARK:- Controller Defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        apiServices.delegateForConnectionError = self
        apiServices.delegateForAPIServiceResponse = self
        
        toastStyle.messageColor = .white
        toastStyle.backgroundColor = .darkGray
        
        viewSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.qmtlTabViewControllerDelegate = self
        tabViewController.topTabBarView.myProfileBtn.isHidden = true
        
        if QMTLSingleton.sharedInstance.userInfo.isLoggedIn{
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        emailIdTxt.text = ""
        passwordTxt.text = ""
    }
    
    //MARK:- API Service Callers
    
    func authenticateUser(username : String, password : String){
        let searchCriteria = [QMTLConstants.UserValues.username:username,QMTLConstants.UserValues.password:password]
        apiServices.authenticateUser(searchCriteria: searchCriteria, serviceFor: QMTLConstants.ServiceFor.authenticateUser, view: self.view)
    }
    
    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("SignIn Error ResponseJSON = \(String(describing: errInfo))")
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.authenticateUser:
                userAuthResponseJsonValue = json
                setUpUser()
                break
            default:
                break
            }
        }
        
        
    }
    
    //MARK:-
    
    func setUpUser() {
        
        let results = userAuthResponseJsonValue[QMTLConstants.UserValues.result].dictionaryValue
        let hasSucceeded = results[QMTLConstants.UserValues.hasSucceeded]?.boolValue
        
        
        if hasSucceeded ?? false {
            //self.view.makeToast("You are logged in successfully", duration: 2.0, position: .center, style: toastStyle)
            
            let person = results[QMTLConstants.UserValues.person]?.dictionaryValue
            let id = results[QMTLConstants.UserValues.personId]?.stringValue ?? ""
            let name = person?[QMTLConstants.UserValues.name]?.dictionaryValue
            let firstName = name?[QMTLConstants.UserValues.first]?.stringValue ?? ""
            let lastName = name?[QMTLConstants.UserValues.last]?.stringValue ?? ""
            let email = person?[QMTLConstants.UserValues.email]?.stringValue ?? ""
            let phone = person?[QMTLConstants.UserValues.phone]?.stringValue ?? ""
            
            
            QMTLSingleton.sharedInstance.userInfo.id = id
            QMTLSingleton.sharedInstance.userInfo.name = "\(firstName) \(lastName)"
            QMTLSingleton.sharedInstance.userInfo.email = email
            QMTLSingleton.sharedInstance.userInfo.phone = phone
            QMTLSingleton.sharedInstance.userInfo.username = emailIdTxt.text ?? ""
            QMTLSingleton.sharedInstance.userInfo.password = passwordTxt.text ?? ""
            QMTLSingleton.sharedInstance.userInfo.isLoggedIn = true
            
            
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.username, forKey: QMTLConstants.UserValues.username)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.password, forKey: QMTLConstants.UserValues.password)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.id, forKey: QMTLConstants.UserValues.personId)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.name, forKey: QMTLConstants.UserValues.name)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.email, forKey: QMTLConstants.UserValues.email)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.phone, forKey: QMTLConstants.UserValues.phone)
            self.keychain.set(QMTLSingleton.sharedInstance.userInfo.isLoggedIn, forKey: QMTLConstants.UserValues.isLoggedIn)
            
            //self.qmtlSignInUserViewControllerDelegate?.signinSuccess()
        guestUserViewController.qmtlGuestUserViewControllerDelegate?.continueUserSignIn()
            //guestUserViewController.navigationController?.popViewController(animated: false)
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            showToast(message: "Username or password is wrong")
            //emailIdTxt.text = ""
            //passwordTxt.text = ""
            //emailIdTxt.becomeFirstResponder()
        }
    }
    
    //MARK:-
    
    func viewSetup(){
        
        localizationSetup()
        
        fieldsContainerView.layer.cornerRadius = 10.0
        
        if isFromGuestUserPage {
            i_SignUp_Btn.isHidden = true
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
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height/2 - 17, width: 250, height: 35))
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
    
    //MARK:- IBAction
    @IBAction func backBtnAction(_ sender : Any){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signinBtnAction(_ sender:Any){
        
        if isValid() {
            authenticateUser(username: emailIdTxt.text ?? "", password: passwordTxt.text ?? "")
        }
        
    }

    //MARK:- Validation
    
    func isValid() -> Bool {
        var returnVal = true
        
        let usernameStr = emailIdTxt.text
        let passwordStr = passwordTxt.text
        
        if usernameStr?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            //emailIdTxt.becomeFirstResponder()
            showToast(message: "Please enter Email Id")
        }else if !isValidEmail(emailAddressString: usernameStr ?? ""){
            returnVal = false
            //emailIdTxt.becomeFirstResponder()
            showToast(message: "Please enter Valid Email Id")
        }else if passwordStr?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            //passwordTxt.becomeFirstResponder()
            showToast(message: "Please enter password")
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
    
    // MARK:- KeyBoard Show or Hide
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    //MARK:- UITextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*€£¥₩_.,-'?\""
        
        var returnVal = false
        let currentCharacterCount = textField.text?.count ?? 0
        
        switch textField {
        case emailIdTxt,passwordTxt:
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
        default:
            break
        }
        
        return returnVal
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case emailIdTxt:
            passwordTxt.becomeFirstResponder()
            break
        case passwordTxt:
            passwordTxt.resignFirstResponder()
            break
        default:
            break
        }
        
        return true
    }
    
    //MARK:- TabBar Delegate
    
    func backBtnSelected() {
        
        if !QMTLSingleton.sharedInstance.userInfo.isLoggedIn {
            
            if isFromGuestUserPage {
                self.navigationController?.popViewController(animated: true)
            }
            else if UserDefaults.standard.bool(forKey: "FromTicket"){
                tabViewController.selectedIndex = 0
                UserDefaults.standard.set(false, forKey: "FromTicket")
                 UserDefaults.standard.set(true, forKey: "FromSignin")
            }
            else if (QMTLSingleton.sharedInstance.isGuestCheckout) {
                    QMTLSingleton.sharedInstance.isGuestCheckout = false
                    tabViewController.selectedIndex = 0
                } else {
                    tabViewController.dismiss(animated: true, completion: nil)
                }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
     //MARK: - Navigation

     //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
         //Pass the selected object to the new view controller.
        print ("sing up segue prepare");
        if segue.identifier == QMTLConstants.Segue.segueCulturePassList{
            print ("sing up segue prepare segueCulturePassList");
            let culturePassTableViewController:CulturePassTableViewController = segue.destination as! CulturePassTableViewController
            culturePassTableViewController.isFromLoginPage = true
            
        }
    }
    
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        
        i_SignIn_Lbl.text =  getLocalizedStr(str: i_SignIn_Lbl.text!)
        i_Info_Lbl.text = getLocalizedStr(str: i_Info_Lbl.text!)
        emailIdTxt.placeholder = getLocalizedStr(str: emailIdTxt.placeholder!)
        passwordTxt.placeholder = getLocalizedStr(str: passwordTxt.placeholder!)
        i_ForgotPass_Btn.setTitle(getLocalizedStr(str: i_ForgotPass_Btn.titleLabel!.text!), for: .normal)
        i_SignUp_Btn.setTitle(NSLocalizedString(getLocalizedStr(str: i_SignUp_Btn.titleLabel!.text!),comment: ""), for: .normal)
        
        i_Login_Btn.setTitle(NSLocalizedString(getLocalizedStr(str: i_Login_Btn.titleLabel!.text!),comment: ""), for: .normal)
        
    }

}
