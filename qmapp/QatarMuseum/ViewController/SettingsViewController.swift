//
//  SettingsViewController.swift
//  QatarMuseums
//
//  Created by Exalture on 23/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Crashlytics
import UIKit

class SettingsViewController: UIViewController,HeaderViewProtocol,EventPopUpProtocol {
   
    

    @IBOutlet weak var headerView: CommonHeaderView!
    @IBOutlet weak var selectLanguageLabel: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var arabicLabel: UILabel!
    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var eventUpdateLabel: UILabel!
    @IBOutlet weak var exhibitionLabel: UILabel!
    @IBOutlet weak var museumLabel: UILabel!
    @IBOutlet weak var culturePassLabel: UILabel!
    @IBOutlet weak var tourGuideLabel: UILabel!
    @IBOutlet weak var languageSwitch: UISwitch!
    @IBOutlet weak var eventSwitch: UISwitch!
    @IBOutlet weak var exhibitionSwitch: UISwitch!
    @IBOutlet weak var museumSwitch: UISwitch!
    @IBOutlet weak var culturePassSwitch: UISwitch!
    @IBOutlet weak var tourGuideSwitch: UISwitch!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var settingsInnerView: UIView!
    
    var eventPopup : EventPopupView = EventPopupView()
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        disableAllSwitches()
    }
    
    func setupUI() {
        headerView.headerViewDelegate = self
        headerView.headerTitle.text = NSLocalizedString("SETTINGS_LABEL", comment: "SETTINGS_LABEL in the Settings page")
        selectLanguageLabel.text = NSLocalizedString("SELECT_LANGUAGE_LABEL", comment: "SELECT_LANGUAGE_LABEL in the Settings page")
        notificationTitleLabel.text = NSLocalizedString("NOTIFICATION_SETTINGS", comment: "NOTIFICATION_SETTINGS in the Settings page")
        arabicLabel.text = NSLocalizedString("ARABIC", comment: "ARABIC in the Settings page")
        englishLabel.text = NSLocalizedString("ENGLISH", comment: "ENGLISH in the Settings page")
        eventUpdateLabel.text = NSLocalizedString("EVENT_UPDATE_LABEL", comment: "EVENT_UPDATE_LABEL in the Settings page")
        exhibitionLabel.text = NSLocalizedString("EXHIBITION_UPDATE_LABEL", comment: "EXHIBITION_UPDATE_LABEL in the Settings page")
        museumLabel.text = NSLocalizedString("MUSEUM_UPDATE_LABEL", comment: "MUSEUM_UPDATE_LABEL in the Settings page")
        culturePassLabel.text = NSLocalizedString("CULTUREPASS_UPDATE_LABEL", comment: "CULTUREPASS_UPDATE_LABEL in the Settings page")
        tourGuideLabel.text = NSLocalizedString("TOURGUIDE_UPDATE_LABEL", comment: "TOURGUIDE_UPDATE_LABEL in the Settings page")
        applyButton.setTitle(NSLocalizedString("APPLY", comment: "APPLY in the Settings page"), for: .normal)
        resetButton.setTitle(NSLocalizedString("RESET_TO_DEFAULT", comment: "RESET_TO_DEFAULT in the Settings page"), for: .normal)
        
        //setting font for english and Arabic
        headerView.headerTitle.font = UIFont.headerFont
        selectLanguageLabel.font = UIFont.headerFont
        arabicLabel.font = UIFont.englishTitleFont
        englishLabel.font = UIFont.englishTitleFont
        notificationTitleLabel.font = UIFont.headerFont
        eventUpdateLabel.font = UIFont.settingsUpdateLabelFont
        exhibitionLabel.font = UIFont.settingsUpdateLabelFont
        museumLabel.font = UIFont.settingsUpdateLabelFont
        culturePassLabel.font = UIFont.settingsUpdateLabelFont
        tourGuideLabel.font = UIFont.settingsUpdateLabelFont
        resetButton.titleLabel?.font = UIFont.clearButtonFont
        applyButton.titleLabel?.font = UIFont.clearButtonFont
        
       self.languageSwitch.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
       
        self.eventSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.exhibitionSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.museumSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.culturePassSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.tourGuideSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            languageSwitch.isOn = false
            let offColor = UIColor.red
            languageSwitch.tintColor = offColor
            languageSwitch.layer.cornerRadius = 16
            languageSwitch.backgroundColor = offColor
            headerView.headerBackButton.setImage(UIImage(named: "back_buttonX1"), for: .normal)
        } else {
            languageSwitch.isOn = true
             headerView.headerBackButton.setImage(UIImage(named: "back_mirrorX1"), for: .normal)
        }
        
    }
    
    func disableAllSwitches() {
        let disableColor = UIColor.lightGrayColor
        eventSwitch.onTintColor = disableColor
        eventSwitch.isEnabled = false

        exhibitionSwitch.onTintColor = disableColor
        exhibitionSwitch.isEnabled = false

        museumSwitch.onTintColor = disableColor
        museumSwitch.isEnabled = false

        culturePassSwitch.onTintColor = disableColor
        culturePassSwitch.isEnabled = false

        tourGuideSwitch.onTintColor = disableColor
        tourGuideSwitch.isEnabled = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func toggleLanguageSwitch(_ sender: UISwitch) {
        let offColor = UIColor.red
        //Change to Arabic
        if (languageSwitch.isOn) {
            languageSwitch.onTintColor = UIColor.settingsSwitchOnTint
            loadConfirmationPopup()
        }
        else {
            languageSwitch.tintColor = offColor
            languageSwitch.layer.cornerRadius = 16
            languageSwitch.backgroundColor = offColor
            loadConfirmationPopup()
        }
    }
    @IBAction func toggleEventSwitch(_ sender: UISwitch) {
        let offColor = UIColor.red
        if (eventSwitch.isOn) {
            eventSwitch.onTintColor = UIColor.settingsSwitchOnTint
        }
        else {
            eventSwitch.tintColor = offColor
            eventSwitch.layer.cornerRadius = 16
            eventSwitch.backgroundColor = offColor
        }
    }
    @IBAction func toggleExhibitionSwitch(_ sender: UISwitch) {
        let offColor = UIColor.red
        if (exhibitionSwitch.isOn) {
            exhibitionSwitch.onTintColor = UIColor.settingsSwitchOnTint
        }
        else {
            exhibitionSwitch.tintColor = offColor
            exhibitionSwitch.layer.cornerRadius = 16
            exhibitionSwitch.backgroundColor = offColor
        }
    }
    @IBAction func toggleMuseumSwitch(_ sender: UISwitch) {
        let offColor = UIColor.red
        if (museumSwitch.isOn) {
            museumSwitch.onTintColor = UIColor.settingsSwitchOnTint
        }
        else {
            museumSwitch.tintColor = offColor
            museumSwitch.layer.cornerRadius = 16
            museumSwitch.backgroundColor = offColor
        }
    }
    @IBAction func toggleCulturePassSwitch(_ sender: UISwitch) {
        let offColor = UIColor.red
        if (culturePassSwitch.isOn) {
            culturePassSwitch.onTintColor = UIColor.settingsSwitchOnTint
        }
        else {
            culturePassSwitch.tintColor = offColor
            culturePassSwitch.layer.cornerRadius = 16
            culturePassSwitch.backgroundColor = offColor
        }
    }
    @IBAction func toggleTourGuideSwitch(_ sender: UISwitch) {
        let offColor = UIColor.red
        if (tourGuideSwitch.isOn) {
            tourGuideSwitch.onTintColor = UIColor.settingsSwitchOnTint
        }
        else {
            tourGuideSwitch.tintColor = offColor
            tourGuideSwitch.layer.cornerRadius = 16
            tourGuideSwitch.backgroundColor = offColor
        }
    }
    
    @IBAction func didTapResetButton(_ sender: UIButton) {
        self.resetButton.backgroundColor = UIColor.profilePink
        self.resetButton.setTitleColor(UIColor.whiteColor, for: .normal)
        self.resetButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func didTapApplyButton(_ sender: UIButton) {
        self.applyButton.backgroundColor = UIColor.viewMycultureBlue
        self.applyButton.setTitleColor(UIColor.white, for: .normal)
        self.applyButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func resetButtonTouchDown(_ sender: UIButton) {
        self.resetButton.backgroundColor = UIColor.profileLightPink
        self.resetButton.setTitleColor(UIColor.viewMyFavDarkPink, for: .normal)
        self.resetButton.transform = CGAffineTransform(scaleX: 0.7, y:0.7)
    }
    @IBAction func applyButtonTouchDown(_ sender: UIButton) {
        self.applyButton.backgroundColor = UIColor.viewMycultureLightBlue
        self.applyButton.setTitleColor(UIColor.viewMyculTitleBlue, for: .normal)
        self.applyButton.transform = CGAffineTransform(scaleX: 0.7, y:0.7)
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
    //MARK: Event Popup Delegate
    func loadConfirmationPopup() {
        eventPopup  = EventPopupView(frame: self.view.frame)
       // eventPopup.eventPopupHeight.constant = 250
        eventPopup.eventPopupDelegate = self
        eventPopup.eventTitle.text = NSLocalizedString("CHANGE_LANGUAGE_TITLE", comment: "CHANGE_LANGUAGE_TITLE  in the popup view")
        eventPopup.eventDescription.text = NSLocalizedString("SETTINGS_REDIRECTION_MSG", comment: "SETTINGS_REDIRECTION_MSG  in the popup view")
        eventPopup.addToCalendarButton.setTitle(NSLocalizedString("CONTINUE_TITLE", comment: "CONTINUE_TITLE  in the popup view"), for: .normal)
        self.view.addSubview(eventPopup)
        }
    func eventCloseButtonPressed() {
        if (self.languageSwitch.isOn == true) {
            self.languageSwitch.isOn = false
        }
        else{
            self.languageSwitch.isOn = true
        }
        self.eventPopup.removeFromSuperview()
    }
    
    func addToCalendarButtonPressed() {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            LocalizationLanguage.setAppleLAnguageTo(lang: "ar")
            languageKey = 2
            UserDefaults.standard.set(true, forKey: "Arabic")
            if #available(iOS 9.0, *) {
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
//                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController

                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = homeViewController
                
                
            } else {
                // Fallback on earlier versions
            }
        }
        else {
            LocalizationLanguage.setAppleLAnguageTo(lang: "en")
            languageKey = 1
            UserDefaults.standard.set(false, forKey: "Arabic")
            if #available(iOS 9.0, *) {
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
//                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeId") as! HomeViewController
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = homeViewController
                // self.dismiss(animated: false, completion: nil)
                
            } else {
                // Fallback on earlier versions
                
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    


}
