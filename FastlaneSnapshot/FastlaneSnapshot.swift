//
//  FastlaneSnapshot.swift
//  FastlaneSnapshot
//
//  Created by Andreas Lüdemann on 11/08/2019.
//  Copyright © 2019 Andreas Lüdemann. All rights reserved.
//

import XCTest

class FastlaneSnapshot: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func testGenerateScreenshots() {
        
        let deckTitle = localizedString("Snapshot.DeckTitle")
        let cardTitle = localizedString("Snapshot.CardTitle")
        let cardContent = localizedString("Snapshot.CardContent")
        
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
        
        app.buttons["stop"].tap()
        app.navigationBars[deckTitle].buttons["QCards"].tap()
        app.tables.staticTexts[deckTitle].swipeLeft()
        
        app.buttons.element(boundBy: 3).tap()
        app.buttons["yesButton"].tap()
    }
}
