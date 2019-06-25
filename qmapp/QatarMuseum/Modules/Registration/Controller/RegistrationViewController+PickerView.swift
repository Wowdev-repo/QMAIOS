//
//  RegistrationViewController+PickerView.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 24/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation

extension RegistrationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: PickerView
    func addPickerView() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if(picker.tag == 0) {
            return titleArray.count
        } else if(picker.tag == 1) {
            return countryArray.count
        } else {
            return nationalityArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
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
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
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
}
