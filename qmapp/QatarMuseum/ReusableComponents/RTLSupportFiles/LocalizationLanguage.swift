//
//  LocalizationLanguage.swift
//  QFind
//
//  Created by Exalture on 22/01/18.
//  Copyright © 2018 QFind. All rights reserved.
//

import UIKit
import CocoaLumberjack
let APPLE_LANGUAGE_KEY = "AppleLanguages"
class LocalizationLanguage {
    /// get current Apple language
    class func currentAppleLanguage() -> String{
        
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as! NSArray
        let current = langArray.firstObject as! String
        let endIndex = current.startIndex
        var currentWithoutLocale = current.substring(to: current.index(endIndex, offsetBy: 2))
        if ((currentWithoutLocale != "en") && (currentWithoutLocale != "ar")){
            currentWithoutLocale = "en"
        }
        
        return currentWithoutLocale
    }
    
    class func currentAppleLanguageFull() -> String{
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as! NSArray
        let current = langArray.firstObject as! String
//        DDLogInfo("File: \(#file)" + "Function: \(#function)" + "Language: \(current)")
        return current
    }
    
    /// set @lang to be the first in Applelanguages list
    class func setAppleLAnguageTo(lang: String) {
        let userdef = UserDefaults.standard
        userdef.set([lang,currentAppleLanguage()], forKey: APPLE_LANGUAGE_KEY)
        userdef.synchronize()
    }
    
    class var isRTL: Bool {
        return LocalizationLanguage.currentAppleLanguage() == "ar"
    }
}
