//
//  Utils.swift
//  QatarMuseums
//
//  Created by Subins P Jose on 21/05/19.
//  Copyright © 2019 Qatar Museums. All rights reserved.
//

import Foundation

class Utils {
    
    
    static func getLanguageCode(_ code: String) -> String {
        if code == ENG_LANGUAGE {
            return "1"
        }
        return "0"
    }
    
    /// Get language string
    ///
    /// - Returns: String, 1 for English and 0 for arabic
    static func getLanguage() -> String {
        var language = "0"
        if LocalizationLanguage.currentAppleLanguage() == ENG_LANGUAGE {
            language = "1"
        }
        return language
    }
    
    static func uniqueDate(_ date: Date) -> String? {
        if let newDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date) {
            let timestamp = newDate.timeIntervalSince1970
            let dateString = String(timestamp)
            let delimiter = "."
            let token = dateString.components(separatedBy: delimiter)
            return token.isEmpty ? nil : token.first
        }
        
        return nil
    }
}
