//
//  LocalizationHelper.swift
//  FastlaneSnapshot
//
//  Created by Andreas Lüdemann on 11/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation

func localizedString(_ key: String) -> String {
    let testBundle = Bundle(for: FastlaneSnapshot.self)
    if let currentLanguage = currentLanguage,
        let testBundlePath = testBundle.path(forResource: currentLanguage.localeCode, ofType: "lproj") ?? testBundle.path(forResource: currentLanguage.langCode, ofType: "lproj"),
        let localizedBundle = Bundle(path: testBundlePath) {
        return NSLocalizedString(key, bundle: localizedBundle, comment: "")
    }
    return "?"
}

var currentLanguage: (langCode: String, localeCode: String)? {
    let currentLocale = Locale(identifier: Locale.preferredLanguages.first!)
    guard let langCode = currentLocale.languageCode else {
        return nil
    }
    var localeCode = langCode
    if let scriptCode = currentLocale.scriptCode {
        localeCode = "\(langCode)-\(scriptCode)"
    } else if let regionCode = currentLocale.regionCode {
        localeCode = "\(langCode)-\(regionCode)"
    }
    return (langCode, localeCode)
}
