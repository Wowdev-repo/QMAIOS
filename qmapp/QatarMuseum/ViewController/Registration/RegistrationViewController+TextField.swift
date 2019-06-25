//
//  RegistrationViewController+TextField.swift
//  QatarMuseums
//
//  Created by Exalture on 24/06/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation

extension RegistrationViewController: UITextFieldDelegate {
    
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
}
