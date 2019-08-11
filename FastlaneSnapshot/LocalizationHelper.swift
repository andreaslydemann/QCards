//
//  LocalizationHelper.swift
//  FastlaneSnapshot
//
//  Created by Andreas Lüdemann on 11/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import Foundation

func localizedString(key: String) -> String {
    let localizationBundle = Bundle(path: Bundle(for: FastlaneSnapshot.self)
        .path(forResource: Locale(identifier: deviceLanguage).languageCode, ofType: "lproj")!)
    let result = NSLocalizedString(key, bundle: localizationBundle!, comment: "")
    return result
}
