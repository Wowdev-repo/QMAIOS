//
//  FilterViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 22/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Crashlytics
import Firebase
import UIKit

class FilterViewController: UIViewController,HeaderViewProtocol,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    @IBOutlet weak var institutionTitleLabel: UILabel!
    @IBOutlet weak var ageGroupLabel: UILabel!
    @IBOutlet weak var programmeTypeLabel: UILabel!
    @IBOutlet weak var institutionText: UITextField!
    @IBOutlet weak var ageGroupText: UITextField!
    @IBOutlet weak var programmeTypeText: UITextField!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var pickerToolBar: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var institutionButton: UIButton!
    @IBOutlet weak var ageGroupButton: UIButton!
    @IBOutlet weak var programmeButton: UIButton!
    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet var institutionView: UIView!
    @IBOutlet var ageGroupView: UIView!
    @IBOutlet var programmeTypeView: UIView!
    
    var picker = UIPickerView()
    var institutionArray = NSArray()
    var ageGroupArray = NSArray()
    var programmeTypeArray = NSArray()
    var institutionPassArray = NSArray()
    var ageGroupPassArray = NSArray()
    var programmePassArray = NSArray()
    var selectedInstitution = String()
    var selectedageGroup = String()
    var selectedProgramme = String()
    var institutionPass = String()
    var ageGroupPass = String()
    var programmePass = String()
    var selectedInstitutionRow = 0
    var selectedAgeGroupRow = 0
    var selectedProgrammeRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        self.recordScreenView()
    }
    
    func setupUI() {
        let inst1 = NSLocalizedString("INSTITUTION_1", comment: "INSTITUTION_1")
        let inst2 = NSLocalizedString("INSTITUTION_2", comment: "INSTITUTION_2")
        let inst3 = NSLocalizedString("INSTITUTION_3", comment: "INSTITUTION_3")
        let inst4 = NSLocalizedString("INSTITUTION_4", comment: "INSTITUTION_4")
        let inst5 = NSLocalizedString("INSTITUTION_5", comment: "INSTITUTION_5")
        let inst6 = NSLocalizedString("INSTITUTION_6", comment: "INSTITUTION_6")
        let inst7 = NSLocalizedString("INSTITUTION_7", comment: "INSTITUTION_7")
        let inst8 = NSLocalizedString("INSTITUTION_8", comment: "INSTITUTION_8")
        
        let ageGrp1 = NSLocalizedString("AGE_GROUP_1", comment: "AGE_GROUP_1")
        let ageGrp2 = NSLocalizedString("AGE_GROUP_2", comment: "AGE_GROUP_2")
        let ageGrp3 = NSLocalizedString("AGE_GROUP_3", comment: "AGE_GROUP_3")
        let ageGrp4 = NSLocalizedString("AGE_GROUP_4", comment: "AGE_GROUP_4")
        let ageGrp5 = NSLocalizedString("AGE_GROUP_5", comment: "AGE_GROUP_5")
        let ageGrp6 = NSLocalizedString("AGE_GROUP_6", comment: "AGE_GROUP_6")
        let ageGrp7 = NSLocalizedString("AGE_GROUP_7", comment: "AGE_GROUP_7")
        let ageGrp8 = NSLocalizedString("AGE_GROUP_8", comment: "AGE_GROUP_8")
        let ageGrp9 = NSLocalizedString("AGE_GROUP_9", comment: "AGE_GROUP_9")
        let ageGrp10 = NSLocalizedString("AGE_GROUP_10", comment: "AGE_GROUP_10")
        let ageGrp11 = NSLocalizedString("AGE_GROUP_11", comment: "AGE_GROUP_11")
        let ageGrp12 = NSLocalizedString("AGE_GROUP_12", comment: "AGE_GROUP_12")
        let ageGrp13 = NSLocalizedString("AGE_GROUP_13", comment: "AGE_GROUP_13")
        let ageGrp14 = NSLocalizedString("AGE_GROUP_14", comment: "AGE_GROUP_14")
        
        let pgmType1 = NSLocalizedString("PGM_TYPE_1", comment: "PGM_TYPE_1")
        let pgmType2 = NSLocalizedString("PGM_TYPE_2", comment: "PGM_TYPE_2")
        let pgmType3 = NSLocalizedString("PGM_TYPE_3", comment: "PGM_TYPE_3")
        let pgmType4 = NSLocalizedString("PGM_TYPE_4", comment: "PGM_TYPE_4")
        let pgmType5 = NSLocalizedString("PGM_TYPE_5", comment: "PGM_TYPE_5")
        let pgmType6 = NSLocalizedString("PGM_TYPE_6", comment: "PGM_TYPE_6")
        let pgmType7 = NSLocalizedString("PGM_TYPE_7", comment: "PGM_TYPE_7")
        let pgmType8 = NSLocalizedString("PGM_TYPE_8", comment: "PGM_TYPE_8")
        institutionArray = [inst1,inst2,inst3,inst4,inst5,inst6,inst7,inst8]
        ageGroupArray = [ageGrp1,ageGrp2,ageGrp3,ageGrp4,ageGrp5,ageGrp6,ageGrp7,ageGrp8,ageGrp9,ageGrp10,ageGrp11,ageGrp12,ageGrp13,ageGrp14]
        programmeTypeArray = [pgmType1,pgmType2,pgmType3,pgmType4,pgmType5,pgmType6,pgmType7,pgmType8]
        
        institutionPassArray = ["Years","Public","Cultural","MIA","Mathaf","National","321","Family"]
        ageGroupPassArray = ["Any","Allages","Nursery","Preschool","EarlyPrimary","Primary","Preparatory","Secondary","College","Youth","Adults","Seniors","Families","Special"]
        programmePassArray = ["Art","Field","Gallery","Lecture","Photography","Reading","Research","Workshop"]
        headerView.headerViewDelegate = self
        headerView.headerBackButton.setImage(UIImage(named: "closeX1"), for: .normal)
        headerView.headerBackButton.contentEdgeInsets = UIEdgeInsets(top:14, left:19, bottom: 14, right:19)
        headerView.headerTitle.text = NSLocalizedString("FILTER_LABEL", comment: "FILTER_LABEL in the Filter page").uppercased()
        institutionTitleLabel.text = NSLocalizedString("INSTITUTION_LABEL", comment: "INSTITUTION_LABEL in the Filter page") 
        ageGroupLabel.text = NSLocalizedString("AGE_GROUP_LABEL", comment: "AGE_GROUP_LABEL in the Filter page")
        programmeTypeLabel.text = NSLocalizedString("PROGRAMME_TYPE_LABEL", comment: "PROGRAMME_TYPE_LABEL in the Filter page")
        
        let filterButtonTitle = NSLocalizedString("FILTER_LABEL", comment: "FILTER_LABEL in the Filter page")
        filterButton.setTitle(filterButtonTitle, for: .normal)
        let clearButtonTitle = NSLocalizedString("CLEAR_LABEL", comment: "CLEAR_LABEL in the Filter page")
        clearButton.setTitle(clearButtonTitle, for: .normal)
        institutionText.delegate = self
        ageGroupText.delegate = self
        programmeTypeText.delegate = self
        
        institutionTitleLabel.font = UIFont.closeButtonFont
        ageGroupLabel.font = UIFont.closeButtonFont
        programmeTypeLabel.font = UIFont.closeButtonFont
        institutionText.font = UIFont.englishTitleFont
        ageGroupText.font = UIFont.englishTitleFont
        programmeTypeText.font = UIFont.englishTitleFont
        clearButton.titleLabel?.font = UIFont.clearButtonFont
        filterButton.titleLabel?.font = UIFont.clearButtonFont
        
//        institutionText.text = institutionArray[0] as? String
//        ageGroupText.text = ageGroupArray[0] as? String
//        programmeTypeText.text = programmeTypeArray[0] as? String
//        institutionPass = institutionPassArray[0] as! String
//        ageGroupPass = ageGroupPassArray[0] as! String
//        programmePass = programmePassArray[0] as! String
        let anyString = NSLocalizedString("ANYSTRING", comment: "ANYSTRING in the Filter page")
        institutionText.text = anyString
        ageGroupText.text = anyString
        programmeTypeText.text = anyString
        institutionPass = anyString
        ageGroupPass = anyString
        programmePass = anyString
        addPickerView()
        
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func didTapInstitutionButton(_ sender: UIButton) {
        institutionText.becomeFirstResponder()
        self.institutionButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func didTapageGroupButton(_ sender: UIButton) {
        ageGroupText.becomeFirstResponder()
        self.ageGroupButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func didTapProgrammeTypeButton(_ sender: UIButton) {
        programmeTypeText.becomeFirstResponder()
        self.programmeButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func didTapClear(_ sender: UIButton) {
        self.clearButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        institutionText.text = ""
        ageGroupText.text = ""
        programmeTypeText.text = ""
    }
    
    @IBAction func didTapFilter(_ sender: UIButton) {
        self.filterButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        if let presenter = presentingViewController as? EventViewController {
            presenter.institutionType = institutionPass
            presenter.ageGroupType = ageGroupPass
            presenter.programmeType = programmePass
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func institutionButtonTouchDown(_ sender: UIButton) {
        self.institutionButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func ageGroupButtonTouchDown(_ sender: UIButton) {
        self.ageGroupButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func programmeTypeButtonTouchDown(_ sender: UIButton) {
        self.programmeButton.transform = CGAffineTransform(scaleX: 0.7, y:0.7)
    }
    
    @IBAction func clearButtonTouchDown(_ sender: UIButton) {
        
        
        self.clearButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    @IBAction func filterButtonTouchDown(_ sender: UIButton) {
        self.filterButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    func addPickerView() {
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
    
    //MARK: header delegate
    func headerCloseButtonPressed() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        var viewForTextField : UIView!
        if (textField == institutionText) {
            picker.tag = 0
            picker.selectRow(selectedInstitutionRow, inComponent: 0, animated: true)
            institutionView.backgroundColor = UIColor.filterTextSelectedGray
            ageGroupView.backgroundColor = UIColor.white
            programmeTypeView.backgroundColor = UIColor.white
            viewForTextField = institutionView
        } else if(textField == ageGroupText) {
            picker.tag = 1
            picker.selectRow(selectedAgeGroupRow, inComponent: 0, animated: true)
            institutionView.backgroundColor = UIColor.white
            ageGroupView.backgroundColor = UIColor.filterTextSelectedGray
            programmeTypeView.backgroundColor = UIColor.white
            viewForTextField = ageGroupView
        } else {
            picker.tag = 2
            picker.selectRow(selectedProgrammeRow, inComponent: 0, animated: true)
            institutionView.backgroundColor = UIColor.white
            ageGroupView.backgroundColor = UIColor.white
            programmeTypeView.backgroundColor = UIColor.filterTextSelectedGray
            viewForTextField = programmeTypeView
        }
        let myScreenRect: CGRect = UIScreen.main.bounds
        let pickerHeight : CGFloat = 200
        UIView.beginAnimations( "animateView", context: nil)
        var needToMove: CGFloat = 0
        
        var frame : CGRect = self.view.frame
        if (viewForTextField.frame.origin.y + viewForTextField.frame.size.height+50  > (myScreenRect.size.height - (pickerHeight+50))) {
                needToMove = (viewForTextField.frame.origin.y + viewForTextField.frame.size.height+70 ) - (myScreenRect.size.height - pickerHeight-100)
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
        institutionText.resignFirstResponder()
        ageGroupText.resignFirstResponder()
        programmeTypeText.resignFirstResponder()
        
        return true
    }

    //MARK: Pickerview delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(picker.tag == 0) {
            return institutionArray.count
        } else if(picker.tag == 1) {
            return ageGroupArray.count
        } else {
            return programmeTypeArray.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
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
    
    //MARK: Picker ToolBar Actions
    @IBAction func didTapPrevious(_ sender: UIButton) {
        if (picker.tag == 0 && selectedInstitutionRow != 0) {
            selectedInstitutionRow = selectedInstitutionRow-1
            picker.selectRow(selectedInstitutionRow, inComponent: 0, animated: true)
            selectedInstitution = (institutionArray[selectedInstitutionRow] as? String)!
            institutionPass = (institutionPassArray[selectedInstitutionRow] as? String)!
            institutionText.text = (institutionArray[selectedInstitutionRow] as? String)!
        } else if(picker.tag == 1 && selectedAgeGroupRow != 0) {
            selectedAgeGroupRow = selectedAgeGroupRow-1
            picker.selectRow(selectedAgeGroupRow, inComponent: 0, animated: true)
            selectedageGroup = (ageGroupArray[selectedAgeGroupRow] as? String)!
            ageGroupPass = (ageGroupPassArray[selectedAgeGroupRow] as? String)!
            ageGroupText.text = (ageGroupArray[selectedAgeGroupRow] as? String)!
        } else if(picker.tag == 2 && selectedProgrammeRow != 0) {
            selectedProgrammeRow = selectedProgrammeRow - 1
            picker.selectRow(selectedProgrammeRow, inComponent: 0, animated: true)
            selectedProgramme = (programmeTypeArray[selectedProgrammeRow] as? String)!
            programmePass = (programmePassArray[selectedProgrammeRow] as? String)!
            programmeTypeText.text = (programmeTypeArray[selectedProgrammeRow] as? String)!
        }
    }
    
    @IBAction func didTapNext(_ sender: UIButton) {
        if (picker.tag == 0 && selectedInstitutionRow != institutionArray.count-1) {
            selectedInstitutionRow = selectedInstitutionRow+1
            picker.selectRow(selectedInstitutionRow, inComponent: 0, animated: true)
            selectedInstitution = (institutionArray[selectedInstitutionRow] as? String)!
            institutionPass = (institutionPassArray[selectedInstitutionRow] as? String)!
            institutionText.text = (institutionArray[selectedInstitutionRow] as? String)!
        } else if(picker.tag == 1 && selectedAgeGroupRow != ageGroupArray.count-1) {
            selectedAgeGroupRow = selectedAgeGroupRow+1
            picker.selectRow(selectedAgeGroupRow, inComponent: 0, animated: true)
            selectedageGroup = (ageGroupArray[selectedAgeGroupRow] as? String)!
            ageGroupPass = (ageGroupPassArray[selectedAgeGroupRow] as? String)!
            ageGroupText.text = (ageGroupArray[selectedAgeGroupRow] as? String)!
        } else if(picker.tag == 2 && selectedProgrammeRow != programmeTypeArray.count-1) {
            selectedProgrammeRow = selectedProgrammeRow+1
            picker.selectRow(selectedProgrammeRow, inComponent: 0, animated: true)
            selectedProgramme = (programmeTypeArray[selectedProgrammeRow] as? String)!
            programmePass = (programmePassArray[selectedProgrammeRow] as? String)!
            programmeTypeText.text = (programmeTypeArray[selectedProgrammeRow] as? String)!
        }
    }
    
    @IBAction func didTapPickerClose(_ sender: UIButton) {
        if (picker.tag == 0) {
            institutionText.text = selectedInstitution
        } else if(picker.tag == 1) {
            ageGroupText.text = selectedageGroup
        } else {
            programmeTypeText.text = selectedProgramme
        }
        institutionText.resignFirstResponder()
        ageGroupText.resignFirstResponder()
        programmeTypeText.resignFirstResponder()
    }
    func recordScreenView() {
        let screenClass = String(describing: type(of: self))
        Analytics.setScreenName(FILTER_VC, screenClass: screenClass)
    }
}
