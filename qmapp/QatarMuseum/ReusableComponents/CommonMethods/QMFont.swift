//
//  QMFont.swift
//  QatarMuseums
//
//  Created by Exalture on 27/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation
extension UIFont {
    static var headerFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 20)!
        }
        else {
            return UIFont.init(name: "DINNextLTArabic-Bold", size: 20)!
        }
    }
    static var heritageTitleFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 20)!
        }
        else{
            return UIFont.init(name: "DINNextLTArabic-Regular", size:20)!
        }
        
    }
   
    static var englishTitleFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 17)!
        }
        else{
            return UIFont.init(name: "DINNextLTArabic-Regular", size:17)!
        }
        
    }
    static var discoverButtonFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 17)!
        }
        else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:17)!
        }
        
    }
    static var settingsUpdateLabelFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 18)!
        }
        else{
            return UIFont.init(name: "DINNextLTArabic-Regular", size:18)!
        }
        
    }
    static var settingResetButtonFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 15)!
        }
        else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:15)!
        }
        
    }
    static var eventPopupTitleFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 23)!
        }
        else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:23)!
        }
        
    }
    static var closeButtonFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 18)!
        }
        else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:18)!
        }
        
    }
    static var sideMenuLabelFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 15)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Regular", size:15)!
        }
        
    }
    static var collectionFirstDescriptionFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 16)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Regular", size:16)!
        }
        
    }
    static var popupProductionFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 16)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:16)!
        }
        
    }
    static var collectionSubTitleFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Light", size: 19)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Light", size:19)!
        }
        
    }
    static var museumTitleFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 37)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:37)!
        }
        
    }
    static var exhibitionDateLabelFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 12)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Regular", size:13)!
        }
        
    }
    static var eventCellTitleFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 13)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:13)!
        }
    }
    static var clearButtonFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 14)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:14)!
        }
    }
    static var homeTitleFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 21)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Regular", size:21)!
        }
    }
    static var diningHeaderFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 23)!
        } else {
            return UIFont.init(name: "DINNextLTArabic-Regular", size: 23)!
        }
    }
    static var artifactNumberFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 30)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Regular", size:30)!
        }
    }
    static var tourGuidesFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 34)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:34)!
        }
    }
    static var selfGuidedFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 26)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:26)!
        }
    }
    static var tourListTitleFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 26)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Regular", size:26)!
        }
    }
    static var miatourGuideFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 38)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:38)!
        }
    }
    static var startTourFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 19)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:19)!
        }
    }
    static var invitationTextFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 19)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Regular", size:19)!
        }
    }
    static var oopsTitleFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 32)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:30)!
        }
    }
    static var tryAgainFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Bold", size: 22)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Bold", size:21)!
        }
    }
    static var eventDescriptionFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 11)!
        } else{
            return UIFont.init(name: "DINNextLTArabic-Regular", size:11)!
        }
        
    }
    static var downloadLabelFont: UIFont {
        if ((LocalizationLanguage.currentAppleLanguage()) == "en") {
            return UIFont.init(name: "DINNextLTPro-Regular", size: 14)!
        } else {
            return UIFont.init(name: "DINNextLTArabic-Regular", size: 14)!
        }
    }
}
