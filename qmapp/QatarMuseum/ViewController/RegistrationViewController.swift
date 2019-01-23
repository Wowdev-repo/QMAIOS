//
//  RegistrationViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 18/10/18.
//  Copyright © 2018 Wakralab. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, HeaderViewProtocol, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var tellUsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var countryText: UITextField!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var nationalityView: UIView!
    @IBOutlet weak var nationalityText: UITextField!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var mobileNumberView: UIView!
    @IBOutlet weak var mobileNumberText: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet var pickerToolBar: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var picker = UIPickerView()
    var titleArray = NSArray()
    var countryArray = NSArray()
    var nationalityArray = NSArray()
    var selectedTitleRow = 0
    var selectedCountryRow = 0
    var selectedNationalityRow = 0
    var selectedTitle = String()
    var selectedCountry = String()
    var selectedNationality = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
    }
    
    func setUpUi() {
        headerView.headerViewDelegate = self
        headerView.headerBackButton.setImage(UIImage(named: "closeX1"), for: .normal)
        self.headerView.headerBackButton.contentEdgeInsets = UIEdgeInsets(top: 13, left: 18, bottom: 13, right: 18)
        headerView.headerTitle.text = NSLocalizedString("CULTURE_BECOME_A_MEMBER", comment: "CULTURE_BECOME_A_MEMBER in the Registration page")
        mainTitleLabel.font = UIFont.startTourFont
        titleLabel.font = UIFont.startTourFont
        userNameLabel.font = UIFont.headerFont
        userNameText.font = UIFont.settingsUpdateLabelFont
        emailLabel.font = UIFont.headerFont
        emailText.font = UIFont.settingsUpdateLabelFont
        passwordLabel.font = UIFont.headerFont
        passwordText.font = UIFont.settingsUpdateLabelFont
        confirmPasswordLabel.font = UIFont.headerFont
        confirmPasswordText.font = UIFont.settingsUpdateLabelFont
        tellUsLabel.font = UIFont.startTourFont
        titleLabel.font = UIFont.headerFont
        titleText.font = UIFont.settingsUpdateLabelFont
        firstNameLabel.font = UIFont.headerFont
        firstNameText.font = UIFont.settingsUpdateLabelFont
        lastNameLabel.font = UIFont.headerFont
        lastNameText.font = UIFont.settingsUpdateLabelFont
        countryLabel.font = UIFont.headerFont
        countryText.font = UIFont.settingsUpdateLabelFont
        nationalityLabel.font = UIFont.headerFont
        nationalityText.font = UIFont.settingsUpdateLabelFont
        mobileNumberLabel.font = UIFont.headerFont
        mobileNumberText.font = UIFont.settingsUpdateLabelFont
        createAccountButton.titleLabel?.font = UIFont.startTourFont
        
        passwordText.isSecureTextEntry = true
        confirmPasswordText.isSecureTextEntry = true
        let placeholderSelectValue = NSLocalizedString("SELECT_A_VALUE", comment: "SELECT_A_VALUE in the Registration page")
        userNameLabel.text = NSLocalizedString("USERNAME", comment: "USERNAME in the Registration page")
        mainTitleLabel.text = NSLocalizedString("CREATE_YOUR_ACCOUNT", comment: "CREATE_YOUR_ACCOUNT in the Registration page")
        emailLabel.text = NSLocalizedString("EMAIL", comment: "EMAIL in the Registration page")
        passwordLabel.text = NSLocalizedString("PASSWORD", comment: "PASSWORD in the Registration page")
        confirmPasswordLabel.text = NSLocalizedString("CONFIRM_PASSWORD", comment: "CONFIRM_PASSWORD in the Registration page")
        tellUsLabel.text = NSLocalizedString("TELL_US_MORE", comment: "TELL_US_MORE in the Registration page")
        titleLabel.text = NSLocalizedString("TITLE", comment: "TITLE in the Registration page")
        firstNameLabel.text = NSLocalizedString("FIRST_NAME", comment: "FIRST_NAME in the Registration page")
        lastNameLabel.text = NSLocalizedString("LAST_NAME", comment: "LAST_NAME in the Registration page")
        countryLabel.text = NSLocalizedString("COUNTRY", comment: "COUNTRY in the Registration page")
        nationalityLabel.text = NSLocalizedString("NATIONALITY", comment: "NATIONALITY in the Registration page")
        mobileNumberLabel.text = NSLocalizedString("MOBILE_NUMBER", comment: "MOBILE_NUMBER in the Registration page")
        createAccountButton.setTitle(NSLocalizedString("CREATE_ACCOUNT", comment: "CREATE_ACCOUNT in the Registration page"), for: .normal)
        
        titleText.placeholder = placeholderSelectValue
        countryText.placeholder = placeholderSelectValue
        nationalityText.placeholder = placeholderSelectValue
        
        userNameView.layer.borderWidth = 1
        userNameView.layer.borderColor = UIColor.lightGray.cgColor
        emailView.layer.borderWidth = 1
        emailView.layer.borderColor = UIColor.lightGray.cgColor
        passwordView.layer.borderWidth = 1
        passwordView.layer.borderColor = UIColor.lightGray.cgColor
        confirmPasswordView.layer.borderWidth = 1
        confirmPasswordView.layer.borderColor = UIColor.lightGray.cgColor
        titleView.layer.borderWidth = 1
        titleView.layer.borderColor = UIColor.lightGray.cgColor
        firstNameView.layer.borderWidth = 1
        firstNameView.layer.borderColor = UIColor.lightGray.cgColor
        lastNameView.layer.borderWidth = 1
        lastNameView.layer.borderColor = UIColor.lightGray.cgColor
        countryView.layer.borderWidth = 1
        countryView.layer.borderColor = UIColor.lightGray.cgColor
        nationalityView.layer.borderWidth = 1
        nationalityView.layer.borderColor = UIColor.lightGray.cgColor
        mobileNumberView.layer.borderWidth = 1
        mobileNumberView.layer.borderColor = UIColor.lightGray.cgColor
        
        titleArray = ["MRS","MR","MS","MISS","MASTER","DR","PROFESSOR",]
        countryArray = ["QATAR","AFGHANISTAN","ALAND ISLANDS","ALBANIA"]
        nationalityArray = ["QATAR","AFGHANISTAN","ALAND ISLANDS","ALBANIA"]
        
        userNameText.delegate = self
        emailText.delegate = self
        passwordText.delegate = self
        confirmPasswordText.delegate = self
        titleText.delegate = self
        firstNameText.delegate = self
        lastNameText.delegate = self
        countryText.delegate = self
        nationalityText.delegate = self
        mobileNumberText.delegate = self
        addPickerView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func didTapCreateAccount(_ sender: UIButton) {
        let profileView =  self.storyboard?.instantiateViewController(withIdentifier: "profileViewId") as! ProfileViewController
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        self.present(profileView, animated: false, completion: nil)
        
    }
    
    @IBAction func createAccountTouchDown(_ sender: UIButton) {
    }
    
    @IBAction func didTapTitleButton(_ sender: UIButton) {
        self.titleText.becomeFirstResponder()
    }
    
    @IBAction func didTapCountryButton(_ sender: UIButton) {
        self.countryText.becomeFirstResponder()
    }
    
    @IBAction func didTapNationality(_ sender: UIButton) {
         self.nationalityText.becomeFirstResponder()
    }
    
    //MARK: TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        var viewForTextField : UIView!
        if (textField == titleText) {
            picker.tag = 0
            picker.selectRow(selectedTitleRow, inComponent: 0, animated: true)
            viewForTextField = titleView
        } else if(textField == countryText) {
            picker.tag = 1
            picker.selectRow(selectedCountryRow, inComponent: 0, animated: true)
            viewForTextField = countryView
        } else if(textField == nationalityText) {
            picker.tag = 2
            picker.selectRow(selectedNationalityRow, inComponent: 0, animated: true)
            viewForTextField = nationalityView
        } else if(textField == userNameText) {
            viewForTextField = userNameView
        } else if(textField == emailText) {
            viewForTextField = emailView
        } else if(textField == passwordText) {
            viewForTextField = passwordView
        } else if(textField == confirmPasswordText) {
            viewForTextField = confirmPasswordView
        } else if(textField == firstNameText) {
            viewForTextField = firstNameView
        } else if(textField == lastNameText) {
            viewForTextField = lastNameView
        } else if(textField == mobileNumberText) {
            viewForTextField = mobileNumberView
        }
        let myScreenRect: CGRect = UIScreen.main.bounds
        let pickerHeight : CGFloat = 200
        UIView.beginAnimations( "animateView", context: nil)
        var needToMove: CGFloat = 0
        
        var frame : CGRect = self.view.frame
        if (viewForTextField.frame.origin.y - scrollView.contentOffset.y + viewForTextField.frame.size.height+100  > (myScreenRect.size.height - (pickerHeight+50))) {
            needToMove = (viewForTextField.frame.origin.y - scrollView.contentOffset.y + viewForTextField.frame.size.height+70 ) - (myScreenRect.size.height - pickerHeight-100)
        }
        frame.origin.y = -needToMove
        self.view.frame = frame
        UIView.commitAnimations()
        
        picker.reloadAllComponents()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.beginAnimations( "animateView", context: nil)
        var frame : CGRect = self.view.frame
        frame.origin.y = 0
        self.view.frame = frame
        UIView.commitAnimations()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userNameText.resignFirstResponder()
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        confirmPasswordText.resignFirstResponder()
        titleText.resignFirstResponder()
        firstNameText.resignFirstResponder()
        lastNameText.resignFirstResponder()
        countryText.resignFirstResponder()
        nationalityText.resignFirstResponder()
        mobileNumberText.resignFirstResponder()
        
        return true
    }
    
    //MARK: PickerView
    func addPickerView() {
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.frame = CGRect(x: 20, y: UIScreen.main.bounds.height-200, width: self.view.frame.width - 40, height: 200)
        picker.backgroundColor = UIColor.whiteColor
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        titleText.inputView = picker
        titleText.inputAccessoryView = pickerToolBar
        countryText.inputView = picker
        countryText.inputAccessoryView = pickerToolBar
        nationalityText.inputView = picker
        nationalityText.inputAccessoryView = pickerToolBar
    }
    
    //MARK: Pickerview delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(picker.tag == 0) {
            return titleArray.count
        } else if(picker.tag == 1) {
            return countryArray.count
        } else {
            return nationalityArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UITextView()
        var pickerTitle : String?
        if (picker.tag == 0) {
            pickerTitle = titleArray[row] as? String
            selectedTitle = (titleArray[row] as? String)!
        } else if(picker.tag == 1) {
            pickerTitle = countryArray[row] as? String
            selectedCountry = (countryArray[row] as? String)!
        } else {
            pickerTitle = nationalityArray[row] as? String
            selectedNationality = (nationalityArray[row] as? String)!
        }
        pickerLabel.text = pickerTitle
        pickerLabel.font = UIFont.closeButtonFont
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (picker.tag == 0) {
            selectedTitleRow = row
            selectedTitle = (titleArray[row] as? String)!
            titleText.text = (titleArray[row] as? String)!
        } else if(picker.tag == 1) {
            selectedCountryRow = row
            selectedCountry = (countryArray[row] as? String)!
            countryText.text = (countryArray[row] as? String)!
            
        } else {
            selectedNationalityRow = row
            selectedNationality = (nationalityArray[row] as? String)!
            nationalityText.text = (nationalityArray[row] as? String)!
        }
    }
    
    @IBAction func didTapPickerCancel(_ sender: UIButton) {
        titleText.resignFirstResponder()
        countryText.resignFirstResponder()
        nationalityText.resignFirstResponder()
    }
    
    @IBAction func didTapPickerDone(_ sender: UIButton) {
        if (picker.tag == 0) {
            titleText.text = selectedTitle
        } else if(picker.tag == 1) {
            countryText.text = selectedCountry
        } else {
            nationalityText.text = selectedNationality
        }
        titleText.resignFirstResponder()
        countryText.resignFirstResponder()
        nationalityText.resignFirstResponder()
    }
    
    //MARK: Header delegate
    func headerCloseButtonPressed() {
        self.dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    

}
