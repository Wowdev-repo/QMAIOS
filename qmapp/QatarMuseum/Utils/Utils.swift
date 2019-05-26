//
//  Utils.swift
//  QatarMuseums
//
//  Created by Subins P Jose on 21/05/19.
//  Copyright © 2019 Wakralab. All rights reserved.
//

import Foundation

class Utils {
    
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
}
