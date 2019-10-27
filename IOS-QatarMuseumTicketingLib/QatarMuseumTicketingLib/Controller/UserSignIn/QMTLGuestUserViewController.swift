//
//  GuestUserViewController.swift
//  QatarMuseumTicketingLib
//
//  Created by Jeeva.S.K on 28/02/19.
//  Copyright © 2019 iProtecs. All rights reserved.
//

import UIKit
import Toast_Swift
import SwiftyJSON
import ActionSheetPicker_3_0
import Reachability

protocol QMTLGuestUserViewControllerDelegate: class {
    func continueUserSignIn()
}

class QMTLGuestUserViewController: UIViewController,QMTLSignInUserViewControllerDelegate,QMTLTabViewControllerDelegate,UITextFieldDelegate,APIServiceResponse, APIServiceProtocolForConnectionError {
    
    //MARK:- Decleration
    var apiServices = QMTLAPIServices()
    var listCountriesResponseJsonValue : JSON = []
    
    var isAgreementChecked = false
    
    //MARK:- IBOutlet
    @IBOutlet weak var nameTxtFld: UITextField!
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var phoneTxtFld: UITextField!
    @IBOutlet weak var nationalityTxtFld: UITextField!
    
    @IBOutlet weak var fieldsContainerView: UIView!
    
    @IBOutlet weak var tAndcBtn: UIButton!
    @IBOutlet weak var alreadyMemberBtn: UIButton!
    
    @IBOutlet weak var scrollView : UIScrollView!
    
    
    @IBOutlet weak var i_1: UILabel!
    @IBOutlet weak var i_2: UILabel!
    @IBOutlet weak var i_3_TandCBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    var attrs = [
        NSAttributedString.Key.font : UIFont.init(name: "DINNextLTArabic-Regular", size: 18) as Any,
        NSAttributedString.Key.foregroundColor : UIColor.black,
        NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]
    
    var attributedString = NSMutableAttributedString(string:"")
    
    //MARK:- Decleration
    var tabViewController = QMTLTabViewController()
    
    var qmtlGuestUserViewControllerDelegate : QMTLGuestUserViewControllerDelegate?
    
    //MARK:- Controller Defaults
    override func viewDidLoad() {
        
        super.viewDidLoad()
        UserDefaults.standard.set("TICKET", forKey: "SCREEN") //setObject

        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationItem.title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        apiServices.delegateForConnectionError = self
        apiServices.delegateForAPIServiceResponse = self
        
        viewSetup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabViewController =  self.navigationController?.tabBarController as! QMTLTabViewController
        tabViewController.qmtlTabViewControllerDelegate = self
        tabViewController.topTabBarView.myProfileBtn.isHidden = true
        
        if QMTLSingleton.sharedInstance.userInfo.isLoggedIn{
            self.navigationController?.popToRootViewController(animated: false)
        }
        
        if QMTLSingleton.sharedInstance.userInfo.name != "" {
            nameTxtFld.text = QMTLSingleton.sharedInstance.userInfo.name
            emailTxtFld.text = QMTLSingleton.sharedInstance.userInfo.email
            phoneTxtFld.text = QMTLSingleton.sharedInstance.userInfo.phone
            nationalityTxtFld.text = QMTLSingleton.sharedInstance.userInfo.nationality
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }
    
    //MARK:-
    
    func viewSetup(){
        localizationSetup()
        
        fieldsContainerView.layer.cornerRadius = 10.0
        tAndcBtn.layer.cornerRadius = 5.0
        alreadyMemberBtn.layer.cornerRadius = 5.0
        alreadyMemberBtn.layer.borderColor = UIColor.lightGray.cgColor
        alreadyMemberBtn.layer.borderWidth = 0.5
        
        if QMTLSingleton.sharedInstance.listCountriesArr.count == 0 {
            apiServices.getCountriesList(searchCriteria: [:], serviceFor: QMTLConstants.ServiceFor.ListCountries, view: self.view)
        }

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
        print("Guest User Error ResponseJSON = \(String(describing: errInfo))")
    }
    
    func responseWith(ResponseJSON json: JSON, StatusCode statusCode: Int, ServiceFor serviceFor: String) {
        print("\(serviceFor) Success ResponseJSON = \(json)")
        
        if statusCode == 200 {
            switch serviceFor {
            case QMTLConstants.ServiceFor.ListCountries:
                listCountriesResponseJsonValue = json
                setUpCountryList()
                break
            default:
                break
            }
        }
        
        
    }
    
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
        
    }
    
    //MARK:- QMTLSignInUserViewControllerDelegate
    func signinSuccess() {
        
        qmtlGuestUserViewControllerDelegate?.continueUserSignIn()
        self.navigationController?.popViewController(animated: true)
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
//        var style = ToastStyle()
//        style.messageColor = .white
//        style.backgroundColor = .darkGray
//        style.maxHeightPercentage = 10
//
//        self.view.makeToast(getLocalizedStr(str: message), duration: 2.0, position: .center, style: style)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//            self.view.hideAllToasts()
//        })
//    }
    //MARK:- Check Internet
    
    
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
    
    
    //MARK:- IBAction
    @IBAction func backBtnAction(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func alreadyMemberBtnAction(_ sender: Any){
        self.performSegue(withIdentifier: QMTLConstants.Segue.segueQMTLSignInUserViewController, sender: sender)
    }
    
    @IBAction func signUpBtnAction(_ sender: Any){
        self.performSegue(withIdentifier: QMTLConstants.Segue.segueCulturePassList, sender: sender)
    }
    
    @IBAction func continueBtnAction(_ sender: Any){
        
        if (internetConnected()){
            if isValid() {
                
                let name = nameTxtFld.text ?? ""
                
                QMTLSingleton.sharedInstance.userInfo.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                QMTLSingleton.sharedInstance.userInfo.email = emailTxtFld.text ?? ""
                QMTLSingleton.sharedInstance.userInfo.phone = phoneTxtFld.text ?? ""
                QMTLSingleton.sharedInstance.userInfo.nationality = nationalityTxtFld.text ?? ""
                qmtlGuestUserViewControllerDelegate?.continueUserSignIn()
                QMTLSingleton.sharedInstance.isGuestCheckout = true
                self.navigationController?.popViewController(animated: true)
            }
        }
        else{
            self.showToast(message:"CHECK_INTERNET")
        }
       
        
    }
    
    @IBAction func tANDcBtnAction(_ sender: Any) {
    
        if isAgreementChecked {
            let image = UIImage(named: "unchecked.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            tAndcBtn.setImage(image, for: .normal)
            isAgreementChecked = false
        }else{
            let image = UIImage(named: "checked.png",
                                in: QMTLSingleton.sharedInstance.bundle,
                                compatibleWith: nil)
            tAndcBtn.setImage(image, for: .normal)
            isAgreementChecked = true
        }
    }

    
    //MARK:- Validation
    
    func isValid() -> Bool {
        var returnVal = true
        
        let nameStr = nameTxtFld.text
        let emailStr = emailTxtFld.text
        
        if nameStr?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            //nameTxtFld.becomeFirstResponder()
            showToast(message: "Please enter name")
        }else if emailStr?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
            returnVal = false
            //emailTxtFld.becomeFirstResponder()
            showToast(message: "Please enter email id")
        }else if !isValidEmail(emailAddressString: emailStr ?? ""){
            returnVal = false
            //emailTxtFld.becomeFirstResponder()
            showToast(message: "Please enter valid email id")
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
    
    func showActionOptionsForTxtFlds(_ textField: UITextField){
        
        nameTxtFld.becomeFirstResponder()
        nameTxtFld.resignFirstResponder()
        
        var titleStr = ""
        var itemsArr = [String]()
        
        switch textField {
        case nationalityTxtFld:
            
            titleStr = self.getLocalizedStr(str: "Select Nationality")
            
            for country in QMTLSingleton.sharedInstance.listCountriesArr {
                itemsArr.append(country.name)
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
                textField.text = itemsArr[count]
                
                
                return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: self.view)
        
    }
    
    //MARK:- UITextField Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        var returnVal = true
        
        switch textField {
        case nationalityTxtFld:
            returnVal = false
            break
        default:
            break
        }
        
        if !returnVal {
            showActionOptionsForTxtFlds(textField)
        }
        
        return returnVal
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        let ACCEPTABLE_CHARACTERS_WITHSPACE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
        let ACCEPTABLE_ALPHA_NUMERIC_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@"
        let ACCEPTABLE_NUMBERS = "0123456789+"
        
        var returnVal = false
        let currentCharacterCount = textField.text?.count ?? 0
        
        switch textField {
        case nameTxtFld:
            let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS_WITHSPACE).inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if !(string == filtered){
                return true
            }
            
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            returnVal = newLength <= 50
            break
        case nationalityTxtFld:
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
        case emailTxtFld:
            
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
        case phoneTxtFld:
            
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
    
    //MARK:- TabBar Delegate
    
    func backBtnSelected() {
        print("Guest page backBtnSelected")
        self.navigationController?.popViewController(animated: true)
    }
    
    func getLocalizedStr(str : String) -> String{
        return NSLocalizedString(str.trimmingCharacters(in: .whitespacesAndNewlines),comment: "")
    }
    
    func localizationSetup(){
        
        i_1.text = getLocalizedStr(str: i_1.text!)
        i_2.text = getLocalizedStr(str: i_2.text!)
        i_3_TandCBtn.setTitle(getLocalizedStr(str: i_3_TandCBtn.titleLabel!.text!), for: .normal)
        nextBtn.setTitle(getLocalizedStr(str: nextBtn.titleLabel!.text!), for: .normal)
      
        let buttonTitleStr = NSMutableAttributedString(string:getLocalizedStr(str: "Existing Culture Pass Member?"), attributes:attrs)
        
        attributedString.append(buttonTitleStr)
        alreadyMemberBtn.setAttributedTitle(attributedString, for: .normal)
        
        
        if ((QMTLLocalizationLanguage.currentAppleLanguage()) == "en") {
            alreadyMemberBtn.titleLabelFont =  UIFont.init(name: "DINNextLTPro-Regular", size: 18)
            i_3_TandCBtn.titleLabelFont =  UIFont.init(name: "DINNextLTPro-Bold", size: 15)
             nextBtn.titleLabelFont =  UIFont.init(name: "DINNextLTPro-Bold", size: 18)
            
        }
        else{
            alreadyMemberBtn.titleLabelFont = UIFont.init(name: "DINNextLTArabic-Regular", size: 18)
            i_3_TandCBtn.titleLabelFont = UIFont.init(name: "DINNextLTArabic-Bold", size: 15)
            nextBtn.titleLabelFont =  UIFont.init(name: "DINNextLTArabic-Bold", size: 18)
            //nxtBtn.setTitle ("التالي", for: .normal);
        }
        
        nameTxtFld.placeholder = getLocalizedStr(str: nameTxtFld.placeholder!)
        emailTxtFld.placeholder = getLocalizedStr(str: emailTxtFld.placeholder!)
        phoneTxtFld.placeholder = getLocalizedStr(str: phoneTxtFld.placeholder!)
        nationalityTxtFld.placeholder = getLocalizedStr(str: nationalityTxtFld.placeholder!)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == QMTLConstants.Segue.segueQMTLSignInUserViewController{
            
            let signInViewController:QMTLSignInUserViewController = segue.destination as! QMTLSignInUserViewController
            signInViewController.qmtlSignInUserViewControllerDelegate = self
            signInViewController.guestUserViewController = self
            signInViewController.isFromGuestUserPage = true
        }
    }
    

}
