//
//  ForgotPasswordViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 24/03/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import Toast_Swift
import SwiftyJSON


class ForgotPasswordViewController: UIViewController, UITextFieldDelegate,QMTLTabViewControllerDelegate,APIServiceResponse, APIServiceProtocolForConnectionError  {

    //MARK:- Decleration
    var tabViewController = QMTLTabViewController()
    var apiServices = QMTLAPIServices()
    
    var findPersonResponseJsonValue : JSON = []
    
    //MARK:- IBOutlet
    @IBOutlet weak var fieldsContainerView: UIView!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var resetLinkContainerView: UIView!
    
    @IBOutlet weak var emailTxtFld: UITextField!
    
    @IBOutlet weak var i_1: UILabel!
    @IBOutlet weak var i_2: UILabel!
    @IBOutlet weak var i_3: UILabel!
    
    
    var toastStyle = ToastStyle()
    
    //MARK:- Controller Default
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        toastStyle.messageColor = .white
        toastStyle.backgroundColor = .darkGray
        
        apiServices.delegateForConnectionError = self
        apiServices.delegateForAPIServiceResponse = self
        
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
        emailTxtFld.text = ""
    }
    
    //MARK:-
    
    func viewSetup(){
        localizationSetup()
        
        fieldsContainerView.layer.cornerRadius = 10.0
        
        emailContainerView.layer.cornerRadius = 10.0
        resetLinkContainerView.layer.cornerRadius = 10.0
        
        resetLinkContainerView.layer.borderColor = UIColor.darkGray.cgColor
        resetLinkContainerView.layer.borderWidth = 1.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.changePWLinkViewTapAction(sender:)))
        resetLinkContainerView.addGestureRecognizer(tap)
    }
    
    @objc func changePWLinkViewTapAction(sender: UITapGestureRecognizer? = nil) {
        print("changePWLinkViewTapAction")
        
        if isValid() {
            
            let searchCriteria = [QMTLConstants.PersonKeys.email:emailTxtFld.text]
            apiServices.findPerson(searchCriteria: searchCriteria as! [String : String], serviceFor: QMTLConstants.ServiceFor.findPerson, view: self.view)
            
        }
    }
    
    
    //MARK:- API Service Delegate
    
    func connectionError(ConnectionErrInfo errInfo: String?, StatusCode statusCode: Int) {
        print("Forgot Password Error ResponseJSON = \(String(describing: errInfo))")
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success Response JSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.findPerson:
                findPersonResponseJsonValue = json
                setUpUserProfile()
                break
            case QMTLConstants.ServiceFor.PasswordReset:
               //showToast(message: "Password reset link has been sent to your mail")
               self.navigationController?.popViewController(animated: false)

                break
            default:
                break
            }
        }        
    }
    
    func setUpUserProfile() {
        let result = findPersonResponseJsonValue[QMTLConstants.PersonKeys.result].arrayValue
        if result.count > 0 {
            let resultObj = result[0]
            //let credentialObj = resultObj[QMTLConstants.PersonKeys.credential].dictionaryValue
            
            //let userName = credentialObj[QMTLConstants.PersonKeys.username]?.stringValue
            let personEmail = resultObj[QMTLConstants.PersonKeys.email].stringValue
            let personID = resultObj[QMTLConstants.PersonKeys.id].stringValue
            
            apiServices.forgotPasswordLink(emailStr: personEmail, username: QMTLConstants.QMAPI.userName, password: QMTLConstants.QMAPI.password, personID: personID, serviceFor: QMTLConstants.ServiceFor.PasswordReset, view: self.view)
            
            showToast(message: "Password reset link has been sent to your mail")
        }else{
            showToast(message: "Failed to find your Profile Kindly try with Correct email")
        }
    }
    
    //MARK:- Show Toast
    
//    func showToast(message : String){
//
//
//
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
    @IBAction func doneBtnAction(_ sender : Any){
        
        
        
    }
    
    //MARK:- Validation
    
    func isValid() -> Bool {
        var returnVal = true
        
        let emailStr = emailTxtFld.text
        
        if emailStr?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            emailTxtFld.becomeFirstResponder()
            showToast(message: "Please enter email id")
        }else if !isValidEmail(emailAddressString: emailStr ?? ""){
            returnVal = false
            emailTxtFld.becomeFirstResponder()
            showToast(message: "Please enter valid email id")
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
    
    //MARK:- UITextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@"
        
        var returnVal = false
        let currentCharacterCount = textField.text?.count ?? 0
        
        switch textField {
        case emailTxtFld:
            
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
    
    
    //MARK:- TabBar Delegate
    
    func backBtnSelected() {
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK:- Localization
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        
        i_1.text = getLocalizedStr(str: i_1.text!)
        i_2.text = getLocalizedStr(str: i_2.text!)
        i_3.text = getLocalizedStr(str: i_3.text!)
        
        emailTxtFld.placeholder = getLocalizedStr(str: emailTxtFld.placeholder!)
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
