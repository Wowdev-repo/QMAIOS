//
//  CPFilterViewController+PickerView.swift
//  QatarMuseums
//
//  Created by Wakralab Software Labs on 25/06/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Crashlytics
import Firebase
import UIKit

extension CPFilterViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    
    func addPickerView() {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.frame = CGRect(x: 20, y: UIScreen.main.bounds.height-200, width: self.view.frame.width - 40, height: 200)
        picker.backgroundColor = UIColor.whiteColor
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        institutionText.inputView = picker
        institutionText.inputAccessoryView = pickerToolBar
        ageGroupText.inputView = picker
        ageGroupText.inputAccessoryView = pickerToolBar
        programmeTypeText.inputView = picker
        programmeTypeText.inputAccessoryView = pickerToolBar
    }
    //MARK: Pickerview delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if(picker.tag == 0) {
            return institutionArray.count
        } else if(picker.tag == 1) {
            return ageGroupArray.count
        } else {
            return programmeTypeArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        let pickerLabel = UITextView()
        var pickerTitle : String?
        if (picker.tag == 0) {
            pickerTitle = institutionArray[row] as? String
            selectedInstitution = (institutionArray[row] as? String)!
        } else if(picker.tag == 1) {
            pickerTitle = ageGroupArray[row] as? String
            selectedageGroup = (ageGroupArray[row] as? String)!
        } else {
            pickerTitle = programmeTypeArray[row] as? String
            selectedProgramme = (programmeTypeArray[row] as? String)!
        }
        pickerLabel.text = pickerTitle
        pickerLabel.font = UIFont.closeButtonFont
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        DDLogInfo(NSStringFromClass(type(of: self)) + "Function: \(#function), line: \(#line)")
        if (picker.tag == 0) {
            selectedInstitutionRow = row
            selectedInstitution = (institutionArray[row] as? String)!
            institutionText.text = (institutionArray[row] as? String)!
            institutionPass = (institutionPassArray[row] as? String)!
        } else if(picker.tag == 1) {
            selectedAgeGroupRow = row
            selectedageGroup = (ageGroupArray[row] as? String)!
            ageGroupText.text = (ageGroupArray[row] as? String)!
            ageGroupPass = (ageGroupPassArray[row] as? String)!
        } else {
            selectedProgrammeRow = row
            selectedProgramme = (programmeTypeArray[row] as? String)!
            programmeTypeText.text = (programmeTypeArray[row] as? String)!
            programmePass = (programmePassArray[row] as? String)!
        }
    }
}
