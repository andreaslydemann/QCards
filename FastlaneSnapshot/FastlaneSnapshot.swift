//
//  FastlaneSnapshot.swift
//  FastlaneSnapshot
//
//  Created by Andreas Lüdemann on 11/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import XCTest

let deckTitle = "My presentation"
let cardTitle = "First topic"
let cardContent = "Here are some very important points"

class FastlaneSnapshot: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        let app = XCUIApplication()
        
        app.buttons["stop"].tap()
        app.navigationBars[deckTitle].buttons["QCards"].tap()
        app.tables.staticTexts[deckTitle].swipeLeft()
        
        app.buttons.element(boundBy: 3).tap()
        app.buttons["yesButton"].tap()
    }
    
    func testGenerateScreenshots() {

        let app = XCUIApplication()
        app.navigationBars["QCards"].buttons["settings"].tap()
        
        app.tables.cells.element(boundBy: 0).tap()
        app.tables.cells.element(boundBy: 1).tap()
        
        app.navigationBars.element(boundBy: 0).buttons["saveButton"].tap()
        app.navigationBars.element(boundBy: 0).buttons["okButton"].tap()
        
        app.navigationBars["QCards"].buttons["createDeckButton"].tap()
        
        let deckTitleField = app.textFields["deckTitleTextField"]
        deckTitleField.tap()
        deckTitleField.typeText(deckTitle)
        
        app.buttons["addButton"].tap()
        
        snapshot("AllDecks")
        
        app.tables.staticTexts[deckTitle].tap()
        app.navigationBars[deckTitle].buttons["addButton"].tap()
        
        let cardTitleTextField = app.textFields["cardTitleTextField"]
        cardTitleTextField.tap()
        cardTitleTextField.typeText(cardTitle)
        
        let cardContentTextView = app.textViews["cardContentTextView"]
        cardContentTextView.tap()
        cardContentTextView.typeText(cardContent)
        
        snapshot("CreateCard")
        
        app.buttons["saveButton"].tap()
        
        snapshot("AllCards")
        
        app.buttons["play"].tap()
        
        snapshot("Presentation")
    }
    /*
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
    
    func localizedString(_ key: String) -> String {
        let testBundle = Bundle(for: FastlaneSnapshot.self)
        if let currentLanguage = currentLanguage,
            let testBundlePath = testBundle.path(forResource: currentLanguage.localeCode, ofType: "lproj") ?? testBundle.path(forResource: currentLanguage.langCode, ofType: "lproj"),
            let localizedBundle = Bundle(path: testBundlePath)
        {
            return NSLocalizedString(key, bundle: localizedBundle, comment: "")
        }
        return "?"
    }*/
}

